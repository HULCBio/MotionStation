/****************************************************************************
*****************************************************************************
    sercmds        - Bird Serial Command Routines

    written for:    Ascension Technology Corporation
		    PO Box 527
		    Burlington, Vermont  05402
		    802-860-6440

    by:             Vlad Kogan


    Modification History:
1/12/96  vk..released
2/23/96  vk..bird_anglealign_serial() renamed to bird_anglealign_sincos_serial() to
		 indicate that the SIN and COS of angles are passed to the bird.
		 - new bird_anglealign_serial() added to pass angles (not SIN, COS) to the Bird.
         - bird_referframe_serial() renamed to bird_referframe_sincos_serial() to
		 indicate that the SIN and COS of angles are passed to the bird.
		 - new bird_referframe_serial() added to pass angles (not SIN, COS) to the Bird.
2/27/96  vk..bird_changevalue_serial(), bird_examinevalue_serial() changed
		 to implement CHANGE/EXAMINE PARAMETER 7 (Measurement Rate) Command.

	   <<<< Copyright 1996 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <math.h>           /* trig math funcs */
#include "asctech.h"        /* general definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "menu.h"           /* for menus */
#include "serial.h"         /* serial I/O */
#include "cmdutil.h"        /* command utilities */
#include "sercmds.h"
#include "iface.h"          /* Interface Functions Prototypes */

/***********************
    Globals
***********************/

/*
    External Varibles
*/
extern FILE * datafilestream;
extern unsigned char displaymultidataflg;
extern short numfbbaddrs;



/************************
    Routines
************************/

/*
    bird_anglealign_sincos_serial  - Sends the ANGLE ALIGN command
                                  through the serial port.
                                  This is an old version of the Command, which
                                  passes sines, cosines of alignment angles
                                  as a comand data.

    Prototype in:       sercmds.h

    Parameters Passed:  azim,elev,roll angles IN DEGREES
			            to align the receiver in the user specified direction

    Return Value:       TRUE if successful
			            FALSE otherwise

    Remarks:            ANGLE ALIGN COMMAND = 'J' = 4Ahex = 74dec
			            Command Data:    Sin(azim)  Cos(azim)
					 					 Sin(elev)  Cos(elev)
					 					 Sin(roll)  Cos(roll)
	NOTE: this function is not called anywhere in cbird. Newer and simplier
		  function bird_anglealign_serial is being used for sensor alignment.
*/

int bird_anglealign_sincos_serial(float azim, float elev, float roll)
{

    short i;                											/* matrix pointer 				*/
    unsigned char * cdataptr;        									/* pointer to cdata 			*/
    double tempfloat;        											/* temporary float value 		*/
    double angle[3];         											/* angles input byte the user 	*/
    static unsigned char cdata[] =   {'J',0,0,0,0,0,0,0,0,0,0,0,0}; 	/* cmd + 12 bytes 				*/

    /*
	Get the array of 3 angles from what the User sent
    */
    angle[0] = azim;
    angle[1] = elev;
    angle[2] = roll;

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

    return(TRUE);
}

/*
    bird_anglealign_serial - Sends the ANGLE ALIGN command through serial port

    Prototype in:    	   sercmds.h

    Parameters Passed:  azim,elev,roll angles IN DEGREES
						to align the receiver in the user specified direction

    Return Value:       TRUE if successful
						FALSE otherwise

    Remarks:            ANGLE ALIGN COMMAND = 'q' = 71hex = 113dec
					 	Command Data:    azim, elev, roll
*/

int bird_anglealign_serial(float azim, float elev, float roll)
{
    int angle[3];                    /* array to store azim,elev,roll */
    unsigned short i;                /* index to the array of angles */
    unsigned char * cdataptr;        /* pointer to cdata */
//    float tempfloat;                 /* temporary float value */
    static unsigned char cdata[] =   {'q',0,0,0,0,0,0}; /* cmd + 6 bytes */

    /*
    Form the array of 3 angles for convenience.
    Convert angles to the integers. Full scale = 180 deg
    */
    angle[0] =  (int)(azim * ANG_TO_INT);
    angle[1] =  (int)(elev * ANG_TO_INT);
    angle[2] =  (int)(roll * ANG_TO_INT);
    cdataptr = &cdata[1];           /* assign pointer to the first character
						            after the command character
						            */
    /*
	construct the command string
    */
    for(i = 0; i < 3; i++ )
    {
	    *cdataptr++ = (unsigned char) (angle[i] & 0x0ff);
	    *cdataptr++ = (unsigned char) ((angle[i] & 0x0ff00) >> 8);
    }

    /*
	Send the Command
    */
    if (send_serial_cmd(cdata,7) != 7)
	return(FALSE);

    return(TRUE);
}

/*
    bird_hemisphere_serial  -   Set the Birds Hemisphere

    Prototype in:       sercmds.h

    Parameters Passed:  hemisphere

    Return Value:       TRUE if successful
			FALSE if unsuccessful
			ESC_SEL if ESC selected

    Remarks:
*/
int bird_hemisphere_serial(hemisphere)
int hemisphere;
{
    static unsigned char hemisphere_cdata[] = {'L',0,0};  /* command string
							     to BIRD */

    /*
	Send the Menu to the User
    */
    switch (hemisphere)
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

    }
    /*
	Send the Command
    */
    if (send_serial_cmd(hemisphere_cdata,3) != 3)
	return(FALSE);
    return(TRUE);
}


/*
    bird_referframe_sincos_serial -   Define a new Bird Reference Frame

    Prototype in:       sercmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE otherwise

    Remarks:            REFERENCE FRAME COMMAND = 'H' = 48hex = 72dec
			            Command Data:    Sin(azim)  Cos(azim)
					 					 Sin(elev)  Cos(elev)
					 					 Sin(roll)  Cos(roll)
	NOTE: this function is not called anywhere in cbird. Newer and simplier
		  function bird_referframe_serial is being used to define reference frame.
*/

int bird_referframe_sincos_serial(float azim, float elev, float roll)
{
    static unsigned char referframe_cdata[] =
			{'H',0,0,0,0,0,0,0,0,0,0,0,0};  /* the cmd */
    unsigned char * cdataptr = &referframe_cdata[1];
    short i;
    double tempfloat;
    double angle[3];     /* holds the floating point angles */

    /*
	Get the array of 3 angles from what the User sent
    */
    angle[0] = azim;
    angle[1] = elev;
    angle[2] = roll;


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
    return(TRUE);
}
/*
    bird_referframe_serial  - Sends the REFERENCE FRAME command through
							  the serial port

    Prototype in:    	   sercmds.h

    Parameters Passed:  azim,elev,roll angles IN DEGREES
						to define new reference frame

    Return Value:       TRUE if successful
						FALSE otherwise

    Remarks:            ANGLE ALIGN COMMAND = 'r' = 72hex = 114dec
					 	Command Data:    azim, elev, roll
*/

int bird_referframe_serial(float azim, float elev, float roll)
{
    int angle[3];                    /* array to store azim,elev,roll */
    unsigned short i;                /* index to the array of angles */
    unsigned char * cdataptr;        /* pointer to cdata */
    static unsigned char cdata[] =   {'r',0,0,0,0,0,0}; /* cmd + 6 bytes */

    /*
    Form the array of 3 angles for convenience.
    Convert angles to the integers. Full scale = 180 deg
    */
    angle[0] =  (int)(azim * ANG_TO_INT);
    angle[1] =  (int)(elev * ANG_TO_INT);
    angle[2] =  (int)(roll * ANG_TO_INT);
    cdataptr = &cdata[1];           /* assign pointer to the first character
						            after the command character
						            */
    /*
	construct the command string
    */
    for(i = 0; i < 3; i++ )
    {
	    *cdataptr++ = (unsigned char) (angle[i] & 0x0ff);
	    *cdataptr++ = (unsigned char) ((angle[i] & 0x0ff00) >> 8);
    }

    /*
	Send the Command
    */
    if (send_serial_cmd(cdata,7) != 7)
	return(FALSE);

    return(TRUE);
}

/*
    bird_reportrate_serial -   Select the Report Rate for Stream Mode

    Prototype in:       sercmds.h

    Parameters Passed:  rate

    Return Value:       TRUE if successful
			FALSE if unsuccessful
			ESC_SEL if user selected ESC

    Remarks:
*/
int bird_reportrate_serial(unsigned char rate_cdata)
{

    /*
	Send of the 1 char
    */
    if (send_serial_cmd(&rate_cdata,1) != 1)
	return(FALSE);

    return(TRUE);
}

/*
    bird_sleep_serial  -   Implements the Sleep ('G') command

    Prototype in:       sercmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessfull

    Remarks:
*/
int bird_sleep_serial()
{
    static unsigned char sleep_cdata = 'G';


    /*
	Send the command
    */
    if (send_serial_cmd(&sleep_cdata,1) != 1)
	return(FALSE);
    return(TRUE);
}
/*
    bird_wakeup_serial  -   Implements the Wake ('F') command

    Prototype in:       sercmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessfull

    Remarks:
*/
int bird_wakeup_serial()
{
    static unsigned char wakeup_cdata = 'F';

    /*
	Send the command
    */
    if (send_serial_cmd(&wakeup_cdata,1) != 1)
	return(FALSE);
    return(TRUE);
}

/*
    bird_buttonmode_serial   -   Implements the M mouse button command

    Prototype in:       sercmds.h

    Parameters Passed:  void

    Return Value:       TRUE if passed
                        otherwise FALSE

    Remarks:
*/
int bird_buttonmode_serial(short buttonmode)
{
    static unsigned char button_cdata[] = {'M',0};  /* button command */

    button_cdata[1] = (unsigned char) buttonmode;

    /*
	Send Button Command
    */
    if (send_serial_cmd(button_cdata,2) != 2)   /* send the button cmd */
	return(FALSE);
    return(TRUE);
}

/*
    bird_buttonread_serial   -   Implements the N mouse button command

    Prototype in:       sercmds.h

    Parameters Passed:  void

    Return Value:       TRUE if passed
                        otherwise FALSE

    Remarks:
*/
int bird_buttonread_serial(void)
{
    static unsigned char button_cdata[] = {'N'};  /* button command */

    /*
    Send Read Button Command
	*/
	if (send_serial_cmd(button_cdata,1) != 1)
  	   return(FALSE);
	return(TRUE);
}

/*
    bird_xonxoff_serial  - Implements the XON / XOFF commands

    Prototype in:       sercmds.h

    Parameters Passed:  XON/XOFF parameter

    Return Value:       TRUE if sent XON or XOFF
			FALSE if could not send the command

    Remarks:            sends down the XON or XOFF command to the BIRD
*/
int bird_xonxoff_serial(birdflowcmd)
unsigned char birdflowcmd;
{

    /*
	Send the command to the Bird
    */
    if (send_serial_cmd(&birdflowcmd,1) != 1)
       return(FALSE);
    return(TRUE);
}
/*
    bird_changevalue_serial   - Sends the Change Value Commmand to the BIRD

    Prototype in:       sercmds.h

    Parameters Passed:  parameter_number - integer number of the parameter
 			            parameter_data_ptr - pointer to the data to be sent to
					    change parameter

    Return Value:       TRUE if Command was sent to the BIRD
				        FALSE if could not send the command
			            ILLEGAL_PARAMETER_VALUE if illegal parameter#

    Remarks:            CHANGE VALUE Command = 'P' = 50hex = 80dec
			            CHANGE VALUE Command Data = parameter_number
*/
int bird_changevalue_serial(parameter_number, parameter_data_ptr)
int parameter_number;
unsigned char * parameter_data_ptr;

{
    short tempaddr;
    short i;
    short cmdsize;

    /*
    size of the spadchangevaluecmd array set to the longest strings
    Parameter5, Parameter12, Parameter13
    */
    static unsigned char spadchangevaluecmd[] = {'P',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    static short change_value_cmdsize[51] = {
    ILLEGAL_PARAMETER_VALUE, /* Parameter00 SYSTEM STATUS (NONCHANGEable)		*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter01 SOFTWARE REV# (NONCHANGEable)		*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter02 CRYSTAL SPEED (NONCHANGEable)		*/
    4,                       /* Parameter03, Range Scale                		*/
    4,                       /* Parameter04 Filter ON/OFF Status        		*/
    16,                      /* Parameter05 DC FILTER Constant ALPHA_MIN		*/
    4,                       /* Parameter06, Measurement Rate Counter   		*/
    4,                       /* Parameter07, Measurement Rate           		*/
    3,                       /* Parameter08, Send Data Ready            		*/
    3,                       /* Parameter09, Data Ready Character       		*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter10 ERROR CODE (NONCHANGEable) 			*/
    3,                       /* Parameter11,Set Error Detect Mask      			*/
    16,                      /* Parameter12 DC FILTER Constant Vm      			*/
    16,                      /* Parameter13 DC FILTER Constant ALPHA_MAX		*/
    3,                       /* Parameter14,Sudden Output Change Ellimination 	*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter15 SYSTEM MODEL (NONCHANGEable)		*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter16, Not used                  			*/
    3,                       /* Parameter17 XYZ REFERENCE FRAME        			*/
    3, 						 /* Parameter18, Transmitter Mode          			*/
    3, 						 /* Parameter19, Address Mode              			*/
    3, 						 /* Parameter20, Line Frequency            			*/
    3, 						 /* Parameter21, FBB Address               			*/
    4,						 /* Parameter22, Hemisphere                			*/
    8,						 /* Parameter23, Angle Align 2             			*/
    8,						 /* Parameter24, Reference Frame 2         			*/
    4,						 /* Parameter25, Bird Serial Number        			*/
    4,             /* Parameter26, Sensor Serial Number        	  */
    4,             /* Parameter27, Xmtr Serial Number     			  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter28, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter29, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter30, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter31, Not used                  			*/
    4,                       /* Parameter32, FBB Response Delay        			*/
    7,                       /* Parameter33 CONFIGURATION              			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter34, Not used                  			*/
    3,                       /* Parameter35 GROUP MODE                 			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter36, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter37, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter38, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter39, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter40, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter41, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter42, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter43, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter44, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter45, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter46, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter47, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter48, Not used                  			*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter49, Not used                  			*/
    3,                       /* Parameter50, Auto-Configuration        			*/
    };

    /*
    Set the command size as a functioin of the parameter #.
    */
    if ((cmdsize = change_value_cmdsize[parameter_number]) == ILLEGAL_PARAMETER_VALUE)
	 return(ILLEGAL_PARAMETER_VALUE);  /* Return if it is illegal
					   parameter number to change value
					   */

    /*
	Store the receiver address as it is modified by parameters 35,50
    */
    tempaddr = rs232tofbbaddr;

    switch(parameter_number)
    {
    case 35: /* GROUP MODE    */
        rs232tofbbaddr = 0; /* Command goes with out any address preface */
    case 50: /* Auto-Configuration */
    /*
	Preset the RS232 to Destination address to 1 for
	this command if the RS232 to FBB command is active
	*/
	if (rs232tofbbaddr != 0)
		 rs232tofbbaddr = 1;
    }

    /*
    Build the Command String into the spadchangevaluecmd[] array.
    The 1st character of the string has been initialized to
    CHANGE VALUE COMMAND = 'P'. Put the Parameter Number
    and Parameter Data after that 'P'.
    */

    /*
    Put the parameter number to the command string ritgh after
    CHANGE VALUE COMMAND = 'P'
    */
    spadchangevaluecmd[1] = parameter_number;

    /*
    put the parameter data right after the parameter number
    */
    for(i = 2; i < cmdsize; i++)
	spadchangevaluecmd[i] = *(parameter_data_ptr++);

    /*
	Send the Command
    */
    if (send_serial_cmd(spadchangevaluecmd,cmdsize) != cmdsize)
    {
	rs232tofbbaddr = tempaddr;  /* Restore the receiver address before return */
	return(FALSE);
    }

    /*
	Restore the receiver address
    */
    rs232tofbbaddr = tempaddr;
    return(TRUE);
}

/*
    bird_examinevalue_serial  - Sends the Examine Value Commmand to the BIRD
                                and gets the response
    Prototype in:       sercmds.h

    Parameters Passed:  parameter_number - integer number of the parameter
			            examine_value_data_ptr - pointer to store the data
						from the BIRD

    Return Value:       TRUE if Command was sent to the BIRD and data received
			FALSE if could not send the command or read the data
			ILLEGAL_PARAMETER_VALUE if illegal parameter#

    Remarks:            EXAMINE VALUE Command = 'O' = 4Fhex = 79dec
			EXAMINE VALUE Command Data = parameter_number
*/
int bird_examinevalue_serial(parameter_number,examine_value_data_ptr)
int parameter_number;
unsigned char * examine_value_data_ptr;
{
    short i;
    short response_size;
    short rxchar;
    static unsigned char spadexaminevaluecmd[] = {'O',0};
    static short examine_value_response[51] = {
    2,                       /* Parameter0 SYSTEM STATUS               */
    2,                       /* Parameter1 SOFTWARE REV#               */
    2,                       /* Parameter2 CRYSTAL SPEED               */
    2,                       /* Parameter3 POSITION SCALING            */
    2,                       /* Parameter4 Filter ON/OFF Status        */
    14,                      /* Parameter5 DC FILTER Constant ALPHA_MIN*/
    2,                       /* Parameter6 MEASUREMENT RATE COUNTER    */
    2,                       /* Parameter7 MEASUREMENT RATE            */
    1,                       /* Parameter8 DATA READY                  */
    1,                       /* Parameter9 DATA READY CHARACTER        */
    1,                       /* Parameter10 ERROR CODE                 */
    1,                       /* Parameter11 ERROR MASK                 */
    14,                      /* Parameter12 DC FILTER Constant Vm      */
    14,                      /* Parameter13 DC FILTER Constant ALPHA_MAX*/
    1,                       /* Parameter14 SUDDEN OUTPUT CHANGE ELLIMINATION */
    10,                      /* Parameter15 SYSTEM MODEL               */
    2,                       /* Parameter16 EXPANDED ERROR CODE        */
    1,                       /* Parameter17 XYZ REFERENCE FRAME        */
    1, 						 /* Parameter18 Transmitter Mode           */
    1, 						 /* Parameter19 Address Mode               */
    1, 						 /* Parameter20 Line Frequency             */
    1, 						 /* Parameter21 FBB Address                */
    2,						 /* Parameter22 Hemisphere			           */
    6, 						 /* Parameter23 Angle Align 2		           */
    6,						 /* Parameter24 Reference Frame 2   		   */
    2,						 /* Parameter25 Bird Serial Number	       */
    2,             /* Parameter26 Sensor Serial Number       */
    2,             /* Parameter27 Xmtr Serial Number         */
    ILLEGAL_PARAMETER_VALUE, /* Parameter28, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter29, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter30, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter31, Not used                  */
    2,                       /* Parameter32 FBB HOST DELAY             */
    5,                       /* Parameter33 CONFIGURATION              */
    ILLEGAL_PARAMETER_VALUE, /* Parameter34, Not used                  */
    1,                       /* Parameter35 GROUP MODE                 */
    14,                      /* Parameter36 FLOCK SYSTEM STATUS        */
    ILLEGAL_PARAMETER_VALUE, /* Parameter37, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter38, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter39, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter40, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter41, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter42, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter43, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter44, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter45, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter46, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter47, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter48, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter49, Not used                  */
    5,                       /* Parameter50, AUTO-CONFIGURATION        */
    };

    /*
    Set the response size in bytes as a function of the parameter #.
    */
    if((response_size = examine_value_response[parameter_number]) == ILLEGAL_PARAMETER_VALUE)
       return(ILLEGAL_PARAMETER_VALUE);   /* Return if it is illegal
					   parameter number to examine value of
					   */

	   /*
		Update the Response size for the FBB CONFIG,
		FBB AUTOCONFIG and the FBB SYSTEM STATUS
	   */
	   if ((parameter_number == 33) && (numfbbaddrs != 14)) /* CONFIGURATION */
		     response_size = 7;
	   if ((parameter_number == 36) && (numfbbaddrs != 14)) /* SYSTEM STATUS */
		     response_size = 30;
	   if ((parameter_number == 50) && (numfbbaddrs != 14)) /* AUTO-CONFIGURATION */
		     response_size = 7;

    /*
    Build the Command String into the spadexaminevaluecmd[] array.
    The 1st character of the string has been initialized to
    EXAMINe VALUE COMMAND = 'O'. Put the Parameter Number
    after that 'O'.
    */

    spadexaminevaluecmd[1] = (unsigned char) parameter_number;

	/*
	    Send the command
	*/
	if (send_serial_cmd(spadexaminevaluecmd,2) != 2)
	    return(FALSE);

	/*
	Get the n byte response
	*/
	for (i=0; i< response_size; i++)
		{
	   	rxchar = waitforchar();
	   	*(examine_value_data_ptr++) = (unsigned char) rxchar;
	   	if (rxchar < 0)
		  	return(FALSE);
		}
	return(TRUE);
}

/*
    bird_crtsync_serial - Implements the CRT SYNC command

    Prototype in:       sercmds.h

    Parameters Passed:  birdcrtsyncmode - CRT sync mode,
                        pointer birdcrtsyncdata to store the data (if any)

    Return Value:       TRUE if a command was executed
			FALSE if command could not be executed
			ESC_SEL if the user selected escape

    Remarks:
*/
int bird_crtsync_serial(birdcrtsyncmode, birdcrtsyncdata)
unsigned char birdcrtsyncmode;
unsigned char * birdcrtsyncdata;
{
    short i;
    short rxchar;
    static unsigned char birdcrtsynccmd[] = {'A',0};

    /*
	Set the Command data
    */
    birdcrtsynccmd[1] = birdcrtsyncmode;

    /*
    Send the Command
	*/
	if (send_serial_cmd(birdcrtsynccmd,2) != 2)
		return(FALSE);

    if (birdcrtsyncmode == 255)
	{
    	/*
		    Get the 4 byte response response
		*/
		for (i=0; i<4; i++)
		{
		    rxchar = waitforchar();
		    * (birdcrtsyncdata++) = (unsigned char) rxchar;
		    if (rxchar < 0)
			   return(FALSE);
		}
    }
    return(TRUE);
}

/*
    bird_nextmaster_serial - Next Master Command

    Prototype in:            sercmds.c

    Parameters Passed:       int nextmaster

    Return Value:       TRUE if command sent OK
			FALSE if command could not be sent
			ESCSEL if the user selected ESC

    Remarks:
*/
int bird_nextmaster_serial(int nextmaster)
{
    unsigned char nextmaster_cmd;

	nextmaster_cmd = (unsigned char) nextmaster + '0';

	    if (send_serial_cmd(&nextmaster_cmd,1) != 1)
 		   return(FALSE);
		return(TRUE);
}


/*
    bird_nextxmtr_serial - Next Transmitter Command

    Prototype in:          sercmds.c

    Parameters Passed:     int nextxmtradress, int nextxmtrnum

    Return Value:       TRUE if command sent OK
			FALSE if command could not be sent

    Remarks:
*/
int bird_nextxmtr_serial(int nextxmtraddr, int nextxmtrnum)
{
    static unsigned char nextxmtr_cmd[2] = {'0',0};

	nextxmtr_cmd[1] = (unsigned char) nextxmtraddr << 4;
	nextxmtr_cmd[1] |= (unsigned char) nextxmtrnum;

    if (send_serial_cmd(nextxmtr_cmd,2) != 2)
	   return(FALSE);
    return(TRUE);
}


