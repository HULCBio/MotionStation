/* $Revision: 1.6 $ $Date: 2002/05/04 03:55:00 $ */
/* dadsrubymm.c - xPC Target, non-inlined S-function driver for */
/* analog output section of the Diamond Systems Ruby-MM digital */
/* to analog converter pc104 board. */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     dadsrubymm

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "util_xpcimport.h"
#include    "multidsrubymm.h"
#endif

        

/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE0_ARG              ssGetSFcnParam(S,1)
#define RANGE1_ARG              ssGetSFcnParam(S,2)
#define RESET_ARG               ssGetSFcnParam(S,3)
#define INIT_VAL_ARG            ssGetSFcnParam(S,4)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,5)
#define BASE_ARG                ssGetSFcnParam(S,6)

#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (3)
#define BASE_I_IND              (0)
#define POLARITY0_I_IND         (1)
#define POLARITY1_I_IND         (2)

#define NO_R_WORKS              (2)
#define SCALE0_R_IND            (0)
#define SCALE1_R_IND            (1)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0;i<mxGetN(CHANNEL_ARG);i++)
    {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
        ssSetInputPortRequiredContiguous( S, i, 1 );
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

    int32_T    base, polarity;
    real_T     scale;
    int_T      i;

    base = (int_T)mxGetPr(BASE_ARG)[0];
    ssSetIWorkValue( S, BASE_I_IND, base );

    // Determine the scale factors and polarities, given the range options.
    // These are determined by jumper settings and cannot be read from
    // the hardware.  The scale and polarity are used to convert the
    // input floating point values to the integer output values.
    for( i = 0 ; i < 2 ; i++ )
    {
        int range;
        switch( i )
        {
          case 0:
            range = (int)mxGetPr(RANGE0_ARG)[0];
            break;
          case 1:
            range = (int)mxGetPr(RANGE1_ARG)[0];
            break;
        }
        switch( range )
        {
          case 1:    // +-10 volts
            polarity = BIPOLAR;
            scale = 4096.0 / 20.0;
            break;
          case 2:    // +-5 volts
            polarity = BIPOLAR;
            scale = 4096.0 / 10.0;
            break;
          case 3:    // +-2.5 volts
            polarity = BIPOLAR;
            scale = 4096.0 / 5.0;
            break;
          case 4:    // 0-10 volts
            polarity = UNIPOLAR;
            scale = 4096.0 / 10.0;
            break;
          case 5:    // 0-5 volts
            polarity = UNIPOLAR;
            scale = 4096.0 / 5.0;
            break;
          case 6:    // 0-2.5 (adjustable) volts
            polarity = UNIPOLAR;
            scale = 4096.0 / 2.5;
            break;
        }
        switch( i )
        {
          case 0:
            ssSetIWorkValue( S, POLARITY0_I_IND, polarity );
            ssSetRWorkValue( S, SCALE0_R_IND, scale );
            break;
          case 1:
            ssSetIWorkValue( S, POLARITY1_I_IND, polarity );
            ssSetRWorkValue( S, SCALE1_R_IND, scale );
            break;
        }
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int32_T  base, i, polarity[2];
    real_T   *uPtr;
    real_T   scale[2];
    int32_T  nchannels;

    base = ssGetIWorkValue( S, BASE_I_IND );
    polarity[0] = ssGetIWorkValue( S, POLARITY0_I_IND );
    polarity[1] = ssGetIWorkValue( S, POLARITY1_I_IND );
    scale[0] = ssGetRWorkValue( S, SCALE0_R_IND );
    scale[1] = ssGetRWorkValue( S, SCALE1_R_IND );

    nchannels = (int32_T)mxGetN(CHANNEL_ARG);

    for( i = 0 ; i < nchannels ; i++ )
    {
        int_T channel = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
        int_T changroup = channel / 4;
        int32_T temp;
        real_T value;

        uPtr = (real_T *)ssGetInputPortRealSignal(S,i);

        value = uPtr[0];
        switch( polarity[changroup] )
        {
          case UNIPOLAR:
            temp = (int32_T)(scale[changroup] * value);
            break;
          case BIPOLAR:
            temp = (int32_T)(scale[changroup] * value) + 2048;
            break;
        }
        if( temp > 4095 )
            temp = 4095;
        if( temp < 0 )
            temp = 0;
        rl32eOutpB( base + LSB, temp & 0xff );
        rl32eOutpB( base + C0MSB + channel, (temp >> 8) & 0xf );
    }

    rl32eInpB( base + LSB );  // A read from the LSB reg updates all 8 outputs.
#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE

    int32_T nchannels, base, i, polarity[2];
    real_T  value, scale[2];

    base = ssGetIWorkValue( S, BASE_I_IND );
    nchannels = (int32_T)mxGetN(CHANNEL_ARG);
    polarity[0] = ssGetIWorkValue( S, POLARITY0_I_IND );
    polarity[1] = ssGetIWorkValue( S, POLARITY1_I_IND );
    scale[0] = ssGetRWorkValue( S, SCALE0_R_IND );
    scale[1] = ssGetRWorkValue( S, SCALE1_R_IND );

    for( i = 0 ; i < nchannels ; i++ )
    {
        // At load time, set channel to its initial value.
        // At termination, set channel to its initial value if reset requested.

        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) 
        {
            int_T channel = (int_T)mxGetPr(CHANNEL_ARG)[i] - 1;
            int_T changroup = channel / 4;
            int32_T temp;
            real_T value = mxGetPr(INIT_VAL_ARG)[i];

            switch( polarity[changroup] )
            {
              case UNIPOLAR:
                temp = (int32_T)(scale[changroup] * value);
                break;
              case BIPOLAR:
                temp = (int32_T)(scale[changroup] * value) + 2048;
                break;
            }
            if( temp > 4095 )
                temp = 4095;
            if( temp < 0 )
                temp = 0;
            rl32eOutpB( base + LSB, temp & 0xff );
            rl32eOutpB( base + C0MSB + channel, (temp >> 8) & 0xf );
        }
    }

    rl32eInpB( base + LSB );  // A read from the LSB reg updates all 8 outputs.

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
