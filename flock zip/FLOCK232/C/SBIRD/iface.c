/****************************************************************************
*****************************************************************************
    iface.c       - Interface Routines using ISA Bus OR rs232 interface

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-860-6440


    written by:     Vlad Kogan

    Modification History:

1/10/96  vk..released
         - readbirddata() changed to choose between Serial and ISA interface.
2/1/96   vk..readbirddata() changed. If ISA interface THEN treat button
         value as a WORD not a byte.

2/12/96  vk..readbirddata() changed. If ISA interface THEN treat address
         as a WORD not a byte when in group mode.

2/13/96  vk..readbirddata() changed. IF ISA interface then to
         stop streaming call bird_clearoutputbuffer_isa() function.

           <<<< Copyright 1990 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include "asctech.h"        /* general definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "birdmain.h"       /* for serialinit prototypes */
#include "menu.h"           /* Ascension Technology Menu Routines */
#include "serial.h"         /* Ascension Technology Serial Port Routines */
#include "iface.h"          /* Own Prototypes */
#ifdef DOS
  #include "isadpcpl.h"       /* Prototypes for ISA related functions */
  #include "isacmds.h"
#endif

/*
    Global Variables
*/
short phaseerror_count = 0;      /* holds the phase errors */
/*
   Define Interface Globals
*/
short interface;      /* =1, if ISA_BUS or =0 if RS232 */


/*
    External Definitions
*/

extern short buttonvalue;
extern unsigned char fbbgroupdataflg;


/*

    interfaceinit     - Interface Initialization

    Prototype in:       iface.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessful

    Remarks:            Routine prompts the user to choose rs232
                        or ISA interface and initializes the
                        choosen one
*/
int interfaceinit()
{
    short menusel;
    static char * interfacehdr =
"****************************************************************************\n\r\
* ASCENSION TECHNOLOGY CORPORATION - Interface Menu                        *\n\r\
****************************************************************************\n\r\n";

    static char * interfacemenu[] =
	      {"Interface Options:",
	       "No Change",
	       "ISA Bus",
	       "Serial Interface"};


    /*
	Clear the Screen and Put up a Header
    */
    CLEARSCREEN;
    sendmenuhdr(interfacehdr);

    /*
	Query the User for the Serial Port configuration
    */
	/*
	    Display Current Configuration
	*/
#ifdef DOS
    if (interface == ISA_BUS)
  	   printf("\n\rCurrently Set to Use ISA Bus. Base Address is %3Xhex.",
	         isa_base_addr);
    else                       /* RS232*/
#endif
    {
       printf("\n\rCurrently Set to Use Serial Port.");
       printf("\n\rSerial Port Configuration: \n\r\t %s at %ld Baud\n\r",
	   sys_com_port[comport],baud);
    }

	/*
	    Get menu selection
	*/
	if ((menusel = sendmenu(interfacemenu,3)) <= 0)   /* ESC or no change */
	{
	    return(TRUE);                       /* all set...go home */
	}


	if (menusel == 1)                       /* if ISA Interface */
	{
#ifdef DOS
       interface = ISA_BUS;
       return (isa_init());
#endif
	}

	/*
	    Must be a Serial Port Interface
	*/
	else
	{
       if (!serialinit())
       {
     	  printf("** ERROR ** could not initialize the serial port\n\r");
 	      restoreconsole();
	      return (FALSE);
       }
       interface = RS232;
       return (TRUE);
	}

}

/*

    send_cmd          - Send Command through either serial port or ISA Bus

    Prototype in:       iface.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			            FALSE if unsuccessful

    Remarks:            Routines checks which Interface to use and sends
                        the command
*/
int send_cmd(cmd, cmdsize)
unsigned char * cmd;
short cmdsize;
{
#ifdef DOS
   if (interface == ISA_BUS)                 /* If ISA interface THEN */
      return (send_isa_cmd(cmd, cmdsize));   /* send through ISA and return */
#endif
   return (send_serial_cmd(cmd, cmdsize));   /* ...ELSE send through serial port */
}
 
 
 
 
 
 
 
 
/*
    readbirddata        -   Read Bird Data and convert to 2's complement

    Prototype in:       iface.h

    Parameters Passed:  birddata    - pointer to integer array to store data
			numwords    - number of words (16 bits) to read
			outputmode  - POINT, CONTINUOUS, or STREAM
			buttonmode  - 0 if off, 1 if on (send button value)

    Return Value:       TRUE if successful
                        FALSE otherwise

    Remarks:            routine reads a record from the bird, and adjusts
			the least and most significant Bird bytes into 2's
			complemented words.
*/
int readbirddata(birddata,numwords,outputmode,buttonmode)
#ifdef IRIX
  unsigned char * birddata;
#else
  short * birddata;
#endif
short numwords;
short outputmode;
short buttonmode;

{
  short i;
  
  short extrachar=0;

  if (fbbgroupdataflg)
	 extrachar = 1;

  /*
  Read 2*numbwords characters from the bird, check for errors
  ...add one character to record length if buttonmode == 1
  */
  if (interface == RS232)                    /* if serial interface */
  {
	 if ((get_serial_record((unsigned char *)birddata, (2 * numwords) + buttonmode + extrachar, outputmode)) < 0)
	 { 
		// printf("get_serial_record<0 error\n\r");  
		//printf("outputmode = %4x\n\r", outputmode);
		if (outputmode == STREAM)
		{
	printf("\n\n\n\r** STOPPING STREAM MODE **");
	send_cmd((unsigned char *)"B",1);     /* stop streaming, via Point cmd */  
		  //hitkeycontinue(); 
		}
		printf("\n\n\n\r** ERROR ** could not read serial data record from the BIRD\n\r");
		hitkeycontinue();
		return(FALSE); 
	 }

	 /*
	 go though the birddata and make into two's complemented
	 16 bit integers by:
		- lsbyte << 1
		- word << 1
	 */
	 for (i=0;i<numwords;i++)
	 {
		/*
		MOTOROLA and some RISC CPUs place
		the high order byte of a 16 bit word in the lower address of
		memory whereas INTEL like CPUs place the high order bytes in the
		higher addresses...therefore this operation must be CPU
		independent
		*/
		#ifdef DOS
			*birddata++ = ((short)((((short)(*(unsigned char *) birddata) & 0x7F)) |
				((short)(*((unsigned char *) birddata+1)) << 7)) << 2);
		#else
			ts = (short)((((short)(* birddata) & 0x7F) | (short)(*( birddata+1)) << 7)) << 2;
			if (little_endian)
				{
				*birddata = ts >> 8;
				*(birddata + 1) = ts & 0xff;
				}
			else
				{
				*(birddata + 1) = ts >> 8;
				*birddata = ts & 0xff;
				}
			birddata += 2;
		#endif
	 }
		 
	 /*
	 Read the Button Value if Required
	 ...Note that birddata currently points to the button value
	 */
	 if (buttonmode)
		buttonvalue = (short)(*birddata);
  }
#ifdef DOS
  else                 /* ISA interface */
  {
	 if ((get_isa_record(birddata, (2 * numwords) + 2 * buttonmode + 2 * extrachar, outputmode)) < 0)
	 {
		if (outputmode == STREAM)
		bird_clearoutputbuffer_isa();     /* stop streaming, via Clear Output Buffer cmd */
		printf("\n\r** ERROR ** could not read ISA data record from the BIRD\n\r");
		hitkeycontinue();
		return(FALSE);
	 }     
	 /*
	 Note then when ISA interface don't need to perform any formatting
	 of the data record
	 */
	
	 /*
	 Read the Button Value if Required
	 ...Note that birddata currently points beginning of the record
	 */
	 if (buttonmode)
		for (i=0;i<numwords;i++)
	birddata++;    /* adjust pointer to point button value */
					buttonvalue = *birddata;
  }
#endif

  return(TRUE);
}

/*
	 waitfordata         -   Wait for a Character from the Serial Port
									 or word from ISA

    Prototype in:       iface.h

    Parameters Passed:  void

    Return Value:       returns the receive data if successful,
                        RXERRORS if recieve errors,
                        RXTIMEOUT if a time out occurs before a
                        data is ready

    Remarks:            Routine waits for the TIMEOUTINTICKS period
                        for a character

*/
int waitfordata()
{
    if (interface == RS232)
       return(waitforchar());
    /* ...ELSE ISA */
#ifdef DOS
    return((int)(waitforword()));
#endif
}
