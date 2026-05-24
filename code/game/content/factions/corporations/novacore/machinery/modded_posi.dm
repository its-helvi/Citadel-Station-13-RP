/obj/item/nvc/modded_positronic
	name = "modified positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. \
			It's been modified beyond recovery, and will not fit in any standard positronic neural interface connectors."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain-searching"
	w_class = WEIGHT_CLASS_NORMAL
	integrity_flags = INTEGRITY_INDESTRUCTIBLE

/obj/item/nvc/prime_drone_card
	name = "P.R.I.M-E neural processing unit"
	desc = "The brains of a positronic remote interface module's emitter component. Holds a neural processing chip storing an unstable drone personality \
			and a supercapacitor to sustain volatile memory, and a standard PCIe connector."
	icon = 'icons/items/circuits.dmi'
	icon_state = "mcontroller"
	var/alarm = 0
	var/coherence = 3600

/obj/item/nvc/prime_drone_card/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/nvc/prime_drone_card/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/nvc/prime_drone_card/examine(mob/user, dist)
	. = ..()
	var/coherence_str = SPAN_REDTEXT(SPAN_ROBOT("[coherence]"))
	. += SPAN_NOTICE("There's a set of red seven-segment displays reading [coherence_str].")

/obj/item/nvc/prime_drone_card/process(delta_time)
	if(istype(loc, /obj/machinery/prime_server) || istype(loc, /obj/structure/salvageable/prime_standalone))
		if(alarm)
			alarm = 0
			coherence = initial(coherence)
			visible_message(SPAN_NOTICE("[icon2html(thing = src, target = world)] The mainboard beeps twice as its power supply stabilizes, displays and lights returning to normal."))
			playsound(loc, 'sound/machines/2beep.ogg')
		return
	else
		if(!alarm)
			alarm = 1
			spawn(30)
				visible_message(SPAN_DANGER("[icon2html(thing = src, target = world)] The system's mainboard flashes a red light and beeps loudly. \
								The display starts counting down!"))
				playsound(src, 'sound/machines/cryo_warning.ogg', 100)
		coherence -= delta_time
