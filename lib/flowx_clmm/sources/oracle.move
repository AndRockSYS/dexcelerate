module flowx_clmm::oracle {
    use std::vector;

    use flowx_clmm::i32::{Self, I32};
    use flowx_clmm::i64::{Self, I64};
    use flowx_clmm::math_u256;
	
    const E_NOT_INITIALIZED: u64 = 0;
    const E_OLDEST_OBSERVATION: u64 = 1;
    const E_EXCEEDED_OBSERVATION_CAP: u64 = 2;
    
    const OBSERVATION_CAP: u64 = 1000u64;

    public struct Observation has copy, drop, store {
        timestamp_s: u64,
        tick_cumulative: I64,
        seconds_per_liquidity_cumulative: u256,
        initialized: bool
    }

    fun default(): Observation {
		abort 0
    }

    public fun timestamp_s(self: &Observation): u64 { self.timestamp_s }

    public fun tick_cumulative(self: &Observation): I64 { self.tick_cumulative }

    public fun seconds_per_liquidity_cumulative(self: &Observation): u256 { self.seconds_per_liquidity_cumulative }

    public fun is_initialized(self: &Observation): bool { self.initialized }

    public(package) fun transform(
        last: &Observation,
        timestamp_s: u64,
        tick_index: I32,
        liquidity: u128
    ): Observation {
		abort 0
    }

    public(package) fun initialize(self: &mut vector<Observation>, timestamp_s: u64): (u64, u64) {
		abort 0
    }

    public(package) fun write(
        self: &mut vector<Observation>,
        index: u64,
        time: u64,
        tick_index: I32,
        liquidity: u128,
        cardinality: u64,
        cardinality_next: u64
    ): (u64, u64) {
		abort 0
    }

    public(package) fun grow(
        self: &mut vector<Observation>,
        current: u64,
        next: u64
    ): u64 {
		abort 0
    }

    fun try_get_observation(
        self: &vector<Observation>,
        index: u64
    ): Observation {
		abort 0
    }

    #[allow(unused_assignment)]
    public fun binary_search(
        self: &vector<Observation>,
        target: u64,
        index: u64,
        cardinality: u64
    ): (Observation, Observation) {
		abort 0
    }

    public fun get_surrounding_observations(
        self: &vector<Observation>,
        target: u64,
        tick_index: I32,
        index: u64,
        liquidity: u128,
        cardinality: u64
    ): (Observation, Observation) {
		abort 0
    }

    public fun observe_single(
        self: &vector<Observation>,
        time: u64,
        seconds_ago: u64,
        tick_index: I32,
        index: u64,
        liquidity: u128,
        cardinality: u64
    ): (I64, u256) {
		abort 0
	}

    public fun observe(
        self: &vector<Observation>,
        time: u64,
        seconds_agos: vector<u64>,
        tick_index: I32,
        index: u64,
        liquidity: u128,
        cardinality: u64
    ): (vector<I64>, vector<u256>) {
		abort 0
    }
}