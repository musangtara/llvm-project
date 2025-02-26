; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-linux-gnu -mcpu=pwr8 -mattr=+vsx < %s | FileCheck %s

define <4 x float> @bar(float* %p, float* %q) {
; CHECK-LABEL: bar:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lxvw4x 0, 0, 3
; CHECK-NEXT:    lxvw4x 1, 0, 4
; CHECK-NEXT:    li 5, 16
; CHECK-NEXT:    lxvw4x 2, 3, 5
; CHECK-NEXT:    lxvw4x 3, 4, 5
; CHECK-NEXT:    li 5, 32
; CHECK-NEXT:    lxvw4x 4, 4, 5
; CHECK-NEXT:    xvsubsp 0, 1, 0
; CHECK-NEXT:    lxvw4x 1, 3, 5
; CHECK-NEXT:    xvsubsp 2, 3, 2
; CHECK-NEXT:    xvsubsp 1, 4, 1
; CHECK-NEXT:    xxsldwi 0, 0, 0, 1
; CHECK-NEXT:    xxmrglw 34, 0, 2
; CHECK-NEXT:    xxsldwi 0, 0, 34, 3
; CHECK-NEXT:    xxmrghw 34, 1, 1
; CHECK-NEXT:    xxsldwi 0, 34, 0, 3
; CHECK-NEXT:    xxsldwi 34, 0, 0, 1
; CHECK-NEXT:    blr
  %1 = bitcast float* %p to <12 x float>*
  %2 = bitcast float* %q to <12 x float>*
  %3 = load <12 x float>, <12 x float>* %1, align 16
  %4 = load <12 x float>, <12 x float>* %2, align 16
  %5 = fsub <12 x float> %4, %3
  %6 = shufflevector <12 x float> %5, <12 x float> undef, <4 x i32> <i32 0, i32 3, i32 6, i32 9>
  ret <4 x float>  %6
}
