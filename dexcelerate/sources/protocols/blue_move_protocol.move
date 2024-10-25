module dexcelerate::blue_move_protocol {
	use sui::coin::{Self, Coin};

	use dexcelerate::slot::{Self, Slot};

	use blue_move::router;
	use blue_move::swap::{Dex_Info};

	public entry fun swap_exact_input_slot<A, B>(
		slot: &mut Slot,
		amount_in: u64,
		amount_out_min: u64,
		dex_info: &mut Dex_Info,
		ctx: &mut TxContext
	) {
		let coin_in = slot::take_from_balance<A>(slot, amount_in, true, ctx);
		let swapped = swap_exact_input_coin<A, B>(
			coin_in, 
			amount_out_min,
			dex_info, 
			ctx
		);
		slot::add_to_balance<B>(slot, coin::into_balance<B>(swapped));
	}

	public(package) fun swap_exact_input_coin<A, B>(
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