module dexcelerate::swap_router {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};

	use flow_x::factory::{Container};
	use dexcelerate::flow_x_protocol;

	use blue_move::swap::{Dex_Info};
	use dexcelerate::blue_move_protocol;

	use move_pump::move_pump::{Configuration};
	use dexcelerate::move_pump_protocol;

	use turbos_clmm::pool::{Pool as TPool, Versioned};
	use dexcelerate::turbos_clmm_protocol;

	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool as CPool};
	use dexcelerate::cetus_clmm_protocol;

	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};

	const ENotEnoughToCoverGas: u64 = 0;
	const EZeroCoins: u64 = 1;
	const ETwoCoins: u64 = 2;

	public(package) fun swap_v2<A, B>(
		coin_in: Coin<A>,
		amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		protocol_id: u8, // 0 or 1
		ctx: &mut TxContext
	): Coin<B> {
		let mut coin_out = coin::zero<B>(ctx);

		if(protocol_id == 0) {
			coin_out.join(flow_x_protocol::swap_exact_input<A, B>(
				container, coin_in, ctx
			));
		} else {
			coin_out.join(blue_move_protocol::swap_exact_input<A, B>(
				coin_in, amount_min_out, dex_info, ctx
			));
		};

		coin_out
	}

	public(package) fun swap_base_v2<T>(
		coin_in: Coin<T>,
		base_in: Coin<SUI>,
		amount_min_out: u64,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		config: &mut Configuration, // move_pump
		protocol_id: u8, // 0 or 1 or 2
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<SUI>, Coin<T>) {
		assert!(coin_in.value() > 0 || base_in.value() > 0, EZeroCoins);
		if(coin_in.value() > 0 && base_in.value() > 0) {
			abort(ETwoCoins)
		};

		if(coin_in.value() > 0) {
			// swapping T to SUI

			let mut coin_in_left = coin::zero<T>(ctx);
			let mut base_out = coin::zero<SUI>(ctx);

			if(protocol_id == 2) {
				let (out, left) = move_pump_protocol::sui_from_coin<T>(
					config, coin_in, amount_min_out, clock, ctx
				);
				coin_in_left.join(left);
				base_out.join(out);
			} else {
				base_out.join(swap_v2<T, SUI>(
					coin_in, amount_min_out,
					container, dex_info, protocol_id,
					ctx
				));
			};

			base_in.destroy_zero();

			(base_out, coin_in_left)
		} else {
			// swapping SUI to T

			let mut base_in_left = coin::zero<SUI>(ctx);
			let mut coin_out = coin::zero<T>(ctx);

			if(protocol_id == 2) {
				let (left, out) = move_pump_protocol::sui_to_coin<T>(
					config, dex_info, base_in, amount_min_out, clock, ctx
				);
				base_in_left.join(left);
				coin_out.join(out);
			} else {
				coin_out.join(swap_v2<SUI, T>(
					base_in, amount_min_out,
					container, dex_info, protocol_id,
					ctx
				));
			};

			coin_in.destroy_zero();

			(base_in_left, coin_out)
		}
	} 

	public(package) fun swap_v3_turbos<A, B, FeeType>(
		coin_a_in: Coin<A>,
		coin_b_in: Coin<B>,
		pool: &mut TPool<A, B, FeeType>,
		versioned: &Versioned,
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		assert!(coin_a_in.value() > 0 || coin_b_in.value() > 0, EZeroCoins);
		if(coin_a_in.value() > 0 && coin_b_in.value() > 0) {
			abort(ETwoCoins)
		};

		let mut coin_a_out = coin::zero<A>(ctx);
		let mut coin_b_out = coin::zero<B>(ctx);

		if(coin_a_in.value() > 0 ) {
			let (coin_out, coin_in_left) = turbos_clmm_protocol::swap_a_to_b<A, B, FeeType>(
				pool, 
				coin_a_in, 
				clock, versioned, ctx
			);
			coin_b_out.join(coin_out);
			coin_a_out.join(coin_in_left);

			coin_b_in.destroy_zero();
		} else {
			let (coin_out, coin_in_left) = turbos_clmm_protocol::swap_b_to_a<A, B, FeeType>(
				pool, 
				coin_b_in, 
				clock, versioned, ctx
			);
			coin_a_out.join(coin_out);
			coin_b_out.join(coin_in_left);

			coin_a_in.destroy_zero();
		};

		(coin_a_out, coin_b_out)
	}

	public(package) fun swap_v3_cetus<A, B>(
		coin_a_in: Coin<A>,
		coin_b_in: Coin<B>,
		config: &GlobalConfig,
		pool: &mut CPool<A, B>,
		clock: &Clock,
		ctx: &mut TxContext
	): (Coin<A>, Coin<B>) {
		assert!(coin_a_in.value() > 0 || coin_b_in.value() > 0, EZeroCoins);
		if(coin_a_in.value() > 0 && coin_b_in.value() > 0) {
			abort(ETwoCoins)
		};

		let (coin_a_out, coin_b_out) = 
			if(coin_a_in.value() > 0) {
				coin_b_in.destroy_zero();

				cetus_clmm_protocol::swap_a_to_b<A, B>(
					config, pool,
					coin_a_in,
					clock, ctx
				)
			} else {
				coin_a_in.destroy_zero();

				cetus_clmm_protocol::swap_b_to_a<A, B>(
					config, pool,
					coin_b_in,
					clock, ctx
				)
			};

		(coin_a_out, coin_b_out)
	}

	public(package) fun take_fee(
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

	public(package) fun return_sponsor_gas_coin_cetus<T>(
		coin: &mut Coin<T>,
		config: &GlobalConfig,
		pool: &mut CPool<T, SUI>,
		gas_amount: u64,
		platform: address,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		if(gas_amount > 0) {
			let coin_value = cetus_clmm_protocol::get_required_coin_amount<T>(
				pool, gas_amount
			);

			assert!(coin.value() > coin_value, ENotEnoughToCoverGas);

			let (coin_a, gas_coin) = swap_v3_cetus<T, SUI>(
				coin.split(coin_value, ctx), coin::zero<SUI>(ctx),
				config, pool, clock, ctx
			);

			coin.join(coin_a);

			transfer::public_transfer(gas_coin, platform);
		};
	}

	public(package) fun return_sponsor_gas_coin_v2<T>(
		coin: &mut Coin<T>,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		protocol_id: u8, // 0 or 1
		gas_amount: u64, // put 0 if user does it on his own
		platform: address,
		ctx: &mut TxContext
	) {
		if(gas_amount > 0) {
			let coin_value = if(protocol_id == 0) {
				flow_x_protocol::get_required_coin_amount<T>(
					container, gas_amount
				)
			} else {
				blue_move_protocol::get_required_coin_amount<T>(
					dex_info, gas_amount
				)
			};
			assert!(coin.value() > coin_value, ENotEnoughToCoverGas);

			let gas_coin = swap_v2<T, SUI>(
				coin.split(coin_value, ctx), 0, container, dex_info, protocol_id, ctx
			);
			transfer::public_transfer(gas_coin, platform);
		};
	}

	public(package) fun return_sponsor_gas_sui(
		coin: &mut Coin<SUI>,
		gas_amount: u64,
		platform: address,
		ctx: &mut TxContext
	) {
		if(gas_amount > 0) {
			assert!(coin.value() >= gas_amount, ENotEnoughToCoverGas);
			transfer::public_transfer(coin.split(gas_amount, ctx), platform);
		};
	}
}