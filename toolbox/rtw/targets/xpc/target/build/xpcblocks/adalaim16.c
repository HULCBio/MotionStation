/* $Revision: 1.2 $ $Date: 2002/03/25 03:59:09 $ */
/* adalaim16.c - xPC Target, non-inlined S-function driver for     */
/* the analog input section of the Analogic AIM16-1/104 and -2/104 */
/* analog to digital converter pc104 board. */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	adalaim16

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"io_xpcimport.h"
#include 	"multialaim16.h"
#endif

	    

/* Input Arguments */
#define NUMBER_OF_ARGS          (6)
#define FIRST_CHANNEL_ARG       ssGetSFcnParam(S,0)
#define LAST_CHANNEL_ARG        ssGetSFcnParam(S,1)
#define COUPLING_ARG            ssGetSFcnParam(S,2)
#define GAIN_ARG                ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG          	ssGetSFcnParam(S,4)
#define BASE_ARG                ssGetSFcnParam(S,5)

#define NO_I_WORKS              (2)
#define BASE_I_IND              (0)
#define NCHANS_I_IND            (1)

#define NO_R_WORKS              (16)
// SCALE value uses indexes 0-15
#define SCALE_R_IND             (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int i;
        int first_channel, last_channel, nchans;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    first_channel = (int)mxGetPr(FIRST_CHANNEL_ARG)[0];
    last_channel = (int)mxGetPr(LAST_CHANNEL_ARG)[0];
    nchans = last_channel - first_channel + 1;

    ssSetNumOutputPorts(S, nchans );
    for( i = 0 ; i < nchans ; i++ )
    {
        ssSetOutputPortWidth(S, i, 1);
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
    if (mxGetPr(SAMP_TIME_ARG)[0]==-1.0)
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

    int32_T    base, polarity, coupling;
    int32_T    first_channel, last_channel, nchans;
    real_T     scale;
    int_T      i;
    int16_T    asr = 0;
    int32_T    gainreg;
    int16_T    csr, csrdio;
    bool       bit16;

    base = (int_T)mxGetPr(BASE_ARG)[0];
    ssSetIWorkValue( S, BASE_I_IND, base );

    // Read and reset the board, don't change the MSB/LSB direction bits.
    csr = rl32eInpW( base + CSR );
    csrdio = csr & (CSRLSBOUT | CSRMSBOUT);
    rl32eOutpW( base + CSR, CSRRESET );
    rl32eOutpW( base + CSR, 0 );
    rl32eOutpW( base + CSR, csrdio );  // Put the DIO direction bits back.

    // Channels are 1 based in Matlab, 0 based in the hardware.
    first_channel = (int32_T)mxGetPr(FIRST_CHANNEL_ARG)[0] - 1;
    last_channel = (int32_T)mxGetPr(LAST_CHANNEL_ARG)[0] - 1;
    nchans = last_channel - first_channel + 1;
    ssSetIWorkValue( S, NCHANS_I_IND, nchans );

    asr = (first_channel & 0xf) + ((last_channel & 0xf) << 4);
    asr |= ASRSOFT | ASRM0 | ASRBURST;
    // Software triggered in mode 0 with mode 0 burst enabled.

    coupling = (int_T)mxGetPr(COUPLING_ARG)[0];
    if( coupling == 2 )  // If differential input is selected.
        asr |= ASRDIFF;

    rl32eOutpW( base + ASR, asr );
    
    // Since we aren't using DMA, set the DTR register to 0.
    rl32eOutpW( base + DTR, 0 );

    // Read the uni/bipolar jumper on the board.
    //  If polarity == CSRUB, then the board is jumpered for unipolar input.
    polarity = rl32eInpW( base + CSR ) & CSRUB;

    // Determine the scale factors, given the gain choices
    // and the position of the uni/bipolar jumper on the board.
    // Compute and write the gain registers.  The lower 16 bits
    // in gainreg go to GR1 and the upper 16 bits go to GR2.
    // In differential mode, only GR1 is used.
    asr = rl32eInpW( base + ASR );
    bit16 = ((asr & ASR16BIT) == ASR16BIT);
    gainreg = 0;
    if( bit16 )
    {
        for( i = 0 ; i < nchans ; i++ )
        {
            real_T scale;
            int32_T index = first_channel + i;
            int32_T gain = (int_T)mxGetPr(GAIN_ARG)[i];
            int32_T gainbit;
            switch( gain )
            {
              case 1:  // +-10
                scale = 20.0 / 65536.0;
                gainbit = 0;
                break;
              case 2:  // +-5
                scale = 10.0 / 65536.0;
                gainbit = 1;
                break;
              case 4:  // +-2.5
                scale = 5.0 / 65536.0;
                gainbit = 2;
                break;
              case 8:  // +-1.25
                scale = 2.5 / 65536.0;
                gainbit = 3;
                break;
            }
            gainreg |= gainbit << (2*index);
            if( polarity == CSRUB )
                scale *= 0.5;

            // Store in the order of the channels, but not according
            // to the real channel, just the position.
            ssSetRWorkValue( S, SCALE_R_IND + i, scale );
        }
    }
    else
    {
        for( i = 0 ; i < nchans ; i++ )
        {
            real_T scale;
            int32_T index = first_channel + i;
            int32_T gain = (int_T)mxGetPr(GAIN_ARG)[i];
            int32_T gainbit;
            switch( gain )
            {
              case 1:  // +-10
                scale = 20.0 / 65536.0;
                gainbit = 0;
                break;
              case 10: // AIM12, gain 10, +-1
                scale = 2.0 / 65536.0;
                gainbit = 1;
                break;
              case 100: // AIM12, gain 100, +-0.1
                scale = 0.2 / 65536.0;
                gainbit = 2;
                break;
            }
            gainreg |= gainbit << (2*index);
            if( polarity == CSRUB )
                scale *= 0.5;

            // Store in the order of the channels, but not according
            // to the real channel, just the position.
            ssSetRWorkValue( S, SCALE_R_IND + i, scale );
        }
    }

    rl32eOutpW( base + GR1, gainreg & 0xffff );
    rl32eOutpW( base + GR2, (gainreg >> 16) & 0xffff );

    // Last item is to set the GO bit in the CSR
    // Be careful to not modify the DIO direction bits.
    csr = rl32eInpW( base + CSR );
    rl32eOutpW( base + CSR, (csr | CSRGO) & ~(CSRRESET | CSROFFSET | CSRDMAST ));
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int32_T  base, i;
    real_T   *uPtr;
    real_T   scale;
    int32_T  nchans;
    int16_T  csr, csrtest;

    base = ssGetIWorkValue( S, BASE_I_IND );

    nchans = ssGetIWorkValue( S, NCHANS_I_IND );

    // Read the CSR so we don't mess with the DIO direction bits.
    csr = rl32eInpW( base + CSR );
    rl32eOutpW( base + CSR, csr | CSRSTRIG );

    for( i = 0 ; i < nchans ; i++ )
    {
        uint16_T unival;    // Unipolar value goes into unsigned int.
        int16_T bival;      // Bipolar value goes into a signed int.
        real_T value;

        uPtr = (real_T *)ssGetOutputPortSignal(S,i);

        csrtest = csr;
        while( (csrtest & CSRDA) == 0 )
        {
            csrtest = rl32eInpW( base + CSR );
        }

        scale = ssGetRWorkValue( S, SCALE_R_IND + i );
        // Let the FPU worry about the difference bewteen signed
        // and unsigned so we don't have to.
        if( csr & CSRUB )
        {
            unival = rl32eInpW( base + ADR );
            uPtr[0] = scale * (double)unival;
        }
        else
        {
            bival = rl32eInpW( base + ADR );
            uPtr[0] = scale * (double)bival;
        }
    }

    // Reset the CSR to stop further conversions.
    rl32eOutpW( base + CSR, csr );
#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE


#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


