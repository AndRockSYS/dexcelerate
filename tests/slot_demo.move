#[test_only]
module dexcelerate::slot_demo {
	use std::type_name;
	use std::ascii::{String};
	use sui::clock::{Clock};
	use sui::event;

	use sui::coin::{Coin};
	use sui::sui::{SUI};
	use token::deep::{DEEP};

	use deepbook::balance_manager::{Self as bm, BalanceManager};
	use deepbook::pool::{Self, Pool};

	public struct ManagerCreated has copy, drop {
		owner: address,
		manager_address: address
	}

	public struct Swap has copy, drop {
		manager_address: address,
		token_in: String,
		amount_in: u64,
		token_out: String,
		amount_out: u64
	}

	public entry fun new(ctx: &mut TxContext) {
		let manager = bm::new(ctx);

		event::emit(ManagerCreated {
			owner: ctx.sender(),
			manager_address: object::id_address(&manager)
		});

		transfer::public_share_object(manager);
	}

	public entry fun deposit<T>(
		balance_manager: &mut BalanceManager,
		pool: &mut Pool<T, SUI>,
		coin_in: Coin<T>, 
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let coin_out = into_quote<T, SUI>(balance_manager, pool, coin_in, clock, ctx);
		bm::deposit<SUI>(balance_manager, coin_out, ctx);
	}

	public entry fun withdraw<T>(
		balance_manager: &mut BalanceManager, 
		pool: &mut Pool<T, SUI>,
		amount: u64, 
		clock: &Clock,
		ctx: &mut TxContext
	) {
		// Will revert if balance is low
		let coin_in = bm::withdraw<T>(balance_manager, amount, ctx);
		let coin_out = into_quote<T, SUI>(balance_manager, pool, coin_in, clock, ctx);

		transfer::public_transfer(coin_out, ctx.sender());
	}

	public fun into_base<Base, Quote>(
		balance_manager: &mut BalanceManager,
		pool: &mut Pool<Base, Quote>,
		coin_in: Coin<Quote>,
		clock: &Clock,
		ctx: &mut TxContext
	): Coin<Base> {
		let coin_in_value = coin_in.value();

		let (expected_base_out, _, deep_required) = pool::get_base_quantity_out(pool, coin_in_value, clock);

		// Will revert if user has not enough of DEEP
		let deep_in = balance_manager.withdraw<DEEP>(deep_required + 1_000, ctx);

		let (base_out, quote_out, deep_out) = pool::swap_exact_quote_for_base<Base, Quote>(
			pool,
			coin_in,
			deep_in,
			expected_base_out,
			clock,
			ctx,
		);

		event::emit(Swap {
			manager_address: object::id_address(balance_manager),
			token_in: type_name::into_string(type_name::get<Quote>()),
			amount_in: coin_in_value - quote_out.value(),
			token_out: type_name::into_string(type_name::get<Base>()),
			amount_out: base_out.value()
		});

		bm::deposit<Quote>(balance_manager, quote_out, ctx);
		bm::deposit<DEEP>(balance_manager, deep_out, ctx);

		base_out
	}

	public fun into_quote<Base, Quote>(
		balance_manager: &mut BalanceManager,
		pool: &mut Pool<Base, Quote>,
		coin_in: Coin<Base>,
		clock: &Clock,
		ctx: &mut TxContext
	): Coin<Quote> {
		let coin_in_value = coin_in.value();

		let (_, expected_quote_out, deep_required) = pool::get_quote_quantity_out(pool, coin_in_value, clock);

		// Will revert if user has not enough of DEEP
		let deep_in = balance_manager.withdraw<DEEP>(deep_required + 1_000, ctx);

		let (base_out, quote_out, deep_out) = pool::swap_exact_base_for_quote<Base, Quote>(
			pool,
			coin_in,
			deep_in,
			expected_quote_out,
			clock,
			ctx,
		);

		event::emit(Swap {
			manager_address: object::id_address(balance_manager),
			token_in: type_name::into_string(type_name::get<Base>()),
			amount_in: coin_in_value - base_out.value(),
			token_out: type_name::into_string(type_name::get<Quote>()),
			amount_out: quote_out.value()
		});

		bm::deposit<Base>(balance_manager, base_out, ctx);
		bm::deposit<DEEP>(balance_manager, deep_out, ctx);

		quote_out
	}

	public entry fun test() {

	}
}
