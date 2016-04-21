/****************************************************************************
*****************************************************************************
    birdmain.c  - Bird Talk Main

    The Bird(tm) position and orientation measurement system is controled
    via a serial RS232 communication link.  This program allows the user
    to 'experiment' with the Bird by selecting control commands from a
    rudimentary menuing system.  After becoming familiar with the commands
    the user can CUT and PASTE code from the source files listed below for
    use in their own application.

    written for:    Ascension Technology Corporation
		    PO Box 527
		    Burlington, Vermont  05402

		    802-655-7879

    written by:     Jeff Finkelstein

    Modification History:

    10/18/90         jf  - released
    11/5/90          jf  - removed the 'Q' and the 'M' command from the Bird
			   initialization
    11/6/90          jf  - added new commands to mainmenu[]
    2/20/91          jf  - moved initialization of factory test to
			   birdloadconfig in BIRDCMDS.c
    4/23/91          jf  - removed ltoa() for NON-DOS applications
    4/24/91          jf  - added initconsole and restoreconsole routines
			   for UNIX platforms
    4/29/91          jf  - renamed birdpositionand.. to birdposand..
    5/20/91          jf  - add revision to Menu Header
    6/18/91          jf  - added FOB baudrate selections
    8/19/91          jf  - updated for prelimary release 3.0
    9/14/91          jf  - updated fob.c..release 3.01
    9/16/91          jf  - removed configuration menu..release 3.02
    10/18/91         jf  - max measurement rate changed to 144..release 3.03
    11/1/91          jf  - added chg/exm alpha max, glitch checking ..
			   release 3.04
    11/7/91          jf  - added exm model ..rev 3.05
    11/28/91         eb  - main menu item 0 changed to quit to DOS
    1/3/92           jf  - revised to revision ..rev 3.06
		     jf  - fixed button mode shutting off problem
    3/23/92          jf  - modified alpha min/max to tables
    3/27/92          jf  - added rs232 to fbb command
    4/7/92           jf  - added set xmtr type ..rev 3.07
		     mo  - added new output modes "Quaternions"
    4/20/92                and "Position/Quaternions"
    5/5/92           jf  - added system test menu selection ..rev 3.08
    6/1/92           jf  - updated examine value for new status
			   definitions ..rev 3.09
    10/12/92         jf  - modified printmatrix..rev 3.10
    11/3/92          jf  - updated for UNIX compatibility ..rev 3.11
    12/5/92          jf  - fixed bug in serpcpl getserialrecord which
			   caused data errors.. rev 3.12
    12/22/92         jf  - updated for Platform compatibility.. rev 3.13
    1/13/93          jf  - serial_init now displays the comport name to
			   to be used
    1/27/93          jf  - merged with MULTI232 for RS232 to FBB command
			   and Group Data Command Display
    1/31/93          jf  - ..rev 3.14 pre release
    2/23/93          jf  - updated for 3.14 release
			   Now, Max RS232 to FBB Data selection is only
			   available with the FACTORYTESTS compile switch
    3/22/93          jf  - added note to expanded error message
			   ..rev 3.15
    7/7/93           jf  - updated to allow button display from multiple
			   devices .. rev 3.16
    10/21/93         jf  - added code to redirect the IRQ 0 (PC TIMER) to
			   our own handler, thereby controlling the interrupt
			   latency.  This allows a DOS Protected Mode
			   Compiler (DPMC) to NOT swith into real mode
			   when the IRQ0 occurs. This revision works
			   with the MetaWare HIGH C compiler and the
			   PHARLAP DOS Extender 386...rev 3.17
    5/23/94          sw  - added BIRD SYSTEM STATUS check for extended/normal 
			   address mode (in Examine Value)
			 - Added XYZ Reference Frame in Examine Value and Change 
			   Value command menu.
			 - Corrected Vm and Alpha_m range tables
    6/23/94          sw  - corrected lockout on no device on comport by 
			   ingaging interupt handler through all of program.
			 - Changed rev number on main screen to 3.18
			 - Factory test of comport speed now works
    9/22/94          sw  - Corrected PCTIMER loop error which lead to lockup
			   on exit of program sometimes.
			 - Corrected "Exteneded" to "Expanded" address mode
			 - Changed rev number to reflect changes.
    5/11/95          sw  - Address mode is only checked in examine value if 
			   user selects a command that will require that information.
			 - Change rev number to reflect change.


       <<<< Copyright 1991 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <stdlib.h>         /* for exit() */
#include <math.h>           /* float math */
#include "asctech.h"        /* Ascension Technology definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "menu.h"           /* Ascension Technology Menu Routines */
#include "serial.h"         /* Ascension Technology Serial Port Routines */
#include "birdcmds.h"       /* Bird Commands */
#include "rstofbb.h"        /* RS232 to FBB Command Info */
#include "cmdutil.h"
#include "pctimer.h"        /* Used to take over IRQ0 (PC TIMER) */
#include "birdmain.h"       /* Prototypes for this file */

/*
    Define Filename Globals
*/
char datafilename[81] = "BIRDDATA.dat";    /* default filename */
FILE * datafilestream;

extern unsigned char displaymultidataflg;
extern unsigned char displayliststartaddr;
extern unsigned char displayliststopaddr;
extern unsigned char fbbsystemstatus[];

#ifdef HIGHC
	void save_ds(void);
#endif

/*
    main                -   Main Program

    Prototype in:       no prototype...called by C startup Code

    Parameters Passed:  void

    Return Value:       0 if exited OK
		       -1 if exited with an error

    Remarks:            The main routine called by the C startup code contains
			the Bird initialization and the main menu selection.
			The routine initializes the serial port to COM1 at
			9600 baud by default.  Default factory addresses are
			also initialized prior to prompting the user with
			the menu selections.
*/

int main()
{
    /*
	Declare the Main Menu
    */
    short exitflag = FALSE;       /* exit flag */
    short buttonmode = 0;         /* holds the buttonmode, 0=manual, 1=send always */
    short tempbuttonmode;         /* temp value of buttonmode */
    unsigned char datamode = POSANGLE; /* default data mode */
    short user_sel;


    static char * mainmenuhdr =
"****************************************************************************\n\r\
* ASCENSION TECHNOLOGY CORPORATION - Bird Main Menu          Revision 3.21 *\n\r\
****************************************************************************\n\r";

    static char * mainmenuptr[] =
	       {"Main Menu Selections:",
		"Quit to DOS",
		"Position",
		"Angles",
		"Matrix",
		"Quaternions",
		"Position/Angles",
		"Position/Matrix",
		"Position/Quaternions",
		"Angle Align",
		"Hemisphere",
		"Reference Frame",
		"Report Rate",
		"Sleep/Wakeup",
		"Mouse Buttons",
		"XON/XOFF",
		"Change Value",
		"Examine Value",
		"Syncronization",
		"FBB Next Master",
		"FBB Next Transmitter",
		"Data Display List Address Init",
		"RS232 to FBB Address Init",
		"Set Transmitter Type",
		"Serial Port Configuration",
		"System Tests"};


#ifdef DOS  /* Redirect IRQ 0 to our own handler */
    pctimer_init(TICK_MSECS);
#endif
    
    /*
	Initialize the Position Conversion Constant
	...done here for compatibility with Coherent's Compiler,
	which can't evalute POSK36 at compile time
    */
    posk = POSK36;

    /*
	Initialize the Console Into Raw Mode..
	..for Menuing Compatibility under UNIX
    */
    if (!initconsole())
	exit(-1);

#ifdef HIGHC
	save_ds();                      /* save DS for interrupt handler */
#endif

    /*
	Call Serial Init in Case the user want COM2 or a different Baud Rate
    */
    if (!serialinit())
    {
	printf("** ERROR ** could not initialize the serial port\n\r");
	restoreconsole();
	exit(-1);
    }

    while (!exitflag)
    {
	sendmenuhdr(mainmenuhdr);

	/*
	    Clear the Receiver
	*/
	clear_rx();

	/*
	    Send the first screen
	*/
	switch (user_sel = sendmenu(mainmenuptr,25))
	{
	    case ESC_SEL:
		break;

	    case 0:     /* Quit */
		if (askyesno("Are you sure you want to quit") == YES)
		   exitflag = TRUE;
		break;

		 /* Pos/Orientation Output modes */

	    case 1:     /* Position */
	    case 2:     /* Angles */
	    case 3:     /* Matrix */
	    case 4:     /* Quaternions */
	    case 5:     /* Position/Angles */
	    case 6:     /* Position/Matrix */
	    case 7:     /* Position/Quaternions */

		/*
		   Set the Proper Data Mode
		*/
		switch(user_sel)
		{
		    case 1:
			datamode = POS;
			break;

		    case 2:
			datamode = ANGLE;
			break;

		    case 3:
			datamode = MATRIX;
			break;

		    case 4:
			datamode = QUATER;
			break;

		    case 5:
			datamode = POSANGLE;
			break;

		    case 6:
			datamode = POSMATRIX;
			break;

		    case 7:
			datamode = POSQUATER;
			break;
		}

		/*
		    Get the Data from the Bird
		*/
		getbirddata(datamode,buttonmode);
		break;

	    case 8:     /* Angle Align */
		bird_anglealign();
		break;

	    case 9:     /* Hemisphere */
		bird_hemisphere();
		break;

	    case 10:     /* Reference Frame */
		bird_referframe();
		break;

	    case 11 :    /* Report Rate */
		bird_reportrate();
		break;

	    case 12:    /* Sleep/Wakeup */
		bird_sleepwake();
		break;

	    case 13:    /* Mouse Buttons */
		if (!((tempbuttonmode = bird_mousebuttons()) == ESC_SEL))
		    buttonmode = tempbuttonmode;
		break;

	    case 14:   /* XON-XOFF */
		bird_xonxoff();
		break;

	    case 15:   /* Change Value */
		bird_changevalue();
		break;

	    case 16:   /* Examine Value */
		bird_examinevalue();
		break;

	    case 17:   /* CRT Synchronization */
		bird_crtsync();
		break;

	    case 18:   /* Next Master Command */
		nextmastercmd();
		break;

	    case 19:   /* Next Transmitter Command */
		nextxmtrcmd();
		break;

	    case 20:   /* Display List Initialization */
		displistinit();
		break;

	    case 21:   /* RS232 to FBB Pass Through Command */
		rs232tofbbcmd();
		break;

	    case 22:   /* Flock/ER XMTR */
		setxmtrtype();
		break;

	    case 23 :    /* Serial configuration */
		if (!serialinit())
		   return(FALSE);
		break;

	    case 24:   /* System Tests */
		alltests();
		break;
	}
    }

    /*
	Close the Data file if already open
    */
    if (datafilestream)
	fclose(datafilestream);

    /*
	Restore the Serial Configuration
    */
    restoreserialconfig();

    /*
	Restore console Configuration
    */
    restoreconsole();

#ifdef DOS  /* restore IRQ 0 handler */
    pctimer_restore();
#endif

    return(0);
}

/*
    getbirddata         Get Data from the Bird

    Prototype in:       birdmain.h

    Parameters Passed:  short outputmode - POINT, CONTINUOUS, STREAM
			unsigned char datamode - POS, ANGLE, POSANGLE..

    Return Value:       int TRUE if test ends normally
			int FALSE if failure
			int ESC_SEL if user escape

    Remarks:            set up to collect data from the Bird(s)
*/
int getbirddata(datamode,buttonmode)
unsigned char datamode;
short buttonmode;
{
    int retval;
    short outputmode;       /* POINT, CONTINUOUS, STREAM */

    /*
	Get the Outputmode from the user
    */
    if ((outputmode = get_output_mode()) == ESC_SEL)
	return(ESC_SEL);    /* If the user Selects ESC
			       ...skip the command */

    /*
	If NOT in GROUP DATA mode (see change value command)
	AND NOT in RS232 to FBB command mode get the data
	then get the data using the getsinglebirddata,
	else, use the getmultibirddata
    */
    if ((fbbgroupdataflg == FALSE) && (displaymultidataflg == FALSE))
	retval = (getsinglebirddata(outputmode,datamode,ON,buttonmode));
    else
	retval = (getmultibirddata(outputmode,datamode,ON,buttonmode));

    return(retval);
}

/*
    displistinit        Display List Initialization

    Prototype in:       birdmain.h

    Parameters Passed:  none

    Return Value:       TRUE if start/stop address set
			FALSE if not set
			ESC_SEL if the user selects ESCAPE

    Remarks:            setsup the display list Start and Stop Addresses
*/
int displistinit()
{
#ifdef SINGLEBIRDOPER
    int answer;
#endif

    /*
	Ask the user if they want to use Display Data from Multiple Devices
    */
    if (!fbbgroupdataflg)
    {
	printf ("\n\rThe Display List is used for display of data from Multiple 6DFOBs and\n\rhas no effect when the FBB Group Mode is enabled...\n\r");
#ifdef SINGLEBIRDOPER
	if ((answer = askyesno("\n\rDo you want enable display of data from Multiple 6DFOBs")) == ESC_SEL)
	{
	    return (ESC_SEL);
	}
	else
	{
	    /*
		Shut off the Command if the user answer NO
	    */
	    if (answer == FALSE)
	    {
		displaymultidataflg = FALSE;
		return (FALSE);
	    }
	}
#endif
    }
    else
    {
	printf ("\n\rCurrently in FBB Group Mode, therefore, the Display Start\n\rand Stop addresses are determined by AUTO CONFIGURATION\n\r");
	hitkeycontinue();
	return(TRUE);
    }

    /*
	get the addressing mode
    */
    if (getaddrmode() == 0)
	return(FALSE);

    /*
	Get the Destination Addresses
    */
    getfbbdestaddress(&displayliststartaddr,&displayliststopaddr);
    displaymultidataflg = TRUE;
    return(TRUE);

}

/* 
    alltests            All system test functions
    
    Prototype in:       birdmain.c

    Parameters Passed:  void

    Return Value:       TRUE if test ends normally
			FALSE otherwise

    Remarks:            Puts up a Menu for Test Selection
*/
int alltests()
{   
    static char * allsystestptr[] = {"Select Test:",
		  "Return to Main Menu",
		  "System Factory Tests",
		  "Max RS232 To FBB Data Rate",
		  "Noise statistics"};

    short testsel;

    testsel = sendmenu(allsystestptr,4);
    if (testsel < 0 )  return(FALSE);

    switch (testsel) {

       case 0:  /* return to main menu */
		return(TRUE);
       
       case 1:  /* System factory tests */
		systests();
		break;
	    

       case 2:  /* Maximum RS232 to FBB Data Rate */
		getmaxrs232tofbbrate();
		break;


       case 3:   /* Noise statistics */
		getbirdstatistics();
		break;
       }


  return(TRUE);

}

/*
    systests            System Tests

    Prototype in:       birdmain.c

    Parameters Passed:  void

    Return Value:       TRUE if test ends normally
			FALSE otherwise

    Remarks:            Puts up a Menu for Test Selection
*/
int systests()
{
    static char * systestptr[] = {"Select Test:",
		  "Return to Main Menu",
		  "Bird Output Test",
		  "Bird Echo Test",
		  "Host Data Read",
		  "Host Data Read Block"};

    static short systestnum[5] = {0,3,5,7,9};
    short testsel;

    testsel = sendmenu(systestptr,5);
    if (testsel > 0)       /* Return to Main Menu */
    {
	/*
	   Inform the User to Set the DIP switch correctly
	*/
	printf("** NOTE ** The DIP switch should be set to Test Number:  %d\n\r",
	       systestnum[testsel]);
	hitkeycontinue();

	switch(testsel)
	{
	    case 1:             /* Bird Output Test */
		birdoutputtest();
		break;

	    case 2:             /* Bird Echo Test */
		birdechotest();
		break;

	    case 3:             /* Host Data Read Test */
		hostreadtest();
		break;

	    case 4:             /* Host Data Read Block Test */
		hostreadblocktest();
		break;
	}
    }
    return(TRUE);
}

int birdoutputtest()
{
    short i;
    short rxchar;
    unsigned char charbuf[5];

    /*
       Display data read from the Bird until a key is hit
    */
    while (!ckkbhit())
    {
	/*
	    Get the 4 byte response.. first, clear the buffer
	*/
	clear_rx();
	for (i=0; i < 4 ; i++)
	{
	    rxchar = waitforchar();
	    if (rxchar < 0)
	    {
		printf("** ERROR ** could not read data from the Bird\n\r");
		hitkeycontinue();
		return(FALSE);
	    }

	    /*
	       Store the char
	    */
	    charbuf[i] = rxchar;
	}

	/*
	   Display the String to the console..first append the NULL termination
	*/
	charbuf[4] = 0;
	printf("%s",charbuf);
    }
    clearkey();
    return(TRUE);
}


int birdechotest()
{
    short rxchar;
    unsigned char txchar;
    short echochar;

    /*
       Allow the user to type any character and the Bird will echo the
       character ...ESC will end the Echo
    */
    printf("\n\rEnter Character to echo from the keyboard, <ESC> to quit\n\n\r");

    while((echochar = getkey()) != ESC)
    {
	/*
	    Display the character input from the keypad
	*/
	putchar(echochar);

	/*
	   Send the input char to the Bird
	*/
	txchar = echochar;
	send_serial_cmd(&txchar,1);

	/*
	   Get the 1 received character .. hopefully
	*/
	rxchar = waitforchar();
	if (rxchar < 0)
	{
	    printf("** ERROR ** could not read data from the Bird\n\r");
	    hitkeycontinue();
	    return(FALSE);
	}

	/*
	    Display the character
	*/
	putchar(rxchar);
    }

    return(TRUE);
}

int hostreadtest()
{
    short rxchar;

    /*
       Allow the user to type any character and the Bird
       will output numbers 0 - 255 ...ESC will end the Test
    */
    printf("\n\rHit any key for next Output Char, <ESC> to quit\n\n\r");

    clear_rx();
    while((getkey()) != ESC)
    {
	/*
	   Send the char to the Bird
	*/
	send_serial_cmd((unsigned char *)" ",1);

	/*
	   Get the 1 received character .. hopefully
	*/
	rxchar = waitforchar();
	if (rxchar < 0)
	{
	    printf("** ERROR ** could not read data from the Bird\n\r");
	    hitkeycontinue();
	    return(FALSE);
	}

	/*
	    Display the character as a decimal number on the screen
	*/
	printf("Bird Output: %d\n\r", rxchar);
    }

    return(TRUE);
}

int hostreadblocktest()
{
    short i;
    short rxchar[256];

    /*
       Allow the user to type any character and the Bird
       will output numbers 0 - 255 ...ESC will end the Test
    */
    printf("\n\rHit any key for next Output Block, <ESC> to quit\n\n\r");

    clear_rx();
    while((getkey()) != ESC)
    {
	/*
	   Send the char to the Bird
	*/
	send_serial_cmd((unsigned char *)" ",1);

	/*
	   Get the 256 received characters
	*/
	for (i=0; i<256 ; i++)
	{
	    rxchar[i] = waitforchar();
	    if (rxchar[i] < 0)
	    {
		printf("** ERROR ** could not read data from the Bird\n\r");
		hitkeycontinue();
		return(FALSE);
	    }
	}

	/*
	    Display the block as a decimal numbers on the screen
	*/
	printf("\n\n\rBird Output: %d", rxchar[0]);
	for(i=1; i<256; i++)
	    printf(",%d", rxchar[i]);
    }

    return(TRUE);
}

/*
    nextmastercmd       - Next Master Command

    Prototype in:       birdmain.c

    Parameters Passed:  void

    Return Value:       TRUE if command sent OK
			FALSE if command could not be sent
			ESCSEL if the user selected ESC

    Remarks:
*/
int nextmastercmd()
{
    unsigned char rs232cmd;
    int nextmaster;
    char * nextmasterques = "\n\rEnter the NEXT Master address (1 - 14): ";

    printf ("%s",nextmasterques);
    while ((nextmaster = getnumber()) != ESC_SEL)
    {
	if ((nextmaster > 0) && (nextmaster < 15))
	{
	    rs232cmd = (unsigned char) nextmaster + '0';

	    if (send_serial_cmd(&rs232cmd,1) != 1)
	    {
		printf("** ERROR ** could not send the NEXTMASTER command\n\r");
		hitkeycontinue();
		return(FALSE);
	    }
	    else
	    {
		return(TRUE);
	    }
	}
	else
	{
	    printf("** ERROR ** invalid address\n\r");
	    printf ("%s",nextmasterques);
	}
    }
    return(TRUE);
}


/*
    nextxmtrcmd         - Next Transmitter Command

    Prototype in:       birdmain.c

    Parameters Passed:  void

    Return Value:       TRUE if command sent OK
			FALSE if command could not be sent
			ESCSEL if the user selected ESC

    Remarks:
*/
int nextxmtrcmd()
{
    unsigned char rs232cmd[2];
    int nextxmtraddr;
    int nextxmtrnum = 0;
    char * nextxmtrques1 = "\n\rEnter the NEXT TRANSMITTER address (1-14): ";
    char * nextxmtrques2 = "\n\rEnter the NEXT TRANSMITTER number (0-3): ";

    /*
	Get the System Status because we will need to which device
	has a transmitter
    */
    if (!getsystemstatus())
	return(FALSE);

    printf ("%s",nextxmtrques1);
    while ((nextxmtraddr = getnumber()) != ESC_SEL)
    {
	if ((nextxmtraddr > 0) && (nextxmtraddr < 15))
	{
	    if (fbbsystemstatus[nextxmtraddr] & 0x0f)
	    {
		rs232cmd[0] = '0';
		rs232cmd[1] = (unsigned char) nextxmtraddr << 4;
		break;
	    }
	    else
	    {
		printf("** ERROR ** transmitter not available at that address\n\r");
		printf ("%s",nextxmtrques1);
	    }
	}
	else
	{
	    printf("** ERROR ** invalid address\n\r");
	    printf ("%s",nextxmtrques1);
	}
    }

    if (nextxmtraddr == ESC_SEL)
	return(ESC_SEL);

    /*
	Only ask for the transmitter number if the device is an ERC
    */
    if (fbbsystemstatus[nextxmtraddr] & 0x10)
    {
	printf ("%s",nextxmtrques2);
	while ((nextxmtrnum = getnumber()) != ESC_SEL)
	{
	    if ((nextxmtrnum >= 0) && (nextxmtrnum <= 3))
	    {
		if (!(fbbsystemstatus[nextxmtraddr] & (0x1 << nextxmtrnum)))
		{
		    printf("** ERROR ** ERT selection not available at that address\n\r");
		    printf ("%s",nextxmtrques2);
		}
		else
		{
		    /*
			Else the Transmitter number OK so load it
		    */
		    rs232cmd[1] |= (unsigned char) nextxmtrnum;
		    break;
		}
	    }
	    else
	    {
		printf("** ERROR ** invalid xmtr number\n\r");
		printf ("%s",nextxmtrques2);
	    }
	}
    }

    if (nextxmtrnum == ESC_SEL)
	return(ESC_SEL);

    if (send_serial_cmd(rs232cmd,2) != 2)
    {
	printf("** ERROR ** could not send the NEXT XMTR command\n\r");
	hitkeycontinue();
	return(FALSE);
    }

    printf("..NEXT XMTR command sent\n\r");
    hitkeycontinue();
    return(TRUE);
}

/*
    setxmtrtype         SET XMTR TYPE

    Prototype in:       birdmain.c

    Parameters Passed:  void

    Return Value:       ESC_SEL if the user selected ESC

    Remarks:            sets the posk global to POSK36 if Flock is 
			selected or POSK144 if the ER Controller is
			selected
*/
int setxmtrtype()
{
    short xmtrtype;
    static char * xmtrtype_menuptr [] =
		 {"Select Transmitter Type:",
		  "Short Range Transmitter",
		  "Extended Range Transmitter"};

    /*
       Let the user select Transmitter type
    */
    if ((xmtrtype = sendmenu(xmtrtype_menuptr,2)) == ESC_SEL)
    return(ESC_SEL);

    /*
       Setup Scaling for 36" if choice 0
    */
    if (xmtrtype == 0)
       posk = POSK36;

    /*
       Setup Scaling for 144" if choice 1
    */
    if (xmtrtype == 1)
       posk = POSK144;

    return(TRUE);
}

/*
    get_output_mode     -   Get Output Mode

    Prototype in:       birdmain.h

    Parameters Passed:  void

    Return Value:       outputmode = POINT, CONTINUOUS, or STREAM
			if mode is selected or ESC_SEL if ESC is selected

    Remarks:            prompts the user to enter the outputmode from the
			bird.
*/
int get_output_mode()
{
    int mode;
    short menuselects;

    static char * outputmode_menuptr [] =
		   {"Data Output Modes:",
		    "Point Mode",
		    "Continuous Point Mode",
		     "Stream Mode"};

    /*
	Only POINT or Continuous mode when using Multi devices in RS232
	to FBB mode and not in the Group Mode
    */
    menuselects = 3;
    if ((displaymultidataflg) && (!fbbgroupdataflg))
	menuselects = 2;

    /*
	Put up the Menu and get the selection
    */
    if ((mode = sendmenu(outputmode_menuptr,menuselects)) == ESC_SEL)
	return(ESC_SEL);

    /*
	Close the Data file if already open
    */
    if (datafilestream)
	fclose(datafilestream);

    /*
	Ask the User if they want to save data to a File
    */
    if (askyesno("\nDo you want to save the data to an ASCII file"))
    {
	printf("\n\r\n\rCurrent data file name is <%s>\n\r",datafilename);
	if (askyesno("...Do you want to change the file name"))
	{
	    printf("\n\rEnter the Filename: ");
	    scanf("%s",datafilename);
	}

	if ((datafilestream = fopen(datafilename,"wt")) == NULL)
	{
	    printf("** ERROR ** could not open the data file\n\r");
	    hitkeycontinue();
	}
    }

    printf("\n\r");

    return(mode); /* return the value selected */
}


/*

    serialinit          -   Serial Port Initialization

    Prototype in:       birdmain.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessful

    Remarks:            Routine prompts the user for the serial port
			configuration parameters of COM1 or COM2 and
			tries to configure the port via configserialport()
*/
int serialinit()
{
    short menusel;
    static char * serialhdr =
"****************************************************************************\n\r\
* ASCENSION TECHNOLOGY CORPORATION - Serial Port Configuration             *\n\r\
****************************************************************************\n\r\n";

    static char * serialmenu[] =
	      {"Serial Port Options:",
	       "No Change",
	       "115200",
	       "57600",
	       "38400",
	       "19200",
	       "9600",
	       "4800",
	       "2400",
	       "COM1",
	       "COM2"};


    /*
	Clear the Screen and Put up a Header
    */
    CLEARSCREEN;
    sendmenuhdr(serialhdr);

    /*
	Save the Serial configuration, if not already saved
    */
    if (!serialconfigsaved)
    {
	if (!saveserialconfig())
	{
	    printf("** NOTE ** could not save current serial port configuration\n\r\n\r");
	    hitkeycontinue();
	}
	else
	{
	    serialconfigsaved = TRUE;
	}
    }

    /*
	Query the User for the Serial Port configuration
    */
    do
    {
	/*
	    Display Current Configuration
	*/
	printf("\n\rCurrent Serial Port Configuration: \n\r\t %s at %ld Baud\n\r",
	    sys_com_port[comport],baud);

	/*
	    Get menu selection
	*/
	if ((menusel = sendmenu(serialmenu,10)) <= 0)   /* ESC or no change */
	{

	    /*
		Configure the Serial Port Hardware
	    */
	    if (!configserialport())
	    {
		printf("** Error Initializing Serial Port **\n\r");
		hitkeycontinue();
		return(FALSE);
	    }
	    return(TRUE);                       /* all set...go home */
	}

	if (menusel < 8)                        /* if Baud rate change */
	{
	    /*
		Store the New Baud Rate
	    */
	    baud = baudratetable[menusel-1];

	    /*
		Store the New Baud in Bits ..get from the table which
		was created using the sgtty.h OR termio.h system
		include file
	    */
	    if ((baudspeedbits = baudspeedbittable[menusel-1]) == -1)
	    {
	       printf("\n\r** ERROR ** baud rate not supported\n\r");
	       baud = 9600L;   /* setup baud to legal value */
	       hitkeycontinue();
	    }
	}

	/*
	    Must be a Com Port Change
	*/
	if (menusel == 8)                       /* if Com 1 port Change */
	{
	    restoreserialconfig();
	    comport = COM1;                     /* set the new port # */
	    if (!saveserialconfig())
		return(FALSE);
	}

	if (menusel == 9)                       /* if Com 2 port Change */
	{
	    restoreserialconfig();
	    comport = COM2;                     /* set the new port # */
	    if (!saveserialconfig())
		return(FALSE);
	}
    }
    while(TRUE);
}

