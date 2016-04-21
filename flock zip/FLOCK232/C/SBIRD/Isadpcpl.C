/****************************************************************************
*****************************************************************************
    isabus.c  - ISAbus general routines - DOS PC Compatible

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-860-6440


    written by:     Vlad Kogan
 6/19/95 vk.. reset_through_isa() added
 10/5/95 vk.. wait_tosend_word() function added
         - calls to send_isa_word() changed to calls to wait_tosend_word,
         which returns on success OR TRANSMIT TIME OUT. Done to eliminate
         software hang ups.
1/9/96   vk..noise_statistic_flg dependency deleted when set timeout value,
         because Noise Statistics is invalid command for the Bird Family
         Product
         - isa_init() changed not to scanf base address directly, but to
         call getshorthex()
       <<<< Copyright 1991 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <dos.h>            /* for hardware port I/O */   
#include <conio.h>			/* for inpw, outpw		*/
#include "asctech.h"
#include "isadpcpl.h"
#include "menu.h"           /* Ascension Technology Menu Routines */
#include "compiler.h"
#include "pctimer.h"

/*
    Global Variables
*/
unsigned short isa_base_addr;
unsigned short isa_status_addr;
extern short rs232tofbbaddr;
/*

    isa_init          -   ISA Bus Initialization

    Prototype in:       isabus.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
			FALSE if unsuccessful

    Remarks:Routine queres the user for the Unit's Base address
*/

int isa_init()
{
    static char * isa_hdr =
"****************************************************************************\n\r\
*  ISA Bus Initialization                                                  *\n\r\
****************************************************************************\n\r\n";

    static char * addr_message =
"\n\nSpecify Base Address of the Unit in hexadecimal.\n\r\
Base Address must be of a range 0..3FC in step of 4.(e.g. 304, 308, 30C etc.)\n\r\n\
Base Address is ";
    short u_short;
    /*
	Clear the Screen and Put up a Header
    */
    CLEARSCREEN;
    sendmenuhdr(isa_hdr);
    do
    {
       printf("\n\rCurrently Use Base Address %3Xhex",isa_base_addr);
       u_short = getshorthex(addr_message,0,0x3FC);
       if(u_short != ESC_SEL)               /* IF NOT ESC THEN
                                               try to set new ISA addresses
                                             */
       {
          if ((u_short & 0x3FC) == u_short)
          {
             isa_base_addr = u_short;
             isa_status_addr = isa_base_addr + 2;
             return (TRUE);
          }
          else
             printf("\n\r *** ERROR *** %3Xhex is Invalid Base Address",u_short);
       }
       return (TRUE);                       /* IF user hit ESC THEN
                                               do nothing and keep old addresses */
    }
    while (TRUE);
}

/*
    send_isa_cmd     -    Send Command through ISA Bus

    Prototype in:       isabus.h

    Parameters Passed:  cmd         -   string to send to the serial point
                        cmdsize     -   size of the cmd string (cmd is NOT
                                        NULL terminated, since the data can
                                        be NULL)
    Return Value:       number of bytes transmitted

    Remarks:            Routine will send a string of characters to the ISA
                        port.  The string is pointed to by cmd and all
                        characters will be sent upto but NOT including
                        the NULL
*/
int send_isa_cmd(cmd,cmdsize)
unsigned char * cmd;
short cmdsize;
{
	short txcount = 0;
//    unsigned char address;
    unsigned short com_word = 0;
    /*
        Add an address preface (if any) to the command here
    */
    if (rs232tofbbaddr > 0) 
    	{
    	if(enhancedModeFlag && (addressMode == SUPER_EXTENDED))
    		{ 
    		com_word = 0xA000 | (0x00FF & (unsigned short)rs232tofbbaddr);
	        /*
	            Wait until a word is sent or time out
	        */
//printf("%04x\n\r", com_word);
	        if (wait_tosend_word(com_word) != TRUE)  
	        	{
	           	return(FALSE);  
	           	}
			com_word = 0;
    		}
    		
    	else
    		{
       		com_word = (0xF0 | (unsigned short) rs232tofbbaddr) << 8; /* MSByte:LSbyte = address:0 */   
            }
		}        

    while (txcount < cmdsize)
    {
       if ((txcount != 0) || (com_word == 0)) /* if the preface (if any) has been sent */
       {
          com_word = (unsigned short) *cmd << 8; /* form MSByte of the word to send */
          cmd++;                                 /* point next character */
          txcount++;                             /* count characters sent */
       }
       if (txcount <  cmdsize)                   /* still have something to send */
       {
          com_word = com_word | (unsigned short) *cmd; /* form LSByte of the word to send */

        /*
            point to the next character
        */
          cmd++;                                       /* point next character */
          txcount++;                                   /* count characters sent */
       }

        /*
            Wait until a word is sent or time out
        */
//printf("%04x\n\r", com_word);
        if (wait_tosend_word(com_word) != TRUE)
           return(FALSE);
    }
    return(txcount);
}

/*
    wait_tosend_word  - Wait to send a word through the ISA Bus

    Prototype in:       isabus.h

    Parameters Passed:  void

    Return Value:       returns TRUE if successful,
                        TXTIMEOUT if a time out occurs before a
                        word is sent

    Remarks:            Routine waits for the TIMEOUTINTICKS period
                        to send a word

*/
int wait_tosend_word(word)
unsigned short word;
{
    long starttime;
    short transmit_delay;

    /*
        Get the delay to wait for ready to read status
    */
    transmit_delay = TXTIMEOUTINSECS;

    /*
        Get the time now in ticks
    */
    starttime = GETTICKS;

    /*
        Wait until a word is sent
        ....leave loop if word sent or timeout
    */
    while ((send_isa_word(word)) != TRUE)
    {
        /*
            Check to see if a timeout occured
        */
        if (((long)(GETTICKS) - starttime) > (long)((transmit_delay * 1000) / TICK_MSECS))
        {
            printf("\n** ERROR ** ISA transmitter timed out\n");
            return(TXTIMEOUT);
        }
    }

    /*
        Everything is OK...
    */
    return(TRUE);
}
/*
    send_isa_word    -   Send one word from the HOST through ISA Bus

    Prototype in:        isabus.h

    Parameters Passed:   word     -  word to send to the ISA

    Return Value:       returns TRUE if successful, or FALSE if
                        cannot send because the status register
                        shows that previous data has not been read yet


    Remarks:
*/
int send_isa_word(word)
unsigned short word;
{

    /*
        Get ISA status and check if it's OK to send the word
            else return
    */
    if (!(read_isa_status() & ISAOKTOWRITE))
    return(FALSE);
    /*
        Else, Transmit the Word
    */
    OUTPORT(isa_base_addr, word);
    return(TRUE);
}


/*
    read_isa_status  -   Read ISA BUS status word

    Prototype in:        isabus.h

    Parameters Passed:  none

    Return Value:       returns the status word read from the isa_status_addr


    Remarks:
*/
int read_isa_status()
{
    /*
        Perform direct read from isa_status_addr
    */
    return (INPORT(isa_status_addr));
}

/*
    get_isa_record   - Get a record from the ISA

    Prototype in:       isabus.h

    Parameters Passed:  rxbuf       -   pointer to a buffer to store the
                                        received characters
                        recsize     -   number of characters to receive
                        outputmode  -   POINT, CONTINUOUS or STREAM

    Return Value:       If successful, returns recsize
                        else, RXERRORS if Rx errors were detected while
                        receiving data, or RXPHASEERRORS if in POINT or
                        CONTINUOUS mode and a phase error is detected.

    Remarks:            A record of data has the LSByte of the first
                        word set to a 1.  The routine verifies that
                        the first character received is in PHASE.  If
                        in STREAM mode, the routine resynches and tries
                        to capture the data into the rxbuf.  If in POINT
                        or CONTINUOUS mode, then the routine returns
                        indicating a RXPHASEERROR.

*/
int get_isa_record(rxbuf, recsize, outputmode)
short * rxbuf;
short recsize;
short outputmode;
{
	short rxcount;
	long rxword;
	short resynch;
    short * rxbufptr;
    resynch = TRUE;

    do
    {
        if  (resynch)
        {
            rxcount = 0;                /* initialize char counter */
            rxbufptr = rxbuf;           /* setup buffer pointer */
            resynch = FALSE;
        }
        /*
            Get first word and if error and NOT in STREAM mode..return
        */
        if (rxcount == 0)
        {       
        	rxword = waitforword();
            if (rxword < 0)
            {
                if ((outputmode != STREAM) || (rxword == RXTIMEOUT))
                {
                    phaseerror_count = 0;
                    return(RXERRORS);
                }

                /*
                   If an Error occured and we are in STREAM mode, resynch
                */
                if (outputmode == STREAM)
                {
                    /*
                       Resynch
                       ...and keep track of the phase error
                    */
                    phaseerror_count++;
                    resynch = TRUE;
                    continue;
                }
            }

            /*
                Check to make sure the the phase bit is a '1'
                If not, then if STREAM mode, resynch
                else, return with error
            */
            if (!(rxword & 0x0001))
            {
                if (outputmode == STREAM)
                {
                    /*
                       Resynch
                       ...and keep track of the phase error
                    */
                    phaseerror_count++;
                    resynch = TRUE;
                    continue;
                }
                else
                {
                     phaseerror_count = 0;
                     return(RXPHASEERROR);
                }
            }
        }
        else    /* rxcount > 0 */
        {
            /*
                Get remainder of Block of data from the ISA bus, recsize characters
                and store them in rxbuf
            */
            if ((rxword = waitforword()) >= 0)  /* no errors */
            {
                /*
                   Check Phase bit
                */
                if (rxword & 0x0001)              /* check to see that phase bit = '0' */
                {
                    if (outputmode == STREAM)
                    {
                        phaseerror_count++;     /* keep track of phase errors */
                        resynch = TRUE;         /* loop again flag */
                        continue;
                    }
                    else
                    {
                       phaseerror_count = 0;
                       return(RXPHASEERROR);       /* return phase error */
                   }
                }
            }
            else
            {
                if (outputmode == STREAM)
                {
                    phaseerror_count++;     /* keep track of phase errors */
                    resynch = TRUE;         /* loop again flag */
                    continue;
                }
                else
                {
                    phaseerror_count = 0;
                    return(RXERRORS);
                }
            }
        }
        /*
           Store the received word
        */
        *rxbufptr++ = (short)rxword;   /* store and adjust pointer */
        rxcount +=2;            /* increment */
    }
    while ((resynch) || (rxcount < recsize));

    /*
        Return the number of characters received
    */
    return(rxcount);
}

/*
    waitforword         -   Wait for a word from the ISA Bus

    Prototype in:       isabus.h

    Parameters Passed:  void

    Return Value:       returns the receive word if successful,
                        RXERRORS if recieve errors,
                        RXTIMEOUT if a time out occurs before a
                        word is ready

    Remarks:            Routine waits for the TIMEOUTINTICKS period
                        for a word

*/
long waitforword()
{
	long rxword;
    long starttime;
    short receive_delay;

    /*
        Get the delay to wait for a system response
    */
    receive_delay = RXTIMEOUTINSECS;

    /*
        Get the time now in ticks
    */
    starttime = GETTICKS;

    /*
        Wait until a word is available
        ....leave loop if errors or word available
    */
    while ((rxword = get_isa_word()) == NODATAAVAIL)
    {
        /*
            Check to see if a timeout occured
        */
        if (((long)(GETTICKS) - starttime) > (long)((receive_delay * 1000) / TICK_MSECS))
        {
            printf("\n** ERROR ** receiver timed out\n");
            return(RXTIMEOUT);
        }
    }
    
    
//    printf("%ld", rxword);
//    hitkeycontinue();


    /*
        return if RX errors
    */
    if (rxword < 0)
        return(RXERRORS);

    /*
        Everything is OK...return the word
    */
    return(rxword);
}

/*
    get_isa_word -      Get 1 Word from the ISA Bus if one is available

    Prototype in:       isabus.h

    Parameters Passed:  void

    Return Value:       returns the receive word if successful,
                        NODATAAVAIL if no word available
    Remarks:
*/
long get_isa_word()
{ 
	long returnValue;  

    /*
        Check if word is available
            else return
    */
    if(read_isa_status() & ISAOKTOREAD)
    	{  
    	returnValue = INPORT(isa_base_addr); 
    	returnValue = returnValue & 0x0000FFFF; 
        }
        
    else
    	{ 
    	returnValue = NODATAAVAIL;
    	}
    	
	return(returnValue);
}


/*

    reset_through_isa() -   Reset the board through ISA bus

    Prototype in:       isa_gen.h

    Parameters Passed:  void

    Return Value:       none

    Remarks:            the board is reset by the rasing edge of the LSBit
                        at the ISA Bus status register.

*/
void reset_through_isa()
{

 /* write 0 to the ISA status register */
 OUTPORT(isa_status_addr, 0);

 /* write 1 to the ISA status register */
 OUTPORT(isa_status_addr, 1);

 /* Put a message for user */
    printf("\n\rThe System is reset\n\r");
    hitkeycontinue();

}
