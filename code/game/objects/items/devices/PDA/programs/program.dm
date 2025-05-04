/**
 * PDA programs.
 * because the last impl was known to the state of california to cause cancer, birth defects, and reproductive harm
 * This datum is not meant to be created outside of a subtype.
 * It holds the base implementation for all PDA programs.
 */
/datum/pda_program
	// Program type, see define for details. Programs must provide procs for the types they provide.
	var/runtype = PDA_PROG_NULL
	// Programs can be of multiple types, this determines what's running.
	var/running = PDA_PROG_NULL
	// Object holding this program, can be a PDA or a cartridge.
	var/host = null

	// Internal program state.
