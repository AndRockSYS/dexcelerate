module flowx_clmm::pool {
    use std::vector;
    use std::type_name::{Self, TypeName};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::table::{Self, Table};
    use sui::event;
    use sui::clock::{Self, Clock};
    use sui::dynamic_field::{Self as df};
    use sui::math;
    
    use flowx_clmm::admin_cap::AdminCap;
    use flowx_clmm::i32::{Self, I32};
    use flowx_clmm::i64::{Self, I64};
    use flowx_clmm::i128::{Self, I128};
    use flowx_clmm::tick::{Self, TickInfo};
    use flowx_clmm::position::{Self, Position};
    use flowx_clmm::versioned::{Self, Versioned};
    use flowx_clmm::liquidity_math;
    use flowx_clmm::tick_bitmap;
    use flowx_clmm::tick_math;
    use flowx_clmm::sqrt_price_math;
    use flowx_clmm::swap_math;
    use flowx_clmm::constants;
    use flowx_clmm::full_math_u64;
    use flowx_clmm::full_math_u128;
    use flowx_clmm::oracle::{Self, Observation};
    use flowx_clmm::utils;

    const E_POOL_ID_MISMATCH: u64 = 0;
    const E_INSUFFICIENT_INPUT_AMOUNT: u64 = 1;
    const E_POOL_ALREADY_INITIALIZED: u64 = 2;
    const E_POOL_ALREADY_LOCKED: u64 = 3;
    const E_PRICE_LIMIT_ALREADY_EXCEEDED: u64 = 4;
    const E_PRICE_LIMIT_OUT_OF_BOUNDS: u64 = 5;
    const E_INSUFFICIENT_LIQUIDITY: u64 = 6;
    const E_INVALID_PROTOCOL_FEE_RATE: u64 = 7;
    const E_TICK_NOT_INITIALIZED: u64 = 8;
    const E_INVALID_REWARD_TIMESTAMP: u64 = 9;
    const E_POOL_REWARD_NOT_FOUND: u64 = 10;
    const E_REWARD_INDEX_OUT_OF_BOUNDS: u64 = 11;

    public struct PoolRewardCustodianDfKey<phantom T> has copy, drop, store {}

    public struct Pool<phantom CoinX, phantom CoinY> has key, store {
        id: UID,
        coin_type_x: TypeName,
        coin_type_y: TypeName,
        // the current price
        sqrt_price: u128,
        // the current tick
        tick_index: I32,
        observation_index: u64,
        observation_cardinality: u64,
        observation_cardinality_next: u64,
        // the pool tick spacing
        tick_spacing: u32,
        max_liquidity_per_tick: u128,
        // the current protocol fee as a percentage of the swap fee taken on withdrawal
        // represented as an integer denominator (1/x)%
        protocol_fee_rate: u64,
        // used for the swap fee, either static at initialize or dynamic via hook
        swap_fee_rate: u64,
        fee_growth_global_x: u128,
        fee_growth_global_y: u128,
        protocol_fee_x: u64,
        protocol_fee_y: u64,
        // the currently in range liquidity available to the pool
        liquidity: u128,
        ticks: Table<I32, TickInfo>,
        tick_bitmap: Table<I32, u256>,
        observations: vector<Observation>,
        locked: bool,
        reward_infos: vector<PoolRewardInfo>,
        reserve_x: Balance<CoinX>,
        reserve_y: Balance<CoinY>,
    }

    public struct PoolRewardInfo has copy, store, drop {
        reward_coin_type: TypeName,
        last_update_time: u64,
        ended_at_seconds: u64,
        total_reward: u64,
        total_reward_allocated: u64,
        reward_per_seconds: u128,
        reward_growth_global: u128
    }

    public struct SwapState has copy, drop {
        amount_specified_remaining: u64,
        amount_calculated: u64,
        sqrt_price: u128,
        tick_index: I32,
        fee_growth_global: u128,
        protocol_fee: u64,
        liquidity: u128,
        fee_amount: u64
    }

    public struct SwapStepComputations has copy, drop {
        sqrt_price_start: u128,
        tick_index_next: I32,
        initialized: bool,
        sqrt_price_next: u128,
        amount_in: u64,
        amount_out: u64,
        fee_amount: u64
    }

    public struct SwapReceipt {
        pool_id: ID,
        amount_x_debt: u64,
        amount_y_debt: u64
    }

    public struct FlashReceipt {
        pool_id: ID,
        amount_x: u64,
        amount_y: u64,
        fee_x: u64,
        fee_y: u64
    }

    public struct ModifyLiquidity has copy, drop, store {
        sender: address,
        pool_id: ID,
        position_id: ID,
        tick_lower_index: I32,
        tick_upper_index: I32,
        liquidity_delta: I128,
        amount_x: u64,
        amount_y: u64
    }

    public struct Swap has copy, drop, store {
        sender: address,
        pool_id: ID,
        x_for_y: bool,
        amount_x: u64,
        amount_y: u64,
        sqrt_price_before: u128,
        sqrt_price_after: u128,
        liquidity: u128,
        tick_index: I32,
        fee_amount: u64
    }

    public struct Flash has copy, drop, store {
        sender: address,
        pool_id: ID,
        amount_x: u64,
        amount_y: u64
    }

    public struct Pay has copy, drop, store {
        sender: address,
        pool_id: ID,
        amount_x_debt: u64,
        amount_y_debt: u64,
        paid_x: u64,
        paid_y: u64
    }

    public struct Collect has copy, drop, store {
        sender: address,
        pool_id: ID,
        position_id: ID,
        amount_x: u64,
        amount_y: u64
    }

    public struct CollectProtocolFee has copy, drop, store {
        sender: address,
        pool_id: ID,
        amount_x: u64,
        amount_y: u64
    }
    
    public struct SetProtocolFeeRate has copy, drop, store {
        sender: address,
        pool_id: ID,
        protocol_fee_rate_x_old: u64,
        protocol_fee_rate_y_old: u64,
        protocol_fee_rate_x_new: u64,
        protocol_fee_rate_y_new: u64
    }

    public struct Initialize has copy, drop, store {
        sender: address,
        pool_id: ID,
        sqrt_price: u128,
        tick_index: I32
    }

    public struct IncreaseObservationCardinalityNext has copy, drop, store {
        sender: address,
        pool_id: ID,
        observation_cardinality_next_old: u64,
        observation_cardinality_next_new: u64
    }

    public struct InitializePoolReward has copy, drop, store {
        sender: address,
        pool_id: ID,
        reward_coin_type: TypeName,
        started_at_seconds: u64
    }

    public struct UpdatePoolRewardEmission has copy, drop, store {
        sender: address,
        pool_id: ID,
        reward_coin_type: TypeName,
        total_reward: u64,
        ended_at_seconds: u64,
        reward_per_seconds: u128
    }

    public struct CollectPoolRewrad has copy, drop, store {
        sender: address,
        pool_id: ID,
        position_id: ID,
        reward_coin_type: TypeName,
        amount: u64
    }

    public fun pool_id<X, Y>(self: &Pool<X, Y>): ID { object::id(self) }

    public fun coin_type_x<X, Y>(self: &Pool<X, Y>): TypeName { self.coin_type_x }

    public fun coin_type_y<X, Y>(self: &Pool<X, Y>): TypeName { self.coin_type_y }

    public fun sqrt_price_current<X, Y>(self: &Pool<X, Y>): u128 { self.sqrt_price }

    public fun tick_index_current<X, Y>(self: &Pool<X, Y>): I32 { self.tick_index }

    public fun observation_index<X, Y>(self: &Pool<X, Y>): u64 { self.observation_index }

    public fun observation_cardinality<X, Y>(self: &Pool<X, Y>): u64 { self.observation_cardinality }

    public fun observation_cardinality_next<X, Y>(self: &Pool<X, Y>): u64 { self.observation_cardinality_next }

    public fun tick_spacing<X, Y>(self: &Pool<X, Y>): u32 { self.tick_spacing }

    public fun max_liquidity_per_tick<X, Y>(self: &Pool<X, Y>): u128 { self.max_liquidity_per_tick }

    public fun protocol_fee_rate<X, Y>(self: &Pool<X, Y>): u64 { self.protocol_fee_rate }

    public fun swap_fee_rate<X, Y>(self: &Pool<X, Y>): u64 { self.swap_fee_rate }

    public fun fee_growth_global_x<X, Y>(self: &Pool<X, Y>): u128 { self.fee_growth_global_x }

    public fun fee_growth_global_y<X, Y>(self: &Pool<X, Y>): u128 { self.fee_growth_global_y }

    public fun protocol_fee_x<X, Y>(self: &Pool<X, Y>): u64 { self.protocol_fee_x }

    public fun protocol_fee_y<X, Y>(self: &Pool<X, Y>): u64 { self.protocol_fee_y }

    public fun liquidity<X, Y>(self: &Pool<X, Y>): u128 { self.liquidity }

    public fun borrow_ticks<X, Y>(self: &Pool<X, Y>): &Table<I32, TickInfo> { &self.ticks }

    public fun borrow_tick_bitmap<X, Y>(self: &Pool<X, Y>): &Table<I32, u256> { &self.tick_bitmap }

    public fun borrow_observations<X, Y>(self: &Pool<X, Y>): &vector<Observation> { &self.observations }

    public fun is_locked<X, Y>(self: &Pool<X, Y>): bool { self.locked }

    public fun reward_length<X, Y>(self: &Pool<X, Y>): u64 { vector::length(&self.reward_infos) }

    public fun reward_info_at<X, Y>(self: &Pool<X, Y>, i: u64): &PoolRewardInfo {
		abort 0
    }

    public fun reward_coin_type<X, Y>(self: &Pool<X, Y>, i: u64): TypeName { reward_info_at(self, i).reward_coin_type }

    public fun reward_last_update_at<X, Y>(self: &Pool<X, Y>, i: u64): u64 { reward_info_at(self, i).last_update_time }

    public fun reward_ended_at<X, Y>(self: &Pool<X, Y>, i: u64): u64 { reward_info_at(self, i).ended_at_seconds }

    public fun total_reward<X, Y>(self: &Pool<X, Y>, i: u64): u64 { reward_info_at(self, i).total_reward }

    public fun total_reward_allocated<X, Y>(self: &Pool<X, Y>, i: u64): u64 { reward_info_at(self, i).total_reward_allocated }

    public fun reward_per_seconds<X, Y>(self: &Pool<X, Y>, i: u64): u128 { reward_info_at(self, i).reward_per_seconds }

    public fun reward_growth_global<X, Y>(self: &Pool<X, Y>, i: u64): u128 { reward_info_at(self, i).reward_growth_global }

    public fun reserves<X, Y>(self: &Pool<X, Y>): (u64, u64) {
		abort 0
    }

    public fun swap_receipt_debts(receipt: &SwapReceipt): (u64, u64) { (receipt.amount_x_debt, receipt.amount_y_debt) }

    public fun flash_receipt_debts(receipt: &FlashReceipt): (u64, u64) {
		abort 0
    }

    public(package) fun create<X, Y>(
        fee_rate: u64,
        tick_spacing: u32,
        ctx: &mut TxContext
    ): Pool<X, Y> {
		abort 0
    }

    public fun initialize<X, Y>(
        self: &mut Pool<X, Y>,
        sqrt_price: u128,
        clock: &Clock,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun modify_liquidity<X, Y>(
        self: &mut Pool<X, Y>,
        position: &mut Position,
        liquidity_delta: I128,
        x_in: Balance<X>,
        y_in: Balance<Y>,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ): (u64, u64) {
		abort 0
    }

    public fun swap<X, Y>(
        self: &mut Pool<X, Y>,
        x_for_y: bool,
        exact_in: bool,
        amount_specified: u64,
        sqrt_price_limit: u128,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ): (Balance<X>, Balance<Y>, SwapReceipt) {
		abort 0
    }

    public fun pay<X, Y>(
        self: &mut Pool<X, Y>,
        receipt: SwapReceipt,
        payment_x: Balance<X>,
        payment_y: Balance<Y>,
        versioned: &mut Versioned,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun flash<X, Y>(
        self: &mut Pool<X, Y>,
        amount_x: u64,
        amount_y: u64,
        versioned: &mut Versioned,
        ctx: &TxContext
    ): (Balance<X>, Balance<Y>, FlashReceipt) {
		abort 0
    }

    public fun repay<X, Y>(
        self: &mut Pool<X, Y>,
        receipt: FlashReceipt,
        payment_x: Balance<X>,
        payment_y: Balance<Y>,
        versioned: &mut Versioned,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun collect<X, Y>(
        self: &mut Pool<X, Y>,
        position: &mut Position,
        amount_x_requested: u64,
        amount_y_requested: u64,
        versioned: &mut Versioned,
        ctx: &TxContext
    ): (Balance<X>, Balance<Y>) {
		abort 0
    }

    public fun collect_protocol_fee<X, Y>(
        _: &AdminCap,
        self: &mut Pool<X, Y>,
        amount_x_requested: u64,
        amount_y_requested: u64,
        versioned: &mut Versioned,
        ctx: &TxContext
    ): (Balance<X>, Balance<Y>) {
		abort 0
    }

    public fun collect_pool_reward<X, Y, RewardCoinType>(
        self: &mut Pool<X, Y>,
        position: &mut Position,
        amount_requested: u64,
        versioned: &mut Versioned,
        ctx: &TxContext
    ): Balance<RewardCoinType> {
		abort 0
    }

    public fun set_protocol_fee_rate<X, Y>(
        _: &AdminCap,
        self: &mut Pool<X, Y>,
        protocol_fee_rate_x: u64,
        protocol_fee_rate_y: u64,
        versioned: &mut Versioned,
        ctx: &TxContext
    ) {
		abort 0
    }
    
    public fun increase_observation_cardinality_next<X, Y>(
        self: &mut Pool<X, Y>,
        observation_cardinality_next: u64,
        versioned: &mut Versioned,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun snapshot_cumulatives_inside<X, Y>(
        self: &Pool<X, Y>,
        tick_lower_index: I32,
        tick_upper_index: I32,
        clock: &Clock
    ): (I64, u256, u64) {
		abort 0
    }

    public fun observe<X, Y>(
        self: &Pool<X, Y>,
        seconds_agos: vector<u64>,
        clock: &Clock
    ): (vector<I64>, vector<u256>) {
        oracle::observe(
            &self.observations,
            utils::to_seconds(clock::timestamp_ms(clock)),
            seconds_agos,
            self.tick_index,
            self.observation_index,
            self.liquidity,
            self.observation_cardinality
        )
    }

    public fun initialize_pool_reward<X, Y, RewardCoinType>(
        _: &AdminCap,
        self: &mut Pool<X, Y>,
        started_at_seconds: u64,
        ended_at_seconds: u64,
        allocated: Balance<RewardCoinType>,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun increase_pool_reward<X, Y, RewardCoinType>(
        _: &AdminCap,
        self: &mut Pool<X, Y>,
        allocated: Balance<RewardCoinType>,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ) {
		abort 0
    }

    public fun extend_pool_reward_timestamp<X, Y, RewardCoinType>(
        _: &AdminCap,
        self: &mut Pool<X, Y>,
        timestamp: u64,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ) {
		abort 0
    }

    fun update_pool_reward_emission<X, Y, RewardCoinType>(
        self: &mut Pool<X, Y>,
        allocated: Balance<RewardCoinType>,
        timestamp: u64,
        ctx: &TxContext
    ) {
		abort 0
    }

    fun modify_position<X, Y>(
        pool: &mut Pool<X, Y>,
        position: &mut Position,
        liquidity_delta: I128,
        clock: &Clock,
    ): (u64, u64) {
		abort 0
    }

    fun update_position<X, Y>(
        pool: &mut Pool<X, Y>,
        position: &mut Position,
        liquidity_delta: I128,
        clock: &Clock,
    ) {
		abort 0
    }

    fun update_reward_infos<X, Y>(self: &mut Pool<X, Y>, current_timestamp: u64): vector<u128> {
		abort 0
    }

    fun find_reward_info_index<X, Y, RewardCoinType>(self: &Pool<X, Y>): u64 {
		abort 0
    }

    fun check_pool_match<X, Y>(self: &Pool<X, Y>, id: ID) {
		abort 0
    }

    fun check_lock<X, Y>(self: &Pool<X, Y>) {
		abort 0
    }

    fun take<X, Y>(
        self: &mut Pool<X, Y>,
        amount_x: u64,
        amount_y: u64
    ): (Balance<X>, Balance<Y>) {
		abort 0
    }

    fun put<X, Y>(
        self: &mut Pool<X, Y>,
        payment_x: Balance<X>,
        payment_y: Balance<Y>,
    ) {
		abort 0
    }
    
    fun safe_withdraw<T>(
        balance: &mut Balance<T>,
        amount_requested: u64
    ): Balance<T> {
		abort 0
    }
}