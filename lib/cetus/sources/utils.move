module cetus::utils {
    public fun merge_coins<T0>(arg0: vector<0x2::coin::Coin<T0>>, arg1: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T0> {
		abort 0
    }
    
    public fun send_coin<T0>(arg0: 0x2::coin::Coin<T0>, arg1: address) {
		abort 0
    }
    
    public fun transfer_coin_to_sender<T0>(arg0: 0x2::coin::Coin<T0>, arg1: &0x2::tx_context::TxContext) {
		abort 0
    }
}