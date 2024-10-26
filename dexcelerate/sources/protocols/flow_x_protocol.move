module dexcelerate::flow_x_protocol {
	use sui::coin::{Coin};

	use flow_x::factory::{Container};
	use flow_x::router;

	public(package) fun swap_exact_input<A, B>(
		container: &mut Container,
		coin_in: Coin<A>,
		ctx: &mut TxContext
	): Coin<B> {
		router::swap_exact_input_direct<A, B>(
			container,
			coin_in,
			ctx
		)
	}
}