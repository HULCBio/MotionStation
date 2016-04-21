/****************************************************************************
*****************************************************************************
    birdcmds        - Bird Command Routines

    written for:    Ascension Technology Corporation
		    PO Box 527
		    Burlington, Vermont  05402
		    802-655-7879

    by:             Jeff Finkelstein
		    802-985-2535


    Modification History:
	  10/18/90  jf - released
	  10/24/90  jf - modified trap for 1.00 in birdanglealign to be 0x7fff
	  11/12/90  jf - add new commands
	  11/29/90  jf - added 'Hit 'B' Key...' to checkdone
			 added the dislay of retrace count to display CRT
			 Pick Display
	  2/4/91    jf - added code to display the button value if enabled
		       - modified change/examine filter strings to reflect
			 Wide/Narrow Notch filters
		       - fixed negative angle bug in bird_referframe
	  2/20/91   jf - added initialization of factory test mode to
			 birdloadconfig
	  3/16/91   jf - added new selection for CRT Sync for Fast Vertical
			 retrace (> 70 Hz)
	  4/25/91   jf - added restoreconsole to exit() condition for UNIX
			 compatibility
	  4/29/91   jf - fixed bug in checkdone(), STREAM mode to assure
			 a TRUE return if a key is hit
	  9/17/91   jf - added new change and examine value commands
			 for the FBB
		    jf - added posk global for POSK36 and POSK72
	  10/18/91  jf - modified max measurement rate to 144 Hz
	  11/1/91   jf - added chg/exm alpha max and glitch checking
	  11/10/91  jf - changed 'glitch checking' to 'sudden output change'
	  11/18/91  jf - changed max CRT sync to 72 Hz
	  1/3/92    jf - fixed bug in shutting off button mode
	  2/25/92   jf - added showfbbconfig from cmdutil.c
	  3/23/92   jf - modified Alpha Min/Max to 7 word tables
	  4/7/92    jf - added data file streaming to all the orientation
			 modes
		    jf - modified operation of chg/exm Error Mask
		    jf - modified measurement rate const to 0.3 for
			 ROMs 3.28 and 4.11
	  4/20/92   mo - added new functions bird_quaternions(),
			 bird_posquaternions() ,fprintquaternions()
			 and printquaternions().
	  6/1/92    jf - updated examine value to reflect new status 
			 definitions
	  6/9/92    jf - removed save config from change and examine value
		    jf - added examine extended error code
	  12/22/92  jf - updated for CPU independence...high byte/low byte
			 order now handled at run time to be compatible
			 with Motorola and RISC CPUs
	  1/26/93   jf - removed individual pos/orient cmds and replaced
			 them with getsinglebirddata
	  2/23/93   jf - added ERC filter values and text strings
	  5/18/94   sw - added Normal/expanded address mode detection
			 for examine birdstatus
	  5/23/94   sw - added XYZ Reference frame change value / examine value 
		       - corrected errors in filter distance labels
	  12/20/94  sw - added routines to run error statistics.
	   5/11/95  sw - removed addressing mode check on examine value, unless
			 command will need that information.                         
	   6/6/95   sw - Placed \r into new printf statements to work with unix systems.

	   <<<< Copyright 1990 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <math.h>           /* trig math funcs */
#include "asctech.h"        /* general definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "menu.h"           /* for menus */
#include "serial.h"         /* serial I/O */
#include "cmdutil.h"        /* command utilities */
#include "birdcmds.h"

/***********************
    Globals
***********************/

/*
    External Varibles
*/
extern FILE * datafilestream;
extern unsigned char displaymultidataflg;

/*
    Position Variable
*/
float posk;
float crystalfreq = DEFAULTCRYSTALFREQ;
float clockvalue = DEFAULTCLOCKVALUE;
short buttonvalue = 0;
unsigned char fbbgroupdataflg = FALSE;
short flocksize = 1;
unsigned char fbbsystemstatus[31];
short numfbbaddrs = 30;
short numfbbrcvrs;
unsigned data_ready_char = ',';

/*
  data returned
*/
short birddata[14];    /* holds the data from the BIRD for buttondata */

/************************
    Routines
************************/

/*
    getsinglebirddata   Get Data from a Single Bird

    Prototype in:       birdcmds.h

    Parameters Passed:  outputmode  - POINT,CONTINUOUS or STREAM
			datamode    - POS, ANGLE, POSANGLE..
			displayon   - 
			buttonmode  - current button mode, 0 if button
				      character is not appended to data,
				      1 if button character is appended

    Return Value:       TRUE if successful
			FALSE otherwise

    Remarks:            Displays current Bird Data in POINT, CONTINUOUS
			or STREAM mode
*/
int getsinglebirddata(outputmode, datamode, displayon, buttonmode)
short outputmode;
unsigned char datamode;
unsigned char displayon;
short buttonmode;
{
    unsigned char datasize;
    unsigned char posorientcmd;

    /*
       Set the for the number of WORDs (16 bits) and the
       Pos/Orientation Mode command
    */
    switch(datamode)
    {
	case POS:
	    datasize = 3;
	    posorientcmd = 'V';
	    break;

	case ANGLE:
	    datasize = 3;
	    posorientcmd = 'W';
	    break;

	case MATRIX:
	    datasize = 9;
	    posorientcmd = 'X';
	    break;

	case QUATER:
	    datasize = 4;
	    posorientcmd = 92;
	    break;

	case POSANGLE:
	    datasize = 6;
	    posorientcmd = 'Y';
	    break;

	case POSMATRIX:
	    datasize = 12;
	    posorientcmd = 'Z';
	    break;

	case POSQUATER:
	    datasize = 7;
	    posorientcmd = ']';
	    break;

	default:
	    printf("\n\r** ERROR ** illegal data mode in getbirddata\n\r");
	    return(FALSE);
    }


    /*
	Send the Mode Command (ie. POS, ANGLES...
    */
    if (send_serial_cmd(&posorientcmd,1) != 1)
	return(FALSE);

    /*
	Send the Stream command if in STREAM mode
    */
    if (outputmode == STREAM)
	if (send_serial_cmd((unsigned char *)"@",1) != 1)
	    return(FALSE);

    /*
	 Send the User a Prompt if in Point mode
    */
    if (outputmode == POINT)
	 printf ("\n\rHit the 'B' Key to read Bird data or any other key to Quit\n\r");

    /*
	Now read the data from the Bird
	storing the data in birddata[]
	check for done condition, keyboard hit while displaying the data
    */

    while (!check_done(outputmode))
    {
	/*
	    Get the data NOW
	*/
	if (!readbirddata(birddata,datasize,outputmode,buttonmode))
	    return(FALSE);

	/*
	    Display and File (if required) the Data Now
	*/
	if (!displaybirddata(birddata, datamode, buttonmode,
			displayon,0,datafilestream))
	    return(FALSE);
    }
    return(TRUE);
}

/*
    bird_anglealign     - Align the Bird User Specified Direction

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE otherwise

    Remarks:            prompts the user for Azimuth, Elevation and Roll of
			the User Direction and sends these values to the Bird
			to reorient the Birds direction
*/
int bird_anglealign()
{

    short i;                /* matrix pointer */
    unsigned char * cdataptr;        /* pointer to cdata */
    float tempfloat;        /* temporary float value */
    float angle[3];         /* angles input byte the user */
    static unsigned char cdata[] =   {'J',0,0,0,0,0,0,0,0,0,0,0,0}; /* cmd + 12 bytes */

    /*
	Get the 3 angles from the User
    */
    if (getangles("\n\rInput Azimuth, Elevation, and Roll angles from receiver\n\rto reference direction in degrees: ",&angle[0]) ==
ESC_SEL)
	return(FALSE);

    /*
	convert sines and cosines to configuration bytes in cdata[],
	constructing the command string as we go.
    */
    cdataptr = &cdata[1];           /* assign pointer to the first character
				       after the command character
				    */
    for (i = 0; i < 3; i++)
    {
	/*
	    calculate the sine of the angle and
	*/
	tempfloat = sin((double)(angle[i] * DTR));

	/*
	    convert to a word and store in cdata
	    NOTE: trap for sin(90)...since the bird
	    can only accept data from -1.000 to 0.99996 (0x8000 to 0x7fff)
	*/
	if (tempfloat < 0.99998)
	{
	    *cdataptr++ = (unsigned char) ((short) (tempfloat * FTW) & 0x0ff);
	    *cdataptr++ = (unsigned char) (((short) (tempfloat * FTW) & 0x0ff00) >> 8);
	}
	else
	{
	    *cdataptr++ = 0x0ff;
	    *cdataptr++ = 0x07f;
	}

	/*
	    calculate the cosine of the angle and
	*/
	tempfloat = cos((double)(angle[i] * DTR));

	/*
	    convert to a word and store in cdata
	    NOTE: trap for cos(0)...since the bird
	    can only accept data from -1.000 to 0.99996 (0x8000 to 0x7fff)
	*/
	if (tempfloat < 0.99998)
	{
	    *cdataptr++ = (unsigned char) ((short) (tempfloat * FTW) & 0x0ff);
	    *cdataptr++ = (unsigned char) (((short) (tempfloat * FTW) & 0x0ff00) >> 8);
	}
	else
	{
	    *cdataptr++ = 0x0ff;
	    *cdataptr++ = 0x07f;
	}
    }

    /*
	Send the Command
    */
    if (send_serial_cmd(cdata,13) != 13)
	return(FALSE);

    printf("Angle Alignment Data sent to the Bird\n\r");
    hitkeycontinue();

    return(TRUE);
}

/*
    bird_hemisphere     -   Set the Birds Hemisphere

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessful
			ESC_SEL if ESC selected

    Remarks:            prompt the user for the Bird hemisphere and send
			down coresponding hemisphere command to the Bird
*/
int bird_hemisphere()
{
    static char * hemisphere_menuptr[] = 
				  {"Hemisphere Options:",  /* menu options */
				   "Forward",
				   "Aft",
				   "Upper",
				   "Lower",
				   "Left",
				   "Right"};
    static unsigned char hemisphere_cdata[] = {'L',0,0};  /* command string 
							     to BIRD */

    /*
	Send the Menu to the User
    */
    switch (sendmenu(hemisphere_menuptr,6))
    {
	/*
	    Setup the Command string to the Bird as a function of the
	    User menu selection.....
	    .....2 data bytes must be set for HEMI_AXIS and HEMI_SIGN
	*/
	case 0: /* Forward */
	    hemisphere_cdata[1] = 0;       /* set XYZ character */
	    hemisphere_cdata[2] = 0;       /* set Sine character */
	    break;

	case 1: /* Aft */
	    hemisphere_cdata[1] = 0;       /* set XYZ character */
	    hemisphere_cdata[2] = 1;       /* set Sine character */
	    break;

	case 2: /* Upper */
	    hemisphere_cdata[1] = 0xc;     /* set XYZ character */
	    hemisphere_cdata[2] = 1;       /* set Sine character */
	    break;

	case 3: /* Lower */
	    hemisphere_cdata[1] = 0xc;     /* set XYZ character */
	    hemisphere_cdata[2] = 0;       /* set Sine character */
	    break;

	case 4: /* Left */
	    hemisphere_cdata[1] = 6;       /* set XYZ character */
	    hemisphere_cdata[2] = 1;       /* set Sine character */
	    break;

	case 5: /* Right */
	    hemisphere_cdata[1] = 6;       /* set XYZ character */
	    hemisphere_cdata[2] = 0;       /* set Sine character */
	    break;

	case ESC_SEL:
	    return(ESC_SEL);
    }
    /*
	Send the Command
    */
    if (send_serial_cmd(hemisphere_cdata,3) != 3)
	return(FALSE);

    printf("Hemisphere Data Sent to the Bird\n\r");
    hitkeycontinue();

    return(TRUE);
}

/*
    bird_referframe -   Define a new Bird Reference Frame

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE otherwise

    Remarks:
*/
int bird_referframe()
{
    static unsigned char referframe_cdata[] =
			{'H',0,0,0,0,0,0,0,0,0,0,0,0};  /* the cmd */
    unsigned char * cdataptr = &referframe_cdata[1];
    short i;
    float tempfloat;
    float angle[3];     /* holds the floating point angles */


    /*
	Get the user to input Azimuth, Elevation, and Roll
    */
    if (getangles("\n\rInput Azimuth, Elevation, and Roll angles\n\rof new reference frame: ",&angle[0]) == ESC_SEL)
	return(FALSE);

    /*
	Convert all angles and store in command string
    */
    for(i=0;i<3;i++)
    {
	/*
	    calculate the sine of the angle and
	*/
	tempfloat = sin((double)(angle[i] * DTR));

	/*
	    convert to a word and store in cdata
	    NOTE: trap for sin(90)...since the bird
	    can only accept data from -1.000 to 0.99996 (0x8000 to 0x7fff)
	*/
	if (tempfloat < 0.99998)
	{
	    *cdataptr++ = (unsigned char) ((short) (tempfloat * FTW) & 0x0ff);
	    *cdataptr++ = (unsigned char) (((short) (tempfloat * FTW) & 0x0ff00) >> 8);
	}
	else
	{
	    *cdataptr++ = 0x0ff;
	    *cdataptr++ = 0x07f;
	}

	/*
	    calculate the cosine of the angle and
	*/
	tempfloat = cos((double)(angle[i] * DTR));

	/*
	    convert to a word and store in cdata
	    NOTE: trap for cos(0)...since the bird
	    can only accept data from -1.000 to 0.99996 (0x8000 to 0x7fff)
	*/
	if (tempfloat < 0.99998)
	{
	    *cdataptr++ = (unsigned char) ((short) (tempfloat * FTW) & 0x0ff);
	    *cdataptr++ = (unsigned char) (((short) (tempfloat * FTW) & 0x0ff00) >> 8);
	}
	else
	{
	    *cdataptr++ = 0x0ff;
	    *cdataptr++ = 0x07f;
	}
    }

    /*
	Send the Command
    */
    if (send_serial_cmd(referframe_cdata,13) != 13)
	return(FALSE);

    printf("Reference Frame Sent to the Bird\n\r");
    hitkeycontinue();

    return(TRUE);
}

/*
    bird_reportrate -   Select the Report Rate for Stream Mode

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessful
			ESC_SEL if user selected ESC

    Remarks:            Queries the User for Bird Report Rate for STREAM
			mode...can be MAX, MAX/2, MAX/8, or MAX/32
*/
int bird_reportrate()
{
    unsigned char rate_cdata;
    static char * reportrate_menuptr[] =
				  {"Select the Report Rate (for STREAM mode):",  /* menu options */
				   "MAX",
				   "MAX/2",
				   "MAX/8",
				   "MAX/32"};
    /*
	Send the Menu to the User
    */
    switch (sendmenu(reportrate_menuptr,4))
    {
	case 0:
	    rate_cdata = 'Q';
	    break;

	case 1:
	    rate_cdata = 'R';
	    break;

	case 2:
	    rate_cdata = 'S';
	    break;

	case 3:
	    rate_cdata = 'T';
	    break;

	case ESC_SEL:
	    return(ESC_SEL);
    }

    /*
	Send of the 1 char
    */
    if (send_serial_cmd(&rate_cdata,1) != 1)
	return(FALSE);

    printf("Report Rate Sent to Bird\n\r");
    hitkeycontinue();

    return(TRUE);
}

/*
    bird_sleepwake  -   Implements the Sleep ('G') or Wake ('F') command

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessfull
			ESC_SEL if user selects ESC

    Remarks:            prompts the user for Sleep or Wake and send the
			corresponding command to the Bird
*/
int bird_sleepwake()
{
    static char * sleepwake_menuptr[] =
				 {"Enter Selection:",
				  "Sleep",
				  "FBB Run/Wake"};

    unsigned char sleepwake_cdata;

    /*
	Get the User selection
    */
    switch (sendmenu(sleepwake_menuptr,2))
    {
	case 0:
	    sleepwake_cdata = 'G';
	    break;

	case 1:
	    sleepwake_cdata = 'F';
	    break;

	case ESC_SEL:
	    return(ESC_SEL);
    }

    /*
	Send the command
    */
    if (send_serial_cmd(&sleepwake_cdata,1) != 1)
	return(FALSE);

    printf("Sent the Sleep/Wake Command to the Bird\n\r");
    return(TRUE);
}

/*
    bird_mousebuttons   -   Implements the M and N mouse button commands

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       0, if buttonmode if off
			1, if buttonmode is on, 'M'
			ESC_SEL, if the user selected ESC_SEL

    Remarks:            sends down the button mode to the Bird and allows
			the user to view the Button state.
*/
int bird_mousebuttons()
{
    static unsigned char button_cdata[] = {'M',0};  /* button command */
    unsigned buttonchar;                /* buffer for button value */
    short buttonmode;
    short tempchar;

    /*
	Ask if they want the Button Commands to aways be sent
    */
    buttonmode = 0;     /* assume button mode off */
    if (askyesno("Do you want the Button Byte added to the End of Data Stream"))
	buttonmode = 1;

    button_cdata[1] = (unsigned char) buttonmode;

    /*
	Send Button Command
    */
    if (send_serial_cmd(button_cdata,2) != 2)   /* send the button cmd */
	return(ESC_SEL);                        /* can't return FALSE */

    /*
	See if the User wants to display the button now
	if in 'N' mode
    */
    if (askyesno("\n\rDisplay Button Value Now "))
    {
	printf("\n\rHit a key to stop printing the button value\n\r");

	while (!ckkbhit())
	{
	    /*
		Send Read Button Command
	    */
	    if (send_serial_cmd((unsigned char *)"N",1) != 1)
	    {
		printf("Could not send Button Read Command\n\r");
		hitkeycontinue();
		return(buttonmode);
	    }

	    /*
		Get button byte
	    */
	    if ((tempchar = waitforchar()) < 0)
	    {
		printf("Could not read button byte\n\r");
		hitkeycontinue();
		return(buttonmode);
	    }

	    buttonchar = tempchar;
	    printf("Button = %d\n\r",buttonchar);
	}
	clearkey();
    }

    return(buttonmode);
}

/*
    bird_xonxoff        - Implements the XON / XOFF commands

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if sent XON or XOFF
			FALSE if could not send the command
			ESC_SEL if the User selected ESC

    Remarks:            sends down the XON or XOFF command to the BIRD
*/
int bird_xonxoff()
{
    unsigned char birdflowcmd;
    static char * xonxoffmenu[] = {"Select Flow Command:",
				   "XON",
				   "XOFF"};
    /*
	Ask the user which they want, XON or XOFF
    */
    switch (sendmenu(xonxoffmenu,2))
    {
	case 0:
	     birdflowcmd = XON;
	     break;

	case 1:
	     birdflowcmd = XOFF;
	     break;

	case ESC_SEL:
	     return(ESC_SEL);
    }

    /*
	Send the command to the Bird
    */
    if (send_serial_cmd(&birdflowcmd,1) != 1)
       return(FALSE);

    printf("Sent the XON/XOFF command to the Bird\n\r");

    hitkeycontinue();

    return(TRUE);
}
/*
    bird_changevalue    - Implements the Change Value Commmand

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if Command was sent to the Bird
			FALSE if could not send the command
			ESC_SEL if the User selected ESC

    Remarks:            Routine queries the user for the PARAMETER to change
			and sends down the new information to the Bird
*/
int bird_changevalue()
{
    short temprs232tofbbaddr;
    short answer;
    short menusel;
    unsigned short i,j;
    short invalid;
    short cmdsize = 0;
    unsigned short * dcfiltervalue;
    char ** dcfiltermsg;
    float floatvalue;
    char floatstring[80];
    static unsigned char birdchangevaluecmd[] = {'P',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    static char * changevaluemenu[] = {"Select Parameter to Change:",
				       "Previous Menu",
				       "Maximum Range Scaling",
				       "Filter ON/OFF Status",
				       "Filter Const - Alpha_Min",
				       "Bird Measurement Rate",
				       "Disable/Enable Data Ready Output",
				       "Change Data Ready Character",
				       "Set ON ERROR Mask",
				       "Filter Const - Vm",
				       "Filter Const - Alpha_Max",
				       "Block/Allow Sudden Output Changes",
				       "XYZ Reference Frame",
				       "Set FBB Host Delay",
				       "Set FBB Configuration",
				       "Set FBB ARMed",
				       "Enable/Disable Group Data Mode",
				       "FBB Auto Config - 1 Trans/N Rec"};

    static char * rangemenu[] = {"Select Scaling Range:",
				 "36 inch range",
				 "72 inch range"};

    static char * errormaskmenu[] = {"Select Error Mask Mode:",
				     "Fatal Errors are Blinked Forever",
				     "Fatal Errors are Blinked Once",
				     "Fatal and Warning Errors are NOT Blinked"};

    static char * configmodemenu[] = {"FBB Configuration Mode:",
				      "Standalone",
				      "1 Transmitter, N Receivers"};

    static char * bird_dcfiltermsg[] = {"0 to 12 inches",
				   "12 to 15 inches",
				   "15 to 19 inches",
				   "19 to 24 inches",
				   "24 to 30 inches",
				   "30 to 38 inches",
				   "38+ inches"};
    static unsigned short bird_dcfiltervalue[] = {2,6,26,99,396,1615,6460};

    static char * erc_dcfiltermsg[] = {"0 to 35 inches",
				   "35 to 49 inches",
				   "49 to 63 inches",
				   "63 to 79 inches",
				   "79 to 96 inches",
				   "96 to 116 inches",
				   "116+ inches"};

    static unsigned short erc_dcfiltervalue[] = {2,2,2,45,90,180,360};

    static unsigned short fbbdevices = 0;

    static unsigned short fbbdependents = 0;

    /*
	Store the rs232tofbbaddr
    */
    temprs232tofbbaddr = rs232tofbbaddr;

    /*
	Initialize the Parameter Bytes
    */
    birdchangevaluecmd[2] = 0;
    birdchangevaluecmd[3] = 0;

    /*
	Setup to use either the 6DFOB parameters or the ERC parameters
    */
    if (posk == POSK144)
    {
       dcfiltervalue = erc_dcfiltervalue;
       dcfiltermsg = erc_dcfiltermsg;
    }
    else
    {
       dcfiltervalue = bird_dcfiltervalue;
       dcfiltermsg = bird_dcfiltermsg;
    }

    /*
	Get the Number of FBB Addrs
    */
    if (getaddrmode() == 0)
	return(FALSE);

    /*
	Send the Menu to the Screen and take appropriate action
    */
    menusel = sendmenu(changevaluemenu,17);
    switch (menusel)
    {
	case ESC_SEL:
	case 0:     /* return */
	     return(ESC_SEL);

	case 1:     /* Range Scale */
	     /*
		 Set the Parameter number and command size
	     */
	     birdchangevaluecmd[1] = 3;
	     cmdsize = 4;

	     /*
		 Now fill the command with the Scale, 0 for 36" or 1 for 72"
	     */
	     switch(sendmenu(rangemenu,2))
	     {
		case 0: /* 36" */
		    birdchangevaluecmd[2] = 0x00;
		    posk = POSK36;
		    break;
		case 1: /* 72" */
		    birdchangevaluecmd[2] = 0x01;
		    posk = POSK72;
		    break;
		case ESC_SEL:
		    return(ESC_SEL);
	     }
	     break;

	case 2:    /* Filter ON/OFF Status */
	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 4;
	     cmdsize = 4;

	     /*
		 Ask the user to 'fill in the bits'...filter ON/OFF selection
	     */
	     if ((answer = askyesno("\n\rDo you want the AC Narrow Notch filter OFF")) == TRUE)
		 birdchangevaluecmd[2] = 4;
	     else if (answer == ESC_SEL)
		 return(ESC_SEL);


	     if ((answer = askyesno("\n\rDo you want the AC Wide Notch OFF")) == TRUE)
		birdchangevaluecmd[2] += 2;
	     else if (answer == ESC_SEL)
		 return(ESC_SEL);

	     if ((answer = askyesno("\n\rDo you want the DC filter OFF")) == TRUE)
		birdchangevaluecmd[2] += 1;
	     else if (answer == ESC_SEL)
		 return(ESC_SEL);

	     break;

	case 3:    /* Filter Constant Table - Alpha Min */
	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 5;
	     cmdsize = 16;         

	     /*
		 Set all 7 table entries
	     */
	     for (i=0; i < 7; i++)
	     {
		 /*
		     Get the Filter Value from the User..with validation
		     0 to 0.99996
		 */
		 do
		 {
		     invalid = FALSE;
		     printf ("For range %s, \n\rInput the New Filter Value (0 to 0.99996): ",
			  dcfiltermsg[i]);
		     if (getfloatstring(floatstring) != NULL)
			 floatvalue = atof(floatstring);
		     else
			 return(ESC_SEL);

		     /*
			 Validate the number
		     */
		     if ((floatvalue < 0.0) || (floatvalue >= 1.00))
		     {
			 invalid = TRUE;
			 printf("** ERROR ** invalid value\n\r");
		     }
		 }
		 while(invalid);

		 /*
		    Convert float to word 0 to 32767 and store in the command
		 */
		 j =  (unsigned)(floatvalue * FTW);
		 *(unsigned char *)&birdchangevaluecmd[2 + (i*2)] =
		    j & 0xff;
		 *(unsigned char *)&birdchangevaluecmd[2 + (i*2) + 1] =
		    ((j & 0xff00) >> 8);

	     }
	     break;

	case 4:    /* Measurement Rate */
	     /*
		Get the CPU crstal freq
	     */
	     if (!getcrystalfreq())
		 return(FALSE);

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 6;
	     cmdsize = 4;

	     printf("**NOTE** do not reduce measurement frequency if the Bird\n\r        is synchronized to the CRT\n\r");

	     /*
		 Get the Measurement frequency from the User
	     */
	     do
	     {
		 printf ("Input the desired measurement frequency (14 to 144 Hz): ");

		 invalid = FALSE;
		 if (getfloatstring(floatstring) != NULL)
		     floatvalue = atof(floatstring);
		 else
		     return(ESC_SEL);
		 /*
		     Validate the number
		 */
		 if ((floatvalue < 14.0) || (floatvalue > 144.0))
		 {
		     invalid = TRUE;
		     printf("** ERROR ** invalid value\n\r");
		 }
	     }
	     while(invalid);

	     /*
		convert to transmitter time counts
	     */
	     i = (unsigned)(((crystalfreq/8.0)*1000.0)*
			  (((1000.0/floatvalue)-0.3)/4.0));

	     *(unsigned char *)&birdchangevaluecmd[2] = (unsigned char) (i & 0xff);
	     *(unsigned char *)&birdchangevaluecmd[3] = (unsigned char) ((i & 0xff00) >> 8);
	     break;

	case 5:    /* Disable/Enable Data Ready Output */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 8;
	     cmdsize = 3;

	     /*
		 Ask the User if they want to Enable the Data Output
		 Character
	     */
	     birdchangevaluecmd[2] = FALSE;
	     if ((answer = askyesno("Do you want Data Ready Output enabled")) == YES)
		  birdchangevaluecmd[2] = TRUE;
	     else if (answer == ESC_SEL)
		  return(ESC_SEL);

	     break;

	case 6:    /* Change Data Ready Character */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 9;
	     cmdsize = 3;

	     /*
		 Ask the User for the Data Ready Character to Send
	     */
	     do
	     {
		 invalid = FALSE;
		 printf("\n\rEnter the desired data ready character in decimal (0-255): ");
		 if (((answer = getnumber()) < 0) || (answer > 255))
		 {
		    invalid = TRUE;
		    printf("\n\r** ERROR ** invalid entry, please try again\n\r");
		    hitkeycontinue();
		 }

		 birdchangevaluecmd[2] = (unsigned char) answer;
		 data_ready_char = (unsigned char) answer;
	     }
	     while (invalid);

	     break;

	case 7:    /* Set ON ERROR Mask */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 11;
	     cmdsize = 3;

	     /*
		 Ask the user the Error Mask Mode
	     */
	     switch(sendmenu(errormaskmenu,3))
	     {
		case 0: /* Fatal Error Blink and Stop system  */
		    birdchangevaluecmd[2] = 0x00;
		    break;
		case 1: /* Fatal Error Blink and system resumes */
		    birdchangevaluecmd[2] = 0x01;
		    break;
		case 2: /* Fatal Error Does NOT Blink and system resumes */
		    birdchangevaluecmd[2] = 0x03;
		    break;
		case ESC_SEL:
		    return(ESC_SEL);
	     }
	     printf("\n\r");
	     break;

	case 8:    /* Set DC Filter Constant Table */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 12;
	     cmdsize = 16;

	     /*
		 Ask the user to enter the DC Filter Table
	     */
	     for (i=0;i<7;i++)
	     {
		 printf("\n\rFor the range %s, current value is %d (decimal)\n\r",
		     dcfiltermsg[i],dcfiltervalue[i]);
		 printf("\n\rEnter the new value for this range, or ESC for no change: ");
		 if ((answer = getnumber()) != ESC_SEL)
		     dcfiltervalue[i] = answer;

		 /*
		     Store the Value in the command string
		 */
		 j = dcfiltervalue[i];
		 *(unsigned char *)&birdchangevaluecmd[2 + (i*2)] =
		     j & 0xff;
		 *(unsigned char *)&birdchangevaluecmd[2 + (i*2) + 1] =
		     ((j & 0xff00) >> 8);

	     }
	     break;

	case 9:    /* Filter Constant Table - Alpha Max */
	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 13;
	     cmdsize = 16;

	     /*
		 Set all 7 table entries
	     */
	     for (i=0; i < 7; i++)
	     {
		 /*
		     Get the Filter Value from the User..with validation
		     0 to 0.99996
		 */
		 do
		 {

		     invalid = FALSE;
		     printf ("For the range %s,\n\rInput the New Filter Value (0 to 0.99996): ",
			      dcfiltermsg[i]);
		     if (getfloatstring(floatstring) != NULL)
			 floatvalue = atof(floatstring);
		     else
			 return(ESC_SEL);

		     /*
			 Validate the number
		     */
		     if ((floatvalue < 0.0) || (floatvalue >= 1.00))
		     {
			 invalid = TRUE;
			 printf("** ERROR ** invalid value\n\r");
		     }
		 }
		 while(invalid);

		 /*
		     Convert float to word 0 to 32767 and store in the command
		 */
		 j = (unsigned)(floatvalue * FTW);
		 *(unsigned char *)&birdchangevaluecmd[2 + (i*2)] =
		     j & 0xff;
		 *(unsigned char *)&birdchangevaluecmd[2 + (i*2) + 1] =
		     ((j & 0xff00) >> 8);
	     }
	     break;

	case 10:    /* Glitch Checking */
	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 14;
	     cmdsize = 3;

	     /*
		 Ask the User if they want to Enable Glitch Checking
	     */
	     birdchangevaluecmd[2] = FALSE;
	     if ((answer = askyesno("Do you want to Block Sudden Output Changes")) == YES)
		  birdchangevaluecmd[2] = TRUE;
	     else if (answer == ESC_SEL)
		  return(ESC_SEL);

	     break;

	case 11:    /* Set XYZ Reference Frame */
	     
	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 17;
	     cmdsize = 3;

	     /* 
		Ask user about value to send
	     */
	     if ((answer = askyesno("Do you want to define Reference Frame")) == YES)
		*(unsigned char *) &birdchangevaluecmd[2] = 1;
	     else
		*(unsigned char *) &birdchangevaluecmd[2] = 0;

	     break;



	case 12:    /* Set FBB Host Delay */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 32;
	     cmdsize = 4;

	     /*
		 Ask the user to enter the FBB Response Delay
	     */
	     printf("\n\rEnter the desired delay in units of microseconds: ");
	     if ((answer = getnumber()) == ESC_SEL)
		 return(ESC_SEL);

	     /*
		 Setup for units of 10 uS
	     */
	     if (answer < 200)
		answer = 20;   /* 200 uS minimum */
	     else
	     {
		if (answer % 10)
		     answer = (answer / 10) + 1;
		else
		     answer = (answer / 10);
	     }
	     *(unsigned char *) &birdchangevaluecmd[2] = answer & 0xff;
	     *(unsigned char *) &birdchangevaluecmd[3] = ((answer & 0xff00) >> 8);

	     break;

	case 13:    /* Set FBB Configuration */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 33;
	     cmdsize = 7;

	     /*
		 Ask the user for the Configuration Mode
	     */
	     switch(sendmenu(configmodemenu,2))
	     {
		 case 0: /* standalone */
		    birdchangevaluecmd[2] = 0x00;
		    break;

		 case 1: /* one trans/ n rec */
		    birdchangevaluecmd[2] = 0x01;
		    break;

		 case ESC_SEL:
		    return(ESC_SEL);
	     }

	     /*
		 Ask the user for the FBB Device Numbers
	     */
	     do
	     {
		 printf("\n\rFBB Devices..");

		 for (i=1;i<=14;i++)
		 {
		     printf("\n\rDevice at FBB address %d is ", i);
		     if ((0x1 << i) & fbbdevices)
			printf("ACTIVE");
		     else
			printf("NOT ACTIVE");
		 }
		 printf("\n\n\rEnter the FBB address to change, 0 if complete: ");
		 if ((answer = getnumber()) == ESC_SEL)
		     return(ESC_SEL);
		 else if (answer != 0)
		     fbbdevices ^= (0x1 << answer);  /* flip the bit state */
	     }
	     while (answer != 0);

	     *(unsigned char *) &birdchangevaluecmd[3] = fbbdevices & 0xff;
	     *(unsigned char *) &birdchangevaluecmd[4] = ((fbbdevices & 0xff00) >> 8);

	     /*
		 Ask the user for the FBB Dependents
	     */
	     do
	     {
		 printf("\n\rFBB Dependents..");

		 for (i=1;i<=14;i++)
		 {
		     /*
			 Only Active devices can be dependentsc
		     */
		     if ((0x1 << i) & fbbdevices)
		     {
			 printf("\n\rDevice at FBB address %d is ", i);
			 if ((0x1 << i) & fbbdependents)
			    printf("DEPENDENT");
			 else
			    printf("NOT DEPENDENT");
		     }
		 }
		 printf("\n\n\rEnter the FBB address to change, 0 if complete: ");
		 if ((answer = getnumber()) == ESC_SEL)
		     return(ESC_SEL);
		 else
		 {
		     if (((0x1 << answer) & fbbdevices) && (answer != 0))
			 fbbdependents ^= (0x1 << answer);  /* flip the bit state */
		     else  /* device is not active */
			 printf("\n\rDevice at FBB address %d is NOT ACTIVE\n\r", answer);
		 }
	     }
	     while (answer != 0);

	     *(unsigned char *) &birdchangevaluecmd[5] = fbbdependents & 0xff;
	     *(unsigned char *) &birdchangevaluecmd[6] = ((fbbdependents & 0xff00) >> 8);

	     break;

	case 14:   /* Set FBB ARMed */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 34;
	     cmdsize = 3;

	     /*
		 Ask the user if they want to ARM the Bird
	     */
	     if ((answer = askyesno("Do you want to ARM the Bird")) == YES)
		 birdchangevaluecmd[2] = TRUE;
	     else if (answer == ESC_SEL)
		 return(ESC_SEL);

	     break;

	case 15:   /* Enable/Disable Group Mode */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 35;
	     cmdsize = 3;

	     /*
		 This command will only go to the device the computer
		 is connected to
	     */
	     rs232tofbbaddr = 0;

	     /*
		 Indicate that we are in the Group Mode
	     */
	     fbbgroupdataflg = FALSE;

	     /*
		 Ask the user if they want to Save the Configuration
	     */
	     if ((answer = askyesno("Do you want to Enable the Group Data Mode")) == YES)
	     {
		 birdchangevaluecmd[2] = TRUE;
		 fbbgroupdataflg = TRUE;
	     }
	     else if (answer == ESC_SEL)
	     {
		 rs232tofbbaddr = temprs232tofbbaddr;
		 return(ESC_SEL);
	     }

	     break;


	case 16:   /* FBB Auto Configuration - 1 Trans/N Rec */

	     /*
		 Set the Parameter number and the command size
	     */
	     birdchangevaluecmd[1] = 50;
	     cmdsize = 3;

	     /*
		 Preset the RS232 to Destination address to 1 for
		 this command if the RS232 to FBB command is active
	     */
	     if (rs232tofbbaddr != 0)
		 rs232tofbbaddr = 1;

	     /*
		 Ask the user to enter the number of receivers
	     */
	     printf("\
NOTE:  This Auto Configuration mode assumes that Bird 1 will be a\n\r\
       Master and Birds 2 through N will be Slaves");
	     do
	     {
		 invalid = FALSE;
		 printf ("\n\rEnter the number of Bird Units in the Flock: ");
		 if ((answer = getnumber()) == ESC_SEL)
		     return(ESC_SEL);
		 if ((answer < 1) || (answer > numfbbaddrs))
		 {
		     invalid = TRUE;
		     printf("\n\r** ERROR ** invalid entry, try again\n\r");
		     hitkeycontinue();
		 }
	     }
	     while(invalid);

	     birdchangevaluecmd[2] = (unsigned char) answer;

	     /*
		 Store the number of Units in the Flock
		 ...for use by other routines
	     */
	     flocksize = answer;
	     displaymultidataflg = TRUE;
	     break;
    }

    /*
	Send the Command to the Bird
    */
    if (send_serial_cmd(birdchangevaluecmd,cmdsize) != cmdsize)
    {
	rs232tofbbaddr = temprs232tofbbaddr;
	return(FALSE);
    }

    /*
	Restore the rs232tofbbaddr
    */
    rs232tofbbaddr = temprs232tofbbaddr;


    printf("\n\rNew Value(s) sent to the Bird\n\r");
    hitkeycontinue();

    /*
	If the Command was the Autoconfiguration...than
	get the current system status
    */
    if (menusel == 16)
    {
	if (getsystemstatus())
	{
	    displayflocksys(&fbbsystemstatus[1]);
	}
	else
	    return(FALSE);

    }

    return(TRUE);
}

/*
    bird_examinevalue    - Implements the Examine Value Commmand

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if Command was sent to the Bird
			FALSE if could not send the command
			ESC_SEL if the User selected ESC

    Remarks:
*/
int bird_examinevalue()
{
    unsigned short i;
    short rxchar;
    short answer;
    char ** dcfiltermsg;
    static unsigned char birdexaminevaluecmd[] = {'O',0};
    unsigned char parameter[30];         /* room for a 30 byte response */
    float measurementrate;
    static char * examinevaluemenu[] = {"Select Parameter to Examine:",
					"Previous Menu",
					"Bird System Status",
					"Software Revision",
					"Bird CPU Crystal Frequency",
					"Maximum Range Scaling",
					"Filter ON/OFF Status",
					"Filter Const - Alpha_Min",
					"Bird Measurement Rate",
					"Data Ready Output",
					"Data Ready Character",
					"Error Code",
					"ON ERROR Mask",
					"Filter Const - Vm",
					"Filter Const - Alpha_Max",
					"Sudden Output Changes",
					"Model",
					"Expanded Error Code",
					"XYZ Reference Frame",
					"FBB Host Delay",
					"FBB Configuration",
					"FBB ARMed",
					"Group Data Mode",
					"Flock System Status",
					"FBB Auto Config - 1 Trans/N Rec"};
    /*
	Parameternumbers for menu items
    */
    static unsigned short examinevalueparanumber[] =
	   {0,0,1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,32,33,34,35,36,50};

    /*
	Number of characters in the response for each menu item
    */
    static unsigned short examinevaluerspsize[] =
	   {0,2,2,2,2,2,14,2,1,1,1,1,14,14,1,10,2,1,2,5,14,1,14,5};

    static char * bird_dcfiltermsg[] = {"0 to 12 inches",
				   "12 to 15 inches",
				   "15 to 19 inches",
				   "19 to 24 inches",
				   "24 to 30 inches",
				   "30 to 38 inches",
				   "38+ inches"};

    static char * erc_dcfiltermsg[] = {"0 to 35 inches",
				   "35 to 49 inches",
				   "49 to 63 inches",
				   "63 to 79 inches",
				   "79 to 96 inches",
				   "96 to 116 inches",
				   "116+ inches"};

    /*
	Set up for ERC or 6DFOB
    */
    if (posk == POSK144)
	dcfiltermsg = erc_dcfiltermsg;
    else
	dcfiltermsg = bird_dcfiltermsg;

    /*
	Find out which Value the User wants to look at and take
	appropriate action
    */
    if ((answer = sendmenu(examinevaluemenu,24)) > 0)
    {
	/* 
		Check the command and only inquire about address mode
		when the user request a function that needs the information
	*/

	if ( answer==19 || answer==20 || answer==22 || answer==23 ) {
	   /*
		 Get the Number of FBB Addrs
	   */
	   if (getaddrmode() == 0)
		return(FALSE);

	   /*
		Update the Response size for the FBB CONFIG, FBB ARM
		FBB AUTOCONFIG and the FBB SYSTEM STATUS
	   */
	   if (numfbbaddrs == 14) {
		examinevaluerspsize[19] = 5;
		examinevaluerspsize[20] = 14;
		examinevaluerspsize[22] = 14;
		examinevaluerspsize[23] = 5;
	   } else {
		examinevaluerspsize[19] = 7;
		examinevaluerspsize[20] = 30;
		examinevaluerspsize[22] = 30;
		examinevaluerspsize[23] = 7;  
	   }
	}


	/*
	    Store the command parameter number
	*/
	birdexaminevaluecmd[1] = (unsigned char) examinevalueparanumber[answer];

	/*
	    Send the command to the Bird
	*/
	if (send_serial_cmd(birdexaminevaluecmd,2) !=2)
	    return(FALSE);

	/*
	    Get the n byte response
	*/
	for (i=0; i< examinevaluerspsize[answer] ; i++)
	{
	    rxchar = waitforchar();
	    parameter[i] = (unsigned char) rxchar;
	    if (rxchar < 0)
	    {
		printf("** ERROR ** could not read data back from the Bird\n\r");
		hitkeycontinue();
		return(FALSE);
	    }
	}

	/*
	    Decode the information retrieved
	*/
	switch (answer)
	{
	    case 1:     /* System Status */
		/* 
		    check Master/Slave bird .. bit 15
		*/
		if ( ((unsigned char) parameter[1]) & 0x80 )
		    printf("Bird is Master\n\r");
		else
		    printf("Bird is Slave\n\r");

		/* 
		    check bird initialization status .. bit 14
		*/
		if ( ((unsigned char) parameter[1]) & 0x40 )
		    printf("Bird has been initialized\n\r");
		else
		    printf("Bird has not been initialized\n\r");

		/* 
		    check if an error has been detected .. bit 13
		*/
		if ( ((unsigned char) parameter[1]) & 0x20 )
		    printf("An error has been detected\n\r");
		else
		    printf("No error detected\n\r");

		
		/* 
		    check if bird is NOT RUNNING / RUNNING .. bit 12
		*/
		if ( ((unsigned char) parameter[1]) & 0x10 )
		    printf("Bird is NOT RUNNING\n\r");
		else
		    printf("Bird is RUNNING\n\r");

		/* 
		    check if bird is in HOST SYNC .. bit 11
		*/
		if ( ((unsigned char) parameter[1]) & 0x08 )
		    printf("Bird is in HOST SYNC\n\r");
		else
		    printf("Bird is not in HOST SYNC\n\r");


		/*
		    Print Expanded Addressing or Expanded .. bit 10
		*/
		if ( ((unsigned char) parameter[1]) & 0x04 )
		    printf("Bird in Expanded Addressing Mode\n\r");
		else
		    printf("Bird in Normal Addressing Mode\n\r");

		
		/*
		    check if in CRTSYNC mode .. bit 9
		*/
		if ( ((unsigned char) parameter[1]) & 0x02 )
		    printf("Bird in CRTSYNC Mode\n\r");
		else
		    printf("Bird not in CRTSYNC Mode\n\r");


		/*
		    check if sync modes enabled .. bit 8
		*/
		if ( ((unsigned char) parameter[1]) & 0x01 )
		    printf("SYNC mode not enabled\n\r");
		else
		    printf("SYNC mode enabled\n\r");

		
		/*
		    check factory test mode ..bit 7
		*/
		printf ("Factory Test Commands: ");
		if (((unsigned char) parameter[0]) & 0x80)
		    printf("ENABLED\n\r");
		else
		    printf("DISABLED\n\r");
		
		
		/*
		    check XOFF/XON ..bit 6 
		*/
		if (((unsigned char) parameter[0]) & 0x80)
		    printf("XOFF\n\r");
		else
		    printf("XON\n\r");
		

		/*
		    check sleep/wake ..bit 5
		*/
		if (((unsigned char) parameter[0]) & 0x20)
		    printf("Bird in Sleep Mode\n\r");
		else
		    printf("Bird in Wake Up Mode\n\r");

		/*
		    check output selection ..bits 4,3,2,1
		*/
		switch (((unsigned char) parameter[0] & 0x1e) >> 1)
		{
		    case 1:
			printf ("Position output selected ");
			break;
		    case 2:
			printf ("Angle output selected ");
			break;
		    case 3:
			printf ("Matrix output selected ");
			break;
		    case 4:
			printf ("Position/Angle output selected ");
			break;
		    case 5:
			printf ("Position/Matrix output selected ");
			break;
		    case 6:
			printf ("Factory Test output selected ");
			break;
		    case 7:
			printf ("Quaternion output selected ");
			break;
		    case 8:
			printf ("Position/Quaternion output selected ");
			break;

		    default:
			printf ("Illegal Output mode detected\n\r");
			hitkeycontinue();
			return(FALSE);
		}

		/*
		    check outputmode .. bit 0
		*/
		if (((unsigned char) parameter[0]) & 0x1)
		    printf("in STREAM mode\n\r");
		else
		    printf("in POINT mode\n\r");

		break;

	    case 2:     /* Software Rev */
		printf ("Software REV %d.%d\n\r",parameter[0],parameter[1]);
		break;

	    case 3:     /* CPU Crystal */
		/*
		    Store the Value in the Global
		*/
		crystalfreq = parameter[0];
		printf ("CPU Crystal is %4.1f MHz\n\r",crystalfreq);
		break;

	    case 4:     /* Maximum Range */
		printf ("Maximum Range is ");
		if (parameter[0] == 1)
		    printf ("72 inches\n\r");
		else
		    printf ("36 inches\n\r");
		break;

	    case 5:     /* Filter Status */
		printf ("AC Narrow Notch filter is: ");
		if (parameter[0] & 4)
		    printf ("OFF\n\r");
		else
		    printf ("ON\n\r");

		printf ("AC Wide Notch filter is: ");
		if (parameter[0] & 2)
		    printf ("OFF\n\r");
		else
		    printf ("ON\n\r");

		printf ("DC filter is: ");
		if (parameter[0] & 1)
		    printf ("OFF\n\r");
		else
		    printf ("ON\n\r");

		break;

	    case 6:     /* Filter Constant Table - Alpha Min */
		for (i=0; i<7; i++)
		{
		    printf ("For the range %s, Filter constant is %6.4f\n\r",
			    dcfiltermsg[i],
			    (float)(((*(unsigned char *)&parameter[(i*2)]) +
				    ((*(unsigned char *)&parameter[(i*2+1)]) << 8))
				     * WTF));
		}
		break;

	    case 7:     /* Measurement Rate */
		/*
		     Display the Rate
		*/
		if (!getcrystalfreq())
		     return(FALSE);
		i = ((*(unsigned char *)&parameter[0]) & 0xff)
		    + (((*(unsigned char *)&parameter[1]) & 0xff) << 8) ;

		measurementrate =
		    1000.0/((4*(i*(8.0/crystalfreq)/1000.0))+ 0.3);
		printf ("Measurement Rate: %6.2f\n\r",measurementrate);

		/*
		     Display the Transmitter Counts
		*/
		printf("Transmitter Time Counts: %u\n\r",i);
		break;

	    case 8:     /* Disable/Enable Data Ready Output */

		printf ("\n\rData Ready Output is ");
		if (parameter[0] == TRUE)
		    printf("ENABLED");
		else
		    printf("DISABLED");
		break;

	    case 9:     /* Change Data Ready Character */
		printf ("\n\rData Ready Output Character is %u (decimal), <%c> (ASCII)",(unsigned char) parameter[0],(char) parameter[0]);
		break;

	    case 10:     /* Error Code */
		displayerror(parameter[0],parameter[1],FALSE);
		break;

	    case 11:    /* ON ERROR Mask */
		switch(parameter[0] & 0x3)
		{
		    case 0:   /* FATAL errors are Blinked Forever */
			printf ("\n\rFATAL Errors are Blinked Forever and Operation is Halted\n\r");
			break;
		    case 1:   /* FATAL errors are Blinked Once */
			printf ("\n\rFATAL Errors are Blinked Once and Operation is Resumed \n\r");
			break;
		    case 2:   /* FATAL errors are Not Blinked  */
			printf ("\n\rFATAL Errors are Not Blinked and Operation is Halted\n\r");
			break;
		    case 3:   /* FATAL errors are Not Blinked Forever */
			printf ("\n\rFATAL Errors are Not Blinked and Operation Continues\n\r");
			break;
		}
		break;

	    case 12:    /* DC Filter Constant Table */

		/*
		    Display the DC Filter Table
		*/
		for (i=0;i<7;i++)
		{
		    printf ("\n\rFor the range %s, current value is %u (decimal)\n\r",
			    dcfiltermsg[i],
				    (unsigned short)((*(unsigned char *)&parameter[i*2]) +
				    ((*(unsigned char *)&parameter[i*2+1]) << 8)));

		}
		break;

	    case 13:    /* Filter Constant Table - Alpha Max */
		for (i=0; i<7; i++)
		{
		    printf ("For the range %s, Filter constant is %6.4f\n\r",
			    dcfiltermsg[i],
			    (float)(((*(unsigned char *)&parameter[i*2]) +
				    ((*(unsigned char *)&parameter[i*2+1]) << 8))
				     * WTF));
		}
		break;

	    case 14:    /* Glitch Checking */
		if (parameter[0] == TRUE)
		    printf("Sudden Changes are not output");
		else
		    printf("Sudden Changes are output");
		break;

	    case 15:    /* Model */
		parameter[10] = 0; /* set the string termination */
		printf ("\n\rModel is: %s",&parameter[0]);
		break;

	    case 16:     /* Expanded Error Code */
		displayerror(parameter[0],parameter[1],TRUE);
		break;

	    case 17:    /* XYZ Reference Frame */
		if (parameter[0] == TRUE)
		    printf("XYZ Reference Frame defined");
		else
		    printf("XYZ Reference Frame Not defined");
		break;

	    case 18:    /* FBB Host Delay */
		printf("\n\rFBB Host Response Delay is %d microseconds",
				(unsigned short)(((*(unsigned char *) &parameter[0]) +
				((*(unsigned char *) &parameter[1]) << 8))) * 10);
		break;

	    case 19:    /* FBB Configuration */
		showfbbconfig(&parameter[0]);
		break;

	    case 20:    /* FBB ARMed */
	    case 22:    /* Flock System Config */
		displayflocksys(&parameter[0]);
		break;

	    case 21:    /* Group Data Mode */

		if (parameter[0] == TRUE)
		    printf("\n\rGroup Data Mode is Enabled");
		else
		    printf("\n\rGroup Data Mode is Disabled");
		break;

	    case 23:    /* FBB Auto Configuration - 1 Trans/N Rec */
		showfbbconfig(&parameter[0]);
		break;
	}

	hitkeycontinue();
	return(TRUE);
    }
    else
    {
	return(ESC_SEL);
    }
}

void displayflocksys(parameter)
unsigned char * parameter;
{
    int i;

    /*
       Display the Configuration for each Address
    */
    printf("\n\rFlock Configuration...");
    for (i=0;i<numfbbaddrs;i++)
    {
	/*
	   Allow the User to View the Data on a 25 line Screen
	*/
	if (i == 20)
	   hitkeycontinue();

	printf("\n\rFBB ADDR %d: ",i+1);

	if (parameter[i] & 0x80)
	{
	    if (parameter[i] & 0x10)
		printf("ERC, ");
	    else
		printf("6DFOB, ");
	}
	else
	{
	    printf("NOT ACCESSIBLE");
	    continue;
	}

	if (parameter[i] & 0x40)
	    printf("RUNNING, ");
	else
	    printf("NOT RUNNING, ");

	if ((parameter[i] & 0x30) == 0x20)
	    printf("RCVR");
	if ((parameter[i] & 0x30) == 0x00)
	    printf("NO RCVR");

	if ((parameter[i] & 0x11) == 0x01)
	    printf(", XMTR ");
	else
	{
	   if ((parameter[i] & 0x10) == 0x00)
	       printf(", NO XMTR");
	}

	if ((parameter[i] & 0x11) == 0x11)
	    printf(" ERT 0");

	if ((parameter[i] & 0x12) == 0x12)
	    printf(" ERT 1");

	if ((parameter[i] & 0x14) == 0x14)
	    printf(" ERT 2");

	if ((parameter[i] & 0x18) == 0x18)
	    printf(" ERT 3");

	if ((parameter[i] & 0x1f) == 0x10)
	    printf(" NO ERTs");
    }
    
    hitkeycontinue();

    return;
}


/*
    bird_crtsync        - Implements the CRT SYNC command

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       TRUE if a command was executed
			FALSE if command could not be executed
			ESC_SEL if the user selected escape

    Remarks:
*/
int bird_crtsync()
{
    short i;
    short rxchar;
    static unsigned char birdcrtsynccmd[] = {'A',0};
    unsigned char parameter[4];
    static char * crtsyncmenu[] = {"Select CRT sync mode:",
				   "CRT Sync Off",
				   "CRT Sync - CRT Vertical Retrace Greater than 72 Hz",
				   "CRT Sync - CRT Vertical Retrace Less than 72 Hz",
				   "Display CRT Pickup Info"};
    /*
	Find out what the user wants to do ...
    */
    switch (sendmenu(crtsyncmenu,4))
    {
	case 0:     /* CRT sync OFF */
	    /*
		Set the Sync Type
	    */
	    birdcrtsynccmd[1] = 0;

	    /*
		Send the Command
	    */
	    if (send_serial_cmd(birdcrtsynccmd,2) != 2)
		return(FALSE);

	    printf("CRT sync OFF command sent to the Bird\n\r");

	    break;

	case 1:     /* CRT sync - > 72 Hz */
	    /*
		Set the Sync Type
	    */
	    birdcrtsynccmd[1] = 1;

	    /*
		Send the Command
	    */
	    if (send_serial_cmd(birdcrtsynccmd,2) != 2)
		return(FALSE);

	    printf("CRT sync '1' command sent to the Bird\n\r");

	    break;

	case 2:     /* CRT sync - < 72 Hz */
	    /*
		Set the Sync Type
	    */
	    birdcrtsynccmd[1] = 2;

	    /*
		Send the Command
	    */
	    if (send_serial_cmd(birdcrtsynccmd,2) != 2)
		return(FALSE);

	    printf("CRT sync '2' command sent to the Bird\n\r");

	    break;

	case 3:     /* Display Pickup Values*/
	    /*
		Get the Crystal Frequency
	    */
	    if (!getcrystalfreq())
		return(FALSE);

	    /*
		Set the Sync Type
	    */
	    birdcrtsynccmd[1] = 255;

	    /*
		Stay in a Loop displaying the Pickup Values
	    */
	    do
	    {
		if (send_serial_cmd(birdcrtsynccmd,2) != 2)
		    return(FALSE);

		/*
		    Get the 4 byte response response
		*/
		for (i=0; i<4; i++)
		{
		    rxchar = waitforchar();
		    parameter[i] = rxchar;
		    if (rxchar < 0)
		    {
			printf("** ERROR ** could not read data back from the Bird\n\r");
			hitkeycontinue();
			return(FALSE);
		    }
		}
		/*
		    Display the Retrace Voltage
		*/
		i = *(unsigned char *) &parameter[0] +
		    ((*(unsigned char *) &parameter[1]) << 8);

		printf ("%6.4f  ", (float)((float)i * 5.0/32768.0));

		/*
		    Compute the Retrace Rate if the count is not = 0
		    ...then display
		*/
		i = *(unsigned char *)&parameter[2] +
		    ((*(unsigned char *)&parameter[3]) << 8);
		if (i != 0)
		     printf ("      %6.2f\n\r",
			  (float)((125000.0 * crystalfreq)/(unsigned short)i)/2);
		else
		     printf ("       00.00\n\r");
	    }
	    while (!ckkbhit());   /* Stay in the loop until a key is hit */
	    clearkey();           /* clear the keyboard */

	    /*
		    Set the Sync Type to OFF
	    */
	    birdcrtsynccmd[1] = 0;

	    /*
		Send the Command
	    */
	    if (send_serial_cmd(birdcrtsynccmd,2) != 2)
		return(FALSE);

	    break;

	    case ESC_SEL:
		return(ESC_SEL);
    }
    hitkeycontinue();
    return(TRUE);
}

/*
    showfbbconfig       Display the FBB Configuration

    Prototype in:       cmdutil.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            Displays the FBB Configuration information pointed
			to by fbbconfig

*/
void showfbbconfig(fbbconfig)
unsigned char * fbbconfig;
{
    short i;
    short j;
    short active;

    switch (fbbconfig[0])
    {
	case 0:
	    printf("\n\rFBB Bird configured for Stand Alone Operation\n\r");
	    break;
	case 1:
	    printf("\n\rFBB Bird configured for 1 Transmitter/N Receiver Operation\n\r");
	    break;
	default:
	    printf("** ERROR ** invalid FBB Configuration Mode\n\r");
    }
    hitkeycontinue();

    printf("\n\rFBB Devices..");
    for (i=1;i<=numfbbaddrs;i++)
    {
	printf("\n\rDevice at FBB address %d is ", i);
	if (i < 15)
	{
	    j = *(unsigned char *)&fbbconfig[1] +
		((*(unsigned char *)&fbbconfig[2]) << 8);
	    active = ((0x1 << i) & j);
	}
	else
	{
	    j = *(unsigned char *)&fbbconfig[5] +
		((*(unsigned char *)&fbbconfig[6]) << 8);
	    active = ((0x1 << i-15) & j);
	}

	if (active)
	   printf("RUNNING");
	else
	   printf("NOT RUNNING");

	if (i == 20)    /* Don't let the info run off the screen */
	   hitkeycontinue();

    }
    hitkeycontinue();

    printf("\n\rFBB Dependents..");
    for (i=1;i<=14;i++)
    {
	printf("\n\rDevice at FBB address %d is ", i);
	j = *(unsigned char *)&fbbconfig[3] +
	    ((*(unsigned char *)&fbbconfig[4]) <<8);
	if ((0x1 << i) & j)
	   printf("DEPENDENT");
	else
	   printf("NOT DEPENDENT");
    }
}



		    /* return number of samples taken*/

int getsamples(samplesize,mean,stddev,pk_pk,maximum,minimum)
int samplesize; 
double mean[]; 
double stddev[];
double pk_pk[];
double maximum[];
double minimum[];
{
 short i;
 int index;
 unsigned char temprs232tofbbaddr;
 short birddata[14]; 
 unsigned char posorientcmd;
 unsigned char datasize;
 int wfc;
 double floatdata[6], sx[6], sx2[6];
 short outputmode = CONTINUOUS;
 short buttonmode = 0;
 short cmdsize=0;
 static unsigned char birdchangevaluecmd[] = {'P',0,0,0,0,0};  

 /* make sure not in FBB group mode - add later */
 /* no button mode */
 
 /* initualize mean[] and stddev[] */
 for (index=0; index<6; index++) {
   mean[index]=0; stddev[index]=0; 
   sx[index]=0; sx2[index]=0;
   maximum[index]=-9999; minimum[index]=9999;
 }

 /* 
	send the mode Command (ie. POSANGLES)
 */
 posorientcmd = 'Y';
 datasize = 6;
 if (send_serial_cmd(&posorientcmd,1) != 1) return(0);
  
 /*
	enable data ready char, only to master
 */
 temprs232tofbbaddr = rs232tofbbaddr;
 rs232tofbbaddr = 0; /* to master */
 birdchangevaluecmd[1] = 8;
 birdchangevaluecmd[2] = 1;
 cmdsize = 3;
 if (send_serial_cmd(birdchangevaluecmd,cmdsize) != cmdsize) {
	       printf("\n\r * problem sending data ready char enable *");
	       rs232tofbbaddr = temprs232tofbbaddr;
	       return(0);
 }
 rs232tofbbaddr = temprs232tofbbaddr;

 /*
    wait 5 cycles for filters to settle
 */
 for (index=0; index<5; index++) 
   do  /* wait for data ready char from master */
     wfc = waitforchar(); 
   while ( wfc != data_ready_char );


 for (index=0; index<samplesize; index++) 
 {
   printf("\r %3d ",index+1);

   /* 
      wait for data ready char from master before taking record from bird
   */

   do  
     wfc = waitforchar(); /* timed out at low measurement speed (14-16 Hz) */
   while ( wfc != data_ready_char );

   /*
	request a new point from bird
   */
   if (send_serial_cmd((unsigned char *)"B",1) != 1) /* get another set of points */
   {
       /*
	    disable data ready char from master, error exit
       */
       birdchangevaluecmd[1] = 8;
       birdchangevaluecmd[2] = 0;
       cmdsize = 3;
       if (send_serial_cmd(birdchangevaluecmd,cmdsize) != cmdsize) 
	       printf("\n\r * problem sending data ready char disable *");
       return(0);           /* return done if errors */
   }
  
  /*
	get the data NOW
  */
  if (!readbirddata(birddata,datasize,outputmode,buttonmode)) {
       /*
	    disable data ready char, error exit
       */
       temprs232tofbbaddr = rs232tofbbaddr;
       rs232tofbbaddr = 0; /* to master */
       birdchangevaluecmd[1] = 8;
       birdchangevaluecmd[2] = 0;
       cmdsize = 3;
       if (send_serial_cmd(birdchangevaluecmd,cmdsize) != cmdsize) 
	       printf("\n\r * problem sending data ready char disable *");
       rs232tofbbaddr = temprs232tofbbaddr;
       return(0);           /* return done if errors */
   }
  
  for (i=0;i<6;i++) {
     if (i<3) floatdata[i] = (double)(birddata[i] * posk);
     else     floatdata[i] = (double)(birddata[i] * ANGK);
     sx[i]+=floatdata[i];
     sx2[i]+= (floatdata[i]*floatdata[i]);
     if (floatdata[i]<minimum[i]) minimum[i]=floatdata[i];
     if (floatdata[i]>maximum[i]) maximum[i]=floatdata[i];
  }

 } 
 
 /* finish calculating the mean and Stddev */
 for (index=0; index<6; index++) {
  double temp;
    mean[index] = sx[index]/(double)samplesize;
    temp= sx2[index]/(double)samplesize - mean[index]*mean[index];
    stddev[index] = sqrt(fabs(temp));
    pk_pk[index]=maximum[index]-minimum[index];
 }

 /*
	disable data ready char from master, pior to normal exit
 */
 temprs232tofbbaddr = rs232tofbbaddr;
 rs232tofbbaddr = 0; /* to master */
 birdchangevaluecmd[1] = 8;
 birdchangevaluecmd[2] = 0;
 cmdsize = 3;
 if (send_serial_cmd(birdchangevaluecmd,cmdsize) != cmdsize) {
	       printf("\n\r * problem sending data ready char disable *");
	       rs232tofbbaddr = temprs232tofbbaddr;
	       return(0);
 }
 rs232tofbbaddr = temprs232tofbbaddr;

 return(samplesize);
}


void printsamples(int samplesize, double mean[], double stddev[], 
		double pk_pk[], double maximum[], double minimum[]) 
{
 int index;
 
 printf("\r     X       Y       Z      Az      El     Roll\t\t%4d samples\n",samplesize);
 for (index=0; index<6; index++) printf("%7.2lf\t",mean[index]);
 printf("\tMean\n\r");
 for (index=0; index<6; index++) printf("%7.2lf\t",maximum[index]);
 printf("\tMax\n\r");
 for (index=0; index<6; index++) printf("%7.2lf\t",minimum[index]);
 printf("\tMin\n\r");
 for (index=0; index<6; index++) printf("%7.2lf\t",pk_pk[index]);
 printf("\tPeak to Peak\n\r");
 for (index=0; index<6; index++) printf("%7.2lf\t",stddev[index]);
 printf("\tStd Deviation\n\r");
 printf("\n\n");

 /* hitkeycontinue(); */
}

void clearbuff() {    /* clear serial buffer  function */
short rxchar;
  do
    rxchar = get_serial_char();
  while ( rxchar != NODATAAVAIL );
}



void getsamplesoverrange(int samplesize) {
 float start, end, step, temp, present;
 unsigned char temprs232tofbbaddr;
 int stepnumber, index;
 double mean[6], stddev[6], pk_pk[6];
 double maximum[6], minimum[6], noise;
 unsigned short i, el;
 unsigned short xmtr_time_cnt;
 float xtime;
 short cmdsize=0;
 static unsigned char birdchangevaluecmd[] = {'P',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};  

  /*
	Get the CPU crstal freq from master
  */
  clearbuff();
  temprs232tofbbaddr = rs232tofbbaddr;
  rs232tofbbaddr = 0; /* to master */
  if (!getcrystalfreq()) {
	  printf("\n\r * problem getting crystal frequency *");
	  return;
  }
  rs232tofbbaddr = temprs232tofbbaddr;
  printf("\n\r Crystal Frequency is: %4.1f\n",crystalfreq);


  start=getfloat("\n What starting frequency (14-144 Hz):",14,144);
  end=getfloat(" What ending frequency (14-144 Hz):",14,144);
  if (start==end) {
	printf("Start value and End value can not be the same.");
	hitkeycontinue();
	return;
  }
  if (start>end) {
    temp=start; start=end; end=temp;
  }
  do {
   step=getfloat(" What step frequency (positive number):",0,144);
  } while (step<=0);

  printf("\n\n\rMeasurement rate at START of scan in Measurments/sec %6.2f.",start);
  printf("\n\rMeasurement rate at END of scan %6.2f.",end);
  printf("\n\rScan step size in measurments/sec %6.2f",step);
    
  /* 
      get the average receiver position for display
  */
  printf("\n\n\r");

  getsamples(100,mean,stddev,pk_pk,maximum,minimum);
  
  printf("\rRECEIVER LOCATION\n\tX\tY\tZ\tAz\tEL\tROLL");
  printf("\n\r      %6.2lf  %6.2lf  %6.2lf %7.2lf %7.2lf %7.2lf",
	     mean[0],mean[1],mean[2],mean[3],mean[4],mean[5]);

  if (abs(mean[4])<45.0) { 
     /* EL below 45 degrees, use average Euler angle statistics */
     el=0;
     printf("\n\n\rSpeed   Xtime    Xmtr_Time_Cnt    Avg Euler Pk-Pk\n");
  } else {
     el=1;
     printf("\n\n\r* NOTE *  because Euler elevation was larger then 45 degrees, only ");
     printf("\n\relevation Peak to Peak will be displayed.");
     printf("\n\n\rSpeed   Xtime    Xmtr_Time_Cnt     EL Pk-Pk\n");
  }

  stepnumber = (int) ( (end-start)/step );

  for (present=start,index=0; index<=stepnumber; index++) {
    
    /*
	Check to see if user is tire of waiting
    */
    if (ckkbhit()) {
	printf("\n\n\r ** Keyboard break ** \n");
	break;
    }

    /*
      set measurement rate
    */

      /*
	Set the Parameter number and the command size
      */
      birdchangevaluecmd[1] = 6;
      cmdsize = 4;

      /*
	convert to transmitter time counts
      */
      i = (unsigned)(((crystalfreq/8.0)*1000.0)*
		   (((1000.0/present)-0.3)/4.0));
      *(unsigned char *)&birdchangevaluecmd[2] = (unsigned char) (i & 0xff);
      *(unsigned char *)&birdchangevaluecmd[3] = (unsigned char) ((i & 0xff00) >> 8);
	    
      xmtr_time_cnt = i;
      xtime = xmtr_time_cnt*(8.0/crystalfreq)/1000.0;
      
      /*
	 Send the new measurement speed Command to the Master unit
      */
      temprs232tofbbaddr = rs232tofbbaddr;
      rs232tofbbaddr = 0; /* to master */

      if (send_serial_cmd(birdchangevaluecmd,cmdsize) != cmdsize) {
	       printf("\n\r * problem setting new measurement rate *");
	       rs232tofbbaddr = temprs232tofbbaddr;
	       return;
      }
      rs232tofbbaddr = temprs232tofbbaddr;       

    if (getsamples(samplesize,mean,stddev,pk_pk,maximum,minimum)!=samplesize) 
	  return;

    if (el==0) noise = (pk_pk[3]+pk_pk[4]+pk_pk[5])/3.0;
    else noise = pk_pk[4];

    printf("\r%5.1lf   %6.3f   %10u         %5.2lf\n",present,xtime,xmtr_time_cnt,noise);
    present+=step;
    if (present>end) present=end;
  }
  hitkeycontinue();
}



/*
    getbirdstatistics   - aquire data and take noise statistics

    Prototype in:       birdcmds.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            Being developed.
*/

void getbirdstatistics(){

    int samplesize;
    int answer;
    double mean[6],stddev[6],pk_pk[6],maximum[6],minimum[6];    


    static char * birdstatmenu[] = {"Select Statistics option:",
				   "Return to main menu",
				   "Change sample number",
				   "Take POS/ANGLE samples",
				   "Take samples over a range"};

    samplesize=500;

    printf("\n\r** Reminder **");
    printf("\n\rIf you have a multiple receiver system and using one RS232 to");
    printf("\n\rthe master, then you must use the RS232 to FBB command to select");
    printf("\n\rthe receiver you want noise statistics from.");
    printf("\n\rTake receiver out of BUTTON mode and GROUP mode.");
    printf("\n\rTo get statistics at measurement rates above 110 Hz, the baud rate");
    printf("\n\rmust be at least 38400.\n");

    while (1) {   /* loop forever */

      printf("\n\rDefault sample number: %4d\n",samplesize);
       /*
	   Find out what the user wants to do ...
       */
      
      switch (sendmenu(birdstatmenu,4))
      {
	case 0:     /* return to main menu */
	   return;

	case 1:     /* specify sample size */
	   do {
	     printf ("\n\rEnter the number of samples for statistics: ");
	     if ((answer = getnumber()) == ESC_SEL)  break;
	     if (answer<3) 
		printf("\n\r number must be greater then 3 (or ESC key)");
	   } while (answer < 3) ;
	   samplesize=answer;
	   break;

	case 2:     /* take samples pos/angles */
	   printf("Sampling %d data records from ",samplesize);
	   if (rs232tofbbaddr<2) printf("Master Receiver..\n\r");
	   else printf("Receiver at address %d..\n\r",rs232tofbbaddr);
	   while (!ckkbhit()) 
	    if ( getsamples(samplesize,mean,stddev,pk_pk,maximum,minimum) == samplesize)
		printsamples(samplesize,mean,stddev,pk_pk,maximum,minimum);
	    else {
	      printf("Error taking samples, no statistics calculated");
	      clearkey();
	      break;
	    }
	   clearkey();
	   break;
	
	case 3:   /* take samples over a range (of cycle speeds) */
	   printf("Sampling %d data records from ",samplesize);
	   if (rs232tofbbaddr<2) printf("Master Receiver..\n\r");
	   else printf("Receiver at address %d..\n\r",rs232tofbbaddr);
	   getsamplesoverrange(samplesize);
      }
      printf("\n\n\n\r");
    } /* while loop */
}

