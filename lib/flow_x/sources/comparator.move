module flow_x::comparator {
    public struct Result has drop {
        inner: u8,
    }
    
    public fun compare<T0>(arg0: &T0, arg1: &T0) : Result {
        compare_u8_vector(0x1::bcs::to_bytes<T0>(arg0), 0x1::bcs::to_bytes<T0>(arg1))
    }
    
    public fun compare_u8_vector(arg0: vector<u8>, arg1: vector<u8>) : Result {
		abort 0
    }
    
    public fun is_equal(arg0: &Result) : bool {
        arg0.inner == 0
    }
    
    public fun is_greater_than(arg0: &Result) : bool {
        arg0.inner == 2
    }
    
    public fun is_smaller_than(arg0: &Result) : bool {
        arg0.inner == 1
    }
}