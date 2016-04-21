/****************************************************************************
*****************************************************************************
    serdpcin.c      - Serial Routines - DOS PC Interrupt Mode

    written for:    Ascension Technology Corporation
		    PO Box 527
		    Burlington, Vermont  05402

		    802-655-7879


    written by:     Jeff Finkelstein

    Modification History:

    10/18/90        jf  - created
    11/12/90        jf  - add getdosticks() to allow Polled mode operation
			  at 19200 even on a pretty slow machine
    4/16/91         jf  - renamed module
    6/18/91         jf  - added FOB baudrate selections
    8/19/91         jf  - removed asserting of RTS
    12/23/92        jf  - added baudratebit definitions to allow
			  for compatibility with UNIX
    1/31/93         jf  - send_serial_cmd modified to be able to send out
			  rs232 to fbb commands to addr 30
    10/20/93        jf  - included pcpic.h
			- added protected mode vector settings


	   <<<< Copyright 1990 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <time.h>           /* clock functions */
#include <dos.h>            /* needed for SETVECT/GETVECT */
#include "compiler.h"
#include "asctech.h"
#include "menu.h"
#include "pcpic.h"
#include "pctimer.h"
#include "serial.h"

#ifdef DOS    /* DOS Systems Only */

/*
    Global Variables for the COM port
*/
	short com_base = COM1BASE;           /* holds the base address of the 8250 */
	short comport = COM1;                /* holds the comport # */

    char * sys_com_port[2] ={"com1","com2"};

/*
    The FOB Bird uses a different set of Baud Rates as compared
    to the standard Bird
*/
    long baud = 9600L;                     /* holds the default baud rate */
    long baudratetable[] = {115200L,
			    57600L,
			    38400L,
			    19200L,
			    9600L,
			    4800L,          /* holds the baud rate selections */
			    2400L};         /* for the FOB Bird               */
    /*
       Used for compatibility with UNIX versions
    */
    short baudspeedbits = 7;            /* holds the current bit definition */
    short baudspeedbittable[] = {11,
				 10,
				 9,
				 8,
				 7,
				 6,
				 5};    /* holds the bitspeed definition */


	short serialconfigsaved = FALSE;            /* flag indicates serial port saved */

/*
    UART variable Storage
*/
    unsigned char olddivisorlow;            /* holds the old divisor low value */
    unsigned char olddivisorhigh;           /* holds the old divisor high value */
    unsigned char oldlinecont;              /* holds the old line control value */
    unsigned char oldinterenable;           /* holds the old interrupt enable value */
    unsigned char oldmodemcont;             /* holds the old modem control value */
    unsigned char oldirqmsk;                /* holds the old interrupt cont msk value */

/*
    Storage for the old serial interrupt vector
*/
#ifdef DPMC /* DOS Protected Mode Compiler */
    RINTTYPE oldserialintvect;    /* REAL old serial interrupt vector */
    INTTYPE  (* oldserialpintvect)(); /* PROT old serial interrupt vector */
#ifdef HIGHC
    extern _INTERRPT void hc_serialisr(void);
    void serialisr(void);
#else
    INTTYPE serialisr(void);
#endif /* HIGHC */

#else
#ifdef MSC
    void (interrupt far * oldserialintvect)();  /* old serial interrupt vector */
#else
    INTTYPE (* oldserialintvect)(); /* old serial interrupt vector */
#endif /* MSC */
    INTTYPE serialisr(void);
#endif /* DPMC */



/*
    Error Counters
*/

	short phaseerror_count = 0;      /* holds the phase errors */
	short rxerrorvalue = 0;          /* holds the rx error value */
	short rxbufoverruns = FALSE;     /* rx buffer overrun flag */
	short rxerrors = FALSE;          /* rx line errors flag */
	short txbufempty = TRUE;         /* tx buffer empty flag */

/*
    RX buffer
*/
    unsigned char rxbuf[RXBUFSIZE];         /* rx buffer */
    unsigned char * rxbufinptr = rxbuf;     /* rx buffer input pointer */
    unsigned char * rxbufoutptr = rxbuf;    /* rx buffer output pointer */

/*
    TX buffer
*/
    unsigned char txbuf[TXBUFSIZE];         /* tx buffer */
    unsigned char * txbufinptr = txbuf;     /* tx buffer input pointer */
    unsigned char * txbufoutptr = txbuf;    /* tx buffer output pointer */

/*
    Define RS232 to FBB Global Address
*/
    short rs232tofbbaddr = 0;

/*
    configserialport    -   Configure the Serial Port connected to the BIRD

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       TRUE if successfull, else FALSE

    Remarks:            Routine assumes that the current comports parameters
			have been saved prior to the call.
					    ** NOTE **
			Unfortunately, the PC ROM BIOS does NOT support baud
			rates upto 19200. Therefore, this routine must talk
			directly to the hardware to configure the serial port
			...this is not a problem in a PC environment since the
			I/O map is fixed for COM1 and COM2.
*/
int configserialport(void)
{
    unsigned divisor;
    unsigned comirq;

    /*
	Verify the comport and set the Base Address
    */
    switch (comport)
    {
	case COM1:
	    com_base = COM1BASE;                /* set the new I/O addr */
	    comirq = IRQ4;
	    break;
	case COM2:
	    com_base = COM2BASE;                /* set the new I/O addr */
	    comirq = IRQ3;
	    break;
	default:
	    printf("\n** ERROR ** invalid COM port\n");
	    return(FALSE);
    }

    /*
	Disable the interrupts
    */
    OUTPORTB(com_base + INTERENABLE, 0);

    /*
	Setup Vectors
    */
#ifdef DPMC
#ifdef HIGHC
    SETRPVECT(COM1INTERRUPT-comport,hc_serialisr);
#else
    SETPVECT(COM1INTERRUPT-comport,serialisr);
#endif /* HIGHC */
#else
    SETVECT(COM1INTERRUPT-comport,serialisr);
#endif /* DPMC */

    /*
	assume that there are NO CHARACTERS CURRENTLY in the Tx Buffer
	and change the baud rate
    */
    OUTPORTB(com_base + LINECONT, DLAB);

    /*
	Set the least significant byte and then the most significant
	byte of the baud rate divisor
    */
    divisor = 115200L/baud;
    OUTPORTB(com_base, (divisor & 0xff));
    OUTPORTB(com_base + 1, ((divisor & 0xff00) >> 8));

    /*
	Set the Stop Bits = 1, Word Length = 8 and Parity = None
    */
    OUTPORTB(com_base + LINECONT, STOP_WORDLEN_PARITY);

    /*
	Clear the Rx Buffer and Rx Errors
    */
    clear_rx();

    /*
	Assert DTR...just in case the cable uses the DTR signal
	Deassert RTS...else the system will reset
	Assert OUT2...needed to allow interrupts to occur on PC compatible
	    serial I/O cards
    */
    OUTPORTB(com_base + MODEMCONT, DTRON | OUT2);

    /*
	Setup the 8250 Interrupt Enable register, RXDATA and RXLINESTATUS
	are turned on...but NOT TXHOLDINTENABLE since it will be turned on
	when we send the first character
    */
    OUTPORTB(com_base + INTERENABLE, RXLINESTATUSINTENABLE | RXDATAAVAILINTENABLE);
    OUTPORTB(com_base + INTERENABLE, RXLINESTATUSINTENABLE | RXDATAAVAILINTENABLE);


    /*
	Enable the 8259 Mask register for serial interrupts
	...IRQ4 ~(0x10) for COM1, IRQ3 ~(0x08) for COM2

	Note: Disable other serial ports (ie. Mouse) to ensure that
	      we do not miss any characters at a high baud rate
    */
    PCPIC_MASK(DISABLESERIALMSK);     /* disable all serial ports */
    PCPIC_UNMASK(comirq);             /* enable the desired serial port */

    return(TRUE);
}

/*
    saveserialconfig    -   save serial port configuration

    Prototype in:       serial.h

    Parameters Passed:  com_base    -   base address of 8250 type comport

    Return Value:       void

    Remarks:            saves the current configuration of the serial port

*/
int saveserialconfig()
{

    /*
	Save the Serial interrupt Vector
    */
    oldserialintvect = GETVECT(COM1INTERRUPT - comport);
#ifdef DPMC
    oldserialpintvect = GETPVECT(COM1INTERRUPT - comport);
#endif

    /*
	Save the current 8259 Interrupt request register
    */
    oldirqmsk = PCPIC_SAVEMASK;

    /*
	Save the Current Com Port Configuration Regs including:
	    Divisor, Interrupt Enable, Line Control, Modem Control
    */
    oldlinecont = INPORTB(com_base + LINECONT);         /* save the old line control value */
    OUTPORTB(com_base + LINECONT, DLAB);                /* set DLAB to get the divisor */
    olddivisorlow = INPORTB(com_base + DIVISORLOW);     /* save the divisor low */
    olddivisorhigh = INPORTB(com_base + DIVISORHIGH);   /* save the divisor high */
    OUTPORTB(com_base + LINECONT,oldlinecont & 0x7f);   /* reset DLAB to get the divisor */
    oldinterenable = INPORTB(com_base + INTERENABLE);   /* save the interrupt enable reg */
    oldmodemcont = INPORTB(com_base + MODEMCONT);       /* save the modem control reg */

    serialconfigsaved = TRUE;

    return(TRUE);
}

/*
    restoreserialconfig -   Restore the original serial port configuration

    Prototype in:       serial.h

    Parameters Passed:  com_base    -   base address of 8250 serial port

    Return Value:       void

    Remarks:            restores the configuration of the serial port
*/
void restoreserialconfig()
{
    /*
	Do not Restore if not previously stored
    */
    if (!serialconfigsaved)
	return;

    /*
	Disable Serial Interrupts on 8259 while initializing port
	and switching interrupt vectors
    */
    PCPIC_MASK(oldirqmsk | DISABLESERIALMSK);

    /*
	Restore the Com Port Configuration Regs including:
	    Divisor, Interrupt Enable, Line Control, Modem Control
    */
    OUTPORTB(com_base + LINECONT, DLAB);                /* set DLAB to get the divisor */
    OUTPORTB(com_base,olddivisorlow);                   /* restore the divisor low */
    OUTPORTB(com_base + 1,olddivisorhigh);              /* restore the divisor high */
    OUTPORTB(com_base + LINECONT,oldlinecont);          /* reset DLAB to get the divisor */
    OUTPORTB(com_base + INTERENABLE,oldinterenable);    /* restore the interrupt enable reg */
    OUTPORTB(com_base + MODEMCONT,oldmodemcont);        /* restore the interrupt enable reg */

    /*
	Restore the Serial Vector
	..disable interrupts during restoration
    */
    DISABLE();
#ifdef DPMC
    SETPVECT(COM1INTERRUPT - comport,oldserialpintvect);
#endif
    SETVECT(COM1INTERRUPT - comport,oldserialintvect);

    /*
	Restore the 8259 Interrupt Mask register
    */
    PCPIC_RESTOREMASK(oldirqmsk);

    ENABLE();
}


/*
    clearrx             -   Read the characters out of the Rx buffer if available

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            clears the rx buffer and rx errors if any

*/
void clear_rx()
{
    phaseerror_count = 0;                       /* clear phase error cntr */
    rxerrorvalue = 0;                           /* clear error byte */
    rxerrors = FALSE;                           /* clear Rx error flag */
    rxbufoverruns = FALSE;                      /* clear Buf Overrun flag */
    rxbufinptr = rxbufoutptr = rxbuf;           /* re initialize buffer ptrs */

    /*
	Clear out pending errors and chars
    */
    INPORTB(com_base + INTERIDENT);
    INPORTB(com_base + INTERIDENT);
    INPORTB(com_base + LINESTATUS);
    INPORTB(com_base + LINESTATUS);
    INPORTB(com_base + RXBUF);
    INPORTB(com_base + RXBUF);

}

/*
    get_serial_record   - Get a record from the serial port

    Prototype in:       serial.h

    Parameters Passed:  rxbuf       -   pointer to a buffer to store the
					received characters
			recsize     -   number of characters to receive
			outputmode  -   POINT, CONTINUOUS or STREAM

    Return Value:       If successful, returns recsize
			else, RXERRORS if Rx errors were detected while
			receiving data, or RXPHASEERRORS if in POINT or
			CONTINUOUS mode and a phase error is detected.

    Remarks:            A record of data has the MSB of the first
			character set to a 1.  The routine verifies that
			the first character received is in PHASE.  If
			in STREAM mode, the routine resynches and tries
			to capture the data into the rxbuf.  If in POINT
			or CONTINUOUS mode, then the routine returns
			indicating a RXPHASEERROR.

*/
int get_serial_record(rxbuffer, recsize, outputmode)
unsigned char * rxbuffer;
short recsize;
short outputmode;
{
	short rxcount = 0;
	short rxchar;
	short resynch;
    char * rxbufptr = (char *)rxbuffer;

    resynch = TRUE;

    do
    {
	if  (resynch)
	{
	    rxcount = 0;                 /* initialize char counter */
	    rxbufptr = (char *)rxbuffer; /* setup buffer pointer */
	    resynch = FALSE;
	}

	/*
	    Get first character and if error and NOT in STREAM mode..return
	*/
	if (rxcount == 0)
	{   
	    if ((rxchar = waitforchar()) < 0)
	    {
		if ((outputmode != STREAM) || (rxchar == RXTIMEOUT))
		{
		    return(RXERRORS);
		}
	    }

	    /*
		Check to make sure the the phase bit is a '1'
		If not, then if STREAM mode, resynch
		else, return with error
	    */
	    if (!(rxchar & 0x80))
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
		     return(RXPHASEERROR);
		}
	    }
	}
	else    /* rxcount > 0 */
	{
	    /*
		Get remainder of Block of data from the serial port, recsize characters
		and store them in rxbuf
	    */
	    if ((rxchar = waitforchar()) >= 0)  /* no errors */
	    {
		/*
		   Check Phase bit
		*/
		if (rxchar & 0x80)              /* check to see that phase bit = '0' */
		{
		    if (outputmode == STREAM)
		    {
			phaseerror_count++;     /* keep track of phase errors */
			resynch = TRUE;         /* loop again flag */
			continue;
		    }
		    else
		    {
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
		    return(RXERRORS);
		}
	    }
	}
	/*
	   Store the received character
	*/
	*rxbufptr++ = rxchar;   /* store and adjust pointer */
	rxcount++;              /* increment */
    }
    while ((resynch) || (rxcount < recsize));

    /*
	Return the number of characters received
    */
    return(rxcount);
}

/*
    send_serial_cmd     -    Send Serial Command to the Bird port

    Prototype in:       serial.h

    Parameters Passed:  cmd         -   string to send to the serial point
			cmdsize     -   size of the cmd string (cmd is NOT
					NULL terminated, since the data can
					be NULL)
    Return Value:       number of characters transmitted

    Remarks:            Routine will send a string of characters to the serial
			port.  The string is pointed to by cmd and all
			characters will be sent upto but NOT including
			the NULL
*/
int send_serial_cmd(cmd,cmdsize)
unsigned char * cmd;
short cmdsize;
{
    short txcount = 0;
    unsigned char rs232tofbbcmd;

    DISABLE();

    /*
	Send the RS232 to FBB Prefice Character if non-zero
    */
    if (rs232tofbbaddr > 0)
    {
	if (rs232tofbbaddr <= 15)
	    /* pass through command 0-15 */
	    rs232tofbbcmd = (unsigned char)(0xF0 | rs232tofbbaddr);
	else
	    /* pass through command 16-31 */
	    rs232tofbbcmd = (unsigned char)(0xE0 | rs232tofbbaddr-16);

	while (send_serial_char(rs232tofbbcmd) == TXNOTEMPTY);
    }

    while (txcount < cmdsize)
    {
	/*
	    Store the character in the TX buffer
	*/
	if (send_serial_char(*cmd++) != TRUE)
	    break;

	txcount++;
    }

    /*
	Verify that the TX interrupt is enabled
	..if not, enable it so that the ISR will execute
    */
    if ((INPORTB (com_base + INTERENABLE) & TXHOLDINTENABLE) == 0)
    {
	OUTPORTB (com_base + INTERENABLE,
	    TXHOLDINTENABLE | RXDATAAVAILINTENABLE | RXLINESTATUSINTENABLE);
	OUTPORTB (com_base + INTERENABLE,
	    TXHOLDINTENABLE | RXDATAAVAILINTENABLE | RXLINESTATUSINTENABLE);
    }
    ENABLE();                   /* reenable interrupts */
    return(txcount);
}

/*
    send_serial_char    -   Send one serial char to the serial port

    Prototype in:       serial.h

    Parameters Passed:  chr     -   character to send to the serial port

    Return Value:       returns TRUE if successful, or TXBUFFERFULL if the
			TXBUF is full

    Remarks:            The routine is used to send a single character
			out to the UART if there is room in the output buffer.
			The routine checks to see if the Transmit interrupts
			are presently enabled...if not they are turned out
			so the ISR will get the character.
*/
int send_serial_char(chr)
unsigned char chr;
{
    /*
	Check for a full TX buffer...
	... 2 ways the txbufinptr can = the txbufoutptr:
		1) if the buffer is empty, which is OK
		2) if the buffer is full, which is not OK
    */
    if (txbufinptr == txbufoutptr)
	if (!txbufempty)
	    return(TXBUFFERFULL);

    /*
	Write the character to the inbufptr
    */
    *txbufinptr++ = chr;
    txbufempty = FALSE;

    /*
	Check for buffer end...wrap around if at end
    */
    if (txbufinptr == &txbuf[TXBUFSIZE])
	txbufinptr = txbuf;

    return(TRUE);
}

/*
    get_serial_char -   Get 1 Character from the serial port if one is available

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       returns the

    Remarks:            returns the receive character if successful,
			RXERRORS if recieve errors
			NODATAAVAIL if no characer available
*/
int get_serial_char()
{
	short rxchar;

    if ((!rxerrors) && (!rxbufoverruns))
    {
	/*
	    get character if available...else return
	*/
	if (rxbufinptr == rxbufoutptr)
	    return(NODATAAVAIL);

	/*
	    get the character
	*/
	rxchar = *rxbufoutptr++;

	/*
	    check for End of Rx buffer..if so, wrap pointer to start
	*/
	if (rxbufoutptr == &rxbuf[RXBUFSIZE])
	    rxbufoutptr = rxbuf;

	/*
	    return the character
	*/
	return(rxchar);
    }
    else
    {
	/*
	    Reset Error flags and Announce the Errors
	*/
	if (rxerrors)
	{
	    printf("** ERROR ** rx line errors have occured\n");
	    rxerrors = FALSE;
	}

	if (rxbufoverruns)
	{
	   printf("** ERROR ** rx buffer overrun errors have occured\n");
	   rxbufoverruns = FALSE;
	}

	return(RXERRORS);
    }

}

/*
    waitforchar         -   Wait for a Character from the Serial Port

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       returns the receive character if successful,
			RXERRORS if recieve errors,
			RXTIMEOUT if a time out occurs before a
			character is ready

    Remarks:            Routine waits for the TIMEOUTINTICKS period
			for a character

*/
int waitforchar()
{
	short rxchar;
    long starttime;

    /*
	Get the time now in ticks
    */
    starttime = GETTICKS;

    /*          
	Wait until a character is available
	....leave loop if errors or character available
    */
    while ((rxchar = get_serial_char()) == NODATAAVAIL)
    {
	/*
	    Check to see if a timeout occured
	*/
	if ((GETTICKS - starttime) > (long)((RXTIMEOUTINSECS * 1000) / TICK_MSECS))
	{
	    printf("\n** ERROR ** receiver timed out\n");
	    return(RXTIMEOUT);
	}
    }


    /*
	return if RX errors
    */
    if (rxchar < 0)
	return(RXERRORS);

    /*
	Everything is OK...return the character
    */
    return(rxchar);
}

/*
    waitforphase        -   Wait for a Character with phase bit set

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       returns the received character if successful,
			or RXERRORS if an error occurs

    Remarks:            waits for a character to be received with the
			most significant bit (bit 7) set to a '1'.  Characters
			received with bit 7 = '0' are thrown away.
			Routine waits for the TIMEOUTINTICKS period.
*/
int waitforphase()
{
	short rxchar;

    /*
	Wait until waitforchar returns a character or error
    */
    while (((rxchar = waitforchar()) & 0x80) == 0)
    {
	/*
	    return if errors
	*/
	if (rxchar < 0)
	    return(RXERRORS);
    }

    /*
	Everything is OK...return the character
    */
    return(rxchar);
}


/*
    serialisr   -   Serial Interrupt Service Routine

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            Routine processes the interrupt request from the
			8250 UART.  There are four possible interrupts from
			the UART...all are processed while in the ISR.
			Note that for the HIGHC users, the routine is
			called from the assembly module, which has
			set the DS to our own Data Segment, which will
			allow DOS to be interruptable since DOS will be
			operating in REAL mode via the DOS Extender
*/
#ifdef HIGHC
void serialisr(void)  /* called from the assembly code */
#else
INTTYPE serialisr()
#endif
{
	short intid;      /* holds the interrupt ID from the UART */
	short txchar;     /* Character to transmit */

#ifndef DPMC
    ENABLE();         /* enable higher priority interrupts to occur */
#endif

    /*
	Verify that the Interrupt is from the UART
	...do all the possible pending interrupts while here...until
	there are NO interrupts pending
    */

    while (!((intid = INPORTB(com_base + INTERIDENT)) & 1)) /* bit 0 = 0 if interrupts pending */
    {
	/*
	    Do the Serial Interrupt in Priority order
	    ..RXLINESTATUS, RXDATAAVAIL,TXEMPTY, MODEMSTATUS
	*/
	switch (intid)
	{
	    /*
		Line Status
		...just increment error counter
	    */
	    case RXLINESTATUS:  /* line status changed ... check RX errors */
		/*
		    Get the error from Linestatus
		*/
		if ((rxerrorvalue = (INPORTB(com_base + LINESTATUS) & RXERRORMSK)) != 0) /* clears interrupt */
		    rxerrors = TRUE;

		break;

	    /*
		RX Data Available
		...get the byte and store it in the RX circular buffer
		.....check for RX buffer overruns when storing character
	    */
	    case RXDATAAVAIL:
		/*
		    Get the RX data and store in the circular buffer
		*/
		*rxbufinptr++ = INPORTB(com_base + RXBUF);

		/*
		    Check for RX circular buffer overrun
		*/
		if (rxbufinptr == rxbufoutptr)          /* ck overrrun? */
		    rxbufoverruns=TRUE;                 /* increment overrun count */

		/*
		    Check for top of buffer...adjust if necessary
		*/
		if (rxbufinptr == &rxbuf[RXBUFSIZE])    /* at top ? */
		    rxbufinptr = rxbuf;                 /* reset */

		break;

	    /*
		TX Holding Register Empty
		...transmit a character from the TX buffer if one is available
		else, shut down the TX interrupt until more characters are
		available
	    */
	    case TXEMPTY:
		/*
		    Get the Character to transmit
		*/
		txchar = *txbufoutptr++;

		/*
		    check for top of buffer
		    ...reset if at top
		*/
		if (txbufoutptr == &txbuf[TXBUFSIZE])
		    txbufoutptr = txbuf;

		if (txbufoutptr == txbufinptr)          /* no data to send */
		{
		    /*
			Disable the Tx Interrupt Enable
			....don't bother until more TX chars in buffer
		    */
		    OUTPORTB(com_base + INTERENABLE,
			RXDATAAVAILINTENABLE | RXLINESTATUSINTENABLE);
		    OUTPORTB(com_base + INTERENABLE,
			RXDATAAVAILINTENABLE | RXLINESTATUSINTENABLE);

		    /*
			Set flag to indicate buffer empty
		    */
		    txbufempty = TRUE;
		}
		/*
		    Send the next TX character and increment the pointer
		*/
		OUTPORTB(com_base + TXBUF, txchar);

		break;

	    /*
		Modem Status Change
		...currently should never get here since it is never enabled,
		but if we do...clear the request by reading the register
	    */
	    case MODEMSTATUSCHG:        /* CTS, DSR, RI, DCD change */
	       INPORTB(com_base + MODEMSTATUS);         /* clear the request */
	}
    }

    /*
	Send End of Interrupt Command to the 8259
    */
    PCPIC_OUTEOI;

    return;         /* go home via IRET */
}

#endif      /* DOS */

