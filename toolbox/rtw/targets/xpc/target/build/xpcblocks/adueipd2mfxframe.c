/* $Revision: 1.1.6.2 $ $Date: 2003/12/01 04:25:38 $ */
/* adueipd2mfxframe.c - xPC Target, non-inlined S-function driver */
/* for A/D section of UEI series boards                           */
/* Copyright 1996-2003 The MathWorks, Inc.                        */

// #define 		XPC 1

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         adueipd2mfxframe

#include        <stddef.h>
#include        <stdlib.h>
#include        <math.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "time_xpcimport.h"
#include 	"ioext_xpcimport.h"
#include        "ueidefines.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (20)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define GAIN_ARG             	ssGetSFcnParam(S,1)
#define MUX_ARG             	ssGetSFcnParam(S,2)
#define RANGE_ARG             	ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define FRAME_TIME_ARG          ssGetSFcnParam(S,5)
#define SLOT_ARG                ssGetSFcnParam(S,6)
#define DEV_ARG                 ssGetSFcnParam(S,7)
#define GAINVAL_ARG             ssGetSFcnParam(S,8)
#define BOARD_ARG             	ssGetSFcnParam(S,9)
#define DEVNAME_ARG            	ssGetSFcnParam(S,10)
#define FRAMESIZE_ARG           ssGetSFcnParam(S,11)
#define FREQ_ARG                ssGetSFcnParam(S,12)
#define SH_ARG                  ssGetSFcnParam(S,13)
#define SEDIFF_ARG              ssGetSFcnParam(S,14)
#define BURST_ARG               ssGetSFcnParam(S,15)
#define NBURSTS_ARG             ssGetSFcnParam(S,16)
#define SLAVE_ARG               ssGetSFcnParam(S,17)
#define OUTFMT_ARG              ssGetSFcnParam(S,18)
#define CLSOURCE_ARG            ssGetSFcnParam(S,19)

#define NO_I_WORKS              (7)
#define CHANNELS_I_IND          (0)
#define BOARD_I_IND          	(1)
#define BUFFER_BASE_I_IND       (2)
#define PAGE0_I_IND             (3)
#define PAGE1_I_IND             (4)
#define BASE_ADDR_IND           (5)
#define START_I_IND             (6)

#define NO_R_WORKS              (2)
#define RANGE_R_IND          	(0)
#define OFFSET_R_IND          	(1)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{	    

    int i;
    int width;
    int outfmt;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
	sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected ",NUMBER_OF_ARGS);
	ssSetErrorStatus(S,msg);
	return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));

    width = (int)mxGetPr(FRAMESIZE_ARG)[0];
    outfmt = (int)mxGetPr(OUTFMT_ARG)[0];
    for (i=0;i<mxGetN(CHANNEL_ARG);i++)
    {
        if( !ssSetOutputPortMatrixDimensions( S, i, width, 1 ) )
            return;
        if( outfmt == 1 ) // use frame output if size > 1
        {
            if( width > 1 )
                ssSetOutputPortFrameData( S, i, 1 );
            else
                ssSetOutputPortFrameData( S, i, 0 );
        }
        else
            ssSetOutputPortFrameData( S, i, 0 );
    }

    ssSetNumInputPorts(S, 0);

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
    real_T output;
    int  subDevId = (int)mxGetPr(DEV_ARG)[0];
    int_T bus, slot;
    void *Physical0;
    void *Virtual0;
    PCIDeviceInfo pciinfo;
    uint16_T wArr[10];
    uint32_T range;
    int_T board;
    char_T devName[50];
    int sediff;
    uint32_T dwChList[PD_MAX_CL_SIZE];
    uint32_T stat;
    uint16_T sample;
    int_T samples;
    int config = 0;
    int cvfreq;
    unsigned int divisor;
    double frametime;
    unsigned int cldivisor;
    unsigned int framesize;
    bool bufok;
    unsigned int bufbaseaddr;
    unsigned int page0addr;
    unsigned int page1addr;
    unsigned int statbaseaddr;
    unsigned int burstsize = (unsigned int)mxGetPr( BURST_ARG )[0];
    unsigned int nbursts = (unsigned int)mxGetPr( NBURSTS_ARG )[0];
    unsigned int BMParamList[4];
    int initstatus;
    unsigned int uctintset;
    TEvents events = {0};
    int slave = mxGetPr(SLAVE_ARG)[0];
    int clsource = mxGetPr( CLSOURCE_ARG )[0];

    //printf("uei mdlStart\n");
    nChannels = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);

    // Set the startup flag to indicate that this is startup.
    ssSetIWorkValue(S, START_I_IND, 0 );

    mxGetString(DEVNAME_ARG,devName, mxGetN(DEVNAME_ARG));

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0)
    {
	/* look for the PCI-Device */
	if (rl32eGetPCIInfoExt((unsigned short)0x1057,
                               (unsigned short)0x1801,
                               (unsigned short)0x54A9,
                               (unsigned short)subDevId,
                               &pciinfo))
	{
	    sprintf(msg,"%s: board not present", devName);
	    ssSetErrorStatus(S,msg);
	    return;
	}
    } else
    {
	int_T bus, slot;
	if (mxGetN(SLOT_ARG) == 1)
	{
	    bus = 0;
	    slot = (int_T)mxGetPr(SLOT_ARG)[0];
	} else
	{
	    bus = (int_T)mxGetPr(SLOT_ARG)[0];
	    slot = (int_T)mxGetPr(SLOT_ARG)[1];
	}
	// look for the PCI-Device
	if (rl32eGetPCIInfoAtSlotExt((unsigned short)0x1057,
                                     (unsigned short)0x1801,
                                     (unsigned short)0x54A9,
                                     (unsigned short)subDevId,
                                     (slot & 0xff) | ((bus & 0xff)<< 8),
                                     &pciinfo))
	{
	    sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
	    ssSetErrorStatus(S,msg);
	    return;
	}
    }

    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 0x8000, RT_PG_USERREADWRITE);

    ssSetIWorkValue( S, BASE_ADDR_IND, (int)pciinfo.BaseAddress[0] );

    board = pd_xpc_assign_device( subDevId,
                                  pciinfo.BaseAddress[0],
                                  pciinfo.InterruptLine);	
    ssSetIWorkValue(S, BOARD_I_IND, board);
    //printf("AD frame, board = %d\n", board );

    if( board < 0 )
    {
        switch( board )
        {
        case -2:  // This should never happen, it indicates an inconsistancy
            sprintf(msg,"%s : Different subdevice ID for board at same address",devName );
            break;
        case -3:
            sprintf(msg,"%s : Too many UEI devices",devName );
            break;
        case -4:
            sprintf(msg,"%s : Error downloading firmware to the board",devName );
            break;
        }
        ssSetErrorStatus(S,msg);
        return;
    }

    // Set up the counter, UCT2
    if( !pd_uct_reset(board) )
    {
	ssSetErrorStatus( S, "Error resetting counter");
	return;
    }

    framesize = (int)mxGetPr(FRAMESIZE_ARG)[0];
    // I need to pass the total number of samples in a frame to
    // the board.  Since framesize is the number of samples per channel,
    // I have to multiply by the number of channels.
    //printf("framesize = %d, total size = %d\n", framesize, nChannels*framesize );
    if( !pd_uct_write(board, 
	    UCT_SelCtr2 | UCT_Mode2 | UCT_RW16bit | ((nChannels * framesize)<<8) ) )
    {
	ssSetErrorStatus( S, "Error setting counter modes");
	return;
    }

    if( !pd_uct_set_config(board, UTB_CLK2 | UTB_CLK2_1 | UTB_SWGATE2 ) )
    {
	ssSetErrorStatus( S, "Error setting counter configuration");
	return;
    }

    if (!pd_ain_reset(board))
    {
	ssSetErrorStatus(S,"Error in pd_ain_reset");
	return;
    }

    switch ((int_T)mxGetPr(RANGE_ARG)[0]) {
    case 1:
	range= AIN_BIPOLAR | AIN_RANGE_10V;
	ssSetRWorkValue(S, RANGE_R_IND, 20.0/65536.0);
	ssSetRWorkValue(S, OFFSET_R_IND, 0.0);
	break;
    case 2:
	range= AIN_BIPOLAR;
	ssSetRWorkValue(S, RANGE_R_IND, 10.0/65536.0);
	ssSetRWorkValue(S, OFFSET_R_IND, 0.0);
	break;
    case 3:
	range= AIN_RANGE_10V;
	ssSetRWorkValue(S, RANGE_R_IND, 10.0/65536.0);
	ssSetRWorkValue(S, OFFSET_R_IND, 5.0);
	break;
    case 4:
	range= 0x0;
	ssSetRWorkValue(S, RANGE_R_IND, 5.0/65536.0);
	ssSetRWorkValue(S, OFFSET_R_IND, 2.5);
	break;
    }

    // From the mask, sediff == 1 if single ended, 2 if differential.
    sediff = mxGetPr(SEDIFF_ARG)[0];

    config = range;
    if( sediff == 2 )  // if differential
        config |= AIN_DIFFERENTIAL;

    // Select the 33 Mhz base frequency for both clocks.
    config |= AIB_INTCVSBASE | AIB_INTCLSBASE;

    // Select Bus Master mode
    config |= AIB_SELMODE0 | AIB_SELMODE1;

    if( slave == 0 ) // The master board programs its CV and CL clocks
    {
        // The mask init file computes the CV frequency needed and already
        // checked against the maximum for this board.
        cvfreq = (int)(mxGetPr(FREQ_ARG)[0]);

        if( clsource == 1 ) // Internal CL source
        {
            config |= AIN_CL_CLOCK_INTERNAL | AIN_CV_CLOCK_INTERNAL;
        }
        else if( clsource == 2 ) // External CL source
        {
            config |= AIN_CL_CLOCK_EXTERNAL | AIN_CV_CLOCK_INTERNAL;
            //printf("External CL clock\n");
        }
        // Set config BEFORE setting divisor or the clock doesn't run!
        if (!pd_ain_set_config(board, config, 0, 0))
        {
            ssSetErrorStatus(S,"error in pd_ain_set_config");
            return;
        }

        frametime = mxGetPr(FRAME_TIME_ARG)[0];  // seconds per complete frame
        cldivisor = 33000000 * frametime / framesize - 1;
        //printf("clfreq = %f, cldivisor = %d\n", framesize / frametime, cldivisor );
        if (!pd_ain_set_cl_clock( board, cldivisor ))
        {
            ssSetErrorStatus(S,"Error setting CL clock");
            return;
        }

        divisor = (33000000 / cvfreq) - 1;
        //printf("cvfreq = %d, cvdivisor = %d\n", cvfreq, divisor );
        if (!pd_ain_set_cv_clock( board, divisor ))
        {
            ssSetErrorStatus(S,"Error setting CV clock");
            return;
        }

        {
            volatile long *ueiaddr;
            volatile int temp;
            int i, j;

            // Enable INTA, master only
            if( !pd_adapter_enable_interrupt( board, 1 ) )
            {
                ssSetErrorStatus( S, "Error enabling interrupts");
                return;
            }

            ueiaddr = (long *)Virtual0;

            // Check for interrupt pending bit
            temp = *(ueiaddr + DSP_HSTR);
            if( temp & (1<<HSTR_HINT) )
            { 
                // Clear any pending interrupt before starting the board.
                *(ueiaddr + DSP_HCVR) = (unsigned long)(1 | PD_BRDINTACK);
                for( i = 0 ; ; i++ )
                {
                    for( j = 100 ; j ; j-- )
                        ;
                    temp = *(ueiaddr + DSP_HSTR);
                    if( !(temp & (1<<HSTR_HINT) ) )
                        break;
                }
                // Re Enable INTA, master only if we had an int to clear!
                if( !pd_adapter_enable_interrupt( board, 1 ) )
                {
                    ssSetErrorStatus( S, "Error enabling interrupts");
                    return;
                }
            }
        }

    }
    else  // Slave sets clock input to external
    {
        config |= AIN_CL_CLOCK_EXTERNAL | AIN_CV_CLOCK_EXTERNAL;
        // Set config BEFORE setting divisor or the clock doesn't run!
        if (!pd_ain_set_config(board, config, 0, 0))
        {
            ssSetErrorStatus(S,"error in pd_ain_set_config");
            return;
        }
    }
    // Possible future enhancement is to define the start and stop triggers.

    for (i = 0; i < nChannels; i++)
    {
        dwChList[i] = CHLIST_ENT((int_T)mxGetPr(CHANNEL_ARG)[i]-1, (int_T)mxGetPr(GAIN_ARG)[i], (int_T)mxGetPr(MUX_ARG)[i]);
    }

    if (!pd_ain_set_channel_list(board, nChannels, dwChList))
    {
        ssSetErrorStatus(S,"error in pd_ain_set_channel_list"); 
        return;
    }   

    // Need to allocate 2 contiguous buffers and communicate the addresses
    // to the bus master mode on the board.
    // The data is 12, 14 or 16 bits but the board uses 24 bit memory
    // and DMA expands this to 32 bits so each sample fills 4 bytes
    // with the top 2 bytes always 0.
    // We need 2 buffers of size: (4 * framesize * nChannels) bytes
    // Since these need to be both contiguous and need physical == virtual,
    // we need to check.  If physical == virtual for all pages in the buffer,
    // then it is contiguous.  The buffer also needs to be aligned on
    // a 256 byte boundary.  The bottom 8 bits of the address must be 0.
    // Allocate size+256 bytes.  Check every 4096 bytes to verify
    // that physical == virtual.  If not, drop the buffer and try again.
    // Save the address in a work variable so we can free it in mdlTerminate.
    // Find the first 256 byte boundary in the buffer by adding 255 and masking
    // off the bottom 8 bits.  That is the buffer address we send to the board.
    // Do that twice.

    // This is a bit of a hack, but the xPC kernel doesn't have a function
    // to simply return the physical address of a virtual buffer.

    // First pass: the board will DMA at most 1024 samples at a time.  With
    // the alignment constraints, allocate 8192+4096 bytes and put both
    // buffers in that space.  The DMA engine doesn't seem to work if the
    // buffers are not both page aligned.
    
    // Need to check base and base+4096 for physical==virtual
    bufok = false;
#define ALIGN 4096
#define SIZE  4096
#define NBUFS 2
    while( !bufok )
    {
        bufbaseaddr = (unsigned int)malloc( NBUFS*SIZE+ALIGN );
        if( bufbaseaddr == 0 )
        {
            ssSetErrorStatus(S,"Can't find a suitable buffer for DMA");
            return;
        }
        // Buffers that don't have physical == virtual are dropped.
        // They won't be recovered until a reboot.  Verify that this works with
        // future versions of the kernel!
        // This check isn't completely general but is ok for 4K buffers.
        if( bufbaseaddr == (unsigned int)rl32eGetDevicePtr( (void *)bufbaseaddr, SIZE, RT_PG_USERREADWRITE) )
        {
            if( bufbaseaddr+SIZE == (unsigned int)rl32eGetDevicePtr( (void *)(bufbaseaddr+SIZE), ALIGN, RT_PG_USERREADWRITE) )
                bufok = true;
        }
    }
    page0addr = (bufbaseaddr + (ALIGN-1)) & ~(ALIGN-1);
    page1addr = page0addr + SIZE;

    // Initialize to dummy values to see when we start writing to the buffer by DMA.
    for( i = 0 ; i < 1024 ; i++ )
    {
        ((long *)page0addr)[i] = i;
        ((long *)page1addr)[i] = 1024 - i;
    }
    *(long *)page0addr = -1;  // data not ready flag, DMA zeros the upper 16 bits.
    *(long *)page1addr = -1;

    //printf("page0addr = 0x%x, page1addr = 0x%x\n", page0addr, page1addr );
    ssSetIWorkValue( S, BUFFER_BASE_I_IND, bufbaseaddr );  // Will free this in terminate
    ssSetIWorkValue( S, PAGE0_I_IND, page0addr );
    ssSetIWorkValue( S, PAGE1_I_IND, page1addr );

    // Get the base of the DSP status memory area from the fixed location
    // '2' in DSP memory.
    statbaseaddr = pd_dsp_reg_read( board, 2 );
    //printf("statbaseaddr = 0x%x\n", statbaseaddr );

    // Write additional parameters to set up bus master mode. 

    // Set real time bus master mode to 1, 0 would turn off bus master mode.
    if( !pd_dsp_reg_write( board, statbaseaddr+ADRREALTIMEBMMODE, 1 ) )
    {
        ssSetErrorStatus(S,"Error enabling bus master mode");
        return;
    }
    // This value is (burstsize - 1).  Some PCI bus extenders won't
    // work with the burst size larger than 8.
    // This is the number of samples per burst so 8 is 16 bytes.
    // burstsize and nbursts are computed in the m file that validates the mask parameters
    if( !pd_dsp_reg_write( board, statbaseaddr+ADRAIBM_DEFDMASIZE, burstsize - 1 ) )
    {
        ssSetErrorStatus(S,"Error enabling bus master mode");
        return;
    }
    // DEFBURSTS is the number of full DMA bursts in a transfer.
    // There may be a remainder that will also be transferred.
    if( !pd_dsp_reg_write( board, statbaseaddr+ADRAIBM_DEFBURSTS, nbursts ) )
    {
        ssSetErrorStatus(S,"Error enabling bus master mode");
        return;
    }
    // Same as DEFDMASIZE, but shifted above the bottom 16 bits of the word.
    if( !pd_dsp_reg_write( board, statbaseaddr+ARDAIBM_DEFBURSTSIZE, (burstsize - 1) << 16 ) )
    {
        ssSetErrorStatus(S,"Error enabling bus master mode");
        return;
    }
    if( !pd_dsp_reg_write( board, statbaseaddr+ADRAIBM_TRANSFERSIZE, burstsize * (nbursts - 1) ) )
    {
        ssSetErrorStatus(S,"Error enabling bus master mode");
        return;
    }
 
    // Have to set up the Bus Master parameter block.
    BMParamList[0] = page0addr >> 8;
    BMParamList[1] = page1addr >> 8;
    BMParamList[2] = 1;  // Size of half fifo, set to 1, not used in this mode.
    BMParamList[3] = 1;  // Not used
    if( !pd_ain_set_busmaster_list( board, BMParamList ) )
    {
        ssSetErrorStatus( S, "Error sending bus master parameters" );
        return;
    }

    // Enable the UCT2 interrupt and acknowledge any outstanding status,
    // Enable page completion and error, ack both pages and error status.
    events.ADUIntr = UTB_Uct2Im | UTB_Uct2IntrSC;  // Enable counter 2 ints to board
    events.AInIntr = AIB_BMPgDoneIm | AIB_BMErrIm;   // Enable bus master ints
    events.AInIntr |= AIB_BMPg0DoneSC | AIB_BMPg1DoneSC | AIB_BMErrSC;
    pd_enable_events( board, &events );

    // The set_enable command has to be sent in the prehook file in
    // the start routine, not here.  Change this once I turn interrupts from the
    // board on.
    if (!pd_ain_set_enable_conversion(board, TRUE))
    {
        sprintf(msg, "On board %d, error in pd_ain_set_enable_conversion", board );
        ssSetErrorStatus( S, msg );
        return;
    }

    //printf("init order: board %d, slave = %d\n", board, slave );

    // When the master hits the start trigger in the starthook function,
    // then the clocks start and all boards run.  The master has to wait
    // until the starthook function or else slow mdlStart functions for
    // the rest of the model may cause a buffer overrun on the board. 
    if( slave == 1 )  // Only the slave does this here
    {
        if (!pd_ain_sw_start_trigger(board))
        {
            ssSetErrorStatus(S,"error in pd_ain_sw_start_trigger");
            return;
        }
    }

    //printf(" exit\n");
    //rl32eWaitDouble( .005 );  // Wait 5 ms to let any long delays happen

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE
    //    unsigned long *baseaddr = (unsigned long *)ssGetIWorkValue( S, BASE_ADDR_IND );
    int_T nChannels = ssGetIWorkValue( S, CHANNELS_I_IND );
    int_T framesize = (int)mxGetPr(FRAMESIZE_ARG)[0];
    int_T board = ssGetIWorkValue( S, BOARD_I_IND );
    int_T startflag = ssGetIWorkValue( S, START_I_IND );
    int_T overflag = 0;
    real_T range = ssGetRWorkValue( S, RANGE_R_IND );
    real_T offset = ssGetRWorkValue( S, OFFSET_R_IND );
    volatile long *page0addr = (long *)ssGetIWorkValue( S, PAGE0_I_IND );
    volatile long *page1addr = (long *)ssGetIWorkValue( S, PAGE1_I_IND );
    volatile long *currentbuffer;
    real_T  *y;
    int_T chan;
    int_T sample;
    TEvents events;
    TEvents cevents = {0};
    unsigned int value;
    int slave = mxGetPr(SLAVE_ARG)[0];
    double sampletime = mxGetPr(SAMP_TIME_ARG)[0];

    cevents.ADUIntr = 0;
    cevents.AIOIntr = 0;
    cevents.AInIntr = 0;
    cevents.AOutIntr = 0;

    // Determine the most recent buffer completed, page 0 or page 1.
    if( !pd_adapter_get_board_status( board, &events ) )
    {
        ssSetErrorStatus(S,"error getting board status in mdlOutputs");
        // Force an overrun by delaying more than sampletime.
        if( sampletime != -1 )
            rl32eWaitDouble( 2.0 * sampletime );
        return;
    }

    if( events.AInIntr & AIB_BMErrSC )
    {
	//printf("brd status: board %d, slave = %d, status = 0x%x\n", board, slave, events.AInIntr );
	cevents.AInIntr |= AIB_BMErrSC;
        overflag = 1;
        if( startflag == 1 )
        {
            printf("Buffer overrun on UEI board %d\n", board );
            // Force an overrun by delaying more than sampletime.
            if( sampletime != -1 )
                rl32eWaitDouble( 2.0 * sampletime );
        }
    }
    else
    {
        overflag = 0;
        startflag = 1;  // Not in startup mode anymore.
        ssSetIWorkValue( S, START_I_IND, startflag );  // Not startup anymore
    }

    // This logic assumes that we will service and empty a buffer before the
    // next one is available.
    currentbuffer = page0addr; // Preset and use buffer 0 if neither buffer completed.
    //printf("Board = 0x%x, ADUIntr = 0x%x, AIOIntr = 0x%x\nAInIntr = 0x%x, AOutIntr = 0x%x\n",
    //       events.Board, events.ADUIntr, events.AIOIntr, events.AInIntr, events.AOutIntr );

    cevents.ADUIntr = UTB_Uct2Im | UTB_Uct2IntrSC;  // Enable counter 2 ints to board
    cevents.AInIntr = events.AInIntr & 0xf0000;
    if( events.AInIntr & AIB_BMPg0DoneSC )
    {
	cevents.AInIntr |= AIB_BMPg0DoneSC;
        //printf("0");
    }
    if( events.AInIntr & AIB_BMPg1DoneSC )
    {
	currentbuffer = page1addr;
	cevents.AInIntr |= AIB_BMPg1DoneSC;
        //printf("1");
    }
    // During the startup transient, we may get both pages completed!
    // If that happens, just ignore, but only the first time on startup.

    if( cevents.AInIntr == 0 )
    {
	printf("No buffers completed!\n");
    }

    if( overflag == 0 )
    {
        //    printf("buffer start = 0x%x\n", currentbuffer );
        // Copy samples from the specified buffer to the output vector, 
        // scaling on the way
        for( chan = 0 ; chan < nChannels ; chan++ )
        {
            real_T gainmult = 1.0 / mxGetPr(GAINVAL_ARG)[chan];
            real_T gainrange = range * gainmult;
            real_T gainoffset = offset * gainmult;
            volatile long *bufferpos = &currentbuffer[chan];

            y = ssGetOutputPortSignal( S, chan );

            for( sample = 0 ; sample < framesize ; sample++ )
            {
                short val = (short)((*bufferpos)&0xffff);
                y[sample] = val * gainrange + gainoffset;
                bufferpos += nChannels;
            }
        }
    }
    else
    {
        // On overrun, return 0 data.
        for( chan = 0 ; chan < nChannels ; chan++ )
        {
            y = ssGetOutputPortSignal( S, chan );

            for( sample = 0 ; sample < framesize ; sample++ )
            {
                y[sample] = 0.0;
            }
        }
    }
    *page0addr = -1;
    *page1addr = -1;

    //printf("about to reenable events\n");
    //printf("writing AInIntr = 0x%x\n", cevents.AInIntr );
    if( !pd_enable_events( board, &cevents ) )
    {
        printf("error resetting board status in mdlOutputs\n");
        // Force an overrun by delaying more than sampletime.
        if( sampletime != -1 )
            rl32eWaitDouble( 2.0 * sampletime );
        return;
    }
    if( slave == 0 )
    {
        if( !pd_adapter_enable_interrupt( board, 1 ) )
        {
            ssSetErrorStatus( S, "Error enabling interrupts");
            // Force an overrun by delaying more than sampletime.
            if( sampletime != -1 )
                rl32eWaitDouble( 2.0 * sampletime );
            return;
        }
    }
#endif

}


static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE    
    unsigned int bufbaseaddr = ssGetIWorkValue( S, BUFFER_BASE_I_IND );
    int_T board = ssGetIWorkValue( S, BOARD_I_IND );

    pd_adapter_set_board_event1( board, 0 );  // Stop UCT interrupts
    if( !pd_uct_reset(board) )
    {
        ssSetErrorStatus( S, "Error resetting counter");
        return;
    }
    if (!pd_ain_set_enable_conversion(board, FALSE))
    {
        ssSetErrorStatus(S,"error in pd_ain_set_enable_conversion");
        return;
    }
#if 0
    if (!pd_ain_sw_stop_trigger(board))
    {
        ssSetErrorStatus(S,"error in pd_ain_sw_start_trigger");
        return;
    }
#endif
    //if (!pd_ain_reset(board))
    // {
    //    ssSetErrorStatus(S,"Error in pd_ain_reset");
    //    return;
    //}
    if( bufbaseaddr != 0 )
        free( (void *)bufbaseaddr );

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
