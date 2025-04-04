
/obj/machinery/atmospherics/component/unary/heater
	name = "gas heating system"
	desc = "Heats gas when connected to a pipe network"
	icon = 'icons/obj/medical/cryogenic2.dmi'
	icon_state = "heater_0"
	density = TRUE
	anchored = TRUE
	use_power = USE_POWER_OFF
	idle_power_usage = 5			//5 Watts for thermostat related circuitry
	circuit = /obj/item/circuitboard/unary_atmos/heater

	var/max_temperature = T20C + 680
	var/internal_volume = 600	//L

	var/max_power_rating = 20000	//power rating when the usage is turned up to 100
	var/power_setting_legacy = 100

	var/set_temperature = T20C	//thermostat
	var/heating = 0		//mainly for icon updates

/obj/machinery/atmospherics/component/unary/heater/atmos_init()
	if(node)
		return

	var/node_connect = dir

	//check that there is something to connect to
	for(var/obj/machinery/atmospherics/target in get_step(src, node_connect))
		if(can_be_node(target, 1))
			node = target
			break

	if(check_for_obstacles())
		node = null

	if(node)
		update_icon()

/obj/machinery/atmospherics/component/unary/heater/update_icon_state()
	if(node)
		if(use_power && heating)
			icon_state = "heater_1"
		else
			icon_state = "heater"
	else
		icon_state = "heater_0"
	return ..()

/obj/machinery/atmospherics/component/unary/heater/process(delta_time)
	..()

	if(machine_stat & (NOPOWER|BROKEN) || !use_power)
		heating = 0
		update_icon()
		return

	if(network && air_contents.total_moles && air_contents.temperature < set_temperature)
		CACHE_VSC_PROP(atmos_vsc, /atmos/thermomachine_cheat_factor, cheat_factor)
		var/limit = clamp(air_contents.heat_capacity() * (set_temperature - air_contents.temperature), 0, power_rating * cheat_factor)
		air_contents.adjust_thermal_energy(limit)
		use_power(power_rating)

		heating = 1
		network.update = 1
	else
		heating = 0

	update_icon()

/obj/machinery/atmospherics/component/unary/heater/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/atmospherics/component/unary/heater/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	ui_interact(user)

/obj/machinery/atmospherics/component/unary/heater/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasTemperatureSystem", name)
		ui.open()

/obj/machinery/atmospherics/component/unary/heater/ui_data(mob/user, datum/tgui/ui)
	var/list/data = list()

	data["on"] = use_power ? 1 : 0
	data["gasPressure"] = round(air_contents.return_pressure())
	data["gasTemperature"] = round(air_contents.temperature)
	data["minGasTemperature"] = 0
	data["maxGasTemperature"] = round(max_temperature)
	data["targetGasTemperature"] = round(set_temperature)
	data["powerSetting"] = power_setting_legacy

	var/temp_class = "average"
	if(air_contents.temperature > (T20C+40))
		temp_class = "bad"
	data["gasTemperatureClass"] = temp_class

	return data

/obj/machinery/atmospherics/component/unary/heater/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	. = TRUE
	switch(action)
		if("toggleStatus")
			update_use_power(!use_power)
			update_icon()
		if("setGasTemperature")
			var/amount = text2num(params["temp"])
			if(amount > 0)
				set_temperature = min(amount, max_temperature)
			else
				set_temperature = max(amount, 0)
		if("setPower") //setting power to 0 is redundant anyways
			var/new_setting = clamp( text2num(params["value"]), 0,  100)
			set_power_level(new_setting)

//upgrading parts
/obj/machinery/atmospherics/component/unary/heater/RefreshParts()
	..()
	var/cap_rating = 0
	var/bin_rating = 0

	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/capacitor))
			cap_rating += P.rating
		if(istype(P, /obj/item/stock_parts/matter_bin))
			bin_rating += P.rating

	max_power_rating = initial(max_power_rating) * cap_rating / 2
	max_temperature = max(initial(max_temperature) - T20C, 0) * ((bin_rating * 4 + cap_rating) / 5) + T20C
	air_contents.volume = max(initial(internal_volume) - 200, 0) + 200 * bin_rating
	set_power_level(power_setting_legacy)

/obj/machinery/atmospherics/component/unary/heater/proc/set_power_level(var/new_power_setting_legacy)
	power_setting_legacy = new_power_setting_legacy
	power_rating = max_power_rating * (power_setting_legacy/100)

/obj/machinery/atmospherics/component/unary/heater/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return

	..()

/obj/machinery/atmospherics/component/unary/heater/examine(mob/user, dist)
	. = ..()
	if(panel_open)
		. += "The maintenance hatch is open."
