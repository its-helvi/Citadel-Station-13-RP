/obj/item/gun/launcher/grenade
	name = "grenade launcher"
	desc = "A bulky pump-action grenade launcher. Holds up to 6 grenades in a revolving magazine."
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = WEIGHT_CLASS_BULKY
	heavy = TRUE
	damage_force = 10
	one_handed_penalty = 5

	fire_sound = 'sound/weapons/grenade_launcher.ogg'
	fire_sound_text = "a metallic thunk"
	recoil = 0
	throw_distance = 7
	release_force = 5

	var/list/grenades = new/list()
	var/max_grenades = 5 //holds this + one in the chamber
	materials_base = list(MAT_STEEL = 2000)

	// todo: rework launchers to maaaybe have a similar chambering system to ballistics.....?
	var/atom/movable/chambered

//revolves the magazine, allowing players to choose between multiple grenade types
/obj/item/gun/launcher/grenade/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)

	var/obj/item/grenade/next
	if(grenades.len)
		next = grenades[1] //get this first, so that the chambered grenade can still be removed if the grenades list is empty
	if(chambered)
		grenades += chambered //rotate the revolving magazine
		chambered = null
	if(next)
		grenades -= next //Remove grenade from loaded list.
		chambered = next
		to_chat(M, "<span class='warning'>You pump [src], loading \a [next] into the chamber.</span>")
	else
		to_chat(M, "<span class='warning'>You pump [src], but the magazine is empty.</span>")
	update_icon()

/obj/item/gun/launcher/grenade/examine(mob/user, dist)
	. = ..()
	var/grenade_count = grenades.len + (chambered? 1 : 0)
	. += "Has [grenade_count] grenade\s remaining."
	if(chambered)
		. += "\A [chambered] is chambered."

/obj/item/gun/launcher/grenade/proc/load(obj/item/grenade/G, mob/user)
	if(G.loadable)
		if(grenades.len >= max_grenades)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return
		if(!user.attempt_insert_item_for_installation(G, src))
			return
		grenades.Insert(1, G) //add to the head of the list, so that it is loaded on the next pump
		user.visible_message("[user] inserts \a [G] into [src].", "<span class='notice'>You insert \a [G] into [src].</span>")
		return
	to_chat(user, "<span class='warning'>[G] doesn't seem to fit in the [src]!</span>")

/obj/item/gun/launcher/grenade/proc/unload(mob/user)
	if(grenades.len)
		var/obj/item/grenade/G = grenades[grenades.len]
		grenades.len--
		user.put_in_hands(G)
		user.visible_message("[user] removes \a [G] from [src].", "<span class='notice'>You remove \a [G] from [src].</span>")
		playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
	else
		to_chat(user, "<span class='warning'>[src] is empty.</span>")

/obj/item/gun/launcher/grenade/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	pump(user)

/obj/item/gun/launcher/grenade/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/grenade)))
		load(I, user)
	else
		..()

/obj/item/gun/launcher/grenade/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(user.get_inactive_held_item() == src)
		unload(user)
	else
		..()

//Underslung grenade launcher to be used with the Z8
/obj/item/gun/launcher/grenade/underslung
	name = "underslung grenade launcher"
	desc = "Not much more than a tube and a firing mechanism, this grenade launcher is designed to be fitted to a rifle."
	w_class = WEIGHT_CLASS_NORMAL
	damage_force = 5
	max_grenades = 0

/obj/item/gun/launcher/grenade/underslung/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	return

//load and unload directly into chambered
/obj/item/gun/launcher/grenade/underslung/load(obj/item/grenade/G, mob/user)
	if(G.loadable)
		if(chambered)
			to_chat(user, "<span class='warning'>[src] is already loaded.</span>")
			return
		if(!user.attempt_insert_item_for_installation(G, src))
			return
		chambered = G
		user.visible_message("[user] load \a [G] into [src].", "<span class='notice'>You load \a [G] into [src].</span>")
		return
	to_chat(user, "<span class='warning'>[G] doesn't seem to fit in the [src]!</span>")

/obj/item/gun/launcher/grenade/underslung/unload(mob/user)
	if(chambered)
		user.put_in_hands(chambered)
		user.visible_message("[user] removes \a [chambered] from [src].", "<span class='notice'>You remove \a [chambered] from [src].</span>")
		playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
		chambered = null
	else
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
