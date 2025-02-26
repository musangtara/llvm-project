#include "clang/Analysis/FlowSensitive/Models/UncheckedOptionalAccessModel.h"
#include "clang/AST/ASTContext.h"
#include "clang/AST/Expr.h"
#include "clang/AST/ExprCXX.h"
#include "clang/AST/Stmt.h"
#include "clang/ASTMatchers/ASTMatchers.h"
#include "clang/Analysis/FlowSensitive/DataflowEnvironment.h"
#include "clang/Analysis/FlowSensitive/MatchSwitch.h"
#include "clang/Analysis/FlowSensitive/SourceLocationsLattice.h"
#include "clang/Analysis/FlowSensitive/Value.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/Casting.h"
#include <cassert>
#include <memory>
#include <utility>

namespace clang {
namespace dataflow {
namespace {

using namespace ::clang::ast_matchers;

using LatticeTransferState = TransferState<SourceLocationsLattice>;

static auto optionalClass() {
  return classTemplateSpecializationDecl(
      anyOf(hasName("std::optional"), hasName("std::__optional_storage_base"),
            hasName("__optional_destruct_base"), hasName("absl::optional"),
            hasName("base::Optional")),
      hasTemplateArgument(0, refersToType(type().bind("T"))));
}

static auto hasOptionalType() { return hasType(optionalClass()); }

static auto isOptionalMemberCallWithName(llvm::StringRef MemberName) {
  return cxxMemberCallExpr(
      on(expr(unless(cxxThisExpr()))),
      callee(cxxMethodDecl(hasName(MemberName), ofClass(optionalClass()))));
}

static auto isOptionalOperatorCallWithName(llvm::StringRef OperatorName) {
  return cxxOperatorCallExpr(hasOverloadedOperatorName(OperatorName),
                             callee(cxxMethodDecl(ofClass(optionalClass()))));
}

static auto isMakeOptionalCall() {
  return callExpr(
      callee(functionDecl(hasAnyName(
          "std::make_optional", "base::make_optional", "absl::make_optional"))),
      hasOptionalType());
}

/// Creates a symbolic value for an `optional` value using `HasValueVal` as the
/// symbolic value of its "has_value" property.
StructValue &createOptionalValue(Environment &Env, BoolValue &HasValueVal) {
  auto OptionalVal = std::make_unique<StructValue>();
  OptionalVal->setProperty("has_value", HasValueVal);
  return Env.takeOwnership(std::move(OptionalVal));
}

/// Returns the symbolic value that represents the "has_value" property of the
/// optional value `Val`. Returns null if `Val` is null.
static BoolValue *getHasValue(Value *Val) {
  if (auto *OptionalVal = cast_or_null<StructValue>(Val)) {
    return cast<BoolValue>(OptionalVal->getProperty("has_value"));
  }
  return nullptr;
}

static void initializeOptionalReference(const Expr *OptionalExpr,
                                        LatticeTransferState &State) {
  if (auto *OptionalVal = cast_or_null<StructValue>(
          State.Env.getValue(*OptionalExpr, SkipPast::Reference))) {
    if (OptionalVal->getProperty("has_value") == nullptr) {
      OptionalVal->setProperty("has_value", State.Env.makeAtomicBoolValue());
    }
  }
}

static void transferUnwrapCall(const Expr *UnwrapExpr, const Expr *ObjectExpr,
                               LatticeTransferState &State) {
  if (auto *OptionalVal = cast_or_null<StructValue>(
          State.Env.getValue(*ObjectExpr, SkipPast::ReferenceThenPointer))) {
    auto *HasValueVal = getHasValue(OptionalVal);
    assert(HasValueVal != nullptr);

    if (State.Env.flowConditionImplies(*HasValueVal))
      return;
  }

  // Record that this unwrap is *not* provably safe.
  State.Lattice.getSourceLocations().insert(ObjectExpr->getBeginLoc());
}

void transferMakeOptionalCall(const CallExpr *E, LatticeTransferState &State) {
  auto &Loc = State.Env.createStorageLocation(*E);
  State.Env.setStorageLocation(*E, Loc);
  State.Env.setValue(
      Loc, createOptionalValue(State.Env, State.Env.getBoolLiteralValue(true)));
}

static void transferOptionalHasValueCall(const CXXMemberCallExpr *CallExpr,
                                         LatticeTransferState &State) {
  if (auto *OptionalVal = cast_or_null<StructValue>(
          State.Env.getValue(*CallExpr->getImplicitObjectArgument(),
                             SkipPast::ReferenceThenPointer))) {
    auto *HasValueVal = getHasValue(OptionalVal);
    assert(HasValueVal != nullptr);

    auto &CallExprLoc = State.Env.createStorageLocation(*CallExpr);
    State.Env.setValue(CallExprLoc, *HasValueVal);
    State.Env.setStorageLocation(*CallExpr, CallExprLoc);
  }
}

void transferEmplaceCall(const CXXMemberCallExpr *E,
                         LatticeTransferState &State) {
  if (auto *OptionalLoc = State.Env.getStorageLocation(
          *E->getImplicitObjectArgument(), SkipPast::ReferenceThenPointer)) {
    State.Env.setValue(
        *OptionalLoc,
        createOptionalValue(State.Env, State.Env.getBoolLiteralValue(true)));
  }
}

void transferResetCall(const CXXMemberCallExpr *E,
                       LatticeTransferState &State) {
  if (auto *OptionalLoc = State.Env.getStorageLocation(
          *E->getImplicitObjectArgument(), SkipPast::ReferenceThenPointer)) {
    State.Env.setValue(
        *OptionalLoc,
        createOptionalValue(State.Env, State.Env.getBoolLiteralValue(false)));
  }
}

static auto buildTransferMatchSwitch() {
  return MatchSwitchBuilder<LatticeTransferState>()
      // Attach a symbolic "has_value" state to optional values that we see for
      // the first time.
      .CaseOf(expr(anyOf(declRefExpr(), memberExpr()), hasOptionalType()),
              initializeOptionalReference)

      // make_optional
      .CaseOf(isMakeOptionalCall(), transferMakeOptionalCall)

      // optional::value
      .CaseOf(
          isOptionalMemberCallWithName("value"),
          +[](const CXXMemberCallExpr *E, LatticeTransferState &State) {
            transferUnwrapCall(E, E->getImplicitObjectArgument(), State);
          })

      // optional::operator*, optional::operator->
      .CaseOf(
          expr(anyOf(isOptionalOperatorCallWithName("*"),
                     isOptionalOperatorCallWithName("->"))),
          +[](const CallExpr *E, LatticeTransferState &State) {
            transferUnwrapCall(E, E->getArg(0), State);
          })

      // optional::has_value
      .CaseOf(isOptionalMemberCallWithName("has_value"),
              transferOptionalHasValueCall)

      // optional::operator bool
      .CaseOf(isOptionalMemberCallWithName("operator bool"),
              transferOptionalHasValueCall)

      // optional::emplace
      .CaseOf(isOptionalMemberCallWithName("emplace"), transferEmplaceCall)

      // optional::reset
      .CaseOf(isOptionalMemberCallWithName("reset"), transferResetCall)

      .Build();
}

} // namespace

UncheckedOptionalAccessModel::UncheckedOptionalAccessModel(ASTContext &Ctx)
    : DataflowAnalysis<UncheckedOptionalAccessModel, SourceLocationsLattice>(
          Ctx),
      TransferMatchSwitch(buildTransferMatchSwitch()) {}

void UncheckedOptionalAccessModel::transfer(const Stmt *S,
                                            SourceLocationsLattice &L,
                                            Environment &Env) {
  LatticeTransferState State(L, Env);
  TransferMatchSwitch(*S, getASTContext(), State);
}

} // namespace dataflow
} // namespace clang
