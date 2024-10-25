module cetus::pool_script_v3 {
    public fun collect_fee<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: &mut 0x2::coin::Coin<T0>, arg4: &mut 0x2::coin::Coin<T1>, arg5: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public fun collect_reward<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::position::Position, arg3: &mut cetus_clmm::rewarder::RewarderGlobalVault, arg4: &mut 0x2::coin::Coin<T2>, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
}

