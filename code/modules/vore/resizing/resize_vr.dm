
//these aren't defines so they can stay in this file
var/const/RESIZE_HUGE = 2
var/const/RESIZE_BIG = 1.5
var/const/RESIZE_NORMAL = 1
/// god forgive me for i have sinned by using a const
var/const/RESIZE_PREF_LIMIT = 0.75
var/const/RESIZE_SMALL = 0.5
var/const/RESIZE_TINY = 0.25

//average
var/const/RESIZE_A_HUGEBIG = (RESIZE_HUGE + RESIZE_BIG) / 2
var/const/RESIZE_A_BIGNORMAL = (RESIZE_BIG + RESIZE_NORMAL) / 2
var/const/RESIZE_A_NORMALSMALL = (RESIZE_NORMAL + RESIZE_SMALL) / 2
var/const/RESIZE_A_SMALLTINY = (RESIZE_SMALL + RESIZE_TINY) / 2

// Adding needed defines to /mob/living
// Note: Polaris had this on /mob/living/carbon/human We need it higher up for animals and stuff.
/mob/living
	var/holder_default

// Define holder_type on types we want to be scoop-able
/mob/living/carbon/human
	holder_type = /obj/item/holder/micro

// The reverse lookup of player_sizes_list, number to name.
/proc/player_size_name(var/size_multiplier)
	// (This assumes list is sorted big->small)
	for(var/N in player_sizes_list)
		. = N // So we return the smallest if we get to the end
		if(size_multiplier >= player_sizes_list[N])
			return N

/**
 * Scale up the size of a mob's icon by the size_multiplier.
 * NOTE: mob/living/carbon/human/update_icons() has a more complicated system and
 * 	is already applying this transform.   BUT, it does not call ..()
 *	as long as that is true, we should be fine.  If that changes we need to
 *	re-evaluate.
 */
/mob/living/update_icons()
	. = ..()
	ASSERT(!ishuman(src))
	var/matrix/M = matrix()
	M.Scale(size_multiplier * icon_scale_x, size_multiplier * icon_scale_y)
	src.transform = M

/**
 * Get the effective size of a mob.
 * Currently this is based only on size_multiplier for micro/macro stuff,
 * but in the future we may also incorporate the "mob_size", so that
 * a macro mouse is still only effectively "normal" or a micro dragon is still large etc.
 */
/mob/proc/get_effective_size()
	return 100000 //Whatever it is, it's too big to pick up, or it's a ghost, or something.

/mob/living/get_effective_size()
	return src.size_multiplier

/**
 * Resizes the mob immediately to the desired mod, animating it growing/shrinking.
 * It can be used by anything that calls it.
 */
/mob/living/proc/resize(var/new_size, var/animate = FALSE, var/ignore_cooldown = FALSE)
	if(size_multiplier == new_size)
		return 1
	if(!ignore_cooldown && last_special > world.time)
		to_chat(src, SPAN_WARNING("You are trying to resize to fast!"))
		return 0
	var/change = new_size - size_multiplier
	size_multiplier = new_size //Change size_multiplier so that other items can interact with them
	if(animate)
		var/duration = (abs(change * 5)+0.25) SECONDS
		var/matrix/resize = matrix() // Defines the matrix to change the player's size
		resize.Scale(new_size * icon_scale_x, size_multiplier * icon_scale_y) //Change the size of the matrix
		resize.Translate(0, 16 * (new_size - 1)) //Move the player up in the tile so their feet align with the bottom
		animate(src, transform = resize, time = duration) //Animate the player resizing
		last_special = world.time + duration
	else
		update_transform() //Lame way
		last_special = world.time + base_attack_cooldown

/mob/living/carbon/human/resize(var/new_size, var/animate = TRUE)
	. = ..()
	if(atom_huds)
		//it lowers lesser than it raises when it comes to micros v. macros else the medHUD would bury the micro
		var/new_y_offset = (size_multiplier < 1 ? 27 : 32) * (size_multiplier - 1)
		for(var/id in atom_huds)
			var/image/image = atom_huds[id]
			image.pixel_y = new_y_offset

// Optimize mannequins - never a point to animating or doing HUDs on these.
/mob/living/carbon/human/dummy/mannequin/resize(var/new_size, var/animate = TRUE)
	size_multiplier = new_size

/**
 * Verb proc for a command that lets players change their size OOCly.
 * Ace was here! Redid this a little so we'd use math for shrinking characters. This is the old code.
 */


/mob/living/proc/set_size()
	set name = "Adjust Mass"
	set category = "Abilities" //Seeing as prometheans have an IC reason to be changing mass.

	var/nagmessage = "Adjust your mass to be a size between 25 to 200% (DO NOT ABUSE)"
	var/new_size = input(nagmessage, "Pick a Size") as num|null
	if(new_size && ISINRANGE(new_size,25,200))
		src.resize(new_size/100, TRUE)
		message_admins("[key_name(src)] used the resize command in-game to be [new_size]% size. \
			([src ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>" : "null"])")

/**
 * Attempt to scoop up this mob up into M's hands, if the size difference is large enough.
 * @return false if normal code should continue, true to prevent normal code.
 */
/mob/living/proc/attempt_to_scoop(var/mob/living/M)
	var/size_diff = M.get_effective_size() - get_effective_size()
	if(!holder_default && holder_type)
		holder_default = holder_type
	if(!istype(M) || !M.has_hands())
		return FALSE
	if(M.get_active_held_item() && !istype(M.get_active_held_item(), /obj/item/grab)) //scooper's hand is holding something that isn't a grab.
		to_chat(M, SPAN_WARNING("You can't pick up someone with your occupied hand."))
		return TRUE
	if(M.buckled)
		to_chat(usr, SPAN_NOTICE("You have to unbuckle \the [M] before you pick them up."))
		return FALSE
	if(size_diff >= 0.50)
		// if the person being scooped up is past a set size limit then the pickup pref is applied
		if(get_effective_size() >= RESIZE_PREF_LIMIT && !permit_size_pickup)
			if(M.check_grab(src)) //requires a grab of any kind before they can commence a "fair gameplay" scoopup. about the same prereqs as a fireman carry
				to_chat(M, SPAN_NOTICE("You attempt to scoop up \the [src]."))
				to_chat(src, SPAN_USERDANGER("[M] is attempting to scoop you up!")) //big red text so they know they're about to get bad-touched
				if(!do_after(M, 3 SECONDS, src))
					return TRUE
			else
				var/datum/gender/G = GLOB.gender_datums[src.get_visible_gender()]
				to_chat(M, SPAN_WARNING("[src] is far too skittish to casually scoop up. Try grabbing [G.him] first."))
				return FALSE
		holder_type = /obj/item/holder/micro
		if(M.get_active_held_item()) //drop the grab before scooping - should be the only item that passes at this point
			M.drop_active_held_item()
		var/obj/item/holder/m_holder = get_scooped(M)
		holder_type = holder_default
		if (m_holder)
			return TRUE
		else
			return FALSE; // Unable to scoop, let other code run

//! Fuck you.
#define STEP_TEXT_OWNER_NON_SHITCODE(x, m) "[replacetext(x,"%prey",m)]"
#define STEP_TEXT_PREY_NON_SHITCODE(x, m) "[replacetext(x,"%owner",m)]"
// they're bigger
#define WE_RAN_BETWEEN_THEIR_LEGS			1
// we're bigger
#define THEY_RAN_BETWEEN_OUR_LEGS			2
#define WE_ARE_BOTH_MICROS					3
#define NEITHER_OF_US_ARE_FETISH_CONTENT	4

//! call this from the bumping side aka the mob that ran into other, not the other way around
/mob/living/proc/fetish_hook_for_help_intent_swapping(mob/living/other)
	if(a_intent != INTENT_HELP)
		return FALSE
	switch(stupid_fucking_micro_canpass_fetish_check(other))
		if(WE_ARE_BOTH_MICROS)
			return TRUE
		if(NEITHER_OF_US_ARE_FETISH_CONTENT)
			return FALSE
		// they are bigger and we just ran under them
		if(WE_RAN_BETWEEN_THEIR_LEGS)
			other.inform_someone_they_just_ran_under_you(src)
			return TRUE
		// we are bigger and just stepped over a micro
		if(THEY_RAN_BETWEEN_OUR_LEGS)
			inform_someone_you_just_stepped_over_them(other)
			return TRUE

/mob/living/proc/stupid_fucking_micro_canpass_fetish_check(mob/living/crossing)
	var/hatred = a_intent != INTENT_HELP || crossing.a_intent != INTENT_HELP
	if(hatred)
		return NEITHER_OF_US_ARE_FETISH_CONTENT
	if(get_effective_size() <= RESIZE_A_SMALLTINY && crossing.get_effective_size() <= RESIZE_A_SMALLTINY)
		return WE_ARE_BOTH_MICROS
	var/diff = get_effective_size() - crossing.get_effective_size()
	if(abs(diff) < 0.50)
		return NEITHER_OF_US_ARE_FETISH_CONTENT
	return diff > 0? THEY_RAN_BETWEEN_OUR_LEGS : WE_RAN_BETWEEN_THEIR_LEGS

/mob/living/proc/inform_someone_you_just_stepped_over_them(mob/living/micro)
	var/mob/living/carbon/human/H
	var/datum/sprite_accessory/tail/legacy_taur/tail
	tail = ishuman(src)? ((H = src) && isTaurTail(H.tail_style) && H.tail_style) : null
	to_chat(src, tail? STEP_TEXT_OWNER_NON_SHITCODE(tail.msg_owner_help_run, micro) : "You carefully step over [micro].")
	to_chat(micro, tail? STEP_TEXT_PREY_NON_SHITCODE(tail.msg_prey_help_run, src) : "[src] carefully steps over you.")

/mob/living/proc/inform_someone_they_just_ran_under_you(mob/living/micro)
	var/mob/living/carbon/human/H
	var/datum/sprite_accessory/tail/legacy_taur/tail
	tail = ishuman(src)? ((H = src) && isTaurTail(H.tail_style) && H.tail_style) : null
	to_chat(micro, tail? STEP_TEXT_OWNER_NON_SHITCODE(tail.msg_prey_stepunder, src) : "You run between [src]'s legs.")
	to_chat(src, tail? STEP_TEXT_PREY_NON_SHITCODE(tail.msg_owner_stepunder, micro) : "[micro] runs between your legs.")

//! sigh, we can't do this yet
/*
/mob/living/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isliving(mover))
		var/fetish_content_check = stupid_fucking_micro_canpass_fetish_check(mover)
		if(fetish_content_check != NEITHER_OF_US_ARE_FETISH_CONTENT)
			return TRUE

/mob/lving/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM))
		var/fetish_content_check = stupid_fucking_micro_canpass_fetish_check(mover)
		var/mob/living/carbon/human/H
		var/datum/sprite_accessory/tail/legacy_taur/tail
		switch(fetish_content_check)
			if(NEITHER_OF_US_ARE_FETISH_CONTENT, WE_ARE_BOTH_MICROS)
				return
			// macro walked onto our tile
			if(WE_RAN_BETWEEN_THEIR_LEGS)
				tail = ishuman(AM) && (H = AM) && isTaurTail(H.tail_style) && H.tail_style
				to_chat(AM, STEP_TEXT_OWNER_NON_SHITCODE(tail?.msg_owner_help_run, AM) || "You carefully step over [src].")
				to_chat(src, STEP_TEXT_PREY_NON_SHITCODE(tail?.msg_prey_help_run, src) || "[AM] carefully steps over you.")
			// micro ran onto our tile
			if(THEY_RAN_BETWEEN_OUR_LEGS)
				tail = ishuman(src) && (H = src) && isTaurTail(H.tail_style) && H.tail_style
				to_chat(AM, STEP_TEXT_PREY_NON_SHITCODE(tail?.msg_prey_stepunder, src),  || "You run between [src]'s legs.")
				to_chat(src, STEP_TEXT_OWNER_NON_SHITCODE(tail?.msg_owner_stepunder, AM) || "[AM] runs between your legs.")
*/

#undef WE_RAN_BETWEEN_THEIR_LEGS
#undef THEY_RAN_BETWEEN_OUR_LEGS
#undef WE_ARE_BOTH_MICROS
#undef NEITHER_OF_US_ARE_FETISH_CONTENT
#undef STEP_TEXT_OWNER_NON_SHITCODE
#undef STEP_TEXT_PREY_NON_SHITCODE

#define STEP_TEXT_OWNER(x) "[replacetext(x,"%prey",tmob)]"
#define STEP_TEXT_PREY(x) "[replacetext(x,"%owner",src)]"

/**
 * we bumped into other
 */
/mob/living/proc/fetish_hook_for_non_help_intent_bumps(mob/living/other)
	if(a_intent == INTENT_HELP)
		return FALSE
	// flatten to true/false
	return !!handle_micro_bump_other(other)

/**
 * Handle bumping into someone without mutual help intent.
 * Called from /mob/living/Bump()
 *
 * @return false if normal code should continue, 1 to prevent normal code.
 */
/mob/living/proc/handle_micro_bump_other(var/mob/living/tmob)
	ASSERT(istype(tmob))

	//If they're flying, don't do any special interactions.
	if(ishuman(src))
		var/mob/living/carbon/human/P = src
		if(P.flying)
			return

	//If the prey is flying, don't smush them.
	if(ishuman(tmob))
		var/mob/living/carbon/human/D = tmob
		if(D.flying)
			return

	//They can't be stepping on anyone
	if(!CHECK_MOBILITY(src, MOBILITY_CAN_MOVE))
		return

	//Test/set if human
	var/mob/living/carbon/human/H
	if(ishuman(src))
		H = src
	else
		//If we're not human, can't do the steppy
		return FALSE

	var/mob/living/carbon/human/Ht
	if(ishuman(tmob))
		Ht = tmob
	else
		//If they're not human, steppy shouldn't happen
		return FALSE

	if(tmob.get_effective_size() >= RESIZE_PREF_LIMIT && !tmob.permit_size_trample)
		if((get_effective_size() - tmob.get_effective_size()) >= 0.75)
			to_chat(src, "<span class='warning'>[tmob] skitters past your legs.</span>")
			to_chat(tmob, "<span class='warning'>You narrowly dodge [src]'s step.</span>")
		return

	//Depending on intent...
	switch(a_intent)

		//src stepped on someone with disarm intent
		if(INTENT_DISARM)
			// If bigger than them by at least 0.75, move onto them and print message.
			if((get_effective_size() - tmob.get_effective_size()) >= 0.75)

				//Running on INTENT_DISARM
				if(m_intent == "run")
					tmob.resting = 1 //Force them down to the ground.

					//Log it for admins (as opposed to walk which logs damage)
					add_attack_logs(src,tmob,"Pinned underfoot (run, no halloss)")

					//Not a human, or not a taur, generic message only
					if(!H || !isTaurTail(H.tail_style))
						to_chat(src,"<span class='danger'>You quickly push [tmob] to the ground with your foot!</span>")
						to_chat(tmob,"<span class='danger'>[src] pushes you down to the ground with their foot!</span>")

					//Human with taur tail, special messages are sent
					else
						var/datum/sprite_accessory/tail/legacy_taur/tail = H.tail_style
						to_chat(src,STEP_TEXT_OWNER("<span class='danger'>[tail.msg_owner_disarm_run]</span>"))
						to_chat(tmob,STEP_TEXT_PREY("<span class='danger'>[tail.msg_prey_disarm_run]</span>"))

				//Walking on INTENT_DISARM
				else
					//Perform some HALLOSS damage to the smaller.
					var/size_damage_multiplier = (src.size_multiplier - tmob.size_multiplier)
					var/damage = (rand(15,30)* size_damage_multiplier) //Since stunned is broken, let's do this. Rand 15-30 multiplied by 1 min or 1.75 max. 15 holo to 52.5 holo, depending on RNG and size differnece.
					tmob.apply_damage(damage, DAMAGE_TYPE_HALLOSS)
					tmob.resting = 1

					//Log it for admins (as opposed to run which logs no damage)
					add_attack_logs(src,tmob,"Pinned underfoot (walk, about [damage] halloss)")

					//Not a human, or not a taur, generic message only
					if(!H || !isTaurTail(H.tail_style))
						to_chat(src,"<span class='danger'>You firmly push your foot down on [tmob], painfully but harmlessly pinning them to the ground!</span>")
						to_chat(tmob,"<span class='danger'>[src] firmly pushes their foot down on you, quite painfully but harmlessly pinning you to the ground!</span>")

					//Human with taur tail, special messages are sent
					else
						var/datum/sprite_accessory/tail/legacy_taur/tail = H.tail_style
						to_chat(src,STEP_TEXT_OWNER("<span class='danger'>[tail.msg_owner_disarm_walk]</span>"))
						to_chat(tmob,STEP_TEXT_PREY("<span class='danger'>[tail.msg_prey_disarm_walk]</span>"))

				//Return true, the sizediff was enough that we handled it.
				return TRUE

			//Not enough sizediff for INTENT_DISARM to do anything.
			else
				return FALSE

		//src stepped on someone with harm intent
		if(INTENT_HARM)
			// If bigger than them by at least 0.75, move onto them and print message.
			if((get_effective_size() - tmob.get_effective_size()) >= 0.75)
				forceMove(tmob.loc)

				//Precalculate base damage
				var/size_damage_multiplier = (src.size_multiplier - tmob.size_multiplier)
				var/damage = (rand(1,3)* size_damage_multiplier) //Rand 1-3 multiplied by 1 min or 1.75 max. 1 min 5.25 max damage to each limb.
				var/calculated_damage = damage/2 //This will sting, but not kill. Does .5 to 2.625 damage, randomly, to each limb.

				//Running on INTENT_HARM
				if(m_intent == "run")

					//Not a human, or not a taur, generic message only
					if(!H || !isTaurTail(H.tail_style))
						to_chat(src,"<span class='danger'>You carelessly step down onto [tmob], crushing them!</span>")
						to_chat(tmob,"<span class='danger'>[src] steps carelessly on your body, crushing you!</span>")

					//Human with taur tail, special messages are sent
					else
						var/datum/sprite_accessory/tail/legacy_taur/tail = H.tail_style
						to_chat(src,STEP_TEXT_OWNER("<span class='danger'>[tail.msg_owner_harm_run]</span>"))
						to_chat(tmob,STEP_TEXT_PREY("<span class='danger'>[tail.msg_prey_harm_run]</span>"))

					//If they are a human, do damage (doesn't hurt other mobs...?)
					if(Ht)
						for(var/obj/item/organ/external/I in Ht.organs)
							I.inflict_bodypart_damage(
								brute = calculated_damage,
							)
						Ht.drip(0.1)
						add_attack_logs(src,tmob,"Crushed underfoot (run, about [calculated_damage] damage)")

				//Walking on INTENT_HARM
				else
					//Multiplies the above damage by 3.5. This means a min of 1.75 damage, or a max of 9.1875. damage to each limb, depending on size and RNG.
					calculated_damage *= 3.5

					//If they are a human, do damage (doesn't hurt other mobs...?)
					if(Ht)
						for(var/obj/item/organ/external/E in Ht.get_damageable_external_organs())
							E.inflict_bodypart_damage(
								brute = calculated_damage,
							)
						Ht.drip(3)
						add_attack_logs(src,tmob,"Crushed underfoot (walk, about [calculated_damage] damage)")

					//Not a human, or not a taur, generic message only
					if(!H || !isTaurTail(H.tail_style))
						to_chat(src,"<span class='danger'>You methodically place your foot down upon [tmob]'s body, slowly applying pressure, crushing them against the floor below!</span>")
						to_chat(tmob,"<span class='danger'>[src] methodically places their foot upon your body, slowly applying pressure, crushing you against the floor below!</span>")

					//Human with taur tail, special messages are sent
					else
						var/datum/sprite_accessory/tail/legacy_taur/tail = H.tail_style
						to_chat(src,STEP_TEXT_OWNER("<span class='danger'>[tail.msg_owner_harm_walk]</span>"))
						to_chat(tmob,STEP_TEXT_PREY("<span class='danger'>[tail.msg_prey_harm_walk]</span>"))

				//Return true, the sizediff was enough that we handled it.
				return TRUE

			//Not enough sizediff for INTENT_HARM to do anything.
			else
				return FALSE

		//src stepped on someone with grab intent
		if(INTENT_GRAB)
			// If bigger than them by at least 0.50, move onto them and print message.
			if((get_effective_size() - tmob.get_effective_size()) >= 0.50)
				tmob.resting = 1
				forceMove(tmob.loc)

				//Not a human, or not a taur while wearing shoes = no grab
				if(!H || (!isTaurTail(H.tail_style) && H.shoes))
					to_chat(src,"<span class='danger'>You step down onto [tmob], squishing them and forcing them down to the ground!</span>")
					to_chat(tmob,"<span class='danger'>[src] steps down and squishes you with their foot, forcing you down to the ground!</span>")
					add_attack_logs(src,tmob,"Grabbed underfoot (nontaur, shoes)")

				//Human, not a taur, but not wearing shoes = yes grab
				else if(H && (!isTaurTail(H.tail_style) && !H.shoes))
					to_chat(src,"<span class='danger'>You pin [tmob] down onto the floor with your foot and curl your toes up around their body, trapping them in between them!</span>")
					to_chat(tmob,"<span class='danger'>[src] pins you down to the floor with their foot and curls their toes up around your body, trapping you in between them!</span>")
					equip_to_slot_if_possible(tmob.get_scooped(H), SLOT_ID_SHOES, INV_OP_SILENT)
					add_attack_logs(src,tmob,"Grabbed underfoot (nontaur, no shoes)")

				//Human, taur, shoes = no grab, special message
				else if(H.shoes)
					var/datum/sprite_accessory/tail/legacy_taur/tail = H.tail_style
					to_chat(src,STEP_TEXT_OWNER("<span class='danger'>[tail.msg_owner_grab_fail]</span>"))
					to_chat(tmob,STEP_TEXT_PREY("<span class='danger'>[tail.msg_prey_grab_fail]</span>"))
					add_attack_logs(src,tmob,"Grabbed underfoot (taur, shoes)")

				//Human, taur, no shoes = yes grab, special message
				else
					var/datum/sprite_accessory/tail/legacy_taur/tail = H.tail_style
					to_chat(src,STEP_TEXT_OWNER("<span class='danger'>[tail.msg_owner_grab_success]</span>"))
					to_chat(tmob,STEP_TEXT_PREY("<span class='danger'>[tail.msg_prey_grab_success]</span>"))
					equip_to_slot_if_possible(tmob.get_scooped(H), SLOT_ID_SHOES, INV_OP_SILENT)
					add_attack_logs(src,tmob,"Grabbed underfoot (taur, no shoes)")

				//Return true, the sizediff was enough that we handled it.
				return TRUE

			//Not enough sizediff for INTENT_GRAB to do anything.
			else
				return FALSE

#undef STEP_TEXT_OWNER
#undef STEP_TEXT_PREY
