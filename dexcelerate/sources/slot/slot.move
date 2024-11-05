module dexcelerate::slot {
	use std::ascii::{String};
	use std::type_name;

	use sui::clock::{Clock};
	use sui::event;

	use sui::balance::{Self, Balance};
	use sui::coin::{Self, Coin};
	use sui::sui::{SUI};

	use sui::bag::{Self, Bag};

	use flow_x::factory::{Container};
	use blue_move::swap::{Dex_Info};
	use move_pump::move_pump::{Configuration};
	use dexcelerate::swap_router;

	const ENotASlotOwner: u64 = 0;
	const ESlotHasNoType: u64 = 1;
	const EBalanceIsLow: u64 = 2;

	public struct Slot has key, store {
		id: UID,
		owner: address,
		balances: Bag
	}

	// Events

	public struct SlotCreated has copy, drop, store {
		slot: address,
		owner: address
	}

	public struct Deposit has copy, drop, store {
		slot: address,
		token: String,
		amount: u64
	}

	public struct Withdraw has copy, drop, store {
		slot: address,
		token: String,
		amount: u64
	}

	public entry fun create(ctx: &mut TxContext) {
		let slot = Slot {
			id: object::new(ctx),
			owner: ctx.sender(),
			balances: bag::new(ctx)
		};

		event::emit(SlotCreated {
			slot: object::id_address(&slot),
			owner: ctx.sender()
		});

		transfer::public_share_object(slot);
	}

	public entry fun deposit_v2<T>(
		slot: &mut Slot, 
		coin_in: Coin<T>, 
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let amount = coin_in.value();
		let token_type = type_name::get<T>().into_string();

		if(token_type == type_name::get<SUI>().into_string()) {
			add_to_balance<T>(slot, coin_in.into_balance<T>());
		} else {
			let (coin_out, coin_in_left) = swap_router::to_base_v2<T>(
				coin_in,
				container, dex_info, config, protocol_id,
				clock, ctx
			);
			add_to_balance<SUI>(slot, coin_out.into_balance<SUI>());	
			transfer::public_transfer(coin_in_left, ctx.sender());
		};
	
		event::emit(Deposit {		
			slot: object::id_address(slot),
			token: token_type,
			amount
		});
	}

	public entry fun withdraw_v2<T>(
		slot: &mut Slot, 
		amount: u64, 
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_in = take_from_balance<T>(slot, amount, true, ctx);

		let token_type = type_name::get<T>().into_string();

		if(token_type == type_name::get<SUI>().into_string()) {
			transfer::public_transfer(coin_in, ctx.sender());
		} else {
			let (coin_out, coin_in_left) = swap_router::to_base_v2<T>(
				coin_in,
				container, dex_info, config, protocol_id,
				clock, ctx
			);
			add_to_balance<T>(slot, coin_in_left.into_balance<T>());	
			transfer::public_transfer(coin_out, ctx.sender());
		};

		event::emit(Withdraw {		
			slot: object::id_address(slot),
			token: token_type,
			amount
		});
	}

	// public entry fun deposit_v3_turbos() {
	// 	if sui deposit
	// 	if another token - swap a to b
	// }

	// public entry fun withdraw_v3_turbos() {
	// 	if sui deposit
	// 	if another token - swap a to b
	// }

	// public entry fun deposit_v3_cetus() {
	// 	if sui deposit
	// 	if another token - swap a to b
	// }

	// public entry fun withdraw_v3_cetus() {
	// 	if sui deposit
	// 	if another token - swap a to b		
	// }

	public(package) fun add_to_balance<T>(slot: &mut Slot, balance: Balance<T>) {
		let coin_type = type_name::get<T>().into_string();

		if(bag::contains<String>(&slot.balances, coin_type)) {
			let main_balance = bag::borrow_mut<String, Balance<T>>(&mut slot.balances, coin_type);
			balance::join<T>(main_balance, balance);
		} else {
			bag::add<String, Balance<T>>(&mut slot.balances, coin_type, balance);
		};
	}

	public(package) fun take_from_balance<T>(
		slot: &mut Slot, 
		amount: u64, 
		check_sender: bool,
		ctx: &mut TxContext
	): Coin<T> {
		if(check_sender) {
			assert!(*&slot.owner == ctx.sender(), ENotASlotOwner);
		};

		let coin_type = type_name::get<T>().into_string();
		assert!(bag::contains<String>(&slot.balances, coin_type), ESlotHasNoType);

		let token_balance = bag::borrow_mut<String, Balance<T>>(&mut slot.balances, coin_type);
		assert!(token_balance.value() >= amount, EBalanceIsLow);

		let taken = token_balance.split(amount);
		coin::from_balance<T>(taken, ctx)
	}

	public fun get_owner(slot: &Slot): address {
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