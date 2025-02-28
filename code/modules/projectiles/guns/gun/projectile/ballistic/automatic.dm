/obj/item/gun/projectile/ballistic/automatic //This should never be spawned in, it is just here because of code necessities.
	name = "daka SMG"
	desc = "A small SMG. You really shouldn't be able to get this gun. Uses 9mm rounds."
	icon_state = "c05r"	//Used because it's not used anywhere else
	load_method = SPEEDLOADER
	ammo_type = /obj/item/ammo_casing/a9mm
	projectile_type = /obj/projectile/bullet/pistol
	mag_insert_sound = 'sound/weapons/guns/interaction/smg_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/smg_magout.ogg'
//Burst is the number of bullets fired; Fire delay is the time you have to wait to shoot the gun again, Move delay is the same but for moving after shooting. .
//Burst accuracy is the accuracy of each bullet fired in the burst. Dispersion is how much the bullets will 'spread' away from where you aimed.

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=4,    burst_accuracy=list(60,30,0), dispersion=list(0.0, 0.6, 1.0)))

/obj/item/gun/projectile/ballistic/automatic/advanced_smg
	name = "advanced SMG"
	desc = "The NT-S3W is an advanced submachine gun design, using a reflective laser optic for increased accuracy over competing models. Chambered for 9mm rounds."
	icon_state = "advanced_smg"
	w_class = WEIGHT_CLASS_NORMAL
	load_method = MAGAZINE
	caliber = /datum/ammo_caliber/a9mm
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	magazine_type = null // R&D builds this. Starts unloaded.
	allowed_magazines = list(/obj/item/ammo_magazine/a9mm/advanced_smg, /obj/item/ammo_magazine/a9mm)

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=4,    burst_accuracy=list(60,30,20), dispersion=list(0.0, 0.3, 0.6))
	)

/obj/item/gun/projectile/ballistic/automatic/advanced_smg/loaded
	magazine_type = /obj/item/ammo_magazine/a9mm/advanced_smg

/obj/item/gun/projectile/ballistic/automatic/c20r
	name = "submachine gun"
	desc = "The C-20r is a lightweight and rapid firing SMG, for when you REALLY need someone dead. It has 'Scarborough Arms - Per falcis, per pravitas' inscribed on the stock. Uses 10mm rounds."
	icon_state = "c20r"
	item_state = "c20r"
	w_class = WEIGHT_CLASS_NORMAL
	damage_force = 10
	caliber = /datum/ammo_caliber/a10mm
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ILLEGAL = 8)
	slot_flags = SLOT_BELT|SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a10mm
	allowed_magazines = list(/obj/item/ammo_magazine/a10mm)
	projectile_type = /obj/projectile/bullet/pistol/medium
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'

	one_handed_penalty = 15

/obj/item/gun/projectile/ballistic/automatic/c20r/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "c20r-[round(ammo_magazine.amount_remaining(),4)]"
	else
		icon_state = "c20r"

/obj/item/gun/projectile/ballistic/automatic/sts35
	name = "assault rifle"
	desc = "The rugged STS-35 is a durable automatic weapon of a make popular on the frontier worlds. Uses 5.56mm rounds."
	icon_state = "arifle"
	item_state = "arifle"
	wielded_item_state = "arifle-wielded"
	item_state = null
	w_class = WEIGHT_CLASS_BULKY
	damage_force = 10
	caliber = /datum/ammo_caliber/a5_56mm
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 4)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a5_56mm
	allowed_magazines = list(/obj/item/ammo_magazine/a5_56mm)
	projectile_type = /obj/projectile/bullet/rifle/a556
	mag_insert_sound = 'sound/weapons/guns/interaction/ltrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/ltrifle_magout.ogg'
	heavy = TRUE
	one_handed_penalty = 30

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=6,    burst_accuracy=list(60,50,45), dispersion=list(0.0, 0.6, 0.6))
//		list(mode_name="short bursts", 	burst=5, fire_delay=null, move_delay=6,    burst_accuracy=list(0,-15,-30,-30,-45), dispersion=list(0.6, 1.0, 1.0, 1.0, 1.2)),
		)

/obj/item/gun/projectile/ballistic/automatic/sts35/update_icon_state()
	. = ..()
	if(istype(ammo_magazine,/obj/item/ammo_magazine/a5_56mm/small))
		icon_state = "arifle-small" // If using the small magazines, use the small magazine sprite.

/obj/item/gun/projectile/ballistic/automatic/sts35/update_icon(ignore_inhands)
	. = ..()

	update_worn_icon()

/obj/item/gun/projectile/ballistic/automatic/wt550
	name = "machine pistol"
	desc = "The WT550 Saber is a cheap self-defense weapon mass-produced by Ward-Takahashi for paramilitary and private use. Uses 9mm rounds."
	icon_state = "wt550"
	item_state = "wt550"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = /datum/ammo_caliber/a9mm
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	ammo_type = "/obj/item/ammo_casing/a9mmr"
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a9mm/top_mount/rubber
	allowed_magazines = list(/obj/item/ammo_magazine/a9mm/top_mount)
	projectile_type = /obj/projectile/bullet/pistol/medium
	worth_intrinsic = 450

/obj/item/gun/projectile/ballistic/automatic/wt550/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "wt550-[round(ammo_magazine.amount_remaining(),4)]"
	else
		icon_state = "wt550"

/obj/item/gun/projectile/ballistic/automatic/wt550/lethal
	magazine_type = /obj/item/ammo_magazine/a9mm/top_mount

/datum/firemode/z8_bulldog
	burst_delay = 2

/datum/firemode/z8_bulldog/one
	name = "semiauto"
	burst_amount = 1
	legacy_direct_varedits = list(use_launcher=null, burst_accuracy=null, dispersion=null)

/datum/firemode/z8_bulldog/two
	name = "2-round bursts"
	burst_amount = 2
	legacy_direct_varedits = list(use_launcher=null, burst_accuracy=list(60,45), dispersion=list(0.0, 0.6))

/datum/firemode/z8_bulldog/grenade
	name = "fire grenades"
	legacy_direct_varedits = list(use_launcher=1,    burst_accuracy=null, dispersion=null)

/obj/item/gun/projectile/ballistic/automatic/z8
	name = "designated marksman rifle"
	desc = "The Z8 Bulldog is an older model designated marksman rifle, made by the now defunct Zendai Foundries. Makes you feel like a space marine when you hold it, even though it can only hold 10 round magazines. Uses 7.62mm rounds and has an under barrel grenade launcher."
	icon_state = "carbine" // This isn't a carbine. :T
	item_state = "z8carbine"
	wielded_item_state = "z8carbine-wielded"
	w_class = WEIGHT_CLASS_BULKY
	damage_force = 10
	caliber = /datum/ammo_caliber/a7_62mm
	origin_tech = list(TECH_COMBAT = 8, TECH_MATERIAL = 3)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a7_62mm
	allowed_magazines = list(/obj/item/ammo_magazine/a7_62mm)
	projectile_type = /obj/projectile/bullet/rifle/a762
	auto_eject = 1
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	mag_insert_sound = 'sound/weapons/guns/interaction/batrifle_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/batrifle_magout.ogg'
	heavy = TRUE
	one_handed_penalty = 60
	worth_intrinsic = 650 // milrp time

	firemodes = list(
		/datum/firemode/z8_bulldog/one,
		/datum/firemode/z8_bulldog/two,
		/datum/firemode/z8_bulldog/grenade,
	)

	var/use_launcher = 0
	var/obj/item/gun/launcher/grenade/underslung/launcher

/obj/item/gun/projectile/ballistic/automatic/z8/Initialize(mapload)
	. = ..()
	launcher = new(src)

/obj/item/gun/projectile/ballistic/automatic/z8/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/grenade)))
		launcher.load(I, user)
	else
		..()

/obj/item/gun/projectile/ballistic/automatic/z8/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(user.get_inactive_held_item() == src && use_launcher)
		launcher.unload(user)
	else
		..()

/obj/item/gun/projectile/ballistic/automatic/z8/fire(datum/gun_firing_cycle/cycle)
	if(use_launcher)
		launcher.fire(cycle)
		if(!launcher.chambered)
			set_firemode(get_next_firemode())
		return GUN_FIRED_SUCCESS
	return ..()

/obj/item/gun/projectile/ballistic/automatic/z8/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "carbine-[round(ammo_magazine.amount_remaining(),2)]"
	else
		icon_state = "carbine"

/obj/item/gun/projectile/ballistic/automatic/z8/update_icon()
	. = ..()
	update_worn_icon()

/obj/item/gun/projectile/ballistic/automatic/z8/examine(mob/user, dist)
	. = ..()
	if(launcher.chambered)
		. += "\The [launcher] has \a [launcher.chambered] loaded."
	else
		. += "\The [launcher] is empty."

/obj/item/gun/projectile/ballistic/automatic/lmg
	name = "light machine gun"
	desc = "A rather traditionally made L6 SAW with a pleasantly lacquered wooden pistol grip. 'Aussec Armoury-2531' is engraved on the reciever. Uses 5.56mm rounds. It's also compatible with magazines from STS-35 assault rifles."
	icon_state = "l6closed50"
	item_state = "l6closed"
	w_class = WEIGHT_CLASS_BULKY
	damage_force = 10
	slot_flags = 0
	max_shells = 50
	caliber = /datum/ammo_caliber/a5_56mm
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 2)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a5_56mm/saw
	allowed_magazines = list(/obj/item/ammo_magazine/a5_56mm/saw, /obj/item/ammo_magazine/a5_56mm)
	projectile_type = /obj/projectile/bullet/rifle/a556
	mag_insert_sound = 'sound/weapons/guns/interaction/lmg_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/lmg_magout.ogg'
	can_special_reload = FALSE
	heavy = TRUE
	one_handed_penalty = 75

	var/cover_open = 0

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, burst_accuracy=null, dispersion=null, automatic = 0),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=4,    burst_accuracy=list(0,-1,-1), dispersion=list(0.0, 0.6, 1.0), automatic = 0),
		list(mode_name="short bursts",	burst=5, move_delay=6, burst_accuracy = list(0,-1,-1,-2,-2), dispersion = list(0.6, 1.0, 1.0, 1.0, 1.2), automatic = 0),
		list(mode_name="automatic",       burst=1, fire_delay=-1,    move_delay=null, burst_accuracy=null, dispersion=null, automatic = 1)
		)

/*
	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=4,    burst_accuracy=list(60,30,0), dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="short bursts",	burst=5, move_delay=6, burst_accuracy = list(60,50,45,40,35), dispersion = list(0.6, 1.0, 1.0, 1.0, 1.2))
		)
*/

/obj/item/gun/projectile/ballistic/automatic/lmg/special_check(mob/user)
	if(cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is open! Close it before firing!</span>")
		return 0
	return ..()

/obj/item/gun/projectile/ballistic/automatic/lmg/proc/toggle_cover(mob/user)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	update_icon()
	update_worn_icon()

/obj/item/gun/projectile/ballistic/automatic/lmg/attack_self(mob/user, datum/event_args/actor/actor)
	if(cover_open)
		toggle_cover(user) //close the cover
	else
		return ..() //once closed, behave like normal

/obj/item/gun/projectile/ballistic/automatic/lmg/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(!cover_open && user.get_inactive_held_item() == src)
		toggle_cover(user) //open the cover
	else
		return ..() //once open, behave like normal

/obj/item/gun/projectile/ballistic/automatic/lmg/update_icon()
	. = ..()
	update_worn_icon()

/obj/item/gun/projectile/ballistic/automatic/lmg/update_icon_state()
	. = ..()
	if(istype(ammo_magazine,/obj/item/ammo_magazine/a7_62mm))
		icon_state = "l6[cover_open ? "open" : "closed"]mag"
		item_state = icon_state
	else
		icon_state = "l6[cover_open ? "open" : "closed"][ammo_magazine ? round(ammo_magazine.amount_remaining(), 10) : "-empty"]"
		item_state = "l6[cover_open ? "open" : "closed"][ammo_magazine ? "" : "-empty"]"

/obj/item/gun/projectile/ballistic/automatic/lmg/load_ammo(var/obj/item/A, mob/user)
	if(!cover_open)
		to_chat(user, "<span class='warning'>You need to open the cover to load [src].</span>")
		return
	..()

/obj/item/gun/projectile/ballistic/automatic/lmg/unload_ammo(mob/user, var/allow_dump=1)
	if(!cover_open)
		to_chat(user, "<span class='warning'>You need to open the cover to unload [src].</span>")
		return
	..()

//MG42 - It's an old gun, but it's just for fun!
/obj/item/gun/projectile/ballistic/automatic/lmg/mg42
	name = "MG 42"
	desc = "The MG 42 is an antique Terran machine gun, and very few original platforms have survived to the modern day. The Schwarzlindt Arms LTD manufacturer's stamp on the body marks this as a Frontier reproduction. It is no less deadly."
	icon_state = "mg42closed50"
	item_state = "mg42closed"
	max_shells = 50
	caliber = /datum/ammo_caliber/a7_62mm
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 1, TECH_ILLEGAL = 2)
	magazine_type = /obj/item/ammo_magazine/a7_62mm/mg42
	allowed_magazines = list(/obj/item/ammo_magazine/a7_62mm/mg42)
	one_handed_penalty = 100

/obj/item/gun/projectile/ballistic/automatic/lmg/mg42/update_icon_state()
	. = ..()
	icon_state = "mg42[cover_open ? "open" : "closed"][ammo_magazine ? round(ammo_magazine.amount_remaining(), 25) : "-empty"]"
	item_state = "mg42[cover_open ? "open" : "closed"][ammo_magazine ? "" : "-empty"]"

/obj/item/gun/projectile/ballistic/automatic/lmg/m60
	name = "M60"
	desc = "Affectionately dubbed 'The Pig' by the Old Earth soldiers assigned it, the M60 belt fed machine gun fell into disuse prior to the Final War, with no known original models surviving to the modern day. Several companies have since begun manufacturing faithful reproductions such as this one."
	icon_state = "M60closed75"
	item_state = "M60closed"
	max_shells = 75
	caliber = /datum/ammo_caliber/a7_62mm
	magazine_type = /obj/item/ammo_magazine/a7_62mm/m60
	allowed_magazines = list(/obj/item/ammo_magazine/a7_62mm/m60)
	projectile_type = /obj/projectile/bullet/rifle/a762
	one_handed_penalty = 100

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0, move_delay=null, burst_accuracy=null, dispersion=null, automatic = 0),
		list(mode_name="automatic", burst=2, fire_delay=-1, move_delay=null, burst_accuracy=null, dispersion=null, automatic = 1)
		)

/obj/item/gun/projectile/ballistic/automatic/lmg/m60/update_icon_state()
	. = ..()
	icon_state = "M60[cover_open ? "open" : "closed"][ammo_magazine ? round(ammo_magazine.amount_remaining(), 15) : "-empty"]"
	item_state = "M60[cover_open ? "open" : "closed"][ammo_magazine ? "" : "-empty"]"

//Future AA-12
/obj/item/gun/projectile/ballistic/automatic/as24
	name = "automatic shotgun"
	desc = "The AS-24 is a rugged looking automatic shotgun produced for the military by Gurov Projectile Weapons LLC. For very obvious reasons, it's illegal to own in many juristictions. Uses 12g rounds."
	icon_state = "ashot"
	item_state = "ashot"
	w_class = WEIGHT_CLASS_BULKY
	damage_force = 10
	caliber = /datum/ammo_caliber/a12g
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 4)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a12g/drum
	allowed_magazines = list(/obj/item/ammo_magazine/a12g/drum)
	projectile_type = /obj/projectile/bullet/shotgun
	heavy = TRUE
	one_handed_penalty = 30 //The AA12 can be fired one-handed fairly easily.
	mag_insert_sound = 'sound/weapons/guns/interaction/lmg_magin.ogg'
	mag_remove_sound = 'sound/weapons/guns/interaction/lmg_magout.ogg'

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0),
		list(mode_name="3-round bursts", burst=3, move_delay=6, burst_accuracy = list(60,40,30,25,15), dispersion = list(0.0, 0.6, 0.6)),
//		list(mode_name="6-round bursts", burst=6, move_delay=6, burst_accuracy = list(0,-15,-15,-30,-30, -30), dispersion = list(0.6, 1.0, 1.0, 1.0, 1.2, 1.2)),
		list(mode_name="automatic", burst=1, fire_delay=-1, move_delay=null, burst_accuracy=null, dispersion=null, automatic = 1)
		)

/obj/item/gun/projectile/ballistic/automatic/as24/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "ashot"
	else
		icon_state = "ashot-empty"
	return

/obj/item/gun/projectile/ballistic/automatic/mini_uzi
	name = "\improper Uzi"
	desc = "The iconic Uzi is a lightweight, compact, fast firing machine pistol. Cybersun Industries were the last major manufacturer of these designs, which have changed little since the 20th century. Uses .45 rounds."
	icon_state = "mini-uzi"
	w_class = WEIGHT_CLASS_NORMAL
	load_method = MAGAZINE
	caliber = /datum/ammo_caliber/a45
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ILLEGAL = 5)
	magazine_type = /obj/item/ammo_magazine/a45/uzi
	allowed_magazines = list(/obj/item/ammo_magazine/a45/uzi)

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0),
		list(mode_name="3-round bursts", burst=3, burst_delay=1, fire_delay=4, move_delay=4, burst_accuracy = list(60,40,30,20,15), dispersion = list(0.6, 1.0, 1.0))
		)

/obj/item/gun/projectile/ballistic/automatic/mini_uzi/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "mini-uzi"
	else
		icon_state = "mini-uzi-empty"

/obj/item/gun/projectile/ballistic/automatic/mini_uzi/custom
	name = "\improper custom Uzi"
	desc = "The iconic Uzi is a lightweight, compact, fast firing machine pistol. These traits make it a popular holdout option for Pathfinders assigned to hazardous expeditions. Uses .45 rounds."
	icon_state = "mini-uzi-custom"
	pin = /obj/item/firing_pin/explorer

/obj/item/gun/projectile/ballistic/automatic/mini_uzi/custom/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "mini-uzi-custom"
	else
		icon_state = "mini-uzi-custom-empty"

/obj/item/gun/projectile/ballistic/automatic/p90
	name = "personal defense weapon"
	desc = "The H90K is a compact, large capacity submachine gun produced by Hephaestus Industries. Despite its fierce reputation, it still manages to feel like a toy. Uses 5.7x28mm rounds."
	icon_state = "p90smg"
	item_state = "p90"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = /datum/ammo_caliber/a5_7mm
	fire_sound = 'sound/weapons/gunshot/gunshot_uzi.wav'
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT // ToDo: Belt sprite.
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a5_7mm/p90
	allowed_magazines = list(/obj/item/ammo_magazine/a5_7mm/p90) // ToDo: New sprite for the different mag.

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=4,    burst_accuracy=list(60,30,30), dispersion=list(0.0, 0.6, 1.0))
		)

/obj/item/gun/projectile/ballistic/automatic/p90/update_icon_state()
	. = ..()
	icon_state = "p90smg-[ammo_magazine ? round(ammo_magazine.amount_remaining(), 6) : "empty"]"

/obj/item/gun/projectile/ballistic/automatic/p90/custom
	name = "custom personal defense weapon"
	desc = "An H90K from Hephaestus Industries. This one has a different colored receiver and a sling."
	icon_state = "p90smgC"
	magazine_type = /obj/item/ammo_magazine/a5_7mm/p90/hunter
	slot_flags = SLOT_BELT|SLOT_BACK
	pin = /obj/item/firing_pin/explorer

/obj/item/gun/projectile/ballistic/automatic/p90/custom/update_icon_state()
	. = ..()
	icon_state = "p90smgC-[ammo_magazine ? round(ammo_magazine.amount_remaining(), 6) : "e"]"

/obj/item/gun/projectile/ballistic/automatic/tommygun
	name = "\improper Tommy Gun"
	desc = "This weapon was made famous by gangsters in the 20th century. Cybersun Industries began reproducing these for a target market of historic gun collectors and classy criminals. \
	After they dissolved, the same plans used by Cybersun are now used by countless small manufacturers and criminal organizations. Uses .45 rounds."
	icon_state = "tommygun"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = /datum/ammo_caliber/a45
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ILLEGAL = 5)
	slot_flags = SLOT_BELT // ToDo: Belt sprite.
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a45/tommy
	allowed_magazines = list(/obj/item/ammo_magazine/a45/tommy, /obj/item/ammo_magazine/a45/tommy/drum)

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=4,    burst_accuracy=list(60,30,25), dispersion=list(0.0, 0.6, 1.0))
		)

/obj/item/gun/projectile/ballistic/automatic/tommygun/update_icon_state()
	. = ..()
	icon_state = (ammo_magazine)? "tommygun" : "tommygun-empty"
//	update_worn_icon()

/obj/item/gun/projectile/ballistic/automatic/bullpup // Admin abuse assault rifle. ToDo: Make this less shit. Maybe remove its autofire, and make it spawn with only 10 rounds at start.
	name = "bullpup rifle"
	desc = "The bullpup configured GP3000 is a battle rifle produced by Gurov Projectile Weapons LLC. It is sold almost exclusively to standing armies. Uses 7.62mm rounds."
	icon_state = "bullpup-small"
	item_state = "bullpup"
	w_class = WEIGHT_CLASS_BULKY
	damage_force = 10
	caliber = /datum/ammo_caliber/a7_62mm
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 4)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a7_62mm
	allowed_magazines = list(/obj/item/ammo_magazine/a7_62mm, /obj/item/ammo_magazine/a7_62mm)
	projectile_type = /obj/projectile/bullet/rifle/a762
	heavy = TRUE
	one_handed_penalty = 45

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, burst_accuracy=null, dispersion=null),
		list(mode_name="2-round bursts", burst=2, fire_delay=null, move_delay=6,    burst_accuracy=list(60,45), dispersion=list(0.0, 0.6))
		)

/obj/item/gun/projectile/ballistic/automatic/bullpup/update_icon_state()
	. = ..()
	if(istype(ammo_magazine,/obj/item/ammo_magazine/a7_62mm))
		icon_state = "bullpup-small"

/obj/item/gun/projectile/ballistic/automatic/bullpup/update_icon()
	. = ..()
	update_worn_icon()

/obj/item/gun/projectile/ballistic/automatic/fal
	name = "FN-FAL"
	desc = "A 20th century Assault Rifle originally designed by Fabrique Nationale. Famous for its use by mercs in grinding proxy wars in backwater nations. This reproduction was probably made for similar purposes."
	icon_state = "fal"
	item_state = "fal"
	w_class = WEIGHT_CLASS_BULKY
	damage_force = 10
	caliber = /datum/ammo_caliber/a7_62mm
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 4)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a7_62mm
	allowed_magazines = list(/obj/item/ammo_magazine/a7_62mm, /obj/item/ammo_magazine/a7_62mm)
	heavy = TRUE
	projectile_type = /obj/projectile/bullet/rifle/a762

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, burst_accuracy=null, dispersion=null),
		list(mode_name="2-round bursts", burst=2, fire_delay=null, move_delay=6,    burst_accuracy=list(60,35), dispersion=list(0.0, 0.6))
		)

/obj/item/gun/projectile/ballistic/automatic/fal/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-empty"

/obj/item/gun/projectile/ballistic/automatic/automat
	name = "Avtomat Rifle"
	desc = " A Bolt Action Rifle taken apart and retooled into a primitive machine gun. Bulky and obtuse, it still capable of unleashing devastating firepower with its 15 round internal drum magazine. Loads with 7.62 stripper clips."
	icon_state = "automat"
	item_state = "automat"
	// fire_anim = "automat_fire"
	w_class = WEIGHT_CLASS_BULKY
	damage_force = 10
	caliber = /datum/ammo_caliber/a7_62mm
	heavy = TRUE
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3) //A real work around to a automatic rifle.
	slot_flags = SLOT_BACK
	load_method = SPEEDLOADER
	ammo_type = /obj/item/ammo_casing/a7_62mm
	max_shells =  15
	firemodes = /datum/firemode{
		burst_amount = 3;
		burst_delay = 0.25 SECONDS;
		cycle_cooldown = 0.72 SECONDS;
	}
	burst_accuracy = list(60,30,15)
	dispersion = list(0.0, 0.6,1.0)

/obj/item/gun/projectile/ballistic/automatic/automat/holy
	ammo_type = /obj/item/ammo_casing/a7_62mm/silver

/obj/item/gun/projectile/ballistic/automatic/holyshot
	name = "Holy automatic shotgun"
	desc = "Based off of an ancient design, this hand crafted weapon has been gilded with the gold of melted icons and inscribed with sacred runes and hexagrammic wards. Works best with blessed 12g rounds."
	icon_state = "holyshotgun"
	item_state = "holy_shot"
	w_class = WEIGHT_CLASS_BULKY
	heavy = TRUE
	damage_force = 10
	caliber = /datum/ammo_caliber/a12g
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 4)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a12g/drum/holy
	allowed_magazines = list(/obj/item/ammo_magazine/a12g/drum/holy, /obj/item/ammo_magazine/a12g/drum/holy/stake)
	projectile_type = /obj/projectile/bullet/shotgun

	one_handed_penalty = 40

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0),
		list(mode_name="2-round burst", burst=2, move_delay=6, burst_accuracy = list(60,50,40,30,25), dispersion = list(0.0, 0.6, 0.6))
		)

/obj/item/gun/projectile/ballistic/automatic/holyshot/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "holyshotgun"
	else
		icon_state = "holyshotgun-empty"

//Clown Rifle
/obj/item/gun/projectile/ballistic/automatic/clown_rifle
	name = "clown assault rifle"
	desc = "The WSS-29m6 is the latest version of the standard Columbina service rifle. Originally a cheap knock-off of the STS-35, the m6 now matches its inspiration in durability. Utilizing a proprietary ROF system, the m6 is able to fire unorthodox, yet effective, weaponry."
	icon_state = "clownrifle"
	item_state = "clownrifle"
	wielded_item_state = "clownrifle_wielded"
	w_class = WEIGHT_CLASS_BULKY
	heavy = TRUE
	damage_force = 10
	caliber = /datum/ammo_caliber/biomatter
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 4)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/biomatter/large/banana
	allowed_magazines = list(/obj/item/ammo_magazine/biomatter/large/banana)
	projectile_type = /obj/projectile/bullet/organic

	one_handed_penalty = 30

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, burst_accuracy=null, dispersion=null),
		list(mode_name="3-round bursts", burst=3, fire_delay=null, move_delay=6,    burst_accuracy=list(60,50,45), dispersion=list(0.0, 0.6, 0.6))
//		list(mode_name="short bursts", 	burst=5, fire_delay=null, move_delay=6,    burst_accuracy=list(0,-15,-30,-30,-45), dispersion=list(0.6, 1.0, 1.0, 1.0, 1.2)),
		)

/obj/item/gun/projectile/ballistic/automatic/clown_rifle/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]-empty"

//Muh Alternator
/obj/item/gun/projectile/ballistic/automatic/wt274
	name = "alternating barrel SMG"
	desc = "Although it experienced an initially successful production run, the WT274 AB-SMG was discontinued in favor of the more reliable WT550. Utilizing a twin-linked barrel assembly, the WT274's ammo consumption was a major factor in its retirement."
	icon_state = "wt274"
	item_state = "gun"
	load_method = MAGAZINE
	caliber = /datum/ammo_caliber/a45
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ILLEGAL = 5)
	magazine_type = /obj/item/ammo_magazine/a45/wt274
	allowed_magazines = list(/obj/item/ammo_magazine/a45/wt274)
	one_handed_penalty = 10

	firemodes = list(
		list(mode_name="standard fire", burst=2, fire_delay=0),
		list(mode_name="double tap", burst=4, burst_delay=1, fire_delay=4, move_delay=2, burst_accuracy = list(40,30,20,15), dispersion = list(0.6, 0.6, 1.0, 1.0))
		)

/obj/item/gun/projectile/ballistic/automatic/wt274/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]-empty"

//NT SpecOps SMG
/obj/item/gun/projectile/ballistic/automatic/combat
	name = "\improper Harpy combat submachine gun"
	desc = "The compact NT-SMG-8 'Harpy' submachine gun was designed for Nanotrasen special operations where close-quarters combat is likely. Chambered in 5.7x28mm with three fire modes, this gun is lethal to soft and armored targets alike."
	icon_state = "combatsmg"
	item_state = "combatsmg"
	w_class = WEIGHT_CLASS_NORMAL
	caliber = /datum/ammo_caliber/a5_7mm
	fire_sound = 'sound/weapons/gunshot/gunshot_uzi.wav'
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 2)
	slot_flags = SLOT_BELT
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/a5_7mm/harpy_smg/ap
	allowed_magazines = list(/obj/item/ammo_magazine/a5_7mm/harpy_smg)

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0),
		list(mode_name="3-round burst", burst=3, fire_delay=null, move_delay=4, burst_accuracy=list(60,30,30), dispersion=list(0.0, 0.6, 1.0)),
		list(mode_name="automatic", burst=1, fire_delay=-1, move_delay=null, burst_accuracy=null, dispersion=null, automatic = 1)
		)

/obj/item/gun/projectile/ballistic/automatic/combat/update_icon_state()
	. = ..()
	icon_state = (ammo_magazine)? "combatsmg" : "combatsmg-empty"

// Please don't spawn these regularly. I'm mostly just adding these for fun.
/obj/item/gun/projectile/ballistic/automatic/bolter
	name = "\improper Ballistae bolt rifle"
	desc = "A boxy rifle clearly designed for larger hands. Uses .75 gyrojet rounds."
	description_fluff = "The HI-GP mk 8 'Ballistae' is a bulky weapon designed to fire an obscenely robust .75 caliber gyrojet round with an explosive payload. The original design was sourced from Old Earth speculative documentation, and developed to test its efficacy. Although the weapon itself is undeniably powerful, its logistical demands, the recoil of the three-stage ammunition system, and its hefty size make it untenable on the modern battlefield."
	icon_state = "bolter"
	item_state = "bolter"
	caliber = /datum/ammo_caliber/a75
	origin_tech = list(TECH_COMBAT = 5, TECH_ILLEGAL = 2)
	load_method = MAGAZINE
	fire_sound = 'sound/weapons/gunshot/gunshot_bolter.ogg'
	max_shells = 30
	magazine_type = /obj/item/ammo_magazine/a75/rifle
	allowed_magazines = list(/obj/item/ammo_magazine/a75/rifle)
	heavy = TRUE
	one_handed_penalty = 80

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0),
		list(mode_name="automatic", burst=1, fire_delay=-1, move_delay=null, burst_accuracy=null, dispersion=null, automatic = 1)
		)

/obj/item/gun/projectile/ballistic/automatic/bolter/update_icon_state()
	. = ..()
	icon_state = "bolter-[ammo_magazine ? round(ammo_magazine.amount_remaining(), 2) : "empty"]"

/obj/item/gun/projectile/ballistic/automatic/bolter/storm
	name = "\improper Onager heavy bolt rifle"
	desc = "A hulking automatic weapon more fit for a crew serve position than personal use. Uses .75 gyrojet rounds."
	description_fluff = "The HI-GP mk 2 'Onager' may perhaps be considered the one successful prototype to come out of Hephaestus' reclamatory efforts. Thanks to its large size many of the issues with ease of maintenance were successfully mitigated. However, the expense of replacing parts and the cost of the weapon's exotic ammunition still resulted in the inititative being considered a failure."
	icon_state = "stormbolter"
	item_state = "stormbolter"
	max_shells = 50
	magazine_type = /obj/item/ammo_magazine/a75/box
	allowed_magazines = list(/obj/item/ammo_magazine/a75/box)
	one_handed_penalty = 100

	firemodes = list(
		list(mode_name="semiauto", burst=1, fire_delay=0),
		list(mode_name="automatic", burst=2, fire_delay=-1, move_delay=null, burst_accuracy=null, dispersion=null, automatic = 1)
		)

/obj/item/gun/projectile/ballistic/automatic/bolter/storm/update_icon_state()
	. = ..()
	icon_state = "stormbolter-[ammo_magazine ? round(ammo_magazine.amount_remaining(), 10) : "empty"]"

//Foam Weapons
/obj/item/gun/projectile/ballistic/automatic/advanced_smg/foam
	name = "toy submachine gun"
	desc = "The existence of this DONKsoft toy has instigated allegations of corporate espionage from Nanotrasen."
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_smg"
	caliber = /datum/ammo_caliber/foam
	magazine_type = /obj/item/ammo_magazine/foam/smg
	allowed_magazines = list(/obj/item/ammo_magazine/foam/smg)
	fire_sound = 'sound/items/syringeproj.ogg'

/obj/item/gun/projectile/ballistic/automatic/advanced_smg/foam/update_icon_state()
	. = ..()
	icon_state = (ammo_magazine)? "toy_smg" : "toy_smg-empty"

/obj/item/gun/projectile/ballistic/automatic/advanced_smg/foam/blue
	icon_state = "toy_smg_blue"

/obj/item/gun/projectile/ballistic/automatic/advanced_smg/foam/blue/update_icon_state()
	. = ..()
	icon_state = (ammo_magazine)? "toy_smg_blue" : "toy_smg_blue-empty"

//Foam c20r
/obj/item/gun/projectile/ballistic/automatic/c20r/foam
	name = "toy submachine gun"
	desc = "A DONKsoft rendition of an infamous submachine gun."
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_c20"
	damage_force = 5
	caliber = /datum/ammo_caliber/foam
	magazine_type = /obj/item/ammo_magazine/foam/smg
	allowed_magazines = list(/obj/item/ammo_magazine/foam/smg)
	projectile_type = /obj/projectile/bullet/reusable/foam
	one_handed_penalty = 5
	fire_sound = 'sound/items/syringeproj.ogg'

/obj/item/gun/projectile/ballistic/automatic/c20r/foam/update_icon_state()
	. = ..()
	if(ammo_magazine)
		icon_state = "toy_c20r-[round(ammo_magazine.amount_remaining(),4)]"
	else
		icon_state = "toy_c20r"

//Foam LMG
/obj/item/gun/projectile/ballistic/automatic/lmg/foam
	name = "toy light machine gun"
	desc = "This plastic replica of a common light machine gun weighs about half as much. It's still pretty bulky, but nothing lays down suppressive fire like this bad boy. The bane of schoolyards across the galaxy."
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_lmgclosed100"
	damage_force = 5
	caliber = /datum/ammo_caliber/foam
	magazine_type = /obj/item/ammo_magazine/foam/lmg
	allowed_magazines = list(/obj/item/ammo_magazine/foam/lmg)
	projectile_type = /obj/projectile/bullet/reusable/foam
	one_handed_penalty = 45 //It's plastic.
	fire_sound = 'sound/items/syringeproj.ogg'
	heavy = FALSE
	one_handed_penalty = 25

/obj/item/gun/projectile/ballistic/automatic/lmg/foam/update_icon_state()
	. = ..()
	icon_state = "toy_lmg[cover_open ? "open" : "closed"][ammo_magazine ? round(ammo_magazine.amount_remaining(), 10) : "-empty"]"
	item_state = "toy_lmg[cover_open ? "open" : "closed"][ammo_magazine ? "" : "-empty"]"

/obj/item/gun/projectile/ballistic/automatic/lmg/foam/update_icon()
	. = ..()
	update_worn_icon()
