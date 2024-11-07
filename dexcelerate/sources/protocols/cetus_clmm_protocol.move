module dexcelerate::cetus_clmm_protocol {
	use sui::clock::{Clock};
	use sui::coin::{Self, Coin};
	use sui::sui::{SUI};

	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Self, Pool};
	use cetus::router;

	public(package) fun swap_a_to_b<A, B>(
		config: &GlobalConfig,
		pool: &mut Pool<A, B>,
		coin_in: Coin<A>,
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		let amount_in = coin_in.value();
		router::swap<A, B>(
			config, 
			pool,
			coin_in,
			coin::zero<B>(ctx),  
			true,
        	true,
        	amount_in,
        	4295048016,
			false, 
			clock, 
			ctx
		)
	}

	public(package) fun swap_b_to_a<A, B>(
		config: &GlobalConfig,
		pool: &mut Pool<A, B>,
		coin_in: Coin<B>,
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		let amount_in = coin_in.value();
		router::swap<A, B>(
			config, 
			pool, 
			coin::zero<A>(ctx),
			coin_in,
			false,
        	true,
        	amount_in,
        	79226673515401279992447579055,
			false, 
			clock, 
			ctx
		)
	}

	public(package) fun get_required_coin_amount<T>(
		pool: &Pool<T, SUI>,
		gas_amount: u64
	): u64 {
    	let swap_result = pool::calculate_swap_result<T, SUI>(
        	pool, true, false, gas_amount
		);

		pool::calculated_swap_result_amount_out(&swap_result)
	}
} 