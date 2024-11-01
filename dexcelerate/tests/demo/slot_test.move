#[test_only]
module dexcelerate::slot_test {
	use sui::coin::{Self, Coin};
	use sui::sui::{SUI};
	use token::deep::{DEEP};

	use sui::clock;
    use sui::test_scenario::{Self as ts, Scenario};
	use deepbook::pool_tests;

	use deepbook::balance_manager::{BalanceManager};
	use deepbook::pool::{Pool};

	use dexcelerate::slot_demo;

	const OWNER: address = @0xa;
	const ALICE: address = @0xAAAA;

	public struct TST has drop {}

	fun deposit_test(scenario: &mut Scenario) {
		let clock = clock::create_for_testing(scenario.ctx());
		let coins = coin::mint_for_testing<TST>(10_000, scenario.ctx());

		ts::next_tx(scenario, ALICE);

		let mut balance_manager = ts::take_shared<BalanceManager>(scenario);
		let mut pool = ts::take_shared<Pool<TST, SUI>>(scenario);

		slot::deposit<TST>(
			&mut balance_manager,
			&mut pool,
			coins,
			&clock,
			scenario.ctx()
		);

		clock::destroy_for_testing(clock);
		ts::return_shared(balance_manager);
		ts::return_shared(pool);
	}

	fun withdraw_test(scenario: &mut Scenario) {
		let clock = clock::create_for_testing(scenario.ctx());
		ts::next_tx(scenario, ALICE);

		let mut balance_manager = ts::take_shared<BalanceManager>(scenario);
		let mut pool = ts::take_shared<Pool<TST, SUI>>(scenario);

		slot::withdraw<TST>(
			&mut balance_manager,
			&mut pool,
			10_000,
			&clock,
			scenario.ctx()
		);

		clock::destroy_for_testing(clock);
		ts::return_shared(balance_manager);
		ts::return_shared(pool);
	}

    #[test]
    fun user_can_deposit_and_convert_to_base() {
		let mut scenario = ts::begin(OWNER);
		pool_tests::setup_everything<TST, SUI, DEEP, SUI>(&mut scenario);

		scenario.next_tx(ALICE);
		
		let mut balance_manager = ts::take_shared<BalanceManager>(&scenario);
		let sui_before = balance_manager.balance<SUI>();
		ts::return_shared(balance_manager);

		deposit_test(&mut scenario);
		scenario.next_tx(ALICE);

		balance_manager = ts::take_shared<BalanceManager>(&scenario);
		assert!(balance_manager.balance<SUI>() - sui_before == 10_000);
		ts::return_shared(balance_manager);

		ts::end(scenario);
    }

	#[test]
	fun user_can_withdraw_and_convert_to_base() {
		let mut scenario = ts::begin(OWNER);
		pool_tests::setup_everything<TST, SUI, DEEP, SUI>(&mut scenario);
		scenario.next_tx(ALICE);

		let mut balance_manager = ts::take_shared<BalanceManager>(&scenario);
		let tst_before = balance_manager.balance<TST>();
		ts::return_shared(balance_manager);

		withdraw_test(&mut scenario);
		scenario.next_tx(ALICE);
		
		balance_manager = ts::take_shared<BalanceManager>(&scenario);
		let sui_coins = ts::take_from_address<Coin<SUI>>(&scenario, ALICE);

		assert!(tst_before - balance_manager.balance<TST>() == 10_000);
		assert!(sui_coins.value() == 10_000);

		ts::return_to_address(ALICE, sui_coins);
		ts::return_shared(balance_manager);

		ts::end(scenario);
	}

	#[test]
	fun user_can_buy_tokens_for_sui() {
		let mut scenario = ts::begin(OWNER);
		pool_tests::setup_everything<TST, SUI, DEEP, SUI>(&mut scenario);
		scenario.next_tx(ALICE);

		let mut pool = ts::take_shared<Pool<TST, SUI>>(&scenario);
		let mut balance_manager = ts::take_shared<BalanceManager>(&scenario);
		let tst_before = balance_manager.balance<TST>();

		let clock = clock::create_for_testing(scenario.ctx());

		scenario.next_tx(ALICE);

		let sui_in = balance_manager.withdraw<SUI>(100_000, scenario.ctx());
		let tst_out = slot::into_base<TST, SUI>(&mut balance_manager, &mut pool, sui_in, &clock, scenario.ctx());
		balance_manager.deposit<TST>(tst_out, scenario.ctx());

		scenario.next_tx(ALICE);
		
		assert!(balance_manager.balance<TST>() - tst_before == 50_000);

		clock::destroy_for_testing(clock);
		ts::return_shared(pool);
		ts::return_shared(balance_manager);

		ts::end(scenario);
	}
	
	#[test]
	fun user_can_sell_tokens_for_sui() {
		let mut scenario = ts::begin(OWNER);
		pool_tests::setup_everything<TST, SUI, DEEP, SUI>(&mut scenario);
		scenario.next_tx(ALICE);

		let mut pool = ts::take_shared<Pool<TST, SUI>>(&scenario);
		let mut balance_manager = ts::take_shared<BalanceManager>(&scenario);
		let sui_before = balance_manager.balance<SUI>();

		let clock = clock::create_for_testing(scenario.ctx());

		scenario.next_tx(ALICE);

		let tst_in = balance_manager.withdraw<TST>(100_000, scenario.ctx());
		let sui_out = slot::into_quote<TST, SUI>(&mut balance_manager, &mut pool, tst_in, &clock, scenario.ctx());
		balance_manager.deposit<SUI>(sui_out, scenario.ctx());

		scenario.next_tx(ALICE);
		
		assert!(balance_manager.balance<SUI>() - sui_before == 100_000);

		clock::destroy_for_testing(clock);
		ts::return_shared(pool);
		ts::return_shared(balance_manager);

		ts::end(scenario);
	}
}
