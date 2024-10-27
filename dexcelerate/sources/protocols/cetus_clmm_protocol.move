module dexcelerate::cetus_clmm_protocol {
	use sui::clock::{Clock};
	use sui::coin::{Self, Coin};

	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool};
	use cetus::router;

	public(package) fun swap_a_to_b<A, B>(
		config: &GlobalConfig,
		pool: &mut Pool<A, B>,
		coin_in: Coin<A>,
		amount_out_min: u64,
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		let amount_in = coin_in.value();
		let sqrt_price_limit = if(amount_in < amount_out_min) {79226673515401279992447579055} else {4295048016};
		router::swap<A, B>(
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
		)
	}

	public(package) fun swap_b_to_a<A, B>(
		config: &GlobalConfig,
		pool: &mut Pool<A, B>,
		coin_in: Coin<B>,
		amount_out_min: u64,
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		let amount_in = coin_in.value();
		let sqrt_price_limit = if(amount_in < amount_out_min) {79226673515401279992447579055} else {4295048016};
		router::swap<A, B>(
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
		)
	}
}