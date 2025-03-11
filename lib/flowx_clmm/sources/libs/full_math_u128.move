// Copied from: https://github.com/CetusProtocol/integer-mate/blob/main/sui/sources/full_math_u128.move
module flowx_clmm::full_math_u128 {
    const MAX_U128: u128 = 0xffffffffffffffffffffffffffffffff;

    const LO_128_MASK: u256 = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;

    public fun mul_div_floor(num1: u128, num2: u128, denom: u128): u128 {
		abort 0
    }

    public fun mul_div_round(num1: u128, num2: u128, denom: u128): u128 {
		abort 0
    }

    public fun mul_div_ceil(num1: u128, num2: u128, denom: u128): u128 {
		abort 0
    }

    public fun mul_shr(num1: u128, num2: u128, shift: u8): u128 {
		abort 0
    }

    public fun mul_shl(num1: u128, num2: u128, shift: u8): u128 {
		abort 0
    }

    public fun full_mul(num1: u128, num2: u128): u256 {
		abort 0
    }

    /// Return the larger of `x` and `y`
    public fun max(x: u128, y: u128): u128 {
		abort 0
    }

    /// Return the smaller of `x` and `y`
    public fun min(x: u128, y: u128): u128 {
		abort 0
    }
    
    public fun wrapping_add(n1: u128, n2: u128): u128 {
		abort 0
    }

    public fun overflowing_add(n1: u128, n2: u128): (u128, bool) {
		abort 0
    }
    
    public fun wrapping_sub(n1: u128, n2: u128): u128 {
		abort 0
    }
    
    public fun overflowing_sub(n1: u128, n2: u128): (u128, bool) {
		abort 0
    }
}
