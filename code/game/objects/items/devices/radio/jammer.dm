var/global/list/active_radio_jammers = list()

/proc/is_jammed(var/obj/radio)
	var/turf/Tr = get_turf(radio)
	if(!Tr) return 0 //Nullspace radios don't get jammed.

	for(var/jammer in active_radio_jammers)
		var/obj/item/radio_jammer/J = jammer
		var/turf/Tj = get_turf(J)

		if(J.on && Tj.z == Tr.z) //If we're on the same Z, it's worth checking.
			var/dist = get_dist(Tj,Tr)
			if(dist <= J.jam_range)
				return list("jammer" = J, "distance" = dist)

/obj/item/radio_jammer
	name = "subspace jammer"
	desc = "Primarily for blocking subspace communications, preventing the use of headsets, PDAs, and communicators. Also masks suit sensors."	// Added suit sensor jamming
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer0"
	var/active_state = "jammer1"
	var/last_overlay_percent = null // Stores overlay icon_state to avoid excessive recreation of overlays.

	var/on = 0
	var/jam_range = 7
	var/obj/item/cell/device/weapon/power_source
	var/tick_cost = 5 // For the ERPs.

	origin_tech = list(TECH_ILLEGAL = 7, TECH_BLUESPACE = 5) //Such technology! Subspace jamming!

/obj/item/radio_jammer/Initialize(mapload)
	. = ..()
	power_source = new(src)
	update_icon() // So it starts with the full overlay.

/obj/item/radio_jammer/Destroy()
	if(on)
		turn_off()
	QDEL_NULL(power_source)
	return ..()

/obj/item/radio_jammer/get_cell(inducer)
	return power_source

/obj/item/radio_jammer/proc/turn_off(mob/user)
	if(user)
		to_chat(user,"<span class='warning'>\The [src] deactivates.</span>")
	STOP_PROCESSING(SSobj, src)
	active_radio_jammers -= src
	on = FALSE
	update_icon()

/obj/item/radio_jammer/proc/turn_on(mob/user)
	if(user)
		to_chat(user,"<span class='notice'>\The [src] is now active.</span>")
	START_PROCESSING(SSobj, src)
	active_radio_jammers += src
	on = TRUE
	update_icon()

/obj/item/radio_jammer/process(delta_time)
	if(!power_source || !power_source.check_charge(tick_cost))
		var/mob/living/notify
		if(isliving(loc))
			notify = loc
		turn_off(notify)
	else
		power_source.use(tick_cost)
		update_icon()


/obj/item/radio_jammer/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(user.get_inactive_held_item() == src && power_source)
		to_chat(user,"<span class='notice'>You eject \the [power_source] from \the [src].</span>")
		user.put_in_hands(power_source)
		power_source = null
		turn_off()
	else
		return ..()

/obj/item/radio_jammer/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(on)
		turn_off(user)
	else
		if(power_source)
			turn_on(user)
		else
			to_chat(user,"<span class='warning'>\The [src] has no power source!</span>")

/obj/item/radio_jammer/attackby(obj/W, mob/user)
	if(istype(W,/obj/item/cell/device/weapon) && !power_source)
		if(!user.attempt_insert_item_for_installation(power_source, src))
			return
		power_source = W
		power_source.update_icon() //Why doesn't a cell do this already? :|
		update_icon()
		to_chat(user,"<span class='notice'>You insert \the [power_source] into \the [src].</span>")

/obj/item/radio_jammer/update_icon()
	cut_overlays()
	. = ..()
	if(on)
		icon_state = active_state
	else
		icon_state = initial(icon_state)

	var/overlay_percent = 0
	if(power_source)
		overlay_percent = between(0, round( power_source.percent() , 25), 100)
	else
		overlay_percent = 0

	var/image/I = image(src.icon, src, "jammer_overlay_[overlay_percent]")
	add_overlay(I)
	last_overlay_percent = overlay_percent

//Unlimited use, unlimited range jammer for admins. Turn it on, drop it somewhere, it works.
/obj/item/radio_jammer/admin
	jam_range = 255
	tick_cost = 0
