module dexcelerate::flow_x_protocol {
	use sui::coin::{Coin};
	use sui::sui::{SUI};

	use flow_x::factory::{Self, Container};
	use flow_x::pair;
	use flow_x::swap_utils;
	use flow_x::router;

	public(package) fun swap_a_to_b<A, B>(
		coin_in: Coin<A>,
		container: &mut Container,
		ctx: &mut TxContext
	): Coin<B> {
		router::swap_exact_input_direct<A, B>(
			container,
			coin_in,
			ctx
		)
	}
	
	public(package) fun get_required_coin_amount<T>(
		container: &mut Container,
		required_sui_out: u64
	): u64 {
		let pair_metadata = factory::borrow_mut_pair<SUI, T>(container); 
		let (reserve_0, reserve_1) = pair::get_reserves<SUI, T>(pair_metadata);
		
		swap_utils::get_amount_in(required_sui_out, reserve_0, reserve_1, pair::fee_rate<SUI, T>(pair_metadata))
	}
}