module dexcelerate::utils {
	use std::type_name;
	use std::bcs::to_bytes;

	use sui::coin::{Self, Coin};

	const EWrongSwapType: u64 = 0;
	
	const EZeroCoins: u64 = 1;
	const ETwoCoins: u64 = 2;

	public fun not_base<T>() {
		assert!(!is_base<T>(), EWrongSwapType);
	}

	public fun is_base<T>(): bool {
		let t_type = to_bytes(&type_name::get<T>());
		let sui_type = b"0x2::sui::SUI";

		if(t_type.length() != sui_type.length()) {
			return false
		};

		let mut i = 0;
		while(i < sui_type.length()) {
			if(*t_type.borrow(i) != *sui_type.borrow(i)) {
				return false
			};
			i = i + 1;
		};

		true
	}

	public fun calculate_fee(
		amount: u64,
		percentage: u64
	): u64 {
		((amount as u128) * (percentage as u128) / 100_000) as u64
	}

	public fun check_amounts<A, B>(
		coin_a: &Coin<A>,
		coin_b: &Coin<B>
	) {
		assert!(coin::value(coin_a) > 0 || coin::value(coin_b) > 0, EZeroCoins);
		assert!(coin::value(coin_a) == 0 || coin::value(coin_b) == 0, ETwoCoins);
	}
}