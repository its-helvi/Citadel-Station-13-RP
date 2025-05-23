// GENERIC PRINTER - DO NOT USE THIS OBJECT.
// Flesh and robot printers are defined below this object.

/obj/machinery/organ_printer
	name = "organ printer"
	desc = "It's a machine that prints organs."
	icon = 'icons/obj/machines/fabricators/bioprinter.dmi'
	icon_state = "bioprinter"
	base_icon_state = "bioprinter"

	anchored = TRUE
	density = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 40
	active_power_usage = 300
	///This is the beaker that holds all of the biomass
	var/obj/item/reagent_containers/container = null

	var/print_delay = 100
	///For Adminbus reasons
	var/base_print_delay = 100
	///Is the bioprinter printing
	var/printing = FALSE
	/// Blood sample for DNA hashing.
	var/datum/blood_mixture/loaded_blood_mixture
	///May cause rejection, or the printing of some alien limb instead!
	var/malfunctioning = FALSE
	///Can it print more 'complex' organs?
	var/complex_organs = FALSE
	/// Can it print anomalous organs?
	var/anomalous_organs = FALSE

	// These should be subtypes of /obj/item/organ
	// Costs roughly 20u Phoron (1 sheet) per internal organ, limbs are 60u for limb and extremity
	var/list/products = list(
		"Heart"   = list(/obj/item/organ/internal/heart,  20),
		"Lungs"   = list(/obj/item/organ/internal/lungs,  20),
		"Kidneys" = list(/obj/item/organ/internal/kidneys,20),
		"Eyes"    = list(/obj/item/organ/internal/eyes,   20),
		"Liver"   = list(/obj/item/organ/internal/liver,  20),
		"Spleen"  = list(/obj/item/organ/internal/spleen, 20),
		"Arm, Left"   = list(/obj/item/organ/external/arm,  40),
		"Arm, Right"   = list(/obj/item/organ/external/arm/right,  40),
		"Leg, Left"   = list(/obj/item/organ/external/leg,  40),
		"Leg, Right"   = list(/obj/item/organ/external/leg/right,  40),
		"Foot, Left"   = list(/obj/item/organ/external/foot,  20),
		"Foot, Right"   = list(/obj/item/organ/external/foot/right,  20),
		"Hand, Left"   = list(/obj/item/organ/external/hand,  20),
		"Hand, Right"   = list(/obj/item/organ/external/hand/right,  20)
		)

	var/list/complex_products = list(
		"Brain" = list(/obj/item/organ/internal/brain, 60),
		"Larynx" = list(/obj/item/organ/internal/voicebox, 20),
		"Head" = list(/obj/item/organ/external/head, 40)
		)

	var/list/anomalous_products = list(
		"Lymphatic Complex" = list(/obj/item/organ/internal/immunehub, 120),
		"Respiration Nexus" = list(/obj/item/organ/internal/lungs/replicant/mending, 80),
		"Adrenal Valve Cluster" = list(/obj/item/organ/internal/heart/replicant/rage, 80)
		)

/obj/machinery/organ_printer/update_icon_state()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]-off"
	else
		icon_state = base_icon_state

/obj/machinery/organ_printer/update_overlays()
	. = ..()
	cut_overlays()
	if(panel_open)
		add_overlay("[base_icon_state]-panel")
	if(printing)
		add_overlay("[base_icon_state]-active")

/obj/machinery/organ_printer/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, O))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return
	if(default_unfasten_wrench(user, O, 20))
		return
	return ..()

/obj/machinery/organ_printer/examine(mob/user, dist)
	. = ..()
	var/biomass = get_biomass_volume()
	if(biomass)
		. += SPAN_INFO("It is loaded with [biomass] units of biomass.")
	else
		. += SPAN_INFO("It is not loaded with any biomass.")

/obj/machinery/organ_printer/RefreshParts()
	// Print Delay updating
	print_delay = base_print_delay
	var/manip_rating = 0
	for(var/obj/item/stock_parts/manipulator/manip in component_parts)
		manip_rating += manip.rating
		print_delay -= (manip.rating-1)*10
	print_delay = max(0,print_delay)

	manip_rating = round(manip_rating / 2)

	if(manip_rating >= 5)
		malfunctioning = TRUE
	else
		malfunctioning = initial(malfunctioning)

	if(manip_rating >= 3)
		complex_organs = TRUE
		if(manip_rating >= 4)
			anomalous_organs = TRUE
			if(manip_rating >= 5)
				malfunctioning = TRUE
	else
		complex_organs = initial(complex_organs)
		anomalous_organs = initial(anomalous_organs)
		malfunctioning = initial(malfunctioning)

	. = ..()

/obj/machinery/organ_printer/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)

	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(panel_open)
		to_chat(user, SPAN_WARNING("Close the panel first!"))
		return

	if(printing)
		to_chat(user, SPAN_NOTICE("\The [src] is busy!"))
		return

	if(container)
		var/response = tgui_alert(user, "What do you want to do?", "Bioprinter Menu", list("Print Limbs", "Cancel"))
		if(response == "Print Limbs")
			printing_menu(user)
	else
		to_chat(user, SPAN_WARNING("\The [src] can't operate without a reagent reservoir!"))

/obj/machinery/organ_printer/proc/printing_menu(mob/user)
	var/list/possible_list = list()

	possible_list |= products

	if(complex_organs)
		possible_list |= complex_products

	if(anomalous_organs)
		possible_list |= anomalous_products

	var/choice = tgui_input_list(usr, "What would you like to print?", "Print Choice", possible_list)

	if(!choice || printing || (machine_stat & (BROKEN|NOPOWER)))
		return

	if(!can_print(choice, possible_list[choice][2]))
		return

	container.reagents.remove_reagent("biomass", possible_list[choice][2])

	update_use_power(USE_POWER_ACTIVE)
	printing = TRUE
	update_appearance()

	visible_message(SPAN_NOTICE("\The [src] begins churning."))

	sleep(print_delay)

	update_use_power(USE_POWER_IDLE)
	printing = FALSE
	update_appearance()

	if(!choice || !src || (machine_stat & (BROKEN|NOPOWER)))
		return

	print_organ(possible_list[choice][1])

	return

/obj/machinery/organ_printer/verb/eject_beaker()
	set name = "Eject Beaker"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)

	if(usr.stat != NONE)
		return
	add_fingerprint(usr)
	remove_beaker()
	return

/// Returns TRUE if it succeeds, FALSE if it fails. Added in case someone wants to add messages to the user.
/obj/machinery/organ_printer/proc/remove_beaker()
	if(container)
		container.forceMove(get_turf(src))
		container = null
		return TRUE
	return FALSE

/// Checks for reagents, then reports how much biomass it has in it.
/obj/machinery/organ_printer/proc/get_biomass_volume()
	return container.reagents?.reagent_volumes?[/datum/reagent/nutriment/biomass::id]

/obj/machinery/organ_printer/proc/can_print(choice, biomass_needed = 0)
	var/biomass = get_biomass_volume()
	if(biomass < biomass_needed)
		visible_message(SPAN_INFO("\The [src] displays a warning: 'Not enough biomass. [biomass] stored and [biomass_needed] needed.'"))
		return FALSE

	var/datum/blood_fragment/using_fragment = loaded_blood_mixture.unsafe_get_fragment_ref(1)
	if(!using_fragment)
		visible_message(SPAN_INFO("\The [src] displays a warning: 'No DNA saved. Insert a blood sample.'"))
		return FALSE
	return TRUE

/obj/machinery/organ_printer/proc/print_organ(var/choice)
	var/new_organ = choice
	var/obj/item/organ/O = new new_organ(get_turf(src))
	O.status |= ORGAN_CUT_AWAY
	var/datum/blood_fragment/using_fragment = loaded_blood_mixture.unsafe_get_fragment_ref(1)
	var/mob/living/carbon/human/C = using_fragment.legacy_donor
	O.set_dna(C.dna)
	O.species = C.species

	var/malfunctioned = FALSE

	if(malfunctioning && prob(30)) // Alien Tech is a hell of a drug.
		malfunctioned = TRUE
		var/possible_species = list(SPECIES_HUMAN, SPECIES_VOX, SPECIES_SKRELL, SPECIES_ZADDAT, SPECIES_UNATHI, SPECIES_UNATHI_DIGI, SPECIES_GOLEM, SPECIES_SHADOW)
		var/new_species = pick(possible_species)
		var/datum/species/S = SScharacters.resolve_species_name(new_species)
		if(!S)
			new_species = SScharacters.resolve_species_name(/datum/species/human)
		O.species = new_species

	if(istype(O, /obj/item/organ/external) && !malfunctioned)
		var/obj/item/organ/external/E = O
		E.sync_colour_to_human(C)

	O.pixel_x = rand(-6.0, 6)
	O.pixel_y = rand(-6.0, 6)

	if(O.species)
		// This is a very hacky way of doing of what organ/New() does if it has an owner
		O.set_weight_class(max(O.w_class + mob_size_difference(O.species.mob_size, MOB_MEDIUM), 1))

	return O
// END GENERIC PRINTER

// CIRCUITS
/obj/item/circuitboard/bioprinter
	name = "bioprinter circuit"
	build_path = /obj/machinery/organ_printer/flesh
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 3)
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2
		)

// FLESH ORGAN PRINTER
/obj/machinery/organ_printer/flesh
	name = "bioprinter"
	desc = "It's a machine that prints replacement organs."
	circuit = /obj/item/circuitboard/bioprinter

/obj/machinery/organ_printer/flesh/full/Initialize(mapload, newdir)
	. = ..()
	container = new /obj/item/reagent_containers/glass/bottle/biomass(src)

/obj/machinery/organ_printer/flesh/dismantle()
	var/turf/T = get_turf(src)
	if(T)
		if(container)
			container.forceMove(T)
			container = null
	return ..()

/obj/machinery/organ_printer/flesh/print_organ(choice)
	var/obj/item/organ/O = ..()

	playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
	visible_message(SPAN_INFO("\The [src] dings, then spits out \a [O]."))
	return O

/obj/machinery/organ_printer/flesh/attackby(obj/item/W, mob/user)
	// DNA sample from syringe.
	if(istype(W,/obj/item/reagent_containers/syringe))	//TODO: Make this actually empty the syringe
		var/obj/item/reagent_containers/syringe/S = W
		var/datum/blood_mixture/mixture = S.reagents?.reagent_datas[/datum/reagent/blood::id]
		if((loaded_blood_mixture = mixture))
			S.reagents.del_reagent(/datum/reagent/blood)
			to_chat(user, SPAN_INFO("You scan the blood sample into the bioprinter."))
		return
	else if(istype(W,/obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/G = W
		if(container)
			to_chat(user, SPAN_WARNING("\The [src] already has a container loaded!"))
			return
		else if(do_after(user, 1 SECOND))
			if(!user.attempt_insert_item_for_installation(G, src))
				return
			user.visible_message("[user] has loaded \the [G] into \the [src].", "You load \the [G] into \the [src].")
			container = G
		return
	return ..()

// END FLESH ORGAN PRINTER


/* Roboprinter is made obsolete by the system already in place and mapped into Robotics
/obj/item/circuitboard/roboprinter
	name = "roboprinter circuit"
	build_path = /obj/machinery/organ_printer/robot
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 3)
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2)

// ROBOT ORGAN PRINTER
// Still Requires DNA, /obj/machinery/pros_fab is better for limbs
/obj/machinery/organ_printer/robot
	name = "prosthetic organ fabricator"
	desc = "It's a machine that prints prosthetic organs."
	icon_state = "roboprinter"
	circuit = /obj/item/circuitboard/roboprinter

	var/matter_amount_per_sheet = 10
	var/matter_type = MAT_STEEL

/obj/machinery/organ_printer/robot/full/New()
	. = ..()
	stored_matter = max_stored_matter

/obj/machinery/organ_printer/robot/dismantle()
	if(stored_matter >= matter_amount_per_sheet)
		new /obj/item/stack/material/steel(get_turf(src), FLOOR(stored_matter/matter_amount_per_sheet, 1))
	return ..()

/obj/machinery/organ_printer/robot/print_organ(var/choice)
	var/obj/item/organ/O = ..()
	O.robotize()
	O.status |= ORGAN_CUT_AWAY  // robotize() resets status to 0
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	audible_message("<span class='info'>\The [src] dings, then spits out \a [O].</span>")
	return O

/obj/machinery/organ_printer/robot/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/stack/material) && W.get_material_name() == matter_type)
		if((max_stored_matter-stored_matter) < matter_amount_per_sheet)
			to_chat(user, "<span class='warning'>\The [src] is too full.</span>")
			return
		var/obj/item/stack/S = W
		var/space_left = max_stored_matter - stored_matter
		var/sheets_to_take = min(S.amount, FLOOR(space_left/matter_amount_per_sheet, 1))
		if(sheets_to_take <= 0)
			to_chat(user, "<span class='warning'>\The [src] is too full.</span>")
			return
		stored_matter = min(max_stored_matter, stored_matter + (sheets_to_take*matter_amount_per_sheet))
		to_chat(user, "<span class='info'>\The [src] processes \the [W]. Levels of stored matter now: [stored_matter]</span>")
		S.use(sheets_to_take)
		return
	else if(istype(W,/obj/item/reagent_containers/syringe))	//TODO: Make this actuall empty the syringe
		var/obj/item/reagent_containers/syringe/S = W
		var/datum/reagent/blood/injected = locate() in S.reagents.reagent_list //Grab some blood
		if(injected && injected.data)
			loaded_dna = injected.data
			to_chat(user, "<span class='info'>You scan the blood sample into the bioprinter.</span>")
		return
	return ..()
// END ROBOT ORGAN PRINTER
*/
