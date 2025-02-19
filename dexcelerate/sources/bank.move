module dexcelerate::bank {
	use sui::clock::{Self, Clock};

	use sui::bcs::{to_bytes};
	use sui::ed25519::{ed25519_verify};
	use sui::hash::{keccak256};

	use sui::bag::{Self, Bag};
	use sui::event;

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};
	use sui::balance::{Self, Balance};

	const EZeroAddress: u64 = 0;
	const EInvalidSignature: u64 = 1;
	const EBalanceIsLow: u64 = 2;

	const ECouponExpired: u64 = 3;
	const ECouponUsed: u64 = 4;

	public struct BankSignerCap has key, store {
		id: UID
	}

	public struct Bank has key, store {
		id: UID,
		balance: Balance<SUI>,
		coupons: Bag,
		signer_public_key: vector<u8>
	}

	// Events

	public struct Claimed has copy, drop, store {
		coupon_hash: vector<u8>,
		receiver: address,
		amount: u64
	}

	public struct SignerUpdated has copy, drop, store {
		new_signer: address
	}

	public struct UserFeeAmount has copy, drop, store {
		amount: u64
	}

	public struct Cancelled has copy, drop, store {
		coupon_hash: vector<u8>
	}

	public struct Withdrawn has copy, drop, store {
		user: address,
		amount: u64
	}

	public struct Received has copy, drop, store {
		sender: address,
		value: u64
	}

	fun init(ctx: &mut TxContext) {
		transfer::public_share_object(Bank {
			id: object::new(ctx),
			balance: balance::zero<SUI>(),
			coupons: bag::new(ctx),
			signer_public_key: vector::empty<u8>()
		});

		transfer::public_transfer(BankSignerCap {
			id: object::new(ctx)
		}, ctx.sender());

		event::emit(SignerUpdated {
			new_signer: ctx.sender()
		});
	}

	// need to call after init to set everything up
	public entry fun set_signer(
		bank: &mut Bank,
		signer_cap: BankSignerCap, 
		new_signer: address,
		new_public_key: vector<u8>
	) {
		assert!(new_signer != @0x0, EZeroAddress);

		*&mut bank.signer_public_key = new_public_key;
		transfer::public_transfer(signer_cap, new_signer);

		event::emit(SignerUpdated {new_signer});
	}

	public entry fun add_to_bank(
		bank: &mut Bank,
		coin: Coin<SUI>,
		ctx: &TxContext
	) {
		event::emit(Received {
			sender: ctx.sender(),
			value: coin.value()
		});
		event::emit(UserFeeAmount {
			amount: coin.value()
		});
		balance::join<SUI>(&mut bank.balance, coin.into_balance());
	}

	public entry fun claim_coupon(
		bank: &mut Bank,
		signed_coupon: vector<u8>,
		coupon_hash: vector<u8>,
		receiver: address,
		amount: u64,
		expiry: u64,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		assert!(clock::timestamp_ms(clock) < expiry, ECouponExpired);

		assert!(!bag::contains<vector<u8>>(&bank.coupons, coupon_hash), ECouponUsed);
		bag::add<vector<u8>, bool>(&mut bank.coupons, coupon_hash, true);

		let mut message = coupon_hash;
		vector::append<u8>(&mut message, to_bytes<address>(&receiver));
		vector::append<u8>(&mut message, to_bytes<u64>(&amount));
		vector::append<u8>(&mut message, to_bytes<u64>(&expiry));
		let hashed_message = keccak256(&message);

		assert!(ed25519_verify(&signed_coupon, &bank.signer_public_key, &hashed_message), EInvalidSignature);

		withdraw_and_transfer(bank, receiver, amount, ctx);
		event::emit(Claimed {
			coupon_hash,
			receiver,
			amount
		});
	}

	public entry fun cancel_coupon(
		_: &BankSignerCap,
		bank: &mut Bank,
		coupon_hash: vector<u8>
	) {
		bag::add<vector<u8>, bool>(&mut bank.coupons, coupon_hash, true);
		event::emit(Cancelled {
			coupon_hash
		});
	}

	public entry fun withdraw_sui(
		_: &BankSignerCap,
		bank: &mut Bank,
		to: address,
		amount: u64,
		ctx: &mut TxContext
	) {
		withdraw_and_transfer(bank, to, amount, ctx);
		event::emit(Withdrawn {
			user: to,
			amount
		});
	}

	fun withdraw_and_transfer(
		bank: &mut Bank, 
		to: address, 
		amount: u64,
		ctx: &mut TxContext
	) {
		assert!(*&bank.balance.value() >= amount, EBalanceIsLow);
		let balance_to_transfer = balance::split<SUI>(&mut bank.balance, amount);
		transfer::public_transfer(coin::from_balance<SUI>(balance_to_transfer, ctx), to);
	}
}