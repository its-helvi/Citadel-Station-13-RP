/obj/machinery/telecomms/relay/preset/triumph/deck_one
	id = "Deck Relay 1"
	autolinkers = list("tb1_relay")

/obj/machinery/telecomms/relay/preset/centcom/triumph/deck_one

/obj/machinery/telecomms/relay/preset/triumph/deck_two
	id = "Deck Relay 2"
	autolinkers = list("tb2_relay")

/obj/machinery/telecomms/relay/preset/centcom/triumph/deck_two

/obj/machinery/telecomms/relay/preset/triumph/deck_three
	id = "Deck Relay 3"
	autolinkers = list("tb3_relay")

/obj/machinery/telecomms/relay/preset/centcom/triumph/deck_three

/obj/machinery/telecomms/relay/preset/triumph/deck_four
	id = "Deck Relay 4"
	autolinkers = list("tb4_relay")

/obj/machinery/telecomms/relay/preset/centcom/triumph/deck_four

// #### Hub ####
/obj/machinery/telecomms/hub/preset/triumph
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub",
		"tb1_relay", "tb2_relay", "tb3_relay", "tb4_relay","c_relay", "m_relay", "r_relay", "sci_o_relay", "ud_relay",
		"science", "medical", "supply", "service", "common", "command", "engineering", "security", "explorer", "unused",
		"hb_relay", "receiverA", "broadcasterA"
	)

/obj/machinery/telecomms/receiver/preset_right/triumph
//	id = "triumph_rx"
	freq_listening = list(FREQ_AI_PRIVATE, FREQ_SCIENCE, FREQ_MEDICAL, FREQ_SUPPLY, FREQ_SERVICE, FREQ_COMMAND, FREQ_ENGINEERING, FREQ_SECURITY, FREQ_ENTERTAINMENT, FREQ_EXPLORER)

/obj/machinery/telecomms/broadcaster/preset_right/triumph
//	id = "triumph_tx"

/obj/machinery/telecomms/bus/preset_two/triumph
	freq_listening = list(FREQ_SUPPLY, FREQ_SERVICE, FREQ_EXPLORER)

/obj/machinery/telecomms/server/presets/service/triumph
	freq_listening = list(FREQ_SERVICE, FREQ_EXPLORER)
	autolinkers = list("service", "explorer")

// Telecommunications Satellite

/obj/item/multitool/triumph_buffered
	name = "pre-linked multitool (tether hub)"
	desc = "This multitool has already been linked to the Tether telecomms hub and can be used to configure one (1) relay."

/obj/item/multitool/triumph_buffered/Initialize(mapload)
	. = ..()
	buffer = locate(/obj/machinery/telecomms/hub/preset/triumph)
