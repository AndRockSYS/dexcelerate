module dexcelerate::blue_move_protocol {
	use sui::coin::{Coin};
	use sui::sui::{SUI};

	use blue_move::router;
	use blue_move::swap::{Self, Dex_Info};

	public(package) fun swap_exact_input<A, B>(
		coin_in: Coin<A>,
		amount_out_min: u64,
		dex_info: &mut Dex_Info,
		ctx: &mut TxContext
	): Coin<B> {
		router::swap_exact_input_<A, B>(
			coin_in.value(), 
			coin_in, 
			amount_out_min,
			dex_info, 
			ctx
		)
	}

	public(package) fun get_required_coin_amount<T>(
		dex_info: &mut Dex_Info,
		required_sui_out: u64
	): u64 {
		let pool = swap::get_pool<SUI, T>(dex_info);
		let (reserve_0, reserve_1, _) = swap::get_amounts<SUI, T>(pool);

		((reserve_1 * required_sui_out as u128) as u64) / reserve_0
	}
}