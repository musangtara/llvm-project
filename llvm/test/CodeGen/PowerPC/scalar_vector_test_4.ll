; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr9 -verify-machineinstrs -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names \
; RUN:    -mtriple=powerpc64le-unknown-linux-gnu < %s | FileCheck %s --check-prefix=P9LE
; RUN: llc -mcpu=pwr9 -verify-machineinstrs -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names \
; RUN:    -mtriple=powerpc64-unknown-linux-gnu < %s | FileCheck %s --check-prefix=P9BE
; RUN: llc -mcpu=pwr8 -verify-machineinstrs -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names \
; RUN:    -mtriple=powerpc64le-unknown-linux-gnu < %s | FileCheck %s --check-prefix=P8LE
; RUN: llc -mcpu=pwr8 -verify-machineinstrs -ppc-vsr-nums-as-vr -ppc-asm-full-reg-names \
; RUN:    -mtriple=powerpc64-unknown-linux-gnu < %s | FileCheck %s --check-prefix=P8BE

; Function Attrs: norecurse nounwind readonly
define <4 x i32> @s2v_test1(i32* nocapture readonly %int32, <4 x i32> %vec)  {
; P9LE-LABEL: s2v_test1:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lwz r3, 0(r3)
; P9LE-NEXT:    mtfprwz f0, r3
; P9LE-NEXT:    xxinsertw v2, vs0, 12
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test1:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lwz r3, 0(r3)
; P9BE-NEXT:    mtfprwz f0, r3
; P9BE-NEXT:    xxinsertw v2, vs0, 0
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test1:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addis r4, r2, .LCPI0_0@toc@ha
; P8LE-NEXT:    lxsiwzx v4, 0, r3
; P8LE-NEXT:    addi r4, r4, .LCPI0_0@toc@l
; P8LE-NEXT:    lvx v3, 0, r4
; P8LE-NEXT:    vperm v2, v2, v4, v3
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test1:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    lfiwzx f0, 0, r3
; P8BE-NEXT:    xxsldwi vs1, v2, vs0, 1
; P8BE-NEXT:    xxmrghw v2, v2, vs0
; P8BE-NEXT:    xxsldwi v2, v2, vs1, 3
; P8BE-NEXT:    blr
entry:
  %0 = load i32, i32* %int32, align 4
  %vecins = insertelement <4 x i32> %vec, i32 %0, i32 0
  ret <4 x i32> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <4 x i32> @s2v_test2(i32* nocapture readonly %int32, <4 x i32> %vec)  {
; P9LE-LABEL: s2v_test2:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lwz r3, 4(r3)
; P9LE-NEXT:    mtfprwz f0, r3
; P9LE-NEXT:    xxinsertw v2, vs0, 12
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test2:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lwz r3, 4(r3)
; P9BE-NEXT:    mtfprwz f0, r3
; P9BE-NEXT:    xxinsertw v2, vs0, 0
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test2:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addis r4, r2, .LCPI1_0@toc@ha
; P8LE-NEXT:    addi r3, r3, 4
; P8LE-NEXT:    addi r4, r4, .LCPI1_0@toc@l
; P8LE-NEXT:    lxsiwzx v4, 0, r3
; P8LE-NEXT:    lvx v3, 0, r4
; P8LE-NEXT:    vperm v2, v2, v4, v3
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test2:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    addi r3, r3, 4
; P8BE-NEXT:    lfiwzx f0, 0, r3
; P8BE-NEXT:    xxsldwi vs1, v2, vs0, 1
; P8BE-NEXT:    xxmrghw v2, v2, vs0
; P8BE-NEXT:    xxsldwi v2, v2, vs1, 3
; P8BE-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds i32, i32* %int32, i64 1
  %0 = load i32, i32* %arrayidx, align 4
  %vecins = insertelement <4 x i32> %vec, i32 %0, i32 0
  ret <4 x i32> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <4 x i32> @s2v_test3(i32* nocapture readonly %int32, <4 x i32> %vec, i32 signext %Idx)  {
; P9LE-LABEL: s2v_test3:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    sldi r4, r7, 2
; P9LE-NEXT:    lwzx r3, r3, r4
; P9LE-NEXT:    mtfprwz f0, r3
; P9LE-NEXT:    xxinsertw v2, vs0, 12
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test3:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    sldi r4, r7, 2
; P9BE-NEXT:    lwzx r3, r3, r4
; P9BE-NEXT:    mtfprwz f0, r3
; P9BE-NEXT:    xxinsertw v2, vs0, 0
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test3:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addis r4, r2, .LCPI2_0@toc@ha
; P8LE-NEXT:    sldi r5, r7, 2
; P8LE-NEXT:    addi r4, r4, .LCPI2_0@toc@l
; P8LE-NEXT:    lxsiwzx v3, r3, r5
; P8LE-NEXT:    lvx v4, 0, r4
; P8LE-NEXT:    vperm v2, v2, v3, v4
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test3:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    sldi r4, r7, 2
; P8BE-NEXT:    lfiwzx f0, r3, r4
; P8BE-NEXT:    xxsldwi vs1, v2, vs0, 1
; P8BE-NEXT:    xxmrghw v2, v2, vs0
; P8BE-NEXT:    xxsldwi v2, v2, vs1, 3
; P8BE-NEXT:    blr
entry:
  %idxprom = sext i32 %Idx to i64
  %arrayidx = getelementptr inbounds i32, i32* %int32, i64 %idxprom
  %0 = load i32, i32* %arrayidx, align 4
  %vecins = insertelement <4 x i32> %vec, i32 %0, i32 0
  ret <4 x i32> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <4 x i32> @s2v_test4(i32* nocapture readonly %int32, <4 x i32> %vec)  {
; P9LE-LABEL: s2v_test4:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lwz r3, 4(r3)
; P9LE-NEXT:    mtfprwz f0, r3
; P9LE-NEXT:    xxinsertw v2, vs0, 12
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test4:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lwz r3, 4(r3)
; P9BE-NEXT:    mtfprwz f0, r3
; P9BE-NEXT:    xxinsertw v2, vs0, 0
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test4:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addis r4, r2, .LCPI3_0@toc@ha
; P8LE-NEXT:    addi r3, r3, 4
; P8LE-NEXT:    addi r4, r4, .LCPI3_0@toc@l
; P8LE-NEXT:    lxsiwzx v4, 0, r3
; P8LE-NEXT:    lvx v3, 0, r4
; P8LE-NEXT:    vperm v2, v2, v4, v3
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test4:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    addi r3, r3, 4
; P8BE-NEXT:    lfiwzx f0, 0, r3
; P8BE-NEXT:    xxsldwi vs1, v2, vs0, 1
; P8BE-NEXT:    xxmrghw v2, v2, vs0
; P8BE-NEXT:    xxsldwi v2, v2, vs1, 3
; P8BE-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds i32, i32* %int32, i64 1
  %0 = load i32, i32* %arrayidx, align 4
  %vecins = insertelement <4 x i32> %vec, i32 %0, i32 0
  ret <4 x i32> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <4 x i32> @s2v_test5(<4 x i32> %vec, i32* nocapture readonly %ptr1)  {
; P9LE-LABEL: s2v_test5:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lwz r3, 0(r5)
; P9LE-NEXT:    mtfprwz f0, r3
; P9LE-NEXT:    xxinsertw v2, vs0, 12
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test5:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lwz r3, 0(r5)
; P9BE-NEXT:    mtfprwz f0, r3
; P9BE-NEXT:    xxinsertw v2, vs0, 0
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test5:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addis r3, r2, .LCPI4_0@toc@ha
; P8LE-NEXT:    lxsiwzx v4, 0, r5
; P8LE-NEXT:    addi r3, r3, .LCPI4_0@toc@l
; P8LE-NEXT:    lvx v3, 0, r3
; P8LE-NEXT:    vperm v2, v2, v4, v3
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test5:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    lfiwzx f0, 0, r5
; P8BE-NEXT:    xxsldwi vs1, v2, vs0, 1
; P8BE-NEXT:    xxmrghw v2, v2, vs0
; P8BE-NEXT:    xxsldwi v2, v2, vs1, 3
; P8BE-NEXT:    blr
entry:
  %0 = load i32, i32* %ptr1, align 4
  %vecins = insertelement <4 x i32> %vec, i32 %0, i32 0
  ret <4 x i32> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <4 x float> @s2v_test_f1(float* nocapture readonly %f64, <4 x float> %vec)  {
; P9LE-LABEL: s2v_test_f1:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lwz r3, 0(r3)
; P9LE-NEXT:    mtfprwz f0, r3
; P9LE-NEXT:    xxinsertw v2, vs0, 12
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test_f1:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lwz r3, 0(r3)
; P9BE-NEXT:    mtfprwz f0, r3
; P9BE-NEXT:    xxinsertw v2, vs0, 0
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test_f1:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addis r4, r2, .LCPI5_0@toc@ha
; P8LE-NEXT:    lxsiwzx v4, 0, r3
; P8LE-NEXT:    addi r4, r4, .LCPI5_0@toc@l
; P8LE-NEXT:    lvx v3, 0, r4
; P8LE-NEXT:    vperm v2, v2, v4, v3
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test_f1:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    lfiwzx f0, 0, r3
; P8BE-NEXT:    xxsldwi vs1, v2, vs0, 1
; P8BE-NEXT:    xxmrghw v2, v2, vs0
; P8BE-NEXT:    xxsldwi v2, v2, vs1, 3
; P8BE-NEXT:    blr
entry:
  %0 = load float, float* %f64, align 4
  %vecins = insertelement <4 x float> %vec, float %0, i32 0
  ret <4 x float> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x float> @s2v_test_f2(float* nocapture readonly %f64, <2 x float> %vec)  {
; P9LE-LABEL: s2v_test_f2:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    addi r3, r3, 4
; P9LE-NEXT:    xxmrglw vs1, v2, v2
; P9LE-NEXT:    lfiwzx f0, 0, r3
; P9LE-NEXT:    xxmrghw v2, vs1, vs0
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test_f2:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    addi r3, r3, 4
; P9BE-NEXT:    lxsiwzx v3, 0, r3
; P9BE-NEXT:    vmrgow v2, v3, v2
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test_f2:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addi r3, r3, 4
; P8LE-NEXT:    xxmrglw vs1, v2, v2
; P8LE-NEXT:    lfiwzx f0, 0, r3
; P8LE-NEXT:    xxmrghw v2, vs1, vs0
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test_f2:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    addi r3, r3, 4
; P8BE-NEXT:    lxsiwzx v3, 0, r3
; P8BE-NEXT:    vmrgow v2, v3, v2
; P8BE-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds float, float* %f64, i64 1
  %0 = load float, float* %arrayidx, align 8
  %vecins = insertelement <2 x float> %vec, float %0, i32 0
  ret <2 x float> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x float> @s2v_test_f3(float* nocapture readonly %f64, <2 x float> %vec, i32 signext %Idx)  {
; P9LE-LABEL: s2v_test_f3:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    sldi r4, r7, 2
; P9LE-NEXT:    xxmrglw vs1, v2, v2
; P9LE-NEXT:    lfiwzx f0, r3, r4
; P9LE-NEXT:    xxmrghw v2, vs1, vs0
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test_f3:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    sldi r4, r7, 2
; P9BE-NEXT:    lxsiwzx v3, r3, r4
; P9BE-NEXT:    vmrgow v2, v3, v2
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test_f3:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    sldi r4, r7, 2
; P8LE-NEXT:    xxmrglw vs1, v2, v2
; P8LE-NEXT:    lfiwzx f0, r3, r4
; P8LE-NEXT:    xxmrghw v2, vs1, vs0
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test_f3:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    sldi r4, r7, 2
; P8BE-NEXT:    lxsiwzx v3, r3, r4
; P8BE-NEXT:    vmrgow v2, v3, v2
; P8BE-NEXT:    blr
entry:
  %idxprom = sext i32 %Idx to i64
  %arrayidx = getelementptr inbounds float, float* %f64, i64 %idxprom
  %0 = load float, float* %arrayidx, align 8
  %vecins = insertelement <2 x float> %vec, float %0, i32 0
  ret <2 x float> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x float> @s2v_test_f4(float* nocapture readonly %f64, <2 x float> %vec)  {
; P9LE-LABEL: s2v_test_f4:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    addi r3, r3, 4
; P9LE-NEXT:    xxmrglw vs1, v2, v2
; P9LE-NEXT:    lfiwzx f0, 0, r3
; P9LE-NEXT:    xxmrghw v2, vs1, vs0
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test_f4:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    addi r3, r3, 4
; P9BE-NEXT:    lxsiwzx v3, 0, r3
; P9BE-NEXT:    vmrgow v2, v3, v2
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test_f4:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    addi r3, r3, 4
; P8LE-NEXT:    xxmrglw vs1, v2, v2
; P8LE-NEXT:    lfiwzx f0, 0, r3
; P8LE-NEXT:    xxmrghw v2, vs1, vs0
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test_f4:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    addi r3, r3, 4
; P8BE-NEXT:    lxsiwzx v3, 0, r3
; P8BE-NEXT:    vmrgow v2, v3, v2
; P8BE-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds float, float* %f64, i64 1
  %0 = load float, float* %arrayidx, align 8
  %vecins = insertelement <2 x float> %vec, float %0, i32 0
  ret <2 x float> %vecins
}

; Function Attrs: norecurse nounwind readonly
define <2 x float> @s2v_test_f5(<2 x float> %vec, float* nocapture readonly %ptr1)  {
; P9LE-LABEL: s2v_test_f5:
; P9LE:       # %bb.0: # %entry
; P9LE-NEXT:    lfiwzx f0, 0, r5
; P9LE-NEXT:    xxmrglw vs1, v2, v2
; P9LE-NEXT:    xxmrghw v2, vs1, vs0
; P9LE-NEXT:    blr
;
; P9BE-LABEL: s2v_test_f5:
; P9BE:       # %bb.0: # %entry
; P9BE-NEXT:    lxsiwzx v3, 0, r5
; P9BE-NEXT:    vmrgow v2, v3, v2
; P9BE-NEXT:    blr
;
; P8LE-LABEL: s2v_test_f5:
; P8LE:       # %bb.0: # %entry
; P8LE-NEXT:    lfiwzx f0, 0, r5
; P8LE-NEXT:    xxmrglw vs1, v2, v2
; P8LE-NEXT:    xxmrghw v2, vs1, vs0
; P8LE-NEXT:    blr
;
; P8BE-LABEL: s2v_test_f5:
; P8BE:       # %bb.0: # %entry
; P8BE-NEXT:    lxsiwzx v3, 0, r5
; P8BE-NEXT:    vmrgow v2, v3, v2
; P8BE-NEXT:    blr
entry:
  %0 = load float, float* %ptr1, align 8
  %vecins = insertelement <2 x float> %vec, float %0, i32 0
  ret <2 x float> %vecins
}

