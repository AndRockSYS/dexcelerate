module dexcelerate::slot_swap {
	use std::bcs::to_bytes;
	use std::type_name;

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};

	use dexcelerate::slot::{Slot};
	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};

	const EWrongSwapType: u64 = 0;

	public entry fun buy_with_base<B>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		slot: &mut Slot,
		amount_in: u64,
		users_fee_percent: u64,
		total_fee_percent: u64,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance<SUI>(amount_in, true, ctx);

		coin_in = calc_and_transfer_fees(
			bank, 
			fee_manager, 
			coin_in, 
			users_fee_percent, 
			total_fee_percent, ctx
		);

		// todo swap here

		// todo transfer here
	}

	public entry fun sell_with_base<A>(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		slot: &mut Slot,
		amount_in: u64,
		users_fee_percent: u64,
		total_fee_percent: u64,
		ctx: &mut TxContext
	) {
		let mut coin_in = slot.take_from_balance<A>(amount_in, true, ctx);

		// todo swap here

		coin_out = calc_and_transfer_fees(
			bank, 
			fee_manager, 
			coin_out, 
			users_fee_percent, 
			total_fee_percent, ctx
		);

		// todo transfer here
	}

	public entry fun buy<A, B>(
		slot: &mut Slot,
		amount_in: u64,
		ctx: &mut TxContext
	) {
		assert!(to_bytes(&type_name::get<SUI>()) == b"0x2::sui::SUI", EWrongSwapType);

		let mut coin_in = slot.take_from_balance<A>(amount_in, true, ctx);
	}

	public entry fun sell<A, B>(
		slot: &mut Slot,
		amount_in: u64,
		ctx: &mut TxContext
	) {
		assert!(to_bytes(&type_name::get<SUI>()) == b"0x2::sui::SUI", EWrongSwapType);

		let mut coin_in = slot.take_from_balance<B>(amount_in, true, ctx);
	}

	fun calc_and_transfer_fees(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		mut payment: Coin<SUI>,
		users_fee_percent: u64,
		total_fee_percent: u64,
		ctx: &mut TxContext
	): Coin<SUI> {
		let total_fee = ((payment.value() as u128) * (total_fee_percent as u128) / 100_000) as u64;
		let user_fee = ((total_fee as u128) * (users_fee_percent as u128) / 100_000) as u64;

		bank.add_to_bank(payment.split(user_fee, ctx), ctx);
		fee_manager.add_fee(payment.split(total_fee - user_fee, ctx));

		payment
	}
}