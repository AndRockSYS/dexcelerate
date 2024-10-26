module dexcelerate::move_pump_protocol {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin::{Coin};

	use blue_move::swap::{Dex_Info};
	use move_pump::move_pump::{Self, Configuration};

	public(package) fun sui_to_coin<T>(
		config: &mut Configuration, 
		dex_info: &mut Dex_Info, 
		coin_in: Coin<SUI>,
		amount_min_out: u64, 
		clock: &Clock, 
		ctx: &mut TxContext
	): (Coin<SUI>, Coin<T>) {
		move_pump::buy_returns<T>(
			config, 
			coin_in, 
			dex_info, 
			amount_min_out, 
			clock, 
			ctx
		)
	}

	public(package) fun sui_from_coin<T>(
		config: &mut Configuration, 
		coin_in: Coin<T>, 
		amount_min_out: u64, 
		clock: &Clock, 
		ctx: &mut TxContext
	): (Coin<SUI>, Coin<T>) {
		move_pump::sell_returns<T>(
			config, 
			coin_in, 
			amount_min_out, 
			clock, 
			ctx
		)
	}
}