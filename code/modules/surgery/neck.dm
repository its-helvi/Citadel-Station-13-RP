//Procedures in this file: Brain-stem reattachment surgery.
//////////////////////////////////////////////////////////////////////
//						BRAINSTEM SURGERY							//
//////////////////////////////////////////////////////////////////////

/datum/surgery_step/brainstem
	priority = 2
	req_open = 1
	can_infect = 1

/datum/surgery_step/brainstem/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..()) return FALSE

	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (!affected || (affected.robotic >= ORGAN_ROBOT) || !(affected.open >= 3))
		return 0
	return target_zone == BP_HEAD

/////////////////////////////
// Blood Vessel Mending
/////////////////////////////

/datum/surgery_step/brainstem/mend_vessels
	step_name = "Mend vessels"

	priority = 1
	allowed_tools = list(
		/obj/item/surgical/FixOVein = 100,
		/obj/item/stack/nanopaste = 50,
		/obj/item/stack/cable_coil = 40,
		/obj/item/assembly/mousetrap = 5)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/brainstem/mend_vessels/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == BP_HEAD && target.op_stage.brainstem == 0

/datum/surgery_step/brainstem/mend_vessels/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to mend the blood vessels on [target]'s brainstem with \the [tool].", \
	"You start to mend the blood vessels on [target]'s brainstem with \the [tool].")
	..()

/datum/surgery_step/brainstem/mend_vessels/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] has mended the blood vessels on [target]'s brainstem with \the [tool].</font>" , \
	"<font color=#4F49AF> You have mended the blood vessels on [target]'s brainstem with \the [tool].</font>",)
	target.op_stage.brainstem = 1

/datum/surgery_step/brainstem/mend_vessels/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, tearing at [target]'s brainstem with \the [tool]!</font>" , \
	"<font color='red'>Your hand slips, tearing at [target]'s brainstem with \the [tool]!</font>" )
	affected.create_wound(WOUND_TYPE_PIERCE, 10)
	target.adjust_unconscious(20 * 10)

/////////////////////////////
// Bone Drilling
/////////////////////////////

/datum/surgery_step/brainstem/drill_vertebrae
	step_name = "Drill vertebrae"

	priority = 3 //Do this instead of expanding the skull cavity
	allowed_tools = list(
		/obj/item/surgical/surgicaldrill = 100,
		/obj/item/melee/changeling/arm_blade = 15,
		/obj/item/pickaxe = 5
	)

	allowed_procs = list(IS_SCREWDRIVER = 75)

	min_duration = 200 //Very. Very. Carefully.
	max_duration = 300

/datum/surgery_step/brainstem/drill_vertebrae/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == BP_HEAD && target.op_stage.brainstem == 1

/datum/surgery_step/brainstem/drill_vertebrae/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to drill around [target]'s brainstem with \the [tool].", \
	"You start to drill around [target]'s brainstem with \the [tool].")
	..()

/datum/surgery_step/brainstem/drill_vertebrae/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color=#4F49AF>[user] has drilled around [target]'s brainstem with \the [tool].</font>" , \
	"<font color=#4F49AF> You have drilled around [target]'s brainstem with \the [tool].</font>",)
	target.adjust_unconscious(20 * 10) //We're getting Invasive here. This only ticks down when the person is alive, so it's a good side-effect for this step. Rattling the braincase with a drill is not optimal.
	target.op_stage.brainstem = 2
	affected.fracture() //Does not apply damage, simply breaks it if it wasn't already. Doesn't stop a defib on its own.

/datum/surgery_step/brainstem/drill_vertebrae/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	//var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user] almost loses their grip on the [tool]!</font>" , \
	"<font color='red'>Your hand slips and nearly shreds [target]'s brainstem with \the [tool]!</font>" )
	/*affected.create_wound(WOUND_TYPE_PIERCE, 10)
	target.adjust_unconscious(20 * 15)
	spawn()
		for(var/obj/item/organ/internal/brain/O in affected.internal_organs)
			O.take_damage(rand(5,10))*/ // Citadel Edit: Make NIF surgeries not so deadly

/////////////////////////////
// Bone Cleaning
/////////////////////////////

/datum/surgery_step/brainstem/clean_chips
	step_name = "Clear bone chips"

	priority = 3 //Do this instead of picking around for implants.
	allowed_tools = list(
		/obj/item/surgical/hemostat = 100,
		/obj/item/surgical/hemostat_primitive = 50,
		/obj/item/melee/changeling/claw = 40) //Surprisingly, claws are kind of okay at picking things out.

	allowed_procs = list(IS_WIRECUTTER = 60)

	min_duration = 90
	max_duration = 120

/datum/surgery_step/brainstem/clean_chips/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == BP_HEAD && target.op_stage.brainstem == 2

/datum/surgery_step/brainstem/clean_chips/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to pick around [target]'s brainstem for bone chips with \the [tool].", \
	"You start to pick around [target]'s brainstem for bone chips with \the [tool].")
	..()

/datum/surgery_step/brainstem/clean_chips/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] has cleaned around [target]'s brainstem with \the [tool].</font>" , \
	"<font color=#4F49AF> You have cleaned around [target]'s brainstem with \the [tool].</font>",)
	target.adjust_unconscious(20 * 10) //Still invasive.
	target.op_stage.brainstem = 3

/datum/surgery_step/brainstem/clean_chips/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	//var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, gouging [target]'s brainstem with \the [tool]!</font>" , \
	"<font color='red'>Your hand slips, gouging [target]'s brainstem with \the [tool]!</font>" )
	/*affected.create_wound(WOUND_TYPE_CUT, 5)
	target.adjust_unconscious(20 * 10)
	spawn()
		for(var/obj/item/organ/internal/brain/O in affected.internal_organs) //If there's more than one...
			O.take_damage(rand(1,10))*/

/////////////////////////////
// Spinal Cord Repair
/////////////////////////////

/datum/surgery_step/brainstem/mend_cord
	step_name = "Mend spinal cord"

	priority = 1 //Do this after IB.
	allowed_tools = list(
		/obj/item/surgical/FixOVein = 100,
		/obj/item/stack/nanopaste = 50,
		/obj/item/stack/cable_coil = 40,
		/obj/item/assembly/mousetrap = 5)

	min_duration = 100
	max_duration = 200

/datum/surgery_step/brainstem/mend_cord/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == BP_HEAD && target.op_stage.brainstem == 3

/datum/surgery_step/brainstem/mend_cord/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to fuse [target]'s spinal cord with \the [tool].", \
	"You start to fuse [target]'s spinal cord with \the [tool].")
	..()

/datum/surgery_step/brainstem/mend_cord/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] has fused [target]'s spinal cord with \the [tool].</font>" , \
	"<font color=#4F49AF> You have fused [target]'s spinal cord with \the [tool].</font>",)
	target.op_stage.brainstem = 4
	target.adjust_unconscious(20 * 5)
	target.add_modifier(/datum/modifier/franken_sickness, 20 MINUTES)

/datum/surgery_step/brainstem/mend_cord/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, tearing at [target]'s spinal cord with \the [tool]!</font>" , \
	"<font color='red'>Your hand slips, tearing at [target]'s spinal cord with \the [tool]!</font>" )
	affected.create_wound(WOUND_TYPE_PIERCE, 5)
	target.adjust_unconscious(20 * 20)
	spawn()
		for(var/obj/item/organ/internal/brain/O in affected.internal_organs)
			O.take_damage(rand(5,15)) //Down to the wire. Or rather, the cord.

/////////////////////////////
// Vertebrae repair
/////////////////////////////

/datum/surgery_step/brainstem/mend_vertebrae
	step_name = "Mend vertebrae"

	priority = 3 //Do this instead of fixing bones.
	allowed_tools = list(
		/obj/item/surgical/bonegel = 100,
		/obj/item/stack/nanopaste = 50,
		/obj/item/duct_tape_roll = 5)

	min_duration = 100
	max_duration = 160

/datum/surgery_step/brainstem/mend_vertebrae/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == BP_HEAD && target.op_stage.brainstem == 4

/datum/surgery_step/brainstem/mend_vertebrae/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to mend [target]'s opened vertebrae with \the [tool].", \
	"You start to mend [target]'s opened vertebrae with \the [tool].")
	..()

/datum/surgery_step/brainstem/mend_vertebrae/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] has mended [target]'s vertebrae with \the [tool].</font>" , \
	"<font color=#4F49AF> You have mended [target]'s vertebrae with \the [tool].</font>",)
	target.can_defib = 1
	target.op_stage.brainstem = 5

/datum/surgery_step/brainstem/mend_vertebrae/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, tearing at [target]'s spinal cord with \the [tool]!</font>" , \
	"<font color='red'>Your hand slips, tearing at [target]'s spinal cord with \the [tool]!</font>" )
	affected.create_wound(WOUND_TYPE_PIERCE, 5)
	target.adjust_unconscious(20 * 15)
	spawn()
		for(var/obj/item/organ/internal/brain/O in affected.internal_organs)
			O.take_damage(rand(1,10))

/////////////////////////////
// Realign tissues
/////////////////////////////

/datum/surgery_step/brainstem/realign_tissue
	step_name = "Realign tissue"

	priority = 3 //Do this instead of searching for objects in the skull.
	allowed_tools = list(
		/obj/item/surgical/hemostat = 100,
		/obj/item/surgical/hemostat_primitive = 50,
		/obj/item/melee/changeling/claw = 20) //Claws. Good for digging, not so much for moving.

	allowed_procs = list(IS_WIRECUTTER = 60)

	min_duration = 90
	max_duration = 120

/datum/surgery_step/brainstem/realign_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == BP_HEAD && target.op_stage.brainstem == 5

/datum/surgery_step/brainstem/realign_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to realign the tissues in [target]'s skull with \the [tool].", \
	"You start to realign the tissues in [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/brainstem/realign_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] has realigned the tissues in [target]'s skull back into place with \the [tool].</font>" , \
	"<font color=#4F49AF> You have realigned the tissues in [target]'s skull back into place with \the [tool].</font>",)
	target.adjust_unconscious(20 * 5) //I n v a s i v e
	target.op_stage.brainstem = 0 //The cycle begins anew.

/datum/surgery_step/brainstem/realign_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, gouging [target]'s brainstem with \the [tool]!</font>" , \
	"<font color='red'>Your hand slips, gouging [target]'s brainstem with \the [tool]!</font>" )
	affected.create_wound(WOUND_TYPE_CUT, 5)
	target.adjust_unconscious(20 * 30)
	spawn()
		for(var/obj/item/organ/internal/brain/O in affected.internal_organs)
			O.take_damage(rand(1,10))
