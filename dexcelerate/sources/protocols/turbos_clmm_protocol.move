module dexcelerate::turbos_clmm_protocol {
	use sui::coin::{Self, Coin};
	use sui::clock::{Clock};

	use turbos_clmm::pool::{Pool, Versioned};
	use turbos_clmm::swap_router;

	use dexcelerate::utils;

	const A_TO_B: u128 = 4295048016;
	const B_TO_A: u128 = 79226673515401279992447579055;
	const DEADLINE: u64 = 9_999_999_999_999;
	const TRESHOLD: u64 = 1_000;

	public(package) fun swap<A, B, FeeType>(
		pool: &mut Pool<A, B, FeeType>,
		coin_a_in: Coin<A>,
		coin_b_in: Coin<B>,
		versioned: &Versioned,
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		utils::check_amounts<A, B>(&coin_a_in, &coin_b_in);

		let mut coin_a_out = coin::zero<A>(ctx);
		let mut coin_b_out = coin::zero<B>(ctx);

		if(coin_a_in.value() > 0 ) { 
			coin_b_in.destroy_zero();
			let amount_in = coin_a_in.value();

			let (coin_b, coin_a) = swap_router::swap_a_b_with_return_<A, B, FeeType>(
				pool, vector::singleton<Coin<A>>(coin_a_in), amount_in,
				TRESHOLD, A_TO_B, true,
				ctx.sender(), DEADLINE, clock, versioned, ctx
			);

			coin_a_out.join(coin_a);
			coin_b_out.join(coin_b);
		} else {
			coin_a_in.destroy_zero();
			let amount_in = coin_b_in.value();

			let (coin_a, coin_b) = swap_router::swap_b_a_with_return_<A, B, FeeType>(
				pool, vector::singleton<Coin<B>>(coin_b_in), amount_in,
				TRESHOLD, B_TO_A, true,
				ctx.sender(), DEADLINE, clock, versioned, ctx
			);

			coin_a_out.join(coin_a);
			coin_b_out.join(coin_b);
		};

		(coin_a_out, coin_b_out)
	}
}