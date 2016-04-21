/****************************************************************************
*****************************************************************************
    serknr.c        - Serial Routines, Kernighan and Ritchie Compatible

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-655-7879


    written by:     Jeff Finkelstein

    Modification History:
    4/8/91      jf  - created
    4/9/91      jf  - added COMPORT1 and COMPORT2 strings for DOS
    4/13/91     jf  - added system command for Com configuration
    4/15/91     jf  - simplified get_serial_record
    4/23/91     jf  - removed IO.h for KNR systems
                jf  - removed O_BINARY
    4/30/91     jf  - removed references to DOS.. SERKNR.c is no longer
                      DOS compatible..DOS is NOT capabable of reasonable
                      serial communication control!!!
    11/3/92     jf  - baudspeedbits now initialized to B9600 for UNIX
    12/22/92    jf  - updated for SGI compatibility..note that
                      get_serial_record has been modified to return
                      the most recent (newest) record from the BIRD
    12/29/92    jf  - moved all #ifdefs and #defines to column 1 for
                      compiler compatibility
    1/8/93      jf  - added DEBUG_VIEWSERIAL ifdefs to allow serial
                      characters received to appear on the console
                jf  - added DEBUG_SKIPSERIAL ifdefs to skip opening
                      and read/writes to the serial port if TRUE
    1/12/93     jf  - open now use O_NDELAY for all systems to disregard
                      the state of the Carrier Detect signal
    1/31/93     jf  - send_serial_cmd modified to be able to send out
                      rs232 to fbb commands to addr 30

           <<<< Copyright 1990 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <string.h>         /* for string commands */
#include "asctech.h"        /* Ascension Technology Definitions */
#include "compiler.h"       /* Compiler Definitions */
#include "menu.h"           /* for user interaction */
#include "serial.h"         /* Serial Definitions */

/*
    Local Prototypes
*/
#ifdef KNR
int get_record();
#else
int get_record(short charsneeded, char * rxbufinptr, short checkphasebit);
#endif

/*
    Descriptors for the COM ports
    =============================

    sys_com_config gets built at run time in configserial via strcpy and
    strcat C library calls... the user MUST modify this code when compiling
    on a UNIX platform using the proper /dev/tty driver
*/

#ifdef DOS
    char * sys_com_port[2] ={"com1","com2"};
#define OPENPARAMS O_RDWR
#endif

    /*
        UNIX Platforms
    */
#ifdef UNIX
#ifdef UNIX_SGTTY
    struct sgttyb oldcom_sgttyb;    /* save the old com config */
    struct sgttyb com_sgttyb;       /* for the new com config */
#endif

#ifdef UNIX_TERMIO
    struct termio oldcom_termio;    /* save the old com config */
    struct termio com_termio;       /* for the new com config */
#endif

    /*
        COHERENT - PCAT/Compatible 386/486 Platform
        --------

        COHERENT defines the Com Ports as: /dev/com1*,/dev/com2*
        Where, the l denotes interrupt mode, w/o Modem control
        Use /dev/com*l for interrupts w/o Modem control
             /dev/com*r for interrupts w/  Modem control
             /dev/com*pl for polled mode w/o Modem control
             /dev/com*pr for polled mode w/  Modem control
    */
#ifdef COHERENT
    char * sys_com_port[2] ={"/dev/com1l","/dev/com2l"};
#define OPENPARAMS O_RDWR
#endif

   /*
        IBM AIX - For the Risc 6000 Platform (using the Berkley terminal
        -------   interface)
   */
#ifdef AIX
    char * sys_com_port[2] ={"/dev/tty0","/dev/tty1"};
#define OPENPARAMS O_RDWR | O_NDELAY

#endif

   /*
        SUN SUNOS - For the SUN platform (using the TERMIO interface)
        ---------
   */
#ifdef SUNOS
    char * sys_com_port[2] ={"/dev/ttyha","/dev/ttyhb"};
#define OPENPARAMS O_RDWR | O_NDELAY
#endif

   /*
        DEC ULTRIX - For the DEC Platforms (using the Berkley terminal
        ----------   interface)
   */
#ifdef ULTRIX
    char * sys_com_port[2] ={"/dev/tty00","/dev/tty01"};
#define OPENPARAMS O_RDWR | O_NDELAY
#endif

   /*
        SGI IRIX - For the Silicon Graphics Platforms (using
        --------   the TERMIO interface)
   */
#ifdef IRIX
    char * sys_com_port[2] ={"/dev/ttyd1","/dev/ttyd2"};
#define OPENPARAMS O_RDWR
#endif

#endif

    /*
        Declare/Init the Variables
    */
    short comport = COM1;                   /* holds the comport # */

    /*
       Baud Rates for 6DFOBs
    */
    long baud = 9600L;                      /* holds the current baud rate */
    long baudratetable[] = {115200L,
                            57600L,
                            38400L,
                            19200L,
                            9600L,
                            4800L,
                            2400L};         /* holds the baud rate selections */

    /*
       Setup a Table for the Baud Rate Bit Definition used when
       setting up the Baud Rates via a call to IOCTL
    */
#ifdef UNIX

    short baudspeedbits = B9600;            /* holds the current bit definition */
    short baudspeedbittable[] = {BAUDRATE_115200,  /* CPU SPECIFIC */
                                 BAUDRATE_57600,   /* CPU SPECIFIC */
                                 BAUDRATE_38400,   /* CPU SPECIFIC */
                                 B19200,
                                 B9600,
                                 B4800,
                                 B2400};    /* holds the bitspeed definition */
#endif

    /*
       Use the Definitions from the BIOS INT14 function 0
    */
#ifdef DOS
    short baudspeedbits = 7;            /* holds the current bit definition */
    short baudspeedbittable[] = {-1,
                                 -1,
                                 -1,
                                 -1,
                                 7,
                                 6,
                                 5};    /* holds the bitspeed definition */
#endif

    int comhandle = -1;                     /* holds the comport handle */
    short serialconfigsaved = FALSE;        /* flag indicates serial port saved */
    short phaseerror_count = 0;             /* holds the phase errors */
    short rxerrors = 0;                     /* holds the rx line errors */

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
*/
int configserialport()
{
#ifdef DEBUG_SKIPSERIAL
       return(TRUE);
#else

#ifdef DOS
#ifdef RTSINCABLE
        int com_base;
#endif

      /*
         Use BIOS INT 14 to setup the Serial Ports Baud Rate and Config
      */
#define SETSERIALINT 0x14       /* INT 14h */
      union REGS regs;                /* Use C's register emulation */

      regs.h.ah = 0;                          /* set up for function 0 */
      regs.h.al = (baudspeedbits << 5) | 3;   /* MS 3 bits of AL = BAUD
                                                 LS 2 bits = 8 bit char */
      regs.x.dx = comport;                    /* DX = comport # */
      int86(SETSERIALINT,&regs,&regs);        /* Do INT */

      /*
         NOTE: Enable the RTSINCABLE code if the RS232 cable connected
               to the Host PC contains a connection for RTS...

               RTS holds the Bird in RESET/STANDY and therefore the
               DOS write times outs
      */

#ifdef RTSINCABLE
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
            Assert DTR...just in case the cable uses the DTR signal
            Deassert RTS...else the system will reset
            Dessert OUT2...needed to disable interrupts on PC compatible
                serial I/O cards
        */
        OUTPORTB(com_base + MODEMCONT, DTRON);
#endif


      return(TRUE);
#endif

#ifdef UNIX_SGTTY
      struct sgttyb tempcom_sgttyb;

      /*
          Get the Current Com Port Configuration
      */
      if (ioctl(comhandle,TIOCGETP,&tempcom_sgttyb) >= 0)
      {
          /*
              Set the New Baud Rate...input and output
          */
          tempcom_sgttyb.sg_ispeed = baudspeedbits;
          tempcom_sgttyb.sg_ospeed = baudspeedbits;
          if (ioctl(comhandle,TIOCSETP,&tempcom_sgttyb) >= 0)
              return(TRUE);
      }
      printf("\n\r** ERROR ** could not set the COM port Baud Rate\n\r");
      return(FALSE);

#endif

#ifdef UNIX_TERMIO
      struct termio tempcom_termio;

      /*
          Get the Current Com Port Configuration
      */
      if (ioctl(comhandle,TCGETA,&tempcom_termio) >= 0)
      {
          /*
              Set the New Baud Rate... don't smash the current CFLAG settings
          */
          tempcom_termio.c_cflag |= baudspeedbits;
          if (ioctl(comhandle,TCSETA,&tempcom_termio) >= 0)
              return(TRUE);
      }
      printf("\n\r** ERROR ** could not set the COM port Baud Rate\n\r");
      return(FALSE);

#endif
#endif /* DEBUG_SKIPSERIAL */
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
#ifdef DEBUG_SKIPSERIAL
    return(TRUE);
#else

#ifdef UNIX
    int zeroint = 0;
#endif

    /*
        if already opened, return FALSE
    */
    if (comhandle != -1)
        return(FALSE);

    /*
        Open the Comport for RD and WR and get a handle
    */
    if ((comhandle = open(sys_com_port[comport], OPENPARAMS)) == -1)
    {
        printf("\n\r** ERROR ** could not open the COM port\n\r");
        return(FALSE);
    }

#ifdef UNIX_SGTTY

    /*
        Save the Current Com Port Configuration
    */
    if (ioctl(comhandle,TIOCGETP,&oldcom_sgttyb) >= 0)
    {
      /*
         Set the New configuration to RAW mode
      */
      com_sgttyb.sg_flags = RAW;
      if (ioctl(comhandle,TIOCSETP,&com_sgttyb) >= 0)
      {
#ifdef ULTRIX
          /*
              Setup the TTY to NOT need the MODEM control Signal
          */
          if (ioctl(comhandle,TIOCNMODEM,zeroint) >= 0)
          {
              /*
                   Setup for ignoring Carrier
              */
              if (ioctl(comhandle,TIOCNCAR,zeroint) >= 0)
                  return(TRUE);
          }
#else
          return(TRUE);
#endif
        }
     }

    /*
        Put up the Error and return
    */
    printf("** ERROR ** could not configure the COM port to RAW mode");
    hitkeycontinue();

    return(FALSE);
#endif

#ifdef UNIX_TERMIO

    /*
        Save the Current Com Port Configuration
    */
    if (ioctl(comhandle,TCGETA,&oldcom_termio) >= 0)
    {
        /*
           Setupt the new port configuration...NON-CANONICAL INPUT MODE
           .. as defined in termio.h
        */
        com_termio.c_iflag = XOFF;
        com_termio.c_cflag = CS8 | CLOCAL | CREAD;
        com_termio.c_lflag = 0;
        com_termio.c_cc[VMIN] = 0;     /* setup to return after 2 seconds */
        com_termio.c_cc[VTIME] = 20;   /* ..if no characters are received */
                                       /* TIME units are assumed to be 0.1 secs */

        if (ioctl(comhandle,TCSETA,&com_termio) >= 0)
        {
           return(TRUE);
        }
     }

    /*
        Put up the Error and return
    */
    printf("** ERROR ** could not configure the COM port to RAW mode");
    hitkeycontinue();

    return(FALSE);
#endif

#ifdef DOS
    return(TRUE);
#endif

#endif /* DEBUG_SKIPSERIAL */

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
#ifdef DEBUG_SKIPSERIAL
    return;
#else
    /*
        Restore the Com Port Configuration.. if already opened
    */
    if (comhandle != -1)
    {
#ifdef UNIX_SGTTY
        ioctl(comhandle,TIOCSETP,&oldcom_sgttyb);    /* restore config */
#endif

#ifdef UNIX_TERMIO
        ioctl(comhandle,TCSETA,&oldcom_termio);    /* restore config */
#endif
        close(comhandle);    /* close the handle */
        comhandle = -1;        /* make the comhandle 'look' closed */
    }
#endif /* DEBUG_SKIPSERIAL */
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
#ifdef UNIX
    short charsrdy;
    char temprxbuf[255]; /* should never be more than 255 chars in buffer ?? */
#endif

    phaseerror_count = 0;               /* clear the phase counter */

#ifdef UNIX
    /*
       Flush Pending Buffers
    */
    ioctl(comhandle,TCFLSH,TIOCFLUSH);  /* flush pending I/O chars */

    /*
       Determine if there are chars in the Buffer
    */
    if (ioctl(comhandle,TIONREAD,&charsrdy))
    {
       printf("\n\r** ERROR ** IOCTL returned an error\n\r");
       return;
    }

    /*
       Get the number of chars ready out of the read buffer
    */
    if (charsrdy)
    {
        if (get_record(charsrdy,temprxbuf,FALSE) != charsrdy)
            printf("\n\r** ERROR ** could not clear the RX buffer\n\r");
    }
#endif

}

/*
    get_serial_record   - Get a record from the serial IO Buffer

    Prototype in:       serial.h

    Parameters Passed:  rxbuf       -   pointer to a buffer to store the
                                        received characters
                        recsize     -   number of characters to receive
                        outputmode  -   POINT, CONTINUOUS or STREAM

    Return Value:       If successful, returns recsize
                        else, RXERRORS if Rx errors were detected while
                        receiving data

    Remarks:            A record of data has the MSB of the first
                        character set to a 1.  The routine verifies that
                        the first character received is in PHASE.

                        NOTE that this routine returns the MOST RECENT
                        record from the Buffer...if more than one record
                        is present, old records are discarded.
*/
int get_serial_record(rxbuf, recsize, outputmode)
unsigned char * rxbuf;
short recsize;
short outputmode;
{
    short charsread;

#ifdef DEBUG_SKIPSERIAL

    /*
       Fill in the Record with the Data Read
    */
    for (charsread = 0; charsread < recsize; charsread++)
    {
        rxbuf[charsread] = charsread;
    }

    /*
        Set the Phasing Bit
    */
    rxbuf[0] |= 0x80;

    return(recsize);
#else

    char * rxbufinptr;
    short tempcharsneeded;
    int   charsrdy = 0;
    short numrecordsrdy;
    int   totalcharsrdy;


    /*
       STREAM mode is NOT allowed if using DOS
       ..DOS does not support interrupt driven serial I/O
    */
#ifdef DOS
    if (outputmode == STREAM)
    {
        printf("\n\r** ERROR ** STREAM mode is not supported by DOS\n\r");
        return(RXERRORS);
    }
#endif

    /*
        Setup some variables
    */
    totalcharsrdy = 0;

    /*
       Get the Number of Chars Ready

       Note that this approach reads the MOST RECENT record received by the
       host computer by manually emptying the operating system's serial
       character buffer until the last valid record
    */
#ifdef UNIX
    if (ioctl(comhandle,TIONREAD,&charsrdy))
    {
       printf("\n\r** ERROR ** IOCTL returned an error\n\r");
       return(RXERRORS);
    }
#endif

    /*
        Add the current amount of chars ready to the total
    */
    totalcharsrdy += charsrdy;

    /*
       Now take care of 3 cases...
       1) charsrdy = recsize
       2) charsrdy > recsize
       3) charsrdy < recsize
    */
    if (totalcharsrdy >= recsize)
    {

        /*
           Determine the number of records available

           If the number is greater than 1 then throw away old records
        */
        if (recsize)
            numrecordsrdy = totalcharsrdy/recsize;
        else
        {
            printf("\n\r** ERROR ** illegal parameter in call to get_serial_record\n\r");
            return(RXERRORS);
        }

        /*
            Read the most recent complete Block from the Port
        */
        while (numrecordsrdy--)
        {
            if (get_record(recsize,(char *) rxbuf,TRUE) == RXERRORS)
                return(RXERRORS);
        }
    }
    else
    {
        return(get_record(recsize,(char *) rxbuf,TRUE));
    }

    /*
        Everything is OK, so return the recsize
    */
    return(recsize);

#endif /* DEBUG_SKIPSERIAL */
}

/*
    get_record          - Get a record from the serial port

    Prototype in:       serknr.c

    Parameters Passed:

                        short charsneeded   - number of chars needed
                        char * rxbufinptr   - place to store the chars
                        short checkphasebit - check phase on/off

    Return Value:       If successful, returns recsize
                        else, RXERRORS if Rx errors were detected while
                        receiving data

    Remarks:            A record of data has the MSB of the first
                        character set to a 1.  The routine verifies that
                        the first character received is in PHASE.
*/
int get_record(charsneeded, rxbufinptr, checkphasebit)
short charsneeded;
char * rxbufinptr;
short checkphasebit;
{
    short tempcharsneeded;
    char * temprxbufinptr = rxbufinptr;
    short charsread;

    /*
        Now Try to Read the required amount of characters...

        Note that we do NOT assume that the read will block until
        required number of characters are available because the
        read can return with less than the number of characters
        needed
    */
    tempcharsneeded = charsneeded;
    while(tempcharsneeded)
    {

        charsread = read(comhandle,temprxbufinptr,tempcharsneeded);
        if (charsread <= 0)  /* check to make sure we got a least 1 */
        {
            printf("\n\r** ERROR ** serial receive timeout \n\r");
            return(RXERRORS);
        }

        /*
            Keep track of the number of characters read
        */
        if (charsread != -1)
        {
            temprxbufinptr += charsread;
            tempcharsneeded -= charsread;
        }

        /*
            Verify that the first character has the Phasing Bit Set
            and all the remaining characters do NOT have the Phasing Bit
            Set ..only if enabled
        */
        if (checkphasebit && !(*rxbufinptr & 0x80))
        {
            printf ("\n\r** ERROR ** phasing bit error\n\r");
            return(RXERRORS);
        }
    }

    return(charsneeded);
}


/*
    send_serial_cmd     -    Send Serial Command to the Bird port

    Prototype in:       serial.h

    Parameters Passed:  cmd         -   string to send to the serial port
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
    char cmdbytessent;

#ifdef DEBUG_SKIPSERIAL
#ifdef DEBUG_VIEWSERIAL

    printf ("\n\rCOMMAND SENT: ");
    for (cmdbytessent = 0; cmdbytessent < cmdsize; cmdbytessent++)
        printf(" 0x%X",*cmd++);
    printf ("\n\r");
#endif /* DEBUG_VIEWSERIAL */

    return(cmdbytessent);
#else  /* DEBUG_SKIPSERIAL */

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

#ifdef DEBUG_VIEWSERIAL
        printf ("\n\rRS232TOFBB COMMAND: 0x%X\n\r",rs232tofbbcmd);
#endif
        write(comhandle,&rs232tofbbcmd,1);
    }

#ifdef DEBUG_VIEWSERIAL
    printf ("\n\rCOMMAND SENT: ");
    for(cmdbytessent = 0;cmdbytessent < cmdsize; cmdbytessent++)
        printf (" 0x%X",cmd[cmdbytessent]);
    printf("\n\r");
#endif

    cmdbytessent = write(comhandle,cmd,cmdsize);

#ifdef UNIX
    ioctl(comhandle,TCFLSH,TIOCFLUSH);  /* flush pending I/O chars */
#endif

    return(cmdbytessent);

#endif /* DEBUG_SKIPSERIAL */
}

/*
    get_serial_char -   Get 1 Character from the serial port if one is available

    Prototype in:       serial.h

    Parameters Passed:  void

    Return Value:       returns the

    Remarks:            returns the receive character if successful,
                        RXERRORS if receive errors
*/
int get_serial_char()
{
#ifdef DEBUG_SKIPSERIAL
    static chr = 0;
#ifdef DEBUG_VIEWSERIAL
    printf("\n\rCHAR RECEIVED: 0x%X\n\r",chr);
#endif
    return(chr++);
#else
    unsigned char chr;

    if ((read(comhandle, &chr,1)) != -1)
    {
#ifdef DEBUG_VIEWSERIAL
        printf("\n\rCHAR RECEIVED: 0x%X\n\r",chr);
#endif
        return(chr);
    }
    else
        return(RXERRORS);

#endif /* DEBUG_SKIPSERIAL */
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
short chr;
{
#ifdef DEBUG_SKIPSERIAL
#ifdef DEBUG_VIEWSERIAL
    printf("\n\rCHAR SENT: 0x%X\n\r",chr);
#endif

    return(TRUE);
#else

#ifdef UNIX
    int zeroint=0;
#endif

    if ((write(comhandle,(char *) &chr,1)) == 1)
    {
#ifdef UNIX
        ioctl(comhandle,TCFLSH,TIOCFLUSH);  /* flush pending I/O chars */
#endif

#ifdef DEBUG_VIEWSERIAL
        printf("\n\rCHAR SENT: 0x%X\n\r",chr);
#endif
        return(TRUE);
    }
    else
        return(TXNOTEMPTY);

#endif /* DEBUG_SKIPSERIAL */
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

    /*
        Wait until a character is available
        ....leave loop if errors or character available
    */
    while ((rxchar = get_serial_char()) == NODATAAVAIL);

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

