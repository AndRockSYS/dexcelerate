module cetus::stable_farming {
	use cetus_stable_farming::config;
	use cetus_stable_farming::pool;

    public entry fun collect_clmm_reward<T0, T1, T2>(arg0: &config::GlobalConfig, arg1: &cetus_clmm::config::GlobalConfig, arg2: &mut cetus_clmm::pool::Pool<T1, T2>, arg3: &pool::WrappedPositionNFT, arg4: &mut cetus_clmm::rewarder::RewarderGlobalVault, arg5: &mut 0x2::coin::Coin<T0>, arg6: &0x2::clock::Clock, arg7: &mut 0x2::tx_context::TxContext) {
		abort 0
	}
    
    public entry fun collect_fee<T0, T1>(arg0: &config::GlobalConfig, arg1: &cetus_clmm::config::GlobalConfig, arg2: &mut cetus_clmm::pool::Pool<T0, T1>, arg3: &pool::WrappedPositionNFT, arg4: &mut 0x2::coin::Coin<T0>, arg5: &mut 0x2::coin::Coin<T1>, arg6: &mut 0x2::tx_context::TxContext) {
		abort 0
    }

}