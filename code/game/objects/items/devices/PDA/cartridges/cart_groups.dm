var/list/command_cartridges = list(
	/obj/item/cartridge/captain,
	/obj/item/cartridge/hop,
	/obj/item/cartridge/hos,
	/obj/item/cartridge/ce,
	/obj/item/cartridge/rd,
	/obj/item/cartridge/cmo,
	/obj/item/cartridge/head,
	/obj/item/cartridge/lawyer	// Internal Affaris,
	)

var/list/security_cartridges = list(
	/obj/item/cartridge/security,
	/obj/item/cartridge/detective,
	/obj/item/cartridge/hos
	)

var/list/engineering_cartridges = list(
	/obj/item/cartridge/engineering,
	/obj/item/cartridge/atmos,
	/obj/item/cartridge/ce
	)

var/list/medical_cartridges = list(
	/obj/item/cartridge/medical,
	/obj/item/cartridge/chemistry,
	/obj/item/cartridge/cmo
	)

var/list/research_cartridges = list(
	/obj/item/cartridge/signal/science,
	/obj/item/cartridge/rd
	)

var/list/cargo_cartridges = list(
	/obj/item/cartridge/quartermaster,	// This also covers cargo-techs, apparently, for some reason
	/obj/item/cartridge/miner,
	/obj/item/cartridge/hop
	)

var/list/civilian_cartridges = list(
	/obj/item/cartridge/janitor,
	/obj/item/cartridge/service,
	/obj/item/cartridge/hop
	)
