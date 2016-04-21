/* $Revision: 1.11.6.1 $ $Date: 2003/11/20 11:57:26 $ */
/* adstartgsadadio.c -- Control block for the General Standards ADADIO  */
/* This block is used to start analog acquisition asynchronously from   */
/* reading out the values.                                              */
/* Copyright 1994-2003 The MathWorks, Inc. */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	adstartgsadadio

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "time_xpcimport.h"
#include        "multigsadadio.h"
#include        "ioext_xpcimport.h"
#include        "util_xpcimport.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (10)
#define IN_ENABLE_ARG           ssGetSFcnParam(S,0)
#define OUT_ENABLE_ARG          ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define SLOT_ARG                ssGetSFcnParam(S,3)
#define BCRINIT_ARG             ssGetSFcnParam(S,4)
#define INIT_ARG                ssGetSFcnParam(S,5)
#define CAL_ARG                 ssGetSFcnParam(S,6)
#define DACHANS_ARG             ssGetSFcnParam(S,7)
#define DARESET_ARG             ssGetSFcnParam(S,8)
#define DAIVAL_ARG              ssGetSFcnParam(S,9)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)
#define BASE_ADDR_I_IND         (0)
#define ADDR_MODE_I_IND         (1)   // Addressing mode, 1 = IO, 0 = memory mapped

#define NO_I_WORKS              (2)
#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)

// This board can be factory programmed in EPROM to either respond
// in IO space or in memory mapped space.  This driver adapts to
// either version dynamically.

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!(int)mxGetPr(OUT_ENABLE_ARG)[0])
    {
        ssSetNumOutputPorts(S, 0);
    }
    else
    {
        ssSetNumOutputPorts(S, 1);
        ssSetOutputPortWidth(S, 0, 1);
        ssSetOutputPortDataType(S, 0, SS_BOOLEAN);
    }

    if (!(int)mxGetPr(IN_ENABLE_ARG)[0])
    {
        ssSetNumInputPorts(S, 0);
    }
    else
    {
        ssSetNumInputPorts(S, 1);
        if (!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION))
            return;
    	ssSetInputPortDirectFeedThrough(S, 0, 1);
        ssSetInputPortDataType(S, 0, SS_BOOLEAN );
        ssSetInputPortRequiredContiguous(S, 0, 1);
    }

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);  /* None of the parameters are tunable */
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int portIndex, const DimsInfo_T *dimsInfo)
{
    if (!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo))
        return;
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int portIndex, const DimsInfo_T *dimsInfo)
{
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    if (!ssSetInputPortVectorDimension(S, 0, 1))
        return;
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int portIndex, DTypeId dType)
{
    ssSetInputPortDataType( S, portIndex, dType);
}

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int portIndex, DTypeId dType)
{
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

    PCIDeviceInfo pciinfo;
    void *Physical;
    void *Virtual;
    volatile uint32_T baseaddr;
    uint32_T addrmode;
    char *devName="PMC-ADADIO";
    volatile uint32_T temp;  // volatile to avoid unused variable optimization
    unsigned short vendorID, deviceID, SubvendorID, SubdeviceID;

    vendorID = 0x10b5;
    deviceID = 0x9080;
    SubvendorID = 0x10b5;
    SubdeviceID = 0x2370;

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0)
    {
        if (rl32eGetPCIInfoExt( vendorID, deviceID, SubvendorID, SubdeviceID, &pciinfo))
        {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    }
    else
    {
        int_T bus, slot;
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
        if (rl32eGetPCIInfoAtSlotExt( vendorID, deviceID, SubvendorID, SubdeviceID, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo))
        {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // Find out how the board is mapped and get the memory or IO base address.
    // If addrSpace == 0, then Physical is a memory mapped address.
    // If addrSpace == 1, then Physical is an IO base address.
    addrmode = pciinfo.AddressSpaceIndicator[2];
    Physical = (void *)pciinfo.BaseAddress[2];

    if( addrmode == ADDR_MODE_MEM )
        Virtual = rl32eGetDevicePtr(Physical, 1024, RT_PG_USERREADWRITE);
    baseaddr = (uint32_T)Physical;
//printf("baseaddr = 0x%x, addrmode = %d\n", baseaddr, addrmode );

    ssSetIWorkValue(S, BASE_ADDR_I_IND, baseaddr );
    ssSetIWorkValue(S, ADDR_MODE_I_IND, addrmode );

    // If this block is supposed to do the initialization:
    if ((int_T)mxGetPr(INIT_ARG)[0])
    {
        int_T i;

        if( xpceIsModelInit() && (int)mxGetPr( CAL_ARG )[0] )
        {
            double start, ticks;
            writeLongIO( BCR, START_CAL );
            start = rl32eGetTicksDouble();
            printf("PMC-ADADIO Autocalibration started\n");
            readLongIO( BCR, temp );
            while( (temp & START_CAL) == START_CAL )
            {
                ticks = rl32eGetTicksDouble();
                if( ticks - start > 1193000.0 * 7 ) // 7 second timeout
                {
                    sprintf( msg, "%s Autocalibration timed out", devName );
                    ssSetErrorStatus( S, msg );
                    return;
                }
                readLongIO( BCR, temp );
            }
            if( (temp & CAL_STATUS) == 0 ) // success
                printf("%s Autocalibration succeeded.\n", devName );
            else
            {
                sprintf( msg, "%s Autocalibration failed", devName );
                ssSetErrorStatus( S, msg );
                return;
            }
        }

        /* reset board */
        writeLongIO( BCR, BOARD_RESET );
        readLongIO( BCR, temp );
        while( temp & BOARD_RESET )
            readLongIO( BCR, temp );
        temp = (uint32_T)mxGetPr(BCRINIT_ARG)[0];
        writeLongIO( BCR, temp );
        readLongIO( BCR, temp );

        // Write the values from the DtoA initial value vector
        {
            int ndachans = (int_T)mxGetN(DACHANS_ARG);
            int chan = (int_T)mxGetPr(DACHANS_ARG)[0];
            //printf("ADSTART init: ndachans = %d, chan = %d\n", ndachans, chan );
            if( ndachans > 0 && chan > 0 )
            {
                for( i = 0 ; i < ndachans ; i++ )
                {
                    int val = (int_T)mxGetPr(DAIVAL_ARG)[i];
                    chan = (int_T)mxGetPr(DACHANS_ARG)[i]- 1;
                    //printf("ADSTART init: chan %d, val %d\n", chan, val );
                    writeLongIO( (AOUT0 + chan), val );
                    readLongIO( BCR, temp );
                }
                writeLongIO( BCR, (temp | OUTPUT_STROBE) );
                readLongIO( BCR, temp );
            }
        }
    }
#endif
                 
}					

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint32_T baseaddr = ssGetIWorkValue( S, BASE_ADDR_I_IND );
    uint32_T addrmode = ssGetIWorkValue( S, ADDR_MODE_I_IND );
    uint32_T temp;

    boolean_T *ePtr;
    boolean_T enabled = true;

    if ((int)mxGetPr(IN_ENABLE_ARG)[0])
    {
        ePtr = (boolean_T *)ssGetInputPortSignal( S, 0 );
        enabled = ePtr[0];
    }
    if( (int)mxGetPr(OUT_ENABLE_ARG)[0] )
    {
        ePtr = (boolean_T *)ssGetOutputPortSignal( S, 0 );
        ePtr[0] = enabled;
    }
    if( enabled )
    {
        readLongIO( BCR, temp );
        temp = ( temp & ~INTERRUPT_REQUEST ) | MANUAL_AD_TRIGGER;
        /* start A/D conversion, reset interrupt request */
        writeLongIO( BCR, temp );
        readLongIO( BCR, temp );
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE

    uint32_T baseaddr = ssGetIWorkValue( S, BASE_ADDR_I_IND );
    uint32_T addrmode = ssGetIWorkValue( S, ADDR_MODE_I_IND );
    uint32_T temp;
    int i;

    if ((int_T)mxGetPr(INIT_ARG)[0])
    {
        // Write the values from the DtoA initial value vector
        {
            int ndachans = (int_T)mxGetN(DACHANS_ARG);
            int chan = (int_T)mxGetPr(DACHANS_ARG)[0];
            //printf("ADSTART terminate: nchans = %d, chan = %d\n", ndachans, chan );
            if( ndachans > 0 && chan > 0 )
            {
                for( i = 0 ; i < ndachans ; i++ )
                {
                    int val = (int_T)mxGetPr(DAIVAL_ARG)[i];
                    int reset = (int_T)mxGetPr(DARESET_ARG)[i];

                    chan = (int_T)mxGetPr(DACHANS_ARG)[i] - 1;
                    if( reset == 1 )
                    {
                        writeLongIO( (AOUT0 + chan), val );
                        readLongIO( BCR, temp );
                    }
                }

                writeLongIO( BCR, (temp | OUTPUT_STROBE) );
                readLongIO( BCR, temp );
            }
        }
    }
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


