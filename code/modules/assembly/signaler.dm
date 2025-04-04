/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices.  Tap against another secured signaler to transfer configuration."
	icon_state = "signaller"
	item_state = "signaler"
	origin_tech = list(TECH_MAGNET = 1)
	materials_base = list(MAT_STEEL = 1000, MAT_GLASS = 200)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	secured = TRUE

	var/code = 30
	var/frequency = FREQ_SIGNALER
	var/delay = 0
	var/hearing_range = 1
	var/airlock_wire = null
	var/datum/wires/connected = null
	var/datum/radio_frequency/radio_connection
	var/deadman = FALSE

/obj/item/assembly/signaler/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/assembly/signaler/LateInitialize()
	set_frequency(frequency)

/obj/item/assembly/signaler/activate()
	if(!process_cooldown())
		return FALSE
	signal()
	return TRUE

/obj/item/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()

/obj/item/assembly/signaler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Signaler", name)
		ui.open()

/obj/item/assembly/signaler/ui_data(mob/user, datum/tgui/ui)
	var/list/data = list()
	data["frequency"] = frequency
	data["code"] = code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	return data

/obj/item/assembly/signaler/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	switch(action)
		if("signal")
			INVOKE_ASYNC(src, PROC_REF(signal))
			. = TRUE
		if("freq")
			frequency = unformat_frequency(params["freq"])
			frequency = sanitize_frequency(frequency, free = TRUE)
			set_frequency(frequency)
			. = TRUE
		if("code")
			code = text2num(params["code"])
			code = clamp(round(code), 1, 100)
			. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				set_frequency(initial(frequency))
			else
				code = initial(code)
			. = TRUE

	update_icon()

/obj/item/assembly/signaler/attackby(obj/item/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			set_frequency(signaler2.frequency)
			to_chat(user, "You transfer the frequency and code of [signaler2] to [src].")
	else
		..()

/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return
	if(is_jammed(src))
		return

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	radio_connection.post_signal(src, signal)

/obj/item/assembly/signaler/pulse(var/radio = 0)
	if(is_jammed(src))
		return FALSE
	if(connected && wires)
		connected.pulse_assembly(src)
	else if(holder)
		holder.process_activation(src, 1, 0)
	else
		..(radio)
	return TRUE

/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE
	if(signal.encryption != code)
		return FALSE
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return FALSE
	if(is_jammed(src))
		return FALSE
	pulse(TRUE)

	audible_message(SPAN_INFOPLAIN("[icon2html(src, hearers(src))] *beep* *beep* *beep*"), null, hearing_range)
	for(var/CHM in get_hearers_in_view(hearing_range, src))
		if(ismob(CHM))
			var/mob/LM = CHM
			LM.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE

/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	if(!frequency)
		return
	if(!radio_controller)
		sleep(20)
	if(!radio_controller)
		return

	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)

/obj/item/assembly/signaler/process(delta_time)
	if(!deadman)
		STOP_PROCESSING(SSobj, src)
	var/mob/M = src.loc
	if(!M || !ismob(M))
		if(prob(5))
			signal()
		deadman = FALSE
		STOP_PROCESSING(SSobj, src)
	else if(prob(5))
		M.visible_message("[M]'s finger twitches a bit over [src]'s signal button!")

/obj/item/assembly/signaler/verb/deadman_it()
	set src in usr
	set name = "Threaten to push the button!"
	set desc = "BOOOOM!"
	set category = VERB_CATEGORY_IC
	deadman = TRUE
	START_PROCESSING(SSobj, src)
	log_and_message_admins("is threatening to trigger a signaler deadman's switch")
	usr.visible_message("<font color='red'>[usr] moves their finger over [src]'s signal button...</font>")

/obj/item/assembly/signaler/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	frequency = 0
	. = ..()
