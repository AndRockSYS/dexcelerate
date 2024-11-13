module dexcelerate::slot_swap_amm {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};

	use dexcelerate::flow_x_amm_protocol;
	use flow_x::factory::{Container};
	use dexcelerate::blue_move_protocol;
	use blue_move::swap::{Dex_Info};
	use dexcelerate::move_pump_protocol;
	use move_pump::move_pump::{Configuration};

	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};
	use dexcelerate::platform_permission::{Self, Platform};

	use dexcelerate::utils;
	use dexcelerate::swap_utils;
	
	public entry fun swap_with_base<T>(
		slot: &mut Slot,
		amount_in: u64,
		amount_min_out: u64,
		is_base_in: bool,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,

		gas: u64, // put 0 if platform doesn't sponsor

		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2

		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut base_in = coin::zero<SUI>(ctx);
		let mut coin_in = coin::zero<T>(ctx);

		if(is_base_in) {
			base_in.join(
				slot.take_from_balance_with_permission<SUI>(amount_in, platform, clock, ctx)
			);
		} else {
			coin_in.join(
				slot.take_from_balance_with_permission<T>(amount_in, platform, clock, ctx)
			);
		};

		if(is_base_in) {
			swap_utils::take_fee(
				bank, fee_manager, &mut base_in, 
				users_fee_percent, total_fee_percent, ctx
			);

			swap_utils::repay_sponsor_gas<SUI>(
				&mut base_in, gas, platform_permission::get_address(platform), ctx
			);

			// todo change amount_out on fees applying
		};

		let (mut base_out, coin_out) = swap_base_amm_no_fees<T>(
			base_in, coin_in, amount_min_out,
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		if(!is_base_in) {
			swap_utils::take_fee(
				bank, fee_manager, &mut base_out, 
				users_fee_percent, total_fee_percent, ctx
			);

			swap_utils::repay_sponsor_gas<SUI>(
				&mut base_out, gas, platform_permission::get_address(platform), ctx
			);
		};

		slot.add_to_balance<T>(coin_out.into_balance<T>());
		slot.add_to_balance<SUI>(base_out.into_balance<SUI>());
	}

	public entry fun swap_a_to_b<A, B>(
		slot: &mut Slot,
		amount_in: u64,
		amount_min_out: u64,

		gas: u64, // put 0 if platform doesn't sponsor

		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		protocol_id: u8, // 0 or 1

		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<A>();
		utils::not_base<B>();

		let coin_in = slot.take_from_balance_with_permission<A>(amount_in, platform, clock, ctx);

		let mut coin_out = swap_coin_amm<A, B>(
			coin_in, amount_min_out,
			container, dex_info, protocol_id, ctx
		);

		swap_utils::repay_sponsor_gas_v2<B>(
			&mut coin_out, 
			container, dex_info, protocol_id,
			gas, platform_permission::get_address(platform), ctx
		);

		slot.add_to_balance<B>(coin_out.into_balance<B>());
	}

	public(package) fun swap_base_amm_no_fees<T>(
		base_in: Coin<SUI>,
		coin_in: Coin<T>,
		amount_min_out: u64,

		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2

		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<SUI>, Coin<T>) {
		utils::check_amounts<SUI, T>(&base_in, &coin_in);

		let mut base_out = coin::zero<SUI>(ctx);
		let mut coin_out = coin::zero<T>(ctx);

		if(base_in.value() > 0) {
			if(protocol_id == 2) {
				let (base, coin) = move_pump_protocol::swap<T>(
					coin::zero<T>(ctx), base_in, amount_min_out,
					config, dex_info, clock, ctx
				);
				base_out.join(base);
				coin_out.join(coin);
			} else {
				let coin = swap_coin_amm<SUI, T>(
					base_in, amount_min_out,
					container, dex_info, protocol_id,
					ctx
				);
				coin_out.join(coin);
			};

			coin_in.destroy_zero();
		} else {
			if(protocol_id == 2) {
				let (base, coin) = move_pump_protocol::swap<T>(
					coin_in, coin::zero<SUI>(ctx), amount_min_out,
					config, dex_info, clock, ctx
				);
				base_out.join(base);
				coin_out.join(coin);
			} else {
				let base = swap_coin_amm<T, SUI>(
					coin_in, amount_min_out,
					container, dex_info, protocol_id,
					ctx
				);
				base_out.join(base);
			};

			base_in.destroy_zero();
		};

		(base_out, coin_out)
	}

	fun swap_coin_amm<A, B>(
		coin_in: Coin<A>,
		amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		protocol_id: u8, // 0 or 1
		ctx: &mut TxContext
	): Coin<B> {
		if(protocol_id == 0) {
			flow_x_amm_protocol::swap_a_to_b<A, B>(
				coin_in, container, ctx
			)
		} else {
			blue_move_protocol::swap_a_to_b<A, B>(
				coin_in, amount_min_out, dex_info, ctx
			)
		}
	}
}