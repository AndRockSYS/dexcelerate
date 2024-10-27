module dexcelerate::slot_swap_v3 {
	use sui::clock::{Clock};

	use sui::sui::{SUI};

	use dexcelerate::utils;
	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};
	use dexcelerate::slot_swap_v2;

	use turbos_clmm::pool::{Pool, Versioned};
	use dexcelerate::turbos_clmm_protocol;

	const EWrongSwapType: u64 = 0;

	// Turbos CLMM

	public entry fun sell_with_base_turbos<A, FeeType>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,
		slot: &mut Slot,
		amount_in: u64,
		amount_out_min: u64,
		pool: &mut Pool<A, SUI, FeeType>,
		versioned: &Versioned,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_in = slot.take_from_balance<A>(amount_in, true, ctx);

		let (mut coin_out, coin_in_left) = turbos_clmm_protocol::swap_a_to_b<A, SUI, FeeType>(
			pool, coin_in, amount_out_min, clock, versioned, ctx
		);

		coin_out = slot_swap_v2::calc_and_transfer_fees(
			bank, fee_manager, coin_out, users_fee_percent, total_fee_percent, ctx
		);

		slot.add_to_balance<A>(coin_in_left.into_balance<A>());
		slot.add_to_balance<SUI>(coin_out.into_balance<SUI>());
	}

	public entry fun buy_with_base_turbos<A, FeeType>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		users_fee_percent: u64,
		total_fee_percent: u64,
		slot: &mut Slot,
		amount_in: u64,
		amount_out_min: u64,
		pool: &mut Pool<A, SUI, FeeType>,
		versioned: &Versioned,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance<SUI>(amount_in, true, ctx);

		coin_in = slot_swap_v2::calc_and_transfer_fees(
			bank, fee_manager, coin_in, users_fee_percent, total_fee_percent, ctx
		);

		let (coin_out, coin_in_left) = turbos_clmm_protocol::swap_b_to_a<A, SUI, FeeType>(
			pool, coin_in, amount_out_min, clock, versioned, ctx
		);

		slot.add_to_balance<SUI>(coin_in_left.into_balance<SUI>());
		slot.add_to_balance<A>(coin_out.into_balance<A>());
	}

	public entry fun swap_turbos<A, B, FeeType>(
		slot: &mut Slot,
		amount_in: u64,
		amount_out_min: u64,
		a_to_b: bool,
		pool: &mut Pool<A, B, FeeType>,
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
				amount_out_min, clock, versioned, ctx
			);
			slot.add_to_balance<A>(coin_in_left.into_balance<A>());
			slot.add_to_balance<B>(coin_out.into_balance<B>());
		} else {
			let (coin_out, coin_in_left) = turbos_clmm_protocol::swap_b_to_a<A, B, FeeType>(
				pool, 
				slot.take_from_balance<B>(amount_in, true, ctx), 
				amount_out_min, clock, versioned, ctx
			);
			slot.add_to_balance<B>(coin_in_left.into_balance<B>());
			slot.add_to_balance<A>(coin_out.into_balance<A>());
		};
	}

	// Cetus CLMM
}