module flowx_clmm::swap_math {
    use flowx_clmm::constants;
    use flowx_clmm::full_math_u64;
    use flowx_clmm::sqrt_price_math;
    
    #[allow(unused_assignment)]
    public fun compute_swap_step(
        sqrt_ratio_current: u128,
        sqrt_ratio_target: u128,
        liquidity: u128,
        amount_remaining: u64,
        fee_rate: u64,
        exact_in: bool
    ): (u128, u64, u64, u64) {
		abort 0
    }
}