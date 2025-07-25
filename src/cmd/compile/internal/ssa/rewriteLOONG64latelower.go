// Code generated from _gen/LOONG64latelower.rules using 'go generate'; DO NOT EDIT.

package ssa

func rewriteValueLOONG64latelower(v *Value) bool {
	switch v.Op {
	case OpLOONG64SLLVconst:
		return rewriteValueLOONG64latelower_OpLOONG64SLLVconst(v)
	case OpLOONG64SRAVconst:
		return rewriteValueLOONG64latelower_OpLOONG64SRAVconst(v)
	case OpLOONG64SRLVconst:
		return rewriteValueLOONG64latelower_OpLOONG64SRLVconst(v)
	}
	return false
}
func rewriteValueLOONG64latelower_OpLOONG64SLLVconst(v *Value) bool {
	v_0 := v.Args[0]
	b := v.Block
	typ := &b.Func.Config.Types
	// match: (SLLVconst (MOVBUreg x) [c])
	// cond: c <= 56
	// result: (SRLVconst (SLLVconst <typ.UInt64> x [56]) [56-c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVBUreg {
			break
		}
		x := v_0.Args[0]
		if !(c <= 56) {
			break
		}
		v.reset(OpLOONG64SRLVconst)
		v.AuxInt = int64ToAuxInt(56 - c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.UInt64)
		v0.AuxInt = int64ToAuxInt(56)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SLLVconst (MOVHUreg x) [c])
	// cond: c <= 48
	// result: (SRLVconst (SLLVconst <typ.UInt64> x [48]) [48-c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVHUreg {
			break
		}
		x := v_0.Args[0]
		if !(c <= 48) {
			break
		}
		v.reset(OpLOONG64SRLVconst)
		v.AuxInt = int64ToAuxInt(48 - c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.UInt64)
		v0.AuxInt = int64ToAuxInt(48)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SLLVconst (MOVWUreg x) [c])
	// cond: c <= 32
	// result: (SRLVconst (SLLVconst <typ.UInt64> x [32]) [32-c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVWUreg {
			break
		}
		x := v_0.Args[0]
		if !(c <= 32) {
			break
		}
		v.reset(OpLOONG64SRLVconst)
		v.AuxInt = int64ToAuxInt(32 - c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.UInt64)
		v0.AuxInt = int64ToAuxInt(32)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SLLVconst x [0])
	// result: x
	for {
		if auxIntToInt64(v.AuxInt) != 0 {
			break
		}
		x := v_0
		v.copyOf(x)
		return true
	}
	return false
}
func rewriteValueLOONG64latelower_OpLOONG64SRAVconst(v *Value) bool {
	v_0 := v.Args[0]
	b := v.Block
	typ := &b.Func.Config.Types
	// match: (SRAVconst (MOVBreg x) [c])
	// cond: c < 8
	// result: (SRAVconst (SLLVconst <typ.Int64> x [56]) [56+c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVBreg {
			break
		}
		x := v_0.Args[0]
		if !(c < 8) {
			break
		}
		v.reset(OpLOONG64SRAVconst)
		v.AuxInt = int64ToAuxInt(56 + c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.Int64)
		v0.AuxInt = int64ToAuxInt(56)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SRAVconst (MOVHreg x) [c])
	// cond: c < 16
	// result: (SRAVconst (SLLVconst <typ.Int64> x [48]) [48+c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVHreg {
			break
		}
		x := v_0.Args[0]
		if !(c < 16) {
			break
		}
		v.reset(OpLOONG64SRAVconst)
		v.AuxInt = int64ToAuxInt(48 + c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.Int64)
		v0.AuxInt = int64ToAuxInt(48)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SRAVconst (MOVWreg x) [c])
	// cond: c < 32
	// result: (SRAVconst (SLLVconst <typ.Int64> x [32]) [32+c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVWreg {
			break
		}
		x := v_0.Args[0]
		if !(c < 32) {
			break
		}
		v.reset(OpLOONG64SRAVconst)
		v.AuxInt = int64ToAuxInt(32 + c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.Int64)
		v0.AuxInt = int64ToAuxInt(32)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SRAVconst x [0])
	// result: x
	for {
		if auxIntToInt64(v.AuxInt) != 0 {
			break
		}
		x := v_0
		v.copyOf(x)
		return true
	}
	return false
}
func rewriteValueLOONG64latelower_OpLOONG64SRLVconst(v *Value) bool {
	v_0 := v.Args[0]
	b := v.Block
	typ := &b.Func.Config.Types
	// match: (SRLVconst (MOVBUreg x) [c])
	// cond: c < 8
	// result: (SRLVconst (SLLVconst <typ.UInt64> x [56]) [56+c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVBUreg {
			break
		}
		x := v_0.Args[0]
		if !(c < 8) {
			break
		}
		v.reset(OpLOONG64SRLVconst)
		v.AuxInt = int64ToAuxInt(56 + c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.UInt64)
		v0.AuxInt = int64ToAuxInt(56)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SRLVconst (MOVHUreg x) [c])
	// cond: c < 16
	// result: (SRLVconst (SLLVconst <typ.UInt64> x [48]) [48+c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVHUreg {
			break
		}
		x := v_0.Args[0]
		if !(c < 16) {
			break
		}
		v.reset(OpLOONG64SRLVconst)
		v.AuxInt = int64ToAuxInt(48 + c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.UInt64)
		v0.AuxInt = int64ToAuxInt(48)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SRLVconst (MOVWUreg x) [c])
	// cond: c < 32
	// result: (SRLVconst (SLLVconst <typ.UInt64> x [32]) [32+c])
	for {
		c := auxIntToInt64(v.AuxInt)
		if v_0.Op != OpLOONG64MOVWUreg {
			break
		}
		x := v_0.Args[0]
		if !(c < 32) {
			break
		}
		v.reset(OpLOONG64SRLVconst)
		v.AuxInt = int64ToAuxInt(32 + c)
		v0 := b.NewValue0(v.Pos, OpLOONG64SLLVconst, typ.UInt64)
		v0.AuxInt = int64ToAuxInt(32)
		v0.AddArg(x)
		v.AddArg(v0)
		return true
	}
	// match: (SRLVconst x [0])
	// result: x
	for {
		if auxIntToInt64(v.AuxInt) != 0 {
			break
		}
		x := v_0
		v.copyOf(x)
		return true
	}
	return false
}
func rewriteBlockLOONG64latelower(b *Block) bool {
	return false
}
