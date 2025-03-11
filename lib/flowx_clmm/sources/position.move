module flowx_clmm::position {
    use std::vector;
    use std::string::utf8;
    use std::type_name::TypeName;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::display;
    use sui::package;
    use sui::transfer;

    use flowx_clmm::i32::I32;
    use flowx_clmm::i128::{Self, I128};
    use flowx_clmm::full_math_u128;
    use flowx_clmm::constants;
    use flowx_clmm::liquidity_math;
    use flowx_clmm::full_math_u64;

    const E_EMPTY_POSITION: u64 = 0;
    const E_COINS_OWED_OVERFLOW: u64 = 1;

    public struct POSITION has drop {}

    public struct Position has key, store {
        id: UID,
        pool_id: ID,
        fee_rate: u64,
        coin_type_x: TypeName,
	    coin_type_y: TypeName,
        tick_lower_index: I32,
	    tick_upper_index: I32,
        liquidity: u128,
        fee_growth_inside_x_last: u128,
        fee_growth_inside_y_last: u128,
        coins_owed_x: u64,
        coins_owed_y: u64,
        reward_infos: vector<PositionRewardInfo>
    }

    public struct PositionRewardInfo has copy, store, drop {
        reward_growth_inside_last: u128,
        coins_owed_reward: u64,
    }

    fun init(otw: POSITION, ctx: &mut TxContext) {
		abort 0
    }

    public fun pool_id(self: &Position): ID { self.pool_id }

    public fun fee_rate(self: &Position): u64 { self.fee_rate }

    public fun liquidity(self: &Position): u128 { self.liquidity }

    public fun tick_lower_index(self: &Position): I32 { self.tick_lower_index }

    public fun tick_upper_index(self: &Position): I32 { self.tick_upper_index }

    public fun coins_owed_x(self: &Position): u64 { self.coins_owed_x }

    public fun coins_owed_y(self: &Position): u64 { self.coins_owed_y }

    public fun fee_growth_inside_x_last(self: &Position): u128 { self.fee_growth_inside_x_last }

    public fun fee_growth_inside_y_last(self: &Position): u128 { self.fee_growth_inside_y_last }

    public fun reward_growth_inside_last(self: &Position, i: u64): u128 {
		abort 0
    }

    public fun coins_owed_reward(self: &Position, i: u64): u64 {
		abort 0
    }

    fun try_borrow_mut_reward_info(self: &mut Position, i: u64): &mut PositionRewardInfo {
		abort 0
    }

    public(package) fun open(
        pool_id: ID,
        fee_rate: u64,
        coin_type_x: TypeName,
	    coin_type_y: TypeName,
        tick_lower_index: I32,
	    tick_upper_index: I32,
        ctx: &mut TxContext
    ): Position {
		abort 0
    }

    public(package) fun close(position: Position) {
		abort 0
    }

    public(package) fun increase_debt(
        self: &mut Position,
        amount_x: u64,
        amount_y: u64
    ) {
		abort 0
    }

    public(package) fun decrease_debt(
        self: &mut Position,
        amount_x: u64,
        amount_y: u64
    ) {
		abort 0
    }

    public(package) fun decrease_reward_debt(
        self: &mut Position,
        i: u64,
        amount: u64
    ) {
		abort 0
    }

    public(package) fun update(
        self: &mut Position,
        liquidity_delta: I128,
        fee_growth_inside_x: u128,
        fee_growth_inside_y: u128,
        reward_growths_inside: vector<u128>
    ) {
		abort 0
    }

    fun update_reward_infos(
        self: &mut Position,
        reward_growths_inside: vector<u128>
    ) {
		abort 0
    }
}