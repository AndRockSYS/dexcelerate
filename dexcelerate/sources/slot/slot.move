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
	use dexcelerate::flow_x_protocol;
	use blue_move::swap::{Dex_Info};
	use dexcelerate::blue_move_protocol;
	use move_pump::move_pump::{Configuration};
	use dexcelerate::move_pump_protocol;

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

		let mut coin_out = coin::zero<SUI>(ctx);
		let amount_min_out = 0;

		if(token_type == type_name::get<SUI>().into_string()) {
			add_to_balance<T>(slot, coin_in.into_balance<T>());
		} else if (protocol_id == 0) {
			coin_out.join(flow_x_protocol::swap_exact_input<T, SUI>(
				container, coin_in, ctx
			));
		} else if (protocol_id == 1) {
			coin_out.join(blue_move_protocol::swap_exact_input<T, SUI>(
				coin_in, amount_min_out, dex_info, ctx
			));
		} else {
			let (out, left) = move_pump_protocol::sui_from_coin<T>(
				config, coin_in, amount_min_out, clock, ctx
			);
			transfer::public_transfer(left, ctx.sender());
			coin_out.join(out);
		};

		add_to_balance<SUI>(slot, coin_out.into_balance<SUI>());
	
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

		let mut coin_out = coin::zero<SUI>(ctx);
		let amount_min_out = 0;

		if(token_type == type_name::get<SUI>().into_string()) {
			transfer::public_transfer(coin_in, ctx.sender());
		} else if (protocol_id == 0) {
			coin_out.join(flow_x_protocol::swap_exact_input<T, SUI>(
				container, coin_in, ctx
			));
		} else if (protocol_id == 1) {
			coin_out.join(blue_move_protocol::swap_exact_input<T, SUI>(
				coin_in, amount_min_out, dex_info, ctx
			));
		} else {
			let (out, left) = move_pump_protocol::sui_from_coin<T>(
				config, coin_in, amount_min_out, clock, ctx
			);
			add_to_balance<T>(slot, left.into_balance<T>());
			coin_out.join(out);
		};

		transfer::public_transfer(coin_out, ctx.sender());

		event::emit(Withdraw {		
			slot: object::id_address(slot),
			token: token_type,
			amount
		});
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