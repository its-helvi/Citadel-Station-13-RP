/datum/prototype/design/science/hud
	abstract_type = /datum/prototype/design/science/hud
	subcategory = DESIGN_SUBCATEGORY_SCANNING
	materials_base = list(MAT_STEEL = 50, MAT_GLASS = 50)

/datum/prototype/design/science/hud/generate_name(template)
	return "HUD glasses prototype ([..()])"

/datum/prototype/design/science/hud/generate_desc(template_name, template_desc)
	return "Allows for the construction of \a [template_name] HUD glasses."

/datum/prototype/design/science/hud/health
	design_name = "health scanner"
	id = "health_hud"
	req_tech = list(TECH_BIO = 2, TECH_MAGNET = 3)
	build_path = /obj/item/clothing/glasses/hud/health

/datum/prototype/design/science/hud/security
	design_name = "security records"
	id = "security_hud"
	req_tech = list(TECH_MAGNET = 3, TECH_COMBAT = 2)
	build_path = /obj/item/clothing/glasses/hud/security

/datum/prototype/design/science/hud/mesons
	design_name = "optical meson scanner"
	id = "mesons"
	req_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2)
	build_path = /obj/item/clothing/glasses/meson

/datum/prototype/design/science/hud/material
	design_name = "optical material scanner"
	id = "material"
	req_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 3)
	build_path = /obj/item/clothing/glasses/material

/* Graviton't
/datum/prototype/design/science/hud/graviton_visor
	design_name = "graviton visor"
	id = "graviton_goggles"
	req_tech = list(TECH_MAGNET = 5, TECH_ENGINEERING = 3, TECH_BLUESPACE = 3, TECH_PHORON = 3)
	materials_base = list(MAT_PLASTEEL = 2000, MAT_GLASS = 3000, MAT_PHORON = 1500)
	build_path = /obj/item/clothing/glasses/graviton
*/

/datum/prototype/design/science/hud/omni
	design_name = "AR glasses"
	id = "omnihud"
	req_tech = list(TECH_MAGNET = 4, TECH_COMBAT = 3, TECH_BIO = 3)
	materials_base = list(MAT_STEEL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/glasses/omnihud
