module dexcelerate::cetus_clmm_protocol {
	use sui::clock::{Clock};
	use sui::coin::{Self, Coin};
	use sui::sui::{SUI};

	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Self, Pool};
	use cetus::router;

	use dexcelerate::swap_utils;

	const A_TO_B: u64 = 4295048016;
	const B_TO_A: u64 = 79226673515401279992447579055;

	public(package) fun swap<A, B> (
		pool: &mut Pool<A, B>,
		coin_a_in: Coin<A>,
		coin_b_in: Coin<B>,
		config: &GlobalConfig,
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		swap_utils::check_amounts<A, B>(&coin_a_in, &coin_b_in);

		let coin_a_amount = coin_a_in.value();
		let amount_in = if(coin_a_amount > 0) {coin_a_in.value()} else {coin_a_amount};

		let sqrt_price = if(coin_a_amount > 0) {A_TO_B} else {B_TO_A};

		router::swap<A, B>(
			config, pool, coin_a_in, coin_b_in,  
			coin_a_amount > 0, true,
        	amount_in, sqrt_price, false, clock, ctx
		)
	}

	public(package) fun get_required_coin_amount<T>(
		pool: &Pool<T, SUI>,
		gas_amount: u64
	): u64 {
    	let swap_result = pool::calculate_swap_result<T, SUI>(
        	pool, true, false, gas_amount
		); 

		pool::calculated_swap_result_amount_in(&swap_result)
	}
} 