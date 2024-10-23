module dexcelerate::fee {
	use sui::sui::{SUI};
	use sui::coin::{Coin};
	use sui::balance::{Self, Balance};

	use sui::event;
	use sui::vec_map::{Self, VecMap};

	const ENotEnoughUniqueWallets: u64 = 0;
	const EZeroAddress: u64 = 1;
	const EBalanceIsLow: u64 = 2;

	const EOnlyCold: u64 = 3;
	const EOldWalletIsNotCold: u64 = 4;
	const ENewWalletIsAlreadyCold: u64 = 5;

	const EAlreadyVoted: u64 = 6;

	public struct FeeManagerWitness has key {
		id: UID
	}

	public struct FeeManager has key, store {
		id: UID,
		balance: Balance<SUI>,

		reset_counter: vector<address>,
		withdraw_counter: vector<address>,

		cold: VecMap<address, bool>
	}

	// Events

	public struct FeeManagerCreated has copy, drop, store {
		manager_address: address
	}

	public struct FeeAddressReset has copy, drop, store {
		old_wallet: address,
		new_wallet: address
	}

	public struct Withdrawal has copy, drop, store {
		recipients: vector<address>,
		amount: u64
	}

	fun init(ctx: &mut TxContext) {
		let empty_addresses = vector::empty<address>();

		let manager = FeeManager {
			id: object::new(ctx),
			balance: balance::zero<SUI>(),
			reset_counter: empty_addresses,
			withdraw_counter: empty_addresses,
			cold: vec_map::empty<address, bool>()
		};

		event::emit(FeeManagerCreated {
			manager_address: object::id_address(&manager)
		});

		transfer::public_share_object(manager);
		transfer::transfer(FeeManagerWitness {
			id: object::new(ctx)
		}, ctx.sender());
	}

	public entry fun initialize_fee_manager(
		witness: FeeManagerWitness,
		manager: &mut FeeManager,
		wallets: vector<address>
	) {
		let wallets_length = wallets.length();
		assert!(wallets_length > 2, ENotEnoughUniqueWallets);

		let cold = vec_map::empty<address, bool>();

		let mut i = 0;
		while(i < wallets_length) {
			let wallet = *wallets.borrow(i);
			assert!(wallet != @0x0, EZeroAddress);

			cold.insert(wallet, true);
			i = i + 1;
		};

		*&mut manager.cold = cold;

		let FeeManagerWitness {id} = witness;
		id.delete();
	}

	public entry fun add_fee(
		fee_manager: &mut FeeManager,
		coin: Coin<SUI>
	) {
		balance::join<SUI>(&mut fee_manager.balance, coin.into_balance());
	}

	public entry fun reset(
		fee_manager: &mut FeeManager, 
		old_wallet: address, 
		new_wallet: address, 
		ctx: &mut TxContext
	) {
		let sender = ctx.sender();
		let cold_copy = *&fee_manager.cold;

		assert!(cold_copy.contains(&sender), EOnlyCold);

		assert!(cold_copy.contains(&old_wallet), EOldWalletIsNotCold);
		assert!(new_wallet != @0x0, EZeroAddress);
		assert!(!cold_copy.contains(&new_wallet), ENewWalletIsAlreadyCold);

		assert!(!vector::contains<address>(&fee_manager.reset_counter, &sender), EAlreadyVoted);

		vector::push_back<address>(&mut fee_manager.reset_counter, sender);

		if(vector::length(&fee_manager.reset_counter) > cold_copy.size() / 2) {
			*&mut fee_manager.reset_counter = vector::empty<address>();

			vec_map::remove<address, bool>(&mut fee_manager.cold, &old_wallet);
			vec_map::insert<address, bool>(&mut fee_manager.cold, new_wallet, true);

			event::emit(FeeAddressReset {
				old_wallet,
				new_wallet
			});
		};
	}

	public entry fun withdraw(
		fee_manager: &mut FeeManager,
		amount: u64,
		ctx: &mut TxContext
	) {
		let sender = ctx.sender();
		assert!(*&fee_manager.cold.contains(&sender), EOnlyCold);
		assert!(*&fee_manager.balance.value() >= amount, EBalanceIsLow);

		assert!(!*&fee_manager.withdraw_counter.contains(&sender), EAlreadyVoted);
		vector::push_back<address>(&mut fee_manager.withdraw_counter, sender);

		if(*&fee_manager.withdraw_counter.length() == *&fee_manager.cold.size()) {
			let (recipients, _) = (*&fee_manager.cold).into_keys_values();
			split_and_pay(balance::split<SUI>(&mut fee_manager.balance, amount), recipients, ctx);

			*&mut fee_manager.withdraw_counter = vector::empty<address>();
			event::emit(Withdrawal {
				recipients,
				amount
			});
		};
	}

	fun split_and_pay(
		balance: Balance<SUI>,
		recipients: vector<address>,
		ctx: &mut TxContext
	) {
		let mut coins = balance.into_coin<SUI>(ctx);
		let amount_to_each = coins.value() / recipients.length();

		let mut i = 0;
		while(i < recipients.length()) {
			transfer::public_transfer(coins.split(amount_to_each, ctx), *recipients.borrow(i));
		};
	}
}