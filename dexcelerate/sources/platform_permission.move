module dexcelerate::platform_permission {
	use sui::event;
	use sui::clock::{Self, Clock};
	use sui::table::{Self, Table};

	const ENotAPlatform: u64 = 0;

	const ONE_MONTH: u64 = 2592000000;

	public struct Platform has key, store {
		id: UID,
		permission: Table<address, u64>,
		platform_address: address
	}

	public struct PermissionUpdated has copy, drop, store {
		user: address
	}

	fun init(ctx: &mut TxContext) {
		transfer::public_share_object(
			Platform {
				id: object::new(ctx),
				permission: table::new<address, u64>(ctx),
				platform_address: ctx.sender()
			}
		);
	}

	public entry fun update_platform_address(
		platform: &mut Platform,
		new_platform: address,
		ctx: &mut TxContext
	) {
		assert!(*&platform.platform_address == ctx.sender(), ENotAPlatform);
		*&mut platform.platform_address = new_platform;
	}

	public entry fun give_permission(
		platform: &mut Platform,
		clock: &Clock,
		ctx: &mut TxContext
	) {
		let new_time = clock::timestamp_ms(clock) + ONE_MONTH;

		if(table::contains<address, u64>(&platform.permission, ctx.sender())) {
			let timestamp = table::borrow_mut<address, u64>(&mut platform.permission, ctx.sender());
			*timestamp = new_time;
		} else {
			table::add<address, u64>(&mut platform.permission, ctx.sender(), new_time)
		};

		event::emit(PermissionUpdated {
			user: ctx.sender()
		});
	}

	public fun get_address(platform: &Platform): address {
		*&platform.platform_address
	}

	public(package) fun has_permission(
		platform: &Platform,
		slot_owner: address,
		clock: &Clock,
		ctx: &TxContext
	): bool {
		if(ctx.sender() != *&platform.platform_address) {
			return false
		};

		if(table::contains<address, u64>(&platform.permission, slot_owner)) {
			let timestamp = table::borrow<address, u64>(&platform.permission, slot_owner);
			return *timestamp > clock::timestamp_ms(clock)
		};

		false
	}
}