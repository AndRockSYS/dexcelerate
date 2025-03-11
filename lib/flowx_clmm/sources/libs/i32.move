// Copied from: https://github.com/CetusProtocol/integer-mate/blob/main/sui/sources/i32.move
module flowx_clmm::i32 {
    const E_OVERFLOW: u64 = 0;

    const MIN_AS_U32: u32 = 1 << 31;
    const MAX_AS_U32: u32 = 0x7fffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    public struct I32 has copy, drop, store {
        bits: u32
    }

    public fun zero(): I32 {
        I32 {
            bits: 0
        }
    }

    public fun from_u32(v: u32): I32 {
        I32 {
            bits: v
        }
    }

    public fun from(v: u32): I32 {
        assert!(v <= MAX_AS_U32, E_OVERFLOW);
        I32 {
            bits: v
        }
    }

    public fun neg_from(v: u32): I32 {
        assert!(v <= MIN_AS_U32, E_OVERFLOW);
        if (v == 0) {
            I32 {
                bits: v
            }
        } else {
            I32 {
                bits: (u32_neg(v) + 1) | (1 << 31)
            }
        }
    }

    public fun wrapping_add(num1: I32, num2: I32): I32 {
		abort 0
    }

    public fun add(num1: I32, num2: I32): I32 {
		abort 0
    }

    public fun wrapping_sub(num1: I32, num2: I32): I32 {
		abort 0
    }

    public fun sub(num1: I32, num2: I32): I32 {
		abort 0
    }

    public fun mul(num1: I32, num2: I32): I32 {
		abort 0
    }

    public fun div(num1: I32, num2: I32): I32 {
		abort 0
    }

    public fun abs(v: I32): I32 {
		abort 0
    }

    public fun abs_u32(v: I32): u32 {
		abort 0
    }

    public fun shl(v: I32, shift: u8): I32 {
		abort 0
    }

    public fun shr(v: I32, shift: u8): I32 {
		abort 0
    }

    public fun mod(v: I32, n: I32): I32 {
		abort 0
    }

    public fun as_u32(v: I32): u32 {
        v.bits
    }

    public fun sign(v: I32): u8 {
        abort 0
    }

    public fun is_neg(v: I32): bool {
        sign(v) == 1
    }

    public fun cmp(num1: I32, num2: I32): u8 {
		abort 0
    }

    public fun eq(num1: I32, num2: I32): bool {
        num1.bits == num2.bits
    }

    public fun gt(num1: I32, num2: I32): bool {
        cmp(num1, num2) == GT
    }

    public fun gte(num1: I32, num2: I32): bool {
        cmp(num1, num2) >= EQ
    }

    public fun lt(num1: I32, num2: I32): bool {
        cmp(num1, num2) == LT
    }

    public fun lte(num1: I32, num2: I32): bool {
        cmp(num1, num2) <= EQ
    }

    public fun or(num1: I32, num2: I32): I32 {
        I32 {
            bits: (num1.bits | num2.bits)
        }
    }

    public fun and(num1: I32, num2: I32): I32 {
        I32 {
            bits: (num1.bits & num2.bits)
        }
    }

    fun u32_neg(v: u32): u32 {
        v ^ 0xffffffff
    }

    fun u8_neg(v: u8): u8 {
        v ^ 0xff
	}
}

