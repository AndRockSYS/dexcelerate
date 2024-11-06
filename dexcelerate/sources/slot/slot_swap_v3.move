module dexcelerate::slot_swap_v3 {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin;

	use dexcelerate::utils;
	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};

	use turbos_clmm::pool::{Pool as TPool, Versioned};

	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool as CPool};
	use dexcelerate::cetus_clmm_protocol;

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
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance<SUI>(amount_in, true, ctx);

		coin_in = swap_router::calc_and_transfer_fees(
			bank, fee_manager, coin_in, users_fee_percent, total_fee_percent, ctx
		);

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
		gas_lended: u64,
		gas_sponsor: Option<address>,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (coin_a, mut coin_b) = swap_router::swap_v3_turbos<A, SUI, FeeType>(
			slot.take_from_balance<A>(amount_in, true, ctx), coin::zero<SUI>(ctx),
			pool,
			versioned, clock, ctx
		);

		coin_b = swap_router::calc_and_transfer_fees(
			bank, fee_manager, coin_b, users_fee_percent, total_fee_percent, ctx
		);

		swap_router::check_and_transfer_sponsor_gas(&mut coin_b, gas_lended, gas_sponsor, ctx);

		slot.add_to_balance<A>(coin_a.into_balance<A>());
		slot.add_to_balance<SUI>(coin_b.into_balance<SUI>());
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
		utils::not_base<A>();
		utils::not_base<B>();

		let mut coin_a_in = coin::zero<A>(ctx);
		let mut coin_b_in = coin::zero<B>(ctx);

		if(a_to_b) {
			coin_a_in.join(slot.take_from_balance<A>(amount_in, true, ctx));
		} else {
			coin_b_in.join(slot.take_from_balance<B>(amount_in, true, ctx));
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