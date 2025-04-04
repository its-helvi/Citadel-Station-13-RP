/obj/machinery/atmospherics/component/trinary/mixer
	icon = 'icons/atmos/mixer.dmi'
	icon_state = "map"
	construction_type = /obj/item/pipe/trinary/flippable
	pipe_state = "mixer"
	density = 0

	name = "Gas mixer"

	use_power = USE_POWER_IDLE
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 3700	//This also doubles as a measure of how powerful the mixer is, in Watts. 3700 W ~ 5 HP

	var/set_flow_rate = ATMOS_DEFAULT_VOLUME_MIXER
	var/list/mixing_inputs

	//for mapping
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	//node 3 is the outlet, nodes 1 & 2 are intakes

/obj/machinery/atmospherics/component/trinary/mixer/update_icon()
	. = ..()
	if(tee)
		icon_state = "t"
	else if(mirrored)
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(node2 && node3 && node1)
		icon_state += use_power ? "on" : "off"
	else
		icon_state += "off"
		update_use_power(USE_POWER_OFF)

/obj/machinery/atmospherics/component/trinary/mixer/Initialize(mapload)
	. = ..()
	air1.volume = ATMOS_DEFAULT_VOLUME_MIXER
	air2.volume = ATMOS_DEFAULT_VOLUME_MIXER
	air3.volume = ATMOS_DEFAULT_VOLUME_MIXER * 1.5

	if (!mixing_inputs)
		mixing_inputs = list(src.air1 = node1_concentration, src.air2 = node2_concentration)

/obj/machinery/atmospherics/component/trinary/mixer/process(delta_time)
	..()

	last_power_draw_legacy = 0
	last_flow_rate_legacy = 0

	if((machine_stat & (NOPOWER|BROKEN)) || !use_power)
		return

	//Figure out the amount of moles to transfer
	var/transfer_moles = (set_flow_rate*mixing_inputs[air1]/air1.volume)*air1.total_moles + (set_flow_rate*mixing_inputs[air1]/air2.volume)*air2.total_moles

	var/power_draw = -1
	if (transfer_moles > MINIMUM_MOLES_TO_FILTER)
		power_draw = mix_gas(src, mixing_inputs, air3, transfer_moles, power_rating)

		if(network1 && mixing_inputs[air1])
			network1.update = 1

		if(network2 && mixing_inputs[air2])
			network2.update = 1

		if(network3)
			network3.update = 1

	if (power_draw >= 0)
		last_power_draw_legacy = power_draw
		use_power(power_draw)

	return 1

/obj/machinery/atmospherics/component/trinary/mixer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosMixer", name)
		ui.open()

/obj/machinery/atmospherics/component/trinary/mixer/ui_data(mob/user, datum/tgui/ui)
	var/list/data = list()
	data["on"] = use_power
	data["set_pressure"] = round(set_flow_rate)
	data["max_pressure"] = min(air1.volume, air2.volume)
	data["node1_concentration"] = round(mixing_inputs[air1]*100, 1)
	data["node2_concentration"] = round(mixing_inputs[air2]*100, 1)
	var/list/node_connects = get_node_connect_dirs()
	data["node1_dir"] = dir_name(node_connects[1],TRUE)
	data["node2_dir"] = dir_name(node_connects[2],TRUE)
	return data

/obj/machinery/atmospherics/component/trinary/mixer/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(..())
		return
	ui_interact(user)

/obj/machinery/atmospherics/component/trinary/mixer/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	switch(action)
		if("power")
			update_use_power(!use_power)
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = min(air1.volume, air2.volume)
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				set_flow_rate = clamp(pressure, 0, min(air1.volume, air2.volume))
		if("node1")
			var/value = text2num(params["concentration"])
			mixing_inputs[air1] = max(0, min(1, value / 100))
			mixing_inputs[air2] = 1.0 - mixing_inputs[air1]
			. = TRUE
		if("node2")
			var/value = text2num(params["concentration"])
			mixing_inputs[air2] = max(0, min(1, value / 100))
			mixing_inputs[air1] = 1.0 - mixing_inputs[air2]
			. = TRUE
	update_icon()

//
// "T" Orientation - Inputs are on oposite sides instead of adjacent
//
/obj/machinery/atmospherics/component/trinary/mixer/t_mixer
	icon_state = "tmap"
	construction_type = /obj/item/pipe/trinary  // Can't flip a "T", its symmetrical
	pipe_state = "t_mixer"
	dir = SOUTH
	initialize_directions = SOUTH|EAST|WEST
	tee = TRUE

//
// Mirrored Orientation - Flips the output dir to opposite side from normal.
//
/obj/machinery/atmospherics/component/trinary/mixer/m_mixer
	icon_state = "mmap"
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|EAST
	mirrored = TRUE
