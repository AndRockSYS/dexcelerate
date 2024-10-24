module flow_x::factory {
    public struct Container has key {
        id: 0x2::object::UID,
        pairs: 0x2::bag::Bag,
        treasury: flow_x::treasury::Treasury,
    }
    
    public struct AdminCap has store, key {
        id: 0x2::object::UID,
    }
    
    public struct PairCreated has copy, drop {
        user: address,
        pair: 0x1::string::String,
        coin_x: 0x1::string::String,
        coin_y: 0x1::string::String,
    }
    
    public struct FeeChanged has copy, drop {
        user: address,
        coin_x: 0x1::string::String,
        coin_y: 0x1::string::String,
        fee_rate: u64,
    }
    
    public fun create_pair<T0, T1>(arg0: &mut Container, arg1: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun set_fee_rate<T0, T1>(arg0: &mut AdminCap, arg1: &mut Container, arg2: u64, arg3: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public fun borrow_mut_pair<T0, T1>(arg0: &mut Container) : &mut flow_x::pair::PairMetadata<T0, T1> {
		abort 0
    }
    
    public fun borrow_mut_pair_and_treasury<T0, T1>(arg0: &mut Container) : (&mut flow_x::pair::PairMetadata<T0, T1>, &flow_x::treasury::Treasury) {
		abort 0
    }
    
    public fun borrow_pair<T0, T1>(arg0: &Container) : &flow_x::pair::PairMetadata<T0, T1> {
		abort 0
    }
    
    public fun borrow_treasury(arg0: &Container) : &flow_x::treasury::Treasury {
		abort 0
    }
    
    fun init(arg0: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public fun pair_is_created<T0, T1>(arg0: &Container) : bool {
		abort 0
    }
    
    fun set_fee_rate_<T0, T1>(arg0: &mut Container, arg1: u64, arg2: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun set_fee_to(arg0: &mut AdminCap, arg1: &mut Container, arg2: address) {
		abort 0
    }
}