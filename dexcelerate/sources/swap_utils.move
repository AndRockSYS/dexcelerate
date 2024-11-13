module dexcelerate::swap_utils {
	use sui::clock::{Clock};

	use sui::sui::{SUI};
	use sui::coin::{Self, Coin};

	use flow_x::factory::{Container};
	use dexcelerate::flow_x_amm_protocol;

	use blue_move::swap::{Dex_Info};
	use dexcelerate::blue_move_protocol;

	use cetus_clmm::config::{GlobalConfig};
	use cetus_clmm::pool::{Pool as CPool};
	use dexcelerate::cetus_clmm_protocol;

	use flowx_clmm::pool::{Pool as FPool};
    use flowx_clmm::versioned::Versioned;
	use dexcelerate::flow_x_clmm_protocol;

	use dexcelerate::bank::{Bank};
	use dexcelerate::fee::{FeeManager};
	use dexcelerate::utils;

	const ENotEnoughToCoverGas: u64 = 0;
	const ENotSuiToken: u64 = 1;

	public(package) fun take_fee(
		bank: &mut Bank,
		fee_manager: &mut FeeManager,
		payment: &mut Coin<SUI>,
		users_fee_percent: u64,
		total_fee_percent: u64,
		ctx: &mut TxContext
	) {
		let total_fee = utils::calculate_fee(payment.value(), total_fee_percent);
		let user_fee = utils::calculate_fee(total_fee, users_fee_percent);

		bank.add_to_bank(payment.split(user_fee, ctx), ctx);
		fee_manager.add_fee(payment.split(total_fee - user_fee, ctx));
	}

	public(package) fun repay_sponsor_gas<T>(
		coin: &mut Coin<T>,
		gas_amount: u64,
		platform: address,
		ctx: &mut TxContext
	) {
		assert!(utils::is_base<T>(), ENotSuiToken);

		if(gas_amount > 0) {
			assert!(coin.value() >= gas_amount, ENotEnoughToCoverGas);
			transfer::public_transfer(coin.split(gas_amount, ctx), platform);
		};
	}

	public(package) fun repay_sponsor_gas_flow_x_clmm<T>(
		pool: &mut FPool<T, SUI>,
		coin: &mut Coin<T>,
		gas_amount: u64,
		platform: address,
		versioned: &mut Versioned,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		if(gas_amount > 0) {
			let coin_value = flow_x_clmm_protocol::get_required_coin_amount<T>(pool, gas_amount);

			assert!(coin.value() > coin_value, ENotEnoughToCoverGas);

			let (coin_a, gas_coin) = flow_x_clmm_protocol::swap<T, SUI>(
				pool, coin.split(coin_value, ctx), coin::zero<SUI>(ctx),
				versioned, clock, ctx
			);

			coin.join(coin_a);

			transfer::public_transfer(gas_coin, platform);
		};
	}

	public(package) fun repay_sponsor_gas_cetus<T>(
		pool: &mut CPool<T, SUI>,
		coin: &mut Coin<T>,
		gas_amount: u64,
		platform: address,
		config: &GlobalConfig,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		if(gas_amount > 0) {
			let coin_value = cetus_clmm_protocol::get_required_coin_amount<T>(
				pool, gas_amount
			);

			assert!(coin.value() > coin_value, ENotEnoughToCoverGas);

			let (coin_a, gas_coin) = cetus_clmm_protocol::swap<T, SUI>(
				pool, coin.split(coin_value, ctx), coin::zero<SUI>(ctx),
				config, clock, ctx
			);

			coin.join(coin_a);

			transfer::public_transfer(gas_coin, platform);
		};
	}

	public(package) fun repay_sponsor_gas_v2<T>(
		coin: &mut Coin<T>,
		container: &mut Container, // flow_x
		dex_info: &mut Dex_Info, // blue_move
		protocol_id: u8, // 0 or 1
		gas_amount: u64,
		platform: address,
		ctx: &mut TxContext
	) {
		if(gas_amount > 0) {
			let coin_value = if(protocol_id == 0) {
				flow_x_amm_protocol::get_required_coin_amount<T>(
					container, gas_amount
				)
			} else {
				blue_move_protocol::get_required_coin_amount<T>(
					dex_info, gas_amount
				)
			};
			assert!(coin.value() > coin_value, ENotEnoughToCoverGas);

			let gas_coin = 	if(protocol_id == 0) {
				flow_x_amm_protocol::swap_a_to_b<T, SUI>(
					coin.split(coin_value, ctx), container, ctx
				)
			} else {
				blue_move_protocol::swap_a_to_b<T, SUI>(
					coin.split(coin_value, ctx), 102, dex_info, ctx
				)
			};

			transfer::public_transfer(gas_coin, platform);
		};
	}
}