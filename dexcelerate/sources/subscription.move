module dexcelerate::subscription {
	use std::ascii::{String};

	use sui::clock::{Clock};
	use sui::event;

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};

	use flow_x::factory::{Container};
	use blue_move::swap::{Dex_Info};
	use move_pump::move_pump::{Configuration};
	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool as CPool};
	use turbos_clmm::pool::{Pool as TPool, Versioned as TVersioned};
	use flowx_clmm::pool::{Pool as FPool};
    use flowx_clmm::versioned::{Versioned as FVersioned};

	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Self, Bank};
	use dexcelerate::fee::{Self, FeeManager};

	use dexcelerate::slot_swap_amm;
	use dexcelerate::cetus_clmm_protocol;
	use dexcelerate::turbos_clmm_protocol;
	use dexcelerate::flow_x_clmm_protocol;

	const ECannotUseSlotToSubscribe: u64 = 0;

	public struct CollectorCap has key, store {
		id: UID
	}

	// Events

	public struct Payment has copy, drop, store {
		payment_info: String,
		amount: u64
	}

	public struct CollectorUpdated has copy, drop, store {
		new_collector: address
	}

	fun init(ctx: &mut TxContext) {
		set_collector(CollectorCap {
			id: object::new(ctx)
		}, ctx.sender())
	}

	public entry fun set_collector(
		collector_cap: CollectorCap,
		new_collector: address
	) {
		transfer::public_transfer(collector_cap, new_collector);

		event::emit(CollectorUpdated {
			new_collector
		});
	}

	public entry fun subsribe_sui(
		slot: &mut Slot,
		amount: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		item_info: String,

		ctx: &mut TxContext
	) {
		split_and_pay_with_sui(
			take_from_slot_for_subscription(slot, amount, false, ctx),
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun collect_sui(
		_: &CollectorCap,

		slot: &mut Slot,
		amount: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		item_info: String,

		ctx: &mut TxContext
	) {
		split_and_pay_with_sui(
			take_from_slot_for_subscription(slot, amount, true, ctx),
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun subscribe_amm<T>(
		slot: &mut Slot,
		amount_in: u64,
		amount_out_min: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2

		item_info: String,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (base_out, coin_out) = slot_swap_amm::swap_base_amm_no_fees<T>(
			coin::zero<SUI>(ctx), take_from_slot_for_subscription(slot, amount_in, false, ctx),
			amount_out_min,
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance());

		split_and_pay_with_sui(
			base_out, 
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun collect_amm<T>(
		_: &CollectorCap,

		slot: &mut Slot,
		amount_in: u64,
		amount_out_min: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2

		item_info: String,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (base_out, coin_out) = slot_swap_amm::swap_base_amm_no_fees<T>(
			coin::zero<SUI>(ctx), take_from_slot_for_subscription(slot, amount_in, true, ctx),
			amount_out_min,
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance());

		split_and_pay_with_sui(
			base_out, 
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun subscribe_cetus<T>(
		slot: &mut Slot,
		amount_in: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		pool: &mut CPool<T, SUI>,
		config: &GlobalConfig,

		item_info: String,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (coin_out, base_out) = cetus_clmm_protocol::swap<T, SUI>(
			pool, 
			take_from_slot_for_subscription(slot, amount_in, false, ctx), coin::zero<SUI>(ctx), 
			config, clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance());

		split_and_pay_with_sui(
			base_out, 
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun collect_cetus<T>(
		_: &CollectorCap,

		slot: &mut Slot,
		amount_in: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		pool: &mut CPool<T, SUI>,
		config: &GlobalConfig,

		item_info: String,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (coin_out, base_out) = cetus_clmm_protocol::swap<T, SUI>(
			pool, 
			take_from_slot_for_subscription(slot, amount_in, true, ctx), coin::zero<SUI>(ctx), 
			config, clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance());

		split_and_pay_with_sui(
			base_out, 
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun subscribe_turbos<T, FeeType>(
		slot: &mut Slot,
		amount_in: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		pool: &mut TPool<T, SUI, FeeType>,
		versioned: &TVersioned,

		item_info: String,

		clock: &Clock,
		ctx: &mut TxContext
	) {

		let (coin_out, base_out) = turbos_clmm_protocol::swap<T, SUI, FeeType>(
			pool, 
			take_from_slot_for_subscription(slot, amount_in, false, ctx), coin::zero<SUI>(ctx),
			versioned, clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance());

		split_and_pay_with_sui(
			base_out, 
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun collect_turbos<T, FeeType>(
		_: &CollectorCap,

		slot: &mut Slot,
		amount_in: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		pool: &mut TPool<T, SUI, FeeType>,
		versioned: &TVersioned,

		item_info: String,

		clock: &Clock,
		ctx: &mut TxContext
	) {

		let (coin_out, base_out) = turbos_clmm_protocol::swap<T, SUI, FeeType>(
			pool, 
			take_from_slot_for_subscription(slot, amount_in, true, ctx), coin::zero<SUI>(ctx),
			versioned, clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance());

		split_and_pay_with_sui(
			base_out, 
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun subscribe_flow_x_clmm<T>(
		slot: &mut Slot,
		amount_in: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		pool: &mut FPool<T, SUI>,
		versioned: &mut FVersioned,

		item_info: String,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (coin_out, base_out) = flow_x_clmm_protocol::swap<T, SUI>(
			pool,
			take_from_slot_for_subscription(slot, amount_in, false, ctx), coin::zero<SUI>(ctx),
			versioned, clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance());

		split_and_pay_with_sui(
			base_out, 
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	public entry fun collect_flow_x_clmm<T>(
		_: &CollectorCap,

		slot: &mut Slot,
		amount_in: u64,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		pool: &mut FPool<T, SUI>,
		versioned: &mut FVersioned,

		item_info: String,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		let (coin_out, base_out) = flow_x_clmm_protocol::swap<T, SUI>(
			pool,
			take_from_slot_for_subscription(slot, amount_in, true, ctx), coin::zero<SUI>(ctx),
			versioned, clock, ctx
		);

		slot.add_to_balance<T>(coin_out.into_balance());

		split_and_pay_with_sui(
			base_out, 
			bank, fee_manager, user_fee_percent,
			item_info, ctx
		);
	}

	fun take_from_slot_for_subscription<T>(
		slot: &mut Slot,
		amount: u64,
		is_collector: bool,
		ctx: &mut TxContext
	): Coin<T> {
		if(is_collector && ctx.sender() != slot.owner()) {
			abort(ECannotUseSlotToSubscribe)
		};

		slot.take_from_balance<T>(amount, ctx)
	}

	fun split_and_pay_with_sui(
		mut payment: Coin<SUI>,

		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		user_fee_percent: u64,

		item_info: String,
		
		ctx: &mut TxContext
	) {
		let user_fee = ((payment.value() as u128) * (user_fee_percent as u128) / 100_000) as u64;
		let dex_fee = payment.value() - user_fee;

		bank::add_to_bank(bank, payment.split(user_fee, ctx), ctx);
		fee::add_fee(fee_manager, payment);

		event::emit(Payment {
			payment_info: item_info,
			amount: dex_fee + user_fee
		});
	}
}