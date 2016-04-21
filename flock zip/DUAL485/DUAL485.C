/****************************************************************************
*****************************************************************************

    dual485.c      Runs the flock using dual RS-485 interfaces

                    Program written to collect data from multiple
                    Birds in Real Time while storing the data into XMS
                    memory.  Data is written to a disk from XMS memory
                    in the order is which is was saved.

                    NOTE: To utilize XMS memory, the PC needs to have
                          an XMS memory driver in operation (ie. HIMEM.sys)


                    File Format:

                         Header - 0x200 bytes => see dual485.h
                                                 systemconfig structure for
                                                 the header format
                         Data   - n bytes for each sample record
                                  where,
                                  Each Record contains a TIMESTAMP and
                                  data from each device. For example,
                                  for Position and Quaternions, with 12
                                  devices the record is 172 bytes long
                                  4 bytes (long) + 12 * 14 = 172

                                  TIMESTAMP is a count of the current tick,
                                  where the tick resolution is set by the
                                  user, but defaults to 10 milliseconds.


    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-655-7879

    written by:     Jeff Finkelstein

    Modification History:
       09-15-93   jf      created
       10-05-93   jf/vm   updated for preliminary use
       11-05-93   jf      update for compatibility with FBB250
       01-05-94   jf      added RS232 Data Upload ..revision 1.1
       03-23-94   sw      added leading bytes to header
       05-06-94   sw      loop added to clear group addres to fix bug.
                          change in getsysconfig()
       03-09-95   ssw     ignore filename cahnge command by ESC


       <<<< Copyright 1991,92,93 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <graphics.h>
#include <stdio.h>          /* general I/O */
#include <stdlib.h>         /* for exit() */
#include <math.h>           /* for sqrt() */
#include <sys\stat.h>       /* for File I/O */
#include <fcntl.h>
#include <io.h>
#include <string.h>
#include "asctech.h"        /* Ascension Technology definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "menu.h"           /* Ascension Technology Menu Routines */
#include "pcpic.h"          /* Programmable Interrupt Controller Routines */
#include "pctimer.h"        /* Programmable Timer Routines */
#include "ser_gen.h"         /* Serial Rountines */
#include "fbbcmds.h"
#include "xms.h"            /* Use Extended Memory for the Application */
#include "dual485.h"


/*
   From CUBE.c
*/
extern float rho;
extern float zoomconst,cx,cy,cz;
extern float v11,v12,v13,v21,v22,v23,v31,v32,v33;

unsigned char update_cube(void);
void convertposquart(unsigned char * dosdataptr);
int rs232init(void);


#define TIMESTAMPSIZE sizeof(long)

#define SIZEDATAHEADER 0x200
struct systemconfigstruct systemconfig;
struct systemconfigstruct reviewsystemconfig;

unsigned char exit_flg = FALSE;
unsigned short xms_memsize; /* XMS memory Available */

float posk = POSK144;
unsigned short position;
short rs232comport = COM1;  /* Default RS232 Port */

long dataavailsize = 0;
long maxdataavail = 0;

/*
    main                -   Main Program

    Prototype in:       none, called by C startup code

    Parameters Passed:  void

    Return Value:       int 0 if exited OK
                        int -1 if exited with an error

    Remarks:

*/
int main()
{
    short i;
    #define NUMMAINMENUSELECTS 6
    static char * mainmenuptr[] = {"Main Menu Selections",
                                   "Exit to DOS",
                                   "Collect Data to a File",
                                   "Review Data File - Text Mode",
                                   "Review Data File (orientation) - Graphics Mode",
                                   "Review Data File (position & orientation) - Graphics Mode",
                                   "Show/Modify System Configuration"};

    /*
        Put up a Sign on Message
    */
    CLEARSCREEN;
    printf("Dual RS-485 Interface Program\n\r\
Version 1.2, Ascension Technology Corporation\n\n\r");

    /*
        Detect the XMS driver
    */
    if (xms_init() <= 0)
    {
        printf("\n\rNO XMS Driver Available");
        return(-1);
    }

    /* *******************************
      Load in leading bytes for header
      ********************************
    */
    systemconfig.leader[0] = 0xFF;
    systemconfig.leader[1] = 0xFF;
    systemconfig.leader[2] = 0xFF;
    systemconfig.leader[3] = 0xFF;

    /*
        Preset some of the System Configuration
    */
    systemconfig.datafileversion = 0x0001;
    systemconfig.datastore_flg = TRUE;
    strcpy(systemconfig.datafile, "BIRDDAT.dat");
    strcpy(systemconfig.usernote, "USER MSG:");

    systemconfig.test_msec = 10000;
    systemconfig.tick_msec = 10;
    systemconfig.flocksize = 13;
    systemconfig.numgroups = 2;
    systemconfig.datamode = POSQUATER;
    systemconfig.recsize = 14;
    systemconfig.filteronoff = 0x04;

    systemconfig.groupconfig[0].addrlist[0] = 2;
    systemconfig.groupconfig[0].addrlist[1] = 3;
    systemconfig.groupconfig[0].addrlist[2] = 4;
    systemconfig.groupconfig[0].addrlist[3] = 5;
    systemconfig.groupconfig[0].addrlist[4] = 6;
    systemconfig.groupconfig[0].addrlist[5] = 7;

    systemconfig.groupconfig[1].addrlist[0] = 8;
    systemconfig.groupconfig[1].addrlist[1] = 9;
    systemconfig.groupconfig[1].addrlist[2] = 10;
    systemconfig.groupconfig[1].addrlist[3] = 11;
    systemconfig.groupconfig[1].addrlist[4] = 12;
    systemconfig.groupconfig[1].addrlist[5] = 13;

    systemconfig.masteraddr = 1;
    systemconfig.transmitteraddr = 1;

    systemconfig.groupconfig[0].comport = COM3;
    systemconfig.groupconfig[1].comport = COM4;

    /*
        Check to see if the User would like to change any of the
        system settings
    */
    while (!exit_flg)
    {
        printf ("\n\r");
        switch (sendmenu(mainmenuptr,NUMMAINMENUSELECTS))
        {
            case ESC_SEL:
            case 0:
                if (askyesno("\n\rAre you sure you want to Quit") == YES)
                    exit_flg = TRUE;
                break;

            case 1:
                if (cktestmemavail())
                {
                    runtest();
                }
                else
                {
                    printf("\n\r** ERROR ** Could not allocate XMS memory for the data collection\n\r");
                    hitkeycontinue();
                }
                break;

            case 2:
                review_datafile(TEXTMODE);
                break;

            case 3:
                position = 0;
                review_datafile(GRAPHICSMODE);
                break;

            case 4:
                position = 1;
                review_datafile(GRAPHICSMODE);
                break;

            case 5:
                getsysconfig();
                break;
        }
    }

    /*
        Cleanup and Exit
    */
    exit_cleanup();

    /*
        Return to DOS
    */
    return(0);
}



/*
    getsysconfig        Get the System configuration

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
void getsysconfig()
{
    short user_sel;
    double user_float;
    short nextaddr;
    short i,qi;
    char msgbuf[80];
    char * msgbufptr;
    short tempdatafilehandle;
    int ignore;

    #define NUMCONFIGMENUSELECTS 13
    static char * configmenuptr[] =
               {"Configuration Parameters:",
                "No Change",
                "Output Mode",
                "Flock Size",
                "Number of Groups",
                "RS485 Communication Ports",
                "Group Device Addresses",
                "Master Address",
                "Transmitter Address",
                "Filter ON/OFF Settings",
                "Time Resolution",
                "Data Collection Time",
                "File Storage",
                "Real Time RS232 Data Upload"};

    #define OUTMODEMENUSELECTS 8
    static char * outmodemenuptr[] =
               {"Output Mode Selections:",
                "No Change",
                "Position",
                "Angles",
                "Matrix",
                "Quaternions",
                "Position and Angles",
                "Position and Matrix",
                "Position and Quaternions"};

    while (TRUE)
    {
        showsysconfig();

        /*
            Check if the User wants to Change anything
        */
        printf ("\n\r");
        switch (user_sel = sendmenu(configmenuptr,NUMCONFIGMENUSELECTS))
        {
            case ESC_SEL:
            case 0:
                return;
            case 1:
                switch (user_sel = sendmenu(outmodemenuptr,OUTMODEMENUSELECTS))
                {
                    case ESC_SEL:
                    case 0:
                         break;

                    case 1:
                         systemconfig.datamode = POS;
                         systemconfig.recsize  = 6;
                         break;
                    case 2:
                         systemconfig.datamode = ANGLE;
                         systemconfig.recsize  = 6;
                         break;
                    case 3:
                         systemconfig.datamode = MATRIX;
                         systemconfig.recsize  = 18;
                         break;
                    case 4:
                         systemconfig.datamode = QUATER;
                         systemconfig.recsize  = 8;
                         break;
                    case 5:
                         systemconfig.datamode = POSANGLE;
                         systemconfig.recsize  = 12;
                         break;
                    case 6:
                         systemconfig.datamode = POSMATRIX;
                         systemconfig.recsize  = 24;
                         break;
                    case 7:
                         systemconfig.datamode = POSQUATER;
                         systemconfig.recsize  = 14;
                         break;
                }
                break;

            case 2:
                user_sel = getushort("Enter the number of Devices in the Flock (1-30):",1,30);
                if (user_sel != ESC_SEL)
                    systemconfig.flocksize = user_sel;
                break;

            case 3:
                user_sel = getushort("Enter the number of groups (1-4):",1,4);
                if (user_sel != ESC_SEL)
                    systemconfig.numgroups = user_sel;
                break;

            case 4:

                for (i = 0; i < systemconfig.numgroups; i++)
                {
                    sprintf(msgbuf,"Enter the COMPORT for Group %d (1-4):",i+1);
                    user_sel = getushort(msgbuf,1,4);
                    if (user_sel != ESC_SEL)
                        systemconfig.groupconfig[i].comport = user_sel-1;
                }
                break;

            case 5:
                sprintf(msgbuf,"Enter the Group number (1-%d) of the address list to modify:",systemconfig.numgroups);
                user_sel = getushort(msgbuf,1,systemconfig.numgroups);
                if (user_sel == ESC_SEL)
                    break;

                i = user_sel-1;
                nextaddr = 0;
                while(TRUE)
                {
                    user_sel = getushort("Enter an Address (1 to 30) or <ESC> to END: ",1,30);
                    if (user_sel > 0)
                    {
                        systemconfig.groupconfig[i].addrlist[nextaddr++] = user_sel;
                        if (nextaddr > 30)
                            break;
                    }
                    else
                    {
                        for (qi=nextaddr; qi<MAXNUMADDR; qi++)
                          systemconfig.groupconfig[i].addrlist[qi] = 0;
                        break;
                    }
                }
                break;

            case 6:
                user_sel = getushort("Enter the Address (1 to 30) of the FBB Master:",1,30);
                if (user_sel != ESC_SEL)
                    systemconfig.masteraddr = user_sel;
                break;

            case 7:
                user_sel = getushort("Enter the Address (1 to 30) of the FBB Transmitter:",1,30);
                if (user_sel != ESC_SEL)
                    systemconfig.transmitteraddr = user_sel;
                break;

            case 8:
                /*
                    Ask the user to 'fill in the bits'...filter ON/OFF selection
                */
                if ((user_sel = askyesno("\n\rDo you want the AC Narrow Notch filter OFF")) == TRUE)
                    systemconfig.filteronoff = 0x04;
                else if (user_sel == FALSE)
                    systemconfig.filteronoff = 0x00;
                else if (user_sel == ESC_SEL)
                    return;


                if ((user_sel = askyesno("\n\rDo you want the AC Wide Notch OFF")) == TRUE)
                   systemconfig.filteronoff |= 0x02;
                else if (user_sel == FALSE)
                    systemconfig.filteronoff &= ~0x02;
                else if (user_sel == ESC_SEL)
                    return;

                if ((user_sel = askyesno("\n\rDo you want the DC filter OFF")) == TRUE)
                   systemconfig.filteronoff |= 0x01;
                else if (user_sel == FALSE)
                    systemconfig.filteronoff &= ~0x01;
                else if (user_sel == ESC_SEL)
                    return;


                break;

            case 9:
                user_sel = getushort("Enter the time stamping resolution in milliseconds (1 to 50):",1,50);
                if (user_sel != ESC_SEL)
                    systemconfig.tick_msec = user_sel;
                break;

            case 10:
                user_float = getfloat("Enter the Data Collection Time in seconds (0.100 to 1000.000):",0.1,1000.0);
                if (user_float != ESC_SEL)
                    systemconfig.test_msec = user_float * 1000;
                break;

            case 11:
                if ((systemconfig.datastore_flg = askyesno("Do you want to store data in a file")) == YES)
                {
                    strcpy(msgbuf,systemconfig.datafile);
                    msgbufptr = getfilename(msgbuf,&ignore);
                    if (ignore) break;
                    if (msgbufptr)
                    {
                        strcpy(systemconfig.datafile,msgbuf);
                    }
                    _fmode =  O_BINARY;
                    if ((tempdatafilehandle = creat(systemconfig.datafile, S_IREAD | S_IWRITE)) < 0)
                    {
                        printf("\n\r** ERROR ** could not create the data file\n\r");
                        hitkeycontinue();
                    }
                    close(tempdatafilehandle);
                }
                break;
            case 12:
                if ((systemconfig.rs232upload_flg = askyesno("Do you want to Upload data to a RS232 Port")) == YES)
                {
                    systemconfig.rs232header_flg = askyesno("\n\rDo you want to Upload the Header to the RS232 Port");

                    /*
                        Initialize the RS232 Port
                    */
                    if (!rs232init())
                    {
                        printf("\n\r** ERROR ** could not initialize the RS232 Port\n\r");
                        hitkeycontinue();
                        return;
                    }
                }

                break;
        }
    }
}

/*
    showsysconfig       Display the System Configuration

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
void showsysconfig()
{
    short i;
    short nextaddr;
    char * outmodestr[] = {"",
                           "Position",
                           "Angles",
                           "Matrix",
                           "Quaternions",
                           "Position and Angles",
                           "Position and Matrix",
                           "Position and Quaternions"};

    /*
        Put up a Heading
    */
    CLEARSCREEN;
    printf ("\n\r*** DUAL RS-485 System Configuration ***\n\r");

    /*
        Display number of groups in the Flock
    */
    printf("\n\rOutput Mode set to %s", outmodestr[systemconfig.datamode]);

    /*
        Display the Flock Size
    */
    printf("\n\rFlock Size set to %d with %d groups",
           systemconfig.flocksize,
           systemconfig.numgroups);

    /*
        Display the group(s) information
           COM PORT
           ADDRESS for Each group
    */
    for (i = 0; i < systemconfig.numgroups; i++)
    {
        printf("\n\rgroup %d (on COM%d) address list: ", i+1, systemconfig.groupconfig[i].comport+1);
        nextaddr = 0;
        while(systemconfig.groupconfig[i].addrlist[nextaddr] != 0)
        {
            printf(" %d", systemconfig.groupconfig[i].addrlist[nextaddr++]);
            if (nextaddr > 30)
                 break;
        }
    }

    /*
        Display which Device is the Master
    */
    printf ("\n\rFBB Master at Address %d, and Transmitter at Address %d\n\r",
             systemconfig.masteraddr,
             systemconfig.transmitteraddr);

    /*
        Display the Filter Info
    */
    printf ("AC Narrow Notch: ");
    if (systemconfig.filteronoff & 4)
        printf ("OFF");
    else
        printf ("ON");

    printf ("  AC Wide Notch: ");
    if (systemconfig.filteronoff & 2)
        printf ("OFF");
    else
        printf ("ON");

    printf ("  DC: ");
    if (systemconfig.filteronoff & 1)
        printf ("OFF");
    else
        printf ("ON");

    /*
        Display the data collection Time for this test
    */
    printf ("\n\rData Collection Time is %4.3f sec, with %d millisec time resolution",
            (float)systemconfig.test_msec/1000,
            systemconfig.tick_msec);

    /*
        Data file name
    */
    if (systemconfig.datastore_flg)
        printf ("\n\rData File Name is <%s>",systemconfig.datafile);
    else
        printf ("\n\rData File Storage is Disabled");

    /*
        RS232 Data Upload
    */
    if (systemconfig.rs232upload_flg)
        printf ("\n\rRS232 Data Will Be Uploaded");
    else
        printf ("\n\rRS232 Data Will NOT be Uploaded");

}


/*
    getusercmd          Get Run Time Commands from the User

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
short getusercmd()
{
    char key;

    /*
        Force a DOS call
    */
    if (ckkbhit())
    {
        switch (key = getkey())
        {
            case 'S':
            case 's':
                printf("\n\r ** USER STOP **\n\r");
                exit_flg = TRUE;
                break;

            case 'l':
            case 'L':
                zoomconst -= 1;
                if (zoomconst < 1)
                   zoomconst = 1;
                break;

            case 'b':
            case 'B':
                zoomconst += 1;
                if (zoomconst > 100)
                   zoomconst = 100;
                break;

            case 'i':
            case 'I':
                rho += 100;
                //if (rho > 1000)
                //    rho = 1000;
                break;

            case 'o':
            case 'O':
                rho -= 100;
                //if (rho < 0)
                //   rho = 0;
                break;

            case ESC:
                return(ESC_SEL);

            default:
                putch(BEL);
                break;
        }
        clearkey();
    }

    return(0);
}


/*
    updatedatafile      Update the Data file

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       TRUE if successfull
                        FALSE otherwise

    Remarks:

*/
short updatedatafile(datafilehandle, xmsstrtptr, xmsdatasize)
short datafilehandle;
LPTR xmsstrtptr;
long xmsdatasize;
{
    unsigned short writedatasize;
    unsigned short xmsblocksize;
    unsigned char * dosdataptr;
    unsigned short * birddataptr;
    unsigned short birddatacount;
    unsigned short tempnumdevices;
    unsigned char nullchr = 0;
    short i,count;

    /*
        zero + counter
    */
    count=0;

    /*
        Set the Date and Time of the Date File
    */
    getdate(&systemconfig.datecreated);
    gettime(&systemconfig.timecreated);

    /* ***************************************
       Add code for leading header bytes here
       ***************************************
    */

    /*
        write data file header...systemconfiguration
    */
    write(datafilehandle, &systemconfig, sizeof(systemconfig));

    /*
        fill in the header with 0's
    */
    for(i=0; i<SIZEDATAHEADER-sizeof(systemconfig); i++)
        write(datafilehandle,&nullchr, 1);

    /*
        Determine the Block Size
    */
    tempnumdevices  = getnumdevices(&systemconfig);
    xmsblocksize = (tempnumdevices * systemconfig.recsize) + TIMESTAMPSIZE;

    /*
        Allocate a Dos Buffer for Data
    */
    if ((dosdataptr = malloc(xmsblocksize)) == NULL)
    {
        printf("\n\r** ERROR ** could not allocate a DOS Data Buffer");
        hitkeycontinue();
        return(FALSE);
    }

    /*
        Store all the Data in a File
    */
    printf("\n\rStoring Data in file...\n\r");
    while (xmsdatasize)
    {
        if (xmsdatasize > xmsblocksize)
            writedatasize = xmsblocksize;
        else
            writedatasize = xmsdatasize;

        /*
            Copy a Block of Data in DOS RAM from
        */
        xms_memcpy(SEG_TO_LINEAR(dosdataptr), xmsstrtptr, writedatasize);
        xmsstrtptr += writedatasize;
        xmsdatasize -= writedatasize;

        /*
            Convert the Data to type short..strip the Phasing Info
        */
        (unsigned char *)birddataptr = dosdataptr + TIMESTAMPSIZE;
        for(i=0;i<tempnumdevices;i++)
        {
             birddatacount = 0;
             while(birddatacount++ < systemconfig.recsize/2)
             {
                 *birddataptr++ = (short)((((short)(*(unsigned char *) birddataptr) & 0x7F) |
                                            (short)(*((unsigned char *) birddataptr+1)) << 7)) << 2;
             }
        }

        /*
            write bytes to the file
        */
        if (write(datafilehandle, dosdataptr, writedatasize) != writedatasize)
        {
            printf("\n\r** ERROR ** could not write data file\n\r");
            return(FALSE);
        }
        if (++count%10 ==0) {
           putch('+');
           count=0;
        }
    }

    free(dosdataptr);
    return(TRUE);
}

/*
    exit_cleanup        Clean Up prior to exit

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
void exit_cleanup()
{
    printf("\n\rExiting DUAL485...");
}

/*
    cktestmemavail      Check the Test Memory Available

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       TRUE if XMS Memory is available
                        FALSE otherwise

    Remarks:

*/
unsigned char cktestmemavail()
{
    /*
        Determine the Amount of XMS memory Available
    */
    if (systemconfig.datastore_flg)
    {
        xms_memsize = xms_size();
        if (xms_memsize <= 0)
        {
            printf("\n\rNO XMS memory was available");
            return(FALSE);
        }
        printf("\n\r%d kbytes of XMS memory available",xms_memsize);
    }
    return(TRUE);
}


/*
    getnumdevices       Get Number of Devices in the group Lists

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       unsigned char numbirds

    Remarks:

*/
unsigned char getnumdevices(configptr)
struct systemconfigstruct * configptr;
{
    unsigned char numbirds;
    unsigned char addrnum;
    unsigned short i;

    /*
       Compute the number of Devices
    */
    numbirds = 0;
    addrnum = 0;
    for (i=0;i<configptr -> numgroups;i++)
    {
        addrnum = 0;
        while (configptr -> groupconfig[i].addrlist[addrnum++])
        {
            numbirds++;
        }
    }
    return(numbirds);
}

/*
    runtest             Run a Test Session

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
short runtest()
{
    short datafilehandle;
    short i,count;
    short devicecount;               
    short nextaddr[4];
    short GROUPdone[4];
    unsigned char fbbcmdaddr[4];
    unsigned char fbbrxbuf[(30 * 25) + TIMESTAMPSIZE];
    unsigned long numfbbrecords;
    unsigned char xms_memalloc_flg = FALSE;
    unsigned short xms_memalloc_size = 0;
    LPTR xmssrcptr;                  /* XMS Source Pointer */
    LPTR xmsdestptr;                 /* XMS Destination Pointer */
    LPTR xmsstrtptr;                 /* Starting XMS Pointer */
    unsigned short xmsblocksize;     /* number of chars to write to xms */
    unsigned short rs232blocksize;   /* number of chars to write to RS232 */
    unsigned short * rs232dataptr;   /* temporary data pointer */
    unsigned short rs232datacount;   /* number of RS232 words */
    short rterr_flg = FALSE;
    static unsigned char zerodata[SIZEDATAHEADER - sizeof(systemconfig)];

    /* 
        Set dot count to zero
    */
    count=0;

    /*
        Shut off the Exit Flag
    */
    exit_flg = FALSE;

    /*
        Preset ALL the GROUP Done Flags to DONE
    */
    for (i=0;i<4;i++)
    {
        GROUPdone[i] = TRUE;
    }

    /*
        Initialize the Serial Port(s) only if not already initialized
    */
    for (i=0;i<systemconfig.numgroups;i++)
    {
        if (serialconfigsaved[systemconfig.groupconfig[i].comport] == FALSE)
        {
            printf("\n\rSaving COM%d Configuration",systemconfig.groupconfig[i].comport+1);
            saveserialconfig(systemconfig.groupconfig[i].comport);
        }

        printf("\n\rConfiguring COM%d",systemconfig.groupconfig[i].comport+1);
        if (!configserialport(systemconfig.groupconfig[i].comport,250000L,RS485_PORT))
        {
            rterr_flg = TRUE;
            break;
        }
    }

    /*
        Try and Allocate ALL of the XMS Memory
    */
    if (systemconfig.datastore_flg)
    {
        xmsstrtptr = xmsdestptr = xms_alloc(xms_memsize);
        xmssrcptr = SEG_TO_LINEAR(&fbbrxbuf[0]);
        if (xmsdestptr < 0x100000L)
        {
            rterr_flg = TRUE;
            printf("\n\r** ERROR ** Could not allocate the XMS memory required for the Test\n\r");
            hitkeycontinue();
        }

        /*
            Compute the Block Size
        */
        if (xmsdestptr > 0)
        {
            xms_memalloc_flg = TRUE;
            xmsblocksize = (getnumdevices(&systemconfig) * systemconfig.recsize) + TIMESTAMPSIZE;
        }
    }

    /*
        Compute the RS232 Block Size
    */
    if (systemconfig.rs232upload_flg)
    {
        rs232blocksize = (getnumdevices(&systemconfig) * systemconfig.recsize) + TIMESTAMPSIZE;
    }

    /*
        Configure the Flock
    */
    if (!rterr_flg)
    {
        if (!fbbconfig())
        {
            printf("\n\r** ERROR ** could not configure the Flock\n\r");
            rterr_flg = TRUE;
        }

        if (askyesno("\n\rAre you ready to run a data collection cycle") != YES)
        {
            rterr_flg = TRUE;
        }
    }

    /*
        Upload the RS232 Header if required
    */
    if (systemconfig.rs232header_flg == YES)
    {
        if (send_serial_cmd(rs232comport,(unsigned char *) &systemconfig, sizeof (systemconfig))
            != sizeof (systemconfig))
        {
            printf("\n\r** ERROR ** could not upload the header information to the RS232 Port\n\r");
            rterr_flg = TRUE;
        }

        if (send_serial_cmd(rs232comport,zerodata, SIZEDATAHEADER - sizeof (systemconfig))
            != SIZEDATAHEADER - sizeof (systemconfig))
        {
            printf("\n\r** ERROR ** could not upload the header information to the RS232 Port\n\r");
            rterr_flg = TRUE;
        }
    }


    /*
        Do the Real-Time Code for as long and the Test is ON and
        the error flag is false
    */
    if (!rterr_flg)
    {
        printf("\n\rCollecting Data From Birds....please wait\n\r");

        /*
            create a binary file for reading and writing
        */
        if (systemconfig.datastore_flg)
        {
            _fmode =  O_BINARY;
            if ((datafilehandle = creat(systemconfig.datafile, S_IREAD | S_IWRITE)) < 0)
            {
                printf("\n\r** ERROR ** could not create the data file\n\r");
                rterr_flg = TRUE;
            }
        }
    }

    /*
        Setup the PC Timer to 'tick' milliseconds
    */
    if (!rterr_flg)
    {
        pctimer_init(systemconfig.tick_msec);
    }

    /*
        Stay in a Loop Collecting Data until the Time is UP OR
        and Error occurss OR the user hits stop
    */
    numfbbrecords = 0;
    systemconfig.filedatasize = 0;
    while (((numirqticks * systemconfig.tick_msec) <= systemconfig.test_msec) && !rterr_flg && !exit_flg)
    {
        devicecount = 0;

        /*
            Check User Command
        */
        getusercmd();

        /*
            Send the Command to get the Data from the groups
        */
        for (i=0;i<systemconfig.numgroups;i++)
        {
            GROUPdone[i] = FALSE;
            nextaddr[i] = 0;
        }
        while(TRUE)
        {
            /*
                Check to see if all the groups are done
            */
            for (i=0;i<systemconfig.numgroups;i++)
            {
                if (GROUPdone[i] == FALSE)
                {
                    /*
                        Load the Address for this GROUP
                    */
                    fbbcmdaddr[i] = systemconfig.groupconfig[i].addrlist[nextaddr[i]];
                    if (fbbcmdaddr[i] != 0)
                    {
                        /*
                            Send the Data Command to the GROUP
                        */
                        if (!sendfbbdatacmd(fbbcmdaddr[i],systemconfig.groupconfig[i].comport))
                        {
                            printf("\n\r...Data Collection Finished\n\r");
                            rterr_flg = TRUE;
                        }
                    }
                }
            }

            /*
                Get the Data Back from all the groups
            */
            for (i=0;i<systemconfig.numgroups;i++)
            {
                /*
                    Get the Device's Data
                */
                if (fbbcmdaddr[i] == 0)
                {
                    GROUPdone[i] = TRUE;
                    continue;
                }

                if (!getfbbdata(fbbcmdaddr[i],
                                systemconfig.groupconfig[i].comport,
                                &fbbrxbuf[TIMESTAMPSIZE + (devicecount * systemconfig.recsize)],
                                systemconfig.recsize))
                {
                    printf("\n\r...Data Collection Finished\n\r");
                    rterr_flg = TRUE;
                }
                numfbbrecords++;
                devicecount++;
            }

            /*
                Point to the next Address
            */
            for (i=0;i<systemconfig.numgroups;i++)
            {
                ++nextaddr[i];
            }

            /*
                If all the groups are DONE then move on to the next record
            */
            if (GROUPdone[0] && GROUPdone[1] && GROUPdone[2] && GROUPdone[3])
                break;
        }

        /*
            Update the Screen
        */
        if (++count%10 == 0) {
           putch('.');
           count=0;
        }

        /*
            Update the XMS Memory
        */
        if (systemconfig.datastore_flg)
        {
            /*
                Verify that we will not overrun XMS memory
            */
            if ((systemconfig.filedatasize + xmsblocksize) > ((long)xms_memsize * 1024L))
            {
                printf("\n\r** NOTE ** XMS Memory FULL.\n\r");
                rterr_flg = TRUE;
            }

            /*
                Write Down the Time Stamp in memory
            */
            *(long *)&fbbrxbuf[0] = GETTICKS;
            xms_memcpy(xmsdestptr,xmssrcptr,xmsblocksize);
            xmsdestptr += xmsblocksize;
            systemconfig.filedatasize += xmsblocksize;
        }

        /*
            Send out the Data to the RS232 Port if required
        */
        if (systemconfig.rs232upload_flg == YES)
        {
            /*
                Time Stamp the data
            */
            *(long *)&fbbrxbuf[0] = GETTICKS;

            /*
                Convert the Data to type short..strip the Phasing Info
            */
            (unsigned char *)rs232dataptr = &fbbrxbuf[TIMESTAMPSIZE];
            for(i=0;i<devicecount;i++)
            {
                 rs232datacount = 0;
                 while(rs232datacount++ < systemconfig.recsize/2)
                 {
                     *rs232dataptr++ = (short)((((short)(*(unsigned char *) rs232dataptr) & 0x7F) |
                                                (short)(*((unsigned char *) rs232dataptr+1)) << 7)) << 2;
                 }
            }

            /*
                Send all the data out the RS232 Port
            */
            if (send_serial_cmd(rs232comport,(unsigned char *)&fbbrxbuf[0],rs232blocksize)
                != rs232blocksize)
            {
                printf("\n\r** ERROR ** could not send Real Time RS232 Data\n\r");
                rterr_flg = TRUE;
            }
        }
    }

    /*
        Restore the Timer
    */
    if (pctimerstored_flg)
    {
        pctimer_restore();
        printf("\n\rTotal data collection time was %4.3f seconds", (float)(numirqticks * systemconfig.tick_msec) / (float) 1000);
        printf("\n\rReceived %ld records",numfbbrecords);
        printf("\n\rSample Rate was %5.2f samples/sec/device",
              (numfbbrecords/getnumdevices(&systemconfig))/((float)(numirqticks * systemconfig.tick_msec) / (float) 1000));
    }

    /*
        Restore the serial Port configuration
    */
    for (i=0;i<systemconfig.numgroups;i++)
    {
        if (serialconfigsaved[systemconfig.groupconfig[i].comport] == TRUE)
        {
            printf("\n\rRestoring COM%d Configuration",systemconfig.groupconfig[i].comport+1);
            restoreserialconfig(systemconfig.groupconfig[i].comport);
        }
    }

    /*
        Update the File with the Data Store in XMS memory
    */
    if ((systemconfig.datastore_flg) && (datafilehandle >= 0))
    {
        updatedatafile(datafilehandle,xmsstrtptr,systemconfig.filedatasize);
        close(datafilehandle);         /* Close the Data file */
    }

    /*
        Free the XMS memory
    */
    if (xms_memalloc_flg)
    {
        printf("\n\rFreeing XMS Memory");
        xms_free(1);
        xms_memalloc_size = 0;
    }

    /*
        Return to the Main Menu
    */
    exit_flg = FALSE;
    if (rterr_flg)
        return(FALSE);
    else
        return(TRUE);
}

/*
    review_datafile     Review Data Stored on a File

    Prototype in:       dual485.h

    Parameters Passed:  TEXTMODE for Text Mode display
                        GRAPHICSMODE for Graphics display

    Return Value:       TRUE if successful
                        FALSE otherwise

    Remarks:

*/
unsigned char review_datafile(mode)
unsigned char mode;
{
    unsigned char fileheaderbuf[SIZEDATAHEADER];
    unsigned char * dosdataptr;
    unsigned char * tdosdataptr;
    unsigned char * tempdosdataptr;
    unsigned char msgbuf[81];
    unsigned char datafile[81];
    unsigned char * msgbufptr;
    unsigned char temprecsize;
    unsigned char tempdatamode;
    unsigned char numdevices;
    unsigned char tempnumdevices;
    unsigned char tempnumgroups;
    unsigned short temptickmsec;
    unsigned short xmsblocksize;
    short nextaddr;
    short i;
    short fbbcmdaddr;
    short filehandle;
    short usersel_graphaddr;
    short tempgraphaddr;
    long tempfiledatasize;
    long currenttick;
    struct date tempdatecreated;
    struct time temptimecreated;
    int ignore;
    int gdriver;
    int gmode;
    int errorcode;
    float tdist,max_dist;
    float jump_dif, last_value;

    /*
        Get the Filename from the User
    */
    strcpy(msgbuf,systemconfig.datafile);
    msgbufptr = getfilename(msgbuf,&ignore);
    if (ignore) return(TRUE);
    if (msgbufptr)
    {
        strcpy(datafile,msgbuf);
    }

    /*
        Open the File
    */
    _fmode =  O_BINARY;
    if ((filehandle = open(datafile, S_IREAD | S_IWRITE)) < 0)
    {
        printf("\n\r** ERROR ** could not open the data file <%s>\n\r",
               datafile);
        hitkeycontinue();
        return(FALSE);
    }

    /*
        If the User wanted Graphics Mode then ask them which device address
        to display
    */
    if (mode == GRAPHICSMODE)
    {
        tempgraphaddr = getushort("Enter the Address to Visualize",1,30);
        usersel_graphaddr = 1;
        if (tempgraphaddr != ESC_SEL)
        {
            usersel_graphaddr = tempgraphaddr;
        }
    }

    /*
        Read in the Header Info
    */
    if (read(filehandle, fileheaderbuf, SIZEDATAHEADER) != SIZEDATAHEADER)
    {
        printf("\n\r** ERROR ** Could not read the file header\n\r");
        hitkeycontinue();
        return(FALSE);
    }

    /*
        Determine the Block Size
    */
    tempdatecreated = ((struct systemconfigstruct *) fileheaderbuf) -> datecreated;
    temptimecreated = ((struct systemconfigstruct *) fileheaderbuf) -> timecreated;
    temprecsize = ((struct systemconfigstruct *) fileheaderbuf) -> recsize;
    tempnumgroups = ((struct systemconfigstruct *) fileheaderbuf) -> numgroups;
    numdevices = getnumdevices((struct systemconfigstruct *) fileheaderbuf);
    xmsblocksize = (numdevices * temprecsize) + TIMESTAMPSIZE;

    printf("\n\n\rRead in File <%s> created on %d/%d/%d at %d:%2d",
           datafile,
           tempdatecreated.da_mon,tempdatecreated.da_day,tempdatecreated.da_year,
           temptimecreated.ti_hour,temptimecreated.ti_min);

    hitkeycontinue();

    /*
        Allocate a Dos Buffer for Data
    */
    if ((dosdataptr = malloc(xmsblocksize)) == NULL)
    {
        printf("\n\r** ERROR ** could not allocate a DOS Data Buffer");
        hitkeycontinue();
        return(FALSE);
    }
    tdosdataptr = dosdataptr;

    /*
        Now go through the File and print out the data
    */
    tempfiledatasize = ((struct systemconfigstruct *) fileheaderbuf) -> filedatasize;
    tempdatamode = ((struct systemconfigstruct *) fileheaderbuf) -> datamode;
    temptickmsec = ((struct systemconfigstruct *) fileheaderbuf) -> tick_msec;

    /*
       Initialize the Graphics
    */
    if (mode == GRAPHICSMODE)
    {
        /*
            initialize graphics mode
        */
        gdriver = DETECT;
        gmode = VGAHI;
        initgraph(&gdriver, &gmode, "");

        /*
            read result of initialization
        */
        errorcode = graphresult();
        if (errorcode != grOk)  /* an error occurred */
        {
           printf("Graphics error: %s\n", grapherrormsg(errorcode));
           hitkeycontinue();
           return(FALSE);
        }
    }
    
    /*
        Get scaling value from data file 
    */
    max_dist = 0;
    while (tempfiledatasize)
    {
        tempdosdataptr = dosdataptr;    /* reset the pointer */
        if (read(filehandle, tempdosdataptr, xmsblocksize) < 0)
        {
            printf("\n\r** ERROR ** Could not read the file data\n\r");
            hitkeycontinue();
            return(FALSE);
        }

        /*
            Update the number of bytes left
        */
        tempfiledatasize -= xmsblocksize;
        
        tempdosdataptr += TIMESTAMPSIZE;

        nextaddr = 0;
        tempnumdevices = numdevices;
        while (tempnumdevices > 0)
        {
            for(i=0; i<tempnumgroups;i++)
            {
                fbbcmdaddr = ((struct systemconfigstruct *) fileheaderbuf) ->
                               groupconfig[i].addrlist[nextaddr];

                if (fbbcmdaddr != 0)
                {
                    viewdata(tempdosdataptr,tempdatamode,OFF,&tdist);
                    max_dist = max(max_dist,tdist);
                    tempdosdataptr += temprecsize;
                    tempnumdevices--;
                }
            }
            nextaddr++;
        }
    }
    /*
        calculate scale value from total distance measured 
        from file review
    */


    /* 
       reset values for another pass in file
    */
    lseek(filehandle,0L,SEEK_SET);
    read(filehandle, fileheaderbuf, SIZEDATAHEADER);
    dosdataptr = tdosdataptr;
    tempfiledatasize = ((struct systemconfigstruct *) fileheaderbuf) -> filedatasize;
    tempdatamode = ((struct systemconfigstruct *) fileheaderbuf) -> datamode;
    temptickmsec = ((struct systemconfigstruct *) fileheaderbuf) -> tick_msec;


    /*
        Print/Graph each Record from the file
    */
    while (tempfiledatasize && !exit_flg)
    {
        tempdosdataptr = dosdataptr;    /* reset the pointer */
        if (read(filehandle, tempdosdataptr, xmsblocksize) < 0)
        {
            printf("\n\r** ERROR ** Could not read the file data\n\r");
            hitkeycontinue();
            return(FALSE);
        }

        /*
            Update the number of bytes left
        */
        tempfiledatasize -= xmsblocksize;

        /*
            Put up the Time on the Screen
        */
        currenttick = *(long *)tempdosdataptr;
        if (mode == TEXTMODE)
        {
            CLEARSCREEN;
        }
        else if (mode == GRAPHICSMODE)
        {
            gotoxy(1,1);
        }

        /*
            Display the Record Time
        */
        printf("Record Start Time: %5.3f seconds\n\r", (float)(temptickmsec * currenttick)/1000);

        /*
            Update the pointer past the Time Stamp location
        */
        tempdosdataptr += TIMESTAMPSIZE;

        /*
            View the Data on the Screen

            First print out the address.. then the data
        */
        nextaddr = 0;
        tempnumdevices = numdevices;
        while (tempnumdevices > 0)
        {
            for(i=0; i<tempnumgroups;i++)
            {
                fbbcmdaddr = ((struct systemconfigstruct *) fileheaderbuf) ->
                               groupconfig[i].addrlist[nextaddr];
                if (mode == TEXTMODE)
                {
                    printf("\n\rADDRESS %3d:   ", fbbcmdaddr);
                }

                if (fbbcmdaddr != 0)
                {
                    if (mode == TEXTMODE)
                    {
                        viewdata(tempdosdataptr,tempdatamode,ON,&tdist);
                    }
                    else if (mode == GRAPHICSMODE)
                    {
                        if (fbbcmdaddr == usersel_graphaddr)
                        {
                            graphdata(tempdosdataptr,tempdatamode);
                        }
                    }
                    tempdosdataptr += temprecsize;
                    tempnumdevices--;
                }
            }
            nextaddr++;
        }
        /*
            Allow the User to Quit after each review
        */
        if (mode == TEXTMODE)
        {
            while(!ckkbhit());
            if (getkey() == ESC)
                tempfiledatasize = 0;
            clearkey();
        }
        else if (mode == GRAPHICSMODE)
        {
            gotoxy(1,2);
            printf("Hit <I> for zoom IN, <O> for zoom OUT");
            gotoxy(1,3);
            printf("Hit <B> for BIGER cube, <L> for LESS cube, <ESC> or <S> to Stop ");

            delay((unsigned)temptickmsec); /* play back at the record rate */
            if (getusercmd() == ESC_SEL)
                tempfiledatasize = 0;
        }
    }

    if (tempfiledatasize == 0)
    {
        printf ("\n\rData file display complete\n\r");
        hitkeycontinue();
    }

    /*
        restore system to text mode if we are in Graphics mode
    */
    if (mode == GRAPHICSMODE)
    {
        restorecrtmode();
        closegraph();
    }

    free(dosdataptr);
    close(filehandle);
    exit_flg = FALSE;
    return(TRUE);
}


/*
    viewdata            View the Data on the CRT

    Prototype in:       dual485.h

    Parameters Passed:  dosdataptr
                        datamode
                        displaymode - ON/OFF
                        tdist - return total distance from transmitter
                                or quaternain distance

    Return Value:       TRUE if successful
                        FALSE otherwise

    Remarks:

*/
unsigned char viewdata(dosdataptr,datamode,displaymode,tdist)
unsigned char * dosdataptr;
unsigned char datamode;
short displaymode;
float *tdist;
{
    switch (datamode)
    {
        case POS:
            if (!printpos((short *) dosdataptr,OFF,displaymode,tdist))
                return(FALSE);
            break;

        case ANGLE:
            if (!printangles((short *) dosdataptr,OFF,displaymode,tdist))
                return(FALSE);
            break;

        case MATRIX:
            if (!printmatrix((short *) dosdataptr,OFF,displaymode,tdist))
                return(FALSE);
            break;

        case QUATER:
            if (!printquaternions((short *) dosdataptr,OFF,displaymode,tdist))
                return(FALSE);
            break;

        case POSANGLE:
            if (!printposangles((short *) dosdataptr,OFF,displaymode,tdist))
                return(FALSE);
            break;

        case POSMATRIX:
            if (!printposmatrix((short *) dosdataptr,OFF,displaymode,tdist))
                return(FALSE);
            break;

        case POSQUATER:
            if (!printposquaternions((short *) dosdataptr,OFF,displaymode,tdist))
                return(FALSE);
            break;

        default:
            printf("\n\r** ERROR ** illegal Data Mode\n\r");
            return(FALSE);

    }
    return(TRUE);
}

/*
    printpos            Print and File the Position Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
                        buttonmode - ON/OFF
                        displayon - ON/OFF
                        distance - total distance from transmitter

    Return Value:       int 7

    Remarks:
*/
int printpos(birddata,buttonmode,displayon,distance)
short * birddata;
short buttonmode;
short displayon;
float *distance;
{
    short i;
    float floatdata[3];
    float tdist;
    char * printdataformat = "%7.2f %7.2f %7.2f ";

    tdist = 0;
    /*
        Compute the Values
    */
    for (i=0;i<3;i++)
        floatdata[i] = (float)(birddata[i] * posk);

    if (displayon == ON) {
      /*
           Display the Data and Button Value (if required)
      */
      printf(printdataformat,floatdata[0],floatdata[1],floatdata[2]);
      /*
      if (buttonmode != 0)
          printf(printbuttonformat, buttonvalue);
      */
    } else {
      /*
         calculate total distance from transmitter
      */
      tdist = sqrt( floatdata[0]*floatdata[0] + 
                    floatdata[1]*floatdata[1] +
                    floatdata[2]*floatdata[2]  );
    }
    *distance = tdist;

    return(TRUE);
}


/*
    printangles         Print and File the Angle Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
                        buttonmode - ON/OFF
                        displayon - ON/OFF
                        distance - total distance from transmitter

    Return Value:       int 7

    Remarks:
*/
int printangles(birddata,buttonmode,displayon,distance)
short * birddata;
short buttonmode;
short displayon;
float *distance;
{
    short i;
    float floatdata[3];
    float tdist;
    char * printdataformat = "%7.2f %7.2f %7.2f";

    tdist = 0;
    /*
        Compute the Values
    */
    for (i=0;i<3;i++)
        floatdata[i] = (float)(birddata[i] * ANGK);

    if (displayon == ON) {
      /*
           Display the Data and Button Value (if required)
      */
      printf(printdataformat,floatdata[0],floatdata[1],floatdata[2]);

      /*
      if (buttonmode != 0)
          printf(printbuttonformat, buttonvalue);
      */
    } else {
      /*
         calculate total distance from transmitter
      */
      tdist = 0;
    }
    *distance = tdist;

    return(TRUE);
}

/*
    printmatrix         Print and File the matrix Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
                        buttonmode - ON/OFF
                        displayon - ON/OFF
                        distance - total distance from transmitter

    Return Value:       int 7

    Remarks:
*/
int printmatrix(birddata,buttonmode,displayon,distance)
short * birddata;
short buttonmode;
short displayon;
float *distance;
{
    short i;
    float floatdata[9];
    float tdist;
    char * printdataformat = " %7.4f %7.4f %7.4f \n\t\t%7.4f %7.4f %7.4f \n\t\t%7.4f %7.4f %7.4f";

    tdist = 0;
    /*
        Compute the Values
    */
    for (i=0;i<9;i++)
        floatdata[i] = (float)(birddata[i] * WTF);

    if (displayon == ON) {
      /*
           Display the Data and Button Value (if required)
      */
      printf(printdataformat,floatdata[0],floatdata[1],floatdata[2],
                             floatdata[3],floatdata[4],floatdata[5],
                             floatdata[6],floatdata[7],floatdata[8]);
      /*
      if (buttonmode != 0)
          printf(printbuttonformat, buttonvalue);
      */
    } else {
      /*
         calculate total distance from transmitter
      */
      tdist = 0;
    }
    *distance = tdist;

    return(TRUE);
}


/*
    printquaternions    Print and File the  Quaternion Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
                        buttonmode - ON/OFF
                        displayon - ON/OFF
                        distance - total distance from transmitter,
                                   or distance for quaternians

    Return Value:       int 7

    Remarks:
*/
int printquaternions(birddata,buttonmode,displayon,distance)
short * birddata;
short buttonmode;
short displayon;
float *distance;
{
    short i;
    float floatdata[4];
    float tdist;
    char * printdataformat = "%8.4f %8.4f %8.4f %8.4f";

    tdist = 0;
    /*
        Compute the Values
    */
    for (i=0;i<4;i++)
        floatdata[i] = (float)(birddata[i] * WTF);

    if (displayon == ON) {
      /*
           Display the Data and Button Value (if required)
      */
      printf(printdataformat,floatdata[0],floatdata[1],
                             floatdata[2],floatdata[3]);
      /*
      if (buttonmode != 0)
          printf(printbuttonformat, buttonvalue);
      */
    }
      /*
         calculate total distance from transmitter
      */
      tdist = sqrt(
                   floatdata[1]*floatdata[1] +
                   floatdata[2]*floatdata[2] +
                   floatdata[3]*floatdata[3] +
                   floatdata[0]*floatdata[0] );
            
       
    
    *distance = tdist;

    return(TRUE);
}


/*
    printposangless     Print and File the Position and Angles Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
                        buttonmode - ON/OFF
                        displayon - ON/OFF
                        distance - total distance from transmitter

    Return Value:       int 7

    Remarks:
*/
int printposangles(birddata,buttonmode,displayon,distance)
short * birddata;
short buttonmode;
short displayon;
float *distance;
{
    short i;
    float floatdata[6];
    float tdist;
    char * printdataformat = "%7.2f %7.2f %7.2f %7.2f %7.2f %7.2f";

    tdist = 0;
    /*
        Compute the Values
    */
    for (i=0;i<3;i++)
        floatdata[i] = (float)(birddata[i] * posk);

    for (i=3;i<6;i++)
        floatdata[i] = (float)(birddata[i] * ANGK);

    if (displayon == ON) {
      /*
           Display the Data and Button Value (if required)
      */
      printf(printdataformat,floatdata[0],floatdata[1],
                             floatdata[2],floatdata[3],
                             floatdata[4],floatdata[5]);
      /*
      if (buttonmode != 0)
          printf(printbuttonformat, buttonvalue);
      */
    } else {
      /*
         calculate total distance from transmitter
      */
      tdist = sqrt( floatdata[0]*floatdata[0] + 
                    floatdata[1]*floatdata[1] +
                    floatdata[2]*floatdata[2]  );
    }
    *distance = tdist;

    return(TRUE);
}

/*
    printposmatrix      Print and File the position and matrix Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
                        buttonmode - ON/OFF
                        displayon - ON/OFF
                        distance - total distance from transmitter

    Return Value:       int 7

    Remarks:
*/
int printposmatrix(birddata,buttonmode,displayon,distance)
short * birddata;
short buttonmode;
short displayon;
float *distance;
{
    short i;
    float floatdata[12];
    float tdist;
    char * printdataformat = " %7.2f %7.2f %7.2f \n\t\t%7.4f %7.4f %7.4f \n\t\t%7.4f %7.4f %7.4f \n\t\t%7.4f %7.4f %7.4f";

    tdist = 0;

    /*
        Compute the Values
    */
    for (i=0;i<3;i++)
        floatdata[i] = (float)(birddata[i] * posk);
    for (i=3;i<12;i++)
        floatdata[i] = (float)(birddata[i] * WTF);


    if (displayon == ON) {
      /*
           Display the Data and Button Value (if required)
      */
      printf(printdataformat,floatdata[0],floatdata[1],floatdata[2],
                             floatdata[3],floatdata[4],floatdata[5],
                             floatdata[6],floatdata[7],floatdata[8],
                             floatdata[9],floatdata[10],floatdata[11]);
      /*
      if (buttonmode != 0)
          printf(printbuttonformat, buttonvalue);
      */
    } else {
      /*
         calculate total distance from transmitter
      */
      tdist = sqrt( floatdata[0]*floatdata[0] + 
                    floatdata[1]*floatdata[1] +
                    floatdata[2]*floatdata[2]  );
    }
    *distance = tdist;

    return(TRUE);
}




/*
    printposquaternions Print and File the Position and Quaternion Data

    Prototype in:       cmdutil.h

    Parameters Passed:  birddata - array of birddata
                        buttonmode - ON/OFF
                        displayon - ON/OFF
                        distance - total distance from transmitter

    Return Value:       int 7

    Remarks:
*/
int printposquaternions(birddata,buttonmode,displayon,distance)
short * birddata;
short buttonmode;
short displayon;
float *distance;
{
    short i;
    float floatdata[7];
    float tdist;
    char * printdataformat = "%7.2f %7.2f %7.2f %8.4f %8.4f %8.4f %8.4f";

    tdist = 0;
    /*
        Compute the Values
    */
    for (i=0;i<3;i++)
        floatdata[i] = (float)(birddata[i] * posk);

    for (i=3;i<7;i++)
        floatdata[i] = (float)(birddata[i] * WTF);

    if (displayon == ON) {
      /*
           Display the Data and Button Value (if required)
      */
      printf(printdataformat,floatdata[0],floatdata[1],
                             floatdata[2],floatdata[3],
                             floatdata[4],floatdata[5],
                             floatdata[6]);
      /*
      if (buttonmode != 0)
          printf(printbuttonformat, buttonvalue);
      */
    } else {
      /*
         calculate total distance from transmitter
      */
      tdist = sqrt( floatdata[0]*floatdata[0] + 
                    floatdata[1]*floatdata[1] +
                    floatdata[2]*floatdata[2]  );
    }
    *distance = tdist;

    return(TRUE);
}

/*
    viewdata            View the Data on the CRT in Graphics Mode

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
                        FALSE otherwise

    Remarks:

*/
unsigned char graphdata(dosdataptr,datamode)
unsigned char * dosdataptr;
unsigned char datamode;
{
    switch (datamode)
    {
        case POS:
        case ANGLE:
        case MATRIX:
        case QUATER:
        case POSANGLE:
            gotoxy(1,1);
            printf("\n\rMode not currently supported\n\r");
            return(FALSE);

        case POSQUATER:
            convertposquart(dosdataptr);
            break;

        default:
            gotoxy(1,1);
            printf("\n\r** ERROR ** illegal Data Mode\n\r");
            return(FALSE);

    }

    return(TRUE);
}

void convertposquart(dosdataptr)
unsigned char * dosdataptr;
{
    float x,y,z,q0,q1,q2,q3;

    /*
        Get data from the Array and convert to Floats
    */
    x  = *((short *)dosdataptr)++ * posk;
    y  = *((short *)dosdataptr)++ * posk;
    z  = *((short *)dosdataptr)++ * posk;

    q0 = *((short *)dosdataptr)++ * WTF;
    q1 = *((short *)dosdataptr)++ * WTF;
    q2 = *((short *)dosdataptr)++ * WTF;
    q3 = *((short *)dosdataptr)++ * WTF;

    /*
        Convert the Data to Position and Angle...

        Rotation matrix from Quaternions is described in Korns
        Math Handebook, p. 473
    */

    v11 = q0*q0 + q1*q1 - q2*q2 - q3*q3;
    v12 = 2 * (q1*q2 - q0*q3);
    v13 = 2 * (q1*q3 + q0*q2);

    v21 = 2 * (q1*q2 + q0*q3);
    v22 = q0*q0 - q1*q1 + q2*q2 - q3*q3;
    v23 = 2 * (q2*q3 - q0*q1);

    v31 = 2 * (q1*q3 - q0*q2);
    v32 = 2 * (q2*q3 + q0*q1);
    v33 = q0*q0 - q1*q1 - q2*q2 + q3*q3;

    if(position == 1)
    {
        cx = x * 64;   /* 64 to transfer inches to pixels */
        cy = y * 64;
        cz = z * 64;
    }
    if(position == 0)
    {
       cx = 50 * 64;
       cy = 0;
       cz = 0;
    }

    /*
        Update the Cube
    */
    update_cube();
}

/*
    rs232init           -   RS232 Serial Port Initialization

    Prototype in:       dual485.h

    Parameters Passed:  void

    Return Value:       TRUE if successful
                        FALSE if unsuccessful

    Remarks:            Routine prompts the user for the serial port
                        configuration parameters of COM1 or COM2 and
                        tries to configure the port via configserialport()
*/
int rs232init()
{

    short menusel;
    static long baud = 19200L;
    static char * serialhdr =
"****************************************************************************\n\r\
* ASCENSION TECHNOLOGY CORPORATION - RS232 Serial Port Configuration       *\n\r\
****************************************************************************\n\r\n";

    static char * serialmenu[] =
              {"Serial Port Options:",
               "No Change",
               "115200",
               "57600",
               "38400",
               "19200",
               "9600",
               "4800",
               "2400",
               "COM1",
               "COM2",
               "COM3",
               "COM4"};


    /*
        Clear the Screen and Put up a Header
    */
    CLEARSCREEN;
    sendmenuhdr(serialhdr);

    /*
        Save the Serial configuration, if not already saved
    */
    if (!serialconfigsaved[rs232comport])
    {
        if (!saveserialconfig(rs232comport))
        {
            printf("** NOTE ** could not save current serial port configuration\n\r\n\r");
            hitkeycontinue();
        }
        else
        {
            serialconfigsaved[rs232comport] = TRUE;
        }
    }

    /*
        Query the User for the Serial Port configuration
    */
    do
    {
        /*
            Display Current Configuration
        */
        printf("\n\rCurrent Serial Port Configuration: \n\r\t %s at %ld Baud\n\r",
            serialmenu[rs232comport+9],baud);

        /*
            Get menu selection
        */
        if ((menusel = sendmenu(serialmenu,12)) <= 0)   /* ESC or no change */
        {

            /*
                Configure the Serial Port Hardware
            */
            if (!configserialport(rs232comport,baud,RS232_PORT))
            {
                printf("** Error Initializing Serial Port **\n\r");
                hitkeycontinue();
                return(FALSE);
            }
            return(TRUE);                       /* all set...go home */
        }

        if (menusel < 8)                        /* if Baud rate change */
        {
            /*
                Store the New Baud Rate
            */
            baud = atol(serialmenu[menusel+1]);
        }

        /*
            Must be a Com Port Change
        */
        if (menusel == 8)                       /* if Com 1 port Change */
        {
            restoreserialconfig(rs232comport);
            rs232comport = COM1;                     /* set the new port # */
            if (!saveserialconfig(rs232comport))
                return(FALSE);
        }

        if (menusel == 9)                       /* if Com 2 port Change */
        {
            restoreserialconfig(rs232comport);
            rs232comport = COM2;                     /* set the new port # */
            if (!saveserialconfig(rs232comport))
                return(FALSE);
        }

        if (menusel == 10)                      /* if Com 3 port Change */
        {
            restoreserialconfig(rs232comport);
            rs232comport = COM3;                     /* set the new port # */
            if (!saveserialconfig(rs232comport))
                return(FALSE);
        }

        if (menusel == 11)                      /* if Com 4 port Change */
        {
            restoreserialconfig(rs232comport);
            rs232comport = COM4;                     /* set the new port # */
            if (!saveserialconfig(rs232comport))
                return(FALSE);
        }
    }
    while(TRUE);
}

