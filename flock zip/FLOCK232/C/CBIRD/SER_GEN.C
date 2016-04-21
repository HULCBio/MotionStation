/****************************************************************************
*****************************************************************************
    ser_gen.c       Generic Serial Routines for
		    RS232 PC Compatible and
		    RS485 Quatech Card (w/16550 UART Support)

    written for:    Ascension Technology Corporation
		    PO Box 527
		    Burlington, Vermont  05402
		    802-655-7879


    written by:     Jeff Finkelstein
		    Microprocessor Designs, Inc
		    PO Box 160
		    Shelburne, Vermont  05482
		    802-985-2535

    Modification History:

    9/16/93         jf  - created from serdpcin.c
    12/30/93        jf  - updated to allow this module to send data
			  out the RS232 port if the comport is configured for
			  an RS232 port
    1/8/94          jf  - restore comport now disables the FIFO

	   <<<< Copyright 1993 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <time.h>           /* clock functions */
#include <dos.h>            /* needed for SETVECT/GETVECT */
#include "compiler.h"
#include "asctech.h"
#include "menu.h"
#include "pctimer.h"
#include "pcpic.h"
#include "birdmain.h"
#include "ser_gen.h"

/*
    Local Prototypes
*/
void interrupt far serialisr_com1(void);
void interrupt far serialisr_com2(void);
void interrupt far serialisr_com3(void);
void interrupt far serialisr_com4(void);
void serial_isr(short comport);
short ckuartfifo(short comport);


/*
    Base address of all the UARTS
*/
short com_base[NUMCOMPORTS] = {COM1BASE,COM2BASE,COM3BASE,COM4BASE};

/*
    flag indicates serial port saved
*/
short serialconfigsaved[NUMCOMPORTS] = {FALSE,FALSE,FALSE,FALSE};

/*
    Flag indicates the the FIFO is enabled
*/
short fifo_enabled[NUMCOMPORTS] = {FALSE,FALSE,FALSE,FALSE};

/*
    Value indicates that the Port is an RS485 Port
*/
short port_type[NUMCOMPORTS];

/*
    UART variable Storage
*/
unsigned char olddivisorlow[NUMCOMPORTS];            /* holds the old divisor low value */
unsigned char olddivisorhigh[NUMCOMPORTS];           /* holds the old divisor high value */
unsigned char oldlinecont[NUMCOMPORTS];              /* holds the old line control value */
unsigned char oldinterenable[NUMCOMPORTS];           /* holds the old interrupt enable value */
unsigned char oldmodemcont[NUMCOMPORTS];             /* holds the old modem control value */


/*
    Storage for the old serial interrupt vector
*/
void (interrupt far * oldserialintvect[NUMCOMPORTS])();  /* old serial interrupt vector */

/*
    Error Counters
*/

    short phaseerror_count[NUMCOMPORTS] = {0,0,0,0};                  /* holds the phase errors */
    short rxerrorvalue[NUMCOMPORTS] = {0,0,0,0};                      /* holds the rx error value */
	short rxbufoverruns[NUMCOMPORTS] = {FALSE,FALSE,FALSE,FALSE};     /* rx buffer overrun flag */
	short rxerrors[NUMCOMPORTS] = {FALSE,FALSE,FALSE,FALSE};          /* rx line errors flag */
	short txbufempty[NUMCOMPORTS] = {TRUE,TRUE,TRUE,TRUE};            /* tx buffer empty flag */

/*
    RX buffer
*/
    unsigned char rxbuf[NUMCOMPORTS][RXBUFSIZE];  /* rx buffer */
    unsigned char * rxbufinptr[NUMCOMPORTS];      /* rx buffer input pointer */
    unsigned char * rxbufoutptr[NUMCOMPORTS];     /* rx buffer output pointer */

/*
    TX buffer
*/
    unsigned char txbuf[NUMCOMPORTS][TXBUFSIZE];  /* tx buffer */
    unsigned char * txbufinptr[NUMCOMPORTS];      /* tx buffer input pointer */
    unsigned char * txbufoutptr[NUMCOMPORTS];     /* tx buffer output pointer */

/*
	tick timing varaible
*/

    unsigned int tick_msec = 18;        /* dos tick time in msec */


/*
    configserialport    -   Configure the Serial Port connected to the BIRD

    Prototype in:       serial.h

    Parameters Passed:  short comport

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
int configserialport(comport,baud,type)
short comport;
long baud;
short type;
{
    unsigned divisor;

    /*
	Disable the interrupts
    */
    OUTPORTB(com_base[comport] + INTERENABLE, 0);

    /*
	Set the Global Port Type
    */
    port_type[comport] = type;

    /*
	Verify the comport and set the Base Address
    */
    switch (comport)
    {
	case COM1:
	    PCPIC_MASK(COM1IRQ);
	    SETVECT(COM1INTERRUPT,serialisr_com1);
	    break;

	case COM2:
	    PCPIC_MASK(COM2IRQ);
	    SETVECT(COM2INTERRUPT,serialisr_com2);
	    break;

	case COM3:
	    PCPIC_MASK(COM3IRQ);
	    SETVECT(COM3INTERRUPT,serialisr_com3);
	    break;

	case COM4:
	    PCPIC_MASK(COM4IRQ);
	    SETVECT(COM4INTERRUPT,serialisr_com4);
	    break;

	default:
	    printf("\n** ERROR ** invalid COM port\n");
	    return(FALSE);
    }

    /*
	assume that there are NO CHARACTERS CURRENTLY in the Tx Buffer
	and change the baud rate
    */
    OUTPORTB(com_base[comport] + LINECONT, DLAB);

    /*
	Set the least significant byte and then the most significant
	byte of the baud rate divisor
    */
    switch (port_type[comport])
    {
	case RS485_PORT:
	    divisor = 500000L/baud;
	    break;
	case RS232_PORT:
	    divisor = 115200L/baud;
	    break;
	default:
	    printf("\n\r** ERROR **  illegal Port Type in configserial\n\r");
	    return(FALSE);
    }
    OUTPORTB(com_base[comport], (divisor & 0xff));
    OUTPORTB(com_base[comport] + 1, ((divisor & 0xff00) >> 8));

    /*
	Set the Stop Bits = 1, Word Length = 8 and Parity = None
    */
    OUTPORTB(com_base[comport] + LINECONT, STOP_WORDLEN_PARITY);

    /*
	Deassert DTR...Make the TRANCEIVER go to Receive.. RS485
	Deassert DTR...Enable Output from the FOB.. RS232
	Deassert RTS...else the system will reset
	Assert OUT2...needed to allow interrupts to occur on PC compatible
	    serial I/O cards
    */
    switch(port_type[comport])
    {
	case RS232_PORT:
	    OUTPORTB(com_base[comport] + MODEMCONT, DTRON | OUT2);
	    break;
	case RS485_PORT:
	    OUTPORTB(com_base[comport] + MODEMCONT, OUT2);
	    break;
    }

    /*
	Check if it is a 16550 UART with a FIFO
	..use it if it is available..setup the receive trigger to 14 characters
    */
    OUTPORTB(com_base[comport] + FCR, 0);   /* disable the FIFO */
    fifo_enabled[comport] = ckuartfifo(comport);
    if (fifo_enabled[comport])
    {
	OUTPORTB(com_base[comport] + FCR, 0xC0 + 1);  /* enable the FIFO..0xc0 is for
						trigger level = 14 bytes */
    }
    else
    {
	/*
	    RS485 Ports Must have the FIFO for the DUAL system
	*/
	if (port_type[comport] == RS485_PORT)
	{
	    printf("\n\r** ERROR ** COM%d does not have a 16550 type UART\n\r",comport+1);
	    return(FALSE);
	}
    }

    /*
	Clear the Rx Buffer and Rx Errors
    */
    clear_rx(comport);

    /*
	Enable the 8259 Mask register for serial interrupts
    */
    switch (comport)
    {
	case COM1:
	     PCPIC_UNMASK(COM1IRQ);
	     break;
	case COM2:
	     PCPIC_UNMASK(COM2IRQ);
	     break;
	case COM3:
	     PCPIC_UNMASK(COM3IRQ);
	     break;
	case COM4:
	     PCPIC_UNMASK(COM4IRQ);
	     break;
    }

    return(TRUE);
}

/*
    ckuartfifo          Check for a Uart FIFO

    Prototype in:       serial.h

    Parameters Passed:  short comport - comport of the UART

    Return Value:       TRUE if the UART has a FIFO
			FALSE otherwise

    Remarks:            routine checks if the UART is a 16550 Type by
			trying to enable the FIFO and then checking if the
			FIFO did in fact become enabled

*/
short ckuartfifo(comport)
short comport;
{
    OUTPORTB(com_base[comport] + FCR, 7); /* Enable and Reset */
    if ((INPORTB(com_base[comport] + INTERIDENT) & 0xC0) != 0xC0)
	return(FALSE);
    OUTPORTB(com_base[comport] + FCR, 0); /* Disable */
    if ((INPORTB(com_base[comport] + INTERIDENT) & 0xC0) == 0xC0)
	return(FALSE);
    OUTPORTB(com_base[comport] + FCR, 1); /* Enable */
    if ((INPORTB(com_base[comport] + INTERIDENT) & 0xC0) != 0xC0)
	return(FALSE);

    return(TRUE);
}

/*
    saveserialconfig    -   save serial port configuration

    Prototype in:       serial.h

    Parameters Passed:  short comport

    Return Value:       void

    Remarks:            saves the current configuration of the serial port

*/
int saveserialconfig(comport)
short comport;
{
    /*
	Save the Serial interrupt Vector
    */
    switch (comport)
    {
	case COM1:
	    oldserialintvect[comport] = GETVECT(COM1INTERRUPT);
	    break;
	case COM2:
	    oldserialintvect[comport] = GETVECT(COM2INTERRUPT);
	    break;
	case COM3:
	    oldserialintvect[comport] = GETVECT(COM3INTERRUPT);
	    break;
	case COM4:
	    oldserialintvect[comport] = GETVECT(COM4INTERRUPT);
	    break;
    }

    /*
	Save the Current Com Port Configuration Regs including:
	    Divisor, Interrupt Enable, Line Control, Modem Control
    */
    oldlinecont[comport] = INPORTB(com_base[comport] + LINECONT);         /* save the old line control value */
    OUTPORTB(com_base[comport] + LINECONT, DLAB);                /* set DLAB to get the divisor */
    olddivisorlow[comport] = INPORTB(com_base[comport] + DIVISORLOW);     /* save the divisor low */
    olddivisorhigh[comport] = INPORTB(com_base[comport] + DIVISORHIGH);   /* save the divisor high */
    OUTPORTB(com_base[comport] + LINECONT,oldlinecont[comport] & 0x7f);   /* reset DLAB to get the divisor */
    oldinterenable[comport] = INPORTB(com_base[comport] + INTERENABLE);   /* save the interrupt enable reg */
    oldmodemcont[comport] = INPORTB(com_base[comport] + MODEMCONT);       /* save the modem control reg */

    serialconfigsaved[comport] = TRUE;

    return(TRUE);
}

/*
    restoreserialconfig -   Restore the original serial port configuration

    Prototype in:       serial.h

    Parameters Passed:  short comport

    Return Value:       void

    Remarks:            restores the configuration of the serial port
*/
void restoreserialconfig(comport)
short comport;
{
    /*
	Do not Restore if not previously stored
    */
    if (!serialconfigsaved[comport])
	return;

    /*
	Disable Serial Interrupts on 8259 while initializing port
	and switching interrupt vectors
    */
    switch (comport)
    {
	case COM1:
	    PCPIC_MASK(COM1IRQ);
	    break;

	case COM2:
	    PCPIC_MASK(COM2IRQ);
	    break;

	case COM3:
	    PCPIC_MASK(COM3IRQ);
	    break;

	case COM4:
	    PCPIC_MASK(COM4IRQ);
	    break;
    }

    /*
	Restore the Com Port Configuration Regs including:
	    Divisor, Interrupt Enable, Line Control, Modem Control
    */
    OUTPORTB(com_base[comport] + LINECONT, DLAB);                /* set DLAB to get the divisor */
    OUTPORTB(com_base[comport], olddivisorlow[comport]);                   /* restore the divisor low */
    OUTPORTB(com_base[comport] + 1,olddivisorhigh[comport]);              /* restore the divisor high */
    OUTPORTB(com_base[comport] + LINECONT,oldlinecont[comport]);          /* reset DLAB to get the divisor */
    OUTPORTB(com_base[comport] + INTERENABLE,oldinterenable[comport]);    /* restore the interrupt enable reg */
    OUTPORTB(com_base[comport] + MODEMCONT,oldmodemcont[comport]);        /* restore the interrupt enable reg */

    /*
	Restore the Serial Vector
	..disable interrupts during restoration
    */
    DISABLE();
    switch (comport)
    {
	case COM1:
	    SETVECT(COM1INTERRUPT,oldserialintvect[comport]);
	    break;
	case COM2:
	    SETVECT(COM2INTERRUPT,oldserialintvect[comport]);
	    break;
	case COM3:
	    SETVECT(COM3INTERRUPT,oldserialintvect[comport]);
	    break;
	case COM4:
	    SETVECT(COM4INTERRUPT,oldserialintvect[comport]);
	    break;
    }
    ENABLE();

    /*
	Disable the FIFO for other applications
    */
    if (fifo_enabled[comport])
	OUTPORTB(com_base[comport] + FCR, 0);   /* disable the FIFO */
}


/*
    clearrx             -   Read the characters out of the Rx buffer if available

    Prototype in:       serial.h

    Parameters Passed:  short comport

    Return Value:       void

    Remarks:            clears the rx buffer and rx errors if any

*/
void clear_rx(comport)
short comport;
{
    short i;

    phaseerror_count[comport] = 0;                       /* clear phase error cntr */
    rxerrorvalue[comport] = 0;                           /* clear error byte */
    rxerrors[comport] = FALSE;                           /* clear Rx error flag */
    rxbufoverruns[comport] = FALSE;                      /* clear Buf Overrun flag */
    rxbufinptr[comport] = rxbufoutptr[comport] = rxbuf[comport];           /* re initialize buffer ptrs */
    txbufinptr[comport] = txbufoutptr[comport] = txbuf[comport];           /* re initialize buffer ptrs */

    /*
       Clear the Interrupts
    */
    while (!(INPORTB(com_base[comport] + INTERIDENT) && 0x01))
    {
	INPORTB(com_base[comport] + RXBUF);       /* Clear the Data */
	INPORTB(com_base[comport] + MODEMSTATUS); /* Clear the Modem Status */
	INPORTB(com_base[comport] + LINESTATUS);  /* Clear the Line Status */
    }
}

/*
    get_serial_record   - Get a record from the serial port

    Prototype in:       serial.h

    Parameters Passed:  short comport
			rxbuf       -   pointer to a buffer to store the
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
int get_serial_record(comport, rxbuffer, recsize, outputmode)
short comport;
unsigned char * rxbuffer;
short recsize;
short outputmode;
{
	short rxcount;
	short rxchar;
	short resynch;
    char * rxbufptr;

    resynch = TRUE;

    do
    {
	if  (resynch)
	{
	    rxcount = 0;                /* initialize char counter */
	    rxbufptr = rxbuffer;        /* setup buffer pointer */
	    resynch = FALSE;
	}

	/*
	    Get first character and if error and NOT in STREAM mode..return
	*/
	if (rxcount == 0)
	{
	    if ((rxchar = waitforchar(comport)) < 0)
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
		    phaseerror_count[comport]++;
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
	    if ((rxchar = waitforchar(comport)) >= 0)  /* no errors */
	    {
		/*
		   Check Phase bit
		*/
		if (rxchar & 0x80)              /* check to see that phase bit = '0' */
		{
		    if (outputmode == STREAM)
		    {
			phaseerror_count[comport]++;     /* keep track of phase errors */
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
		    phaseerror_count[comport]++;     /* keep track of phase errors */
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

    Parameters Passed:  short comport
			cmd         -   string to send to the serial point
			cmdsize     -   size of the cmd string (cmd is NOT
					NULL terminated, since the data can
					be NULL)
    Return Value:       number of characters transmitted

    Remarks:            Routine will send a string of characters to the serial
			port.  The string is pointed to by cmd and all
			characters will be sent upto but NOT including
			the NULL
*/
int send_serial_cmd(comport, cmd, cmdsize)
short comport;
unsigned char * cmd;
short cmdsize;
{
    short txcount = 0;

    DISABLE();
    /*
	Disable the Receive Interrupts
    */
    OUTPORTB(com_base[comport] + INTERENABLE, 0);
    OUTPORTB(com_base[comport] + INTERENABLE, 0);

    /*
	Turn the Transmitter to Transmit
    */
    if(port_type[comport] == RS485_PORT)
	 OUTPORTB(com_base[comport] + MODEMCONT, DTRON + OUT2);

    /*
	Transmit the CMD and DATA Characters NOW
    */
    while (txcount < cmdsize)
    {
	/*
	    Store the character in the TX buffer
	*/
	if (txcount == 0)
	{
	    if(port_type[comport] == RS485_PORT)
		while (send_serial_cmdchar(comport,*cmd) == TXBUFFERFULL);
	    else
		while (send_serial_datachar(comport,*cmd) == TXBUFFERFULL);
	}
	else
	{
	    while (send_serial_datachar(comport,*cmd) == TXBUFFERFULL);
	}
	cmd++;
	txcount++;
    }

    /*
	Clear the Receive Buffer in case of a dirty char
    */

    while (INPORTB(com_base[comport] + LINESTATUS) & DATARDY)
	INPORTB(com_base[comport] + RXBUF);

    /*
	Turn the Transceiver to Receive
    */
    if(port_type[comport] == RS485_PORT)
	OUTPORTB(com_base[comport] + MODEMCONT, OUT2);

    /*
	Enable the Receive Interrupts
    */
    OUTPORTB (com_base[comport] + INTERENABLE,
	RXDATAAVAILINTENABLE | RXLINESTATUSINTENABLE);
    OUTPORTB (com_base[comport] + INTERENABLE,
	RXDATAAVAILINTENABLE | RXLINESTATUSINTENABLE);

    ENABLE();
    return(txcount);
}

/*
    send_serial_cmdchar    -   Send one serial CMD char to the serial port
    send_serial_datachar    -   Send one serial DATA char to the serial port

    Prototype in:       serial.h

    Parameters Passed:  short comport
			chr     -   character to send to the serial port

    Return Value:       returns TRUE if successful, or TXBUFFERFULL if the
			TXBUF is full

    Remarks:            The routine is used to send a single character
			out to the UART if there is room in the output buffer.
			The routine checks to see if the Transmit interrupts
			are presently enabled...if not they are turned out
			so the ISR will get the character.
*/
int send_serial_cmdchar(comport,chr)
short comport;
unsigned char chr;
{
    /*
	Check for a full TX Hardware buffer...
    */
    if (!(INPORTB(com_base[comport] + LINESTATUS) & TXSHIFTEMPTY))
	return(TXBUFFERFULL);

    /*
	Set the Parity to a MARK
    */
    if(port_type[comport] == RS485_PORT)
	OUTPORTB(com_base[comport] + LINECONT, STOP_WORDLEN_MARKPARITY);

    /*
	Write the character to the Hardware
    */
    OUTPORTB(com_base[comport] + TXBUF, chr);

    /*
	Wait for the Buffer to EMPTY
    */
    while (!(INPORTB(com_base[comport] + LINESTATUS) & TXSHIFTEMPTY));

    /*
	Set the Parity back to a SPACE
    */
    if(port_type[comport] == RS485_PORT)
	OUTPORTB(com_base[comport] + LINECONT, STOP_WORDLEN_SPACEPARITY);

    return(TRUE);
}

int send_serial_datachar(comport,chr)
short comport;
unsigned char chr;
{
    /*
	Check for a full TX Hardware buffer...
    */
    if (!(INPORTB(com_base[comport] + LINESTATUS) & TXSHIFTEMPTY))
	return(TXBUFFERFULL);

    /*
	Write the character to the Hardware
    */
    OUTPORTB(com_base[comport] + TXBUF, chr);

    /*
	Wait for the Buffer to EMPTY
    */
    while (!(INPORTB(com_base[comport] + LINESTATUS) & TXSHIFTEMPTY));


    return(TRUE);
}

/*
    get_serial_char -   Get 1 Character from the serial port if one is available

    Prototype in:       serial.h

    Parameters Passed:  short comport

    Return Value:       returns the

    Remarks:            returns the receive character if successful,
			RXERRORS if recieve errors
			NODATAAVAIL if no characer available
*/
int get_serial_char(comport)
short comport;
{
	short rxchar;

    if ((!rxerrors[comport]) && (!rxbufoverruns[comport]))
    {
	/*
	    get character if available...else return
	*/
	if (rxbufinptr[comport] == rxbufoutptr[comport])
	    return(NODATAAVAIL);

	/*
	    get the character
	*/
	rxchar = *rxbufoutptr[comport]++;

	/*
	    check for End of Rx buffer..if so, wrap pointer to start
	*/
	if (rxbufoutptr[comport] == &rxbuf[comport][RXBUFSIZE])
	    rxbufoutptr[comport] = rxbuf[comport];

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
	if (rxerrors[comport])
	{
	    DISABLE();
	    printf("** ERROR ** rx line errors have occured\n");
	    rxerrors[comport] = FALSE;
	    ENABLE();
	}

	if (rxbufoverruns[comport])
	{
	    DISABLE();
	    printf("** ERROR ** rx buffer overrun errors have occured\n");
	    rxbufoverruns[comport] = FALSE;
	    ENABLE();
	}

	return(RXERRORS);
    }

}

/*
    waitforchar         -   Wait for a Character from the Serial Port

    Prototype in:       serial.h

    Parameters Passed:  short comport

    Return Value:       returns the receive character if successful,
			RXERRORS if recieve errors,
			RXTIMEOUT if a time out occurs before a
			character is ready

    Remarks:            Routine waits for the TIMEOUTINTICKS period
			for a character

*/
int waitforchar(comport)
short comport;
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
    while ((rxchar = get_serial_char(comport)) == NODATAAVAIL)
    {
	/*
	    Check to see if a timeout occured
	*/
	if ((GETTICKS - starttime) > (long) (RXTIMEOUTINSECS * 1000) / tick_msec)
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

    Parameters Passed:  short comport

    Return Value:       returns the received character if successful,
			or RXERRORS if an error occurs

    Remarks:            waits for a character to be received with the
			most significant bit (bit 7) set to a '1'.  Characters
			received with bit 7 = '0' are thrown away.
			Routine waits for the TIMEOUTINTICKS period.
*/
int waitforphase(comport)
short comport;
{
	short rxchar;

    /*
	Wait until waitforchar returns a character or error
    */
    while (((rxchar = waitforchar(comport)) & 0x80) == 0)
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
    serialisr           -   Serial Interrupt Service Routine for COM*

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            Routine processes the interrupt request from the
			8250 UART.  There are four possible interrupts from
			the UART...all are processed while in the ISR.
*/
void interrupt far serialisr_com1()
{
    serial_isr(COM1);
    return;         /* go home via IRET */
}
void interrupt far serialisr_com2()
{
    serial_isr(COM2);
    return;         /* go home via IRET */
}
void interrupt far serialisr_com3()
{
    serial_isr(COM3);
    return;         /* go home via IRET */
}
void interrupt far serialisr_com4()
{
    serial_isr(COM4);
    return;         /* go home via IRET */
}

void serial_isr(comport)
short comport;
{
	short intid;      /* holds the interrupt ID from the UART */
	short txchar;     /* Character to transmit */
    short sts;

    ENABLE();       /* enable higher priority interrupts to occur */

    /*
	Verify that the Interrupt is from the UART
	...do all the possible pending interrupts while here...until
	there are NO interrupts pending
    */

    while (!((intid = (0x0F & INPORTB(com_base[comport] + INTERIDENT))) & 1)) /* bit 0 = 0 if interrupts pending */
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
		if ((rxerrorvalue[comport] = (INPORTB(com_base[comport] + LINESTATUS) & RXERRORMSK)) != 0) /* clears interrupt */
		    rxerrors[comport] = TRUE;

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
		*rxbufinptr[comport]++ = INPORTB(com_base[comport] + RXBUF);

		/*
		    Check for RX circular buffer overrun
		*/
		if (rxbufinptr[comport] == rxbufoutptr[comport])          /* ck overrrun? */
		    rxbufoverruns[comport]=TRUE;                 /* increment overrun count */

		/*
		    Check for top of buffer...adjust if necessary
		*/
		if (rxbufinptr[comport] == &rxbuf[comport][RXBUFSIZE])    /* at top ? */
		    rxbufinptr[comport] = rxbuf[comport];                 /* reset */

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
		txchar = *txbufoutptr[comport]++;

		/*
		    check for top of buffer
		    ...reset if at top
		*/
		if (txbufoutptr[comport] == &txbuf[comport][TXBUFSIZE])
		    txbufoutptr[comport] = txbuf[comport];

		if (txbufoutptr[comport] == txbufinptr[comport])          /* no data to send */
		{
		    /*
			Disable the Tx Interrupt Enable
			....don't bother until more TX chars in buffer
		    */
		    OUTPORTB(com_base[comport] + INTERENABLE,
			RXDATAAVAILINTENABLE | RXLINESTATUSINTENABLE);
		    OUTPORTB(com_base[comport] + INTERENABLE,
			RXDATAAVAILINTENABLE | RXLINESTATUSINTENABLE);

		    /*
			Set flag to indicate buffer empty
		    */
		    txbufempty[comport] = TRUE;
		}
		/*
		    Send the next TX character and increment the pointer
		*/
		OUTPORTB(com_base[comport] + TXBUF, txchar);

		break;

	    /*
		Modem Status Change
		...currently should never get here since it is never enabled,
		but if we do...clear the request by reading the register
	    */
	    case MODEMSTATUSCHG:        /* CTS, DSR, RI, DCD change */
		INPORTB(com_base[comport] + MODEMSTATUS);         /* clear the request */

	    case FIFORECV:
		while ((sts = INPORTB(com_base[comport] + LINESTATUS)) & DATARDY)
		{
		    /*
			Check for Errors
		    */
		    if (sts & FIFORCVERR)
		    {
			rxerrors[comport] = TRUE;
			break;
		    }

		    /*
			Get the RX data and store in the circular buffer
		    */
		    *rxbufinptr[comport]++ = INPORTB(com_base[comport] + RXBUF);

		    /*
			Check for RX circular buffer overrun
		    */
		    if (rxbufinptr[comport] == rxbufoutptr[comport])          /* ck overrrun? */
			rxbufoverruns[comport]=TRUE;                 /* increment overrun count */

		    /*
			Check for top of buffer...adjust if necessary
		    */
		    if (rxbufinptr[comport] == &rxbuf[comport][RXBUFSIZE])    /* at top ? */
			rxbufinptr[comport] = rxbuf[comport];                 /* reset */

		}
		break;
	}
    }

    /*
	Send End of Interrupt Command to the 8259
    */
    PCPIC_OUTEOI;
}
