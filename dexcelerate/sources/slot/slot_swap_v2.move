module dexcelerate::slot_swap_v2 {
	use std::bcs::to_bytes;
	use std::type_name;

	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};

	use dexcelerate::utils;
	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};

	use flow_x::factory::{Container};
	use dexcelerate::flow_x_protocol;
	use blue_move::swap::{Dex_Info};
	use dexcelerate::blue_move_protocol;
	use move_pump::move_pump::{Configuration};
	use dexcelerate::move_pump_protocol;

	const EWrongSwapType: u64 = 0;

	public entry fun buy_with_base<B>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,
		slot: &mut Slot,
		amount_in: u64,
		amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance<SUI>(amount_in, true, ctx);

		coin_in = calc_and_transfer_fees(
			bank, 
			fee_manager, 
			coin_in, 
			users_fee_percent, 
			total_fee_percent, ctx
		);

		let mut coin_in_left = coin::zero<SUI>(ctx);
		let mut coin_out = coin::zero<B>(ctx);

		if(protocol_id == 0) {
			coin_out.join(flow_x_protocol::swap_exact_input<SUI, B>(container, coin_in, ctx));
		} else if(protocol_id == 1) {
			coin_out.join(blue_move_protocol::swap_exact_input<SUI, B>(coin_in, amount_min_out, dex_info, ctx));
		} else {
			let (left, out) = move_pump_protocol::sui_to_coin<B>(
				config, dex_info, coin_in, amount_min_out, clock, ctx
			);
			coin_in_left.join(left);
			coin_out.join(out);
		};

		slot.add_to_balance<B>(coin_out.into_balance<B>());
		slot.add_to_balance<SUI>(coin_in_left.into_balance<SUI>());
	}

	public entry fun sell_with_base<A>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,
		slot: &mut Slot,
		amount_in: u64,
		amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_in = slot.take_from_balance<A>(amount_in, true, ctx);

		let mut coin_in_left = coin::zero<A>(ctx);
		let mut coin_out = coin::zero<SUI>(ctx);

		if(protocol_id == 0) {
			coin_out.join(flow_x_protocol::swap_exact_input<A, SUI>(container, coin_in, ctx));
		} else if(protocol_id == 1) {
			coin_out.join(blue_move_protocol::swap_exact_input<A, SUI>(coin_in, amount_min_out, dex_info, ctx));
		} else {
			let (out, left) = move_pump_protocol::sui_from_coin<A>(
				config, coin_in, amount_min_out, clock, ctx
			);
			coin_in_left.join(left);
			coin_out.join(out);
		};

		coin_out = calc_and_transfer_fees(
			bank, 
			fee_manager, 
			coin_out, 
			users_fee_percent, 
			total_fee_percent, ctx
		);

		slot.add_to_balance<A>(coin_in_left.into_balance<A>());
		slot.add_to_balance<SUI>(coin_out.into_balance<SUI>());
	}

	public entry fun swap_a_to_b<A, B>(
		slot: &mut Slot,
		amount_in: u64,
		amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		protocol_id: u8, // 0 or 1
		ctx: &mut TxContext
	) {
		assert!(!utils::is_sui<A>(), EWrongSwapType);
		assert!(!utils::is_sui<B>(), EWrongSwapType);

		let coin_in = slot.take_from_balance<A>(amount_in, true, ctx);

		let mut coin_out = coin::zero<B>(ctx);

		if(protocol_id == 0) {
			coin_out.join(flow_x_protocol::swap_exact_input<A, B>(container, coin_in, ctx));
		} else {
			coin_out.join(blue_move_protocol::swap_exact_input<A, B>(coin_in, amount_min_out, dex_info, ctx));
		};

		slot.add_to_balance<B>(coin_out.into_balance<B>());
	}

	fun calc_and_transfer_fees(
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
}