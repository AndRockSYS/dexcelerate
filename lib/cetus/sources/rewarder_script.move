module cetus::rewarder_script {
    public entry fun deposit_reward<T0>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::rewarder::RewarderGlobalVault, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun emergent_withdraw<T0>(arg0: &cetus_clmm::config::AdminCap, arg1: &cetus_clmm::config::GlobalConfig, arg2: &mut cetus_clmm::rewarder::RewarderGlobalVault, arg3: u64, arg4: address, arg5: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun emergent_withdraw_all<T0>(arg0: &cetus_clmm::config::AdminCap, arg1: &cetus_clmm::config::GlobalConfig, arg2: &mut cetus_clmm::rewarder::RewarderGlobalVault, arg3: address, arg4: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
}