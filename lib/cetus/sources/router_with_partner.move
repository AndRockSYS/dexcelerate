module cetus::router_with_partner {
    public fun swap_ab_bc_with_partner<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::pool::Pool<T1, T2>, arg3: &mut cetus_clmm::partner::Partner, arg4: 0x2::coin::Coin<T0>, arg5: 0x2::coin::Coin<T2>, arg6: bool, arg7: u64, arg8: u64, arg9: u128, arg10: u128, arg11: &0x2::clock::Clock, arg12: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T2>) {
		abort 0
    }
    
    public fun swap_ab_cb_with_partner<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::pool::Pool<T2, T1>, arg3: &mut cetus_clmm::partner::Partner, arg4: 0x2::coin::Coin<T0>, arg5: 0x2::coin::Coin<T2>, arg6: bool, arg7: u64, arg8: u64, arg9: u128, arg10: u128, arg11: &0x2::clock::Clock, arg12: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T2>) {
		abort 0
    }
    
    public fun swap_ba_bc_with_partner<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T1, T0>, arg2: &mut cetus_clmm::pool::Pool<T1, T2>, arg3: &mut cetus_clmm::partner::Partner, arg4: 0x2::coin::Coin<T0>, arg5: 0x2::coin::Coin<T2>, arg6: bool, arg7: u64, arg8: u64, arg9: u128, arg10: u128, arg11: &0x2::clock::Clock, arg12: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T2>) {
		abort 0
    }
    
    public fun swap_ba_cb_with_partner<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T1, T0>, arg2: &mut cetus_clmm::pool::Pool<T2, T1>, arg3: &mut cetus_clmm::partner::Partner, arg4: 0x2::coin::Coin<T0>, arg5: 0x2::coin::Coin<T2>, arg6: bool, arg7: u64, arg8: u64, arg9: u128, arg10: u128, arg11: &0x2::clock::Clock, arg12: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T2>) {
		abort 0
    }
    
    public fun swap_with_partner<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::partner::Partner, arg3: 0x2::coin::Coin<T0>, arg4: 0x2::coin::Coin<T1>, arg5: bool, arg6: bool, arg7: u64, arg8: u128, arg9: bool, arg10: &0x2::clock::Clock, arg11: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
		abort 0
    }
}