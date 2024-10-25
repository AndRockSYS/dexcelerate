module dexcelerate::flow_x_protocol {
	use sui::coin;

	use flow_x::factory::{Container};
	use flow_x::router;

	use dexcelerate::slot::{Self, Slot};

	public entry fun swap_exact_input<A, B>(
		container: &mut Container,
		slot: &mut Slot,
		amount_in: u64,
		ctx: &mut TxContext
	) {
		let coin_in = slot::take_from_balance<A>(slot, amount_in, true, ctx);
		let coin_out = router::swap_exact_input_direct<A, B>(
			container,
			coin_in,
			ctx
		);

		slot::add_to_balance<B>(slot, coin::into_balance<B>(coin_out));
	}
}