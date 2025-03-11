// Copied from: https://github.com/CetusProtocol/cetus-clmm-interface/blob/main/sui/clmmpool/sources/math/tick_math.move
module flowx_clmm::tick_math {
    use flowx_clmm::full_math_u128;
    use flowx_clmm::i32::{Self, I32};
    use flowx_clmm::i128;

    const TICK_BOUND: u32 = 443636;
    const MAX_SQRT_PRICE_X64: u128 = 79226673515401279992447579055;
    const MIN_SQRT_PRICE_X64: u128 = 4295048016;

    /// Errors
    const EINVALID_TICK: u64 = 1;
    const EINVALID_SQRT_PRICE: u64 =2;

    public fun max_sqrt_price(): u128 {
        MAX_SQRT_PRICE_X64
    }

    public fun min_sqrt_price(): u128 {
        MIN_SQRT_PRICE_X64
    }

    public fun max_tick(): i32::I32 {
        i32::from(TICK_BOUND)
    }

    public fun min_tick(): i32::I32 {
        i32::neg_from(TICK_BOUND)
    }

    public fun tick_bound(): u32 {
        TICK_BOUND
    }

    public fun get_sqrt_price_at_tick(tick: i32::I32): u128 {
		abort 0
    }

    public fun is_valid_index(index: I32, tick_spacing: u32): bool {
		abort 0
    }

    public fun get_tick_at_sqrt_price(sqrt_price: u128): i32::I32 {
		abort 0
    }

    fun as_u8(b: bool): u8 {
        if (b) {
            1
        } else {
            0
        }
    }

    fun get_sqrt_price_at_negative_tick(tick: i32::I32): u128 {
		abort 0
	}
}
