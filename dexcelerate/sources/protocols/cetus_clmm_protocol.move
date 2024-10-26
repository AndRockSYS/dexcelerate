module dexcelerate::cetus_clmm_protocol {
	use sui::clock::{Clock};
	use sui::coin;

	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool};
	use cetus::router;

	use dexcelerate::slot::{Self, Slot};

	public entry fun swap_a_to_b_exact_input<A, B>(
		config: &GlobalConfig,
		pool: &mut Pool<A, B>,
		slot: &mut Slot,
		amount_in: u64,
		amount_out_min: u64,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let sqrt_price_limit = if(amount_in < amount_out_min) {79226673515401279992447579055} else {4295048016};
		let coin_in = slot::take_from_balance<A>(slot, amount_in, true, ctx);
		let (coin_a_out, coin_b_out) = router::swap<A, B>(
			config, 
			pool,
			coin_in,
			coin::zero<B>(ctx),  
			true,
        	true,
        	amount_in,
        	sqrt_price_limit,
			false, 
			clock, 
			ctx
		);

		slot::add_to_balance<A>(slot, coin::into_balance<A>(coin_a_out));
		slot::add_to_balance<B>(slot, coin::into_balance<B>(coin_b_out));
	}

	public entry fun swap_b_to_a_exact_input<A, B>(
		config: &GlobalConfig,
		pool: &mut Pool<A, B>,
		slot: &mut Slot,
		amount_in: u64,
		amount_out_min: u64,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let sqrt_price_limit = if(amount_in < amount_out_min) {79226673515401279992447579055} else {4295048016};
		let coin_in = slot::take_from_balance<B>(slot, amount_in, true, ctx);
		let (coin_a_out, coin_b_out) = router::swap<A, B>(
			config, 
			pool, 
			coin::zero<A>(ctx),
			coin_in,
			false,
        	true,
        	amount_in,
        	sqrt_price_limit,
			false, 
			clock, 
			ctx
		);

		slot::add_to_balance<A>(slot, coin::into_balance<A>(coin_a_out));
		slot::add_to_balance<B>(slot, coin::into_balance<B>(coin_b_out));
	}
}