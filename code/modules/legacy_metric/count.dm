/*
 * Procs for counting active players in different situations. Returns the number of active players within the given cutoff.
 */

/datum/legacy_metric/proc/count_all_outdoor_mobs(var/cutoff = 75)
	var/num = 0
	for(var/mob/living/L in GLOB.player_list)
		var/turf/T = get_turf(L)
		if(istype(T) && !istype(T, /turf/space) && T.outdoors)
			if(assess_player_activity(L) >= cutoff)
				num++
	return num

/datum/legacy_metric/proc/count_all_space_mobs(var/cutoff = 75, var/respect_z = TRUE)
	var/num = 0
	for(var/mob/living/L in GLOB.player_list)
		var/turf/T = get_turf(L)
		if(istype(T, /turf/space) && istype(T.loc, /area/space))
			if(respect_z && !(L.z in (LEGACY_MAP_DATUM).station_levels))
				continue
			if(assess_player_activity(L) >= cutoff)
				num++
	return num

// Gives a count of how many human mobs of a specific species are on the station.
// Note that `ignore_synths` makes this proc ignore posibrains and drones, but NOT cyborgs, as they are still the same species in-universe.
/datum/legacy_metric/proc/count_all_of_specific_species(species_name, ignore_synths = TRUE, cutoff = 75, respect_z = TRUE)
	var/num = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(respect_z && !(H.z in (LEGACY_MAP_DATUM).station_levels))
			continue
		if(ignore_synths && H.isSynthetic() && H.get_FBP_type() != FBP_CYBORG)
			continue
		if(H.species.name == species_name)
			if(assess_player_activity(H) >= cutoff)
				num++
	return num

// Gives a count of how many FBPs of a specific type there are on the station.
/datum/legacy_metric/proc/count_all_FBPs_of_kind(desired_FBP_class, cutoff = 75, respect_z = TRUE)
	var/num = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(respect_z && !(H.z in (LEGACY_MAP_DATUM).station_levels))
			continue
		if(H.get_FBP_type() != desired_FBP_class)
			continue
		if(assess_player_activity(H) >= cutoff)
			num++
	return num

// Like above, but for all FBPs.
/datum/legacy_metric/proc/count_all_FBPs(cutoff = 75, respect_z = TRUE)
	var/num = count_all_FBPs_of_kind(FBP_CYBORG, cutoff, respect_z)
	num += count_all_FBPs_of_kind(FBP_POSI, cutoff, respect_z)
	num += count_all_FBPs_of_kind(FBP_DRONE, cutoff, respect_z)
	return num


/datum/legacy_metric/proc/get_all_antags(cutoff = 75)
	. = list()
	for(var/mob/living/L in GLOB.player_list)
		if(L.mind && player_is_antag(L.mind) && assess_player_activity(L) >= cutoff)
			. += L

/datum/legacy_metric/proc/count_all_antags(cutoff = 75)
	var/list/L = get_all_antags(cutoff)
	return L.len
