// Copied from: https://github.com/aptos-labs/aptos-core/tree/main/aptos-move/framework/aptos-framework/sources/comparator.move
module flowx_clmm::comparator {
    use std::bcs;
    use std::vector;

    const EQUAL: u8 = 0;
    const SMALLER: u8 = 1;
    const GREATER: u8 = 2;

    public struct Result has drop {
        inner: u8,
    }

    public fun is_equal(result: &Result): bool {
        result.inner == EQUAL
    }

    public fun is_smaller_than(result: &Result): bool {
        result.inner == SMALLER
    }

    public fun is_greater_than(result: &Result): bool {
        result.inner == GREATER
    }

    // Performs a comparison of two types after BCS serialization.
    // BCS uses little endian encoding for all integer types,
    // so comparison between primitive integer types will not behave as expected.
    // For example, 1(0x1) will be larger than 256(0x100) after BCS serialization.
    public fun compare<T>(left: &T, right: &T): Result {
		abort 0
    }

    // Performs a comparison of two vector<u8>s or byte vectors
    public fun compare_u8_vector(left: vector<u8>, right: vector<u8>): Result {
		abort 0
    }
}
