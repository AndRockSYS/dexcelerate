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
	const EZeroCoins: u64 = 1;
	const ETwoCoins: u64 = 2;

	public(package) fun swap_v2<A, B>(
		coin_in: Coin<A>,
		amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		protocol_id: u8, // 0 or 1
		ctx: &mut TxContext
	): Coin<B> {
		let mut coin_out = coin::zero<B>(ctx);

		if(protocol_id == 0) {
			coin_out.join(flow_x_protocol::swap_exact_input<A, B>(
				container, coin_in, ctx
			));
		} else {
			coin_out.join(blue_move_protocol::swap_exact_input<A, B>(
				coin_in, amount_min_out, dex_info, ctx
			));
		};

		coin_out
	}

	public(package) fun swap_base_v2<T>(
		coin_in: Coin<T>,
		base_in: Coin<SUI>,
		amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<SUI>, Coin<T>) {
		assert!(coin_in.value() > 0 || base_in.value() > 0, EZeroCoins);
		if(coin_in.value() > 0 && base_in.value() > 0) {
			abort(ETwoCoins)
		};

		if(coin_in.value() > 0) {
			// swapping T to SUI

			let mut coin_in_left = coin::zero<T>(ctx);
			let mut base_out = coin::zero<SUI>(ctx);

			if(protocol_id == 2) {
				let (out, left) = move_pump_protocol::sui_from_coin<T>(
					config, coin_in, amount_min_out, clock, ctx
				);
				coin_in_left.join(left);
				base_out.join(out);
			} else {
				base_out.join(swap_v2<T, SUI>(
					coin_in, amount_min_out,
					container, dex_info, protocol_id,
					ctx
				));
			};

			base_in.destroy_zero();

			(base_out, coin_in_left)
		} else {
			// swapping SUI to T

			let mut base_in_left = coin::zero<SUI>(ctx);
			let mut coin_out = coin::zero<T>(ctx);

			if(protocol_id == 2) {
				let (left, out) = move_pump_protocol::sui_to_coin<T>(
					config, dex_info, base_in, amount_min_out, clock, ctx
				);
				base_in_left.join(left);
				coin_out.join(out);
			} else {
				coin_out.join(swap_v2<SUI, T>(
					base_in, amount_min_out,
					container, dex_info, protocol_id,
					ctx
				));
			};

			coin_in.destroy_zero();

			(base_in_left, coin_out)
		}
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