/****************************************************************************
*****************************************************************************

    fbbcmds.c       FBB Commands

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-655-7879

    written by:     Jeff Finkelstein

    Modification History:
       9-20-93   jf      created

       <<<< Copyright 1991,92,93 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>
#include "compiler.h"
#include "asctech.h"
#include "menu.h"
#include "ser485.h"
#include "dual485.h"
#include "fbbcmds.h"

/* #define DEBUGNOTES */

/*
    fbbconfig           Configure the FBB

    Prototype in:       fbbcmds.h

    Parameters Passed:  void

    Return Value:       short TRUE if all went OK
                        short FALSE otherwise

    Remarks:
*/
short fbbconfig()
{
    short i;
    short comport;
    unsigned char nextaddr;
    unsigned char fbbcmdaddr;
    unsigned char fbbautoconfigcmd[4] = {0x01,0x50,0x32,0x00};
    unsigned char fbbnextmastercmd[2] = {0x01,0x30};
    unsigned char fbbnextxmtrcmd[3] = {0x01,0x30,0x00};

    /*
        Assume set 0 has the address 1
    */
    comport = systemconfig.groupconfig[0].comport;
    printf("\n\rConfiguring the Flock using COM%d...", comport+1);

    /*
        Setup the Mode for all the Devices in All the groups
    */
     for (i=0;i<systemconfig.numgroups;i++)
     {
         nextaddr = 0;
         /*
             Load the Next Address
         */
         while ((fbbcmdaddr = systemconfig.groupconfig[i].addrlist[nextaddr++]) != 0)
         {
             /*
                 Send the Command Data Command to ALL the device
             */
             printf ("\n\rConfiguring Output Mode and Filter Settings for Address %d",fbbcmdaddr);
             if (!sendfbboutmodecmd(fbbcmdaddr,
                                    systemconfig.groupconfig[i].comport,
                                    systemconfig.datamode))
             {
                 return(FALSE);
             }

             /*
                 Send the Filter command to ALL the Devices
             */
             if (!sendfbbfiltercmd(fbbcmdaddr,
                                   systemconfig.groupconfig[i].comport,
                                   systemconfig.filteronoff))
             {
                 return(FALSE);
             }
         }
    }
    delay(200);

    /*
        Send the AUTOCONFIG Command to the Bird
    */
    fbbautoconfigcmd[3] = systemconfig.flocksize;
    if (send_serial_cmd(comport,fbbautoconfigcmd,4) != 4)
    {
        printf("\n\r** ERROR could not send the AUTOCONFIG command\n\r");
        return(FALSE);
    }
    delay(400);

    /*
        Send the NEXT Transmitter command to the Bird if required
    */
    if (systemconfig.transmitteraddr != 1)
    {
        printf("\n\rSending the NEXT Transmitter Command for Address %d, Transmitter %d",
                    systemconfig.transmitteraddr,systemconfig.transmitternum);
        fbbnextxmtrcmd[2] = systemconfig.transmitteraddr << 4;
        fbbnextxmtrcmd[2] |= systemconfig.transmitternum;
        if (send_serial_cmd(comport,fbbnextxmtrcmd,3) != 3)
        {
            printf("\n\r** ERROR could not send the NEXT Transmitter command\n\r");
            return(FALSE);
        }
    }
    delay(200);

    /*
        Send the NEXT Master command to the Bird if required
    */
    if (systemconfig.masteraddr != 1)
    {
        printf("\n\rSending the NEXT Master Command for Address %d",systemconfig.masteraddr);
        fbbnextmastercmd[1] &= 0xe0;
        fbbnextmastercmd[1] |= systemconfig.masteraddr;
        if (send_serial_cmd(comport,fbbnextmastercmd,2) != 2)
        {
            printf("\n\r** ERROR could not send the Next Master command\n\r");
            return(FALSE);
        }
    }
    delay(200);

    printf("\n\rConfigured OK\n\r");
    return(TRUE);
}

/*
    sendfbbdatacmd      Send the FBB SENDDATA command

    Prototype in:       fbbcmds.h

    Parameters Passed:  unsigned char fbbaddr - FBB address
                        unsigned char comport - Serial Com Port #

    Return Value:       short TRUE if all went OK
                        short FALSE otherwise

    Remarks:

*/
short sendfbbdatacmd(fbbaddr, comport)
unsigned char fbbaddr;
unsigned char comport;
{
    unsigned char fbbsenddatacmd;

#ifdef DEBUGNOTES
    printf("\n\rSending SENDDATA Command to FBB address %d on via COM%d",
            fbbaddr, comport+1);
#endif

    fbbsenddatacmd = 0x20 + fbbaddr;
    if (send_serial_cmd(comport,&fbbsenddatacmd,1) != 1)
    {
        printf("\n\r** ERROR could not send the Send Data command\n\r");
        return(FALSE);
    }

    return(TRUE);
}

/*
    getfbbdata          Get the FBB DATA

    Prototype in:       fbbcmds.h

    Parameters Passed:  unsigned char fbbaddr - FBB address
                        unsigned char comport - Serial Com Port #

    Return Value:       short TRUE if all went OK
                        short FALSE otherwise

    Remarks:

*/
short getfbbdata(fbbaddr, comport, rxbufptr, recsize)
unsigned char fbbaddr;
unsigned char comport;
unsigned char * rxbufptr;
unsigned char recsize;
{
    short retval;

#ifdef DEBUGNOTES
    printf("\n\rWaiting for FBB Data from ADDR %d on COM%d",
            fbbaddr, comport+1);
#endif
    retval = get_serial_record(comport, rxbufptr, recsize, POINT);
    if (retval < 0)
    {
        printf ("\n\r** ERROR ** could not receive Bird Data from COM%d\n\r", comport+1);
        return(FALSE);
    }
    if (retval != recsize)
    {
        printf ("\n\r** ERROR ** did not receive enough Bird Data\n\r", comport+1);
        return(FALSE);
    }
#ifdef DEBUGNOTES
    printf("....Received Data OK");
#endif
    return(TRUE);
}


/*
    sendfbboutmodecmd   Send the Output Data Mode command

    Prototype in:       fbbcmds.h

    Parameters Passed:  unsigned char fbbaddr
                        unsigned char comport
                        unsigned char datamode

    Return Value:


    Remarks:

*/
short sendfbboutmodecmd(fbbaddr, comport, datamode)
unsigned char fbbaddr;
unsigned char comport;
unsigned char datamode;
{
    unsigned char fbbsendoutmodecmd[2] = {0x00,0x00};

    fbbsendoutmodecmd[0] = 0x00 + fbbaddr; /* RS232 Command */
    switch (datamode)
    {
        case POS:
            fbbsendoutmodecmd[1] = 0x56; /* Postion */
            break;
        case ANGLE:
            fbbsendoutmodecmd[1] = 0x57; /* Angles */
            break;
        case MATRIX:
            fbbsendoutmodecmd[1] = 0x58; /* Matrix */
            break;
        case QUATER:
            fbbsendoutmodecmd[1] = 0x5c; /* Quaternions */
            break;
        case POSANGLE:
            fbbsendoutmodecmd[1] = 0x59; /* Position/Angles */
            break;
        case POSMATRIX:
            fbbsendoutmodecmd[1] = 0x5a; /* Position/Matrix */
            break;
        case POSQUATER:
            fbbsendoutmodecmd[1] = 0x5d; /* Position/Quater */
            break;
        default:
            printf("\n\r** ERROR ** illegal Data Mode\n\r");
            return(FALSE);
        }

    if (send_serial_cmd(comport,fbbsendoutmodecmd,2) != 2)
    {
        printf("\n\r** ERROR could not send the Output Mode command\n\r");
        return(FALSE);
    }
    delay(1);
    return(TRUE);
}

/*
    sendfbbfiltercmd    Send the Filter command

    Prototype in:       fbbcmds.h

    Parameters Passed:  unsigned char fbbaddr
                        unsigned char comport
                        unsigned char filteronoff

    Return Value:


    Remarks:

*/
short sendfbbfiltercmd(fbbaddr, comport, filteronoff)
unsigned char fbbaddr;
unsigned char comport;
unsigned char filteronoff;
{
    unsigned char fbbsendfiltercmd[5] = {0x00,0x50,0x04,0x00,0x00};

    fbbsendfiltercmd[0] = 0x00 + fbbaddr; /* RS232 Command */
    fbbsendfiltercmd[3] = filteronoff;
    if (send_serial_cmd(comport,fbbsendfiltercmd,5) != 5)
    {
        printf("\n\r** ERROR could not send the Filter ON/OFF command\n\r");
        return(FALSE);
    }
    delay(1);
    return(TRUE);
}
