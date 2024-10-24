module dexcelerate::turbos_clmm_protocol {
	use sui::coin::{Self, Coin};
	use sui::clock::{Clock};

	use dexcelerate::slot::{Self, Slot};

	use turbos_clmm::pool::{Pool, Versioned};
	use turbos_clmm::swap_router;

	const ENotASlotOwner: u64 = 0;

	public entry fun swap_a_to_b<A, B, FeeType>(
		slot: &mut Slot,
		pool: &mut Pool<A, B, FeeType>,
		amount_in: u64,
		amount_threshold: u64,
		sqrt_price_limit: u128,
		is_exact_in: bool,
		deadline: u64,
		clock: &Clock,
		versioned: &Versioned,
		ctx: &mut TxContext
	) {
		assert!(slot::get_owner(slot) == ctx.sender(), ENotASlotOwner);
		let balance_in = slot::take_from_balance<A>(slot, amount_in);

		let mut coins_a = vector::empty<Coin<A>>();
		coins_a.push_back(coin::from_balance<A>(balance_in, ctx));

		let (coin_out, coin_in_left) = swap_router::swap_a_b_with_return_<A, B, FeeType>(
			pool,
			coins_a, 
			amount_in,
			amount_threshold,
			sqrt_price_limit,
			is_exact_in,
			ctx.sender(),
			deadline,
			clock,
			versioned,
			ctx
    	);

		slot::add_to_balance<A>(slot, coin::into_balance<A>(coin_in_left));
		slot::add_to_balance<B>(slot, coin::into_balance<B>(coin_out));
	}

	public entry fun swap_b_to_a<A, B, FeeType>(
		slot: &mut Slot,
		pool: &mut Pool<A, B, FeeType>,
		amount_in: u64,
		amount_threshold: u64,
		sqrt_price_limit: u128,
		is_exact_in: bool,
		deadline: u64,
		clock: &Clock,
		versioned: &Versioned,
		ctx: &mut TxContext
	) {
		assert!(slot::get_owner(slot) == ctx.sender(), ENotASlotOwner);
		let balance_in = slot::take_from_balance<B>(slot, amount_in);

		let mut coins_a = vector::empty<Coin<B>>();
		coins_a.push_back(coin::from_balance<B>(balance_in, ctx));

		let (coin_out, coin_in_left) = swap_router::swap_b_a_with_return_<A, B, FeeType>(
			pool,
			coins_a, 
			amount_in,
			amount_threshold,
			sqrt_price_limit,
			is_exact_in,
			ctx.sender(),
			deadline,
			clock,
			versioned,
			ctx
    	);

		slot::add_to_balance<B>(slot, coin::into_balance<B>(coin_in_left));
		slot::add_to_balance<A>(slot, coin::into_balance<A>(coin_out));
	}
}