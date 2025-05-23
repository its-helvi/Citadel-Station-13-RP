// Shoots syringe-darts at enemies, which applies a stacking poison modifier that hurts over time.
// They also do this in melee.
// Fortunately they're quite fragile and don't fire that fast.

/datum/category_item/catalogue/technology/odysseus
	name = "Exosuit - Odysseus"
	desc = "The dominant medical exosuit on the modern market, the Odysseus is a Vey-Med product \
	designed to incorporate other Vey-Med inventions - like the Sleeper - into a mobile frame. The \
	Odysseus' focus on rescue operations in hazardous environments is augmented with some of the best \
	agility ratings on the civilian market. In spite of its narrow profile, the Odysseus stands slightly \
	taller than the APLU at 9.5'(3m). Capable of operating in vacuum as well as in most adverse weather \
	conditions, the staying power of this mecha speaks volumes for its efficacy."
	value = CATALOGUER_REWARD_EASY

/mob/living/simple_mob/mechanical/mecha/odysseus
	name = "odysseus"
	desc = "These exosuits are developed and produced by Vey-Med. This one has a syringe gun."
	catalogue_data = list(
		/datum/category_item/catalogue/technology/odysseus,
		/datum/category_item/catalogue/information/organization/vey_med
		)
	icon_state = "odysseus"
	wreckage = /obj/structure/loot_pile/mecha/odysseus

	maxHealth = 120
	movement_base_speed = 6.66
	turn_sound = 'sound/mecha/mechmove01.ogg'

	legacy_melee_damage_lower = 5
	legacy_melee_damage_upper = 5
	base_attack_cooldown = 2 SECONDS
	attacktext = list("injected")
	projectiletype = /obj/projectile/fake_syringe/poison
	projectilesound = 'sound/weapons/empty.ogg' // Just like the syringe gun.

	ai_holder_type = /datum/ai_holder/polaris/simple_mob/ranged/kiting/no_moonwalk

/mob/living/simple_mob/mechanical/mecha/odysseus/manned
	pilot_type = /mob/living/simple_mob/humanoid/merc/ranged // Carries a pistol.


// Resprite of the regular one, perhaps for merc PoIs.
/mob/living/simple_mob/mechanical/mecha/odysseus/murdysseus
	icon_state = "murdysseus"
	wreckage = /obj/structure/loot_pile/mecha/odysseus/murdysseus

/mob/living/simple_mob/mechanical/mecha/odysseus/murdysseus/manned
	pilot_type = /mob/living/simple_mob/humanoid/merc/ranged


/mob/living/simple_mob/mechanical/mecha/odysseus/apply_melee_effects(atom/A)
	if(isliving(A))
		var/mob/living/L = A

		var/target_zone = pick(BP_TORSO,BP_TORSO,BP_TORSO,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_HEAD)
		if(L.can_inject(src, null, target_zone))
			L.custom_pain(SPAN_WARNING("You feel a tiny prick."), 1, TRUE)
			if(L.get_poison_protection() < 1)
				L.add_modifier(/datum/modifier/poisoned, 30 SECONDS)
				L.inflict_poison_damage(5)


// Fake syringe that tests if target can be injected before applying damage/modifiers/etc.
/obj/projectile/fake_syringe
	name = "syringe"
	icon_state = "syringe"
	damage_force = 5 // Getting hit with a launched syringe probably hurts, and makes it at least slightly relevant against synthetics.
	var/piercing = FALSE // If true, ignores thick material.

/obj/projectile/fake_syringe/on_impact(atom/target, impact_flags, def_zone, efficiency)
	if(isliving(target))
		var/mob/living/L = target
		if(!L.can_inject(null, null, def_zone, piercing))
			return impact_flags | PROJECTILE_IMPACT_BLOCKED
		L.custom_pain(SPAN_WARNING("You feel a tiny prick!"), 1, TRUE)
	return ..()

// Fake syringe, which inflicts a long lasting modifier that slowly kills them.
/obj/projectile/fake_syringe/poison
	modifier_type_to_apply = /datum/modifier/poisoned
	modifier_duration = 1 MINUTE // About 30 damage per stack over a minute.
