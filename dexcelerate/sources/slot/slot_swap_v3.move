module dexcelerate::slot_swap_v3 {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin;

	use dexcelerate::utils;
	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};

	use turbos_clmm::pool::{Pool as TPool, Versioned};
	use dexcelerate::turbos_clmm_protocol;

	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool as CPool};
	use dexcelerate::cetus_clmm_protocol;

	use dexcelerate::swap_router;

	const EWrongSwapType: u64 = 0;

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
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance<SUI>(amount_in, true, ctx);

		coin_in = swap_router::calc_and_transfer_fees(
			bank, fee_manager, coin_in, users_fee_percent, total_fee_percent, ctx
		);

		let (coin_out, coin_in_left) = turbos_clmm_protocol::swap_b_to_a<A, SUI, FeeType>(
			pool, coin_in, clock, versioned, ctx
		);

		slot.add_to_balance<SUI>(coin_in_left.into_balance<SUI>());
		slot.add_to_balance<A>(coin_out.into_balance<A>());
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
		gas_lended: u64,
		gas_sponsor: Option<address>,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_in = slot.take_from_balance<A>(amount_in, true, ctx);

		let (mut coin_out, coin_in_left) = turbos_clmm_protocol::swap_a_to_b<A, SUI, FeeType>(
			pool, coin_in, clock, versioned, ctx
		);

		coin_out = swap_router::calc_and_transfer_fees(
			bank, fee_manager, coin_out, users_fee_percent, total_fee_percent, ctx
		);

		swap_router::check_and_transfer_sponsor_gas(&mut coin_out, gas_lended, gas_sponsor, ctx);

		slot.add_to_balance<A>(coin_in_left.into_balance<A>());
		slot.add_to_balance<SUI>(coin_out.into_balance<SUI>());
	}

	public entry fun swap_turbos<A, B, FeeType>(
		slot: &mut Slot,
		amount_in: u64,
		a_to_b: bool,
		pool: &mut TPool<A, B, FeeType>,
		versioned: &Versioned,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		assert!(!utils::is_base<A>(), EWrongSwapType);
		assert!(!utils::is_base<B>(), EWrongSwapType);

		if(a_to_b) {
			let (coin_out, coin_in_left) = turbos_clmm_protocol::swap_a_to_b<A, B, FeeType>(
				pool, 
				slot.take_from_balance<A>(amount_in, true, ctx), 
				clock, versioned, ctx
			);
			slot.add_to_balance<A>(coin_in_left.into_balance<A>());
			slot.add_to_balance<B>(coin_out.into_balance<B>());
		} else {
			let (coin_out, coin_in_left) = turbos_clmm_protocol::swap_b_to_a<A, B, FeeType>(
				pool, 
				slot.take_from_balance<B>(amount_in, true, ctx), 
				clock, versioned, ctx
			);
			slot.add_to_balance<B>(coin_in_left.into_balance<B>());
			slot.add_to_balance<A>(coin_out.into_balance<A>());
		};
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
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance<SUI>(amount_in, true, ctx);

		coin_in = swap_router::calc_and_transfer_fees(
			bank, fee_manager, coin_in, users_fee_percent, total_fee_percent, ctx
		);

		let (coin_out, coin_in_left) = cetus_clmm_protocol::swap_b_to_a<A, SUI>(
			config, pool, coin_in, clock, ctx
		);

		slot.add_to_balance<SUI>(coin_in_left.into_balance<SUI>());
		slot.add_to_balance<A>(coin_out.into_balance<A>());
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
		gas_lended: u64,
		gas_sponsor: Option<address>,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_in = slot.take_from_balance<A>(amount_in, true, ctx);

		let (coin_in_left, mut coin_out) = cetus_clmm_protocol::swap_a_to_b<A, SUI>(
			config, pool, coin_in, clock, ctx
		);

		coin_out = swap_router::calc_and_transfer_fees(
			bank, fee_manager, coin_out, users_fee_percent, total_fee_percent, ctx
		);

		swap_router::check_and_transfer_sponsor_gas(&mut coin_out, gas_lended, gas_sponsor, ctx);

		slot.add_to_balance<SUI>(coin_out.into_balance<SUI>());
		slot.add_to_balance<A>(coin_in_left.into_balance<A>());
	}

	public entry fun swap_cetus<A, B> (
		slot: &mut Slot,
		amount_in: u64,
		a_to_b: bool,
		config: &GlobalConfig,
		pool: &mut CPool<A, B>,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_a = coin::zero<A>(ctx);
		let mut coin_b = coin::zero<B>(ctx);

		if(a_to_b) {
			let (coin_a_out, coin_b_out) = cetus_clmm_protocol::swap_a_to_b<A, B>(
				config, pool, 
				slot.take_from_balance<A>(amount_in, true, ctx), 
				clock, ctx
			);
			coin_a.join(coin_a_out);
			coin_b.join(coin_b_out);
		} else {
			let (coin_a_out, coin_b_out) = cetus_clmm_protocol::swap_b_to_a<A, B>(
				config, pool, 
				slot.take_from_balance<B>(amount_in, true, ctx), 
				clock, ctx
			);
			coin_a.join(coin_a_out);
			coin_b.join(coin_b_out);
		};	

		slot.add_to_balance<A>(coin_a.into_balance<A>());
		slot.add_to_balance<B>(coin_b.into_balance<B>());
	}
}