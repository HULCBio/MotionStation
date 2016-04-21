/****************************************************************************
*****************************************************************************
    cmdutil.c       - Bird Command Utilities Routine

    written for:    Ascension Technology Corporation
		    PO Box 527
		    Burlington, Vermont  05402
		    802-655-7879

    by:             Jeff Finkelstein
		    802-985-2535


    Modification History:
			4/29/91        jf  - created from BIRDCMDS.c
			5/20/91            jf  - fixed row/col order in printmatrix
	    9/16/91        jf  - added showfbbconfig
	    2/25/92        jf  - removed showfbbconfig
	    4/7/92         jf  - added fprintmatrix
	    4/20/92        mo  - added fprintquaternions() and
				 printquaternions().
	    10/12/92       jf  - modified to display 3 sig. digits for Matrix
	    12/23/92       jf  - updated readbirddata to be CPU independent
				 by using C types to define byte ordering
	    1/26/93        jf  - added functions to print/file for all
				 output modes
			   jf  - modified readbirddata to read an extra
				 character if in fbbgroupdata mode
	    2/26/93        jf  - added getsystemstatus
	    3/1/93         jf  - added checkerrorstatus
			       - added displayerror
			       - added getsystemstatus
	    3/22/93        jf  - added expanded error 'Note'
	    6/22/94        ssw - modified getaddmode to include setting IRQ 0
				 fix to stop lockout
1/10/96  vk..readbirddata() moved to iface.c
1/12/96  vk..dumpbirdarray(),checkerrorstatus() deleted - not in use.
         - getcrystalfreq(), getaddrmode(), getsystemstatus () changed
         to choose Serial or ISA interface.
2/1/96   vk..displaybirddata() changed. If ISA interface THEN treat button
         value as a WORD not a byte.
2/2/96   vk..displayerror() changed to send "Invalid Command" message
         instead of "Invalid RS232 Command" message, because it's either
         RS232 OR ISA Bus.
2/12/96  vk..displaybirddata() changed. If ISA interface THEN treat address
         as a WORD not a byte when in group mode.
2/13/96  vk..check_done() changed. IF ISA interface then to
         stop streaming call bird_clearoutputbuffer_isa() function.
2/16/96  vk..getsystemstatus(), getcrystalfreq(), getaddrmode() changed
         to clear Bird Output Buffer and disable data ready char output
         in a case of ISA interface. Otherwise instead of good
         data will read data ready char IF it was enabled.
         - set_system_isa_protocol() added to initialize ISA protocol
         for all devices in the configuration.
	   <<<< Copyright 1990 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <math.h>           /* trig math funcs */
#include "asctech.h"        /* general definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "menu.h"           /* for menus */
#include "serial.h"         /* serial I/O */
#include "cmdutil.h"        /* cmdutil.header */
#include "iface.h"          /* Interface Functions Prototypes */
#ifdef DOS
  #include "isadpcpl.h"       /* ISA Functions Prototypes */
  #include "isacmds.h"
#endif

/*
    External Definitions
*/
short endian(short *sptr);

extern short interface;
extern float crystalfreq;
extern short buttonvalue;
extern float posk;
extern unsigned char fbbgroupdataflg;
extern short numfbbaddrs;
extern short numfbbrcvrs;
extern unsigned char fbbsystemstatus[];
extern unsigned char rs232tofbbstartaddr;
extern unsigned char displayliststartaddr;
extern unsigned char displayliststopaddr;
extern unsigned char displaymultidataflg;
extern short little_endian;
#ifdef DOS
extern unsigned short isa_status_addr;
#endif

/*
    Definitions Expanded Error Decoding
*/
unsigned char fbbaddrbits;
unsigned char cmdbitshft;


/*
    check_done          -   Check to seed if Data Output Done

    Prototype in:       cmdutil.h

    Parameters Passed:  outputmode      - output mode POINT,CONTINUOUS, STREAM

    Return Value:       TRUE if done
			FALSE otherwise

    Remarks:            POINT mode:
			    - wait for key hit
			    - if B/b return FALSE
			      else, return TRUE

			CONTINUOUS mode:
			    - if key hit return TRUE
			      else, return FALSE

			STREAM mode:
			    - if key hit
				send 'f' command to turn off stream mode and clear buffer
				return TRUE
			      else, return FALSE
*/
int check_done(outputmode)
short outputmode;
{
	short chr;            /* character returned from getch() */

    /*
	Do this as a function of POINT, CONTINUOUS, or STREAM outputmode
    */
    switch (outputmode)
    {
	case STREAM:
	    if (ckkbhit())
	    {
		clearkey();                 /* clear the keyboard */
        if (interface == RS232)
		   send_cmd((unsigned char *)"B",1);     /* stop streaming, via Point cmd */
#ifdef DOS
        else                                 /* ISA interface */
           bird_clearoutputbuffer_isa();     /* stop streaming, via Clear Output Buffer cmd */
#endif
		if (phaseerror_count)       /* inform the user of phase errors */
					printf("*NOTE* %d Phase Errors have occured\n\r",phaseerror_count);

		break;                        /* return TRUE */
	    }
	    return(FALSE);                  /* not done */

	case CONTINUOUS:
	    if (ckkbhit())                  /* if key hit... */
	    {
		clearkey();                 /* clear the keyboard */
		break;
	    }
	    else                            /* no key hit .. continue */
	    {
		if (send_cmd((unsigned char *)"B",1) != 1) /* get another set of points */
		    return(TRUE);           /* return done if errors */

		return(FALSE);              /* continue */
	    }

	case POINT:
	    while (!ckkbhit());               /* wait for a key */
	    chr = getkey();                   /* get the character */
	    if ((chr == 'B') || (chr == 'b')) /* check if a B or b */
	    {
		send_cmd((unsigned char *)"B",1);     /* get another set of points */
		return(FALSE);              /* return not done */
	    }
	    break;
    }

    /*
	Wait for the user to see the data
    */
    hitkeycontinue();
    return(TRUE);               /* indicate done */
}

/*
    displaybirddata     Display and File the Bird Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
			unsigned char datamode - POS, ANGLE, POSANGLE..
			buttonmode - ON/OFF
			datafilestream - file to store data in..if any

    Return Value:       void

    Remarks:

*/
int displaybirddata(birddata, datamode, buttonmode, displayon, displayaddr, datafilestream)
short * birddata;
unsigned char datamode;
short buttonmode;
unsigned char displayon;
unsigned char displayaddr;
FILE * datafilestream;
{
    short displaysize;
    unsigned char * tempbirddata;

    /*
	Use tempbirddata to point to individual characters in
	the birddata
    */
    tempbirddata = (unsigned char *) birddata;

    /*
	Display the address at  the begginning if in RS232TOFBB mode

	Display the Address information at the end if in the
	group data mode.. since that is where the address information
	is within the data stream
    */
    if ((displaymultidataflg) && (!fbbgroupdataflg))
    {
	if (displayon)
	    printf("%d ", displayaddr);

	if (datafilestream)
	    fprintf(datafilestream,"%d ", displayaddr);
    }

    /*
       Set the for the number of WORDs (16 bits) and Pos/Orientation Mode
       command
    */
    switch(datamode)
    {
	case POS:
	    displaysize = printposition((short *) tempbirddata,buttonmode,displayon,datafilestream);
	    break;

	case ANGLE:
	    displaysize = printangles((short *) tempbirddata,buttonmode,displayon,datafilestream);
	    break;

	case MATRIX:
	    displaysize = printmatrix((short *) tempbirddata,buttonmode,displayon,datafilestream);
	    break;

	case QUATER:
	    displaysize = printquaternions((short *) tempbirddata,buttonmode,displayon,datafilestream);
	    break;

	case POSANGLE:
	    displaysize = printposangles((short *) tempbirddata,buttonmode,displayon,datafilestream);
	    break;

	case POSMATRIX:
	    displaysize = printposmatrix((short *) tempbirddata,buttonmode,displayon,datafilestream);
	    break;

	case POSQUATER:
	    displaysize = printposquaternions((short *) tempbirddata,buttonmode,displayon,datafilestream);
	    break;

	default:
	    printf("\n\r** ERROR ** illegal data mode in displaybirddata\n\r");
	    return(0);
    }

    /*
	If in Group Data Mode, print the address just received
    */
    if (fbbgroupdataflg)
    {
	/*
	    get to the addr loc
	*/
	tempbirddata += ((displaysize * 2) + buttonmode);
    if (interface == ISA_BUS)            /* If ISA BUS THEN */
    {
       tempbirddata += buttonmode;       /* increment more, because buttonmode is a WORD */
       tempbirddata += 1;                /* increment more, because address is in LSByte of a Word */
    }
	if (displayon)
	    printf("    %d", *tempbirddata); /* print the address */

	if (datafilestream)
	    fprintf(datafilestream, "    %d", *tempbirddata);

	tempbirddata += 1;                   /* increment the pointer
                                            to point following byte in the record */
    }

    /*
	Set up for the next line
    */
    if (displayon)
    {
	printf("\n\r");
	if ((datamode == MATRIX) || (datamode == POSMATRIX))
	    printf("\n\r");
    }

    if (datafilestream)
    {
	fprintf(datafilestream,"\n");
	if ((datamode == MATRIX) || (datamode == POSMATRIX))
	    fprintf(datafilestream,"\n");
    }

    return(displaysize);
}

/*
    printposition       Print and File the Position Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
			buttonmode - ON/OFF
			displayon - DISPLAYON/OFF
			datafilestream - file to store data in..if any

    Return Value:       int 3

    Remarks:
*/
int printposition(birddata,buttonmode,displayon,datafilestream)
short * birddata;
short buttonmode;
unsigned char displayon;
FILE * datafilestream;
{
    short i;
    float floatdata[3];
    char * printdataformat = "\t%7.2f\t%7.2f\t%7.2f";
    char * printbuttonformat = "\t%3d";

    /*
	Only compute if display or file is enabled
    */
    if ((displayon) || (datafilestream))
    {
	#ifdef IRIX
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(endian(birddata+i) * posk);
	#else
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(birddata[i] * posk);
	#endif
	}

    /*
	Display the Data and Button Value (if required)
    */
    if (displayon)
    {
	printf(printdataformat,floatdata[0],floatdata[1],floatdata[2]);
	if (buttonmode != 0)
	    printf(printbuttonformat, buttonvalue);
    }

    /*
	Save the Data to a File...only if one exists!
    */
    if (datafilestream)
    {
	/*
	    print the data to the file
	*/
	fprintf(datafilestream,printdataformat,
		floatdata[0],floatdata[1],floatdata[2]);

	/*
	    save the Button Value if required
	*/
	if (buttonmode != 0)
	    fprintf(datafilestream, printbuttonformat, buttonvalue);
    }
    return(3);
}

/*
    printangles         Print and File the Angle Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
			buttonmode - ON/OFF
			displayon - DISPLAYON/OFF
			datafilestream - file to store data in..if any

    Return Value:       int 3

    Remarks:
*/
int printangles(birddata,buttonmode,displayon,datafilestream)
short * birddata;
short buttonmode;
unsigned char displayon;
FILE * datafilestream;
{
    short i;
    float floatdata[3];
    char * printdataformat = "\t%7.2f\t%7.2f\t%7.2f";
    char * printbuttonformat = "\t%3d";

    /*
	Only compute if display or file is enabled
    */
    if ((displayon) || (datafilestream))
    {
	#ifdef IRIX
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(endian(birddata+i) * ANGK);
	#else
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(birddata[i] * ANGK);
	#endif
	 }

	 /*
	Display the Data and Button Value (if required)
	 */
	 if (displayon)
	 {
	printf(printdataformat,floatdata[0],floatdata[1],floatdata[2]);
	if (buttonmode != 0)
		 printf(printbuttonformat, buttonvalue);
	 }

	 /*
	Save the Data to a File...only if one exists!
	 */
	 if (datafilestream)
    {
	/*
	    print the data to the file
	*/
	fprintf(datafilestream,printdataformat,
		floatdata[0],floatdata[1],floatdata[2]);

	/*
	    save the Button Value if required
	*/
	if (buttonmode != 0)
	    fprintf(datafilestream, printbuttonformat, buttonvalue);

    }
    return(3);
}

/*
    printmatrix         Print and File the Matrix Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
			buttonmode - ON/OFF
			displayon - DISPLAYON/OFF
			datafilestream - file to store data in..if any

    Return Value:       int 9

    Remarks:
*/
int printmatrix(birddata,buttonmode,displayon,datafilestream)
short * birddata;
short buttonmode;
unsigned char displayon;
FILE * datafilestream;
{
    short i;
	short row;
    float floatdata[9];
    char * printdataformat[3] = {"\t%7.3f\t%7.3f\t%7.3f\n",
				 "\t%7.3f\t%7.3f\t%7.3f\n",
				 "\t%7.3f\t%7.3f\t%7.3f"};
    char * printbuttonformat = "\t%3d";

    /*
	Only compute if display or file is enabled
    */
    if ((displayon) || (datafilestream))
    {
	#ifdef IRIX
 		for (i=0;i<9;i++)
			 floatdata[i] = (float)(endian(birddata+i) * WTF);
	#else
		for (i=0;i<9;i++)
			 floatdata[i] = (float)(birddata[i] * WTF);
	#endif
    }

    /*
	Display the Data and Button Value (if required)
    */
    if (displayon)
    {
	/*
	    send out three rows of data
	*/
	    for(row=0;row<3;row++)      /* print the rows */
	    {
		    printf(printdataformat[row],
					    floatdata[row + 0],
					    floatdata[row + 3],
					    floatdata[row + 6]);

	    /*
		Display the Button Value if required
	    */
		    if ((row == 2) && (buttonmode != 0))
		printf(printbuttonformat,buttonvalue);
	    }
    }

    /*
	Save the Data to a File...only if one exists!
    */
    if (datafilestream)
    {
	/*
	    send out three rows of data
	*/
	    for(row=0;row<3;row++)      /* print the rows */
	    {
		    fprintf(datafilestream,printdataformat[row],
					    floatdata[row + 0],
					    floatdata[row + 3],
					    floatdata[row + 6]);

	    /*
		Display the Button Value if required
	    */
		    if ((row == 2) && (buttonmode != 0))
			    fprintf(datafilestream,printbuttonformat,buttonvalue);
	    }
    }
    return(9);
}

/*
    printposangles      Print and File the Position and Angle Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
			buttonmode - ON/OFF
			displayon - DISPLAYON/OFF
			datafilestream - file to store data in..if any

    Return Value:       int 6

    Remarks:
*/
int printposangles(birddata,buttonmode,displayon,datafilestream)
short * birddata;
short buttonmode;
unsigned char displayon;
FILE * datafilestream;
{
    short i;
    float floatdata[6];
    char * printdataformat = "\t%7.2f\t%7.2f\t%7.2f\t%7.2f\t%7.2f\t%7.2f";
	 char * printbuttonformat = "\t%3d";

    /*
	Only compute if display or file is enabled
    */
    if ((displayon) || (datafilestream))
    {
	#ifdef IRIX
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(endian(birddata+i) * posk);

		for (i=3;i<6;i++)
			 floatdata[i] = (float)(endian(birddata+i) * ANGK);
	#else
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(birddata[i] * posk);

		for (i=3;i<6;i++)
			 floatdata[i] = (float)(birddata[i] * ANGK);
	#endif
	 }

    /*
	Display the Data and Button Value (if required)
    */
    if (displayon)
    {
	printf(printdataformat,floatdata[0],floatdata[1],floatdata[2],
			       floatdata[3],floatdata[4],floatdata[5]);
	if (buttonmode != 0)
	    printf(printbuttonformat, buttonvalue);
    }

    /*
	Save the Data to a File...only if one exists!
    */
    if (datafilestream)
    {
	/*
	    print the data to the file
	*/
	fprintf(datafilestream,printdataformat,
		floatdata[0],floatdata[1],floatdata[2],
		floatdata[3],floatdata[4],floatdata[5]);

	/*
	    save the Button Value if required
	*/
	if (buttonmode != 0)
	    fprintf(datafilestream, printbuttonformat, buttonvalue);
    }
    return(6);
}

/*
    printquaternions    Print and File the Quaternion Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
			buttonmode - ON/OFF
			displayon - DISPLAYON/OFF
			datafilestream - file to store data in..if any

    Return Value:       int 4

    Remarks:
*/
int printquaternions(birddata,buttonmode,displayon,datafilestream)
short * birddata;
short buttonmode;
unsigned char displayon;
FILE * datafilestream;
{
    short i;
    float floatdata[4];
    char * printdataformat = "\t%8.4f %8.4f %8.4f %8.4f";
    char * printbuttonformat = "\t%3d";

    /*
	Only compute if display or file is enabled
    */
    if ((displayon) || (datafilestream))
    {
	#ifdef IRIX
		for (i=0;i<4;i++)
			 floatdata[i] = (float)(endian(birddata+i) * WTF);
	#else
		for (i=0;i<4;i++)
			 floatdata[i] = (float)(birddata[i] * WTF);
	#endif
    }

    /*
	Display the Data and Button Value (if required)
    */
    if (displayon)
    {
	printf(printdataformat,floatdata[0],floatdata[1],
			       floatdata[2],floatdata[3]);
	if (buttonmode != 0)
	    printf(printbuttonformat, buttonvalue);
    }

    /*
	Save the Data to a File...only if one exists!
    */
    if (datafilestream)
    {
	/*
	    print the data to the file
	*/
	fprintf(datafilestream,printdataformat,
		floatdata[0],floatdata[1],floatdata[2],floatdata[3]);

	/*
	    save the Button Value if required
	*/
	if (buttonmode != 0)
	    fprintf(datafilestream, printbuttonformat, buttonvalue);
    }
    return(4);
}

/*
    printposquaternions Print and File the Position and Quaternion Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
			buttonmode - ON/OFF
			displayon - DISPLAYON/OFF
			datafilestream - file to store data in..if any

    Return Value:       int 7

    Remarks:
*/
int printposquaternions(birddata,buttonmode,displayon,datafilestream)
short * birddata;
short buttonmode;
unsigned char displayon;
FILE * datafilestream;
{
    short i;
    float floatdata[7];
    char * printdataformat = "%7.2f %7.2f %7.2f %8.4f %8.4f %8.4f %8.4f";
    char * printbuttonformat = "\t%3d";

    /*
	Only compute if display or file is enabled
    */
    if ((displayon) || (datafilestream))
    {
	#ifdef IRIX
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(endian(birddata+i) * posk);

		for (i=3;i<7;i++)
			 floatdata[i] = (float)(endian(birddata+i) * WTF);
	#else
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(birddata[i] * posk);

		for (i=3;i<7;i++)
			 floatdata[i] = (float)(birddata[i] * WTF);
	#endif
    }

    /*
	Display the Data and Button Value (if required)
    */
    if (displayon)
    {
	printf(printdataformat,floatdata[0],floatdata[1],
			       floatdata[2],floatdata[3],
			       floatdata[4],floatdata[5],
			       floatdata[6]);
	if (buttonmode != 0)
	    printf(printbuttonformat, buttonvalue);
    }

    /*
	Save the Data to a File...only if one exists!
    */
    if (datafilestream)
    {
	/*
	    print the data to the file
	*/
	fprintf(datafilestream,printdataformat,
			       floatdata[0],floatdata[1],
			       floatdata[2],floatdata[3],
			       floatdata[4],floatdata[5],
			       floatdata[6]);

	/*
	    save the Button Value if required
	*/
	if (buttonmode != 0)
	    fprintf(datafilestream, printbuttonformat, buttonvalue);
    }
    return(7);
}

/*
    printposmatrix      Print and File the Position and Matrix Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
			buttonmode - ON/OFF
			displayon - DISPLAYON/OFF
			datafilestream - file to store data in..if any

    Return Value:       int 12

    Remarks:
*/
int printposmatrix(birddata,buttonmode,displayon,datafilestream)
short * birddata;
short buttonmode;
unsigned char displayon;
FILE * datafilestream;
{
    short i;
    short row;
    float floatdata[12];
    char * printdataformat1 = "\t%7.2f\t%7.2f\t%7.2f\n";
    char * printdataformat2[3] = {"\t%7.3f\t%7.3f\t%7.3f\n",
				 "\t%7.3f\t%7.3f\t%7.3f\n",
				 "\t%7.3f\t%7.3f\t%7.3f"};
	 char * printbuttonformat = "\t%3d";

    /*
	Only compute if display or file is enabled
    */
    if ((displayon) || (datafilestream))
    {
	#ifdef IRIX
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(endian(birddata+i) * posk);

		for (i=3;i<12;i++)
			 floatdata[i] = (float)(endian(birddata+i) * WTF);
	#else
		for (i=0;i<3;i++)
			 floatdata[i] = (float)(birddata[i] * posk);

		for (i=3;i<12;i++)
			 floatdata[i] = (float)(birddata[i] * WTF);
	#endif
    }

    /*
	Display the Data and Button Value (if required)
    */
    if (displayon)
    {
	printf(printdataformat1,floatdata[0],floatdata[1],
			       floatdata[2]);

	/*
	    send out three rows of data
	*/
	    for(row=0;row<3;row++)      /* print the rows */
	    {
		    printf(printdataformat2[row],
					    floatdata[row + 3],
					    floatdata[row + 6],
					    floatdata[row + 9]);

	    /*
		Display the Button Value if required
	    */
		    if ((row == 2) && (buttonmode != 0))
		printf(printbuttonformat,buttonvalue);
	    }
    }

    /*
	Save the Data to a File...only if one exists!
    */
    if (datafilestream)
    {
	fprintf(datafilestream,printdataformat1,floatdata[0],floatdata[1],
			       floatdata[2]);

	/*
	    send out three rows of data
	*/
	    for(row=0;row<3;row++)      /* print the rows */
	    {
		    fprintf(datafilestream,printdataformat2[row],
					    floatdata[row + 3],
					    floatdata[row + 6],
					    floatdata[row + 9]);

	    /*
		Display the Button Value if required
	    */
		    if ((row == 2) && (buttonmode != 0))
		fprintf(datafilestream,printbuttonformat,buttonvalue);
	    }
    }
    return(12);
}


/*
    printarray          -   Print Array Data

    Prototype in:       cmdutil.h

    Parameters Passed:  dataarray       - character/data array pointer
			size            - number of items to print

    Return Value:       TRUE

    Remarks:            prints each item of dataarray as a decimal number
			followed by a CR LF.
*/
int printarray(dataarray,size)
char * dataarray;
short size;
{
    while (size--)
		printf("%d\n\r",*dataarray++);

    return(TRUE);
}


/*
    getangles           - Get Angles from User

    Prototype in:       cmdutil.h

    Parameters Passed:  promptstrg      - string used to prompt user
			angle           - pointer to float array

    Return Value:       TRUE if got OK
			ESC_SEL if user selected ESC

    Remarks:            prompts user to enter 3 floating point angles and
			stores them in the angle array
*/
int getangles(promptstrg,angle)
char * promptstrg;
float * angle;
{
	short 			invalid;
	short 			i = 0;
    char 			floatstring[80];
    static double 	anglevalidlow[] = {-180.0, -90.0, -180.0};
    static double 	anglevalidhigh[] = {180.0,90.0,180.0};
    static char 	*anglepromptmsg[]= {"Azimuth","Elevation","Roll"};
	static char 	*invalidanglemsg = "\n\r** ERROR ** invalid angle\n\r";

    /*
	Put up a Prompt String
    */
	 printf("%s\n\r",promptstrg);

    /*
	Get Angle Info from user, 3 floating point (double) variables
    */
    do
    {
	invalid = FALSE;
	printf("Input %s: ",anglepromptmsg[i]);

	/*
	    Get a float value from the user
	*/
	if (getfloatstring(floatstring) != NULL)
	    angle[i] = (float) atof(floatstring);
	else
	    return(ESC_SEL);

	if ((angle[i] < anglevalidlow[i]) || (angle[i] > anglevalidhigh[i]))
	{
	    invalid = TRUE;
	       printf("%s",invalidanglemsg);
	}
	else
	{
	    i++;
	}
    }
    while ((invalid) || (i<3));

    return(TRUE);
}

/*
    getcrystalfreq      - Get the Crystal Frequency from the Bird

    Prototype in:       cmdutil.h

    Parameters Passed:  void

    Return Value:       TRUE if got OK, sets the Global crystalfreq
			FALSE if could not get the crystal frequency

    Remarks:            Gets the crystal frequency from the Bird via the
			Examine CMD function 2.
*/
int getcrystalfreq()
{
	short i;
    short j;
    unsigned char parameter[2];
    static unsigned char birdgetcrystalcmd[] = {'O',2};

    /* clear Bird output buffer */
#ifdef DOS
    if (interface == ISA_BUS)
       bird_clearoutputbuffer_isa();
#endif
    /*
	Send the Command to the Bird
    */

    if (send_cmd(birdgetcrystalcmd,2) != 2)
	return(FALSE);

    if (interface == RS232)
    /*
	Get the 2 byte response
    */
    {
       for (i=0; i<2; i++)
       {
	      j = waitforchar();
	      if (j < 0)
	      {
			printf("**ERROR** could not read data back from the Bird\n\r");
	        return(FALSE);
	      }
          parameter[i] = (unsigned char)(j);
       }
    /*
	Set the crystal frequency variable
    */
    crystalfreq = parameter[0];
    }
#ifdef DOS
    else /* ISA */
    /*
	Set the crystal frequency variable
    */
       crystalfreq  = (unsigned char)(waitforword());
#endif
    return(TRUE);
}

/*
    getaddrmode         Get the current Addressing Mode

    Prototype in:       cmdutil.h

    Parameters Passed:  void

    Return Value:       30 if in Expanded Address Mode
			14 if in Normal Address Mode
			FALSE if an Error Occurs

    Remarks:            The routine gets the Bird Status from the Master
			and uses bit 12 to determine if the flock is in
			expanded address mode
*/
int getaddrmode()
{
	short i;
    long rxword;
    short rxchar;
    unsigned char parameter[2];
    static unsigned char birdgetaddrmodecmd[] = {'O',0};
    unsigned char temp_char;

    /* clear Bird output buffer */
#ifdef DOS
    if (interface == ISA_BUS)
       bird_clearoutputbuffer_isa();
#endif

    /*
       Send the Examine Value Comand with Parameter 0 and wait for a 2
       byte response
    */
    printf("Checking System Status...");
    if (send_cmd(birdgetaddrmodecmd,2) !=2)
	return(FALSE);

    if (interface == RS232)
    {
       /*
	   Get the 2 byte response
       */
       for (i=0; i<2; i++)
       {
	      rxchar = waitforchar();
	      parameter[i] = (unsigned char) rxchar;
	      if (rxchar < 0)
	      {
	         printf("** ERROR ** could not read Bird Status\n\r");
	         hitkeycontinue();
	         return(FALSE);
	      }
       }
       temp_char = parameter[1]; /* get the byte with the addr mode bit */
   }
#ifdef DOS
   else     /* ISA interface */
   {
       /* Get 1 word response */
	   rxword = waitforword();
	   parameter[0] = (unsigned char) ((rxword & 0Xff00) >> 8);
	   parameter[1] = (unsigned char) (rxword & 0Xff);
	      if (rxword < 0)
	      {
	         printf("** ERROR ** could not read Bird Status\n\r");
	         hitkeycontinue();
	         return(FALSE);
	      }
       temp_char = parameter[0]; /* get the byte with the addr mode bit */

   }
#endif
    /*
	Assume a normal addressing mode
    */
    numfbbaddrs = 14;

    /*
       Check bit 12 in the Status Word...or bit 2 in the second byte
       and return the proper value  
       
       ALSO check the global parameter addressMode and enhancedModeFlag
       
    */   
    if(enhancedModeFlag)
    	{ 
    	switch(addressMode)
    		{
    		case 0: 
	       		printf ("\n\r...Flock is setup to the Normal Addressing Mode (Enhanced)\n\n\r");
	       		numfbbaddrs = 14;
	       		fbbaddrbits = 0x0f;
	       		cmdbitshft = 4;
	       		return(14);  
	       		break;
    			
    		case 1:
	       		printf ("\n\r...Flock is setup to the Expanded Addressing Mode (Enhanced)\n\n\r");
	       		numfbbaddrs = 30;
	       		fbbaddrbits = 0x1f;
	       		cmdbitshft = 5;
	       		return(30);
	       		break;
    		
    		case 3:
	       		printf ("\n\r...Flock is setup to the Super-Expanded Addressing Mode (Enhanced)\n\n\r");
	       		numfbbaddrs = 126;
	       		fbbaddrbits = 0x7f;
//	       		cmdbitshft = 5;
	       		return(126);
	       		break;
    		
    		case 2:
    		default:
                printf("ERROR - Unknown addressing mode");
                hitkeycontinue();  
                return(14);		/* assuming NORMAL addressing mode */
    			break;
    		}
    	}
    	
    else
    	{
	    if (temp_char & 0x04)
	    	{
	       	printf ("\n\r...Flock is setup to the Expanded Addressing Mode\n\n\r");
	       	numfbbaddrs = 30;
	       	fbbaddrbits = 0x1f;
	       	cmdbitshft = 5;
	       	return(30);
	    	}
	    else
	    	{
	       	printf ("\n\r...Flock is setup to the Normal Addressing Mode\n\n\r");
	       	numfbbaddrs = 14;
	       	fbbaddrbits = 0x0f;
	       	cmdbitshft = 4;
	       	return(14);
	    	} 
	    }
}

/*
    getsystemstatus     Get System Status

    Prototype in:       cmdutil.h

    Parameters Passed:  void

    Return Value:       TRUE if all goes OK
			FALSE if an Error Occurs

    Remarks:            Gets the System Status from the Bird
*/
int getsystemstatus()
{
	short i;
    short rxchar;
    long rxword;
    short temprs232tofbbaddr;
    static unsigned char birdgetsysstatuscmd[] = {'O', 36};

    /*
       Save the Current Address, but only send this command to
       the device we are connected to..DO NOT USE the RS232 To FBB Command
    */
    temprs232tofbbaddr = rs232tofbbaddr;
    rs232tofbbaddr = 0;

    /* clear Bird output buffer */
#ifdef DOS
    if (interface == ISA_BUS)
       bird_clearoutputbuffer_isa();
#endif

    /*
       Send the Examine Value Command with Parameter 36 and wait for a 14(30)(126)
       byte response
    */
    if (send_cmd(birdgetsysstatuscmd, 2) != 2)
    {
	rs232tofbbaddr = temprs232tofbbaddr;
	return(FALSE);
    }

    if (interface == RS232)
    {
       /*
	   Get the 14 or 30 OR 126 byte response
       */
       for (i=1; i<=numfbbaddrs; i++)
       {
	      rxchar = waitforchar();
	      if (rxchar < 0)
	      {
	         rs232tofbbaddr = temprs232tofbbaddr;
	         printf("** ERROR ** could not read Bird Status\n\r");
	         hitkeycontinue();
	         return(FALSE);
	      }
	      else
	      {
	         fbbsystemstatus[i] = (unsigned char) rxchar;
	      }
       }
    }
#ifdef DOS
    else       /* ISA interface */
    {
       /*
	   Get the 7 or 15 (OR 63) word response = 14 or 30 bytes   OR 126 BYTES
       */
       for (i=1; i<=numfbbaddrs; i = i+2)
       {
	      rxword = waitforword();
	      if (rxword < 0)
	      {
	         rs232tofbbaddr = temprs232tofbbaddr;
	         printf("** ERROR ** could not read Bird Status\n\r");
	         hitkeycontinue();
	         return(FALSE);
	      }
	      else
	      {
	         fbbsystemstatus[i+0] = (unsigned char) ((rxword & 0xFF00) >> 8);
	         fbbsystemstatus[i+1] = (unsigned char) ((rxword & 0x00FF) >> 0);
	      }
       }

    }
#endif

    /*
	Go through the List and Fill in the number of receivers
	and the start and stop addresses of currently Running Devices
    */
    numfbbrcvrs = 0;
    displayliststartaddr = 199; /* Start with a illegal and High value */
    displayliststopaddr = 1;
    for (i=1; i<=numfbbaddrs; i++)
    {
	if (fbbsystemstatus[i] & 0x40)  /* Device is Running */
	{
	    /*
		On the First time through setup the start address
		..rs232tofbbstartaddr was initialized to 99
	    */
	    if (rs232tofbbstartaddr > 30)
		if (i < rs232tofbbstartaddr)
		    rs232tofbbstartaddr = (unsigned int)(i);

	    if (fbbsystemstatus[i] & 0x20)  /* Device has a receiver */
	    {
		if (i < displayliststartaddr)
		   displayliststartaddr = (unsigned int)(i);

		displayliststopaddr = (unsigned int)(i);
		numfbbrcvrs++;
	    }
	}
    }

    rs232tofbbaddr = temprs232tofbbaddr;
    return(TRUE);
}

/*
    displayerror        Display the Current Error Status

    Prototype in:       cmdutil.h

    Parameters Passed:  errnum - Error Code
			exterrnum - Expanded Error Code

    Return Value:       void


    Remarks:
*/
void displayerror(errnum,exterrnum,displayexpinfo)
unsigned char errnum;
unsigned char exterrnum;
unsigned char displayexpinfo;
{
    /*
       Display the Error Number
    */
    printf ("\n\rError Code is %u (decimal) ",(unsigned char) errnum);

    /*
       Display a message describing the Error
    */
    switch (errnum)
    {
	case 0:
	    printf("...No Errors Have Occurred");
	    break;

	case 1:
	    printf("...System RAM Test Error");
	    break;

	case 2:
	    printf("...Non-Volatile Storage Write Failure");
	    break;

	case 3:
	    printf("...System EEPROM Configuration Corrupt");
	    break;

	case 4:
	    printf("...Transmitter EEPROM Configuration Corrupt");
	    break;

	case 5:
	    printf("...Receiver EEPROM Configuration Corrupt");
	    break;

	case 6:
	    printf("...Invalid Command");
	    break;

	case 7:
	    printf("...Not an FBB Master");
	    break;

	case 8:
	    printf("...No 6DFOBs are Active");
	    break;

	case 9:
	    printf("...6DFOB has not been Initialized");
	    break;

	case 10:
	    printf("...FBB Receive Error - Intra Bird Bus");
	    break;

	case 11:
	    printf("...RS232 Overrun and/or Framing Error");
	    break;

	case 12:
	    printf("...FBB Receive Error - FBB Host Bus");
	    break;

	case 13:
	    printf("...No FBB Command Response from Device at address %d",exterrnum & fbbaddrbits);
	    if (displayexpinfo)
	    {
	      printf ("\n\rExpanded Error Code Address is %u (decimal)",exterrnum & fbbaddrbits);
	      printf ("\n\rExpanded Error Code Command is %u (decimal)\n\r",(unsigned char) ((exterrnum & ~fbbaddrbits) >> cmdbitshft));
	    }

	    break;

	case 14:
	    printf("...Invalid FBB Host Command");
	    break;

	case 15:
	    printf("...FBB Run Time Error");
	    break;

	case 16:
	    printf("...Invalid CPU Speed");
	    break;

	case 17:
	    printf("...Slave No Data Error");
	    break;

	case 18:
	    printf("...Illegal Baud Rate");
	    break;

	case 19:
	    printf("...Slave Acknowledge Error");
	    break;

	case 20:
	    printf("...CPU Overflow Error - call factory");
	    break;

	case 21:
	    printf("...Array Bounds Error - call factory");
	    break;

	case 22:
	    printf("...Unused Opcode Error - call factory");
	    break;

	case 23:
	    printf("...Escape Opcode Error - call factory");
	    break;

	case 24:
	    printf("...Reserved Int 9 - call factory");
	    break;

	case 25:
	    printf("...Reserved Int 10 - call factory");
	    break;

	case 26:
	    printf("...Reserved Int 11 - call factory");
	    break;

	case 27:
	    printf("...Numeric CPU Error - call factory");
	    break;

	case 28:
	    printf("...CRT Syncronization Error");
	    break;

	case 29:
	    printf("...Transmitter Not Active Error");
	    break;

	case 30:
	    printf("...ERC Extended Range Transmitter Not Attached Error");
	    break;

	case 31:
	    printf("...CPU Time Overflow Error");
	    break;

	case 32:
	    printf("...Receiver Saturated Error");
	    break;

	case 33:
	    printf("...Slave Configuration Error");
	    break;

	case 34:
	    printf("...ERC Watchdog Error");
	    break;

	case 35:
	    printf("...ERC Overtemp Error");
	    break;

	default:
	    printf("...UNKNOWN ERROR... check user manual");
	    break;
    }

    return;
}


/*
    set_system_isa_protocol() - Initiates the ISA protocol for
                                each unit in the system through
                                Examine Parameter0 (Status) of each unit.

    Prototype in:       cmdutil.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            The routine gets from the user the base
                        addresses of all units and Examines their statuses.
*/
#ifdef DOS
void set_system_isa_protocol(void)
{
   short unsigned i;
   int addr, temp_int;
   static unsigned char birdgetcrystalcmd[] = {'O',2};
   unsigned short isa_base_addr_temp;
   unsigned short isa_status_addr_temp;
   /*
      if start and stop addresses are not initialized properly then
      can't do anything but return
   */
   if (displayliststartaddr > displayliststopaddr)
   {
      printf("\n\n\r*** ERROR *** System lowest and highest addresses are not initialized properly\n\r");
      /*
	   Wait for the user to read the error message
      */
      hitkeycontinue();
      return;
   }
   /*
   Save Master Base address
   */
   isa_base_addr_temp = isa_base_addr;
   isa_status_addr_temp = isa_status_addr;

   /* clear screen */
   CLEARSCREEN;

   /* Move Cursor to the Top of the Screen */
   SETTEXTPOS(1,1);
   printf("\n\rAssume following ISA base addresses of the units in the system.\n\r\
If correct, hit <ENTER>. If wrong, enter the correct hexadecimal value.\n\n\r");


   /*
      Get the base address from the user.
      Send Examine Parameter 2 (Crystal Frequency) Command
      Read the data back.
   */

   for (i = displayliststartaddr; i <= displayliststopaddr; i++)
   {
      printf("\n\rUnit # %d. Base address is %3Xhex.   ",i,isa_base_addr_temp + 4 * (i-1));
      addr = gethexnumber();  /* get the address */

      if (addr == ESC_SEL)    /* if user hits ESC or RETURN on nothing, then assune default */
         addr = isa_base_addr + 4 * (i-1);

      /*
         check if it's valid base address: 0...3FC in steps of 4
      */
      if ((addr & 0x3FC) == addr)  /* if valid address then try to send cmd and read the data */
      {
        /* get the slave isa addresses */
        isa_base_addr = addr;
        isa_status_addr = isa_base_addr + 2;
        if (send_cmd(birdgetcrystalcmd,2) != 2)  /* send get crystal frequency cmd */
        {
           printf("\n\r*** ERROR *** Failed to send command to device at base address %3Xhex \n\r",isa_base_addr);
           /*
	        Wait for the user to read the error message
           */
           hitkeycontinue();
           isa_base_addr = isa_base_addr_temp;
           isa_status_addr = isa_status_addr_temp;
	       return;
        }

        /*
         Command came out OK. Read the data*/
        temp_int = (int)(waitforword());
        if (temp_int < 0 )  /* if no valid data came back */
        {
           printf("\n\r*** ERROR *** Failed to read data from Device at base address %3Xhex \n\r",isa_base_addr);
           /*
	        Wait for the user to read the error message
           */
           hitkeycontinue();
           isa_base_addr = isa_base_addr_temp;
           isa_status_addr = isa_status_addr_temp;
	       return;
        }
      }
      else /* invalid base address */
      {
         printf("\n\r*** ERROR *** %3Xhex is invalid address.",addr);
         --i;            /* decrement i to try last unit address again */
      }
   }
   /* all done. Restore Master addresses */
   isa_base_addr = isa_base_addr_temp;
   isa_status_addr = isa_status_addr_temp;
   return;
}
#endif
short endian(short *sptr)
{
	unsigned char *cptr;

	cptr = (unsigned char *)sptr;
	if (little_endian)
		return((((short)*cptr) << 8) | *(cptr + 1));
	else
		return((((short)*(cptr+1)) << 8) | *cptr);
}		
		

