//Common breathing procs

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing()
	if(SSair.current_cycle%4==2 || failed_last_breath || (health < getCritHealth())) 	//First, resolve location and get a breath
		breathe()

/mob/living/carbon/proc/breathe()
	//if(istype(loc, /obj/machinery/atmospherics/component/unary/cryo_cell)) return
	if(!should_have_organ(O_LUNGS))
		return

	var/datum/gas_mixture/breath

	var/stabilization = HAS_TRAIT(src, TRAIT_MECHANICAL_VENTILATION)

	//First, check if we can breathe at all
	// cpr completely nullifies brainstem requirement
	if(health < getCritHealth() && !(CE_STABLE in chem_effects) && !stabilization) //crit aka circulatory shock
		AdjustLosebreath(1)

	if(losebreath>0) //Suffocating so do not take a breath
		AdjustLosebreath(stabilization? -5 : -1)
		if (prob(10) && !stat) //Gasp per 10 ticks? Sounds about right.
			spawn emote("gasp")
	else
		//Okay, we can breathe, now check if we can get air
		breath = get_breath_from_internal() //First, check for air from internals
		// Respirocytes as a NIF implant
		if(!breath && ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.nif && H.nif.flag_check(NIF_H_SPAREBREATH,NIF_FLAGS_HEALTH))
				var/datum/nifsoft/spare_breath/SB = H.nif.imp_check(NIF_SPAREBREATH)
				breath = SB.resp_breath()
		if(!breath)
			breath = get_breath_from_environment() //No breath from internals so let's try to get air from our location
		if(!breath)
			var/static/datum/gas_mixture/vacuum //avoid having to create a new gas mixture for each breath in space
			if(!vacuum)
				vacuum = new

			breath = vacuum //still nothing? must be vacuum

	handle_breath(breath)
	handle_post_breath(breath)

/mob/living/carbon/proc/get_breath_from_internal(var/volume_needed=BREATH_VOLUME) //hopefully this will allow overrides to specify a different default volume without breaking any cases where volume is passed in.
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!(wear_mask && (wear_mask.clothing_flags & ALLOWINTERNALS)))
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return null

/mob/living/carbon/proc/get_breath_from_environment(var/volume_needed=BREATH_VOLUME)
	var/datum/gas_mixture/breath = null

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air_for_internal_lifeform(src)

	if(environment)
		breath = environment.remove_volume(volume_needed)
		handle_chemical_smoke(environment) //handle chemical smoke while we're at it

	if(breath)
		//handle mask filtering
		if(istype(wear_mask, /obj/item/clothing/mask))
			var/obj/item/clothing/mask/M = wear_mask
			var/datum/gas_mixture/gas_filtered = M.process_air(breath)
			loc.assume_air(gas_filtered)
		return breath
	return null

//Handle possble chem smoke effect
/mob/living/carbon/proc/handle_chemical_smoke(var/datum/gas_mixture/environment)
	if(wear_mask && (wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT))
		return

	for(var/obj/effect/particle_effect/smoke/chem/smoke in view(1, src))
		if(smoke.reagents.total_volume)
			smoke.reagents.trans_to_mob(src, 10, CHEM_INGEST, copy = 1)
			//maybe check air pressure here or something to see if breathing in smoke is even possible.
			// I dunno, maybe the reagents enter the blood stream through the lungs?
			break // If they breathe in the nasty stuff once, no need to continue checking

/mob/living/carbon/proc/handle_breath(datum/gas_mixture/breath)
	return

/mob/living/carbon/proc/handle_post_breath(datum/gas_mixture/breath)
	if(breath)
		if(istype(wear_mask, /obj/item/clothing/mask))
			var/obj/item/clothing/mask/M = wear_mask
			loc.assume_air(M.process_exhale(breath))
		else
			loc?.assume_air(breath) //by default, exhale
