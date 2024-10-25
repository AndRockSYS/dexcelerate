module cetus::fetcher_script {
    public struct FetchTicksResultEvent has copy, drop, store {
        ticks: vector<cetus_clmm::tick::Tick>,
    }
    
    public struct CalculatedSwapResultEvent has copy, drop, store {
        data: cetus_clmm::pool::CalculatedSwapResult,
    }
    
    public struct FetchPositionsEvent has copy, drop, store {
        positions: vector<cetus_clmm::position::PositionInfo>,
    }
    
    public struct FetchPoolsEvent has copy, drop, store {
        pools: vector<cetus_clmm::factory::PoolSimpleInfo>,
    }
    
    public struct FetchPositionRewardsEvent has copy, drop, store {
        data: vector<u64>,
        position_id: 0x2::object::ID,
    }
    
    public struct FetchPositionFeesEvent has copy, drop, store {
        position_id: 0x2::object::ID,
        fee_owned_a: u64,
        fee_owned_b: u64,
    }
    
    public struct FetchPositionPointsEvent has copy, drop, store {
        position_id: 0x2::object::ID,
        points_owned: u128,
    }
    
    public entry fun fetch_pools(arg0: &cetus_clmm::factory::Pools, arg1: vector<0x2::object::ID>, arg2: u64) {
		abort 0
    }
    
    public entry fun calculate_swap_result<T0, T1>(arg0: &cetus_clmm::pool::Pool<T0, T1>, arg1: bool, arg2: bool, arg3: u64) {
		abort 0
    }
    
    public entry fun fetch_positions<T0, T1>(arg0: &cetus_clmm::pool::Pool<T0, T1>, arg1: vector<0x2::object::ID>, arg2: u64) {
		abort 0
    }
    
    public entry fun fetch_ticks<T0, T1>(arg0: &cetus_clmm::pool::Pool<T0, T1>, arg1: vector<u32>, arg2: u64) {
		abort 0
    }
    
    public entry fun fetch_position_fees<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: 0x2::object::ID) {
		abort 0
    }
    
    public entry fun fetch_position_points<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T0>, arg2: 0x2::object::ID, arg3: &0x2::clock::Clock) {
		abort 0
    }
    
    public entry fun fetch_position_rewards<T0, T1>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::pool::Pool<T0, T1>, arg2: 0x2::object::ID, arg3: &0x2::clock::Clock) {
		abort 0
    }
}