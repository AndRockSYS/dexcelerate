module flowx_clmm::tick_bitmap {
    use sui::table::{Self, Table};

    use flowx_clmm::i32::{Self, I32};
    use flowx_clmm::caster;
    use flowx_clmm::bit_math;
    use flowx_clmm::constants;

    const E_TICK_MISALIGNED: u64 = 0;

    fun position(tick: I32): (I32, u8) {
		abort 0
    }

    fun try_get_tick_word(
        self: &Table<I32, u256>,
        word_pos: I32
    ): u256 {
		abort 0
    }

    fun try_borrow_mut_tick_word(
        self: &mut Table<I32, u256>,
        word_pos: I32
    ): &mut u256 {
		abort 0
    }

    public(package) fun flip_tick(
        self: &mut Table<I32, u256>,
        tick: I32,
        tick_spacing: u32
    ) {
		abort 0
	}

    public fun next_initialized_tick_within_one_word(
        self: &Table<I32, u256>,
        tick: I32,
        tick_spacing: u32,
        lte: bool
    ): (I32, bool) {
		abort 0
    }
}