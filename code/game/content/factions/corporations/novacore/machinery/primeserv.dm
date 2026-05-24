/obj/item/circuitboard/prime_server
	name = T_BOARD("P.R.I.M-E motherboard")
	desc = "A positronic remote interface module's emitter component's backplane. Holds countless, mostly standardized connectors for off-the-shelf components."
	icon_state = "mainboard"
	board_type = new /datum/frame/frame_types/machine
	build_path = /obj/machinery/prime_server
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		// power supply
		/obj/item/stock_parts/capacitor = 2,
		// for running subspace transmissions
		/obj/item/stock_parts/micro_laser = 2,
		// built-in backup transmitter and receiver
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/subspace/sub_filter = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/subspace/transmitter = 1,
		// enables haunting
		/obj/item/integrated_circuit/input/EPv2 = 1,
		// storage, graphics cards, and memory for model processing
		/obj/item/computer_hardware/hard_drive/cluster = 2,
		/obj/item/computer_hardware/processor_unit/photonic = 4,
		/obj/item/integrated_circuit/memory/huge = 8,
		// backup power supply
		/obj/item/computer_hardware/battery_module/super = 1,
		// :slime:
		/obj/item/nvc/prime_drone_card = 1,
		/obj/item/nvc/modded_positronic = 1
	)

/obj/machinery/prime_server
	name = "P.R.I.M-E system endpoint"
	desc = "A positronic remote interface module's emitter component."
	description_fluff = "Allows a positronic brain to seamlessly remotely control a chassis or other system, by modifying the internal states of a low-class drone \
						personality running on a collector component on the remote system. The drone personality reduces bandwidth requirements and allows the \
						system to run autonomously for a limited time, in case of connection loss caused by factors such as ion storms. In other words, it lets a \
						positronic work from home by puppeteering a non-sentient drone."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server-on"
	circuit = /obj/item/circuitboard/prime_server
	idle_power_usage = 2000

/obj/machinery/prime_server/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return

/obj/structure/salvageable/prime_standalone
	name = "P.R.I.M-E standalone system"
	desc = "A positronic remote interface module's emitter component. This doesn't seem like it comes apart very easily."
	icon_state = "bliss0"
	salvageable_parts = list(
		/obj/item/nvc/modded_positronic = 100,
		/obj/item/circuitboard/prime_server = 100,
		/obj/item/computer_hardware/hard_drive/cluster = 100,
		/obj/item/nvc/prime_drone_card = 100
	)
