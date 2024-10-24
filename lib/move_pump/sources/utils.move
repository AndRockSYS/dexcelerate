module move_pump::utils {
	use std::bcs;

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
    
    public fun div(mut arg0: U256, mut arg1: U256) : U256 {
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
    
    public fun get_equal() : u8 {
        0
    }
    
    public fun get_greater_than() : u8 {
        2
    }
    
    public fun get_less_than() : u8 {
        1
    }
    
    fun leading_zeros_u64(arg0: u64) : u8 {
		abort 0
    }
    
    public fun mul(arg0: U256, arg1: U256) : U256 {
		abort 0
    }
    
    public fun or(arg0: &U256, arg1: &U256) : U256 {
		abort 0
    }
    
    fun overflowing_add(arg0: u64, arg1: u64) : (u64, bool) {
		abort 0
    }
    
    fun overflowing_sub(arg0: u64, arg1: u64) : (u64, bool) {
		abort 0
    }
    
    fun put(arg0: &mut U256, arg1: u64, arg2: u64) {
		abort 0
    }
    
    fun put_d(arg0: &mut DU256, arg1: u64, arg2: u64) {
		abort 0
    }
    
    public fun shl(arg0: U256, arg1: u8) : U256 {
		abort 0
    }
    
    public fun shr(arg0: U256, arg1: u8) : U256 {
		abort 0
    }
    
    fun split_u128(arg0: u128) : (u64, u64) {
        ((arg0 >> 64) as u64, (arg0 & 18446744073709551615) as u64)
    }
    
    public fun sub(arg0: U256, arg1: U256) : U256 {
		abort 0
    }
    
    public fun xor(arg0: &U256, arg1: &U256) : U256 {
		abort 0
    }
    
    public fun zero() : U256 {
        U256{
            v0 : 0, 
            v1 : 0, 
            v2 : 0, 
            v3 : 0,
        }
    }
}