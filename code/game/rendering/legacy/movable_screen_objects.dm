
//////////////////////////
//Movable Screen Objects//
//   By RemieRichards	//
//////////////////////////


//Movable Screen Object
//Not tied to the grid, places it's center where the cursor is

/atom/movable/screen/movable
	var/snap2grid = FALSE
	var/moved = FALSE

//Snap Screen Object
//Tied to the grid, snaps to the nearest turf

/atom/movable/screen/movable/snap
	snap2grid = TRUE


/atom/movable/screen/movable/OnMouseDropLegacy(over_object, src_location, over_location, src_control, over_control, params)
	var/list/PM = params2list(params)

	//No screen-loc information? abort.
	if(!PM || !PM["screen-loc"])
		return

	//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
	var/list/screen_loc_params = splittext(PM["screen-loc"], ",")

	//Split X+Pixel_X up into list(X, Pixel_X)
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")
	screen_loc_X[1] = encode_screen_X(text2num(screen_loc_X[1]))
	//Split Y+Pixel_Y up into list(Y, Pixel_Y)
	var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
	screen_loc_Y[1] = encode_screen_Y(text2num(screen_loc_Y[1]))

	if(snap2grid) //Discard Pixel Values
		screen_loc = "[screen_loc_X[1]],[screen_loc_Y[1]]"

	else //Normalise Pixel Values (So the object drops at the center of the mouse, not 16 pixels off)
		var/pix_X = text2num(screen_loc_X[2]) - 16
		var/pix_Y = text2num(screen_loc_Y[2]) - 16
		screen_loc = "[screen_loc_X[1]]:[pix_X],[screen_loc_Y[1]]:[pix_Y]"

	moved = TRUE

/atom/movable/screen/movable/proc/encode_screen_X(X)
	var/view_dist = world.view
	if(view_dist)
		view_dist = view_dist
	if(X > view_dist+1)
		. = "RIGHT-[view_dist *2 + 1-X]"
	else if(X < view_dist +1)
		. = "LEFT+[X-1]"
	else
		. = "CENTER"

/atom/movable/screen/movable/proc/decode_screen_X(X)
	var/view_dist = world.view
	if(view_dist)
		view_dist = view_dist
	//Find RIGHT/LEFT implementations
	if(findtext(X,"RIGHT-"))
		var/num = text2num(copytext(X,6)) //Trim RIGHT-
		if(!num)
			num = 0
		. = view_dist*2 + 1 - num
	else if(findtext(X,"LEFT+"))
		var/num = text2num(copytext(X,6)) //Trim LEFT+
		if(!num)
			num = 0
		. = num+1
	else if(findtext(X,"CENTER"))
		. = view_dist+1

/atom/movable/screen/movable/proc/encode_screen_Y(Y)
	var/view_dist = world.view
	if(view_dist)
		view_dist = view_dist
	if(Y > view_dist+1)
		. = "TOP-[view_dist*2 + 1-Y]"
	else if(Y < view_dist+1)
		. = "BOTTOM+[Y-1]"
	else
		. = "CENTER"

/atom/movable/screen/movable/proc/decode_screen_Y(Y)
	var/view_dist = world.view
	if(view_dist)
		view_dist = view_dist
	if(findtext(Y,"TOP-"))
		var/num = text2num(copytext(Y,7)) //Trim TOP-
		if(!num)
			num = 0
		. = view_dist*2 + 1 - num
	else if(findtext(Y,"BOTTOM+"))
		var/num = text2num(copytext(Y,7)) //Time BOTTOM+
		if(!num)
			num = 0
		. = num+1
	else if(findtext(Y,"CENTER"))
		. = view_dist+1

/**
 * call to try to reset position
 *
 * subtypes must implement this!
 */
/atom/movable/screen/movable/proc/request_position_reset()
	screen_loc = initial(screen_loc)

/**
 * use in Click() to allow ctrl shift click resetting of position
 * like so:
 *
 * /atom/movable/screen/movable/action_button/Click(location, contrl, params)
 * var/list/decoded_params = params2list(params)
 * if(ctrl_shift_click_reset_hook(decoded_params))
 * 	 return
 */
/atom/movable/screen/movable/proc/ctrl_shift_click_reset_hook(list/params)
	if(params["ctrl"] && params["shift"])
		request_position_reset()
		return TRUE
	return FALSE

//Debug procs
/client/proc/test_movable_UI()
	set category = "Debug"
	set name = "Spawn Movable UI Object"

	var/atom/movable/screen/movable/M = new()
	M.name = "Movable UI Object"
	M.icon_state = "block"
	M.maptext = MAPTEXT("Movable")
	M.maptext_width = 64

	var/screen_l = input(usr,"Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Movable UI Object") as text
	if(!screen_l)
		return

	M.screen_loc = screen_l

	screen += M


/client/proc/test_snap_UI()
	set category = "Debug"
	set name = "Spawn Snap UI Object"

	var/atom/movable/screen/movable/snap/S = new()
	S.name = "Snap UI Object"
	S.icon_state = "block"
	S.maptext = MAPTEXT("Snap")
	S.maptext_width = 64

	var/screen_l = input(usr,"Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Snap UI Object") as text
	if(!screen_l)
		return

	S.screen_loc = screen_l

	screen += S
