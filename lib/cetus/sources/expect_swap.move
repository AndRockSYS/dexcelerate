module cetus::expect_swap {
    public struct ExpectSwapResult has copy, drop, store {
        amount_in: u256,
        amount_out: u256,
        fee_amount: u256,
        fee_rate: u64,
        after_sqrt_price: u128,
        is_exceed: bool,
        step_results: vector<SwapStepResult>,
    }
    
    public struct SwapStepResult has copy, drop, store {
        current_sqrt_price: u128,
        target_sqrt_price: u128,
        current_liquidity: u128,
        amount_in: u256,
        amount_out: u256,
        fee_amount: u256,
        remainder_amount: u64,
    }
    
    public struct SwapResult has copy, drop {
        amount_in: u256,
        amount_out: u256,
        fee_amount: u256,
        ref_fee_amount: u256,
        steps: u64,
    }
    
    public struct ExpectSwapResultEvent has copy, drop, store {
        data: ExpectSwapResult,
        current_sqrt_price: u128,
    }
    
    public fun expect_swap<T0, T1>(arg0: &cetus_clmm::pool::Pool<T0, T1>, arg1: bool, arg2: bool, arg3: u64) : ExpectSwapResult {
		abort 0
    }
    
    fun check_remainer_amount_sub(arg0: u64, arg1: u64) : u64 {
		abort 0
    }
    
    public fun compute_swap_step(arg0: u128, arg1: u128, arg2: u128, arg3: u64, arg4: u64, arg5: bool, arg6: bool) : (u256, u256, u128, u256) {
        abort 0
    }
    
    fun default_swap_result() : SwapResult {
		abort 0
    }
    
    public fun expect_swap_result_after_sqrt_price(arg0: &ExpectSwapResult) : u128 {
		abort 0
    }
    
    public fun expect_swap_result_amount_in(arg0: &ExpectSwapResult) : u256 {
		abort 0
    }
    
    public fun expect_swap_result_amount_out(arg0: &ExpectSwapResult) : u256 {
		abort 0
    }
    
    public fun expect_swap_result_fee_amount(arg0: &ExpectSwapResult) : u256 {
		abort 0
    }
    
    public fun expect_swap_result_is_exceed(arg0: &ExpectSwapResult) : bool {
		abort 0
    }
    
    public fun expect_swap_result_step_results(arg0: &ExpectSwapResult) : &vector<SwapStepResult> {
		abort 0
    }
    
    public fun expect_swap_result_step_swap_result(arg0: &ExpectSwapResult, arg1: u64) : &SwapStepResult {
		abort 0
    }
    
    public fun expect_swap_result_steps_length(arg0: &ExpectSwapResult) : u64 {
		abort 0
    }
    
    public entry fun get_expect_swap_result<T0, T1>(arg0: &cetus_clmm::pool::Pool<T0, T1>, arg1: bool, arg2: bool, arg3: u64) {
		abort 0
    }
    
    public fun step_swap_result_amount_in(arg0: &SwapStepResult) : u256 {
		abort 0
    }
    
    public fun step_swap_result_amount_out(arg0: &SwapStepResult) : u256 {
		abort 0
    }
    
    public fun step_swap_result_current_liquidity(arg0: &SwapStepResult) : u128 {
		abort 0
    }
    
    public fun step_swap_result_current_sqrt_price(arg0: &SwapStepResult) : u128 {
		abort 0
    }
    
    public fun step_swap_result_fee_amount(arg0: &SwapStepResult) : u256 {
		abort 0
    }
    
    public fun step_swap_result_remainder_amount(arg0: &SwapStepResult) : u64 {
		abort 0
    }
    
    public fun step_swap_result_target_sqrt_price(arg0: &SwapStepResult) : u128 {
		abort 0
    }
    
    fun update_swap_result(arg0: &mut SwapResult, arg1: u256, arg2: u256, arg3: u256) {
        abort 0
    }
}