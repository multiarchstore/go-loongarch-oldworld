// Copyright 2018 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#include "go_asm.h"
#include "textflag.h"

TEXT ·Index<ABIInternal>(SB),NOSPLIT,$0-56
	MOVV	 R7, R6		 // R6 = separator pointer
	MOVV	 R8, R7		 // R7 = separator length
	JMP 	indexbody<>(SB)

TEXT ·IndexString<ABIInternal>(SB),NOSPLIT,$0-40
	JMP 	indexbody<>(SB)

// input:
//   R4 = string
//   R5 = length
//   R6 = separator pointer
//   R7 = separator length (2 <= len <= 32)
TEXT indexbody<>(SB),NOSPLIT,$0
	// main idea is to load 'sep' into separate register(s)
	// to avoid repeatedly re-load it again and again
	// for sebsequent substring comparisons
	SUBV	R7, R5, R8
	ADDV	$1, R4, R9		  // store base for later
	MOVV	$8, R5
	ADDV	R4, R8			  // end
	BLT	    R5, R7, len_gt_8

len_le_8:
	AND		$0x8, R7, R5
	BNE	    R5, len_8
	AND		$0x4, R7, R5
	BNE	    R5, len_4_7

len_2_3:
	AND		$0x1, R7, R5
	BNE	    R5, len_3

len_2:
	MOVHU   (R6), R10
loop_2:
	BLT	    R8, R4, not_found
	MOVHU   (R4), R11
	ADDV	$1, R4
	BNE	    R10, R11, loop_2
	JMP	    found

len_3:
	MOVHU	(R6), R10
	MOVBU	2(R6), R11
loop_3:
	BLT	    R8, R4, not_found
	MOVHU   (R4), R12
	ADDV	$1, R4
	BNE	    R10, R12, loop_3
	MOVBU   1(R4), R12
	BNE	    R11, R12, loop_3
	JMP	    found

len_4_7:
	AND		$0x2, R7, R5
	BNE	    R5, len_6_7
	AND		$0x1, R7, R5
	BNE	    R5, len_5

len_4:
	MOVWU   (R6), R10
loop_4:
	BLT	    R8, R4, not_found
	MOVWU   (R4), R11
	ADDV	$1, R4
	BNE	    R10, R11, loop_4
	JMP	    found
len_5:
	MOVWU	(R6), R10
	MOVBU	4(R6), R11
loop_5:
	BLT	    R8, R4, not_found
	MOVWU   (R4), R12
	ADDV	$1, R4
	BNE	    R10, R12, loop_5
	MOVBU   3(R4), R12
	BNE	    R11, R12, loop_5
	JMP	    found

len_6_7:
	AND		$0x1, R7, R5
	BNE	    R5, len_7

len_6:
	MOVWU	(R6), R10
	MOVHU	4(R6), R11
loop_6:
	BLT	    R8, R4, not_found
	MOVWU   (R4), R12
	ADDV	$1, R4
	BNE	    R10, R12, loop_6
	MOVHU   3(R4), R12
	BNE	    R11, R12, loop_6
	JMP	    found

len_7:
	MOVWU	(R6), R10
	MOVWU	3(R6), R11
loop_7:
	BLT	    R8, R4, not_found
	MOVWU   (R4), R12
	ADDV	$1, R4
	BNE	    R10, R12, loop_7
	MOVWU   2(R4), R12
	BNE	    R11, R12, loop_7
	JMP	    found

len_8:
	MOVV	(R6), R10
loop_8:
	BLT	    R8, R4, not_found
	MOVV	(R4), R11
	ADDV	$1, R4
	BNE	    R10, R11, loop_8
	JMP	    found

len_gt_8:
	MOVV	$16, R5
	BLT	    R5, R7, len_gt_16

len_9_16:
	MOVV	(R6), R10
	SUBV	$8, R7
	MOVV	(R6)(R7), R11
	SUBV	$1, R7
loop_9_16:
	BLT	    R8, R4, not_found
	MOVV	(R4), R12
	ADDV	$1, R4
	BNE	    R10, R12, loop_9_16
	MOVV	(R4)(R7), R12
	BNE	    R11, R12, loop_9_16
	JMP	    found

len_gt_16:
	MOVV	$24, R5
	BLT	    R5, R7, len_25_32

len_17_24:
	MOVV	(R6), R10
	SUBV	$8, R7
	MOVV	8(R6), R11
	MOVV	(R6)(R7), R12
	SUBV	$1, R7
loop_17_24:
	BLT	    R8, R4, not_found
	MOVV	(R4), R13
	ADDV	$1, R4
	BNE	    R10, R13, loop_17_24
	MOVV	7(R4), R13
	BNE	    R11, R13, loop_17_24
	MOVV	(R4)(R7), R13
	BNE	    R12, R13, loop_17_24
	JMP	    found

len_25_32:
	MOVV	(R6), R10
	SUBV	$8, R7
	MOVV	8(R6), R11
	MOVV	16(R6), R12
	MOVV	(R6)(R7), R13
	SUBV	$1, R7
loop_25_32:
	BLT	    R8, R4, not_found
	MOVV	(R4), R14
	ADDV	$1, R4
	BNE	    R10, R14, loop_25_32
	MOVV	7(R4), R14
	BNE	    R11, R14, loop_25_32
	MOVV	15(R4), R14
	BNE	    R12, R14, loop_25_32
	MOVV	(R4)(R7), R14
	BNE	    R13, R14, loop_25_32
	JMP	    found

found:
	SUBV	R9, R4
	RET

not_found:
	MOVV	$-1, R4
	RET
