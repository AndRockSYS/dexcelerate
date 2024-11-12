module dexcelerate::turbos_clmm_protocol {
	use sui::coin::{Coin};
	use sui::clock::{Clock};

	use turbos_clmm::pool::{Pool, Versioned};
	use turbos_clmm::swap_router;

	public(package) fun swap_a_to_b<A, B, FeeType>(
		pool: &mut Pool<A, B, FeeType>,
		coin_in: Coin<A>,
		clock: &Clock,
		versioned: &Versioned,
		ctx: &mut TxContext
	): (Coin<B>, Coin<A>) {
		let amount_in = coin_in.value();
		swap_router::swap_a_b_with_return_<A, B, FeeType>(
			pool,
			vector::singleton<Coin<A>>(coin_in), 
			amount_in,
			1_000, // amount_threshold
			4295048016,
			true,
			ctx.sender(),
			9_999_999_999_999, // deadline
			clock,
			versioned,
			ctx
    	)
	}

	public(package) fun swap_b_to_a<A, B, FeeType>(
		pool: &mut Pool<A, B, FeeType>,
		coin_in: Coin<B>,
		clock: &Clock,
		versioned: &Versioned,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		let amount_in = coin_in.value();
		swap_router::swap_b_a_with_return_<A, B, FeeType>(
			pool,
			vector::singleton<Coin<B>>(coin_in), 
			amount_in,
			1_000, // amount_threshold
			79226673515401279992447579055,
			true,
			ctx.sender(),
			9_999_999_999_999, // deadline
			clock,
			versioned,
			ctx
    	)
	}
}