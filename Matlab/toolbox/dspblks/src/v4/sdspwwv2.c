/*
 *  SDSPWWV2 - IRIG-H Decoder for WWV Time Clock
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.8.4.3 $ $Date: 2004/04/12 23:14:58 $
 */
#define S_FUNCTION_NAME sdspwwv2
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

/* Define IRIG code marker values: */
enum {P_MISS=0, P_ZERO, P_ONE, P_ID};

#define INPORT  0
#define OUTPORT 0

#define IS_ONE(a) ((*(a)==P_ONE)||(*(a)==P_ID))

enum {YEAR_START_ARGC=0, NUM_ARGS};
#define YEAR_START_ARG(S)   (ssGetSFcnParam(S,YEAR_START_ARGC))


static int_T get_bcd(const real_T *x, int_T N) {

	const int_T bcd[] = {1,2,4,8, 10,20,40,80, 100,200};
	int_T       s     = 0;
	int_T       i, iN;

	iN = MIN(N, 4);
	for(i=0; i<iN; i++) {
		s += IS_ONE(x) * bcd[i];
		x++;
	}
	if(N<=4) return(s);

	x++; /* Skip next unused P0 bit */
	iN = MIN(N,8);
	for(i=4; i<iN; i++) {
		s += IS_ONE(x) * bcd[i];
		x++;
	}
	if (N<=8) return(s);

	x++; /* Skip next unused P0 bit */
	for(i=8; i<N; i++) {
		s += IS_ONE(x) * bcd[i];
		x++;
	}
	return(s);
}

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) 
{
    if (OK_TO_CHECK_VAR(S, YEAR_START_ARG(S))) 
    {
        if (mxIsEmpty(YEAR_START_ARG(S))) {
            THROW_ERROR(S, "The year argument must contain integer value.");
        }
        if (mxIsComplex(YEAR_START_ARG(S))) {
            THROW_ERROR(S, "The year argument must be real integer.");
        }
    }
}

static void mdlInitializeSizes(SimStruct *S)
{
    REGISTER_SFCN_PARAMS(S, NUM_ARGS)
    ssSetSFcnParamNotTunable(S, YEAR_START_ARGC);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
#endif

    /* Inputs */
    if (!ssSetNumInputPorts(S, 1)) return;

    if (!ssSetInputPortDimensionInfo(S, INPORT, DYNAMIC_DIMENSION)) return;
    ssSetInputPortFrameData(         S, INPORT, FRAME_INHERITED);
    ssSetInputPortDirectFeedThrough( S, INPORT, 1);
    ssSetInputPortOptimOpts(          S, INPORT, SS_REUSABLE_AND_LOCAL);
    ssSetInputPortOverWritable(      S, INPORT, 0);
    ssSetInputPortRequiredContiguous(S, INPORT, 1);
    
    /* Outputs */
    if (!ssSetNumOutputPorts(S, 1)) return;

    if (!ssSetOutputPortDimensionInfo(S, OUTPORT, DYNAMIC_DIMENSION)) return;
    ssSetOutputPortFrameData(         S, OUTPORT, FRAME_NO);
    ssSetOutputPortOptimOpts(          S, OUTPORT, SS_REUSABLE_AND_LOCAL);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                    SS_OPTION_NONVOLATILE         |
                    SS_OPTION_WORKS_WITH_CODE_REUSE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


/* 
 * Define order of time decoder output values:
 */
typedef struct {
    real_T time;
    real_T ut1;
    real_T year;
    real_T day;
    real_T dst1;
    real_T dst2;
    real_T leap;
} TimeCode;


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef	MATLAB_MEX_FILE
    if (ssGetSampleTime(S, 0) == CONTINUOUS_SAMPLE_TIME) {
        THROW_ERROR(S, "Input to block must have a discrete sample time");
    }
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const real_T *u = ssGetInputPortRealSignal(S, INPORT);
    TimeCode *y = (TimeCode *)ssGetOutputPortSignal(S, OUTPORT);

    int_T  yy, utneg, mm, hh;
    int_T  yearstart =(int_T)((*mxGetPr(YEAR_START_ARG(S))));

#ifdef MATLAB_MEX_FILE
    /* On entry, u should point to the symbol pair {P_ID, P_MISS} */
    if ((u[0] != P_ID) || (u[1] != P_MISS)) {
	THROW_ERROR(S, "Data frame not properly aligned.");
	return;
    }
#endif

    u += 3;   /* Skip marker pair, and an unused P0 */

    y->dst2  = IS_ONE(u);        u++;
    y->leap  = IS_ONE(u);        u++;
    yy       = get_bcd(u, 4);    u += 6;
    mm       = get_bcd(u, 7);    u += 10;
    hh       = get_bcd(u, 6);    u += 10;
    y->time  = (real_T)(100*hh + mm);
    y->day   = (real_T)get_bcd(u, 10);   u += 20;
    utneg    = IS_ONE(u);        u++;
    y->year  = (real_T)(yearstart + yy + 10*get_bcd(u, 4)); u += 4;
    y->dst1  = IS_ONE(u);        u++;
    y->ut1  = (utneg ? -0.1 : 0.1) * (real_T)get_bcd(u, 3);
}


static void mdlTerminate(SimStruct *S)
{
}


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, 
                                      int_T port,
                                      const DimsInfo_T *dimsInfo)
{
    if(!ssSetInputPortDimensionInfo(S, INPORT, dimsInfo)) return;
    ErrorIfInputIsNot1or2D(S, INPORT);

    if (isOutputDynamicallySized(S, OUTPORT)) {
        if(!ssSetOutputPortMatrixDimensions(S, OUTPORT, 7, 1)) return;
    }
}



# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port,
                                          const DimsInfo_T *dimsInfo)
{
    if(!ssSetOutputPortDimensionInfo(S, OUTPORT, dimsInfo)) return;
    ErrorIfOutputIsNot1or2D(S, OUTPORT);
}
#endif

#include "dsp_trailer.c"

/* [EOF] sdspwwv2.c */
