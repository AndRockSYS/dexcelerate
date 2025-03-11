module flowx_clmm::position_manager {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::balance;
    use sui::coin::{Self, Coin};
    use sui::event;
    use sui::transfer;
    use sui::clock::Clock;

    use flowx_clmm::i128;
    use flowx_clmm::tick_math;
    use flowx_clmm::liquidity_math;
    use flowx_clmm::i32::I32;
    use flowx_clmm::tick;
    use flowx_clmm::pool;
    use flowx_clmm::position::{Self, Position};
    use flowx_clmm::versioned::{Self, Versioned};
    use flowx_clmm::pool_manager::{Self, PoolRegistry};
    use flowx_clmm::utils;

    const E_NOT_EMPTY_POSITION: u64 = 0;
    const E_INSUFFICIENT_OUTPUT_AMOUNT: u64 = 1;

    public struct PositionRegistry has key, store {
        id: UID,
        num_positions: u64
    }

    public struct Open has copy, drop, store {
        sender: address,
        pool_id: ID,
        position_id: ID,
        tick_lower_index: I32,
	    tick_upper_index: I32
    }

    public struct Close has copy, drop, store {
        sender: address,
        position_id: ID
    }

    public struct IncreaseLiquidity has copy, drop, store {
        sender: address,
        pool_id: ID,
        position_id: ID,
        liquidity: u128,
        amount_x: u64,
        amount_y: u64
    }

    public struct DecreaseLiquidity has copy, drop, store {
        sender: address,
        pool_id: ID,
        position_id: ID,
        liquidity: u128,
        amount_x: u64,
        amount_y: u64
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(PositionRegistry {
            id: object::new(ctx),
            num_positions: 0
        });
    }

    public fun open_position<X, Y>(
        self: &mut PositionRegistry,
        pool_registry: &PoolRegistry,
        fee_rate: u64,
        tick_lower_index: I32,
        tick_upper_index: I32,
        versioned: &mut Versioned,
        ctx: &mut TxContext
    ): Position {
		abort 0
    }

    public fun close_position(
        self: &mut PositionRegistry,
        position: Position,
        versioned: &mut Versioned,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun increase_liquidity<X, Y>(
        self: &mut PoolRegistry,
        position: &mut Position,
        x_in: Coin<X>,
        y_in: Coin<Y>,
        amount_x_min: u64,
        amount_y_min: u64,
        deadline: u64,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
		abort 0
    }

    public fun decrease_liquidity<X, Y>(
        self: &mut PoolRegistry,
        position: &mut Position,
        liquidity: u128,
        amount_x_min: u64,
        amount_y_min: u64,
        deadline: u64,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun collect<X, Y>(
        self: &mut PoolRegistry,
        position: &mut Position,
        amount_x_requested: u64,
        amount_y_requested: u64,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
    ): (Coin<X>, Coin<Y>) {
		abort 0
    }

    public fun collect_pool_reward<X, Y, RewardCoinType>(
        self: &mut PoolRegistry,
        position: &mut Position,
        amount_requested: u64,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
    ): Coin<RewardCoinType> {
		abort 0
    }
}