/****************************************************************************
*****************************************************************************
    serdpcpl.c      - Serial Routines - DOS PC Compatible

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-655-7879


    written by:     Jeff Finkelstein

    Modification History:

    10/18/90        jf  - released
    11/12/90        jf  - add getdosticks() to allow Polled mode operation
                          at 19200 even on a pretty slow machine
    4/16/91         jf  - renamed file to serdpcpl.c
    6/18/91         jf  - added FOB baudrates
    12/5/93         jf  - fixed bug in getserialrecord to assure that a
                          character with an error does not get into the
                          rxbuffer
    12/23/92        jf  - added baudratebit definitions to allow
                          for compatibility with UNIX
    1/31/93         jf  - send_serial_cmd modified to be able to send out
                          rs232 to fbb commands to addr 30
    10/21/93        jf  - remove getdosticks() and replaced with GETTICKS

           <<<< Copyright 1990 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <time.h>           /* clock functions */
#include <dos.h>            /* int86 call */
#include "asctech.h"
#include "compiler.h"
#include "menu.h"
#include "pctimer.h"
#include "serial.h"

/*
    Prototype for DOS Systems Only
*/
void interrupt far serialisr(void);

/*
    Global Variables
*/
	short com_base = COM1BASE;           /* holds the base address of the 8250 */
	short comport = COM1;                   /* holds the comport # */

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

	short phaseerror_count = 0;      /* holds the phase errors */
	short rxerrors = 0;              /* holds the rx line errors */

/*
    Define RS232 to FBB Global Address
*/
    short rs232tofbbaddr = 0;


/*
    configserialport    -   Configure the Serial Port connected to the BIRD

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       TRUE if successfull, else FALSE

    Remarks:
                        Unfortunately, the PC ROM BIOS does NOT support baud
                        rates upto 19200. Therefore, this routine must talk
                        directly to the hardware to configure the serial port
                        ...this is not a problem in a PC environment since the
                        I/O map is fixed for COM1 and COM2.

                                *** NOTE ***

    The 8250 UART cannot withstand back to back writes (OUTs).  The
    compiler does not generate contiguous 'out dx,al' instructions
    and therefore there are delays between the OUTPUTs.  If written in
    assembly language, the typical BIOS type delay is a 'jmp' to the next
    instruction. For example...
                                out dx,al       ; output to serial port
                                jmp $+2         ; jump to the PC + 2
                                out dx,al       ; output to serial port
                        or
                                out dx,al       ; output to serial port
                                clc             ; clear carry
                                jnc $+2         ; jump to the PC + 2
                                out dx,al       ; output to serial port


*/
int configserialport(void)
{
    unsigned divisor;

    /*
        Verify the comport and set the Base Address
    */
    switch (comport)
    {
        case COM1:
            com_base = COM1BASE;                /* set the new I/O addr */
            break;
        case COM2:
            com_base = COM2BASE;                /* set the new I/O addr */
            break;
        default:
            printf("\n** ERROR ** invalid COM port\n");
            return(FALSE);
    }

    /*
        disable the interrupts
    */
    OUTPORTB(com_base + INTERENABLE, 0);

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
        Clear the Rx Buffer
    */
    clear_rx();

    /*
        Assert DTR...just in case the cable uses the DTR signal
    */
    OUTPORTB(com_base + MODEMCONT,1);

    return(TRUE);
}

/*
    saveserialconfig    -   save serial port configuration

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            saves the current configuration of the serial port

*/
int saveserialconfig()
{
    /*
        Save the Current Com Port Configuration Regs including:
            Divisor, Interrupt Enable, Line Control, Modem Control
    */
    oldlinecont = INPORTB(com_base + LINECONT);         /* save the old line control value */
    OUTPORTB(com_base + LINECONT, DLAB);                /* set DLAB to get the divisor */
    olddivisorlow = INPORTB(com_base);                  /* save the divisor low */
    olddivisorhigh = INPORTB(com_base + 1);             /* save the divisor high */
    OUTPORTB(com_base + LINECONT,oldlinecont & 0x7f);   /* reset DLAB to get the divisor */
    oldinterenable = INPORTB(com_base + INTERENABLE);   /* save the interrupt enable reg */
    oldmodemcont = INPORTB(com_base + MODEMCONT);       /* save the interrupt enable reg */

    return(TRUE);
}

/*
    restoreserialconfig -   Restore the original serial port configuration

    Prototype in:       serial.h

    Parameters Passed:  void

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
        Restore the Com Port Configuration Regs including:
            Divisor, Interrupt Enable, Line Control, Modem Control
    */
    OUTPORTB(com_base + LINECONT, DLAB);                /* set DLAB to get the divisor */
    OUTPORTB(com_base,olddivisorlow);                   /* restore the divisor low */
    OUTPORTB(com_base + 1,olddivisorhigh);              /* restore the divisor high */
    OUTPORTB(com_base + LINECONT,oldlinecont);          /* reset DLAB to get the divisor */
    OUTPORTB(com_base + INTERENABLE,oldinterenable);    /* restore the interrupt enable reg */
    OUTPORTB(com_base + MODEMCONT,oldmodemcont);        /* restore the interrupt enable reg */
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
    phaseerror_count = 0;                       /* clear the phase counter */

    while (get_serial_char() != NODATAAVAIL);   /* get chars */
    INPORTB(com_base + LINESTATUS);             /* clear errors */
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
int get_serial_record(rxbuf, recsize, outputmode)
unsigned char * rxbuf;
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
            rxbufptr = rxbuf;           /* setup buffer pointer */
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
                    clear_rx();
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
                     clear_rx();
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
                        clear_rx();
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
                    clear_rx();
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
            Wait until the character goes out OK
        */
        while ((send_serial_char(*cmd)) == TXNOTEMPTY);

        /*
            point to the next character
        */
        cmd++;
        txcount++;
    }
    return(txcount++);
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
	short linestatus;

    /*
        Get line status and check if character is available
            else return
    */
    if ((linestatus = INPORTB(com_base + LINESTATUS)) & DATARDY)
    {
        /*
            check for errors and return
        */
        if ((rxerrors = (linestatus & RXERRORMSK)) != 0)
            return(RXERRORS);

        /*
            Send back the RX data
        */
        return(INPORTB(com_base + RXBUF));
    }
    else
    {
        /*
            check for errors and return
        */
        if ((rxerrors = (linestatus & RXERRORMSK)) != 0)
            return(RXERRORS);

        return(NODATAAVAIL);
    }
}
/*
    send_serial_char    -   Send one serial char to the serial port

    Prototype in:       serial.h

    Parameters Passed:  chr     -   character to send to the serial port

    Return Value:       returns TRUE if successful, or TXNOTEMPTY if
                        cannot send because the holding register is not
                        empty

    Remarks:
*/
int send_serial_char(chr)
unsigned char chr;
{

    /*
        Get line status and check if transmit holding register is empty
            else return TXNOTEMPTY
    */
    if (!(INPORTB(com_base + LINESTATUS) & TXHOLDEMPTY))
            return(TXNOTEMPTY);

    /*
        Else, Transmit the Character
    */
    OUTPORTB(com_base + TXBUF, (char) chr);
    return(TRUE);
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

