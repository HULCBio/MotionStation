/* $Revision: 1.10 $ $Date: 2002/03/25 04:05:14 $ */
/* dacbisa.c - xPC Target, non-inlined S-function driver for analog output section of ComputerBoards/NI ISA D/A sections ot boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     dacbisa

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
#include    "xpcniatcal.h"
#endif

        

/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE_ARG               ssGetSFcnParam(S,1)
#define RESET_ARG               ssGetSFcnParam(S,2)
#define INIT_VAL_ARG            ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define BASE_ARG                ssGetSFcnParam(S,5)
#define DEV_ID_ARG              ssGetSFcnParam(S,6)


#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (4)
#define BASE_I_IND              (0)
#define NCHANNELS_I_IND         (1)
#define RESINT_I_IND            (2)
#define DEV_ID_I_IND            (3)


#define NO_R_WORKS              (32)
#define GAIN_R_IND              (0)
#define OFFSET_R_IND            (16)


static char_T msg[256];

#ifndef     MATLAB_MEX_FILE
#include    "xpcniatcal.c"
#endif


static void mdlInitializeSizes(SimStruct *S)
{

    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input args expected, %d passed", NUMBER_OF_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUMBER_OF_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);


        
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}
 
#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


    int_T   nChannels, base, i, channel, range, counts; 
    real_T  *RWork=ssGetRWork(S);
    int_T   *IWork=ssGetIWork(S);
    real_T  resFloat, value;

    IWork[DEV_ID_I_IND]=(int_T)mxGetPr(DEV_ID_ARG)[0];

    switch (IWork[DEV_ID_I_IND]) {
        case 1:         // CIO-DDA06/12
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
        case 2:         // CIO-DAC08/12
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
        case 3:         // CIO-DAC16/12
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
        case 4:         // CIO-DDA06/16
            resFloat=resFloat=65536.0;
            IWork[RESINT_I_IND]=65535;
            break;
        case 5:         // CIO-DAC08/16
            resFloat=resFloat=65536.0;
            IWork[RESINT_I_IND]=65535;
            break;
        case 6:         // CIO-DAC16/16
            resFloat=resFloat=65536.0;
            IWork[RESINT_I_IND]=65535;
            break;
        case 7:         // PC104-DAC06/12
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
        case 8:         // CIO-DAS1601/12
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
        case 9:         // CIO-DAS1602/12
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
        case 10:        // CIO-DAS1602/16
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
        case 11:        // NI AT-AO-6
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
        case 12:        // NI AT-AO-10
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;

    }
    
    base=(int_T)mxGetPr(BASE_ARG)[0];
    IWork[BASE_I_IND]=base;
  
    nChannels = mxGetN(CHANNEL_ARG);
    IWork[NCHANNELS_I_IND]=nChannels;

   
    for (i=0;i<nChannels;i++) {
        channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
        range=100*mxGetPr(RANGE_ARG)[i];
        switch (range) {
            case -1000:
                RWork[GAIN_R_IND+channel-1]=20.0/resFloat;
                RWork[OFFSET_R_IND+channel-1]=10.0;
                break;
            case -500:
                RWork[GAIN_R_IND+channel-1]=10.0/resFloat;
                RWork[OFFSET_R_IND+channel-1]=5.0;
                break;
            case -250:
                RWork[GAIN_R_IND+channel-1]=5.0/resFloat;
                RWork[OFFSET_R_IND+channel-1]=2.5;
                break;
            case -167:
                RWork[GAIN_R_IND+channel-1]=3.34/resFloat;
                RWork[OFFSET_R_IND+channel-1]=1.67;
                break;
            case 1000:
                RWork[GAIN_R_IND+channel-1]=10.0/resFloat;
                RWork[OFFSET_R_IND+channel-1]=0.0;
                break;
            case 500:
                RWork[GAIN_R_IND+channel-1]=5.0/resFloat;
                RWork[OFFSET_R_IND+channel-1]=0.0;
                break;
            case 250:
                RWork[GAIN_R_IND+channel-1]=2.5/resFloat;
                RWork[OFFSET_R_IND+channel-1]=0.0;
                break;
            case 167:
                RWork[GAIN_R_IND+channel-1]=1.67/resFloat;
                RWork[OFFSET_R_IND+channel-1]=0.0;
                break;
        }
                    
    }

    switch (IWork[DEV_ID_I_IND]) {

    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
        break;

    case 11:
    case 12:

        /* calibrate DACs */
        {
           unsigned int value;
           int error;

           rl32eOutpW((unsigned short)(base+0x0a),(unsigned short)0x0000); 
           rl32eOutpW((unsigned short)(base+0x02),(unsigned short)0x0000); 
           ao_6_10_cfg1_val=0x0000;
           ao_6_10_cfg2_val=0x0000;
           for (i=0;i<nChannels;i++) {
                int_T channele, channelc;
                channele=(int_T)mxGetPr(CHANNEL_ARG)[i]-1;
                channelc=(int_T)mxGetPr(CHANNEL_ARG)[i]-1;
                if (channele>5) {
                    channele=96+channele*2+1;
                } else {
                    channele=96+channele*2;
                } 
                if (channelc>5) {
                    switch (channelc) {
                        case 6:
                            channelc=20;
                            break;
                        case 7:
                            channelc=22;
                            break;
                        case 8:
                            channelc=16;
                            break;
                        case 9:
                            channelc=18;
                            break;
                    }
                } else {
                    channelc=channelc*2;
                }
                error = eeprom_read(AT_AO_6_10, base, channele, &value);
                if (error) {
                    sprintf(msg,"DAC calibration error 1");
                    ssSetErrorStatus(S,msg);
                    return;
                }
                //printf("%d,%d,%d\n",value, channele,channelc);
                error = caldac_wr(AT_AO_6_10, base, channelc, value);
                if (error) {
                    sprintf(msg,"DAC calibration error 2");
                    ssSetErrorStatus(S,msg);
                    return;
                }
                error = eeprom_read(AT_AO_6_10, base, channele+1, &value);
                if (error) {
                    sprintf(msg,"DAC calibration error 3");
                    ssSetErrorStatus(S,msg);
                    return;
                }
                //printf("%d,%d,%d\n",value, channele+1,channelc+1);
                error = caldac_wr(AT_AO_6_10, base, channelc+1, value);
                if (error) {
                    sprintf(msg,"DAC calibration error 4");
                    ssSetErrorStatus(S,msg);
                    return;
                }
            }
        }

        rl32eOutpW((unsigned short)(base+0x0a),(unsigned short)0x0000); // enable additional CFG registers
        rl32eOutpW((unsigned short)(base+0x02),(unsigned short)0x1f00); // straight binary mode
        rl32eOutpW((unsigned short)(base+0x0a),(unsigned short)0x0080); // disable additional CFG registers
        break;

    }

#endif
                     
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int_T               channel, base, i, counts;
    InputRealPtrsType   uPtrs;
    real_T              *RWork=ssGetRWork(S);
    int_T               *IWork=ssGetIWork(S);
    real_T              value;

    base=IWork[BASE_I_IND];

    switch (IWork[DEV_ID_I_IND]) {

    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:

        for (i=0;i<IWork[NCHANNELS_I_IND];i++) {
            channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
            uPtrs=ssGetInputPortRealSignalPtrs(S,i);
            value=*uPtrs[0];
            counts=(value+RWork[OFFSET_R_IND+channel-1])/RWork[GAIN_R_IND+channel-1];
            if (counts>IWork[RESINT_I_IND]) counts=IWork[RESINT_I_IND];
            if (counts<0)    counts=0;
            if (IWork[DEV_ID_I_IND]<8) {
                rl32eOutpW((unsigned short)(base+(channel-1)*2),(unsigned short)counts);
            } else {
                rl32eOutpB((unsigned short)(base+i*2+4),(unsigned short)((counts << 4) & 0x00f0));
                rl32eOutpB((unsigned short)(base+i*2+1+4),(unsigned short)((counts >> 4) & 0x00ff));
            }
        }
        if (IWork[DEV_ID_I_IND]<8) {
            rl32eInpB((unsigned short)(base+0x0));
        }
        break;

    case 11:
    case 12:

        for (i=0;i<IWork[NCHANNELS_I_IND];i++) {
            channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
            uPtrs=ssGetInputPortRealSignalPtrs(S,i);
            value=*uPtrs[0];
            counts=(value+RWork[OFFSET_R_IND+channel-1])/RWork[GAIN_R_IND+channel-1];
            if (counts>IWork[RESINT_I_IND]) counts=IWork[RESINT_I_IND];
            if (counts<0)    counts=0;
            rl32eOutpW((unsigned short)(base+0x0c+(channel-1)*2),(unsigned short)counts);
        }
        break;

    }
    
#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE

    int_T               channel, base, i, counts;
    real_T              *RWork=ssGetRWork(S);
    int_T               *IWork=ssGetIWork(S);
    real_T              value;

    base=IWork[BASE_I_IND];

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    switch (IWork[DEV_ID_I_IND]) {

    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:

        for (i=0;i<IWork[NCHANNELS_I_IND];i++) {
            if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
                value=(real_T)mxGetPr(INIT_VAL_ARG)[i];
                channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
                counts=(value+RWork[OFFSET_R_IND+channel-1])/RWork[GAIN_R_IND+channel-1];
                if (counts>IWork[RESINT_I_IND]) counts=IWork[RESINT_I_IND];
                if (counts<0)    counts=0;
                if (IWork[DEV_ID_I_IND]<8) {
                    rl32eOutpW((unsigned short)(base+(channel-1)*2),(unsigned short)counts);
                } else {
                    rl32eOutpB((unsigned short)(base+i*2+4),(unsigned short)((counts << 4) & 0x00f0));
                    rl32eOutpB((unsigned short)(base+i*2+1+4),(unsigned short)((counts >> 4) & 0x00ff));
                }
            }
        }
        if (IWork[DEV_ID_I_IND]<8) {
            rl32eInpB((unsigned short)(base+0x0));
        }
        break;

    case 11:
    case 12:

        for (i=0;i<IWork[NCHANNELS_I_IND];i++) {
            if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
                value=(real_T)mxGetPr(INIT_VAL_ARG)[i];
                channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
                counts=(value+RWork[OFFSET_R_IND+channel-1])/RWork[GAIN_R_IND+channel-1];
                if (counts>IWork[RESINT_I_IND]) counts=IWork[RESINT_I_IND];
                if (counts<0)    counts=0;
                rl32eOutpW((unsigned short)(base+0x0c+(channel-1)*2),(unsigned short)counts);
            }
        }
        break;

    }
    
    
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
