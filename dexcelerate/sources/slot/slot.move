module dexcelerate::slot {
	use std::ascii::{String};
	use std::type_name;

	use sui::clock::{Clock};
	use sui::event;
	use sui::bag::{Self, Bag};

	use sui::balance::{Self, Balance};
	use sui::coin::{Self, Coin};

	use dexcelerate::platform::{Self, Platform};

	const ENotASlotOwner: u64 = 0;
	const ESlotHasNoType: u64 = 1;
	const EBalanceIsLow: u64 = 2;

	public struct Slot has key, store {
		id: UID,
		owner: address,
		balances: Bag
	}

	public struct SlotInitialized has copy, drop, store {
		owner: address,
		slot: address,
	}

	public entry fun create(ctx: &mut TxContext) {
		let slot = Slot {
			id: object::new(ctx),
			owner: ctx.sender(),
			balances: bag::new(ctx)
		};

		event::emit(SlotInitialized {
			owner: ctx.sender(),
			slot: object::id_address(&slot),
		});

		transfer::public_share_object(slot);
	}

	public(package) fun add_to_balance<T>(slot: &mut Slot, balance: Balance<T>) {
		let coin_type = type_name::get<T>().into_string();

		if(bag::contains<String>(&slot.balances, coin_type)) {
			let main_balance = bag::borrow_mut<String, Balance<T>>(&mut slot.balances, coin_type);
			balance::join<T>(main_balance, balance);
		} else {
			bag::add<String, Balance<T>>(&mut slot.balances, coin_type, balance);
		};
	}

	public(package) fun take_from_balance_with_sender<T>(
		slot: &mut Slot, 
		amount: u64,
		ctx: &mut TxContext
	): Coin<T> {
		assert!(*&slot.owner == ctx.sender(), ENotASlotOwner);

		take_from_balance(slot, amount, ctx)
	}

	public(package) fun take_from_balance_with_permission<T>(
		slot: &mut Slot, 
		amount: u64,
		platform: &Platform, 
		clock: &Clock,
		ctx: &mut TxContext
	): Coin<T> {
		let has_permission = platform::has_permission(
			platform, slot.owner(), clock, ctx
		);

		if(!has_permission) {
			assert!(*&slot.owner == ctx.sender(), ENotASlotOwner);
		};

		take_from_balance<T>(slot, amount, ctx)
	}

	public(package) fun take_from_balance<T>(
		slot: &mut Slot, 
		amount: u64, 
		ctx: &mut TxContext
	): Coin<T> {
		let coin_type = type_name::get<T>().into_string();
		assert!(bag::contains<String>(&slot.balances, coin_type), ESlotHasNoType);

		let token_balance = bag::borrow_mut<String, Balance<T>>(&mut slot.balances, coin_type);
		assert!(token_balance.value() >= amount, EBalanceIsLow);

		let taken = token_balance.split(amount);
		coin::from_balance<T>(taken, ctx)
	}

	public fun owner(slot: &Slot): address {
		*&slot.owner
	}

	public fun balance<T>(slot: &Slot): u64 {
		let coin_type = type_name::get<T>().into_string();
		let mut value = 0;
		if(bag::contains<String>(&slot.balances, coin_type)) {
			let balance = bag::borrow<String, Balance<T>>(&slot.balances, coin_type);
			value = balance::value(balance);
		};
		value
	}
}