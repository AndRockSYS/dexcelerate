module dexcelerate::move_pump_protocol {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin;

	use blue_move::swap::{Dex_Info};
	use move_pump::move_pump::{Self, Configuration};

	use dexcelerate::slot::{Self, Slot};

	const ENotASlotOwner: u64 = 0;

	public entry fun swap_sui_for_coin<T>(
		config: &mut Configuration, 
		dex_info: &mut Dex_Info, 
		slot: &mut Slot,
		amount_in: u64, 
		amount_min_out: u64, 
		clock: &Clock, 
		ctx: &mut TxContext
	) {
		assert!(slot::get_owner(slot) == ctx.sender(), ENotASlotOwner);

		let balance_in = slot::take_from_balance<SUI>(slot, amount_in);
		let (coin_in_left, coin_out) = move_pump::buy_returns<T>(
			config, 
			coin::from_balance<SUI>(balance_in, ctx), 
			dex_info, 
			amount_min_out, 
			clock, 
			ctx
		);

		slot::add_to_balance<SUI>(slot, coin::into_balance<SUI>(coin_in_left));
		slot::add_to_balance<T>(slot, coin::into_balance<T>(coin_out));
	}

	public entry fun swap_coin_for_sui<T>(
		config: &mut Configuration, 
		slot: &mut Slot,
		amount_in: u64, 
		amount_min_out: u64, 
		clock: &Clock, 
		ctx: &mut TxContext
	) {
		assert!(slot::get_owner(slot) == ctx.sender(), ENotASlotOwner);

		let balance_in = slot::take_from_balance<T>(slot, amount_in);
		let (coin_out, coin_in_left) = move_pump::sell_returns<T>(
			config, 
			coin::from_balance<T>(balance_in, ctx), 
			amount_min_out, 
			clock, 
			ctx
		);

		slot::add_to_balance<T>(slot, coin::into_balance<T>(coin_in_left));
		slot::add_to_balance<SUI>(slot, coin::into_balance<SUI>(coin_out));
	}
}