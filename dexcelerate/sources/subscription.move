/*
	Remove withdraw at all, 
	because all the coins are splitted into fee and bank modules, 
	so they can be withdrawn from over there
*/

module dexcelerate::subscription {
	use std::ascii::{String};

	use sui::event;
	use sui::bag::{Self, Bag};

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};

	use dexcelerate::slot::{Self, Slot};
	use dexcelerate::bank::{Self, Bank};
	use dexcelerate::fee::{Self, FeeManager};

	use blue_move::swap::{Dex_Info};
	use dexcelerate::blue_move_protocol;

	const ENotASubscriber: u64 = 0;

	public struct CollectorCap has key, store {
		id: UID
	}
	
	public struct Subscription has key, store {
		id: UID,
		subscribers: Bag,
	}

	// Events

	public struct CollectorUpdated has copy, drop, store {
		new_collector: address
	}

	public struct UserFeePayed has copy, drop, store {
		amount: u64
	}

	public struct BankFeePayed has copy, drop, store {
		amount: u64
	}

	public struct Payment has copy, drop, store {
		payment_info: String,
		amount: u64
	}

	fun init(ctx: &mut TxContext) {
		transfer::public_share_object(Subscription {
			id: object::new(ctx),
			subscribers: bag::new(ctx)
		});

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
		subscription: &mut Subscription,
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

		bag::add<address, bool>(&mut subscription.subscribers, ctx.sender(), true);
	}

	public entry fun subscribe<T>(
		subscription: &mut Subscription,
		fee_manager: &mut FeeManager,
		bank: &mut Bank,
		item_info: String,
		payment: Coin<T>,
		user_fee_percent: u64,
		dex_info: &mut Dex_Info,
		amount_out_min: u64,
		ctx: &mut TxContext
	) {
		let coin_out: Coin<SUI> = blue_move_protocol::swap_exact_input_coin(
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

		bag::add<address, bool>(&mut subscription.subscribers, ctx.sender(), true);
	}

	public entry fun unsubscribe(
		subscription: &mut Subscription,
		ctx: &mut TxContext
	) {
		assert!(bag::contains<address>(&subscription.subscribers, ctx.sender()), ENotASubscriber);
		bag::remove<address, bool>(&mut subscription.subscribers, ctx.sender());
	}

	public entry fun collect_sui(
		_: &CollectorCap,
		subscription: &mut Subscription,
		fee_manager: &mut FeeManager,
		bank: &mut Bank,
		item_info: String,
		user_slot: &mut Slot,
		amount: u64,
		user_fee_percent: u64,
		ctx: &mut TxContext
	) {
		assert!(bag::contains<address>(&subscription.subscribers, slot::get_owner(user_slot)), ENotASubscriber);

		let balance_amount = slot::balance<SUI>(user_slot);
		if(balance_amount < amount) {
			bag::remove<address, bool>(&mut subscription.subscribers, slot::get_owner(user_slot));
			return
		};

		let sui_balance = slot::take_from_balance<SUI>(user_slot, amount, false, ctx);
		split_and_pay_with_sui(
			fee_manager,
			bank, 
			item_info,
			coin::from_balance<SUI>(sui_balance, ctx), 
			user_fee_percent,
			ctx
		);
	}

	public entry fun collect<T>(
		_: &CollectorCap,
		subscription: &mut Subscription,
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
		assert!(bag::contains<address>(&subscription.subscribers, slot::get_owner(user_slot)), ENotASubscriber);

		let balance_amount = slot::balance<T>(user_slot);
		if(balance_amount < amount) {
			bag::remove<address, bool>(&mut subscription.subscribers, slot::get_owner(user_slot));
			return
		};

		let balance = slot::take_from_balance<T>(user_slot, amount, false, ctx);
		let coin_out: Coin<SUI> = blue_move_protocol::swap_exact_input_coin(
			coin::from_balance<T>(balance, ctx),
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

		event::emit(UserFeePayed {amount: user_fee});
		event::emit(BankFeePayed {amount: dex_fee});
		event::emit(Payment {
			payment_info: item_info,
			amount: dex_fee + user_fee
		});
	}
}