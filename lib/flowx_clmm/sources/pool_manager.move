module flowx_clmm::pool_manager {
    use std::type_name::{Self, TypeName};
    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::dynamic_object_field::{Self as dof};
    use sui::event;
    use sui::transfer;
    use sui::clock::Clock;

    use flowx_clmm::admin_cap::AdminCap;
    use flowx_clmm::pool::{Self, Pool};
    use flowx_clmm::versioned::{Self, Versioned};
    use flowx_clmm::utils;

    const E_POOL_ALREADY_CREATED: u64 = 1;
    const E_INVALID_FEE_RATE: u64 = 2;
    const E_TICK_SPACING_OVERFLOW: u64 = 3;
    const E_FEE_RATE_ALREADY_ENABLED: u64 = 4;
    const E_POOL_NOT_CREATED: u64 = 5;
    const E_FEE_RATE_NOT_ENABLED: u64 = 6;

    public struct PoolDfKey has copy, drop, store {
        coin_type_x: TypeName,
        coin_type_y: TypeName,
        fee_rate: u64
    }

    public struct PoolRegistry has key, store {
        id: UID,
        fee_amount_tick_spacing: Table<u64, u32>,
        num_pools: u64
    }

    public struct PoolCreated has copy, drop, store {
        sender: address,
        pool_id: ID,
        coin_type_x: TypeName,
        coin_type_y: TypeName,
        fee_rate: u64,
        tick_spacing: u32
    }

    public struct FeeRateEnabled has copy, drop, store {
        sender: address,
        fee_rate: u64,
        tick_spacing: u32
    }

    fun init(ctx: &mut TxContext) {
		abort 0
    }
    
    fun pool_key<X, Y>(fee_rate: u64): PoolDfKey {
		abort 0
    }

    public fun check_exists<X, Y>(self: &PoolRegistry, fee_rate: u64) {
		abort 0
    }

    public fun borrow_pool<X, Y>(self: &PoolRegistry, fee_rate: u64): &Pool<X, Y> {
		abort 0
    }

    public fun borrow_mut_pool<X, Y>(self: &mut PoolRegistry, fee_rate: u64): &mut Pool<X, Y> {
		abort 0
    }

    fun create_pool_<X, Y>(
        self: &mut PoolRegistry,
        fee_rate: u64,
        ctx: &mut TxContext
    ) {
		abort 0
    }

    public fun create_pool<X, Y>(
        self: &mut PoolRegistry,
        fee_rate: u64,
        versioned: &mut Versioned,
        ctx: &mut TxContext
    ) {
		abort 0
    }

    public fun create_and_initialize_pool<X, Y>(
        self: &mut PoolRegistry,
        fee_rate: u64,
        sqrt_price: u128,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
		abort 0
    }

    public fun enable_fee_rate(
        _: &AdminCap,
        self: &mut PoolRegistry,
        fee_rate: u64,
        tick_spacing: u32,
        versioned: &mut Versioned,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun set_protocol_fee_rate<X, Y>(
        admin_cap: &AdminCap,
        self: &mut PoolRegistry,
        fee_rate: u64,
        protocol_fee_rate_x: u64,
        protocol_fee_rate_y: u64,
        versioned: &mut Versioned,
        ctx: &mut TxContext
    ) {
		abort 0
    }

    public fun collect_protocol_fee<X, Y>(
        admin_cap: &AdminCap,
        self: &mut PoolRegistry,
        fee_rate: u64,
        amount_x_requested: u64,
        amount_y_requested: u64,
        versioned: &mut Versioned,
        ctx: &mut TxContext
    ): (Coin<X>, Coin<Y>) {
		abort 0
    }

    public fun initialize_pool_reward<X, Y, RewardCoinType>(
        admin_cap: &AdminCap,
        self: &mut PoolRegistry,
        fee_rate: u64,
        started_at_seconds: u64,
        ended_at_seconds: u64,
        allocated: Coin<RewardCoinType>,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun increase_pool_reward<X, Y, RewardCoinType>(
        admin_cap: &AdminCap,
        self: &mut PoolRegistry,
        fee_rate: u64,
        allocated: Coin<RewardCoinType>,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun extend_pool_reward_timestamp<X, Y, RewardCoinType>(
        admin_cap: &AdminCap,
        self: &mut PoolRegistry,
        fee_rate: u64,
        timestamp: u64,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ) {
		abort 0
    }

    fun enable_fee_rate_internal(
        self: &mut PoolRegistry,
        fee_rate: u64,
        tick_spacing: u32,
        ctx: &TxContext
    ) {
		abort 0
    }
}