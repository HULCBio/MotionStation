/****************************************************************************
*****************************************************************************
    isacmds         - BIRD Command Routines sent through ISA

    written for:    Ascension Technology Corporation
		    PO Box 527
		    Burlington, Vermont  05402
		    802-860-6440

    by:     Vlad Kogan


    Modification History:
1/12/96  vk..released
2/23/96  vk..bird_anglealign_isa() renamed to bird_anglealign_sincos_isa() to
		 indicate that the SIN and COS of angles are passed to the bird.
		 - new bird_anglealign_isa() added to pass angles (not SIN, COS) to the Bird.
         - bird_referframe_isa() renamed to bird_referframe_sincos_isa() to
		 indicate that the SIN and COS of angles are passed to the bird.
		 - new bird_referframe_isa() added to pass angles (not SIN, COS) to the Bird.
2/27/96  vk..bird_changevalue_isa(), bird_examinevalue_isa() changed
		 to implement CHANGE/EXAMINE PARAMETER 7 (Measurement Rate) Command.
	   <<<< Copyright 1996 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <stdlib.h>          /* general I/O */
#include <math.h>           /* trig math funcs */  
#include <conio.h>
#include "asctech.h"        /* general definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "cmdutil.h"        /* command utilities */
#include "isacmds.h"
#include "menu.h"
#include "isadpcpl.h"        /* ISA bus I/O */
#include "pctimer.h"         /* Used to take over IRQ0 (PC TIMER) */

/*
    External Varibles
*/
extern short numfbbaddrs;
extern short data_rdy_output;          /* data ready character output */

/***********************
    Globals
***********************/

short datasize;              /* size of the output data record in words */



/************************
    Routines
************************/
/*
    bird_anglealign_sincos_isa  - Sends the ANGLE ALIGN command through ISA.
                                  This is an old version of the Command, which
                                  passes  sines, cosines of alignment angles
                                  as a comand data.

    Prototype in:       isacmds.h

    Parameters Passed:  azim,elev,roll angles IN DEGREES
			            to align the receiver in the user specified direction

    Return Value:       TRUE if successful
			            FALSE otherwise

    Remarks:            ANGLE ALIGN COMMAND = 'J' = 4Ahex = 74dec
			            Command Data:    Sin(azim)  Cos(azim)
					 					 Sin(elev)  Cos(elev)
					 					 Sin(roll)  Cos(roll)
	NOTE: this function is not called anywhere in cbird. Newer and simplier
		  function bird_anglealign_isa is being used for sensor alignment.
*/

int bird_anglealign_sincos_isa(float azim, float elev, float roll)
{
    double 					angle[3];                  					/* array to store azim,elev,roll 	*/
    unsigned short 			i;                							/* index to the array of angles 	*/
    unsigned char 			*cdataptr;        							/* pointer to cdata 				*/
    double 					tempfloat;                 					/* temporary float value 			*/
    static unsigned char 	cdata[] =   {'J',0,0,0,0,0,0,0,0,0,0,0,0}; 	/* cmd + 12 bytes 					*/

    /*
    Form the array of 3 angles for convenience
    */
    angle[0] =  azim;
    angle[1] =  elev;
    angle[2] =  roll;

    cdataptr = &cdata[1];           /* assign pointer to the first character
						       after the command character
						    */
    /*
	convert sines and cosines to configuration bytes in cdata[],
	constructing the command string as we go.
    */
    for(i = 0; i < 3; i++ )
    {
	/*
	    calculate the sine of the angle and
	*/
	tempfloat = sin((double)(angle[i] * DTR));

	/*
	    convert to a word and store in cdata
	    NOTE: trap for sin(90)...since the BIRD
	    can only accept data from -1.000 to 0.99996 (0x8000 to 0x7fff)
	*/
	if (tempfloat < 0.99998)
	{
	    *cdataptr++ = (unsigned char) (((short) (tempfloat * FTW) & 0x0ff00) >> 8);
	    *cdataptr++ = (unsigned char) ((short) (tempfloat * FTW) & 0x0ff);
	}
	else
	{
	    *cdataptr++ = 0x07f;
	    *cdataptr++ = 0x0ff;
	}

	/*
	    calculate the cosine of the angle and
	*/
	tempfloat = cos((double)(angle[i] * DTR));

	/*
	    convert to a word and store in cdata
	    NOTE: trap for cos(0)...since the SPACPAD
	    can only accept data from -1.000 to 0.99996 (0x8000 to 0x7fff)
	*/
	if (tempfloat < 0.99998)
	{
	    *cdataptr++ = (unsigned char) (((short) (tempfloat * FTW) & 0x0ff00) >> 8);
	    *cdataptr++ = (unsigned char) ((short) (tempfloat * FTW) & 0x0ff);
    }
	else
	{
	    *cdataptr++ = 0x07f;
	    *cdataptr++ = 0x0ff;
	}
    }

    /*
	Send the Command
    */
    if (send_isa_cmd(cdata,13) != 13)
	return(FALSE);

    return(TRUE);
}
/*
    bird_anglealign_isa     - Sends the ANGLE ALIGN command through ISA

    Prototype in:    	   isacmds.h

    Parameters Passed:  azim,elev,roll angles IN DEGREES
						to align the receiver in the user specified direction

    Return Value:       TRUE if successful
						FALSE otherwise

    Remarks:            ANGLE ALIGN COMMAND = 'q' = 71hex = 113dec
					 	Command Data:    azim, elev, roll
*/

int bird_anglealign_isa(float azim, float elev, float roll)
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
	    *cdataptr++ = (unsigned char) ((angle[i] & 0x0ff00) >> 8);
	    *cdataptr++ = (unsigned char) (angle[i] & 0x0ff);
    }

    /*
	Send the Command
    */
    if (send_isa_cmd(cdata,7) != 7)
	return(FALSE);

    return(TRUE);
}

/*
    bird_hemisphere_isa  -   Set the Birds Hemisphere

    Prototype in:       isacmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessful
			ESC_SEL if ESC selected

    Remarks:
*/
int bird_hemisphere_isa(hemisphere)
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
    if (send_isa_cmd(hemisphere_cdata,3) != 3)
	return(FALSE);
    return(TRUE);
}
/*
    bird_referframe_sincos_isa -   Define a new Bird Reference Frame

    Prototype in:       isacmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE otherwise

    Remarks:            REFERENCE FRAME COMMAND = 'H' = 48hex = 72dec
			            Command Data:    Sin(azim)  Cos(azim)
					 					 Sin(elev)  Cos(elev)
					 					 Sin(roll)  Cos(roll)
	NOTE: this function is not called anywhere in cbird. Newer and simplier
		  function bird_referframe_isa is being used to define reference frame.
*/
int bird_referframe_sincos_isa(float azim, float elev, float roll)
{
    static unsigned char 		referframe_cdata[] =
									{'H',0,0,0,0,0,0,0,0,0,0,0,0};  /* the cmd 							*/
    unsigned char 				*cdataptr = &referframe_cdata[1];
    short 						i;
    double 						tempfloat;
    double 						angle[3];     						/* holds the floating point angles 	*/

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
	    *cdataptr++ = (unsigned char) (((short) (tempfloat * FTW) & 0x0ff00) >> 8);
	    *cdataptr++ = (unsigned char) ((short) (tempfloat * FTW) & 0x0ff);
	}
	else
	{
	    *cdataptr++ = 0x07f;
	    *cdataptr++ = 0x0ff;
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
	    *cdataptr++ = (unsigned char) (((short) (tempfloat * FTW) & 0x0ff00) >> 8);
	    *cdataptr++ = (unsigned char) ((short) (tempfloat * FTW) & 0x0ff);
	}
	else
	{
	    *cdataptr++ = 0x07f;
	    *cdataptr++ = 0x0ff;
	}
    }

    /*
	Send the Command
    */
    if (send_isa_cmd(referframe_cdata,13) != 13)
	return(FALSE);
    return(TRUE);
}

/*
    bird_referframe_isa     - Sends the REFERENCE FRAME command through ISA

    Prototype in:    	   isacmds.h

    Parameters Passed:  azim,elev,roll angles IN DEGREES
						to define new reference frame

    Return Value:       TRUE if successful
						FALSE otherwise

    Remarks:            ANGLE ALIGN COMMAND = 'r' = 72hex = 114dec
					 	Command Data:    azim, elev, roll
*/

int bird_referframe_isa(float azim, float elev, float roll)
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
	    *cdataptr++ = (unsigned char) ((angle[i] & 0x0ff00) >> 8);
	    *cdataptr++ = (unsigned char) (angle[i] & 0x0ff);
    }

    /*
	Send the Command
    */
    if (send_isa_cmd(cdata,7) != 7)
	return(FALSE);

    return(TRUE);
}

/*
    bird_reportrate_isa -   Select the Report Rate for Stream Mode

    Prototype in:       isacmds.h

    Parameters Passed:  rate

    Return Value:       TRUE if successful
			FALSE if unsuccessful
			ESC_SEL if user selected ESC

    Remarks:
*/
int bird_reportrate_isa(unsigned char rate_cdata)
{

    /*
	Send of the 1 char
    */
    if (send_isa_cmd(&rate_cdata,1) != 1)
	return(FALSE);

    return(TRUE);
}

/*
    bird_sleep_isa  -   Implements the Sleep ('G') command

    Prototype in:       isacmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessfull

    Remarks:
*/
int bird_sleep_isa()
{
    static unsigned char sleep_cdata = 'G';


    /*
	Send the command
    */
    if (send_isa_cmd(&sleep_cdata,1) != 1)
	return(FALSE);
    return(TRUE);
}
/*
    bird_wakeup_isa  -   Implements the Wake ('F') command

    Prototype in:        isacmds.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessfull

    Remarks:
*/
int bird_wakeup_isa()
{
    static unsigned char wakeup_cdata = 'F';

    /*
	Send the command
    */
    if (send_isa_cmd(&wakeup_cdata,1) != 1)
	return(FALSE);
    return(TRUE);
}
/*
    bird_buttonmode_isa   -   Implements the M mouse button command

    Prototype in:       isacmds.h

    Parameters Passed:  void

    Return Value:       TRUE if passed
                        otherwise FALSE

    Remarks:
*/
int bird_buttonmode_isa(short buttonmode)
{
    static unsigned char button_cdata[] = {'M',0};  /* button command */

    button_cdata[1] = (unsigned char) buttonmode;

    /*
	Send Button Command
    */
    if (send_isa_cmd(button_cdata,2) != 2)   /* send the button cmd */
	return(FALSE);
    return(TRUE);
}

/*
    bird_buttonread_isa   -   Implements the N mouse button command

    Prototype in:       isacmds.h

    Parameters Passed:  void

    Return Value:       TRUE if passed
                        otherwise FALSE

    Remarks:
*/
int bird_buttonread_isa(void)
{
    static unsigned char button_cdata[] = {'N'};  /* button command */

    /*
    Send Read Button Command
	*/
	if (send_isa_cmd(button_cdata,1) != 1)
  	   return(FALSE);
	return(TRUE);
}

/*
    bird_xonxoff_isa  - Implements the XON / XOFF commands

    Prototype in:       isacmds.h

    Parameters Passed:  XON/XOFF parameter

    Return Value:       TRUE if sent XON or XOFF
			FALSE if could not send the command

    Remarks:            sends down the XON or XOFF command to the BIRD
*/
int bird_xonxoff_isa(birdflowcmd)
unsigned char birdflowcmd;
{

    /*
	Send the command to the Bird
    */
    if (send_isa_cmd(&birdflowcmd,1) != 1)
       return(FALSE);
    return(TRUE);
}


/*
    bird_changevalue_isa      - Sends the Change Value Commmand to the BIRD

    Prototype in:       isacmds.h

    Parameters Passed:  parameter_number - integer number of the parameter
 			            parameter_data_ptr - pointer to the data to be sent to
					    change parameter

    Return Value:       TRUE if Command was sent to the BIRD
				        FALSE if could not send the command
			            ILLEGAL_PARAMETER_VALUE if illegal parameter#

    Remarks:            CHANGE VALUE Command = 'P' = 50hex = 80dec
			            CHANGE VALUE Command Data = parameter_number
*/
int bird_changevalue_isa(parameter_number, parameter_data_ptr)
int parameter_number;
unsigned char *parameter_data_ptr;

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
    ILLEGAL_PARAMETER_VALUE, /* Parameter0 SYSTEM STATUS (NONCHANGEable)*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter1 SOFTWARE REV# (NONCHANGEable)*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter2 CRYSTAL SPEED (NONCHANGEable)*/
    4,                       /* Parameter3, Range Scale                */
    4,                       /* Parameter4 Filter ON/OFF Status        */
    16,                      /* Parameter5 DC FILTER Constant ALPHA_MIN*/
    4,                       /* Parameter6, Measurement Rate Count     */
    4,                       /* Parameter7, Measurement Rate           */
    4,                       /* Parameter8, Send Data Ready            */
    4,                       /* Parameter9, Data Ready Character       */
    ILLEGAL_PARAMETER_VALUE, /* Parameter10 ERROR CODE (NONCHANGEable) */
    4,                       /* Parameter11,Set Error Detect Mask      */
    16,                      /* Parameter12 DC FILTER Constant Vm      */
    16,                      /* Parameter13 DC FILTER Constant ALPHA_MAX*/
    4,                       /* Parameter14,Sudden Output Change Ellimination */
    ILLEGAL_PARAMETER_VALUE, /* Parameter15 SYSTEM MODEL (NONCHANGEable)*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter16, Not used                  */
    4,                       /* Parameter17 XYZ REFERENCE FRAME        */
    4, 						 /* Parameter18 Transmitter mode           */
    4, 						 /* Parameter19 Addressing Mode            */
    4, 						 /* Parameter20 Line Frequency             */
    4, 						 /* Parameter21 FBB Address                */
    4, 						 /* Parameter22 Hemisphere                 */
    8,						 /* Parameter23 Angle Align 2              */
    8,						 /* Parameter24 Reference Frame 2          */
    4,						 /* Parameter25, Bird Serial Number        */
    4,             /* Parameter26, Sensor Serial Number      */
    4,             /* Parameter27, Xmtr Serial Number        */
    ILLEGAL_PARAMETER_VALUE, /* Parameter28, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter29, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter30, Not used                  */
    ILLEGAL_PARAMETER_VALUE, /* Parameter31, Not used                  */
    4,                       /* Parameter32, FBB Response Delay        */
    7,                       /* Parameter33 CONFIGURATION              */
    ILLEGAL_PARAMETER_VALUE, /* Parameter34, Not used                  */
    4,                       /* Parameter35 GROUP MODE                 */
    ILLEGAL_PARAMETER_VALUE, /* Parameter36, Not used                  */
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
    4,                       /* Parameter50, Auto-Configuration        */
    };

    /*
    Set the command size as a function of the parameter #.
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
    Put the parameter number to the command string right after
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
    if (send_isa_cmd(spadchangevaluecmd,cmdsize) != cmdsize)
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
    bird_examinevalue_isa     - Sends the Examine Value Commmand to the BIRD
                                and gets the response
    Prototype in:       isacmds.h

    Parameters Passed:  parameter_number - integer number of the parameter
			            examine_value_data_ptr - pointer to store the data
						from the BIRD

    Return Value:       TRUE if Command was sent to the BIRD and data received
			FALSE if could not send the command or read the data
			ILLEGAL_PARAMETER_VALUE if illegal parameter#

    Remarks:            EXAMINE VALUE Command = 'O' = 4Fhex = 79dec
			EXAMINE VALUE Command Data = parameter_number
*/
int bird_examinevalue_isa(parameter_number,examine_value_data_ptr)
int parameter_number;
unsigned char * examine_value_data_ptr;
{
    short i;
    short response_size;
    long rxword;
    static unsigned char spadexaminevaluecmd[] = {'O',0};
    static short examine_value_response[51] = {
    2,                       /* Parameter00 SYSTEM STATUS               			*/
    2,                       /* Parameter01 SOFTWARE REV#               			*/
    2,                       /* Parameter02 CRYSTAL SPEED               			*/
    2,                       /* Parameter03 POSITION SCALING            			*/
    2,                       /* Parameter04 Filter ON/OFF Status        			*/
    14,                      /* Parameter05 DC FILTER Constant ALPHA_MIN			*/
    2,                       /* Parameter06 MEASUREMENT RATE COUNTER    			*/
    2,  					 /* Parameter07,MEASUREMENT RATE            			*/
    2,                       /* Parameter08 DATA READY                  			*/
    2,                       /* Parameter09 DATA READY CHARACTER        			*/
    2,                       /* Parameter10 ERROR CODE                 				*/
    2,                       /* Parameter11 ERROR MASK                				*/
    14,                      /* Parameter12 DC FILTER Constant Vm     				*/
    14,                      /* Parameter13 DC FILTER Constant ALPHA_MAX			*/
    2,                       /* Parameter14 SUDDEN OUTPUT CHANGE ELLIMINATION 		*/
    10,                      /* Parameter15 SYSTEM MODEL               				*/
    2,                       /* Parameter16 EXPANDED ERROR CODE        				*/
    2,                       /* Parameter17 XYZ REFERENCE FRAME        				*/
    2,						 /* Parameter18, Transmitter Mode		   		 */
    2, 						 /* Parameter19, Addressing Mode		   		 */
    2, 						 /* Parameter20, Line Frequency            */
    2, 						 /* Parameter21, FBB Address               */
    2,						 /* Parameter22, Hemisphere	            	 */
    6,						 /* Parameter23, Angle Align 2		       	 */
    6,						 /* Parameter24, Reference Frame 2	     	 */
    2,						 /* Parameter25 Bird Serial Number	       */
    2,             /* Parameter26 Sensor Serial Number         */
    2,             /* Parameter27 Xmtr Serial Number       */
    ILLEGAL_PARAMETER_VALUE, /* Parameter28, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter29, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter30, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter31, Not used                  				*/
    2,                       /* Parameter32 FBB HOST DELAY             				*/
    5,                       /* Parameter33 CONFIGURATION              				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter34, Not used                  				*/
    2,                       /* Parameter35 GROUP MODE                 				*/
    14,                      /* Parameter36 FLOCK SYSTEM STATUS        				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter37, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter38, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter39, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter40, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter41, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter42, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter43, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter44, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter45, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter46, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter47, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter48, Not used                  				*/
    ILLEGAL_PARAMETER_VALUE, /* Parameter49, Not used                  				*/
    5,                       /* Parameter50, AUTO-CONFIGURATION        				*/
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
	if (send_isa_cmd(spadexaminevaluecmd,2) != 2)
	    return(FALSE);

	/*
	    Get the n byte response
	*/
	for (i=0; i < response_size ; i = i+2)
	{
	    rxword = waitforword(); 
//	    printf("%ld", rxword);
//	    hitkeycontinue();
	    * (examine_value_data_ptr++) = (unsigned char) ((rxword & 0xff00) >> 8);
	    * (examine_value_data_ptr++)= (unsigned char) (rxword & 0x0ff);
	    if (rxword < 0)
		   return(FALSE);
	}

	return(TRUE);
}

/*
    bird_crtsync_isa    - Implements the CRT SYNC command

    Prototype in:       isacmds.h

    Parameters Passed:  birdcrtsyncmode - CRT sync mode,
                        pointer birdcrtsyncdata to store the data (if any)

    Return Value:       TRUE if a command was executed
			FALSE if command could not be executed
			ESC_SEL if the user selected escape

    Remarks:
*/
int bird_crtsync_isa(birdcrtsyncmode, birdcrtsyncdata)
unsigned char birdcrtsyncmode;
unsigned char * birdcrtsyncdata;
{
    short i;
    long rxword;
    static unsigned char birdcrtsynccmd[] = {'A',0};

    /*
	Set the Command data
    */
    birdcrtsynccmd[1] = birdcrtsyncmode;

    /*
    Send the Command
	*/
	if (send_isa_cmd(birdcrtsynccmd,2) != 2)
		return(FALSE);

    if (birdcrtsyncmode == 255)
	{
    	/*
		    Get the 4 byte = 2 words response response
		*/
		for (i=0; i<2; i++)
		{
		    rxword = waitforword();
 	        * (birdcrtsyncdata++)  = (unsigned char) ((rxword & 0xff00) >> 8);
 	        * (birdcrtsyncdata++)  = (unsigned char) (rxword & 0xff00);
		    if (rxword < 0)
			   return(FALSE);
		}
    }
    return(TRUE);
}

/*
    bird_nextmaster_isa     - Next Master Command

    Prototype in:            isacmds.c

    Parameters Passed:       int nextmaster

    Return Value:       TRUE if command sent OK
			FALSE if command could not be sent
			ESCSEL if the user selected ESC

    Remarks:
*/
int bird_nextmaster_isa(int nextmaster)
{
    unsigned char nextmaster_cmd;

	nextmaster_cmd = (unsigned char) nextmaster + '0';

	    if (send_isa_cmd(&nextmaster_cmd,1) != 1)
 		   return(FALSE);
		return(TRUE);
}

/*
    bird_nextxmtr_isa     - Next Transmitter Command

    Prototype in:          isacmds.c

    Parameters Passed:     int nextxmtradress, int nextxmtrnum

    Return Value:       TRUE if command sent OK
			FALSE if command could not be sent

    Remarks:
*/
int bird_nextxmtr_isa(int nextxmtraddr, int nextxmtrnum)
{
    static unsigned char nextxmtr_cmd[2] = {'0',0};

	nextxmtr_cmd[1] = (unsigned char) nextxmtraddr << 4;
	nextxmtr_cmd[1] |= (unsigned char) nextxmtrnum;

    if (send_isa_cmd(nextxmtr_cmd,2) != 2)
	   return(FALSE);
    return(TRUE);
}

/*
    bird_clearoutputbuffer_isa - Clear Output Buffer Command

    Prototype in:          isacmds.c

    Parameters Passed:     void

    Return Value:          TRUE if command sent OK
			               FALSE if command could not be sent

    Remarks:
*/
void bird_clearoutputbuffer_isa(void)
{
    static unsigned char clearbuffer_cmd = 'f';
    long starttime;
    short transmit_delay;

    /* Send The Command to stop streaming and clear output buffer */
    if (send_isa_cmd(&clearbuffer_cmd,1) != 1)
	   return;


    /*
        Get the delay to wait for ready to send
    */
    transmit_delay = TXTIMEOUTINSECS;

    /*
        Get the time now in ticks
    */
    starttime = GETTICKS;

    /*
       Wait untill the command has been read by the Bird
        ....leave loop when read or timeout
    */
    while (!(read_isa_status() & ISAOKTOWRITE))
    {
        /*
            Check to see if a timeout occured
        */
        if (((long)(GETTICKS) - starttime) > (long)((transmit_delay * 1000) / TICK_MSECS))
        {
            printf("\n** ERROR ** ISA transmitter timed out\n");
            return;
        }
    }

    /*
     Perform a dummy read to reset the ISA Status bit in a case if it had been set
     prior we sent a command.
    */
    INPORT(isa_base_addr);

    /* Reset Data Ready Output flag, as it's disabled in the Bird */
    data_rdy_output = FALSE;     /* data ready character disabled */

    return;
}
