module cetus::router {
    public struct CalculatedRouterSwapResult has copy, drop, store {
        amount_in: u64,
        amount_medium: u64,
        amount_out: u64,
        is_exceed: bool,
        current_sqrt_price_ab: u128,
        current_sqrt_price_cd: u128,
        target_sqrt_price_ab: u128,
        target_sqrt_price_cd: u128,
    }
    
    public struct CalculatedRouterSwapResultEvent has copy, drop, store {
        data: CalculatedRouterSwapResult,
    }
    
    public fun swap<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: 0x2::coin::Coin<T0>, arg3: 0x2::coin::Coin<T1>, arg4: bool, arg5: bool, arg6: u64, arg7: u128, arg8: bool, arg9: &0x2::clock::Clock, arg10: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
		abort 0
    }
    
    public fun calculate_router_swap_result<T0, T1, T2, T3>(arg0: &mut cetus_clmm::pool::Pool<T0, T1>, arg1: &mut cetus_clmm::pool::Pool<T2, T3>, arg2: bool, arg3: bool, arg4: bool, arg5: u64) {
		abort 0
    }
    
    public fun check_coin_threshold<T0>(arg0: &0x2::coin::Coin<T0>, arg1: u64) {
		abort 0
    }
    
    public fun swap_ab_bc<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::pool::Pool<T1, T2>, arg3: 0x2::coin::Coin<T0>, arg4: 0x2::coin::Coin<T2>, arg5: bool, arg6: u64, arg7: u64, arg8: u128, arg9: u128, arg10: &0x2::clock::Clock, arg11: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T2>) {
		abort 0
    }
    
    public fun swap_ab_cb<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: &mut cetus_clmm::pool::Pool<T2, T1>, arg3: 0x2::coin::Coin<T0>, arg4: 0x2::coin::Coin<T2>, arg5: bool, arg6: u64, arg7: u64, arg8: u128, arg9: u128, arg10: &0x2::clock::Clock, arg11: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T2>) {
		abort 0
    }
    
    public fun swap_ba_bc<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T1, T0>, arg2: &mut cetus_clmm::pool::Pool<T1, T2>, arg3: 0x2::coin::Coin<T0>, arg4: 0x2::coin::Coin<T2>, arg5: bool, arg6: u64, arg7: u64, arg8: u128, arg9: u128, arg10: &0x2::clock::Clock, arg11: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T2>) {
		abort 0
    }
    
    public fun swap_ba_cb<T0, T1, T2>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T1, T0>, arg2: &mut cetus_clmm::pool::Pool<T2, T1>, arg3: 0x2::coin::Coin<T0>, arg4: 0x2::coin::Coin<T2>, arg5: bool, arg6: u64, arg7: u64, arg8: u128, arg9: u128, arg10: &0x2::clock::Clock, arg11: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T2>) {
		abort 0
    }
}