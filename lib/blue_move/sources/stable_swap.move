module blue_move::stable_swap {
    public struct LSP<phantom T0, phantom T1> has drop {
        dummy_field: bool,
    }
    
    public struct Stable_Pool<phantom T0, phantom T1> has store, key {
        id: 0x2::object::UID,
        creator: address,
        token_x: 0x2::balance::Balance<T0>,
        token_y: 0x2::balance::Balance<T1>,
        lsp_supply: 0x2::balance::Supply<LSP<T0, T1>>,
        fee_x: 0x2::balance::Balance<T0>,
        fee_y: 0x2::balance::Balance<T1>,
        last_price_x_cumulative: u128,
        last_price_y_cumulative: u128,
        x_scale: u64,
        y_scale: u64,
        is_freeze: bool,
        fee: u64,
        dao_fee: u64,
        last_block_timestamp: u64,
    }
    
    public struct Dex_Stable_Info has store, key {
        id: 0x2::object::UID,
        fee_to: address,
        dev: address,
        total_pool_created: u64,
    }
    
    public struct Created_Stable_Pool_Event has copy, drop {
        pool_id: 0x2::object::ID,
        creator: address,
        token_x_name: 0x1::string::String,
        token_y_name: 0x1::string::String,
        token_x_amount_in: u64,
        token_y_amount_in: u64,
        lsp_balance: u64,
    }
    
    public struct Add_Liquidity_Stable_Pool_Event has copy, drop {
        pool_id: 0x2::object::ID,
        user: address,
        token_x_name: 0x1::string::String,
        token_y_name: 0x1::string::String,
        token_x_amount_in: u64,
        token_y_amount_in: u64,
        lsp_balance: u64,
    }
    
    public struct Remove_Liqidity_Stable_Pool_Event has copy, drop {
        pool_id: 0x2::object::ID,
        user: address,
        token_x_name: 0x1::string::String,
        token_y_name: 0x1::string::String,
        token_x_amount_out: u64,
        token_y_amount_out: u64,
    }
    
    public struct Stable_Swap_Event<phantom T0, phantom T1> has copy, drop {
        pool_id: 0x2::object::ID,
        user: address,
        token_x_in: 0x1::string::String,
        amount_x_in: u64,
        token_y_in: 0x1::string::String,
        amount_y_in: u64,
        token_x_out: 0x1::string::String,
        amount_x_out: u64,
        token_y_out: 0x1::string::String,
        amount_y_out: u64,
    }
    
    public struct Freeze_Stable_Pool_Event<phantom T0, phantom T1> has copy, drop {
        pool_id: 0x2::object::ID,
        token_x_name: 0x1::string::String,
        amount_x: u64,
        token_y_name: 0x1::string::String,
        amount_y: u64,
        lsp_balance: u64,
        is_freeze: bool,
    }
    
    fun swap<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: 0x2::coin::Coin<T1>, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        let v0 = 0x2::coin::value<T0>(&arg2);
        let v1 = 0x2::coin::value<T1>(&arg4);
        assert!(v0 > 0 || v1 > 0, 104);
        let v2 = 0x2::balance::value<T0>(&arg0.token_x);
        let v3 = 0x2::balance::value<T1>(&arg0.token_y);
        0x2::balance::join<T0>(&mut arg0.token_x, 0x2::coin::into_balance<T0>(arg2));
        0x2::balance::join<T1>(&mut arg0.token_y, 0x2::coin::into_balance<T1>(arg4));
        let (v4, v5) = new_reserves_after_fees_scaled(0x2::balance::value<T0>(&arg0.token_x), 0x2::balance::value<T1>(&arg0.token_y), v0, v1, arg0.fee);
        assert_lp_value_is_increased(arg0.x_scale, arg0.y_scale, v2 as u128, v3 as u128, v4, v5);
        split_fee_to_dao<T0, T1>(arg0, v0, v1);
        update_oracle<T0, T1>(arg0, arg1, v2, v3);
        (0x2::coin::from_balance<T0>(0x2::balance::split<T0>(&mut arg0.token_x, arg3), arg6), 0x2::coin::from_balance<T1>(0x2::balance::split<T1>(&mut arg0.token_y, arg5), arg6))
    }
    
    public(package) fun add_liquidity<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: 0x2::coin::Coin<T1>, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>, 0x2::coin::Coin<LSP<T0, T1>>) {
        assert!(!arg0.is_freeze, 111);
        let v0 = 0x2::coin::value<T0>(&arg2);
        let v1 = 0x2::coin::value<T1>(&arg4);
        assert!(v0 >= arg3, 203);
        assert!(v1 >= arg5, 202);
        let (v2, v3) = calc_optimal_coin_values<T0, T1>(arg0, v0, v1, arg3, arg5);
        let v4 = stable_mint<T0, T1>(arg0, arg1, 0x2::coin::split<T0>(&mut arg2, v2, arg6), 0x2::coin::split<T1>(&mut arg4, v3, arg6), arg6);
        let v5 = Add_Liquidity_Stable_Pool_Event{
            pool_id           : 0x2::object::uid_to_inner(&arg0.id), 
            user              : 0x2::tx_context::sender(arg6), 
            token_x_name      : blue_move::utils::get_token_name<T0>(), 
            token_y_name      : blue_move::utils::get_token_name<T1>(), 
            token_x_amount_in : v2, 
            token_y_amount_in : v3, 
            lsp_balance       : 0x2::coin::value<LSP<T0, T1>>(&v4),
        };
        0x2::event::emit<Add_Liquidity_Stable_Pool_Event>(v5);
        (arg2, arg4, v4)
    }
    
    public fun add_stable_swap_event_internal<T0, T1>(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: &mut Dex_Stable_Info, arg5: &mut 0x2::tx_context::TxContext) {
        add_stable_swap_event_with_address_internal<T0, T1>(0x2::tx_context::sender(arg5), arg0, arg1, arg2, arg3, arg4);
    }
    
    public fun add_stable_swap_event_with_address<T0, T1>(arg0: address, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: &mut Stable_Pool<T0, T1>) {
        let v0 = Stable_Swap_Event<T0, T1>{
            pool_id      : 0x2::object::uid_to_inner(&arg5.id), 
            user         : arg0, 
            token_x_in   : blue_move::utils::get_token_name<T0>(), 
            amount_x_in  : arg1, 
            token_y_in   : blue_move::utils::get_token_name<T1>(), 
            amount_y_in  : arg2, 
            token_x_out  : blue_move::utils::get_token_name<T0>(), 
            amount_x_out : arg3, 
            token_y_out  : blue_move::utils::get_token_name<T1>(), 
            amount_y_out : arg4,
        };
        0x2::event::emit<Stable_Swap_Event<T0, T1>>(v0);
    }
    
    fun add_stable_swap_event_with_address_internal<T0, T1>(arg0: address, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: &mut Dex_Stable_Info) {
        if (blue_move::utils::sort_token_type<T0, T1>()) {
            add_stable_swap_event_with_address<T0, T1>(arg0, arg1, arg2, arg3, arg4, get_stable_pool<T0, T1>(arg5));
        } else {
            add_stable_swap_event_with_address<T1, T0>(arg0, arg2, arg1, arg4, arg3, get_stable_pool<T1, T0>(arg5));
        };
    }
    
    fun assert_lp_value_is_increased(arg0: u64, arg1: u64, arg2: u128, arg3: u128, arg4: u128, arg5: u128) {
        assert!(blue_move::stable_curve::lp_value(arg4, arg0, arg5, arg1) > blue_move::stable_curve::lp_value(arg2, arg0, arg3, arg1), 105);
    }
    
    public fun calc_optimal_coin_values<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: u64, arg2: u64, arg3: u64, arg4: u64) : (u64, u64) {
        let v0 = 0x2::balance::value<T0>(&arg0.token_x);
        let v1 = 0x2::balance::value<T1>(&arg0.token_y);
        if (v0 == 0 && v1 == 0) {
            return (arg1, arg2)
        };
        let v2 = convert_with_current_price(arg1, v0, v1);
        if (v2 <= arg2) {
            assert!(v2 >= arg4, 202);
            return (arg1, v2)
        };
        let v3 = convert_with_current_price(arg2, v1, v0);
        assert!(v3 <= arg1, 204);
        assert!(v3 >= arg3, 203);
        (v3, arg2)
    }
    
    public fun check_stable_pool_exist<T0, T1>(arg0: &Dex_Stable_Info) : bool {
        0x2::dynamic_object_field::exists_<0x1::string::String>(&arg0.id, blue_move::utils::get_lp_name<T0, T1>())
    }
    
    public fun convert_with_current_price(arg0: u64, arg1: u64, arg2: u64) : u64 {
        assert!(arg0 > 0, 200);
        assert!(arg1 > 0 && arg2 > 0, 201);
        let v0 = (arg0 as u128) * (arg2 as u128) / (arg1 as u128);
        assert!(v0 <= 18446744073709551615, 208);
        v0 as u64
    }
    
    public(package) fun create_pool<T0, T1>(arg0: u8, arg1: u8, arg2: u64, arg3: u64, arg4: &mut Dex_Stable_Info, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg6) == arg4.dev, 112);
        if (blue_move::utils::sort_token_type<T0, T1>()) {
            create_stable_pool_internal<T0, T1>(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
        } else {
            create_stable_pool_internal<T1, T0>(arg1, arg0, arg2, arg3, arg4, arg5, arg6);
        };
    }
    
    fun create_stable_pool_internal<T0, T1>(arg0: u8, arg1: u8, arg2: u64, arg3: u64, arg4: &mut Dex_Stable_Info, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
        let v0 = blue_move::utils::get_lp_name<T0, T1>();
        assert!(!0x2::dynamic_object_field::exists_<0x1::string::String>(&arg4.id, v0), 1);
        let v1 = 0x2::tx_context::sender(arg6);
        let v2 = LSP<T0, T1>{dummy_field: false};
        let v3 = 0x2::object::new(arg6);
        let v4 = Stable_Pool<T0, T1>{
            id                      : v3, 
            creator                 : v1, 
            token_x                 : 0x2::balance::zero<T0>(), 
            token_y                 : 0x2::balance::zero<T1>(), 
            lsp_supply              : 0x2::balance::create_supply<LSP<T0, T1>>(v2), 
            fee_x                   : 0x2::balance::zero<T0>(), 
            fee_y                   : 0x2::balance::zero<T1>(), 
            last_price_x_cumulative : 0, 
            last_price_y_cumulative : 0, 
            x_scale                 : blue_move::math::pow_10(arg0), 
            y_scale                 : blue_move::math::pow_10(arg1), 
            is_freeze               : false, 
            fee                     : arg2, 
            dao_fee                 : arg3, 
            last_block_timestamp    : 0x2::clock::timestamp_ms(arg5),
        };
        arg4.total_pool_created = arg4.total_pool_created + 1;
        0x2::dynamic_object_field::add<0x1::string::String, Stable_Pool<T0, T1>>(&mut arg4.id, v0, v4);
        let v5 = Created_Stable_Pool_Event{
            pool_id           : 0x2::object::uid_to_inner(&v3), 
            creator           : v1, 
            token_x_name      : blue_move::utils::get_token_name<T0>(), 
            token_y_name      : blue_move::utils::get_token_name<T1>(), 
            token_x_amount_in : 0, 
            token_y_amount_in : 0, 
            lsp_balance       : 0,
        };
        0x2::event::emit<Created_Stable_Pool_Event>(v5);
    }
    
    public entry fun freeze_stable_pool<T0, T1>(arg0: bool, arg1: &mut Dex_Stable_Info, arg2: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg2) == arg1.dev, 112);
        if (blue_move::utils::sort_token_type<T0, T1>()) {
            freeze_stable_pool_internal<T0, T1>(get_stable_pool<T0, T1>(arg1), arg0);
        } else {
            freeze_stable_pool_internal<T1, T0>(get_stable_pool<T1, T0>(arg1), arg0);
        };
    }
    
    fun freeze_stable_pool_internal<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: bool) {
        arg0.is_freeze = arg1;
        let v0 = Freeze_Stable_Pool_Event<T0, T1>{
            pool_id      : 0x2::object::uid_to_inner(&arg0.id), 
            token_x_name : blue_move::utils::get_token_name<T0>(), 
            amount_x     : 0x2::balance::value<T0>(&arg0.token_x), 
            token_y_name : blue_move::utils::get_token_name<T1>(), 
            amount_y     : 0x2::balance::value<T1>(&arg0.token_y), 
            lsp_balance  : 0x2::balance::supply_value<LSP<T0, T1>>(&arg0.lsp_supply), 
            is_freeze    : arg0.is_freeze,
        };
        0x2::event::emit<Freeze_Stable_Pool_Event<T0, T1>>(v0);
    }
    
    public fun get_amount_in<T0, T1>(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64) : u64 {
        get_coin_in_with_fees<T0, T1>(arg0, arg2, arg1, arg6, arg5, arg3, arg4)
    }
    
    public fun get_amount_out<T0, T1>(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64) : u64 {
        get_coin_out_with_fees<T0, T1>(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
    }
    
    fun get_coin_in_with_fees<T0, T1>(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64) : u64 {
        assert!(arg1 > arg0, 202);
        blue_move::math::mul_div((blue_move::stable_curve::coin_in(arg0 as u128, arg3, arg4, arg1 as u128, arg2 as u128) as u64) + 1, arg6, arg6 - arg5) + 1
    }
    
    fun get_coin_out_with_fees<T0, T1>(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64) : u64 {
        let v0 = blue_move::math::mul_to_u128(arg0, arg6 - arg5);
        let v1 = if (v0 % (arg6 as u128) != 0) {
            v0 / (arg6 as u128) + 1
        } else {
            v0 / (arg6 as u128)
        };
        blue_move::stable_curve::coin_out(v1, arg3, arg4, arg1 as u128, arg2 as u128) as u64
    }
    
    public fun get_cumulative_prices<T0, T1>(arg0: &mut Stable_Pool<T0, T1>) : (u128, u128) {
        (arg0.last_price_x_cumulative, arg0.last_price_y_cumulative)
    }
    
    public fun get_decimals_scales<T0, T1>(arg0: &mut Stable_Pool<T0, T1>) : (u64, u64) {
        (arg0.x_scale, arg0.y_scale)
    }
    
    public fun get_fees_config<T0, T1>(arg0: &mut Stable_Pool<T0, T1>) : (u64, u64) {
        (arg0.fee, 10000)
    }
    
    public fun get_reserves_size<T0, T1>(arg0: &mut Dex_Stable_Info) : (u64, u64) {
        let v0 = get_stable_pool<T0, T1>(arg0);
        (0x2::balance::value<T0>(&v0.token_x), 0x2::balance::value<T1>(&v0.token_y))
    }
    
    public fun get_stable_pool<T0, T1>(arg0: &mut Dex_Stable_Info) : &mut Stable_Pool<T0, T1> {
        assert!(check_stable_pool_exist<T0, T1>(arg0), 23);
        0x2::dynamic_object_field::borrow_mut<0x1::string::String, Stable_Pool<T0, T1>>(&mut arg0.id, blue_move::utils::get_lp_name<T0, T1>())
    }
    
    fun init(arg0: &mut 0x2::tx_context::TxContext) {
        let v0 = Dex_Stable_Info{
            id                 : 0x2::object::new(arg0), 
            fee_to             : @0x85bf745a737a34bf73f360c22d5c8aea1f1767f3c458f5269a7c2f821b9d3781, 
            dev                : @0x49cc391ab4d3503e03dbb24c4f9e28f3cdd2ddf8a459e0d43012c3868ffefa1, 
            total_pool_created : 0,
        };
        0x2::transfer::public_share_object<Dex_Stable_Info>(v0);
    }
    
    fun new_reserves_after_fees_scaled(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64) : (u128, u128) {
        ((arg0 - blue_move::math::mul_div(arg2, arg4, 10000)) as u128, (arg1 - blue_move::math::mul_div(arg3, arg4, 10000)) as u128)
    }
    
    public(package) fun remove_liquidity<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<LSP<T0, T1>>, arg3: u64, arg4: u64, arg5: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        assert!(!arg0.is_freeze, 111);
        let (v0, v1) = stable_burn<T0, T1>(arg0, arg1, arg2, arg5);
        let v2 = v1;
        let v3 = v0;
        assert!(0x2::coin::value<T0>(&v3) >= arg3, 205);
        assert!(0x2::coin::value<T1>(&v2) >= arg4, 205);
        let v4 = Remove_Liqidity_Stable_Pool_Event{
            pool_id            : 0x2::object::uid_to_inner(&arg0.id), 
            user               : 0x2::tx_context::sender(arg5), 
            token_x_name       : blue_move::utils::get_token_name<T0>(), 
            token_y_name       : blue_move::utils::get_token_name<T1>(), 
            token_x_amount_out : 0x2::coin::value<T0>(&v3), 
            token_y_amount_out : 0x2::coin::value<T1>(&v2),
        };
        0x2::event::emit<Remove_Liqidity_Stable_Pool_Event>(v4);
        (v3, v2)
    }
    
    public entry fun set_dao_fee<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &mut Dex_Stable_Info, arg2: u64, arg3: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg3) == arg1.fee_to, 112);
        arg0.dao_fee = arg2;
    }
    
    public entry fun set_dev_account(arg0: &mut Dex_Stable_Info, arg1: address, arg2: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg2) == arg0.dev, 17);
        arg0.dev = arg1;
    }
    
    public entry fun set_fee<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &mut Dex_Stable_Info, arg2: u64, arg3: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg3) == arg1.fee_to, 112);
        arg0.fee = arg2;
    }
    
    public entry fun set_fee_config<T0, T1>(arg0: u64, arg1: u64, arg2: &mut Dex_Stable_Info, arg3: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg3) == arg2.dev, 17);
        if (blue_move::utils::sort_token_type<T0, T1>()) {
            let v0 = get_stable_pool<T0, T1>(arg2);
            v0.fee = arg0;
            v0.dao_fee = arg1;
        } else {
            let v1 = get_stable_pool<T1, T0>(arg2);
            v1.fee = arg0;
            v1.dao_fee = arg1;
        };
    }
    
    public entry fun set_fee_to(arg0: &mut Dex_Stable_Info, arg1: address, arg2: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg2) == arg0.dev, 17);
        arg0.fee_to = arg1;
    }
    
    fun split_fee_to_dao<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: u64, arg2: u64) {
        let v0 = arg0.fee;
        let v1 = arg0.dao_fee;
        let v2 = if (v0 * v1 % 100 != 0) {
            v0 * v1 / 100 + 1
        } else {
            v0 * v1 / 100
        };
        0x2::balance::join<T0>(&mut arg0.fee_x, 0x2::balance::split<T0>(&mut arg0.token_x, blue_move::math::mul_div(arg1, v2, 10000)));
        0x2::balance::join<T1>(&mut arg0.fee_y, 0x2::balance::split<T1>(&mut arg0.token_y, blue_move::math::mul_div(arg2, v2, 10000)));
    }
    
    fun stable_burn<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<LSP<T0, T1>>, arg3: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        let v0 = 0x2::coin::value<LSP<T0, T1>>(&arg2);
        let v1 = 0x2::balance::supply_value<LSP<T0, T1>>(&arg0.lsp_supply) as u128;
        let v2 = 0x2::balance::value<T0>(&arg0.token_x);
        let v3 = 0x2::balance::value<T1>(&arg0.token_y);
        let v4 = blue_move::math::mul_div_u128(v0 as u128, v2 as u128, v1);
        let v5 = blue_move::math::mul_div_u128(v0 as u128, v3 as u128, v1);
        assert!(v4 > 0 && v5 > 0, 106);
        update_oracle<T0, T1>(arg0, arg1, v2, v3);
        0x2::balance::decrease_supply<LSP<T0, T1>>(&mut arg0.lsp_supply, 0x2::coin::into_balance<LSP<T0, T1>>(arg2));
        (0x2::coin::from_balance<T0>(0x2::balance::split<T0>(&mut arg0.token_x, v4), arg3), 0x2::coin::from_balance<T1>(0x2::balance::split<T1>(&mut arg0.token_y, v5), arg3))
    }
    
    fun stable_mint<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T0>, arg3: 0x2::coin::Coin<T1>, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<LSP<T0, T1>> {
        let v0 = 0x2::balance::supply_value<LSP<T0, T1>>(&arg0.lsp_supply) as u128;
        let v1 = 0x2::balance::value<T0>(&arg0.token_x);
        let v2 = 0x2::balance::value<T1>(&arg0.token_y);
        let v3 = if (v0 == 0) {
            let v4 = blue_move::math::sqrt_u64(blue_move::math::mul_to_u128(0x2::coin::value<T0>(&arg2), 0x2::coin::value<T1>(&arg3)));
            assert!(v4 > 1000, 102);
            v4 - 1000
        } else {
            let v5 = blue_move::math::mul_div_u128(0x2::coin::value<T0>(&arg2) as u128, v0, v1 as u128);
            let v6 = blue_move::math::mul_div_u128(0x2::coin::value<T1>(&arg3) as u128, v0, v2 as u128);
            let v7 = if (v5 < v6) {
                v5
            } else {
                v6
            };
            v7
        };
        assert!(v3 > 0, 103);
        0x2::balance::join<T0>(&mut arg0.token_x, 0x2::coin::into_balance<T0>(arg2));
        0x2::balance::join<T1>(&mut arg0.token_y, 0x2::coin::into_balance<T1>(arg3));
        update_oracle<T0, T1>(arg0, arg1, v1, v2);
        0x2::coin::from_balance<LSP<T0, T1>>(0x2::balance::increase_supply<LSP<T0, T1>>(&mut arg0.lsp_supply, v3), arg4)
    }
    
    public(package) fun swap_coin_for_coin_unchecked<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T1> {
        let (v0, v1) = swap<T0, T1>(arg0, arg1, arg2, 0, 0x2::coin::zero<T1>(arg4), arg3, arg4);
        0x2::coin::destroy_zero<T0>(v0);
        v1
    }
    
    public(package) fun swap_coin_for_coin_unchecked_<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T1>, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T0> {
        let (v0, v1) = swap<T0, T1>(arg0, arg1, 0x2::coin::zero<T0>(arg4), arg3, arg2, 0, arg4);
        0x2::coin::destroy_zero<T1>(v1);
        v0
    }
    
    public(package) fun swap_exact_x_to_y<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T1> {
        assert!(!arg0.is_freeze, 111);
        let v0 = get_amount_out<T0, T1>(0x2::coin::value<T0>(&arg2), 0x2::balance::value<T0>(&arg0.token_x), 0x2::balance::value<T1>(&arg0.token_y), arg0.x_scale, arg0.y_scale, arg0.fee, 10000);
        assert!(v0 >= arg3, 205);
        swap_coin_for_coin_unchecked<T0, T1>(arg0, arg1, arg2, v0, arg4)
    }
    
    public(package) fun swap_exact_y_to_x<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T1>, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T0> {
        assert!(!arg0.is_freeze, 111);
        let v0 = get_amount_out<T0, T1>(0x2::coin::value<T1>(&arg2), 0x2::balance::value<T1>(&arg0.token_y), 0x2::balance::value<T0>(&arg0.token_x), arg0.y_scale, arg0.x_scale, arg0.fee, 10000);
        assert!(v0 >= arg3, 205);
        swap_coin_for_coin_unchecked_<T0, T1>(arg0, arg1, arg2, v0, arg4)
    }
    
    public(package) fun swap_x_to_exact_y<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T1>, u64) {
        assert!(!arg0.is_freeze, 111);
        let v0 = get_amount_in<T0, T1>(arg3, 0x2::balance::value<T0>(&arg0.token_x), 0x2::balance::value<T1>(&arg0.token_y), arg0.fee, 10000, arg0.x_scale, arg0.y_scale);
        assert!(v0 <= 0x2::coin::value<T0>(&arg2), 206);
        let v1 = 0x2::coin::split<T0>(&mut arg2, v0, arg4);
        blue_move::utils::destroy_zero_coin<T0>(arg2, 0x2::tx_context::sender(arg4));
        (swap_coin_for_coin_unchecked<T0, T1>(arg0, arg1, v1, arg3, arg4), 0x2::coin::value<T0>(&v1))
    }
    
    public(package) fun swap_y_to_exact_x<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<T1>, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, u64) {
        assert!(!arg0.is_freeze, 111);
        let v0 = get_amount_in<T0, T1>(arg3, 0x2::balance::value<T1>(&arg0.token_y), 0x2::balance::value<T0>(&arg0.token_x), arg0.fee, 10000, arg0.y_scale, arg0.x_scale);
        assert!(v0 <= 0x2::coin::value<T1>(&arg2), 206);
        let v1 = 0x2::coin::split<T1>(&mut arg2, v0, arg4);
        blue_move::utils::destroy_zero_coin<T1>(arg2, 0x2::tx_context::sender(arg4));
        (swap_coin_for_coin_unchecked_<T0, T1>(arg0, arg1, v1, arg3, arg4), 0x2::coin::value<T1>(&v1))
    }
    
    fun update_oracle<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &0x2::clock::Clock, arg2: u64, arg3: u64) {
        let v0 = 0x2::clock::timestamp_ms(arg1);
        let v1 = (v0 - arg0.last_block_timestamp) as u128;
        if (v1 > 0 && arg2 != 0 && arg3 != 0) {
            arg0.last_price_x_cumulative = blue_move::math::overflow_add(arg0.last_price_x_cumulative, blue_move::uq64x64::to_u128(blue_move::uq64x64::fraction(arg3, arg2)) * v1);
            arg0.last_price_y_cumulative = blue_move::math::overflow_add(arg0.last_price_y_cumulative, blue_move::uq64x64::to_u128(blue_move::uq64x64::fraction(arg2, arg3)) * v1);
        };
        arg0.last_block_timestamp = v0;
    }
    
    public entry fun withdraw_fee_stable_pool<T0, T1>(arg0: &mut Dex_Stable_Info, arg1: &mut 0x2::tx_context::TxContext) {
        let v0 = 0x2::tx_context::sender(arg1);
        assert!(v0 == arg0.fee_to || v0 == arg0.dev, 17);
        if (blue_move::utils::sort_token_type<T0, T1>()) {
            withdraw_fee_stable_pool_internal<T0, T1>(get_stable_pool<T0, T1>(arg0), arg1);
        } else {
            withdraw_fee_stable_pool_internal<T1, T0>(get_stable_pool<T1, T0>(arg0), arg1);
        };
    }
    
    fun withdraw_fee_stable_pool_internal<T0, T1>(arg0: &mut Stable_Pool<T0, T1>, arg1: &mut 0x2::tx_context::TxContext) {
        let v0 = 0x2::tx_context::sender(arg1);
        0x2::transfer::public_transfer<0x2::coin::Coin<T0>>(0x2::coin::from_balance<T0>(0x2::balance::split<T0>(&mut arg0.fee_x, 0x2::balance::value<T0>(&arg0.fee_x)), arg1), v0);
        0x2::transfer::public_transfer<0x2::coin::Coin<T1>>(0x2::coin::from_balance<T1>(0x2::balance::split<T1>(&mut arg0.fee_y, 0x2::balance::value<T1>(&arg0.fee_y)), arg1), v0);
    }
    
    // decompiled from Move bytecode v6
}

