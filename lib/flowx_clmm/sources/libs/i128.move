// Copied from: https://github.com/CetusProtocol/integer-mate/blob/main/sui/sources/i128.move
module flowx_clmm::i128 {
    use flowx_clmm::i64;
    use flowx_clmm::i32;

    const E_OVERFLOW: u64 = 0;

    const MIN_AS_U128: u128 = 1 << 127;
    const MAX_AS_U128: u128 = 0x7fffffffffffffffffffffffffffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    public struct I128 has copy, drop, store {
        bits: u128
    }

    public fun zero(): I128 {
        I128 {
            bits: 0
        }
    }

    public fun from(v: u128): I128 {
        assert!(v <= MAX_AS_U128, E_OVERFLOW);
        I128 {
            bits: v
        }
    }

    public fun neg_from(v: u128): I128 {
        assert!(v <= MIN_AS_U128, E_OVERFLOW);
        if (v == 0) {
            I128 {
                bits: v
            }
        } else {
            I128 {
                bits: (u128_neg(v)  + 1) | (1 << 127)
            }
        }
    }

    public fun neg(v: I128): I128 {
		abort 0
    }

    public fun wrapping_add(num1: I128, num2:I128): I128 {
		abort 0
    }

    public fun add(num1: I128, num2: I128): I128 {
		abort 0
    }

    public fun overflowing_add(num1: I128, num2: I128): (I128, bool) {
		abort 0
    }

    public fun wrapping_sub(num1: I128, num2: I128): I128 {
		abort 0
    }
    
    public fun sub(num1: I128, num2: I128): I128 {
		abort 0
    }

    public fun overflowing_sub(num1: I128, num2: I128): (I128, bool) {
		abort 0
    }

    public fun mul(num1: I128, num2: I128): I128 {
		abort 0
    }

    public fun div(num1: I128, num2: I128): I128 {
		abort 0
    }

    public fun abs(v: I128): I128 {
		abort 0
    }

    public fun abs_u128(v: I128): u128 {
		abort 0
    }

    public fun shl(v: I128, shift: u8): I128 {
		abort 0
    }

    public fun shr(v: I128, shift: u8): I128 {
		abort 0
    }

    public fun as_u128(v: I128): u128 {
        v.bits
    }

    public fun as_i64(v: I128): i64::I64 {
		abort 0
    }

    public fun as_i32(v: I128): i32::I32 {
		abort 0
    }

    public fun sign(v: I128): u8 {
        abort 0
    }

    public fun is_neg(v: I128): bool {
        sign(v) == 1
    }

    public fun cmp(num1: I128, num2: I128): u8 {
		abort 0
    }

    public fun eq(num1: I128, num2: I128): bool {
        num1.bits == num2.bits
    }

    public fun gt(num1: I128, num2: I128): bool {
        cmp(num1, num2) == GT
    }
    
    public fun gte(num1: I128, num2: I128): bool {
        cmp(num1, num2) >= EQ
    }
    
    public fun lt(num1: I128, num2: I128): bool {
        cmp(num1, num2) == LT
    }
    
    public fun lte(num1: I128, num2: I128): bool {
        cmp(num1, num2) <= EQ
    }

    public fun or(num1: I128, num2: I128): I128 {
        I128 {
            bits: (num1.bits | num2.bits)
        }
    }

    public fun and(num1: I128, num2: I128): I128 {
        I128 {
            bits: (num1.bits & num2.bits)
        }
    }

    fun u128_neg(v :u128) : u128 {
        v ^ 0xffffffffffffffffffffffffffffffff
    }

    fun u8_neg(v: u8): u8 {
        v ^ 0xff
	}
}

