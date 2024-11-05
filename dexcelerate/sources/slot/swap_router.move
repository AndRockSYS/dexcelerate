module dexcelerate::swap_router {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};

	use flow_x::factory::{Container};
	use dexcelerate::flow_x_protocol;
	use blue_move::swap::{Dex_Info};
	use dexcelerate::blue_move_protocol;
	use move_pump::move_pump::{Configuration};
	use dexcelerate::move_pump_protocol;

	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};

	const ENotEnoughToCoverGas: u64 = 0;

	public(package) fun to_base_v2<T>(
		coin_in: Coin<T>,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<SUI>, Coin<T>) {
		let mut coin_in_left = coin::zero<T>(ctx);
		let mut coin_out = coin::zero<SUI>(ctx);

		let amount_min_out = 0;

		if(protocol_id == 0) {
			coin_out.join(flow_x_protocol::swap_exact_input<T, SUI>(
				container, coin_in, ctx
			));
		} else if(protocol_id == 1) {
			coin_out.join(blue_move_protocol::swap_exact_input<T, SUI>(
				coin_in, amount_min_out, dex_info, ctx
			));
		} else {
			let (out, left) = move_pump_protocol::sui_from_coin<T>(
				config, coin_in, amount_min_out, clock, ctx
			);
			coin_in_left.join(left);
			coin_out.join(out);
		};

		(coin_out, coin_in_left)
	} 

	public(package) fun calc_and_transfer_fees(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		mut payment: Coin<SUI>,
		users_fee_percent: u64,
		total_fee_percent: u64,
		ctx: &mut TxContext
	): Coin<SUI> {
		let total_fee = ((payment.value() as u128) * (total_fee_percent as u128) / 100_000) as u64;
		let user_fee = ((total_fee as u128) * (users_fee_percent as u128) / 100_000) as u64;

		bank.add_to_bank(payment.split(user_fee, ctx), ctx);
		fee_manager.add_fee(payment.split(total_fee - user_fee, ctx));

		payment
	}

	public(package) fun check_and_transfer_sponsor_gas(
		coin: &mut Coin<SUI>,
		gas_lended: u64,
		gas_sponsor: Option<address>,
		ctx: &mut TxContext
	) {
		if(gas_sponsor.is_some()) {
			assert!(coin.value() >= gas_lended, ENotEnoughToCoverGas);
			transfer::public_transfer(coin.split(gas_lended, ctx), gas_sponsor.destroy_some());
		};
	}
}