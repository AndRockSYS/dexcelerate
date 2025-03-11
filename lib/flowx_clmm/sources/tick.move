module flowx_clmm::tick {
    use std::vector;
    use sui::table::{Self, Table};

    use flowx_clmm::i32::{Self, I32};
    use flowx_clmm::i64::{Self, I64};
    use flowx_clmm::i128::{Self, I128};
    use flowx_clmm::tick_math;
    use flowx_clmm::constants;
    use flowx_clmm::liquidity_math;
    use flowx_clmm::full_math_u128;

    const E_LIQUIDITY_OVERFLOW: u64 = 0;
    const E_TICKS_MISORDERED: u64 = 1;
    const E_TICK_LOWER_OUT_OF_BOUNDS: u64 = 2;
    const E_TICK_UPPER_OUT_OF_BOUNDS: u64 = 3;

    public struct TickInfo has copy, drop, store {
        liquidity_gross: u128,
        liquidity_net: I128,
        fee_growth_outside_x: u128,
        fee_growth_outside_y: u128,
        reward_growths_outside: vector<u128>,
        tick_cumulative_out_side: I64,
        seconds_per_liquidity_out_side: u256,
        seconds_out_side: u64
    }

    public fun check_ticks(tick_lower_index: I32, tick_upper_index: I32)  {
		abort 0
    }

    public fun is_initialized(
        self: &Table<I32, TickInfo>,
        tick_index: I32
    ): bool {
		abort 0
    }

    public fun get_fee_and_reward_growths_outside(
        self: &Table<I32, TickInfo>,
        tick_index: I32
    ): (u128, u128, vector<u128>) {
		abort 0
    }

    public fun get_liquidity_gross(
        self: &Table<I32, TickInfo>,
        tick_index: I32
    ): u128 {
		abort 0
    }

    public fun get_liquidity_net(
        self: &Table<I32, TickInfo>,
        tick_index: I32
    ): I128 {
		abort 0
    }

    public fun get_tick_cumulative_out_side(
        self: &Table<I32, TickInfo>,
        tick_index: I32
    ): I64 {
		abort 0
    }

    public fun get_seconds_per_liquidity_out_side(
        self: &Table<I32, TickInfo>,
        tick_index: I32
    ): u256 {
		abort 0
    }

    public fun get_seconds_out_side(
        self: &Table<I32, TickInfo>,
        tick_index: I32
    ): u64 {
		abort 0
    }

    fun try_borrow_mut_tick(
        self: &mut Table<I32, TickInfo>,
        tick_index: I32
    ): &mut TickInfo {
		abort 0
    }

    public fun tick_spacing_to_max_liquidity_per_tick(tick_spacing: u32): u128 {
		abort 0
    }

    public fun get_fee_and_reward_growths_inside(
        self: &Table<I32, TickInfo>,
        tick_lower_index: I32,
        tick_upper_index: I32,
        tick_current_index: I32,
        fee_growth_global_x: u128,
        fee_growth_global_y: u128,
        reward_growths_global: vector<u128>
    ): (u128, u128, vector<u128>) {
		abort 0
    }

    public(package) fun update(
        self: &mut Table<I32, TickInfo>,
        tick_index: I32,
        tick_current_index: I32,
        liquidity_delta: I128,
        fee_growth_global_x: u128,
        fee_growth_global_y: u128,
        reward_growths_global: vector<u128>,
        seconds_per_liquidity_cumulative: u256,
        tick_cumulative: I64,
        timestamp_s: u64,
        upper: bool,
        max_liquidity: u128
    ): bool {
		abort 0
    }

    public(package) fun clear(self: &mut Table<I32, TickInfo>, tick: I32) {
        table::remove(self, tick);
    }

    public(package) fun cross(
        self: &mut Table<I32, TickInfo>,
        tick_index: I32,
        fee_growth_global_x: u128,
        fee_growth_global_y: u128,
        reward_growths_global: vector<u128>,
        seconds_per_liquidity_cumulative: u256,
        tick_cumulative: I64,
        timestamp_s: u64,
    ): I128 {
		abort 0
    }

    fun compute_reward_growths(reward_growths_global: vector<u128>, reward_growths_outside: vector<u128>): vector<u128> {
		abort 0
    }
}