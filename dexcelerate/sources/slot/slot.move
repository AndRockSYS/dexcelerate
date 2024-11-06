module dexcelerate::slot {
	use std::ascii::{String};
	use std::type_name;

	use sui::clock::{Clock};
	use sui::event;
	use sui::bag::{Self, Bag};

	use sui::balance::{Self, Balance};
	use sui::coin::{Self, Coin};
	use sui::sui::{SUI};

	use flow_x::factory::{Container};
	use blue_move::swap::{Dex_Info};
	use move_pump::move_pump::{Configuration};
	use turbos_clmm::pool::{Pool as TPool, Versioned};
	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool as CPool};

	use dexcelerate::swap_router;
	use dexcelerate::utils;

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

	public entry fun deposit_base(
		slot: &mut Slot, 
		coin_in: Coin<SUI>, 
	) {
		event::emit(Deposit {		
			slot: object::id_address(slot),
			token: type_name::get<SUI>().into_string(),
			amount: coin_in.value()
		});

		add_to_balance<SUI>(slot, coin_in.into_balance<SUI>());
	}

	public entry fun withdraw_base(
		slot: &mut Slot, 
		amount: u64, 
		ctx: &mut TxContext
	) {
		let coin_out = take_from_balance<SUI>(slot, amount, true, ctx);
		withdraw_after_swap<SUI>(
			slot, coin_out, ctx
		);
	}

	#[allow(lint(self_transfer))]
	fun withdraw_after_swap<T>(
		slot: &Slot,
		base_coin: Coin<SUI>,
		ctx: &TxContext
	) {
		event::emit(Withdraw {		
			slot: object::id_address(slot),
			token: type_name::get<T>().into_string(),
			amount: base_coin.value()
		});

		transfer::public_transfer(base_coin, ctx.sender());
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
		utils::not_base<T>();

		let (base_out, coin_in_left) = swap_router::swap_base_v2<T>(
			coin_in, coin::zero<SUI>(ctx), 0, // ! amount_min_out
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		transfer::public_transfer(coin_in_left, ctx.sender());
		deposit_base(slot, base_out);
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
		utils::not_base<T>();

		let coin_in = take_from_balance<T>(slot, amount, true, ctx);

		let (base_out, coin_in_left) = swap_router::swap_base_v2<T>(
			coin_in, coin::zero<SUI>(ctx), 0, // ! amount_min_out
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		add_to_balance<T>(slot, coin_in_left.into_balance<T>());	

		withdraw_after_swap<SUI>(
			slot, base_out, ctx
		);
	}

	public entry fun deposit_v3_turbos<T, FeeType>(
		slot: &mut Slot,
		pool: &mut TPool<T, SUI, FeeType>,
		coin_in: Coin<T>,
		versioned: &Versioned,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<T>();

		let (coin_a, coin_b) = swap_router::swap_v3_turbos<T, SUI, FeeType>(
			coin_in, coin::zero<SUI>(ctx),
			pool,
			versioned, clock, ctx
		);

		transfer::public_transfer(coin_a, ctx.sender());
		deposit_base(slot, coin_b);
	}

	public entry fun withdraw_v3_turbos<T, FeeType>(
		slot: &mut Slot,
		pool: &mut TPool<T, SUI, FeeType>,
		coin_in: Coin<T>,
		versioned: &Versioned,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<T>();

		let (coin_a, coin_b) = swap_router::swap_v3_turbos<T, SUI, FeeType>(
			coin_in, coin::zero<SUI>(ctx),
			pool,
			versioned, clock, ctx
		);

		add_to_balance<T>(slot, coin_a.into_balance<T>());

		withdraw_after_swap<SUI>(
			slot, coin_b, ctx
		);
	}

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