module dexcelerate::blue_move_protocol {
	use sui::coin::{Coin};

	use blue_move::router;
	use blue_move::swap::{Dex_Info};

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
}