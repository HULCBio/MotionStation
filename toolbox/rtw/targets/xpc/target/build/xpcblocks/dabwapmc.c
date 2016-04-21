/* $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:01:55 $ */
/* dabwapmc.c - xPC Target, non-inlined S-function driver for the D/A function */
/* on the BittWare Audio-PMC+ board.                                           */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dabwapmc

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "util_xpcimport.h"
#include        "time_xpcimport.h"
#include        "audPMCHelper.h"

// The 21065 programs are converted from .dxe files to header files
// using the matlab function dxe2array('dirpath\filename.dxe').  This function
// creates 'filename_dxe.h' in the current directory with DspProg
// defined and pointing to the array of data that makes up the executable.

extern long g_verbose;  // Set to 1 to get verbose printouts from pmc_aud routines.

extern arraydes DspProg;

// AudPMCBoards is shared with adbwapmc.c as well.
extern boardInfo AudPMCBoards[NUM_AUDPMC_BOARDS];

#endif  // ifndef MATLAB_MEX_FILE

/* Input Arguments */
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define FRAMESIZE_ARG           ssGetSFcnParam(S,1)
#define SAMPLERATE_ARG          ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)
#define CONVERT_ARG             ssGetSFcnParam(S,4)
#define SLOT_ARG                ssGetSFcnParam(S,5)

#define NO_I_WORKS              (9)
#define PROC_I_IND0             (0)
#define PROC_I_IND1             (1)
// The next 4 are indexed in a loop as (CHAN_1_HDL + i) for i = 0,1,2,3
#define CHAN_1_BUF              (2)
#define CHAN_2_BUF              (3)
#define CHAN_3_BUF              (4)
#define CHAN_4_BUF              (5)
#define BAR0_I_IND              (6)
#define BAR2_I_IND              (7)
#define LAST_FRAME              (8)

#define NO_R_WORKS              (0)

#define NUMBUFS                  3  /* must agree with the value in the AD driver */

static char_T msg[256];

int count1addr;
int count2addr;

static void mdlInitializeSizes(SimStruct *S)
{
    int i;
    int width;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "util_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    width = mxGetPr(FRAMESIZE_ARG)[0];

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0;i<mxGetN(CHANNEL_ARG);i++)
    {
        if( !ssSetInputPortMatrixDimensions( S, i, width, 1 ) )
            return;
    	ssSetInputPortDirectFeedThrough( S, i, 1 );
        ssSetInputPortRequiredContiguous( S, i, 1 );
        ssSetInputPortDataType( S, i, DYNAMICALLY_TYPED );
        if( width > 1 )
            ssSetInputPortFrameData( S, i, 1 );
        else
            ssSetInputPortFrameData( S, i, 0 );
    }

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);  /* None of the parameters are tunable */
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMP_TIME_ARG)[0] == -1.0)
    {
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    }
    else
    {
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
    	ssSetOffsetTime(S, 0, 0.0);
    }
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

    int_T nChannels;
    int_T i, channel;

    PCIDeviceInfo pciinfo;
    PDSP21K processor;
    char devName[20];
    int  devId;
    int  startResult;
    char *apmcaddr;
    int_T bus, slot;
    int  boardNum;
    int  thisBoard;
    int  doinit = 0;

//printf("DA mdlStart running\n");
    nChannels = mxGetN(CHANNEL_ARG);

    strcpy(devName,"BittWare Audio-PMC+");
    devId=0x002c;

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0)
    {
        bus = 0;
        slot = -1;
        /* look for the PCI-Device */
        if (rl32eGetPCIInfo((unsigned short)0x12ba,(unsigned short)devId,&pciinfo))
        {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    }
    else
    {
        if (mxGetN(SLOT_ARG) == 1)
        {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        }
        else
        {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x12ba,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

    // First check to see if this bus/slot has already been initialized.
    thisBoard = -1;
    for( boardNum = 0 ; boardNum < NUM_AUDPMC_BOARDS ; boardNum++ )
    {
        boardInfo *checkBoard = &AudPMCBoards[boardNum];
        if( checkBoard->proc[0] != 0 && checkBoard->proc[1] != 0 )
        {
            if( checkBoard->bus == bus && checkBoard->slot == slot )
            {
                thisBoard = boardNum;
//printf("DA found existing board at slot %d\n", thisBoard );
                break;  // thisBoard points to this board.
            }
        }
    }

    if( thisBoard == -1 )  // We didn't find it above.
    {
        int pnum;
        boardInfo *info;
//printf("DA Board not previously initialized, starting configuration\n");

        doinit = 1;

        for( boardNum = 0 ; boardNum < NUM_AUDPMC_BOARDS ; boardNum++ )
        {
            info = &AudPMCBoards[boardNum];
            if( info->proc[0] == 0 && info->proc[1] == 0 )
            {
                thisBoard = boardNum;
                info->bus = bus;    // Save bus and slot to identify the board.
                info->slot = slot;
                break;
            }
        }        
        if( thisBoard == -1 )
        {
            sprintf( msg, "Unable to find an empty slot for the board at bus = %d, slot = %d.\n", bus, slot );
            ssSetErrorStatus( S, msg );
            return;
        }

        for( pnum = 0 ; pnum < 2 ; pnum++ )  // Set up and download to both DSP's now.
        {
            int frequency;
            int crystal;

            // the pmc_aud routines need 0 or 1 for processor number.
            processor = ConstructProc( &pciinfo, pnum );
            if( processor == 0 )
            {
                sprintf( msg, "Error while constructing AudioPMC descriptor.\n" );
                ssSetErrorStatus( S, msg );
                return;
            }
            info->proc[pnum] = processor;

            if( !dsp21k_dl_dxe_array( processor, &DspProg ) )
            {
                sprintf( msg, "Error downloading the DSP executable file to processor %d\n", pnum );
                ssSetErrorStatus( S, msg );
                return;
            }
            printf("dsp %d loaded\n", pnum);

            // Set up the sample rate and framesize  before starting the processor.
            frequency = mxGetPr(SAMPLERATE_ARG)[0];
            if( frequency < 0 )
            {
                frequency = -frequency;
                crystal = 1;  // Use the 48 Khz crystal
            }
            else
                crystal = 0;  // Use DSP0 PWM output

            xpcSetAudioPMC( processor, pnum,
                            frequency,
                            mxGetPr(FRAMESIZE_ARG)[0],
                            crystal );

        }  // Loop over pnum = 0 and 1
    }

//printf("DA start allocating buffers\n");
    // Do the next section always.  D/A buffer allocation
    if( !xpceIsModelInit() )
    {
        boardInfo *info = &AudPMCBoards[ thisBoard ];
        int pnum;
        int desc_addr;
        int frame_size = mxGetPr( FRAMESIZE_ARG )[0];
        int needbuf[4];
        int channel;
        uint_T nchans = mxGetN( CHANNEL_ARG );

//printf("Allocating buffers for DA\n");

        // Figure out which channels are in use and only allocate
        // buffers for those channels.  This reduces the work that
        // the DSPs have to do since only the channels in use are then
        // transferred.
        for( i = 0 ; i < 4 ; i++ )
            needbuf[i] = 0;   // preset to no buffer needed

        for( i = 0 ; i < nchans ; i++ )
        {
            channel = mxGetPr(CHANNEL_ARG)[i] - 1;  // convert 1 based channel to 0 based
            switch( channel )
            {
              case 0:
              case 1:
              case 4:
              case 5:
                needbuf[channel/2] = 1;
                break;
              case 2:
              case 3:
              case 6:
              case 7:
                needbuf[channel/2] = 1;
                // In addition, we need the first buffer for this
                // DSP for the buffer indicator.
                needbuf[channel/2 - 1] = 1;
                break;
            }
        }

        // Save processor pointers for mdlOutputs and mdlTerminate
        ssSetIWorkValue( S, PROC_I_IND0, (int)info->proc[0] );
        ssSetIWorkValue( S, PROC_I_IND1, (int)info->proc[1] );

        desc_addr = dsp21k_get_addr( info->proc[0], "_numadbufs" );
        dsp21k_dl_int( info->proc[0], desc_addr, NUMBUFS );
        dsp21k_dl_int( info->proc[1], desc_addr, NUMBUFS );

        // Allocate host buffers to receive data from the DSPs.  Each DSP
        // gets 2 of these.  The implicit structure is:
        // typedef struct {
        //    int current_buffer, dummy;
        //    struct {
        //      int leftdata;
        //      int rightdata;
        //    } data[ NUMBUFS ][ framesize ];
        // } buffer;
        // The DSP side puts data into a buffer with DMA, sets
        // current_buffer to indicate which part of the buffer, then
        // signals an interrupt that causes mdlOutputs to execute.

        for( i = 0 ; i < 4 ; i++ )
        {
            int raw_buffer;
            int direct_buffer;
            int virtual;
            int test;
            int j;
            int size;

            if( needbuf[i] == 0 )  // Are we using this buffer?
                continue;  // No, don't allocate a buffer.

            pnum = i/2;
            desc_addr = dsp21k_get_addr( info->proc[pnum], "_host_buffers" );
            // Output buffers are indices 2,3 on each processor.
            desc_addr += i%2 + 2;

            // Add 16 bytes to the size.  8 bytes of host_desc for the last
            // buffer indicator, plus 8 bytes of alignment space.
            size = NUMBUFS * frame_size * sizeof( host_desc ) + 16;
            // With very small buffers, the initial search for a buffer with
            // virtual == physical takes too long and Matlab gets a timeout.
            // With a minimum allocation size of 1024, the timeout doesn't
            // occur.
            if( size < 1024 )
                size = 1024;

            do
            {
                raw_buffer = (int)malloc( size );
                // We only allow physical == virtual buffers here
                // Assume raw_buffer is a good physical address and 
                // get virtual address translation and see if they are equal.
                virtual = (int)rl32eGetDevicePtr( (void *)raw_buffer, size, RT_PG_USERREADWRITE );
                if( virtual == 0 )
                {
                    sprintf( msg, "Unable to find a suitable DMA buffer\n" );
                    ssSetErrorStatus( S, msg );
                    return;
                }
                if( size >= 4096 )
                {
                    // If size >= 4096, then we have to check the second page
                    // as well.  The frame size is limited to 256 elements
                    // which is less than 2 pages.
                    if( raw_buffer + 4096 != (int)rl32eGetDevicePtr( (void *)(raw_buffer+4096), size - 4096, RT_PG_USERREADWRITE ) )
                        continue;  // Try again.
                }
                // Check the end of the buffer since it may have crossed
                // a page boundary.
                if( raw_buffer + size-8 != (int)rl32eGetDevicePtr( (void *)(raw_buffer+size-8), 8, RT_PG_USERREADWRITE ) )
                    continue;  // Try again.
            } while( virtual != raw_buffer );  // should work on any system
//printf("DA: raw = 0x%x, addr = 0x%x\n", raw_buffer, desc_addr );

            for( j = 0 ; j < size/4 ; j++ )
                *((int *)raw_buffer + j) = 0;  // Clear the buffers.

            direct_buffer = (raw_buffer + 7) & ~0x7;
            // We need the raw_buffer pointer to free in mdlTerminate, so
            // just save the raw pointer and realign in mdlOutputs.
            ssSetIWorkValue( S, CHAN_1_BUF + i, raw_buffer );

            dsp21k_dl_int( info->proc[pnum], desc_addr, direct_buffer );
            // The duplicate write appears necessary sometimes.  Occasionally
            // one of the writes doesn't go through.  This is bothersome!
            dsp21k_dl_int( info->proc[pnum], desc_addr, direct_buffer );

            test = dsp21k_ul_int( info->proc[pnum], desc_addr );
            if( test != direct_buffer )
            {
                sprintf( msg, "WARNING: buffer address download error" );
                ssSetErrorStatus( S, msg );
                return;
            }
        }
    }

    if( doinit == 1 )
    {
        // Start both processors
        boardInfo *info = &AudPMCBoards[ thisBoard ];
        int pnum;
        int desc_addr;

        for( pnum = 0 ; pnum < 2 ; pnum++ )
        {
            printf("Start DSP %d\n", pnum );
            if(dsp21k_start(info->proc[pnum]) != TRUE)
            {
                sprintf( msg, "Error starting DSP processor %d", pnum );
                ssSetErrorStatus( S, msg );
                return;
            }
        }
        ssSetIWorkValue( S, LAST_FRAME, 0 );
        desc_addr = dsp21k_get_addr( info->proc[0], "_reset_flag" );
        dsp21k_dl_int( info->proc[0], desc_addr, 1 );
        dsp21k_dl_int( info->proc[1], desc_addr, 1 );

        if(0)
        {
            // Enable interrupts from the board.
            int temp;
            int simask, sistatus;
            unsigned char mbcontents = 0;

            // Get bar0 (pciinfo.BaseAddress[0] for xpcmain use) 
            // Remove when the general interrupt acknowledge framework
            // is available.
// printf("bar0 = 0x%x\n", pciinfo.BaseAddress[0] );

            apmcaddr = (char *)pciinfo.BaseAddress[0];
            ssSetIWorkValue( S, BAR0_I_IND, (int)apmcaddr );

            // Set mailbox interrupt mask
            *(volatile char *)(apmcaddr + 0x8d) = 0xff;
            // read mailbox interrupt status
            temp = *(volatile char *)(apmcaddr + 0x85);
            // Clear mailbox interrupt status
            *(volatile char *)(apmcaddr + 0x85) = temp;
            // Read SharcFIN interrupt mask
            simask = *(volatile int *)(apmcaddr + 0x160);
            // Read SharcFIN interrupt status
            sistatus = *(volatile int *)(apmcaddr + 0x178) & simask;
            // Clear SharcFIN interrupt mask
            *(volatile int *)(apmcaddr + 0x160) = 0;
            // Set User Interrupt mask
            *(volatile char *)(apmcaddr + 0x8f) = 1;

            // Read each mailbox once or we don't get any interrupts!
            mbcontents = *(volatile char *)(apmcaddr + 0x78); 
            mbcontents = *(volatile char *)(apmcaddr + 0x79); 
            mbcontents = *(volatile char *)(apmcaddr + 0x7a); 
            mbcontents = *(volatile char *)(apmcaddr + 0x7b); 
            mbcontents = *(volatile char *)(apmcaddr + 0x7c); 
            mbcontents = *(volatile char *)(apmcaddr + 0x7d); 
            mbcontents = *(volatile char *)(apmcaddr + 0x7e); 
            mbcontents = *(volatile char *)(apmcaddr + 0x7f); 
        }
    }
//printf("DA mdlStart ending\n");
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    real_T  *y;
    void *u;
    int *ui;
    uint_T nchans = mxGetN( CHANNEL_ARG );
    uint_T width = mxGetPr( FRAMESIZE_ARG )[0];
    host_desc *buffer;
    int i;
    int j;
    int channel;
    int lr;
    PDSP21K processor[2];
    int pnum;
    int reset_addr;
    int stuff_frame[2];
    int overrun[2];

    processor[0] = (PDSP21K)ssGetIWorkValue( S, PROC_I_IND0 );
    processor[1] = (PDSP21K)ssGetIWorkValue( S, PROC_I_IND1 );

    // DSP tells us which part of the buffer was last sent to DA.
    buffer = (host_desc *)ssGetIWorkValue( S, CHAN_1_BUF );
    buffer = (host_desc *)(((int)buffer + 7) & ~7);
    if( buffer != 0 )
    {
        stuff_frame[0] = (buffer->lower + 2) % NUMBUFS;
        overrun[0] = buffer->upper;
    }
    else
    {
        stuff_frame[0] = 0;
        overrun[0] = 0;
    }
    buffer = (host_desc *)ssGetIWorkValue( S, CHAN_3_BUF );
    buffer = (host_desc *)(((int)buffer + 7) & ~7);
    if( buffer != 0 )
    {
        stuff_frame[1] = (buffer->lower + 2) % NUMBUFS;
        overrun[1] = buffer->upper;
    }
    else
    {
        stuff_frame[1] = 0;
        overrun[1] = 0;
    }

    if( overrun[0] || overrun[1] )
    {
        double time = mxGetPr(SAMP_TIME_ARG)[0];
        sprintf( msg, "DSP Overrun (DA)" );
        ssSetErrorStatus( S, msg );
        rl32eWaitDouble( time );  // Force overload by waiting the whole sample time.
        return;
    }

    for( i = 0 ; i < nchans ; i++ )
    {
        DTypeId inputType;

        channel = mxGetPr(CHANNEL_ARG)[i] - 1;  // convert 1 based channel to 0 based
        inputType = ssGetInputPortDataType( S, channel );
        pnum = channel / 4; // 0 or 1
        lr = channel & 1;
        channel = channel / 2;  // Since 2 channels of data per buffer, interleaved
        buffer = (host_desc *)ssGetIWorkValue( S, CHAN_1_BUF + channel );
        if( buffer == 0 )
            continue;  // No buffer in use.
        buffer = (host_desc *)(((int)buffer + 7) & ~7);
        // if this is the second channel in a buffer, add 4 bytes to the address.
        // Plus skip the 8 byte last frame indicator at the beginning.
        buffer = (host_desc *)((int)buffer + 8 + 4 * lr);
        buffer += stuff_frame[pnum] * width;  // point to the correct part of the buffer
        u = (void *)ssGetInputPortSignal( S, i );
        switch( inputType )
        {
          case SS_DOUBLE:
            y = (real_T *)u;
            for( j = 0 ; j < width ; j++ )
                (buffer + j)->lower = (int)(y[j] * (double)(0x7fffffff));
            break;

          case SS_INT32:
            ui = (int *)u;
            for( j = 0 ; j < width ; j++ )
            {
                (buffer + j)->lower = (int)ui[j] << 8;
            }
            break;

          default:
            // ERROR: illegal data type of input data
            sprintf( msg, "Illegal input data type, %d", inputType );
            ssSetErrorStatus( S, msg );
            return;
        }
    }
#endif


}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    PDSP21K processor[2];
    int i, j;
    void *buffer;
    int desc_addr;

//printf("DA mdlTerminate starting\n");
    // free all the processor structs for all boards.  If the pointer
    // is already 0, then another driver got here first.
    for( i = 0 ; i < NUM_AUDPMC_BOARDS ; i++ )
    {
        boardInfo *checkBoard = &AudPMCBoards[i];
        // Free memory allocated during mdlStart.
        if( checkBoard->proc[0] != 0 )
        {
//            desc_addr = dsp21k_get_addr( checkBoard->proc[0], "_avg_idle" );
//            printf("dsp0 average idle = %f\n", dsp21k_ul_flt( checkBoard->proc[0], desc_addr ) );

            // Set the buffer pointers to 0 on first DSP
            // This stops both the A/D and the D/A from accessing host memory.
            desc_addr = dsp21k_get_addr( checkBoard->proc[0], "_host_buffers" );
            for( j = 0 ; j < 4 ; j++ )
                dsp21k_dl_int( checkBoard->proc[0], desc_addr + j, 0 );

            DestroyProc( checkBoard->proc[0] );
            checkBoard->proc[0] = 0;
        }
        if( checkBoard->proc[1] != 0 )
        {
//            desc_addr = dsp21k_get_addr( checkBoard->proc[1], "_avg_idle" );
//            printf("dsp1 average idle = %f\n", dsp21k_ul_flt( checkBoard->proc[1], desc_addr ) );

            // Set the buffer pointers to 0 on second DSP
            desc_addr = dsp21k_get_addr( checkBoard->proc[1], "_host_buffers" );
            for( j = 0 ; j < 4 ; j++ )
                dsp21k_dl_int( checkBoard->proc[1], desc_addr + j, 0 );

            DestroyProc( checkBoard->proc[1] );
            checkBoard->proc[1] = 0;
        }
        checkBoard->bus = 0;
        checkBoard->slot = 0;
    }

    for( j = 0 ; j < 4 ; j++ )
    {
        buffer = (void *)ssGetIWorkValue( S, CHAN_1_BUF + j );
        if( buffer != 0 )
            free( buffer );
    }

//printf("DA mdlTerminate ending\n");
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
