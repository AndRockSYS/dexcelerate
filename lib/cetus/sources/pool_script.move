module cetus::pool_script {
    fun swap<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: vector<0x2::coin::Coin<T0>>, arg3: vector<0x2::coin::Coin<T1>>, arg4: bool, arg5: bool, arg6: u64, arg7: u64, arg8: u128, arg9: &0x2::clock::Clock, arg10: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun create_pool<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::factory::Pools, arg2: u32, arg3: u128, arg4: 0x1::string::String, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun close_position<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: cetus_clmm::position::Position, arg3: u64, arg4: u64, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun collect_fee<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun collect_protocol_fee<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun collect_reward<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: &mut cetus_clmm::rewarder::RewarderGlobalVault, arg4: &0x2::clock::Clock, arg5: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun initialize_rewarder<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun open_position<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: u32, arg3: u32, arg4: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun remove_liquidity<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: u128, arg4: u64, arg5: u64, arg6: &0x2::clock::Clock, arg7: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    fun repay_add_liquidity<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: cetus_clmm::pool::AddLiquidityReceipt<T0, T1>, arg3: vector<0x2::coin::Coin<T0>>, arg4: vector<0x2::coin::Coin<T1>>, arg5: u64, arg6: u64, arg7: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun set_display<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &0x2::package::Publisher, arg2: 0x1::string::String, arg3: 0x1::string::String, arg4: 0x1::string::String, arg5: 0x1::string::String, arg6: 0x1::string::String, arg7: 0x1::string::String, arg8: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun update_fee_rate<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: u64, arg3: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun update_position_url<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: 0x1::string::String, arg3: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun add_liquidity_fix_coin_only_a<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: vector<0x2::coin::Coin<T0>>, arg4: u64, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun add_liquidity_fix_coin_only_b<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: vector<0x2::coin::Coin<T1>>, arg4: u64, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun add_liquidity_fix_coin_with_all<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: vector<0x2::coin::Coin<T0>>, arg4: vector<0x2::coin::Coin<T1>>, arg5: u64, arg6: u64, arg7: bool, arg8: &0x2::clock::Clock, arg9: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun add_liquidity_only_a<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: vector<0x2::coin::Coin<T0>>, arg4: u64, arg5: u128, arg6: &0x2::clock::Clock, arg7: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun add_liquidity_only_b<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: vector<0x2::coin::Coin<T1>>, arg4: u64, arg5: u128, arg6: &0x2::clock::Clock, arg7: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun add_liquidity_with_all<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: vector<0x2::coin::Coin<T0>>, arg4: vector<0x2::coin::Coin<T1>>, arg5: u64, arg6: u64, arg7: u128, arg8: &0x2::clock::Clock, arg9: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun create_pool_with_liquidity_only_a<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::factory::Pools, arg2: u32, arg3: u128, arg4: 0x1::string::String, arg5: vector<0x2::coin::Coin<T0>>, arg6: u32, arg7: u32, arg8: u64, arg9: &0x2::clock::Clock, arg10: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun create_pool_with_liquidity_only_b<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::factory::Pools, arg2: u32, arg3: u128, arg4: 0x1::string::String, arg5: vector<0x2::coin::Coin<T1>>, arg6: u32, arg7: u32, arg8: u64, arg9: &0x2::clock::Clock, arg10: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun create_pool_with_liquidity_with_all<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::factory::Pools, arg2: u32, arg3: u128, arg4: 0x1::string::String, arg5: vector<0x2::coin::Coin<T0>>, arg6: vector<0x2::coin::Coin<T1>>, arg7: u32, arg8: u32, arg9: u64, arg10: u64, arg11: bool, arg12: &0x2::clock::Clock, arg13: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun open_position_with_liquidity_only_a<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: u32, arg3: u32, arg4: vector<0x2::coin::Coin<T0>>, arg5: u64, arg6: &0x2::clock::Clock, arg7: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun open_position_with_liquidity_only_b<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: u32, arg3: u32, arg4: vector<0x2::coin::Coin<T1>>, arg5: u64, arg6: &0x2::clock::Clock, arg7: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun open_position_with_liquidity_with_all<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: u32, arg3: u32, arg4: vector<0x2::coin::Coin<T0>>, arg5: vector<0x2::coin::Coin<T1>>, arg6: u64, arg7: u64, arg8: bool, arg9: &0x2::clock::Clock, arg10: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun pause_pool<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun swap_a2b<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: vector<0x2::coin::Coin<T0>>, arg3: bool, arg4: u64, arg5: u64, arg6: u128, arg7: &0x2::clock::Clock, arg8: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun swap_a2b_with_partner<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::partner::Partner, arg3: vector<0x2::coin::Coin<T0>>, arg4: bool, arg5: u64, arg6: u64, arg7: u128, arg8: &0x2::clock::Clock, arg9: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun swap_b2a<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: vector<0x2::coin::Coin<T1>>, arg3: bool, arg4: u64, arg5: u64, arg6: u128, arg7: &0x2::clock::Clock, arg8: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun swap_b2a_with_partner<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::partner::Partner, arg3: vector<0x2::coin::Coin<T1>>, arg4: bool, arg5: u64, arg6: u64, arg7: u128, arg8: &0x2::clock::Clock, arg9: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    fun swap_with_partner<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::partner::Partner, arg3: vector<0x2::coin::Coin<T0>>, arg4: vector<0x2::coin::Coin<T1>>, arg5: bool, arg6: bool, arg7: u64, arg8: u64, arg9: u128, arg10: &0x2::clock::Clock, arg11: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun unpause_pool<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun update_rewarder_emission<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &cetus_clmm::rewarder::RewarderGlobalVault, arg3: u128, arg4: &0x2::clock::Clock, arg5: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
}