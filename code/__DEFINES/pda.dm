#define PDA_PROG_NULL 		0x00
// PDA apps that provide a user interface (manifest, notes).
#define PDA_PROG_FOREGROUND 0x01
// PDA apps that do something when the PDA's used on something (atmos / med scanners).
#define PDA_PROG_SCANNER	0x02
// PDA apps that do something in the background (newscasters, messengers).
#define PDA_PROG_SERVICE	0x04

// PDA loadout types.
#define PDA_CHOICE_NORM    1
#define PDA_CHOICE_SLIM    2
#define PDA_CHOICE_OLD     3
#define PDA_CHOICE_RUGGED  4
#define PDA_CHOICE_MINIMAL 5
#define PDA_CHOICE_HOLO    6
#define PDA_CHOICE_WRIST   7
