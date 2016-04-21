/****************************************************************************
*****************************************************************************

    rstofbb.c       RS232 to FBB C Commands

    written for:    Ascension Technology Corporation
		    PO Box 527
		    Burlington, Vermont  05402

		    802-655-7879

    written by:     Jeff Finkelstein

    Modification History:
       4/22/92   jf.. POSK36 changed to posk, posk declared external
       6/16/92   jf.. modified angle output format to 0.1 degree resol.
       8/17/92   jf.. modified for Group Data Mode
       10/3/92   jf.. fixed bug in POS/MATRIX display
       10/12/92  jf.. fixed bug in Group Data Mode Display of Info
       1/27/92   jf.. integrated with CBIRD
       7/7/93    jf.. updated to allow the display of button data from
		      multiple units in both the RS232 PASS through mode
		      and Group Mode
       10/20/93  jf.. modified to use GETTICKS

	   <<<< Copyright 1992 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/

#include <stdio.h>          /* general I/O */
#include "asctech.h"        /* Ascension Technology definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "menu.h"           /* Ascension Technology Menu Routines */
#include "serial.h"         /* Ascension Technology Serial Port Routines */
#include "cmdutil.h"
#include "pctimer.h"
#include "rstofbb.h"

/*
    Define Externals
*/
extern float posk;
extern unsigned char fbbgroupdataflg;
extern FILE * datafilestream;
extern short flocksize;
extern short numfbbaddrs;
extern short numfbbrcvrs;
extern short buttonvalue;
extern unsigned char fbbsystemstatus[];


/*
    Define Globals
*/
unsigned char displayliststartaddr = 1;
unsigned char displayliststopaddr = 0;
unsigned char displaymultidataflg = FALSE;
unsigned char rs232tofbbstartaddr = 99; /* start with an illegal address */
unsigned char screencleared = FALSE;
unsigned char multibuttonvalue[30];     /* holds the buttonvalue for each unit */



/*
    rs232tofbbcmd       RS232 to FBB Command

    Prototype in:       rstofbb.h

    Parameters Passed:  void

    Return Value:       TRUE if command sent OK
			FALSE if command could not be sent
			ESC_SEL if the user selected ESC

    Remarks:
*/
int rs232tofbbcmd()
{
    int answer;
    printf ("\n\rIf enabled, the RS232 TO FBB Command will be used for all commands other\n\rthen the data display commands...\n\r");

    if ((answer = askyesno("\n\rDo you want to enable the RS232 TO FBB Command")) == ESC_SEL)
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
	    rs232tofbbaddr = 0;     /* The Zero Address indicates not used */
	    return (FALSE);
	}
    }

    /*
	Get the Destination Addresses
    */
    getfbbdestaddress(&rs232tofbbstartaddr,NULL);

    /*
	Store for serial communications
    */
    rs232tofbbaddr = rs232tofbbstartaddr;

    return(TRUE);
}

/*
    getmultibirddata    Get Data from Multiple Birds

    Prototype in:       rstofbb.h

    Parameters Passed:  outputmode - POINT, CONTINUOUS, STREAM
			datamode   - POS, ANGLE, MATRIX, etc.
			displayon  - TRUE, FALSE
			buttonmode - ON, OFF
			(global) displayliststartaddr - 1st address in
				 the group to retrieve data from
			(global) displayliststopaddr - last address in
				 the group to retrieve data from

    Return Value:       TRUE if command executed OK
			FALSE otherwise

    Remarks:            Get data from a group of Birds using the ind
			the datamode specified
*/
int getmultibirddata(outputmode,datamode,displayon,buttonmode)
short outputmode;
unsigned char datamode;
unsigned char displayon;
short buttonmode;
{
    unsigned char startaddr;
    unsigned char stopaddr;
    short chr;
    unsigned char birddata[25 * 30];
    unsigned char firsttime = TRUE;

    /*
	Get the System Status from the Flock in Group Mode to assure
	that we get data from the correct number of receivers
    */
    if (fbbgroupdataflg)
    {
	if (!getsystemstatus())
	    return(FALSE);
    }

    /*
	Set All the Birds into the correct Data Output Mode
    */
    startaddr = displayliststartaddr;
    stopaddr = displayliststopaddr;

    if (!setdatamode(startaddr, stopaddr, datamode))
	return(FALSE);

    /*
	Now Get Data from all the Birds
    */
    screencleared = FALSE;

    while (TRUE)
    {
	/*
	   Display from on the Top of Screen
	*/
	if (!screencleared)
	{
	   CLEARSCREEN;
	   screencleared = TRUE;
	}

	/*
	   Move Cursor to the Top of the Screen
	*/
	SETTEXTPOS(1,1);

	/*
	    Put up a User Message
	*/
	if (!fbbgroupdataflg)
	   printf ("Data from Flock... (Hit Any Key to Quit) \n\n\r");
	else
	   printf ("Group Data from Flock... (Hit Any Key to Quit) \n\n\r");

	/*
	     Send the User a Prompt if in Point mode
	*/
	switch  (outputmode)
	{
	    case POINT:
		printf ("Hit the 'B' Key to read Bird data...\n\r");
		while (!ckkbhit());               /* wait for a key */
		chr = getkey();                   /* get the character */
		if ((chr != 'B') && (chr != 'b')) /* check if a B or b */
		   return(TRUE);
		break;

	    case CONTINUOUS:

		if (ckkbhit())
		{
		   clearkey();
		   SETTEXTPOS(1,numfbbrcvrs+4);
		   hitkeycontinue();
		   return(TRUE);
		}
		break;

	    case STREAM:
		if (firsttime)
		{
		   send_serial_cmd((unsigned char *)"@",1);     /* START streaming */
		   firsttime = FALSE;
		}

		if (ckkbhit())
		{
		   clearkey();
		   send_serial_cmd((unsigned char *)"B",1);     /* stop streaming, via Point cmd */
		   if (phaseerror_count)       /* inform the user of phase errors */
		   {
					    printf("*NOTE* %d Phase Errors have occured\n\r",phaseerror_count);
		   }
		   SETTEXTPOS(1,numfbbrcvrs+4);
		   hitkeycontinue();
		   return(TRUE);
		}
		break;

	    default:
		printf("\n\r** ERROR ** mode not currently supported\n\r");
		hitkeycontinue();
		return(FALSE);
	}

	/*
	    Get and Display the Data from all the Birds
	*/
	if (getmultirecords(outputmode, buttonmode, datamode, startaddr, stopaddr, birddata))
	{
	    displaymultidata(datamode, buttonmode, displayon,
			     startaddr,stopaddr, birddata,
			     datafilestream);
	}
	else
	{
	    return(FALSE);
	}
    }
}

/*
    getmultirecords     Get Multiple Records

    Prototype in:       rstofbb.h

    Parameters Passed:  datamode - POS,ANGLE,MATRIX,etc
			buttonmode - ON/OFF
			startaddr - 1st FBB address to collect data from
			stopaddr - last FBB address to collect data from
			(global) fbbgroupdataflg - TRUE or FALSE, indicating the state
				 group mode

    Return Value:       TRUE if all went well
			FALSE otherwise

    Remarks:
*/
int getmultirecords(outputmode, buttonmode, datamode, startaddr, stopaddr, birddata)
short outputmode;
short buttonmode;
unsigned char datamode;
unsigned char startaddr;
unsigned char stopaddr;
unsigned char * birddata;
{
    short datasize;
    short numrecords = 0;
    unsigned char addr = 0;
    unsigned char temprs232tofbbaddr;
    unsigned char birdcmd;

    /*
	Save the Global rs232tofbbaddr in a temp
    */
    birdcmd = (unsigned char) 'B';        /* POINT data mode */
    temprs232tofbbaddr = rs232tofbbaddr;


    switch (datamode)
    {
	case POS:  /* position */
	     datasize = 3;
	     break;

	case ANGLE:  /* angles */
	     datasize = 3;
	     break;

	case MATRIX:  /* matrix */
	     datasize = 9;
	     break;

	case POSANGLE:  /* position/angles */
	     datasize = 6;
	     break;

	case POSMATRIX:  /* position/matrix */
	     datasize = 12;
	     break;

	case QUATER:     /* quaternions */
	     datasize = 4;
	     break;

	case POSQUATER:  /* position and quaternions */
	     datasize = 7;
	     break;

	default:
	     printf("\n\r** ERROR ** illegal datamode in getmultirecord\n\r");
	     rs232tofbbaddr = temprs232tofbbaddr;
	     return(FALSE);
    }

    /*
       If the Bird is NOT in the Group Data Mode
    */
    if (!fbbgroupdataflg)
    {
	/*
	    Now Get the Data for each device
	*/
	for (addr = startaddr; addr <= stopaddr; addr++)
	{
	    /*
		Only Get data from devices with receivers
	    */
	    if (!(fbbsystemstatus[addr] & 0x20))
		continue;

	    /*
		Set the FBB Address
	    */
	    rs232tofbbaddr = addr;

	    /*
		Send the POINT command
	    */
	    if (send_serial_cmd(&birdcmd,1) != 1)
	    {
		printf("\n\r** ERROR ** could not send Point command to Bird at address %d\n\r",addr);
		rs232tofbbaddr = temprs232tofbbaddr;
		return(FALSE);
	    }
	    else
	    {
		if (!readbirddata((short *)birddata, datasize, POINT, buttonmode))
		{
		    printf("\n\r** ERROR ** could not get information from Bird at address %d\n\r",addr);
		    rs232tofbbaddr = temprs232tofbbaddr;
		    return(FALSE);
		}
		else
		{
		    birddata += (datasize * 2) + buttonmode;

		    /*
			Save the Button Value for Each Address
		    */
		    multibuttonvalue[addr] = buttonvalue;
		}
	    }
	}
    }
    else /* The Bird is in the Group Data Mode */
    {
	/*
	    Shut off the rs232 to fbb command..temporarily
	*/
	rs232tofbbaddr = 0;

	/*
	    Send the output position command
	*/
	if (outputmode != STREAM)
	{
	    if (send_serial_cmd(&birdcmd,1) != 1)
	    {
		printf("\n\r** ERROR ** could not send Point command to Bird at address %d\n\r",addr);
		rs232tofbbaddr = temprs232tofbbaddr;
		return(FALSE);
	    }
	}

	/*
	    Do for all the address ..
	    Only Get Data from the devices with Receivers
	    ..so offset the number of records
	*/
	while (numrecords++ < numfbbrcvrs)
	{
	    if (!readbirddata((short *)birddata, datasize, POINT, buttonmode))
	    {
		printf("\n\r** ERROR ** could not get information from Bird %d\n\r",addr);
		rs232tofbbaddr = temprs232tofbbaddr;
		return(FALSE);
	    }
	    else
	    {
		/*
		    Add in the extra address char (GROUP MODE)
		    Note that datasize was in WORDs
		*/
		birddata += (datasize * 2) + 1 + buttonmode;

		/*
		    Save the Button Value for Each Address
		*/
		multibuttonvalue[numrecords] = buttonvalue;
	    }
	}
    }

    rs232tofbbaddr = temprs232tofbbaddr;
    return(TRUE);
}


/*
    getfbbdestaddress   Get the FBB Destination Addresses

    Prototype in:       rstofbb.h

    Parameters Passed:  startaddrptr - pointer to the start address
			stopaddrptr - pointer to the stop address
				      If stopaddrptr == NULL then
				      the routine only gets the destination
				      address

    Return Value:       TRUE (always)

    Remarks:            Prompts the User for the start and stop address

*/
int getfbbdestaddress(startaddrptr,stopaddrptr)
unsigned char * startaddrptr;
unsigned char * stopaddrptr;
{
    short tempstartaddr;
    short tempstopaddr;
    short illegaladdr = FALSE;

    /*
	Use the System Status to determine if address the user selects
	is avaible
    */
    if (!getsystemstatus())
	return(FALSE);

    do
    {
	if (stopaddrptr != NULL)
	{
	    /*
	       If the user goes to this menu first, reset the illegal
	       address in the startaddress location
	    */
	    if (*startaddrptr > 30)
		*startaddrptr = 1;
	    printf("\n\rCurrent Start Destination Address is %d\n\r",*startaddrptr);
	    printf("Enter the Start Destination Address (<ESC> for no change): ");
	}
	else
	{
	    printf("\n\rCurrent Destination Address is %d\n\r",*startaddrptr);
	    printf("Enter the new Destination Address (<ESC> for no change): ");

	}

	if ((tempstartaddr = getnumber()) != ESC_SEL)
	{
	    if ((tempstartaddr < 0) || (tempstartaddr > numfbbaddrs))
	    {
		illegaladdr = TRUE;
		printf ("\n\r** ERROR ** illegal address\n\r");
	    }
	    else
	    {
		if (fbbsystemstatus[tempstartaddr] & 0x80)
		{
		    illegaladdr = FALSE;
		    *startaddrptr = tempstartaddr;
		}
		else
		{
		    illegaladdr = TRUE;
		    printf("\n\r** ERROR ** address selected is not accessible\n\r");
		}
	    }
	}
	else
	    break;
    }
    while (illegaladdr);

    /*
	Only get the Stop address info if stopaddrptr exists
    */
    if (stopaddrptr != NULL)
    {
	do
	{
	    printf("\n\r\n\rCurrent Stop Destination Address is %d\n\r",*stopaddrptr);
	    printf("Enter the Stop Destination Address (<ESC> for no change): ");
	    if ((tempstopaddr = getnumber()) != ESC_SEL)
	    {
		if ((tempstopaddr <= 0)
		   || (tempstopaddr > numfbbaddrs)
		   || (tempstopaddr < tempstartaddr))
		{
		    illegaladdr = TRUE;
		    printf ("\n\r** ERROR ** illegal address\n\r");
		}
		else
		{
		    if (fbbsystemstatus[tempstartaddr] & 0x80)
		    {
			illegaladdr = FALSE;
			*stopaddrptr = tempstopaddr;
		    }
		    else
		    {
			illegaladdr = TRUE;
			printf("\n\r** ERROR ** address selected is not accessible\n\r");
		    }
		}
	    }
	    else
		break;
	}
	while (illegaladdr);
    }
    return(TRUE);
}

/*
    seddatamode         Set the FBB Data Mode

    Prototype in:       rstofbb.h

    Parameters Passed:  startaddr - 1st address to set the data mode
			stopaddr - last address to set the data mode
			datamode - POS,ANGLE,MATRIX,etc

    Return Value:       TRUE if the datamode was set on all the Birds
			FALSE otherwise

    Remarks:            Sends the desired mode to all the Birds in the
			start - stop range
*/
int setdatamode(startaddr,stopaddr,datamode)
unsigned char startaddr;
unsigned char stopaddr;
unsigned char datamode;
{
    int addr;
    unsigned char posorientcmd;
    unsigned char temprs232tofbbaddr;

    /*
       Setup the command
    */
    switch(datamode)
    {
	case POS:
	    posorientcmd = 'V';
	    break;

	case ANGLE:
	    posorientcmd = 'W';
	    break;

	case MATRIX:
	    posorientcmd = 'X';
	    break;

	case QUATER:
	    posorientcmd = 92;
	    break;

	case POSANGLE:
	    posorientcmd = 'Y';
	    break;

	case POSMATRIX:
	    posorientcmd = 'Z';
	    break;

	case POSQUATER:
	    posorientcmd = ']';
	    break;

	default:
	    printf("\n\r** ERROR ** illegal data mode in setdatamode\n\r");
	    return(FALSE);
    }

    temprs232tofbbaddr = rs232tofbbaddr;

    for (addr = startaddr; addr <= stopaddr; addr++)
    {
	/*
	    Set the Address
	*/
	rs232tofbbaddr = addr;

	/*
	    Send the output position command
	*/
	if (send_serial_cmd(&posorientcmd,1) != 1)
	{
	    printf("\n\r** ERROR ** could not initialize Output Mode of Bird %d\n\r",addr);
	    rs232tofbbaddr = temprs232tofbbaddr;
	    return(FALSE);
	}
    }

    rs232tofbbaddr = temprs232tofbbaddr;
    return(TRUE);
}

/*
    displaymultidata    Display Data from Multiple Birds

    Prototype in:       rstofbb.h

    Parameters Passed:  datamode - POS,ANGLE,MATRIX,etc
			buttonmode - ON,OFF indicates the state of button
				     output
			displayon - TRUE,FALSE

    Return Value:

    Remarks:
*/
int displaymultidata(datamode, buttonmode, displayon, startaddr,stopaddr,
		     birddata, datafilestream)
unsigned char datamode;
short buttonmode;
unsigned char displayon;
unsigned char startaddr;
unsigned char stopaddr;
unsigned char * birddata;
FILE * datafilestream;
{
    unsigned char addr;
    short displaysize;

    for (addr = startaddr; addr <= stopaddr; addr++)
    {
	/*
	    Display the data only if the device has a receiver
	*/
	if (!(fbbsystemstatus[addr] & 0x20))
	    continue;

	/*
	    Get the current button value prior to displaying the data
	*/
	buttonvalue = multibuttonvalue[addr];
	displaysize = displaybirddata((short *)birddata,datamode,buttonmode,
				      displayon,addr,datafilestream);

	/*
	    compute the new birddata address for the next record
	*/
	birddata += displaysize * 2 + buttonmode;

	/*
	    If in Group Data Mode, increment past the address
	*/
	if (fbbgroupdataflg)
	    birddata += 1; /* increment the pointer */
    }
    return(TRUE);
}


/*
    getmaxrs232tofbbrate  Get the Maximum Data Rate for RS232 to FBB command

    Prototype in:       rstofbb.h

    Parameters Passed:  none
			(assumes the Flock in NOT IN GROUP MODE)

    Return Value:       TRUE if all goes well
			FALSE otherwise

    Remarks:            Only available to DOS since this module uses
			GETTICKS

			UNIX user can modify the code to call there system
			timer in order to keep track of real time

*/
int getmaxrs232tofbbrate()
{
#ifdef DOS
    static unsigned char startaddr = 1;
    static unsigned char stopaddr = 0;
    unsigned char datamode = 0;
    int testtime;
    long testcounter;
    unsigned long testtimeticks;
    unsigned long starttimeticks;
    unsigned long currenttimeticks;
    unsigned char birddata[25 * 30];

    static char * outputmodemenu[] = {"Select the Output Mode:",
				      "Return to Main Menu",
				      "Position",
				      "Angles",
				      "Matrix",
				      "Quaternions",
				      "Position and Angles",
				      "Position and Matrix",
				      "Position and Quaternions"};

    /*
	Ask the User what Data Mode they want
    */
    switch (sendmenu(outputmodemenu,8))
    {
	case ESC_SEL:
	case 0:
	     return(TRUE);

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
	Get the desired addresses
	.. preload the stop address with the group size
    */
    if (stopaddr == 0)
       stopaddr = flocksize;
    getfbbdestaddress(&startaddr,&stopaddr);

    /*
	Set up all the Devices to the Correct Data Mode
    */
    if (setdatamode(startaddr, stopaddr, datamode))
    {
	if ((testtime = getsampletime()) == ESC_SEL)
	    return(FALSE);

	testtimeticks = (unsigned long)(testtime * (1000/TICK_MSECS));

	printf("\n\rTest Started...collecting data, please wait\n\r");
	putch(BEL);
	starttimeticks = GETTICKS;
	while ((currenttimeticks = GETTICKS) == starttimeticks);
	starttimeticks = currenttimeticks;

	testcounter = 0;

	while (((currenttimeticks = GETTICKS) - starttimeticks) < testtimeticks)
	{
	    if (!getmultirecords(POINT, OFF, datamode, startaddr, stopaddr, birddata))
	    {
		putch(BEL);
		printf ("\n\r** ERROR ** Test Aborted\n\r");
		hitkeycontinue();
		return(FALSE);
	    }
	    testcounter += 1;
	}

	/*
	    Indicate the Test Complete to the User
	*/
	putch(BEL);
	printf ("\n\rTest Complete !!\n\r");
	printf ("Sample birds %d through %d %ld times in %d seconds...\n\r"
		"yielding a maximum data rate of %6.2f samples/sec/Bird\n\r",
		 startaddr, stopaddr, testcounter, testtime,(float)testcounter/testtime);
    }

    hitkeycontinue();
    return(TRUE);

#endif
#ifdef UNIX
    return(FALSE);
#endif
}

/*
    getsampletime       Get the Sample Time (length of Time) from the User

    Prototype in:       rstofbb.h

    Parameters Passed:  void

    Return Value:       testtime as an integer

    Remarks:
*/
int getsampletime()
{
#ifdef UNIX
   printf("\n\r** NOTE ** mode not supported under UNIX\n\r");
   hitkeycontinue();
   return(TRUE);

#endif


#ifdef DOS
    int testtimeint;

    while(1)
    {
	printf("\n\rEnter the length of the test in seconds (10 to 100): ");

	if ((testtimeint = getnumber()) == ESC_SEL)
	    return(ESC_SEL);

	if ((testtimeint < 10) || (testtimeint > 100))
	{
	    printf("\n\r** ERROR ** illegal time\n\r");
	}
	else
	{
	    return(testtimeint);
	}
    }
#endif
}
