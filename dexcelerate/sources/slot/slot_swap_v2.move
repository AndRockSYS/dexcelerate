module dexcelerate::slot_swap_v2 {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin;

	use dexcelerate::utils;
	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};
	use dexcelerate::platform_permission::{Self, Platform};

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
		mut amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2
		gas: u64, // put 0 if user does it on his own
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance_with_permission<SUI>(amount_in, platform, clock, ctx);

		coin_in = swap_router::take_fee(
			bank, 
			fee_manager, 
			coin_in, 
			users_fee_percent, 
			total_fee_percent, ctx
		);

		swap_router::return_sponsor_gas_sui(&mut coin_in, gas, platform_permission::get_address(platform), ctx);

		amount_min_out = if (gas > 0) {
			amount_min_out / 2
		} else {
			amount_min_out
		};
		
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
		gas: u64, // put 0 if user does it on his own
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_in = slot.take_from_balance_with_permission<T>(amount_in, platform, clock, ctx);

		let (mut base_out, coin_in_left) = swap_router::swap_base_v2<T>(
			coin_in, coin::zero<SUI>(ctx), amount_min_out,
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		base_out = swap_router::take_fee(
			bank, fee_manager, 
			base_out, 
			users_fee_percent, total_fee_percent,
			ctx
		);

		swap_router::return_sponsor_gas_sui(&mut base_out, gas, platform_permission::get_address(platform), ctx);

		slot.add_to_balance<SUI>(base_out.into_balance<SUI>());
		slot.add_to_balance<T>(coin_in_left.into_balance<T>());
	}

	// ! if sponsored or executed by the platform and coin a has no pool with SUI will revert
	public entry fun swap_a_to_b<A, B>(
		slot: &mut Slot,
		amount_in: u64,
		mut amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		protocol_id: u8, // 0 or 1
		gas: u64, // put 0 if user does it on his own
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<A>();
		utils::not_base<B>();

		let mut coin_in = slot.take_from_balance_with_permission<A>(amount_in, platform, clock, ctx);

		swap_router::return_sponsor_gas_coin_v2<A>(
			&mut coin_in,
			container, dex_info, protocol_id,
			gas, platform_permission::get_address(platform),
			ctx
		);

		amount_min_out = if(gas > 0) {
			amount_min_out / 2
		} else {
			amount_min_out
		};

		let coin_out = swap_router::swap_v2<A, B>(
			coin_in, amount_min_out,
			container, dex_info, protocol_id,
			ctx
		);

		slot.add_to_balance<B>(coin_out.into_balance<B>());
	}
}