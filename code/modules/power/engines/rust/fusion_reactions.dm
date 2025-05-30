var/list/fusion_reactions

/singleton/fusion_reaction
	var/p_react = "" // Primary reactant.
	var/s_react = "" // Secondary reactant.
	var/minimum_energy_level = 1
	/**
	 * at one unit of reaction, how many joules of energy are consumed?
	 */
	var/energy_consumption = 0
	/**
	 * at one unit of reaction, how many joules of energy are released?
	 */
	var/energy_production = 0
	var/radiation = 0
	var/instability = 0
	var/list/products = list()
	var/minimum_reaction_temperature = 100

/singleton/fusion_reaction/proc/handle_reaction_special(var/obj/effect/fusion_em_field/holder)
	return 0

/proc/get_fusion_reaction(p_react, s_react, m_energy)
	if(!fusion_reactions)
		fusion_reactions = list()
		for(var/rtype in typesof(/singleton/fusion_reaction) - /singleton/fusion_reaction)
			var/singleton/fusion_reaction/cur_reaction = new rtype()
			if(!fusion_reactions[cur_reaction.p_react])
				fusion_reactions[cur_reaction.p_react] = list()
			fusion_reactions[cur_reaction.p_react][cur_reaction.s_react] = cur_reaction
			if(!fusion_reactions[cur_reaction.s_react])
				fusion_reactions[cur_reaction.s_react] = list()
			fusion_reactions[cur_reaction.s_react][cur_reaction.p_react] = cur_reaction

	if(fusion_reactions.Find(p_react))
		var/list/secondary_reactions = fusion_reactions[p_react]
		if(secondary_reactions.Find(s_react))
			return fusion_reactions[p_react][s_react]

// Material fuels
//  deuterium
//  tritium
//  phoron
//  supermatter

// Virtual fuels
//  helium-3
//  lithium-6
//  boron-11

// Basic power production reactions.
/singleton/fusion_reaction/deuterium_deuterium
	p_react = "deuterium"
	s_react = "deuterium"
	energy_consumption = 1
	energy_production = 2
// Advanced production reactions (todo)

/singleton/fusion_reaction/deuterium_helium
	p_react = "deuterium"
	s_react = "helium-3"
	energy_consumption = 1
	energy_production = 5

/singleton/fusion_reaction/deuterium_tritium
	p_react = "deuterium"
	s_react = "tritium"
	energy_consumption = 1
	energy_production = 1
	products = list("helium-3" = 1)
	instability = 0.5

/singleton/fusion_reaction/deuterium_lithium
	p_react = "deuterium"
	s_react = "lithium"
	energy_consumption = 2
	energy_production = 0
	radiation = 3
	products = list("tritium"= 1)
	instability = 1

// Unideal/material production reactions
/singleton/fusion_reaction/oxygen_oxygen
	p_react = "oxygen"
	s_react = "oxygen"
	energy_consumption = 10
	energy_production = 0
	instability = 5
	radiation = 5
	products = list("silicon"= 1)

/singleton/fusion_reaction/iron_iron
	p_react = "iron"
	s_react = "iron"
	products = list(MAT_SILVER = 1, MAT_GOLD = 1, MAT_PLATINUM = 1) // Not realistic but w/e
	energy_consumption = 10
	energy_production = 0
	instability = 2
	minimum_reaction_temperature = 10000

/singleton/fusion_reaction/phoron_hydrogen
	p_react = "hydrogen"
	s_react = "phoron"
	energy_consumption = 10
	energy_production = 0
	instability = 5
	products = list("mydrogen" = 1)
	minimum_reaction_temperature = 8000

// VERY UNIDEAL REACTIONS.
/singleton/fusion_reaction/phoron_supermatter
	p_react = "supermatter"
	s_react = "phoron"
	energy_consumption = 0
	energy_production = 5
	radiation = 20
	instability = 20

/singleton/fusion_reaction/phoron_supermatter/handle_reaction_special(var/obj/effect/fusion_em_field/holder)

	wormhole_event()

	var/turf/origin = get_turf(holder)
	holder.Rupture()
	qdel(holder)

	radiation_pulse(holder, 7500, RAD_FALLOFF_ENGINE_FUSION)

	for(var/mob/living/mob in living_mob_list)
		var/turf/T = get_turf(mob)
		if(T && (holder.z == T.z))
			if(istype(mob, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = mob
				H.adjustHallucination(rand(100,150))

	for(var/obj/machinery/fusion_fuel_injector/I in range(world.view, origin))
		if(I.cur_assembly && I.cur_assembly.fuel_type == "supermatter")
			explosion(get_turf(I), 1, 2, 3)
			spawn(5)
				if(I && I.loc)
					qdel(I)

	sleep(5)
	explosion(origin, 1, 2, 5)

	return 1

// High end reactions.
/singleton/fusion_reaction/boron_hydrogen
	p_react = "boron"
	s_react = "hydrogen"
	minimum_energy_level = 78500 //Was unobtainable or rather unsustainable before
	energy_consumption = 3
	energy_production = 15
	radiation = 3
	instability = 3

/singleton/fusion_reaction/hydrogen_hydrogen
	p_react = "hydrogen"
	s_react = "hydrogen"
	minimum_reaction_temperature = 40000 //So its actually unobtainable even with the new values I swear if engineering makes me add cold fusion I am going to not touch engineering for at least a month
	energy_consumption = 0
	energy_production = 20
	radiation = 5
	instability = 5
