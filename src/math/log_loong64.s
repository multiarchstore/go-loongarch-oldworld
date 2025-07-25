// Copyright 2025 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#include "textflag.h"

DATA logrodata<>+0(SB)/8, $0.5
DATA logrodata<>+8(SB)/8, $1.0
DATA logrodata<>+16(SB)/8, $2.0
DATA logrodata<>+24(SB)/8, $7.07106781186547524401e-01	// sqrt(2)/2
DATA logrodata<>+32(SB)/8, $6.93147180369123816490e-01	// Ln2Hi
DATA logrodata<>+40(SB)/8, $1.90821492927058770002e-10	// Ln2Lo
DATA logrodata<>+48(SB)/8, $6.666666666666735130e-01	// L1
DATA logrodata<>+56(SB)/8, $3.999999999940941908e-01	// L2
DATA logrodata<>+64(SB)/8, $2.857142874366239149e-01	// L3
DATA logrodata<>+72(SB)/8, $2.222219843214978396e-01	// L4
DATA logrodata<>+80(SB)/8, $1.818357216161805012e-01	// L5
DATA logrodata<>+88(SB)/8, $1.531383769920937332e-01	// L6
DATA logrodata<>+96(SB)/8, $1.479819860511658591e-01	// L7
DATA logrodata<>+104(SB)/8, $2.2250738585072014e-308	// 2**-1022
GLOBL logrodata<>+0(SB), NOPTR|RODATA, $112

#define NaN    0x7FF8000000000001
#define NegInf 0xFFF0000000000000
#define PosInf 0x7FF0000000000000

// func Log(x float64) float64
TEXT ·archLog(SB),NOSPLIT,$0
	// test bits for special cases
	MOVD	x+0(FP), F0
	MOVV	x+0(FP), R4
	MOVV	$logrodata<>+0(SB), R10
	FCLASSD	F0, F4
	MOVV	F4, R5
	AND	$67, R5, R6	// NaN or +Inf
	AND	$544, R5, R7	// +0 or -0
	AND	$28, R5, R8	// <0
	BNE	R6, R0, isInfOrNaN
	BNE	R7, R0, isZero
	BNE	R8, R0, isNegative

	// reduce
	// f1, ki := Frexp(x) FIXME
	MOVD	104(R10), F4
	ABSD	F0, F1
	CMPGED	F1, F4, FCC0
	BFPT	direct_return
	MOVV	$0x10000000000000, R5	// 1 << 52
	MULV	R4, R5, R4		// R4 = y
	MOVV	$-52, R15		// R15 = ki  (exp)
	JMP	2(PC)
direct_return:
	MOVV	$0, R15			// R15 = ki  (exp)  F0 = y

	MOVV	$0x000FFFFFFFFFFFFF, R5
	AND	R4, R5, R7		// x &^= mask << shift
	MOVV	$0x3FE0000000000000, R6	// (-1 + bias) << shift
	OR	R6, R7			// x |= (-1 + bias) << shift
	MOVV	R7, F2			// F2 = f1
	SRLV	$52, R4			// x >> shift
	AND	$0x7FF, R4		// (x>>shift)&mask
	SUBV	$0x3FE, R4		// int((x>>shift)&mask) - bias + 1
	ADDV	R4, R15, R4		// R4 = exp

	// if f1 < math.Sqrt2/2 { k -= 1; f1 *= 2 }
	MOVD	0(R10), F10	// 0.5
	MOVD	8(R10), F3	// 1.0
	MOVD	16(R10), F4	// 2.0
	MOVD	24(R10), F0	// sqrt(2)/2
	CMPGED	F2, F0, FCC0	// if f1 >= Sqrt2/2
	BFPT	next
	MULD	F4, F2, F2	// f1 *= 2
	SUBV	$1, R4, R4
next:
	MOVV	R4, F1		// k--
	FFINTDV	F1, F1		// F1 = k
	// f := f1 - 1
	SUBD	F3, F2, F2

	// compute
	MOVD	96(R10), F17	// L7
	MOVD	80(R10), F15	// L5
	MOVD	64(R10), F13	// L3
	MOVD	48(R10), F11	// L1
	ADDD	F4, F2, F3	// 2 + f
	DIVD	F3, F2, F4	// s := f / (2 + f)
	MULD	F4, F4, F5	// s2 := s * s
	MULD	F5, F5, F6	// s4 := s2 * s2
	// t1 := s2 * (L1 + s4*(L3+s4*(L5+s4*L7)))
	MULD	F17, F6, F7	// s4*L7
	ADDD	F15, F7		// L5+s4*L7
	MULD	F6, F7		// s4*(L5+s4*L7)
	ADDD	F13, F7		// L3+s4*(L5+s4*L7)
	MULD	F6, F7		// s4*(L3+s4*(L5+s4*L7))
	ADDD	F11, F7		// L1 + s4*(L3+s4*(L5+s4*L7))
	MULD	F5, F7		// s2 * (L1 + s4*(L3+s4*(L5+s4*L7)))

	MOVD	88(R10), F16	// L6
	MOVD	72(R10), F14	// L4
	MOVD	56(R10), F12	// L2
	// t2 := s4 * (L2 + s4*(L4+s4*L6))
	MULD	F6, F16, F8	// s4*L6
	ADDD	F14, F8		// L4+s4*L6
	MULD	F6, F8		// s4*(L4+s4*L6)
	ADDD	F12, F8		// L2 + s4*(L4+s4*L6)
	MULD	F6, F8		// s4 * (L2 + s4*(L4+s4*L6))

	// R := t1 + t2
	ADDD   F7, F8

	// hfsq := 0.5 * f * f
	MULD	F2, F2, F12	// f * f
	MULD	F10, F12, F9	// 0.5 * f * f

	// return k*Ln2Hi - ((hfsq - (s*(hfsq+R) + k*Ln2Lo)) - f)
	MOVD	40(R10), F19	// Ln2Lo
	MOVD	32(R10), F18	// Ln2Hi
	// f9=hfsq, f1=k, f4=s, f8=R, f2=f
	ADDD	F9, F8, F10	// F10 = hfsq+R
	MULD	F1, F19, F11	// F11 = k*Ln2Lo
	MULD	F10, F4, F12	// F12 = s*(hfsq+R)
	MULD	F1, F18, F15	// F15 = k*Ln2Hi
	ADDD	F12, F11, F13	// F13 = s*(hfsq+R) + k*Ln2Lo
	SUBD	F13, F9, F14	// F14 = hfsq - (s*(hfsq+R) + k*Ln2Lo)
	SUBD	F2, F14, F14	// F14 = (hfsq - (s*(hfsq+R) + k*Ln2Lo)) - f
	SUBD	F14, F15, F0
	MOVD	F0, ret+8(FP)
	RET

isInfOrNaN:
	MOVV	R4, ret+8(FP)	// +Inf or NaN, return x
	RET
isNegative:
	MOVV	$NaN, R4
	MOVV	R4, ret+8(FP)	// return NaN
	RET
isZero:
	MOVV	$NegInf, R4
	MOVV	R4, ret+8(FP)	// return -Inf
	RET
