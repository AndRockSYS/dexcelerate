module dexcelerate::slot_balance_manager {
	use std::ascii::{String};
	use std::type_name;

	use sui::clock::{Clock};
	use sui::event;

	use sui::coin::{Self, Coin};
	use sui::sui::{SUI};

	use flow_x::factory::{Container};
	use blue_move::swap::{Dex_Info};
	use move_pump::move_pump::{Configuration};
	use turbos_clmm::pool::{Pool as TPool, Versioned as TVersioned};
	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool as CPool};
	use flowx_clmm::pool::{Pool as FPool};
    use flowx_clmm::versioned::{Versioned as FVersioned};

	use dexcelerate::slot::{Slot};
	use dexcelerate::slot_swap_amm;
	use dexcelerate::turbos_clmm_protocol;
	use dexcelerate::cetus_clmm_protocol;
	use dexcelerate::flow_x_clmm_protocol;

	use dexcelerate::utils;

	public struct Deposit has copy, drop, store {
		to: address,
		base_token_amount: u64
	}

	public struct Withdraw has copy, drop, store {
		to: address,
		token: String,
		amount: u64
	}

	public entry fun deposit_base(
		slot: &mut Slot, 
		coin_in: Coin<SUI>, 
	) {
		event::emit(Deposit {		
			to: object::id_address(slot),
			base_token_amount: coin_in.value()
		});

		slot.add_to_balance<SUI>(coin_in.into_balance<SUI>());
	}

	public entry fun withdraw_base(
		slot: &mut Slot, 
		amount: u64, 
		ctx: &mut TxContext
	) {
		let coin_out = slot.take_from_balance_with_sender<SUI>(amount, ctx);

		withdraw_base_internal<SUI>(coin_out, ctx);
	}

	public entry fun deposit_amm<T>(
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

		let (base_out, coin_in_left) = slot_swap_amm::swap_base_amm_no_fees<T>(
			coin::zero<SUI>(ctx), coin_in, 0, // ! amount_min_out
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		transfer::public_transfer(coin_in_left, ctx.sender());
		deposit_base(slot, base_out);
	}

	public entry fun withdraw_amm<T>(
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

		let coin_in = slot.take_from_balance_with_sender<T>(amount, ctx);

		let (base_out, coin_in_left) = slot_swap_amm::swap_base_amm_no_fees<T>(
			coin::zero<SUI>(ctx), coin_in, 0, // ! amount_min_out
			container, dex_info, config, protocol_id,
			clock, ctx
		);

		slot.add_to_balance<T>(coin_in_left.into_balance<T>());	
		withdraw_base_internal<SUI>(base_out, ctx);
	}

	public entry fun deposit_turbos<T, FeeType>(
		slot: &mut Slot,
		coin_in: Coin<T>,

		pool: &mut TPool<T, SUI, FeeType>,
		versioned: &TVersioned,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<T>();

		let (coin_a, coin_b) = turbos_clmm_protocol::swap<T, SUI, FeeType>(
			pool, coin_in, coin::zero<SUI>(ctx), versioned, clock, ctx
		);

		transfer::public_transfer(coin_a, ctx.sender());
		deposit_base(slot, coin_b);
	}

	public entry fun withdraw_turbos<T, FeeType>(
		slot: &mut Slot,
		amount: u64,

		pool: &mut TPool<T, SUI, FeeType>,
		versioned: &TVersioned,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<T>();

		let (coin_a, coin_b) = turbos_clmm_protocol::swap<T, SUI, FeeType>(
			pool, 
			slot.take_from_balance_with_sender<T>(amount, ctx), coin::zero<SUI>(ctx), 
			versioned, clock, ctx
		);

		slot.add_to_balance<T>(coin_a.into_balance<T>());
		withdraw_base_internal<SUI>(coin_b, ctx);
	}

	public entry fun deposit_cetus<T>(
		slot: &mut Slot,
		coin_in: Coin<T>,

		pool: &mut CPool<T, SUI>,
		config: &GlobalConfig,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<T>();

		let (coin_a, coin_b) = cetus_clmm_protocol::swap<T, SUI>(
			pool, coin_in, coin::zero<SUI>(ctx),
			config, clock, ctx
		);

		transfer::public_transfer(coin_a, ctx.sender());
		deposit_base(slot, coin_b);
	}

	public entry fun withdraw_cetus<T>(
		slot: &mut Slot,
		amount: u64,

		pool: &mut CPool<T, SUI>,
		config: &GlobalConfig,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<T>();

		let (coin_a, coin_b) = cetus_clmm_protocol::swap<T, SUI>(
			pool, 
			slot.take_from_balance_with_sender<T>(amount, ctx), coin::zero<SUI>(ctx),
			config, clock, ctx
		);

		transfer::public_transfer(coin_a, ctx.sender());
		withdraw_base_internal<SUI>(coin_b, ctx);
	}

	public entry fun deposit_flow_x_clmm<T>(
		slot: &mut Slot,
		coin_in: Coin<T>,

		pool: &mut FPool<T, SUI>,
		versioned: &mut FVersioned,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<T>();

		let (coin_a, coin_b) = flow_x_clmm_protocol::swap<T, SUI>(
			pool, coin_in, coin::zero<SUI>(ctx), versioned, clock, ctx
		);

		transfer::public_transfer(coin_a, ctx.sender());
		deposit_base(slot, coin_b);
	}

	public entry fun withdraw_flow_x_clmm<T>(
		slot: &mut Slot,
		amount: u64,

		pool: &mut FPool<T, SUI>,
		versioned: &mut FVersioned,

		clock: &Clock,
		ctx: &mut TxContext
	) {
		utils::not_base<T>();

		let (coin_a, coin_b) = flow_x_clmm_protocol::swap<T, SUI>(
			pool, 
			slot.take_from_balance_with_sender<T>(amount, ctx), coin::zero<SUI>(ctx), 
			versioned, clock, ctx
		);

		slot.add_to_balance<T>(coin_a.into_balance<T>());
		withdraw_base_internal<SUI>(coin_b, ctx);
	}

	#[allow(lint(self_transfer))]
	fun withdraw_base_internal<T>(
		base_coin: Coin<SUI>,
		ctx: &TxContext
	) {
		event::emit(Withdraw {		
			to: ctx.sender(),
			token: type_name::get<T>().into_string(),
			amount: base_coin.value()
		});

		transfer::public_transfer(base_coin, ctx.sender());
	}
}