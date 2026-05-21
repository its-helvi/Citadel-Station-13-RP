/obj/item/circuitboard/prime_server
	name = T_BOARD("P.R.I.M-E motherboard")
	desc = "A positronic remote interface mainframe's emitter component. Holds a neural processing chip storing an unstable drone personality \
			and a supercapacitor to sustain volatile memory, along with countless, mostly standardized connectors for off-the-shelf components."
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
		// storage, graphics cards, and memory for model processing
		/obj/item/computer_hardware/hard_drive/cluster = 2,
		/obj/item/computer_hardware/processor_unit/photonic = 4,
		/obj/item/integrated_circuit/memory/huge = 8,
		// backup power supply
		/obj/item/computer_hardware/battery_module/super = 1,
		// :slime:
		/obj/item/nvc/modded_positronic = 1
	)
	var/alarm = 0
	var/coherence = 3600

/obj/item/circuitboard/prime_server/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/circuitboard/prime_server/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/circuitboard/prime_server/examine(mob/user, dist)
	. = ..()
	var/coherence_str = SPAN_REDTEXT(SPAN_ROBOT("[coherence]"))
	. += SPAN_NOTICE("There's a set of red seven-segment displays reading [coherence_str].")

/obj/item/circuitboard/prime_server/process(delta_time)
	if(istype(loc, /obj/machinery/prime_server))
		if(alarm)
			alarm = 0
			coherence = initial(coherence)
		return
	else
		if(!alarm)
			alarm = 1
			visible_message(SPAN_DANGER("[icon2html(thing = src, target = world)] The system's main board flashes a red light and beeps loudly. The display starts counting down!"))
		coherence -= delta_time

/obj/machinery/prime_server
	name = "P.R.I.M-E system endpoint"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server-on"
	circuit = /obj/item/circuitboard/prime_server
	idle_power_usage = 2000

/obj/machinery/prime_server/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
