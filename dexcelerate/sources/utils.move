module dexcelerate::utils {
	use std::type_name;
	use std::bcs::to_bytes;

	public fun is_sui<T>(): bool {
		let t_type = to_bytes(&type_name::get<T>());
		let sui_type = b"0x2::sui::SUI";

		if(t_type.length() != sui_type.length()) {
			return false;
		};

		let mut i = 0;
		while(i < sui_type.length()) {
			if(*t_type.borrow(i) != *sui_type.borrow(i)) {
				return false;
			};
		};

		true
	}
}