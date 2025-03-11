module flowx_clmm::swap_router {
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::clock::Clock;

    use flowx_clmm::pool_manager::{Self, PoolRegistry};
    use flowx_clmm::tick_math;
    use flowx_clmm::pool::{Self, Pool};
    use flowx_clmm::versioned::Versioned;
    use flowx_clmm::utils;

    const E_INSUFFICIENT_OUTPUT_AMOUNT: u64 = 1;
    const E_EXCESSIVE_INPUT_AMOUNT: u64 = 2;

    public fun swap_exact_x_to_y<X, Y>(
        pool: &mut Pool<X, Y>,
        coin_in: Coin<X>,
        sqrt_price_limit: u128,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ): Balance<Y> {
		abort 0
    }

    public fun swap_exact_y_to_x<X, Y>(
        pool: &mut Pool<X, Y>,
        coin_in: Coin<Y>,
        sqrt_price_limit: u128,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &TxContext
    ): Balance<X> {
		abort 0
    }

    public fun swap_exact_input<X, Y>(
        pool_registry: &mut PoolRegistry,
        fee: u64,
        coin_in: Coin<X>,
        amount_out_min: u64,
        sqrt_price_limit: u128,
        deadline: u64,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
    ): Coin<Y> {
		abort 0
    }

    public fun swap_x_to_exact_y<X, Y>(
        pool: &mut Pool<X, Y>,
        coin_in: Coin<X>,
        amount_y_out: u64,
        sqrt_price_limit: u128,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
    ): Balance<Y> {
		abort 0
    }

    public fun swap_y_to_exact_x<X, Y>(
        pool: &mut Pool<X, Y>,
        coin_in: Coin<Y>,
        amount_x_out: u64,
        sqrt_price_limit: u128,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
    ): Balance<X> {
		abort 0
    }

    public fun swap_exact_output<X, Y>(
        pool_registry: &mut PoolRegistry,
        fee: u64,
        coin_in: Coin<X>,
        amount_out: u64,
        sqrt_price_limit: u128,
        deadline: u64,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
    ): Coin<Y> {
		abort 0
	}

    fun get_sqrt_price_limit(sqrt_price_limit: u128, x_for_y: bool): u128 {
		abort 0
    }
}