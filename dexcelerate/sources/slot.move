module dexcelerate::slot {
	use std::ascii::{String};
	use std::type_name;

	use sui::event;

	use sui::balance::{Self, Balance};
	use sui::coin::{Self, Coin};
	use sui::sui::{SUI};

	use sui::bag::{Self, Bag};

	use blue_move::router;
	use blue_move::swap::{Dex_Info};

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

	public entry fun deposit<T>(
		slot: &mut Slot, 
		coin_in: Coin<T>, 
		dex_info: &mut Dex_Info, 
		ctx: &mut TxContext
	) {
		let coin_out: Coin<SUI> = router::swap_exact_input_<T, SUI>(
			coin_in.value(), 
			coin_in, 
			0, // ! amount out min 
			dex_info, 
			ctx
		);

		event::emit(Deposit {		
			slot: object::id_address(slot),
			token: type_name::get<T>().into_string(),
			amount: coin_in.value()
		});

		add_to_balance<SUI>(slot, coin_out.into_balance<SUI>());
	}

	public entry fun withdraw<T>(
		slot: &mut Slot, 
		amount: u64, 
		dex_info: &mut Dex_Info,
		ctx: &mut TxContext
	) {
		assert!(*&slot.owner == ctx.sender(), ENotASlotOwner);

		let balance_in = take_from_balance<T>(slot, amount);
		let coin_out: Coin<SUI> = router::swap_exact_input_<T, SUI>(
			balance_in.value(), 
			coin::from_balance<T>(balance_in, ctx), 
			0, // ! amount out min 
			dex_info, 
			ctx
		);

		event::emit(Deposit {		
			slot: object::id_address(slot),
			token: type_name::get<T>().into_string(),
			amount
		});

		transfer::public_transfer(coin_out, ctx.sender());
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

	public(package) fun take_from_balance<T>(slot: &mut Slot, amount: u64): Balance<T> {
		let coin_type = type_name::get<T>().into_string();
		assert!(bag::contains<String>(&slot.balances, coin_type), ESlotHasNoType);

		let coin_balance = bag::borrow_mut<String, Balance<T>>(&mut slot.balances, coin_type);
		assert!(balance::value<T>(coin_balance) >= amount, EBalanceIsLow);

		balance::withdraw_all<T>(coin_balance)
	}

	public fun get_owner(slot: &Slot): address {
		*&slot.owner
	}
}