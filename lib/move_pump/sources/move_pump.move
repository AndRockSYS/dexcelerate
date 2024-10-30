module move_pump::move_pump {
    public struct Configuration has store, key {
        id: 0x2::object::UID,
        version: u64,
        admin: address,
        platform_fee: u64,
        graduated_fee: u64,
        initial_virtual_sui_reserves: u64,
        initial_virtual_token_reserves: u64,
        remain_token_reserves: u64,
        token_decimals: u8,
    }
    
    public struct Pool<phantom T0> has store, key {
        id: 0x2::object::UID,
        real_sui_reserves: 0x2::coin::Coin<0x2::sui::SUI>,
        real_token_reserves: 0x2::coin::Coin<T0>,
        virtual_token_reserves: u64,
        virtual_sui_reserves: u64,
        remain_token_reserves: 0x2::coin::Coin<T0>,
        is_completed: bool,
    }
    
    public struct ConfigChangedEvent has copy, drop, store {
        old_platform_fee: u64,
        new_platform_fee: u64,
        old_graduated_fee: u64,
        new_graduated_fee: u64,
        old_initial_virtual_sui_reserves: u64,
        new_initial_virtual_sui_reserves: u64,
        old_initial_virtual_token_reserves: u64,
        new_initial_virtual_token_reserves: u64,
        old_remain_token_reserves: u64,
        new_remain_token_reserves: u64,
        old_token_decimals: u8,
        new_token_decimals: u8,
        ts: u64,
    }
    
    public struct CreatedEvent has copy, drop, store {
        name: 0x1::ascii::String,
        symbol: 0x1::ascii::String,
        uri: 0x1::ascii::String,
        description: 0x1::ascii::String,
        twitter: 0x1::ascii::String,
        telegram: 0x1::ascii::String,
        website: 0x1::ascii::String,
        token_address: 0x1::ascii::String,
        bonding_curve: 0x1::ascii::String,
        pool_id: 0x2::object::ID,
        created_by: address,
        virtual_sui_reserves: u64,
        virtual_token_reserves: u64,
        ts: u64,
    }
    
    public struct OwnershipTransferredEvent has copy, drop, store {
        old_admin: address,
        new_admin: address,
        ts: u64,
    }
    
    public struct PoolCompletedEvent has copy, drop, store {
        token_address: 0x1::ascii::String,
        lp: 0x1::ascii::String,
        ts: u64,
    }
    
    public struct TradedEvent has copy, drop, store {
        is_buy: bool,
        user: address,
        token_address: 0x1::ascii::String,
        sui_amount: u64,
        token_amount: u64,
        virtual_sui_reserves: u64,
        virtual_token_reserves: u64,
        pool_id: 0x2::object::ID,
        ts: u64,
    }
    
    fun swap<T0>(arg0: &mut Pool<T0>, arg1: 0x2::coin::Coin<T0>, arg2: 0x2::coin::Coin<0x2::sui::SUI>, arg3: u64, arg4: u64, arg5: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<0x2::sui::SUI>) {
		abort 0
    }
    
    public fun asert_pool_not_completed<T0>(arg0: &Configuration, arg1: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    fun assert_lp_value_is_increased_or_not_changed(arg0: u64, arg1: u64, arg2: u64, arg3: u64) {
		abort 0
    }
    
    fun assert_version(arg0: u64) {
		abort 0
    }
    
    public entry fun buy<T0>(arg0: &mut Configuration, arg1: 0x2::coin::Coin<0x2::sui::SUI>, arg2: &mut blue_move::swap::Dex_Info, arg3: u64, arg4: &0x2::clock::Clock, arg5: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public fun buy_returns<T0>(arg0: &mut Configuration, arg1: 0x2::coin::Coin<0x2::sui::SUI>, arg2: &mut blue_move::swap::Dex_Info, arg3: u64, arg4: &0x2::clock::Clock, arg5: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<0x2::sui::SUI>, 0x2::coin::Coin<T0>) {
		abort 0
    }
    
    public entry fun create<T0>(arg0: &mut Configuration, arg1: 0x2::coin::TreasuryCap<T0>, arg2: &0x2::clock::Clock, arg3: 0x1::ascii::String, arg4: 0x1::ascii::String, arg5: 0x1::ascii::String, arg6: 0x1::ascii::String, arg7: 0x1::ascii::String, arg8: 0x1::ascii::String, arg9: 0x1::ascii::String, arg10: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    fun init(arg0: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun migrate_version(arg0: &mut Configuration, arg1: u64, arg2: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun sell<T0>(arg0: &mut Configuration, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &0x2::clock::Clock, arg4: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public fun sell_returns<T0>(arg0: &mut Configuration, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &0x2::clock::Clock, arg4: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<0x2::sui::SUI>, 0x2::coin::Coin<T0>) {
		abort 0
    }
    
    public fun skim<T0>(arg0: &mut Configuration, arg1: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun transfer_admin(arg0: &mut Configuration, arg1: address, arg2: &0x2::clock::Clock, arg3: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    fun transfer_pool<T0>(arg0: &mut Pool<T0>, arg1: &mut blue_move::swap::Dex_Info, arg2: address, arg3: u64, arg4: &0x2::clock::Clock, arg5: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun update_config(arg0: &mut Configuration, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u8, arg7: &0x2::clock::Clock, arg8: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
}