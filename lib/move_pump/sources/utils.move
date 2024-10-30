module move_pump::utils {
    public struct U256 has copy, drop, store {
        v0: u64,
        v1: u64,
        v2: u64,
        v3: u64,
    }
    
    public struct DU256 has copy, drop, store {
        v0: u64,
        v1: u64,
        v2: u64,
        v3: u64,
        v4: u64,
        v5: u64,
        v6: u64,
        v7: u64,
    }
    
    public fun to_bytes(arg0: &U256) : vector<u8> {
		abort 0
    }
    
    public fun add(arg0: U256, arg1: U256) : U256 {
		abort 0
    }
    
    public fun and(arg0: &U256, arg1: &U256) : U256 {
		abort 0
    }
    
    public fun as_u128(arg0: U256) : u128 {
		abort 0
    }
    
    public fun as_u64(arg0: U256) : u64 {
		abort 0
    }
    
    fun bits(arg0: &U256) : u64 {
		abort 0
    }
    
    public fun compare(arg0: &U256, arg1: &U256) : u8 {
		abort 0
    }
    
    public fun div(arg0: U256, arg1: U256) : U256 {
		abort 0
    }
    
    fun du256_to_u256(arg0: DU256) : (U256, bool) {
		abort 0
    }
    
    public fun from_bytes(arg0: &vector<u8>) : U256 {
		abort 0
    }
    
    public fun from_u128(arg0: u128) : U256 {
		abort 0
    }
    
    public fun from_u64(arg0: u64) : U256 {
		abort 0
    }
    
    public fun get(arg0: &U256, arg1: u64) : u64 {
		abort 0
    }
    
    fun get_d(arg0: &DU256, arg1: u64) : u64 {
		abort 0
    }
}