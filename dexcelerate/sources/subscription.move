module dexcelerate::subscription {
	use std::ascii::{String};

	use sui::event;

	use sui::sui::{SUI};
	use sui::coin::{Coin};

	use dexcelerate::slot::{Self, Slot};
	use dexcelerate::bank::{Self, Bank};
	use dexcelerate::fee::{Self, FeeManager};

	use blue_move::swap::{Dex_Info};
	use dexcelerate::blue_move_protocol;

	public struct CollectorCap has key, store {
		id: UID
	}

	// Events

	public struct CollectorUpdated has copy, drop, store {
		new_collector: address
	}

	public struct Payment has copy, drop, store {
		payment_info: String,
		amount: u64
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
		fee_manager: &mut FeeManager,
		bank: &mut Bank,
		item_info: String,
		payment: Coin<SUI>,
		user_fee_percent: u64,
		ctx: &mut TxContext
	) {
		split_and_pay_with_sui(
			fee_manager,
			bank, 
			item_info,
			payment, 
			user_fee_percent,
			ctx
		);
	}

	public entry fun subscribe<T>(
		fee_manager: &mut FeeManager,
		bank: &mut Bank,
		item_info: String,
		payment: Coin<T>,
		user_fee_percent: u64,
		dex_info: &mut Dex_Info,
		amount_out_min: u64,
		ctx: &mut TxContext
	) {
		let coin_out: Coin<SUI> = blue_move_protocol::swap_a_to_b(
			payment,
			amount_out_min,
			dex_info,
			ctx
		);

		split_and_pay_with_sui(
			fee_manager,
			bank, 
			item_info,
			coin_out, 
			user_fee_percent,
			ctx
		);
	}

	public entry fun collect_sui(
		_: &CollectorCap,
		fee_manager: &mut FeeManager,
		bank: &mut Bank,
		item_info: String,
		user_slot: &mut Slot,
		amount: u64,
		user_fee_percent: u64,
		ctx: &mut TxContext
	) {
		let sui_coin = slot::take_from_balance<SUI>(user_slot, amount, ctx);
		split_and_pay_with_sui(
			fee_manager,
			bank, 
			item_info,
			sui_coin, 
			user_fee_percent,
			ctx
		);
	}

	public entry fun collect<T>(
		_: &CollectorCap,
		fee_manager: &mut FeeManager,
		bank: &mut Bank,
		item_info: String,
		user_slot: &mut Slot,
		amount: u64,
		user_fee_percent: u64,
		dex_info: &mut Dex_Info,
		amount_out_min: u64,
		ctx: &mut TxContext
	) {
		let sui_coin = user_slot.take_from_balance<T>(amount, ctx);
		let coin_out: Coin<SUI> = blue_move_protocol::swap_a_to_b(
			sui_coin,
			amount_out_min,
			dex_info,
			ctx
		);

		split_and_pay_with_sui(
			fee_manager,
			bank, 
			item_info,
			coin_out, 
			user_fee_percent,
			ctx
		);
	}

	fun split_and_pay_with_sui(
		fee_manager: &mut FeeManager,
		bank: &mut Bank,
		item_info: String,
		mut payment: Coin<SUI>,
		user_fee_percent: u64,
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