module cetus::config_script {
    public entry fun add_fee_tier(arg0: &mut cetus_clmm::config::GlobalConfig, arg1: u32, arg2: u64, arg3: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun add_role(arg0: &cetus_clmm::config::AdminCap, arg1: &mut cetus_clmm::config::GlobalConfig, arg2: address, arg3: u8) {
		abort 0
    }
    
    public entry fun delete_fee_tier(arg0: &mut cetus_clmm::config::GlobalConfig, arg1: u32, arg2: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun remove_member(arg0: &cetus_clmm::config::AdminCap, arg1: &mut cetus_clmm::config::GlobalConfig, arg2: address) {
		abort 0
    }
    
    public entry fun remove_role(arg0: &cetus_clmm::config::AdminCap, arg1: &mut cetus_clmm::config::GlobalConfig, arg2: address, arg3: u8) {
		abort 0
    }
    
    public entry fun set_roles(arg0: &cetus_clmm::config::AdminCap, arg1: &mut cetus_clmm::config::GlobalConfig, arg2: address, arg3: u128) {
		abort 0
    }
    
    public entry fun update_fee_tier(arg0: &mut cetus_clmm::config::GlobalConfig, arg1: u32, arg2: u64, arg3: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun update_protocol_fee_rate(arg0: &mut cetus_clmm::config::GlobalConfig, arg1: u64, arg2: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun set_position_display(arg0: &cetus_clmm::config::GlobalConfig, arg1: &0x2::package::Publisher, arg2: 0x1::string::String, arg3: 0x1::string::String, arg4: 0x1::string::String, arg5: 0x1::string::String, arg6: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
}