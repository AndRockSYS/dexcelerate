module cetus::partner_script {
    public entry fun claim_ref_fee<T0>(arg0: &cetus_clmm::config::GlobalConfig, arg1: &cetus_clmm::partner::PartnerCap, arg2: &mut cetus_clmm::partner::Partner, arg3: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun create_partner(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::partner::Partners, arg2: 0x1::string::String, arg3: u64, arg4: u64, arg5: u64, arg6: address, arg7: &0x2::clock::Clock, arg8: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun update_partner_ref_fee_rate(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::partner::Partner, arg2: u64, arg3: &0x2::tx_context::TxContext) {
		abort 0
    }
    
    public entry fun update_partner_time_range(arg0: &cetus_clmm::config::GlobalConfig, arg1: &mut cetus_clmm::partner::Partner, arg2: u64, arg3: u64, arg4: &0x2::clock::Clock, arg5: &mut 0x2::tx_context::TxContext) {
		abort 0
    }
}