module dexcelerate::move_pump_protocol {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin::{Coin};

	use blue_move::swap::{Dex_Info};
	use move_pump::move_pump::{Self, Configuration};

	use dexcelerate::swap_utils;

	public(package) fun swap<T>(
		coin_in: Coin<T>,
		sui_in: Coin<SUI>,
		amount_min_out: u64, 
		config: &mut Configuration, 
		dex_info: &mut Dex_Info, 
		clock: &Clock, 
		ctx: &mut TxContext
	): (Coin<SUI>, Coin<T>) {
		swap_utils::check_amounts<A, SUI>(&coin_in, &sui_in);

		if(coin_in.value() > 0) {
			sui_in.destroy_zero();

			move_pump::sell_returns<T>(
				config, coin_in, amount_min_out, clock, ctx
			)
		} else {
			coin_in.destroy_zero();

			move_pump::buy_returns<T>(
				config, sui_in, dex_info, amount_min_out, clock, ctx
			)
		}
	}
}