/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_closed"
	plane = TURF_PLANE
	layer = ABOVE_TURF_LAYER
	anchored = 1
	density = 0
	var/obj/item/extinguisher/has_extinguisher
	var/opened = 0

/obj/structure/extinguisher_cabinet/Initialize(mapload, dir, building = FALSE)
	. = ..()
	if(building)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
		pixel_y = (dir & 3)? (dir ==1 ? -27 : 27) : 0
		update_icon()
		return
	else
		has_extinguisher = new/obj/item/extinguisher(src)

/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user)
	if(isrobot(user))
		return
	if(istype(O, /obj/item/extinguisher))
		if(!has_extinguisher && opened)
			if(!user.attempt_insert_item_for_installation(O, src))
				return
			has_extinguisher = O
			to_chat(user, "<span class='notice'>You place [O] in [src].</span>")
		else
			opened = !opened
	if(O.is_wrench())
		if(!has_extinguisher)
			to_chat(user, "<span class='notice'>You start to unwrench the extinguisher cabinet.</span>")
			playsound(src.loc, O.tool_sound, 50, 1)
			if(do_after(user, 15 * O.tool_speed))
				to_chat(user, "<span class='notice'>You unwrench the extinguisher cabinet.</span>")
				new /obj/item/frame/extinguisher_cabinet( src.loc )
				qdel(src)
			return
	else
		opened = !opened
	update_icon()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(isrobot(user))
		return
	if(!user.standard_hand_usability_check(src, e_args.using_hand_index, HAND_MANIPULATION_GENERAL))
		return
	if(has_extinguisher)
		user.put_in_hands_or_drop(has_extinguisher)
		to_chat(user, "<span class='notice'>You take [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.loc = loc
		to_chat(user, "<span class='notice'>You telekinetically remove [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"
