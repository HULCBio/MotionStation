/*
 *  SDSPWWV - IRIG-H Decoder for WWV Time Clock
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.17 $ $Date: 2002/04/14 20:44:19 $
 */
#define S_FUNCTION_NAME sdspwwv
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

/* Define IRIG code marker values: */
enum {P_MISS=0, P_ZERO, P_ONE, P_ID};

#define IS_ONE(a) ((**(a)==P_ONE)||(**(a)==P_ID))

static int_T get_bcd(UPtrsType x, int_T N) {

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


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
#endif

    /* Inputs */
    if (!ssSetNumInputPorts(S, 1)) return;

    ssSetInputPortWidth(            S, 0, 60);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortReusable(        S, 0, 1);
    ssSetInputPortOverWritable(     S, 0, 0);

    /* Outputs */
    if (!ssSetNumOutputPorts(S, 1)) return;

    ssSetOutputPortWidth(    S, 0, 7);
    ssSetOutputPortReusable(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE );
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uptr = ssGetInputPortRealSignalPtrs(S, 0);
    real_T           *y    = ssGetOutputPortRealSignal(S, 0);

    int_T  dst1, dst2, leap, yy, mm, dd, hh, utneg, utmag;

	/* On entry, uptr points to marker pair {P_ID, P_MISS} */
#ifdef MATLAB_MEX_FILE
	if ((*uptr[0] != P_ID) || (*uptr[1] != P_MISS)) {
		ssSetErrorStatus(S, "Data frame not properly aligned.");
		return;
	}
#endif

	uptr += 3;   /* Skip marker pair, and an unused P0 */

	dst2  = IS_ONE(uptr);        uptr++;
	leap  = IS_ONE(uptr);        uptr++;
	yy    = get_bcd(uptr, 4);    uptr += 6;
	mm    = get_bcd(uptr, 7);    uptr += 10;
	hh    = get_bcd(uptr, 6);    uptr += 10;
	dd    = get_bcd(uptr, 10);   uptr += 20;
	utneg = IS_ONE(uptr);        uptr++;
	yy   += 10*get_bcd(uptr, 4); uptr += 4;
	dst1  = IS_ONE(uptr);        uptr++;
	utmag = get_bcd(uptr, 3);

	*y++ = hh*100.0 + mm;
	*y++ = (utneg ? -utmag : utmag) * 0.1;
	*y++ = 1900.0 + yy;
	*y++ = (real_T) dd;
	*y++ = (real_T) dst1;
	*y++ = (real_T) dst2;
	*y   = (real_T) leap;
}


static void mdlTerminate(SimStruct *S)
{
}


#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

/* [EOF] sdspwwv.c */
