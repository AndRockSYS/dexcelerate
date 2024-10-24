module blue_move::router {
    public entry fun add_liquidity<T0, T1>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: 0x2::coin::Coin<T1>, arg4: u64, arg5: u64, arg6: &mut blue_move::swap::Dex_Info, arg7: &mut 0x2::tx_context::TxContext) {
        let v0 = blue_move::swap::check_pool_exist<T0, T1>(arg6) || blue_move::swap::check_pool_exist<T1, T0>(arg6);
        if (!v0) {
            blue_move::swap::create_new_pool<T0, T1>(arg6, arg7);
        };
        if (blue_move::utils::sort_token_type<T0, T1>()) {
            let (v1, v2, _) = blue_move::swap::add_liquidity<T0, T1>(arg0, arg2, arg1, arg3, blue_move::swap::get_pool<T0, T1>(arg6), arg7);
            assert!(v1 >= arg4, 2);
            assert!(v2 >= arg5, 3);
        } else {
            let (v4, v5, _) = blue_move::swap::add_liquidity<T1, T0>(arg2, arg0, arg3, arg1, blue_move::swap::get_pool<T1, T0>(arg6), arg7);
            assert!(v5 >= arg4, 2);
            assert!(v4 >= arg5, 3);
        };
    }
    
    public entry fun remove_liquidity<T0, T1>(arg0: u64, arg1: 0x2::coin::Coin<blue_move::swap::LSP<T0, T1>>, arg2: u64, arg3: u64, arg4: &mut blue_move::swap::Dex_Info, arg5: &mut 0x2::tx_context::TxContext) {
        let (v0, v1) = blue_move::swap::remove_liquidity<T0, T1>(arg0, arg1, blue_move::swap::get_pool<T0, T1>(arg4), arg5);
        assert!(v0 >= arg2, 2);
        assert!(v1 >= arg3, 3);
    }
    
    fun get_intermediate_output<T0, T1>(arg0: bool, arg1: 0x2::coin::Coin<T0>, arg2: &mut blue_move::swap::Dex_Info, arg3: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T1> {
        if (arg0) {
            let (v1, v2) = blue_move::swap::swap_exact_x_to_y_direct<T0, T1>(arg1, blue_move::swap::get_pool<T0, T1>(arg2), arg3);
            0x2::coin::destroy_zero<T0>(v1);
            v2
        } else {
            let (v3, v4) = blue_move::swap::swap_exact_y_to_x_direct<T1, T0>(arg1, blue_move::swap::get_pool<T1, T0>(arg2), arg3);
            0x2::coin::destroy_zero<T0>(v4);
            v3
        }
    }
    
    fun get_intermediate_output_x_to_exact_y<T0, T1>(arg0: bool, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T1> {
        if (arg0) {
            let (v1, v2) = blue_move::swap::swap_x_to_exact_y_direct<T0, T1>(arg1, arg2, blue_move::swap::get_pool<T0, T1>(arg3), arg4);
            0x2::coin::destroy_zero<T0>(v1);
            v2
        } else {
            let (v3, v4) = blue_move::swap::swap_y_to_exact_x_direct<T1, T0>(arg1, arg2, blue_move::swap::get_pool<T1, T0>(arg3), arg4);
            0x2::coin::destroy_zero<T0>(v4);
            v3
        }
    }
    
    public entry fun swap_exact_input<T0, T1>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) {
        let v0 = 0x2::tx_context::sender(arg4);
        let (v1, v2) = if (blue_move::utils::sort_token_type<T0, T1>()) {
            let (v3, v4) = blue_move::swap::swap_exact_x_to_y<T0, T1>(arg0, arg1, v0, blue_move::swap::get_pool<T0, T1>(arg3), arg4);
            (v3, v4)
        } else {
            let (v5, v6) = blue_move::swap::swap_exact_y_to_x<T1, T0>(arg0, arg1, blue_move::swap::get_pool<T1, T0>(arg3), v0, arg4);
            (v5, v6)
        };
        assert!(v1 >= arg2, 0);
        0x2::transfer::public_transfer<0x2::coin::Coin<T1>>(v2, v0);
        blue_move::swap::add_swap_event_internal<T0, T1>(arg0, 0, 0, v1, arg3, arg4);
    }
    
    public fun swap_exact_input_<T0, T1>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T1> {
        let (v0, v1) = if (blue_move::utils::sort_token_type<T0, T1>()) {
            let (v2, v3) = blue_move::swap::swap_exact_x_to_y<T0, T1>(arg0, arg1, 0x2::tx_context::sender(arg4), blue_move::swap::get_pool<T0, T1>(arg3), arg4);
            (v2, v3)
        } else {
            let (v4, v5) = blue_move::swap::swap_exact_y_to_x<T1, T0>(arg0, arg1, blue_move::swap::get_pool<T1, T0>(arg3), 0x2::tx_context::sender(arg4), arg4);
            (v4, v5)
        };
        assert!(v0 >= arg2, 0);
        blue_move::swap::add_swap_event_internal<T0, T1>(arg0, 0, 0, v0, arg3, arg4);
        v1
    }
    
    fun swap_exact_input_double_internal<T0, T1, T2>(arg0: bool, arg1: bool, arg2: u64, arg3: 0x2::coin::Coin<T0>, arg4: u64, arg5: &mut blue_move::swap::Dex_Info, arg6: &mut 0x2::tx_context::TxContext) : (u64, 0x2::coin::Coin<T2>) {
        let v0 = get_intermediate_output<T0, T1>(arg0, arg3, arg5, arg6);
        let v1 = 0x2::coin::value<T1>(&v0);
        let v2 = get_intermediate_output<T1, T2>(arg1, v0, arg5, arg6);
        let v3 = 0x2::coin::value<T2>(&v2);
        assert!(v3 >= arg4, 0);
        blue_move::swap::add_swap_event_internal<T0, T1>(arg2, 0, 0, v1, arg5, arg6);
        blue_move::swap::add_swap_event_internal<T1, T2>(v1, 0, 0, v3, arg5, arg6);
        (v3, v2)
    }
    
    public entry fun swap_exact_input_doublehop<T0, T1, T2>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) {
        blue_move::swap::assert_input_amount<T0>(arg0, &arg1);
        let (_, v1) = swap_exact_input_double_internal<T0, T1, T2>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), arg0, arg1, arg2, arg3, arg4);
        0x2::transfer::public_transfer<0x2::coin::Coin<T2>>(v1, 0x2::tx_context::sender(arg4));
    }
    
    public fun swap_exact_input_doublehop_<T0, T1, T2>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T2> {
        blue_move::swap::assert_input_amount<T0>(arg0, &arg1);
        let (_, v1) = swap_exact_input_double_internal<T0, T1, T2>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), arg0, arg1, arg2, arg3, arg4);
        v1
    }
    
    fun swap_exact_input_quadruple_internal<T0, T1, T2, T3, T4>(arg0: bool, arg1: bool, arg2: bool, arg3: bool, arg4: u64, arg5: 0x2::coin::Coin<T0>, arg6: u64, arg7: &mut blue_move::swap::Dex_Info, arg8: &mut 0x2::tx_context::TxContext) : (u64, 0x2::coin::Coin<T4>) {
        let v0 = get_intermediate_output<T0, T1>(arg0, arg5, arg7, arg8);
        let v1 = 0x2::coin::value<T1>(&v0);
        let v2 = get_intermediate_output<T1, T2>(arg1, v0, arg7, arg8);
        let v3 = 0x2::coin::value<T2>(&v2);
        let v4 = get_intermediate_output<T2, T3>(arg2, v2, arg7, arg8);
        let v5 = 0x2::coin::value<T3>(&v4);
        let v6 = get_intermediate_output<T3, T4>(arg3, v4, arg7, arg8);
        let v7 = 0x2::coin::value<T4>(&v6);
        assert!(v7 >= arg6, 0);
        blue_move::swap::add_swap_event_internal<T0, T1>(arg4, 0, 0, v1, arg7, arg8);
        blue_move::swap::add_swap_event_internal<T1, T2>(v1, 0, 0, v3, arg7, arg8);
        blue_move::swap::add_swap_event_internal<T2, T3>(v3, 0, 0, v5, arg7, arg8);
        blue_move::swap::add_swap_event_internal<T3, T4>(v5, 0, 0, v7, arg7, arg8);
        (v7, v6)
    }
    
    public entry fun swap_exact_input_quadruplehop<T0, T1, T2, T3, T4>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) {
        blue_move::swap::assert_input_amount<T0>(arg0, &arg1);
        let (_, v1) = swap_exact_input_quadruple_internal<T0, T1, T2, T3, T4>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), blue_move::utils::sort_token_type<T2, T3>(), blue_move::utils::sort_token_type<T3, T4>(), arg0, arg1, arg2, arg3, arg4);
        0x2::transfer::public_transfer<0x2::coin::Coin<T4>>(v1, 0x2::tx_context::sender(arg4));
    }
    
    public fun swap_exact_input_quadruplehop_<T0, T1, T2, T3, T4>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T4> {
        blue_move::swap::assert_input_amount<T0>(arg0, &arg1);
        let (_, v1) = swap_exact_input_quadruple_internal<T0, T1, T2, T3, T4>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), blue_move::utils::sort_token_type<T2, T3>(), blue_move::utils::sort_token_type<T3, T4>(), arg0, arg1, arg2, arg3, arg4);
        v1
    }
    
    fun swap_exact_input_triple_internal<T0, T1, T2, T3>(arg0: bool, arg1: bool, arg2: bool, arg3: u64, arg4: 0x2::coin::Coin<T0>, arg5: u64, arg6: &mut blue_move::swap::Dex_Info, arg7: &mut 0x2::tx_context::TxContext) : (u64, 0x2::coin::Coin<T3>) {
        let v0 = get_intermediate_output<T0, T1>(arg0, arg4, arg6, arg7);
        let v1 = 0x2::coin::value<T1>(&v0);
        let v2 = get_intermediate_output<T1, T2>(arg1, v0, arg6, arg7);
        let v3 = 0x2::coin::value<T2>(&v2);
        let v4 = get_intermediate_output<T2, T3>(arg2, v2, arg6, arg7);
        let v5 = 0x2::coin::value<T3>(&v4);
        assert!(v5 >= arg5, 0);
        blue_move::swap::add_swap_event_internal<T0, T1>(arg3, 0, 0, v1, arg6, arg7);
        blue_move::swap::add_swap_event_internal<T1, T2>(v1, 0, 0, v3, arg6, arg7);
        blue_move::swap::add_swap_event_internal<T2, T3>(v3, 0, 0, v5, arg6, arg7);
        (v5, v4)
    }
    
    public entry fun swap_exact_input_triplehop<T0, T1, T2, T3>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) {
        blue_move::swap::assert_input_amount<T0>(arg0, &arg1);
        let (_, v1) = swap_exact_input_triple_internal<T0, T1, T2, T3>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), blue_move::utils::sort_token_type<T2, T3>(), arg0, arg1, arg2, arg3, arg4);
        0x2::transfer::public_transfer<0x2::coin::Coin<T3>>(v1, 0x2::tx_context::sender(arg4));
    }
    
    public fun swap_exact_input_triplehop_<T0, T1, T2, T3>(arg0: u64, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T3> {
        blue_move::swap::assert_input_amount<T0>(arg0, &arg1);
        let (_, v1) = swap_exact_input_triple_internal<T0, T1, T2, T3>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), blue_move::utils::sort_token_type<T2, T3>(), arg0, arg1, arg2, arg3, arg4);
        v1
    }
    
    public entry fun swap_exact_output<T0, T1>(arg0: u64, arg1: u64, arg2: 0x2::coin::Coin<T0>, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) {
        let v0 = 0x2::tx_context::sender(arg4);
        let (v1, v2) = if (blue_move::utils::sort_token_type<T0, T1>()) {
            let v3 = blue_move::swap::get_pool<T0, T1>(arg3);
            let (v4, v5) = blue_move::swap::token_reserves<T0, T1>(v3);
            let v6 = blue_move::utils::get_amount_in(arg0 + arg0 * 10 / 10000, v4, v5);
            0x2::pay::keep<T0>(arg2, arg4);
            let (v7, v8) = blue_move::swap::swap_x_to_exact_y<T0, T1>(v6, 0x2::coin::split<T0>(&mut arg2, v6, arg4), arg0, v0, v3, arg4);
            (v7, v8)
        } else {
            let v9 = blue_move::swap::get_pool<T1, T0>(arg3);
            let (v10, v11) = blue_move::swap::token_reserves<T1, T0>(v9);
            let v12 = blue_move::utils::get_amount_in(arg0 + arg0 * 10 / 10000, v11, v10);
            0x2::pay::keep<T0>(arg2, arg4);
            let (v13, v14) = blue_move::swap::swap_y_to_exact_x<T1, T0>(v12, 0x2::coin::split<T0>(&mut arg2, v12, arg4), arg0, v0, v9, arg4);
            (v13, v14)
        };
        assert!(v1 <= arg1, 1);
        0x2::transfer::public_transfer<0x2::coin::Coin<T1>>(v2, v0);
        blue_move::swap::add_swap_event_internal<T0, T1>(v1, 0, 0, arg0, arg3, arg4);
    }
    
    public fun swap_exact_output_<T0, T1>(arg0: u64, arg1: u64, arg2: 0x2::coin::Coin<T0>, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T1> {
        let (v0, v1) = if (blue_move::utils::sort_token_type<T0, T1>()) {
            let v2 = blue_move::swap::get_pool<T0, T1>(arg3);
            let (v3, v4) = blue_move::swap::token_reserves<T0, T1>(v2);
            let v5 = blue_move::utils::get_amount_in(arg0 + arg0 * 10 / 10000, v3, v4);
            0x2::pay::keep<T0>(arg2, arg4);
            let (v6, v7) = blue_move::swap::swap_x_to_exact_y<T0, T1>(v5, 0x2::coin::split<T0>(&mut arg2, v5, arg4), arg0, 0x2::tx_context::sender(arg4), v2, arg4);
            (v6, v7)
        } else {
            let v8 = blue_move::swap::get_pool<T1, T0>(arg3);
            let (v9, v10) = blue_move::swap::token_reserves<T1, T0>(v8);
            let v11 = blue_move::utils::get_amount_in(arg0 + arg0 * 10 / 10000, v10, v9);
            0x2::pay::keep<T0>(arg2, arg4);
            let (v12, v13) = blue_move::swap::swap_y_to_exact_x<T1, T0>(v11, 0x2::coin::split<T0>(&mut arg2, v11, arg4), arg0, 0x2::tx_context::sender(arg4), v8, arg4);
            (v12, v13)
        };
        assert!(v0 <= arg1, 1);
        blue_move::swap::add_swap_event_internal<T0, T1>(v0, 0, 0, arg0, arg3, arg4);
        v1
    }
    
    fun swap_exact_output_double_internal<T0, T1, T2>(arg0: bool, arg1: bool, arg2: u64, arg3: 0x2::coin::Coin<T0>, arg4: u64, arg5: &mut blue_move::swap::Dex_Info, arg6: &mut 0x2::tx_context::TxContext) : (u64, 0x2::coin::Coin<T2>) {
        let v0 = if (arg1) {
            let (v1, v2) = blue_move::swap::token_reserves<T1, T2>(blue_move::swap::get_pool<T1, T2>(arg5));
            blue_move::utils::get_amount_in(arg4, v1, v2)
        } else {
            let (v3, v4) = blue_move::swap::token_reserves<T2, T1>(blue_move::swap::get_pool<T2, T1>(arg5));
            blue_move::utils::get_amount_in(arg4, v4, v3)
        };
        let v5 = if (arg0) {
            let (v6, v7) = blue_move::swap::token_reserves<T0, T1>(blue_move::swap::get_pool<T0, T1>(arg5));
            blue_move::utils::get_amount_in(v0 + v0 * 10 / 10000, v6, v7)
        } else {
            let (v8, v9) = blue_move::swap::token_reserves<T1, T0>(blue_move::swap::get_pool<T1, T0>(arg5));
            blue_move::utils::get_amount_in(v0 + v0 * 10 / 10000, v9, v8)
        };
        assert!(v5 <= arg2, 1);
        0x2::pay::keep<T0>(arg3, arg6);
        let v10 = get_intermediate_output_x_to_exact_y<T1, T2>(arg1, get_intermediate_output_x_to_exact_y<T0, T1>(arg0, 0x2::coin::split<T0>(&mut arg3, v5, arg6), v0, arg5, arg6), arg4, arg5, arg6);
        let v11 = 0x2::coin::value<T2>(&v10);
        blue_move::swap::add_swap_event_internal<T0, T1>(v5, 0, 0, v0, arg5, arg6);
        blue_move::swap::add_swap_event_internal<T1, T2>(v0, 0, 0, v11, arg5, arg6);
        (v11, v10)
    }
    
    public entry fun swap_exact_output_doublehop<T0, T1, T2>(arg0: u64, arg1: u64, arg2: 0x2::coin::Coin<T0>, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) {
        blue_move::swap::assert_input_amount<T0>(arg1, &arg2);
        let (_, v1) = swap_exact_output_double_internal<T0, T1, T2>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), arg1, arg2, arg0, arg3, arg4);
        0x2::transfer::public_transfer<0x2::coin::Coin<T2>>(v1, 0x2::tx_context::sender(arg4));
    }
    
    public fun swap_exact_output_doublehop_<T0, T1, T2>(arg0: u64, arg1: u64, arg2: 0x2::coin::Coin<T0>, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T2> {
        blue_move::swap::assert_input_amount<T0>(arg1, &arg2);
        let (_, v1) = swap_exact_output_double_internal<T0, T1, T2>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), arg1, arg2, arg0, arg3, arg4);
        v1
    }
    
    fun swap_exact_output_quadruple_internal<T0, T1, T2, T3, T4>(arg0: bool, arg1: bool, arg2: bool, arg3: bool, arg4: u64, arg5: 0x2::coin::Coin<T0>, arg6: u64, arg7: &mut blue_move::swap::Dex_Info, arg8: &mut 0x2::tx_context::TxContext) : (u64, 0x2::coin::Coin<T4>) {
        let v0 = if (arg3) {
            let (v1, v2) = blue_move::swap::token_reserves<T3, T4>(blue_move::swap::get_pool<T3, T4>(arg7));
            blue_move::utils::get_amount_in(arg6, v1, v2)
        } else {
            let (v3, v4) = blue_move::swap::token_reserves<T4, T3>(blue_move::swap::get_pool<T4, T3>(arg7));
            blue_move::utils::get_amount_in(arg6, v4, v3)
        };
        let v5 = if (arg2) {
            let (v6, v7) = blue_move::swap::token_reserves<T2, T3>(blue_move::swap::get_pool<T2, T3>(arg7));
            blue_move::utils::get_amount_in(v0, v6, v7)
        } else {
            let (v8, v9) = blue_move::swap::token_reserves<T3, T2>(blue_move::swap::get_pool<T3, T2>(arg7));
            blue_move::utils::get_amount_in(v0, v9, v8)
        };
        let v10 = if (arg1) {
            let (v11, v12) = blue_move::swap::token_reserves<T1, T2>(blue_move::swap::get_pool<T1, T2>(arg7));
            blue_move::utils::get_amount_in(v5, v11, v12)
        } else {
            let (v13, v14) = blue_move::swap::token_reserves<T2, T1>(blue_move::swap::get_pool<T2, T1>(arg7));
            blue_move::utils::get_amount_in(v5, v14, v13)
        };
        let v15 = if (arg0) {
            let (v16, v17) = blue_move::swap::token_reserves<T0, T1>(blue_move::swap::get_pool<T0, T1>(arg7));
            blue_move::utils::get_amount_in(v10 + v10 * 10 / 10000, v16, v17)
        } else {
            let (v18, v19) = blue_move::swap::token_reserves<T1, T0>(blue_move::swap::get_pool<T1, T0>(arg7));
            blue_move::utils::get_amount_in(v10 + v10 * 10 / 10000, v19, v18)
        };
        assert!(v15 <= arg4, 1);
        0x2::pay::keep<T0>(arg5, arg8);
        let v20 = get_intermediate_output_x_to_exact_y<T3, T4>(arg3, get_intermediate_output_x_to_exact_y<T2, T3>(arg2, get_intermediate_output_x_to_exact_y<T1, T2>(arg1, get_intermediate_output_x_to_exact_y<T0, T1>(arg0, 0x2::coin::split<T0>(&mut arg5, v15, arg8), v10, arg7, arg8), v5, arg7, arg8), v0, arg7, arg8), arg6, arg7, arg8);
        let v21 = 0x2::coin::value<T4>(&v20);
        blue_move::swap::add_swap_event_internal<T0, T1>(v15, 0, 0, v10, arg7, arg8);
        blue_move::swap::add_swap_event_internal<T1, T2>(v10, 0, 0, v5, arg7, arg8);
        blue_move::swap::add_swap_event_internal<T2, T3>(v5, 0, 0, v0, arg7, arg8);
        blue_move::swap::add_swap_event_internal<T3, T4>(v0, 0, 0, v21, arg7, arg8);
        (v21, v20)
    }
    
    public fun swap_exact_output_quadruplehop<T0, T1, T2, T3, T4>(arg0: u64, arg1: u64, arg2: 0x2::coin::Coin<T0>, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) {
        blue_move::swap::assert_input_amount<T0>(arg1, &arg2);
        let (_, v1) = swap_exact_output_quadruple_internal<T0, T1, T2, T3, T4>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), blue_move::utils::sort_token_type<T2, T3>(), blue_move::utils::sort_token_type<T3, T4>(), arg1, arg2, arg0, arg3, arg4);
        0x2::transfer::public_transfer<0x2::coin::Coin<T4>>(v1, 0x2::tx_context::sender(arg4));
    }
    
    public fun swap_exact_output_quadruplehop_<T0, T1, T2, T3, T4>(arg0: u64, arg1: u64, arg2: 0x2::coin::Coin<T0>, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T4> {
        blue_move::swap::assert_input_amount<T0>(arg1, &arg2);
        let (_, v1) = swap_exact_output_quadruple_internal<T0, T1, T2, T3, T4>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), blue_move::utils::sort_token_type<T2, T3>(), blue_move::utils::sort_token_type<T3, T4>(), arg1, arg2, arg0, arg3, arg4);
        v1
    }
    
    fun swap_exact_output_triple_internal<T0, T1, T2, T3>(arg0: bool, arg1: bool, arg2: bool, arg3: u64, arg4: 0x2::coin::Coin<T0>, arg5: u64, arg6: &mut blue_move::swap::Dex_Info, arg7: &mut 0x2::tx_context::TxContext) : (u64, 0x2::coin::Coin<T3>) {
        let v0 = if (arg2) {
            let (v1, v2) = blue_move::swap::token_reserves<T2, T3>(blue_move::swap::get_pool<T2, T3>(arg6));
            blue_move::utils::get_amount_in(arg5, v1, v2)
        } else {
            let (v3, v4) = blue_move::swap::token_reserves<T3, T2>(blue_move::swap::get_pool<T3, T2>(arg6));
            blue_move::utils::get_amount_in(arg5, v4, v3)
        };
        let v5 = if (arg1) {
            let (v6, v7) = blue_move::swap::token_reserves<T1, T2>(blue_move::swap::get_pool<T1, T2>(arg6));
            blue_move::utils::get_amount_in(v0, v6, v7)
        } else {
            let (v8, v9) = blue_move::swap::token_reserves<T2, T1>(blue_move::swap::get_pool<T2, T1>(arg6));
            blue_move::utils::get_amount_in(v0, v9, v8)
        };
        let v10 = if (arg0) {
            let (v11, v12) = blue_move::swap::token_reserves<T0, T1>(blue_move::swap::get_pool<T0, T1>(arg6));
            blue_move::utils::get_amount_in(v5 + v5 * 10 / 10000, v11, v12)
        } else {
            let (v13, v14) = blue_move::swap::token_reserves<T1, T0>(blue_move::swap::get_pool<T1, T0>(arg6));
            blue_move::utils::get_amount_in(v5 + v5 * 10 / 10000, v14, v13)
        };
        assert!(v10 <= arg3, 1);
        0x2::pay::keep<T0>(arg4, arg7);
        let v15 = get_intermediate_output_x_to_exact_y<T2, T3>(arg2, get_intermediate_output_x_to_exact_y<T1, T2>(arg1, get_intermediate_output_x_to_exact_y<T0, T1>(arg0, 0x2::coin::split<T0>(&mut arg4, v10, arg7), v5, arg6, arg7), v0, arg6, arg7), arg5, arg6, arg7);
        let v16 = 0x2::coin::value<T3>(&v15);
        blue_move::swap::add_swap_event_internal<T0, T1>(v10, 0, 0, v5, arg6, arg7);
        blue_move::swap::add_swap_event_internal<T1, T2>(v5, 0, 0, v0, arg6, arg7);
        blue_move::swap::add_swap_event_internal<T2, T3>(v0, 0, 0, v16, arg6, arg7);
        (v16, v15)
    }
    
    public entry fun swap_exact_output_triplehop<T0, T1, T2, T3>(arg0: u64, arg1: u64, arg2: 0x2::coin::Coin<T0>, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) {
        blue_move::swap::assert_input_amount<T0>(arg1, &arg2);
        let (_, v1) = swap_exact_output_triple_internal<T0, T1, T2, T3>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), blue_move::utils::sort_token_type<T2, T3>(), arg1, arg2, arg0, arg3, arg4);
        0x2::transfer::public_transfer<0x2::coin::Coin<T3>>(v1, 0x2::tx_context::sender(arg4));
    }
    
    public fun swap_exact_output_triplehop_<T0, T1, T2, T3>(arg0: u64, arg1: u64, arg2: 0x2::coin::Coin<T0>, arg3: &mut blue_move::swap::Dex_Info, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T3> {
        blue_move::swap::assert_input_amount<T0>(arg1, &arg2);
        let (_, v1) = swap_exact_output_triple_internal<T0, T1, T2, T3>(blue_move::utils::sort_token_type<T0, T1>(), blue_move::utils::sort_token_type<T1, T2>(), blue_move::utils::sort_token_type<T2, T3>(), arg1, arg2, arg0, arg3, arg4);
        v1
    }
    
    // decompiled from Move bytecode v6
}

