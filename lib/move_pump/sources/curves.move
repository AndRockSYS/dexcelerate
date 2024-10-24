module move_pump::curves {
    public fun calculate_add_liquidity_cost(arg0: u64, arg1: u64, arg2: u64) : u64 {
        let v0 = move_pump::utils::as_u64(move_pump::utils::sub(move_pump::utils::from_u64(arg1), move_pump::utils::from_u64(arg2)));
        assert!(v0 > 0, 100);
        move_pump::utils::as_u64(move_pump::utils::sub(move_pump::utils::from_u64(move_pump::utils::as_u64(move_pump::utils::div(move_pump::utils::mul(move_pump::utils::from_u64(arg0), move_pump::utils::from_u64(arg1)), move_pump::utils::from_u64(v0)))), move_pump::utils::from_u64(arg0)))
    }
    
    public fun calculate_remove_liquidity_return(arg0: u64, arg1: u64, arg2: u64) : u64 {
        move_pump::utils::as_u64(move_pump::utils::sub(move_pump::utils::from_u64(arg1), move_pump::utils::from_u64(move_pump::utils::as_u64(move_pump::utils::div(move_pump::utils::mul(move_pump::utils::from_u64(arg1), move_pump::utils::from_u64(arg0)), move_pump::utils::from_u64(move_pump::utils::as_u64(move_pump::utils::add(move_pump::utils::from_u64(arg0), move_pump::utils::from_u64(arg2)))))))))
    }
    
    public fun calculate_token_amount_received(arg0: u64, arg1: u64, arg2: u64) : u64 {
        move_pump::utils::as_u64(move_pump::utils::sub(move_pump::utils::from_u64(arg1), move_pump::utils::from_u64(move_pump::utils::as_u64(move_pump::utils::div(move_pump::utils::mul(move_pump::utils::from_u64(arg0), move_pump::utils::from_u64(arg1)), move_pump::utils::from_u64(move_pump::utils::as_u64(move_pump::utils::add(move_pump::utils::from_u64(arg0), move_pump::utils::from_u64(arg2)))))))))
    }
}