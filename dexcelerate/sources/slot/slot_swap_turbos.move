module dexcelerate::slot_swap_turbos {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin;

	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};
	use dexcelerate::platform::{Self, Platform};

	use turbos_clmm::pool::{Pool, Versioned};
	use dexcelerate::turbos_clmm_protocol;

	use dexcelerate::swap_utils;
	use dexcelerate::utils;

	public entry fun swap_with_base<T, FeeType>(
		slot: &mut Slot,
		amount_in: u64,
		is_base_in: bool,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,

		gas: u64, // put 0 if platform doesn't sponsor

		pool: &mut Pool<T, SUI, FeeType>,
		versioned: &Versioned,
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
				bank, fee_manager, &mut base_in, users_fee_percent, total_fee_percent, ctx
			);

			swap_utils::repay_sponsor_gas<SUI>(
				&mut base_in, gas, platform::get_address(platform), ctx
			);
		};

		let (coin_a_out, mut base_out) = turbos_clmm_protocol::swap<T, SUI, FeeType>(
			pool, coin_in, base_in, versioned, clock, ctx
		);
		
		if(!is_base_in) {
			swap_utils::take_fee(
				bank, fee_manager, &mut base_out, users_fee_percent, total_fee_percent, ctx
			);

			swap_utils::repay_sponsor_gas<SUI>(
				&mut base_out, gas, platform::get_address(platform), ctx
			);
		};

		slot.add_to_balance<T>(coin_a_out.into_balance<T>());
		slot.add_to_balance<SUI>(base_out.into_balance<SUI>());
	}

	public entry fun swap_turbos<A, B, FeeType>(
		slot: &mut Slot,
		amount_in: u64,
		a_to_b: bool,

		gas: u64, // put 0 if platform doesn't sponsor

		pool: &mut Pool<A, B, FeeType>,
		versioned: &Versioned,
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
	utils::not_base<A>();
		utils::not_base<B>();

		let mut coin_a_in = coin::zero<A>(ctx);
		let mut coin_b_in = coin::zero<B>(ctx);

		if(a_to_b) {
			coin_a_in.join(
				slot.take_from_balance_with_permission<A>(amount_in, platform, clock, ctx)
			);
		} else {
			coin_b_in.join(
				slot.take_from_balance_with_permission<B>(amount_in, platform, clock, ctx)
			);
		};

		let(coin_a, coin_b) = turbos_clmm_protocol::swap<A, B, FeeType>(
			pool, coin_a_in, coin_b_in,
			versioned, clock, ctx
		);

		if(gas > 0) {
			let gas_coin = slot.take_from_balance_with_permission<SUI>(gas, platform, clock, ctx);
			transfer::public_transfer(gas_coin, platform::get_address(platform));
		};

		slot.add_to_balance<A>(coin_a.into_balance<A>());
		slot.add_to_balance<B>(coin_b.into_balance<B>());
	}
}