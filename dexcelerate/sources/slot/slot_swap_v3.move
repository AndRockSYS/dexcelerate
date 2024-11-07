module dexcelerate::slot_swap_v3 {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin;

	use dexcelerate::utils;
	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};
	use dexcelerate::platform_permission::{Self, Platform};

	use turbos_clmm::pool::{Pool as TPool, Versioned};
	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool as CPool};

	use dexcelerate::swap_router;

	// Turbos CLMM

	public entry fun buy_with_base_turbos<A, FeeType>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,
		slot: &mut Slot,
		amount_in: u64,
		pool: &mut TPool<A, SUI, FeeType>,
		versioned: &Versioned,
		gas: u64, // put 0 if user does it on his own
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance_with_permission<SUI>(amount_in, platform, clock, ctx);

		coin_in = swap_router::take_fee(
			bank, fee_manager, coin_in, users_fee_percent, total_fee_percent, ctx
		);

		swap_router::return_sponsor_gas_sui(&mut coin_in, gas, platform_permission::get_address(platform), ctx);

		let (coin_a, coin_b) = swap_router::swap_v3_turbos<A, SUI, FeeType>(
			coin::zero<A>(ctx), coin_in,
			pool,
			versioned, clock, ctx
		);

		slot.add_to_balance<A>(coin_a.into_balance<A>());
		slot.add_to_balance<SUI>(coin_b.into_balance<SUI>());
	}

	public entry fun sell_with_base_turbos<A, FeeType>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,
		slot: &mut Slot,
		amount_in: u64,
		pool: &mut TPool<A, SUI, FeeType>,
		versioned: &Versioned,
		gas: u64, // put 0 if user does it on his own
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (coin_a, mut coin_b) = swap_router::swap_v3_turbos<A, SUI, FeeType>(
			slot.take_from_balance_with_permission<A>(amount_in, platform, clock, ctx), coin::zero<SUI>(ctx),
			pool,
			versioned, clock, ctx
		);

		coin_b = swap_router::take_fee(
			bank, fee_manager, coin_b, users_fee_percent, total_fee_percent, ctx
		);

		swap_router::return_sponsor_gas_sui(&mut coin_b, gas, platform_permission::get_address(platform), ctx);

		slot.add_to_balance<A>(coin_a.into_balance<A>());
		slot.add_to_balance<SUI>(coin_b.into_balance<SUI>());
	}

	public entry fun swap_turbos<A, B, FeeType>(
		slot: &mut Slot,
		amount_in: u64,
		a_to_b: bool,
		pool: &mut TPool<A, B, FeeType>,
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
			coin_a_in.join(slot.take_from_balance_with_permission<A>(amount_in, platform, clock, ctx));
		} else {
			coin_b_in.join(slot.take_from_balance_with_permission<B>(amount_in, platform, clock, ctx));
		};

		let (coin_a, coin_b) = swap_router::swap_v3_turbos<A, B, FeeType>(
			coin_a_in, coin_b_in,
			pool,
			versioned, clock, ctx
		);

		slot.add_to_balance<A>(coin_a.into_balance<A>());
		slot.add_to_balance<B>(coin_b.into_balance<B>());
	}

	// Cetus CLMM

	public entry fun buy_with_base_cetus<A>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,
		slot: &mut Slot,
		amount_in: u64,
		config: &GlobalConfig,
		pool: &mut CPool<A, SUI>,
		gas: u64, // put 0 if user does it on his own
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance_with_permission<SUI>(amount_in, platform, clock, ctx);

		coin_in = swap_router::take_fee(
			bank, fee_manager, coin_in, users_fee_percent, total_fee_percent, ctx
		);

		swap_router::return_sponsor_gas_sui(&mut coin_in, gas, platform_permission::get_address(platform), ctx);

		let (coin_a, coin_b) = swap_router::swap_v3_cetus<A, SUI>(
			coin::zero<A>(ctx), coin_in, config, pool, clock, ctx
		);

		slot.add_to_balance<SUI>(coin_b.into_balance<SUI>());
		slot.add_to_balance<A>(coin_a.into_balance<A>());
	}

	public entry fun sell_with_base_cetus<A>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,
		slot: &mut Slot,
		amount_in: u64,
		config: &GlobalConfig,
		pool: &mut CPool<A, SUI>,
		gas: u64, // put 0 if user does it on his own
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_in = slot.take_from_balance_with_permission<A>(amount_in, platform, clock, ctx);

		let (coin_a, mut coin_b) = swap_router::swap_v3_cetus<A, SUI>(
			coin_in, coin::zero<SUI>(ctx), config, pool, clock, ctx
		);

		coin_b = swap_router::take_fee(
			bank, fee_manager, coin_b, users_fee_percent, total_fee_percent, ctx
		);

		swap_router::return_sponsor_gas_sui(&mut coin_b, gas, platform_permission::get_address(platform), ctx);

		slot.add_to_balance<SUI>(coin_b.into_balance<SUI>());
		slot.add_to_balance<A>(coin_a.into_balance<A>());
	}

	public entry fun swap_cetus<A, B> (
		slot: &mut Slot,
		amount_in: u64,
		a_to_b: bool,
		config: &GlobalConfig,
		pool: &mut CPool<A, B>,
		sui_pool: &mut CPool<A, SUI>,
		gas: u64, // put 0 if user does it on his own
		platform: &Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (coin_a, coin_b) = 
			if(a_to_b) { 
				let mut coin_in = slot.take_from_balance_with_permission<A>(amount_in, platform, clock, ctx);

				swap_router::return_sponsor_gas_coin_cetus<A>(
					&mut coin_in, 
					config, sui_pool,
					gas, platform_permission::get_address(platform),
					clock, ctx
				);

				swap_router::swap_v3_cetus<A, B>(
					coin_in, coin::zero<B>(ctx),
					config, pool, clock, ctx
				)
			} else {
				let (mut coin_a_out, coin_b_out) = swap_router::swap_v3_cetus<A, B>(
					coin::zero<A>(ctx), slot.take_from_balance_with_permission<B>(amount_in, platform, clock, ctx),
					config, pool, clock, ctx
				);

				swap_router::return_sponsor_gas_coin_cetus<A>(
					&mut coin_a_out, 
					config, sui_pool,
					gas, platform_permission::get_address(platform),
					clock, ctx
				);

				(coin_a_out, coin_b_out)
			};

		slot.add_to_balance<A>(coin_a.into_balance<A>());
		slot.add_to_balance<B>(coin_b.into_balance<B>());
	}
}