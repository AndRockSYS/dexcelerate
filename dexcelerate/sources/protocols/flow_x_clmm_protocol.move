module dexcelerate::flow_x_clmm_protocol {
	use sui::clock::{Clock};

	use sui::coin::{Self, Coin};
	use sui::balance;
	use sui::sui::{SUI};

	use flowx_clmm::pool::{Pool};
	use flowx_clmm::swap_router;
    use flowx_clmm::versioned::Versioned;
	use flowx_clmm::swap_math;

	use dexcelerate::utils;

	const A_TO_B: u128 = 4295048016;
	const B_TO_A: u128 = 79226673515401279992447579055;

	public(package) fun swap<A, B>(
		pool: &mut Pool<A, B>,
        coin_a_in: Coin<A>,
		coin_b_in: Coin<B>,
        versioned: &mut Versioned,
        clock: &Clock,
        ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		utils::check_amounts<A, B>(&coin_a_in, &coin_b_in);

		let mut coin_a_out = balance::zero<A>();
		let mut coin_b_out = balance::zero<B>();

		if(coin_a_in.value() > 0) {
			coin_b_out.join(
				swap_router::swap_exact_x_to_y<A, B>(
					pool, coin_a_in, A_TO_B, versioned, clock, ctx
				)
			);

			coin_b_in.destroy_zero();
		} else {
			coin_a_out.join(
				swap_router::swap_exact_y_to_x<A, B>(
					pool, coin_b_in, B_TO_A, versioned, clock, ctx
				)
			);

			coin_a_in.destroy_zero();
		};

		(coin::from_balance<A>(coin_a_out, ctx), coin::from_balance<B>(coin_b_out, ctx))
	}

	public(package) fun get_required_coin_amount<T>(
		pool: &Pool<T, SUI>,
		gas_amount: u64
	): u64 {
		let (_, amount_in, _, _) = swap_math::compute_swap_step(
			pool.sqrt_price_current(), pool.sqrt_price_current(),
			pool.liquidity(), gas_amount, pool.swap_fee_rate(), false
    	);

		amount_in
	}
}