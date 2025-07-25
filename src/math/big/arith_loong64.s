// Copyright 2022 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build !math_big_pure_go

#include "textflag.h"

// This file provides fast assembly versions for the elementary
// arithmetic operations on vectors implemented in arith.go.

// func addVV(z, x, y []Word) (c Word)
TEXT ·addVV(SB),NOSPLIT,$0
	// input:
	//   R4: z
	//   R5: z_len
	//   R7: x
	//   R10: y
	MOVV	z+0(FP), R4
	MOVV	z_len+8(FP), R5
	MOVV	x+24(FP), R7
	MOVV	y+48(FP), R10
	MOVV	$0, R6
	SLLV	$3, R5
	MOVV	$0, R8
loop:
	BEQ	R5, R6, done
	MOVV	(R6)(R7), R9
	MOVV	(R6)(R10), R11
	ADDV	R9, R11, R11	// x1 + y1 = z1', if z1' < x1 then z1' overflow
	ADDV	R8, R11, R12	// z1' + c0 = z1, if z1 < z1' then z1 overflow
	SGTU	R9, R11, R9
	SGTU	R11, R12, R11
	MOVV	R12, (R6)(R4)
	OR	R9, R11, R8
	ADDV	$8, R6
	JMP	loop
done:
	MOVV	R8, c+72(FP)
	RET

// func subVV(z, x, y []Word) (c Word)
TEXT ·subVV(SB),NOSPLIT,$0
	// input:
	//   R4: z
	//   R5: z_len
	//   R7: x
	//   R10: y
	MOVV	z+0(FP), R4
	MOVV	z_len+8(FP), R5
	MOVV	x+24(FP), R7
	MOVV	y+48(FP), R10
	MOVV	$0, R6
	SLLV	$3, R5
	MOVV	$0, R8
loop:
	BEQ	R5, R6, done
	MOVV	(R6)(R7), R9
	MOVV	(R6)(R10), R11
	SUBV	R11, R9, R11	// x1 - y1 = z1', if z1' > x1 then overflow
	SUBV	R8, R11, R12	// z1' - c0 = z1, if z1 > z1' then overflow
	SGTU	R11, R9, R9
	SGTU	R12, R11, R11
	MOVV	R12, (R6)(R4)
	OR	R9, R11, R8
	ADDV	$8, R6
	JMP	loop
done:
	MOVV	R8, c+72(FP)
	RET

// func addVW(z, x []Word, y Word) (c Word)
TEXT ·addVW(SB),NOSPLIT,$0
	// input:
	//   R4: z
	//   R5: z_len
	//   R7: x
	//   R10: y
	MOVV	z+0(FP), R4
	MOVV	z_len+8(FP), R5
	MOVV	x+24(FP), R7
	MOVV	y+48(FP), R10
	MOVV	$0, R6
	SLLV	$3, R5
loop:
	BEQ	R5, R6, done
	MOVV	(R6)(R7), R8
	ADDV	R8, R10, R9	// x1 + c = z1, if z1 < x1 then z1 overflow
	SGTU	R8, R9, R10
	MOVV	R9, (R6)(R4)
	ADDV	$8, R6
	JMP	loop
done:
	MOVV	R10, c+56(FP)
	RET

// func subVW(z, x []Word, y Word) (c Word)
TEXT ·subVW(SB),NOSPLIT,$0
	// input:
	//   R4: z
	//   R5: z_len
	//   R7: x
	//   R10: y
	MOVV	z+0(FP), R4
	MOVV	z_len+8(FP), R5
	MOVV	x+24(FP), R7
	MOVV	y+48(FP), R10
	MOVV	$0, R6
	SLLV	$3, R5
loop:
	BEQ	R5, R6, done
	MOVV	(R6)(R7), R8
	SUBV	R10, R8, R11	// x1 - c = z1, if z1 > x1 then overflow
	SGTU	R11, R8, R10
	MOVV	R11, (R6)(R4)
	ADDV	$8, R6
	JMP	loop
done:
	MOVV	R10, c+56(FP)
	RET

// func shlVU(z, x []Word, s uint) (c Word)
TEXT ·shlVU(SB),NOSPLIT,$0
	// input:
	//   R4: z
	//   R5: z_len
	//   R7: x
	//   R10: s
	MOVV	z_len+8(FP), R5
	MOVV	s+48(FP), R10
	MOVV	z+0(FP), R4
	MOVV	x+24(FP), R7
	BEQ	R5, len0
	SLLV	$3, R5
	BEQ	R10, copy
	MOVV	$64, R9
	ADDV	$-8, R7		// &x[-1]
	SUB	R10, R9		// ŝ = 64 - s
	MOVV	(R5)(R7), R6
	SRLV	R9, R6, R8	// c = x[len(z)-1] >> ŝ
loop:
	ADDV	$-8, R5
	BEQ	R5, done
	SLLV	R10, R6, R12
	MOVV	(R5)(R7), R6
	SRLV	R9, R6, R11
	OR	R11, R12
	MOVV	R12, (R5)(R4)	// z[i] = x[i]<<s | x[i-1]>>ŝ
	JMP	loop
done:
	SLLV	R10, R6
	MOVV	R8, c+56(FP)
	MOVV	R6, 0(R4)	// z[0] = x[0] << s
	RET
copy:
	BEQ	R7, R4, len0
copyloop:
	ADDV	$-8, R5
	BLT	R5, R0, len0
	MOVV	(R5)(R7), R9
	MOVV	R9, (R5)(R4)
	JMP	copyloop
len0:
	MOVV	R0, c+56(FP)
	RET

TEXT ·shrVU(SB),NOSPLIT,$0
	// input:
	//   R4: z
	//   R5: z_len
	//   R7: x
	//   R10: s
	MOVV	z_len+8(FP), R5
	MOVV	s+48(FP), R10
	MOVV	z+0(FP), R4
	MOVV	x+24(FP), R7
	BEQ	R5, len0
	SLLV	$3, R5
	BEQ	R10, copy
	MOVV	0(R7), R6
	MOVV	$64, R9
	MOVV	$8, R8
	SUB	R10, R9		// ŝ = 64 - s
	ADDV	$-8, R4		// &z[-1]
	SLLV	R9, R6, R13	// c = x[0] << ŝ
loop:
	BEQ	R5, R8, done
	SRLV	R10, R6, R12
	MOVV	(R8)(R7), R6
	SLLV	R9, R6, R11
	OR	R11, R12
	MOVV	R12, (R8)(R4)	// z[i-1] = x[i-1]>>s | x[i]<<ŝ
	ADDV	$8, R8
	JMP	loop
done:
	SRLV	R10, R6
	MOVV	R13, c+56(FP)
	MOVV	R6, (R8)(R4)	// z[len(z)-1] = x[len(z)-1] >> s
	RET
copy:
	MOVV	$0, R8
	BEQ	R7, R4, len0
copyloop:
	BEQ	R5, R8, len0
	MOVV	(R8)(R7), R9
	MOVV	R9, (R8)(R4)
	ADDV	$8, R8
	JMP	copyloop
len0:
	MOVV	R0, c+56(FP)
	RET

// func mulAddVWW(z, x []Word, y, r Word) (c Word)
TEXT ·mulAddVWW(SB),NOSPLIT,$0
	// input:
	//   R4: z
	//   R5: z_len
	//   R7: x
	//   R10: y
	//   R11: r
	MOVV	z+0(FP), R4
	MOVV	z_len+8(FP), R5
	MOVV	x+24(FP), R7
	MOVV	y+48(FP), R10
	MOVV	r+56(FP), R11
	SLLV	$3, R5
	MOVV	$0, R6
loop:
	BEQ	R5, R6, done
	MOVV	(R6)(R7), R8
	MULV	R8, R10, R9
	MULHVU	R8, R10, R12
	ADDV	R9, R11, R8
	SGTU	R9, R8, R11	// if (c' = lo + c) < lo then overflow
	MOVV	R8, (R6)(R4)
	ADDV	R12, R11
	ADDV	$8, R6
	JMP	loop
done:
	MOVV	R11, c+64(FP)
	RET

// func addMulVVW(z, x []Word, y Word) (c Word)
TEXT ·addMulVVW(SB),NOSPLIT,$0
	// input:
	//   R4: z
	//   R5: z_len
	//   R7: x
	//   R10: y
	MOVV	z_len+8(FP), R5
	MOVV	x+24(FP), R7
	MOVV	z+0(FP), R4
	MOVV	y+48(FP), R10
	MOVV	$0, R6
	SLLV	$3, R5
	MOVV	$0, R11
loop:
	BEQ	R5, R6, done
	MOVV	(R6)(R7), R8
	MOVV	(R6)(R4), R9
	MULV	R8, R10, R12
	MULHVU	R8, R10, R13
	ADDV	R12, R9, R8
	SGTU	R12, R8, R9
	ADDV	R13, R9
	ADDV	R8, R11, R12
	SGTU	R8, R12, R11
	MOVV	R12, (R6)(R4)
	ADDV	$8, R6
	ADDV	R9, R11
	JMP	loop
done:
	MOVV	R11, c+56(FP)
	RET
