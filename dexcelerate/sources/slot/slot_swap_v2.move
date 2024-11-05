module dexcelerate::slot_swap_v2 {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin;

	use dexcelerate::utils;
	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};

	use flow_x::factory::{Container};
	use blue_move::swap::{Dex_Info};
	use move_pump::move_pump::{Configuration};
	use dexcelerate::swap_router;

	public entry fun buy_with_base<T>(
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

		coin_in = swap_router::calc_and_transfer_fees(
			bank, 
			fee_manager, 
			coin_in, 
			users_fee_percent, 
			total_fee_percent, ctx
		);
		
		let (base_left, coin_out) = swap_router::swap_base_v2<T>(
			coin::zero<T>(ctx), coin_in, amount_min_out,
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance<T>());
		slot.add_to_balance<SUI>(base_left.into_balance<SUI>());
	}

	public entry fun sell_with_base<T>(
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
		gas_lended: u64,
		gas_sponsor: Option<address>,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_in = slot.take_from_balance<T>(amount_in, true, ctx);

		let (mut base_out, coin_in_left) = swap_router::swap_base_v2<T>(
			coin_in, coin::zero<SUI>(ctx), amount_min_out,
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		base_out = swap_router::calc_and_transfer_fees(
			bank, fee_manager, 
			base_out, 
			users_fee_percent, total_fee_percent,
			ctx
		);

		swap_router::check_and_transfer_sponsor_gas(&mut base_out, gas_lended, gas_sponsor, ctx);

		slot.add_to_balance<SUI>(base_out.into_balance<SUI>());
		slot.add_to_balance<T>(coin_in_left.into_balance<T>());
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
		utils::not_base<A>();
		utils::not_base<B>();

		let coin_out = swap_router::swap_v2<A, B>(
			slot.take_from_balance<A>(amount_in, true, ctx), amount_min_out,
			container, dex_info, protocol_id,
			ctx
		);

		slot.add_to_balance<B>(coin_out.into_balance<B>());
	}
}