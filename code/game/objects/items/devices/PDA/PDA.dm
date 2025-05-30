
//The advanced pea-green monochrome lcd of tomorrow.

GLOBAL_LIST_EMPTY(PDAs)

/obj/item/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_ID | SLOT_BELT
	rad_flags = RAD_BLOCK_CONTENTS
	item_flags = ITEM_NO_BLUDGEON

	//Main variables
	var/pdachoice = 1
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/cartridge/cartridge = null //current cartridge
	var/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	var/lastmode = 0
	var/ui_tick = 0
	var/nanoUI[0]

	//Secondary variables
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner.
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function
	var/message_silent = 0 //To beep or not to beep, that is the question
	var/news_silent = 1 //To beep or not to beep, that is the question.  The answer is No.
	var/toff = 0 //If 1, messenger disabled
	var/tnote[0]  //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/ringtone = "beep" //The PDA ringtone!
	var/newstone = "beep, beep" //The news ringtone!
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?
	var/active_conversation = null // New variable that allows us to only view a single conversation.
	var/list/conversations = list()    // For keeping up with who we have PDA messsages from.
	var/new_message = 0			//To remove hackish overlay check
	var/new_news = 0

	var/active_feed				// The selected feed
	var/list/warrant			// The warrant as we last knew it
	var/list/feeds = list()		// The list of feeds as we last knew them
	var/list/feed_info = list()	// The data and contents of each feed as we last knew them

	var/list/cartmodes = list(40, 42, 43, 433, 44, 441, 45, 451, 46, 48, 47, 49) // If you add more cartridge modes add them to this list as well.
	var/list/no_auto_update = list(1, 40, 43, 44, 441, 45, 451)		     // These modes we turn off autoupdate
	var/list/update_every_five = list(3, 41, 433, 46, 47, 48, 49)			     // These we update every 5 ticks

	var/obj/item/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above - this is assignment (potentially alt title)
	var/ownrank = null // this one is rank, never alt title

	var/obj/item/paicard/pai = null	// A slot for a personal AI device

/obj/item/pda/examine(mob/user, dist)
	. = ..()
	. += "The time [stationtime2text()] is displayed in the corner of the screen."

/obj/item/pda/CtrlClick()
	if (issilicon(usr))
		return

	if (can_use(usr))
		remove_pen()
		return
	..()

/obj/item/pda/AltClick()
	if(issilicon(usr))
		return

	if (can_use(usr))
		if(id)
			remove_id()
		else
			to_chat(usr, "<span class='notice'>This PDA does not have an ID in it.</span>")


/obj/item/pda/medical
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-m"

/obj/item/pda/viro
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-v"

/obj/item/pda/engineering
	default_cartridge = /obj/item/cartridge/engineering
	icon_state = "pda-e"

/obj/item/pda/security
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-s"

/obj/item/pda/detective
	default_cartridge = /obj/item/cartridge/detective
	icon_state = "pda-det"

/obj/item/pda/warden
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-warden"

/obj/item/pda/janitor
	default_cartridge = /obj/item/cartridge/janitor
	icon_state = "pda-j"
	ringtone = "slip"

/obj/item/pda/science
	default_cartridge = /obj/item/cartridge/signal/science
	icon_state = "pda-tox"
	ringtone = "boom"

/obj/item/pda/clown
	default_cartridge = /obj/item/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ringtone = "honk"

/obj/item/pda/mime
	default_cartridge = /obj/item/cartridge/mime
	icon_state = "pda-mime"
	message_silent = 1
	news_silent = 1
	ringtone = "silence"
	newstone = "silence"

/obj/item/pda/heads
	default_cartridge = /obj/item/cartridge/head
	icon_state = "pda-h"
	news_silent = 1

/obj/item/pda/heads/hop
	default_cartridge = /obj/item/cartridge/hop
	icon_state = "pda-hop"

/obj/item/pda/heads/hos
	default_cartridge = /obj/item/cartridge/hos
	icon_state = "pda-hos"

/obj/item/pda/heads/blueshield
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-hop"

/obj/item/pda/heads/ce
	default_cartridge = /obj/item/cartridge/ce
	icon_state = "pda-ce"

/obj/item/pda/heads/cmo
	default_cartridge = /obj/item/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/pda/heads/rd
	default_cartridge = /obj/item/cartridge/rd
	icon_state = "pda-rd"

/obj/item/pda/captain
	default_cartridge = /obj/item/cartridge/captain
	icon_state = "pda-c"
	detonate = 0
	//toff = 1

/obj/item/pda/ert
	default_cartridge = /obj/item/cartridge/captain
	icon_state = "pda-h"
	detonate = 0
//	hidden = 1

/obj/item/pda/cargo
	default_cartridge = /obj/item/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/pda/quartermaster
	default_cartridge = /obj/item/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/pda/shaftminer
	icon_state = "pda-miner"
	default_cartridge = /obj/item/cartridge/miner

/obj/item/pda/syndicate
	default_cartridge = /obj/item/cartridge/syndicate
	icon_state = "pda-syn"
	hidden = 1

/obj/item/pda/chaplain
	default_cartridge = /obj/item/cartridge/service
	icon_state = "pda-holy"
	ringtone = "holy"

/obj/item/pda/lawyer
	default_cartridge = /obj/item/cartridge/lawyer
	icon_state = "pda-lawyer"
	ringtone = "..."

/obj/item/pda/botanist
	default_cartridge = /obj/item/cartridge/service
	icon_state = "pda-hydro"

/obj/item/pda/roboticist
	default_cartridge = /obj/item/cartridge/signal/science
	icon_state = "pda-robot"

/obj/item/pda/librarian
	default_cartridge = /obj/item/cartridge/service
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	message_silent = 1 //Quiet in the library!
	news_silent = 0		// Librarian is above the law!  (That and alt job title is reporter)

/obj/item/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/pda/chef
	default_cartridge = /obj/item/cartridge/service
	icon_state = "pda-chef"

/obj/item/pda/bar
	default_cartridge = /obj/item/cartridge/service
	icon_state = "pda-bar"

/obj/item/pda/atmos
	default_cartridge = /obj/item/cartridge/atmos
	icon_state = "pda-atmo"

/obj/item/pda/chemist
	default_cartridge = /obj/item/cartridge/chemistry
	icon_state = "pda-chem"

/obj/item/pda/geneticist
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-gene"


// Special AI/pAI PDAs that cannot explode.
/obj/item/pda/ai
	icon_state = "NONE"
	ringtone = "data"
	newstone = "news"
	detonate = 0


/obj/item/pda/ai/proc/set_name_and_job(newname as text, newjob as text, newrank as null|text)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob
	name = newname + " (" + ownjob + ")"

//AI verb and proc for sending PDA messages.
/obj/item/pda/ai/verb/cmd_send_pdamesg()
	set category = "AI IM"
	set name = "Send Message"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	var/list/plist = available_pdas()
	tim_sort(plist, cmp = GLOBAL_PROC_REF(cmp_text_asc))
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in plist
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		create_message(usr, selected, 0)

/obj/item/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI IM"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	toff = !toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(toff ? "Off" : "On")]!</span>")

/obj/item/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI IM"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	message_silent=!message_silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(message_silent ? "Off" : "On")]!</span>")

/obj/item/pda/ai/verb/cmd_show_message_log()
	set category = "AI IM"
	set name = "Show Message Log"
	set src in usr
	if(usr.stat == 2)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>"
	for(var/index in tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To <a href='byond://?src=\ref[src];choice=Message;notap=1;target=",index["src"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From <a href='byond://?src=\ref[src];choice=Message;notap=1;target=",index["target"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
	HTML +="</body></html>"
	usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")


/obj/item/pda/ai/can_use()
	return 1


/obj/item/pda/ai/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return


/obj/item/pda/ai/pai
	ringtone = "assist"


// Used for the PDA multicaster, which mirrors messages sent to it to a specific department,
/obj/item/pda/multicaster
	ownjob = "Relay"
	icon_state = "NONE"
	ringtone = "data"
	detonate = 0
	news_silent = 1
	var/list/cartridges_to_send_to = list()

// This is what actually mirrors the message,
/obj/item/pda/multicaster/new_message(var/sending_unit, var/sender, var/sender_job, var/message)
	if(sender)
		var/list/targets = list()
		for(var/obj/item/pda/pda in GLOB.PDAs)
			if(pda.cartridge && pda.owner && is_type_in_list(pda.cartridge, cartridges_to_send_to))
				targets |= pda
		if(targets.len)
			for(var/obj/item/pda/target in targets)
				create_message(target, sender, sender_job, message)

// This has so much copypasta,
/obj/item/pda/multicaster/create_message(var/obj/item/pda/P, var/original_sender, var/original_job, var/t)
	t = sanitize(t, MAX_MESSAGE_LEN, 0)
	t = replace_characters(t, list("&#34;" = "\""))
	if (!t || !istype(P))
		return

	if (isnull(P)||P.toff || toff)
		return

	last_text = world.time
	var/datum/reception/reception = get_reception(src, P, t)
	t = reception.message

	if(reception.message_server && (reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER)) // only send the message if it's stable,
		if(reception.telecomms_reception & TELECOMMS_RECEPTION_RECEIVER == 0) // Does our recipient have a broadcaster on their level?,
			return
		var/send_result = reception.message_server.send_pda_message("[P.owner]","[owner]","[t]")
		if (send_result)
			return

		P.tnote.Add(list(list("sent" = 0, "owner" = "[owner]", "job" = "[ownjob]", "message" = "[t]", "target" = "\ref[src]")))

		if(!P.conversations.Find("\ref[src]"))
			P.conversations.Add("\ref[src]")

		P.new_message(src, "[original_sender] \[Relayed\]", original_job, t, 0)

	else
		return

/obj/item/pda/multicaster/command/Initialize(mapload)
	. = ..()
	owner = "Command Department"
	name = "Command Department (Relay)"
	cartridges_to_send_to = command_cartridges

/obj/item/pda/multicaster/security/Initialize(mapload)
	. = ..()
	owner = "Security Department"
	name = "Security Department (Relay)"
	cartridges_to_send_to = security_cartridges

/obj/item/pda/multicaster/engineering/Initialize(mapload)
	. = ..()
	owner = "Engineering Department"
	name = "Engineering Department (Relay)"
	cartridges_to_send_to = engineering_cartridges

/obj/item/pda/multicaster/medical/Initialize(mapload)
	. = ..()
	owner = "Medical Department"
	name = "Medical Department (Relay)"
	cartridges_to_send_to = medical_cartridges

/obj/item/pda/multicaster/research/Initialize(mapload)
	. = ..()
	owner = "Research Department"
	name = "Research Department (Relay)"
	cartridges_to_send_to = research_cartridges

/obj/item/pda/multicaster/cargo/Initialize(mapload)
	. = ..()
	owner = "Cargo Department"
	name = "Cargo Department (Relay)"
	cartridges_to_send_to = cargo_cartridges

/obj/item/pda/multicaster/civilian/Initialize(mapload)
	. = ..()
	owner = "Civilian Services Department"
	name = "Civilian Services Department (Relay)"
	cartridges_to_send_to = civilian_cartridges

/*
 *	The Actual PDA
 */

/obj/item/pda/Initialize(mapload)
	. = ..()
	GLOB.PDAs += src
	tim_sort(GLOB.PDAs, cmp = GLOBAL_PROC_REF(cmp_name_asc))
	if(default_cartridge)
		cartridge = new default_cartridge(src)
	new /obj/item/pen(src)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		var/pdachoice = H.pdachoice
		switch(pdachoice)
			if(1) icon = 'icons/obj/pda.dmi'
			if(2) icon = 'icons/obj/pda_slim.dmi'
			if(3) icon = 'icons/obj/pda_old.dmi'
			if(4) icon = 'icons/obj/pda_rugged.dmi'
			if(5) icon = 'icons/obj/pda_minimal.dmi'
			if(6) icon = 'icons/obj/pda_holo.dmi'
			if(7)
				icon = 'icons/obj/pda_wrist.dmi'
				item_state = icon_state
				item_icons = list(
					SLOT_ID_BELT = 'icons/mob/clothing/pda_wrist.dmi',
					SLOT_ID_WORN_ID = 'icons/mob/clothing/pda_wrist.dmi',
					SLOT_ID_GLOVES = 'icons/mob/clothing/pda_wrist.dmi'
				)
				desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a wrist-bound version."
				slot_flags = SLOT_ID | SLOT_BELT | SLOT_GLOVES
				LAZYINITLIST(sprite_sheets)
				sprite_sheets = list(
				SPECIES_TESHARI = 'icons/mob/clothing/species/teshari/pda_wrist.dmi',
				SPECIES_VR_TESHARI = 'icons/mob/clothing/species/teshari/pda_wrist.dmi',
				)
			else
				icon = 'icons/obj/pda_old.dmi'
				log_debug(SPAN_DEBUG("Invalid switch for PDA, defaulting to old PDA icons. [pdachoice] chosen."))


/obj/item/pda/proc/can_use()

	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(!CHECK_MOBILITY(M, MOBILITY_CAN_USE))
		return 0
	if((src in M.contents) || ( istype(loc, /turf) && in_range(src, M) ))
		return 1
	else
		return 0

/obj/item/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/pda/GetID()
	return id

/obj/item/pda/OnMouseDropLegacy(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /atom/movable/screen)) && can_use())
		return attack_self(M)
	return


/obj/item/pda/nano_ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui_tick++
	var/datum/nanoui/old_ui = SSnanoui.get_open_ui(user, src, "main")
	var/auto_update = 1
	if(mode in no_auto_update)
		auto_update = 0
	if(old_ui && (mode == lastmode && (ui_tick % 5) && (mode in update_every_five)))
		return

	lastmode = mode

	var/title = "Personal Data Assistant"

	var/data[0]  // This is the data that will be sent to the PDA

	data["owner"] = owner					// Who is your daddy...
	data["ownjob"] = ownjob					// ...and what does he do?

	data["mode"] = mode					// The current view
	data["scanmode"] = scanmode				// Scanners
	data["fon"] = fon					// Flashlight on?
	data["pai"] = (isnull(pai) ? 0 : 1)			// pAI inserted?
	data["note"] = note					// current pda notes
	data["message_silent"] = message_silent					// does the pda make noise when it receives a message?
	data["news_silent"] = news_silent					// does the pda make noise when it receives news?
	data["toff"] = toff					// is the messenger function turned off?
	data["active_conversation"] = active_conversation	// Which conversation are we following right now?


	data["idInserted"] = (id ? 1 : 0)
	data["idLink"] = (id ? "[id.registered_name], [id.assignment]" : "--------")

	data["cart_loaded"] = cartridge ? 1:0
	if(cartridge)
		var/cartdata[0]
		cartdata["access"] = list(\
					"access_security" = cartridge.access_security,\
					"access_engine" = cartridge.access_engine,\
					"access_atmos" = cartridge.access_atmos,\
					"access_medical" = cartridge.access_medical,\
					"access_clown" = cartridge.access_clown,\
					"access_mime" = cartridge.access_mime,\
					"access_janitor" = cartridge.access_janitor,\
					"access_quartermaster" = cartridge.access_quartermaster,\
					"access_hydroponics" = cartridge.access_hydroponics,\
					"access_reagent_scanner" = cartridge.access_reagent_scanner,\
					"access_remote_door" = cartridge.access_remote_door,\
					"access_status_display" = cartridge.access_status_display,\
					"access_detonate_pda" = cartridge.access_detonate_pda\
			)

		if(mode in cartmodes)
			data["records"] = cartridge.create_NanoUI_values()

		if(mode == 0)
			cartdata["name"] = cartridge.name
			if(isnull(cartridge.radio))
				cartdata["radio"] = 0
			else
				if(istype(cartridge.radio, /obj/item/integated_radio/beepsky))
					cartdata["radio"] = 1
				if(istype(cartridge.radio, /obj/item/integated_radio/signal))
					cartdata["radio"] = 2
				//if(istype(cartridge.radio, /obj/item/integated_radio/mule))
				//	cartdata["radio"] = 3

		if(mode == 2)
			cartdata["charges"] = cartridge.charges ? cartridge.charges : 0
		data["cartridge"] = cartdata

	data["stationTime"] = stationtime2text()
	data["new_Message"] = new_message
	data["new_News"] = new_news

	var/datum/reception/reception = get_reception(src, do_sleep = 0)
	var/has_reception = reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER
	data["reception"] = has_reception

	if(mode==2)
		var/convopdas[0]
		var/pdas[0]
		var/count = 0
		for (var/obj/item/pda/P in GLOB.PDAs)
			if (!P.owner||P.toff||P == src||P.hidden)       continue
			if(conversations.Find("\ref[P]"))
				convopdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
			else
				pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
			count++

		data["convopdas"] = convopdas
		data["pdas"] = pdas
		data["pda_count"] = count

	if(mode==21)
		data["messagescount"] = tnote.len
		data["messages"] = tnote
	else
		data["messagescount"] = null
		data["messages"] = null

	if(active_conversation)
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				data["convo_name"] = sanitize(c["owner"])
				data["convo_job"] = sanitize(c["job"])
				break
	if(mode==41)
		data_core.get_manifest_list()


	if(mode==3)
		data["aircontents"] = src.analyze_air()
	if(mode==6)
		if(has_reception)
			feeds.Cut()
			for(var/datum/feed_channel/channel in news_network.network_channels)
				feeds[++feeds.len] = list("name" = channel.channel_name, "censored" = channel.censored)
		data["feedChannels"] = feeds
	if(mode==61)
		var/datum/feed_channel/FC
		for(FC in news_network.network_channels)
			if(FC.channel_name == active_feed["name"])
				break

		var/list/feed = feed_info[active_feed]
		if(!feed)
			feed = list()
			feed["channel"] = FC.channel_name
			feed["author"]	= "Unknown"
			feed["censored"]= 0
			feed["updated"] = -1
			feed_info[active_feed] = feed

		if(FC.updated > feed["updated"] && has_reception)
			feed["author"]	= FC.author
			feed["updated"]	= FC.updated
			feed["censored"] = FC.censored

			var/list/messages = list()
			if(!FC.censored)
				var/index = 0
				for(var/datum/feed_message/FM in FC.messages)
					index++
					if(FM.img)
						usr << browse_rsc(FM.img, "pda_news_tmp_photo_[feed["channel"]]_[index].png")
					// News stories are HTML-stripped but require newline replacement to be properly displayed in NanoUI
					var/body = replacetext(FM.body, "\n", "<br>")
					messages[++messages.len] = list("author" = FM.author, "body" = body, "message_type" = FM.message_type, "time_stamp" = FM.time_stamp, "has_image" = (FM.img != null), "caption" = FM.caption, "index" = index)
			feed["messages"] = messages

		data["feed"] = feed

	data["manifest"] = GLOB.PDA_Manifest

	nanoUI = data
	// update the ui if it exists, returns null if no ui is passed/found

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		// the ui does not exist, so we'll create a new() one
	        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "pda.tmpl", title, 520, 400, state = inventory_state)
		// add templates for screens in common with communicator.
		ui.add_template("atmosphericScan", "atmospheric_scan.tmpl")
		ui.add_template("crewManifest", "crew_manifest.tmpl")
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
	// auto update every Master Controller tick
	ui.set_auto_update(auto_update)

//NOTE: graphic resources are loaded on client login
/obj/item/pda/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return

	user.set_machine(src)

	if(active_uplink_check(user))
		return

	nano_ui_interact(user) //NanoUI requires this proc
	return

/obj/item/pda/Topic(href, href_list)
	if(href_list["cartmenu"] && !isnull(cartridge))
		cartridge.Topic(href, href_list)
		return 1
	if(href_list["radiomenu"] && !isnull(cartridge) && !isnull(cartridge.radio))
		cartridge.radio.Topic(href, href_list)
		return 1


	..()
	var/mob/user = usr
	var/datum/nanoui/ui = SSnanoui.get_open_ui(user, src, "main")
	var/mob/living/U = usr
	//Looking for master was kind of pointless since PDAs don't appear to have one.
	//if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ) )
	if (usr.stat == DEAD)
		return 0
	if(!can_use()) //Why reinvent the wheel? There's a proc that does exactly that.
		U.unset_machine()
		if(ui)
			ui.close()
		return 0

	U.set_machine(src)

	switch(href_list["choice"])

//BASIC FUNCTIONS===================================

		if("Close")//Self explanatory
			U.unset_machine()
			ui.close()
			return 0
		if("Refresh")//Refresh, goes to the end of the proc.
		if("Return")//Return
			if(mode<=9)
				mode = 0
			else
				mode = round(mode/10)
				if(mode==2)
					active_conversation = null
				if(mode==4)//Fix for cartridges. Redirects to hub.
					mode = 0
				else if(mode >= 40 && mode <= 49)//Fix for cartridges. Redirects to refresh the menu.
					cartridge.mode = mode
		if ("Authenticate")//Checks for ID
			id_check(U, 1)
		if("UpdateInfo")
			ownjob = id.assignment
			ownrank = id.rank
			name = "PDA-[owner] ([ownjob])"
		if("Eject")//Ejects the cart, only done from hub.
			verb_remove_cartridge()

//MENU FUNCTIONS===================================

		if("0")//Hub
			mode = 0
		if("1")//Notes
			mode = 1
		if("2")//Messenger
			mode = 2
		if("21")//Read messages
			mode = 21
		if("3")//Atmos scan
			mode = 3
		if("4")//Redirects to hub
			mode = 0
		if("chatroom") // chatroom hub
			mode = 5
		if("41") //Manifest
			mode = 41


//MAIN FUNCTIONS===================================

		if("Light")
			if(fon)
				fon = 0
				set_light(0)
			else
				fon = 1
				set_light(f_lum)
		if("Medical Scan")
			if(scanmode == 1)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_medical))
				scanmode = 1
		if("Reagent Scan")
			if(scanmode == 3)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_reagent_scanner))
				scanmode = 3
		if("Halogen Counter")
			if(scanmode == 4)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_engine))
				scanmode = 4
		if("Honk")
			if ( !(last_honk && world.time < last_honk + 20) )
				playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
				last_honk = world.time
		if("Gas Scan")
			if(scanmode == 5)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_atmos))
				scanmode = 5

//MESSENGER/NOTE FUNCTIONS===================================

		if ("Edit")
			var/n = input(U, "Please enter message", name, notehtml) as message
			if (in_range(src, U) && loc == U)
				n = sanitizeSafe(n, extra = 0)
				if (mode == 1)
					note = html_decode(n)
					notehtml = note
					note = replacetext(note, "\n", "<br>")
			else
				ui.close()
		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			message_silent = !message_silent
		if("Toggle News")
			news_silent = !news_silent
		if("Clear")//Clears messages
			if(href_list["option"] == "All")
				tnote.Cut()
				conversations.Cut()
			if(href_list["option"] == "Convo")
				var/new_tnote[0]
				for(var/i in tnote)
					if(i["target"] != active_conversation)
						new_tnote[++new_tnote.len] = i
				tnote = new_tnote
				conversations.Remove(active_conversation)

			active_conversation = null
			if(mode==21)
				mode=2

		if("Ringtone")
			var/t = input(U, "Please enter a new ringtone.", name, ringtone) as text
			if (in_range(src, U) && loc == U && t)
				if(src.hidden_uplink && hidden_uplink.check_trigger(U, lowertext(t), lowertext(lock_code)))
					to_chat(U, "The PDA softly beeps.")
					ui.close()
				else
					ringtone = sanitize(t, 20)
			else
				ui.close()
				return 0
		if("Newstone")
			var/t = input(U, "Please enter new news tone", name, newstone) as text
			if (in_range(src, U) && loc == U && t)
				newstone = sanitize(t, 20)
			else
				ui.close()
				return 0
		if("Message")

			var/obj/item/pda/P = locate(href_list["target"])
			src.create_message(U, P, !href_list["notap"])
			if(mode == 2)
				if(href_list["target"] in conversations)            // Need to make sure the message went through, if not welp.
					active_conversation = href_list["target"]
					mode = 21

		if("Select Conversation")
			var/P = href_list["convo"]
			for(var/n in conversations)
				if(P == n)
					active_conversation=P
					mode=21
		if("Select Feed")
			var/n = href_list["name"]
			for(var/f in feeds)
				if(f["name"] == n)
					active_feed = f
					mode=61
		if("Send Honk")//Honk virus
			if(cartridge && cartridge.access_clown)//Cartridge checks are kind of unnecessary since everything is done through switch.
				var/obj/item/pda/P = locate(href_list["target"])//Leaving it alone in case it may do something useful, I guess.
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--
						U.show_message("<span class='notice'>Virus sent!</span>", 1)
						P.honkamt = (rand(15,20))
				else
					to_chat(U, "PDA not found.")
			else
				ui.close()
				return 0
		if("Send Silence")//Silent virus
			if(cartridge && cartridge.access_mime)
				var/obj/item/pda/P = locate(href_list["target"])
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--
						U.show_message("<span class='notice'>Virus sent!</span>", 1)
						P.message_silent = 1
						P.news_silent = 1
						P.ringtone = "silence"
						P.newstone = "silence"
				else
					to_chat(U, "PDA not found.")
			else
				ui.close()
				return 0


//SYNDICATE FUNCTIONS===================================

		if("Toggle Door")
			if(cartridge && cartridge.access_remote_door)
				for(var/obj/machinery/door/blast/M in GLOB.machines)
					if(M.id == cartridge.remote_door_id)
						if(M.density)
							M.open()
						else
							M.close()

		if("Detonate")//Detonate PDA... maybe
			if(cartridge && cartridge.access_detonate_pda)
				var/obj/item/pda/P = locate(href_list["target"])
				var/datum/reception/reception = get_reception(src, P, "", do_sleep = 0)
				if(!(reception.message_server && reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER))
					U.show_message("<span class='warning'>An error flashes on your [src]: Connection unavailable</span>", 1)
					return
				if(reception.telecomms_reception & TELECOMMS_RECEPTION_RECEIVER == 0) // Does our recepient have a broadcaster on their level?
					U.show_message("<span class='warning'>An error flashes on your [src]: Recipient unavailable</span>", 1)
					return
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--

						var/difficulty = 2

						if(P.cartridge)
							difficulty += P.cartridge.access_medical
							difficulty += P.cartridge.access_security
							difficulty += P.cartridge.access_engine
							difficulty += P.cartridge.access_clown
							difficulty += P.cartridge.access_janitor
							if(P.hidden_uplink)
								difficulty += 3

						if(prob(difficulty))
							U.show_message("<span class='warning'>An error flashes on your [src].</span>", 1)
						else if (prob(difficulty * 7))
							U.show_message("<span class='warning'>Energy feeds back into your [src]!</span>", 1)
							ui.close()
							detonate_act(src)
							log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up")
							message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge but failed.", 1)
						else
							U.show_message("<span class='notice'>Success!</span>", 1)
							log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge and succeeded")
							message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge and succeeded.", 1)
							detonate_act(P)
					else
						to_chat(U, "No charges left.")

				else
					to_chat(U, "PDA not found.")
			else
				U.unset_machine()
				ui.close()
				return 0

//pAI FUNCTIONS===================================
		if("pai")
			if(pai)
				if(pai.loc != src)
					pai = null
				else
					switch(href_list["option"])
						if("1")		// Configure pAI device
							pai.attack_self(U)
						if("2")		// Eject pAI device
							var/turf/T = get_turf_or_move(src.loc)
							if(T)
								pai.forceMove(T)
								pai = null

		else
			mode = text2num(href_list["choice"])
			if(cartridge)
				cartridge.mode = mode

//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 21)//To clear message overlays.
		new_message = 0
		update_icon()

	if (mode == 6||mode == 61)//To clear news overlays.
		new_news = 0
		update_icon()

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	return 1 // return 1 tells it to refresh the UI in NanoUI

/obj/item/pda/update_icon()
	..()

	cut_overlays()
	if(new_message || new_news)
		add_overlay(image(icon, "pda-r"))

/obj/item/pda/proc/detonate_act(var/obj/item/pda/P)
	//TODO: sometimes these attacks show up on the message server
	var/i = rand(1,100)
	var/j = rand(0,1) //Possibility of losing the PDA after the detonation
	var/message = ""
	var/mob/living/M = null
	if(ismob(P.loc))
		M = P.loc

	//switch(i) //Yes, the overlapping cases are intended.
	if(i<=10) //The traditional explosion
		P.explode()
		j=1
		message += "Your [P] suddenly explodes!"
	if(i>=10 && i<= 20) //The PDA burns a hole in the holder.
		j=1
		if(M && isliving(M))
			M.apply_damage( rand(30,60) , DAMAGE_TYPE_BURN)
		message += "You feel a searing heat! Your [P] is burning!"
	if(i>=20 && i<=25) //EMP
		empulse(P.loc, 1, 2, 4, 6, 1)
		message += "Your [P] emits a wave of electromagnetic energy!"
	if(i>=25 && i<=40) //Smoke
		var/datum/effect_system/smoke_spread/chem/S = new /datum/effect_system/smoke_spread/chem
		S.attach(P.loc)
		S.set_up(P, 10, 0, P.loc)
		playsound(P.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		S.start()
		message += "Large clouds of smoke billow forth from your [P]!"
	if(i>=40 && i<=45) //Bad smoke
		var/datum/effect_system/smoke_spread/bad/B = new /datum/effect_system/smoke_spread/bad
		B.attach(P.loc)
		B.set_up(P, 10, 0, P.loc)
		playsound(P.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		B.start()
		message += "Large clouds of noxious smoke billow forth from your [P]!"
	if(i>=65 && i<=75) //Weaken
		if(M && isliving(M))
			M.apply_effects(0,1)
		message += "Your [P] flashes with a blinding white light! You feel weaker."
	if(i>=75 && i<=85) //Stun and stutter
		if(M && isliving(M))
			M.apply_effects(1,0,0,0,1)
		message += "Your [P] flashes with a blinding white light! You feel weaker."
	if(i>=85) //Sparks
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(2, 1, P.loc)
		s.start()
		message += "Your [P] begins to spark violently!"
	if(i>45 && i<65 && prob(50)) //Nothing happens
		message += "Your [P] bleeps loudly."
		j = prob(10)

	if(j && detonate) //This kills the PDA
		qdel(P)
		if(message)
			message += "It melts in a puddle of plastic."
		else
			message += "Your [P] shatters in a thousand pieces!"

	if(M && isliving(M))
		message = "<span class='warning'>[message]</span>"
		M.show_message(message, 1)

/obj/item/pda/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands_or_drop(id)
			to_chat(usr, "<span class='notice'>You remove the ID from the [name].</span>")
		else
			id.forceMove(drop_location())
		id = null

/obj/item/pda/proc/remove_pen()
	var/obj/item/pen/O = locate() in src
	if(O)
		if(istype(loc, /mob))
			var/mob/M = loc
			if(M.get_active_held_item() == null)
				M.put_in_hands(O)
				to_chat(usr, "<span class='notice'>You remove \the [O] from \the [src].</span>")
				return
		O.forceMove(get_turf(src))
	else
		to_chat(usr, "<span class='notice'>This PDA does not have a pen in it.</span>")

/obj/item/pda/proc/create_message(var/mob/living/U = usr, var/obj/item/pda/P, var/tap = 1)
	if(tap)
		U.visible_message("<span class='notice'>\The [U] taps on their PDA's screen.</span>")
	var/t = input(U, "Please enter message", P.name, null) as text
	t = sanitize(t)
	//t = readd_quotes(t)
	t = replace_characters(t, list("&#34;" = "\""))
	if (!t || !istype(P))
		return
	if (!in_range(src, U) && loc != U)
		return

	if (isnull(P)||P.toff || toff)
		return

	if (last_text && world.time < last_text + 5)
		return

	if (!can_use())
		return

	if (is_jammed(src))
		return

	last_text = world.time
	var/datum/reception/reception = get_reception(src, P, t)
	t = reception.message

	if(reception.message_server && (reception.telecomms_reception & TELECOMMS_RECEPTION_SENDER)) // only send the message if it's stable
		if(reception.telecomms_reception & TELECOMMS_RECEPTION_RECEIVER == 0) // Does our recipient have a broadcaster on their level?
			to_chat(U, "ERROR: Cannot reach recipient.")
			return
		var/send_result = reception.message_server.send_pda_message("[P.owner]","[owner]","[t]")
		if (send_result)
			to_chat(U, "ERROR: Messaging server rejected your message. Reason: contains '[send_result]'.")
			return

		tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[t]", "target" = "\ref[P]")))
		P.tnote.Add(list(list("sent" = 0, "owner" = "[owner]", "job" = "[ownjob]", "message" = "[t]", "target" = "\ref[src]")))
		for(var/mob/M in GLOB.player_list)
			if(M.stat == DEAD && M.client && (M.get_preference_toggle(/datum/game_preference_toggle/observer/ghost_ears))) // src.client is so that ghosts don't have to listen to mice
				if(istype(M, /mob/new_player))
					continue
				if(M.forbid_seeing_deadchat)
					continue
				M.show_message("<span class='game say'>PDA Message - <span class='name'>[owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span></span>")

		if(!conversations.Find("\ref[P]"))
			conversations.Add("\ref[P]")
		if(!P.conversations.Find("\ref[src]"))
			P.conversations.Add("\ref[src]")

		to_chat(U, "[icon2html(thing = src, target = U)] <b>Sent message to [P.owner] ([P.ownjob]), </b>\"[t]\"")


		if (prob(15)) //Give the AI a chance of intercepting the message
			var/who = src.owner
			if(prob(50))
				who = P.owner
			for(var/mob/living/silicon/ai/ai in GLOB.mob_list)
				// Allows other AIs to intercept the message but the AI won't intercept their own message.
				if(ai.aiPDA != P && ai.aiPDA != src)
					ai.show_message("<i>Intercepted message from <b>[who]</b>: [t]</i>")

		P.new_message_from_pda(src, t)
		SSnanoui.update_user_uis(U, src) // Update the sending user's PDA UI so that they can see the new message
	else
		to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")

/obj/item/pda/proc/new_info(var/beep_silent, var/message_tone, var/reception_message)
	if (!beep_silent)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		for (var/mob/O in hearers(2, loc))
			O.show_message("[icon2html(thing = src, target = world)] *[message_tone]*")
	//Search for holder of the PDA.
	var/mob/living/L = null
	if(loc && isliving(loc))
		L = loc
	//Maybe they are a pAI!
	else
		L = get(src, /mob/living/silicon)

	if(L)
		if(reception_message)
			to_chat(L, reception_message)
		SSnanoui.update_user_uis(L, src) // Update the receiving user's PDA UI so that they can see the new message

/obj/item/pda/proc/new_news(var/message)
	new_info(news_silent, newstone, news_silent ? "" : "[icon2html(thing = src, target = world)] <b>[message]</b>")

	if(!news_silent)
		new_news = 1
		update_icon()

/obj/item/pda/ai/new_news(var/message)
	// Do nothing

/obj/item/pda/proc/new_message_from_pda(var/obj/item/pda/sending_device, var/message)
	if (is_jammed(src))
		return
	new_message(sending_device, sending_device.owner, sending_device.ownjob, message)

/obj/item/pda/proc/new_message(var/sending_unit, var/sender, var/sender_job, var/message, var/reply = 1)
	var/reception_message = "[icon2html(thing = src, target = world)] <b>Message from [sender] ([sender_job]), </b>\"[message]\" ([reply ? "<a href='byond://?src=\ref[src];choice=Message;notap=[istype(loc, /mob/living/silicon)];skiprefresh=1;target=\ref[sending_unit]'>Reply</a>" : "Unable to Reply"])"
	new_info(message_silent, ringtone, reception_message)

	log_pda("(PDA: [sending_unit]) sent \"[message]\" to [name]", usr)
	new_message = 1
	update_icon()

/obj/item/pda/ai/new_message(var/atom/movable/sending_unit, var/sender, var/sender_job, var/message)
	var/track = ""
	if(ismob(sending_unit.loc) && isAI(loc))
		track = "(<a href='byond://?src=\ref[loc];track=\ref[sending_unit.loc];trackname=[html_encode(sender)]'>Follow</a>)"

	var/reception_message = "[icon2html(thing = src, target = world)] <b>Message from [sender] ([sender_job]), </b>\"[message]\" (<a href='byond://?src=\ref[src];choice=Message;notap=1;skiprefresh=1;target=\ref[sending_unit]'>Reply</a>) [track]"
	new_info(message_silent, newstone, reception_message)

	log_pda("(PDA: [sending_unit]) sent \"[message]\" to [name]",usr)
	new_message = 1

/obj/item/pda/verb/verb_reset_pda()
	set category = VERB_CATEGORY_OBJECT
	set name = "Reset PDA"
	set src in usr

	if(issilicon(usr))
		return

	if(can_use(usr))
		mode = 0
		SSnanoui.update_uis(src)
		to_chat(usr, "<span class='notice'>You press the reset button on \the [src].</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/pda/verb/verb_remove_id()
	set category = VERB_CATEGORY_OBJECT
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		if(id)
			remove_id()
		else
			to_chat(usr, "<span class='notice'>This PDA does not have an ID in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")


/obj/item/pda/verb/verb_remove_pen()
	set category = VERB_CATEGORY_OBJECT
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		remove_pen()
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/pda/verb/verb_remove_cartridge()
	set category = VERB_CATEGORY_OBJECT
	set name = "Remove cartridge"
	set src in usr

	if(issilicon(usr))
		return

	if(!can_use(usr))
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")
		return

	if(isnull(cartridge))
		to_chat(usr, "<span class='notice'>There's no cartridge to eject.</span>")
		return

	cartridge.forceMove(get_turf(src))
	if(ismob(loc))
		var/mob/M = loc
		M.put_in_hands(cartridge)
	mode = 0
	scanmode = 0
	if (cartridge.radio)
		cartridge.radio.hostpda = null
	to_chat(usr, "<span class='notice'>You remove \the [cartridge] from the [name].</span>")
	cartridge = null

/obj/item/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
			return 1
		else
			var/obj/item/I = user.get_active_held_item()
			if (istype(I, /obj/item/card/id))
				if(!user.attempt_insert_item_for_installation(I, src))
					return
				id = I
			return 1
	else
		var/obj/item/card/I = user.get_active_held_item()
		if (istype(I, /obj/item/card/id) && I:registered_name)
			var/obj/old_id = id
			if(!user.attempt_insert_item_for_installation(I, src))
				return
			id = I
			if(old_id && !user.put_in_hands(old_id))
				return
			return 1
	return 0

// access to status display signals
/obj/item/pda/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(istype(C, /obj/item/cartridge) && !cartridge)
		if(!user.attempt_insert_item_for_installation(C, src))
			return
		cartridge = C
		to_chat(usr, "<span class='notice'>You insert [cartridge] into [src].</span>")
		SSnanoui.update_uis(src) // update all UIs attached to src
		if(cartridge.radio)
			cartridge.radio.hostpda = src

	else if(istype(C, /obj/item/card/id))
		var/obj/item/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			ownrank = idcard.rank
			name = "PDA-[owner] ([ownjob])"
			to_chat(user, "<span class='notice'>Card scanned.</span>")
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if(id_check(user, 2))
					to_chat(user, "<span class='notice'>You put the ID into \the [src]'s slot.</span>")
					updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(C, /obj/item/paicard) && !pai)
		if(!user.attempt_insert_item_for_installation(C, src))
			return
		pai = C
		to_chat(user, "<span class='notice'>You slot \the [C] into \the [src].</span>")
		SSnanoui.update_uis(src) // update all UIs attached to src
	else if(istype(C, /obj/item/pen))
		var/obj/item/pen/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else
			if(!user.attempt_insert_item_for_installation(C, src))
				return
			to_chat(user, "<span class='notice'>You slot \the [C] into \the [src].</span>")

/obj/item/pda/legacy_mob_melee_hook(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	var/mob/living/carbon/C = target
	if (istype(C, /mob/living/carbon))
		switch(scanmode)
			if(1)

				for (var/mob/O in viewers(C, null))
					O.show_message(SPAN_WARNING("\The [user] has analyzed [C]'s vitals!"), SAYCODE_TYPE_VISIBLE)
				user.show_message(SPAN_NOTICE("Analyzing Results for [C]:"))
				user.show_message(SPAN_NOTICE("[FOURSPACES]Overall Status: [C.stat > 1 ? "dead" : "[C.health - C.halloss]% healthy"]"), SAYCODE_TYPE_VISIBLE)
				user.show_message(
					"<span class='notice'>[FOURSPACES]Damage Specifics:</span> <span class='[(C.getOxyLoss() > 50) ? "warning" : ""]'>[C.getOxyLoss()]</span>-<span class='[(C.getToxLoss() > 50) ? "warning" : ""]'>[C.getToxLoss()]</span>-<span class='[(C.getFireLoss() > 50) ? "warning" : ""]'>[C.getFireLoss()]</span>-<span class='[(C.getBruteLoss() > 50) ? "warning" : ""]'>[C.getBruteLoss()]</span>",
					SAYCODE_TYPE_VISIBLE
				)
				user.show_message(SPAN_NOTICE("[FOURSPACES]Key: Suffocation/Toxin/Burns/Brute"), 1)
				user.show_message(SPAN_NOTICE("[FOURSPACES]Body Temperature: [C.bodytemperature-T0C]&deg;C ([C.bodytemperature*1.8-459.67]&deg;F)"), SAYCODE_TYPE_VISIBLE)
				if(C.tod && (C.stat == DEAD || (C.status_flags & STATUS_FAKEDEATH)))
					user.show_message(SPAN_NOTICE("[FOURSPACES]Time of Death: [C.tod]"))
				if(istype(C, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = C
					var/list/damaged = H.get_damaged_organs(1,1)
					user.show_message(SPAN_NOTICE("Localized Damage, Brute/Burn:"), SAYCODE_TYPE_VISIBLE)
					if(length(damaged)>0)
						for(var/obj/item/organ/external/org in damaged)
							user.show_message(
								SPAN_NOTICE("[FOURSPACES][capitalize(org.name)]: <span class='[(org.brute_dam > 0) ? "warning" : "notice"]'>[org.brute_dam]</span>-<span class='[(org.burn_dam > 0) ? "warning" : "notice"]'>[org.burn_dam]</span>"),
								SAYCODE_TYPE_VISIBLE
							)
					else
						user.show_message(SPAN_NOTICE("[FOURSPACES]Limbs are OK."), SAYCODE_TYPE_VISIBLE)

			if(2)
				if (!istype(C.dna, /datum/dna))
					to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
				else
					to_chat(user, SPAN_NOTICE("\The [C]'s Fingerprints: [md5(C.dna.uni_identity)]"))
				if ( !(C:blood_DNA) )
					to_chat(user, "<span class='notice'>No blood found on [C]</span>")
					if(C:blood_DNA)
						qdel(C:blood_DNA)
				else
					to_chat(user, "<span class='notice'>Blood found on [C]. Analysing...</span>")
					spawn(15)
						for(var/blood in C:blood_DNA)
							to_chat(user, "<span class='notice'>Blood type: [C:blood_DNA[blood]]\nDNA: [blood]</span>")

			if(4)
				user.visible_message("<span class='warning'>\The [user] has analyzed [C]'s radiation levels!</span>", "<span class='notice'>You have analyzed [C]'s radiation levels!</span>")
				to_chat(user, "<span class='notice'>Analyzing Results for [C]:</span>")
				if(C.radiation)
					to_chat(user, "<span class='notice'>Radiation Level: [C.radiation]</span>")
				else
					to_chat(user, "<span class='notice'>No radiation detected.</span>")

/obj/item/pda/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	if(!(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY))
		return
	switch(scanmode)

		if(3)
			if(!isobj(target))
				return
			if(!isnull(target.reagents))
				if(target.reagents.total_volume)
					var/reagents_length = length(target.reagents.reagent_volumes)
					to_chat(user, "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>")
					for (var/re in target.reagents.get_reagent_datums())
						to_chat(user,"<span class='notice'>    [re]</span>")
				else
					to_chat(user,"<span class='notice'>No active chemical agents found in [target].</span>")
			else
				to_chat(user,"<span class='notice'>No significant chemical agents found in [target].</span>")

		if(5)
			analyze_gases(target, user)

	if (!scanmode && istype(target, /obj/item/paper) && owner)
		// JMO 20140705: Makes scanned document show up properly in the notes. Not pretty for formatted documents,
		// as this will clobber the HTML, but at least it lets you scan a document. You can restore the original
		// notes by editing the note again. (Was going to allow you to edit, but scanned documents are too long.)
		var/raw_scan = (target:info)
		var/formatted_scan = ""
		// Scrub out the tags (replacing a few formatting ones along the way)

		// Find the beginning and end of the first tag.
		var/tag_start = findtext(raw_scan,"<")
		var/tag_stop = findtext(raw_scan,">")

		// Until we run out of complete tags...
		while(tag_start&&tag_stop)
			var/pre = copytext(raw_scan,1,tag_start) // Get the stuff that comes before the tag
			var/tag = lowertext(copytext(raw_scan,tag_start+1,tag_stop)) // Get the tag so we can do intellegent replacement
			var/tagend = findtext(tag," ") // Find the first space in the tag if there is one.

			// Anything that's before the tag can just be added as is.
			formatted_scan = formatted_scan+pre

			// If we have a space after the tag (and presumably attributes) just crop that off.
			if (tagend)
				tag=copytext(tag,1,tagend)

			if (tag=="p"||tag=="/p"||tag=="br") // Check if it's I vertical space tag.
				formatted_scan=formatted_scan+"<br>" // If so, add some padding in.

			raw_scan = copytext(raw_scan,tag_stop+1) // continue on with the stuff after the tag

			// Look for the next tag in what's left
			tag_start = findtext(raw_scan,"<")
			tag_stop = findtext(raw_scan,">")

		// Anything that is left in the page. just tack it on to the end as is
		formatted_scan=formatted_scan+raw_scan

    	// If there is something in there already, pad it out.
		if (length(note)>0)
			note = note + "<br><br>"

    	// Store the scanned document to the notes
		note = "Scanned Document. Edit to restore previous notes/delete scan.<br>----------<br>" + formatted_scan + "<br>"
		// notehtml ISN'T set to allow user to get their old notes back. target better implementation would add a "scanned documents"
		// feature to the PDA, which would better convey the availability of the feature, but this will work for now.

		// Inform the user
		to_chat(user,"<span class='notice'>Paper scanned and OCRed to notekeeper.</span>") //concept of scanning paper copyright brainoblivion 2009


/obj/item/pda/proc/explode() //This needs tuning. //Sure did.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)
	if(T)
		T.hotspot_expose(700,125)
		explosion(T, 0, 0, 1, rand(1,2))
	return

/obj/item/pda/Destroy()
	GLOB.PDAs -= src
	if (src.id && prob(100)) //IDs are kept in 100% of the cases //TODO: WHY?
		src.id.forceMove(get_turf(src.loc))
	else
		QDEL_NULL(src.id)
	QDEL_NULL(src.cartridge)
	QDEL_NULL(src.pai)
	return ..()

/obj/item/pda/clown/Crossed(atom/movable/AM as mob|obj) //Clown PDA is slippery.
	. = ..()
	if(AM.is_incorporeal() || AM.is_avoiding_ground())
		return
	if (istype(AM, /mob/living))
		var/mob/living/M = AM

		if(M.slip_act(SLIP_CLASS_LUBRICANT, src, 5, 5) > 0 && M.real_name != src.owner && istype(src.cartridge, /obj/item/cartridge/clown))
			if(src.cartridge.charges < 5)
				src.cartridge.charges++

/obj/item/pda/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()

	if (toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for (var/obj/item/pda/P in GLOB.PDAs)
		if (!P.owner)
			continue
		else if(P.hidden)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue

		var/name = P.owner
		if(names[name])
			names[name]++
			name = "[name] ([names[name]])"
		else
			names[name] = 1

		plist[name] = P
	return plist


//Some spare PDAs in a box
/obj/item/storage/box/PDAs
	name = "box of spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

/obj/item/storage/box/PDAs/New()
	..()
	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/cartridge/head(src)

	var/newcart = pick(
		/obj/item/cartridge/engineering,
		/obj/item/cartridge/medical,
		/obj/item/cartridge/quartermaster,
		/obj/item/cartridge/security,
		/obj/item/cartridge/signal/science,
	)
	new newcart(src)

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)

/obj/item/pda/proc/analyze_air()
	var/list/results = list()
	var/turf/T = get_turf(src.loc)
	if(!isnull(T))
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles
		if (total_moles)
			var/o2_level = environment.gas[GAS_ID_OXYGEN]/total_moles
			var/n2_level = environment.gas[GAS_ID_NITROGEN]/total_moles
			var/co2_level = environment.gas[GAS_ID_CARBON_DIOXIDE]/total_moles
			var/phoron_level = environment.gas[GAS_ID_PHORON]/total_moles
			var/unknown_level =  1-(o2_level+n2_level+co2_level+phoron_level)

			// entry is what the element is describing
			// Type identifies which unit or other special characters to use
			// Val is the information reported
			// Bad_high/_low are the values outside of which the entry reports as dangerous
			// Poor_high/_low are the values outside of which the entry reports as unideal
			// Values were extracted from the template itself
			results = list(
						list("entry" = "Pressure", "units" = "kPa", "val" = "[round(pressure,0.1)]", "bad_high" = 120, "poor_high" = 110, "poor_low" = 95, "bad_low" = 80),
						list("entry" = "Temperature", "units" = "&degC", "val" = "[round(environment.temperature-T0C,0.1)]", "bad_high" = 35, "poor_high" = 25, "poor_low" = 15, "bad_low" = 5),
						list("entry" = "Oxygen", "units" = "kPa", "val" = "[round(o2_level*100,0.1)]", "bad_high" = 140, "poor_high" = 135, "poor_low" = 19, "bad_low" = 17),
						list("entry" = "Nitrogen", "units" = "kPa", "val" = "[round(n2_level*100,0.1)]", "bad_high" = 105, "poor_high" = 85, "poor_low" = 50, "bad_low" = 40),
						list("entry" = "Carbon Dioxide", "units" = "kPa", "val" = "[round(co2_level*100,0.1)]", "bad_high" = 10, "poor_high" = 5, "poor_low" = 0, "bad_low" = 0),
						list("entry" = "Phoron", "units" = "kPa", "val" = "[round(phoron_level*100,0.01)]", "bad_high" = 0.5, "poor_high" = 0, "poor_low" = 0, "bad_low" = 0),
						list("entry" = "Other", "units" = "kPa", "val" = "[round(unknown_level, 0.01)]", "bad_high" = 1, "poor_high" = 0.5, "poor_low" = 0, "bad_low" = 0)
						)

	if(isnull(results))
		results = list(list("entry" = "pressure", "units" = "kPa", "val" = "0", "bad_high" = 120, "poor_high" = 110, "poor_low" = 95, "bad_low" = 80))
	return results

//! ## VR FILE MERGE ## !//
/obj/item/pda/centcom
	default_cartridge = /obj/item/cartridge/captain
	icon_state = "pda-h"
	detonate = 0
//	hidden = 1

/obj/item/pda/pathfinder
	default_cartridge = /obj/item/cartridge/signal/science
	icon_state = "pda-lawyer"

/obj/item/pda/explorer
	default_cartridge = /obj/item/cartridge/signal/science
	icon_state = "pda-det"

/obj/item/pda/sar
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-h"
