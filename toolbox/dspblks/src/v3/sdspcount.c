/*
 * SDSPCOUNT DSP Blockset Counter block
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.37.4.1 $  $Date: 2004/01/25 22:39:38 $
 */

#define S_FUNCTION_NAME sdspcount
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

/*
 * ----------------------------------------------------------
 * Simulink/RTW zero-crossing detector function prototype:
 *
 * OBSOLETE FOR DSP BLOCKSET 5.0 (Release 13) AND LATER
 * THIS IS JUST FOR CERTAIN S-FCNS FROM RELEASE 11.x !!!
 * ----------------------------------------------------------
 */
extern ZCEventType rt_ZCFcn(ZCDirection direction,
                            ZCSigState *prevSigState, 
                            real_T      zcSig);

/* Determine if we have an input event. */
#define GET_EVENT(S, IDX) \
	(EdgeTrig) ? (rt_ZCFcn(zc_dir, (ZCSigState *)(ssGetIWork(S) + PREV_CLK_STATE), \
			     *in_clk[IDX]) != NO_ZCEVENT) \
               : ((FreeRun) ? 1 : (*in_clk[IDX] != 0.0))

/* Reset counter state and re-test for hitvalue: */
#define RESET_CNT_IF_RST_TRUE(RST, DTYPE) \
if(RST) *cnt = (DTYPE)mxGetPr(INITIALCOUNT_ARG)[0];

/* Clear all hit_out outputs to zero. */
#define CLEAR_HIT_OUT(hit_port) \
if(hit_port) { \
	int_T i;   \
	for(i=0; i<OutputFrameSize; i++) { \
		hit_out[i] = 0;  \
	} \
}


/* Process count witha user defined maximum. */
#define COUNT_WITH_USER_DEF_MAX(S, IDX, dir, cnt, maxcount) \
if (GET_EVENT(S, IDX)) { \
	if (dir == DIR_UP) { \
		if (*cnt < maxcount) (*cnt)++; \
		else (*cnt) = 0; \
	} else { \
		if (*cnt > 0) (*cnt)--; \
		else (*cnt) = maxcount; \
	} \
}

/* Process count with a maximum defined by the data type. */
#define COUNT_WITH_TYPE_DEF_MAX(S, IDX, dir, cnt) \
if (GET_EVENT(S, IDX)) (dir == DIR_UP) ? (*cnt)++ : (*cnt)--;


#define UPDATE_CNT_IF_EVENT(S, IDX, UserDefMax, dir, cnt, maxcount) \
if(!UserDefMax) { \
   COUNT_WITH_TYPE_DEF_MAX(S, IDX, dir, cnt) \
} else { \
   COUNT_WITH_USER_DEF_MAX(S, IDX, dir, cnt, maxcount) \
}


#define UPDATE_CNT_AND_OUTPUTS(D_TYPE, cnt_port, hit_port, UserDefMax, dir) {  \
	D_TYPE      *cnt      = ssGetDWork(S, DWORK_CNT); \
	const int_T  port_num = (cnt_port)   ? OUTPORT_HIT : OUTPORT_HIT-1; \
	D_TYPE       maxcount = (UserDefMax) ? (D_TYPE)(mxGetPr(MAXCOUNT_ARG)[0])       : 0;    \
	real_T      *cnt_out  = (cnt_port)   ? ssGetOutputPortRealSignal(S, OUTPORT_CNT) : NULL; \
	real_T      *hit_out  = (hit_port)   ? ssGetOutputPortRealSignal(S, port_num)    : NULL; \
	int_T        i; \
\
	/* Reset input is always scalar and occurs before updating states. */ \
	RESET_CNT_IF_RST_TRUE(rst, D_TYPE) \
\
	CLEAR_HIT_OUT(hit_port)  /* Set all hit_out states to 0 */ \
\
	for(i=0; i < InputFrameSize; i++) { \
		int_T j; \
		for(j=0; j < OutputFrameSize; j++) { \
			/* If in triggered mode, then we want to update the state   \
			* before outputting the counter value.  However, if we are \
			* in free-running mode, we expect the "initial" count to   \
			* be output in the first step  ... so we must postpone     \
			* the counter-updates until later.                         \
			*/ \
\
			/* PRE_UPDATE_STATE */ \
			if(!FreeRun) UPDATE_CNT_IF_EVENT(S, i, UserDefMax, dir, cnt, maxcount) \
\
			/* OUTPUT_COUNT */ \
			if(cnt_port) cnt_out[j] = *cnt; \
\
			/* OUTPUT_HIT */ \
			/* if(hit_port) hit_out[j] ||= (*cnt == hitval); equiv code */ \
			if(hit_port && (*cnt == hitval)) hit_out[j] = 1; \
\
			/* POST_UPDATE_STATE */ \
			if(FreeRun) UPDATE_CNT_IF_EVENT(S, i, UserDefMax, dir, cnt, maxcount) \
		} \
	} \
}


enum {  DIRECTION_ARGC=0, EVENT_TYPE_ARGC, COUNTER_SIZE_ARGC, 
        MAXCOUNT_ARGC, INITIALCOUNT_ARGC, OUTPORTS_ARGC, 
        HITVALUE_ARGC, RESETINPUT_ARGC, FRAME_BASED_ARGC,
        OUT_FRAME_SIZE_ARGC, SAMPLETIME_ARGC, NUM_PARAMS};

#define DIRECTION_ARG    (ssGetSFcnParam(S,DIRECTION_ARGC))
#define EVENT_TYPE_ARG   (ssGetSFcnParam(S,EVENT_TYPE_ARGC))
#define COUNTER_SIZE_ARG (ssGetSFcnParam(S,COUNTER_SIZE_ARGC))
#define MAXCOUNT_ARG     (ssGetSFcnParam(S,MAXCOUNT_ARGC))
#define INITIALCOUNT_ARG (ssGetSFcnParam(S,INITIALCOUNT_ARGC))
#define OUTPORTS_ARG     (ssGetSFcnParam(S,OUTPORTS_ARGC))
#define HITVALUE_ARG     (ssGetSFcnParam(S,HITVALUE_ARGC))
#define RESETINPUT_ARG   (ssGetSFcnParam(S,RESETINPUT_ARGC))
#define FRAME_BASED_ARG  (ssGetSFcnParam(S,FRAME_BASED_ARGC))
#define OUT_FRAME_SIZE_ARG  (ssGetSFcnParam(S,OUT_FRAME_SIZE_ARGC))
#define SAMPLETIME_ARG   (ssGetSFcnParam(S,SAMPLETIME_ARGC))

enum {INPORT_CLK=0, INPORT_RST, NUM_INPORTS};
enum {OUTPORT_CNT=0, OUTPORT_HIT, NUM_OUTPORTS};
enum {DIR_UP=1, DIR_DOWN=2};
enum {RISING_EDGE=1, 
      FALLING_EDGE, 
      EITHER_EDGE, 
      NONZERO_SAMPLE, 
      FREE_RUN}; /* must match popup ordering */
enum {CNT_8=1, CNT_16, CNT_32, CNT_USER_DEF};
enum {COUNT_PORT=1, HIT_PORT, COUNT_AND_HIT_PORTS};

/* Keep the count */
enum {DWORK_CNT=0, NUM_DWORK};

/* We use 1 or 2 IWorks depending on input options: */
enum {PREV_CLK_STATE=0, PREV_RST_STATE, NUM_IWORK};

typedef struct {
    BuiltInDTypeId cnt_type;
} SFcnCache;

#ifdef MATLAB_MEX_FILE

#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)
{

    if(!IS_FLINT_IN_RANGE(COUNTER_SIZE_ARG,1,4)) {
        THROW_ERROR(S, "Bits in clock must be 8, 16, 32, or user defined");
    }    

	/* If Counter Size is UserDefine. */
	if( mxGetPr(COUNTER_SIZE_ARG)[0] == CNT_USER_DEF) {
		if(OK_TO_CHECK_VAR(S, MAXCOUNT_ARG)) {
			if(!IS_SCALAR_DOUBLE(MAXCOUNT_ARG)) {
				THROW_ERROR(S, "Maximum Count must be a scalar double.");
			}
		}
	}

    /* Check Sample time if defined and in free_run mode. */
    if(mxGetPr(EVENT_TYPE_ARG)[0] == FREE_RUN) { 

		if(OK_TO_CHECK_VAR(S, OUT_FRAME_SIZE_ARG)) {
			if (!IS_FLINT(OUT_FRAME_SIZE_ARG)) {
				THROW_ERROR(S, "The samples per output frame parameter must be a scalar integer.");
			}
		}
	
		if(OK_TO_CHECK_VAR(S, SAMPLETIME_ARG)) {
			if(!IS_SCALAR_DOUBLE(SAMPLETIME_ARG)) {
				THROW_ERROR(S, "The sample time must be a scalar.");
			}
			
			if(mxGetPr(SAMPLETIME_ARG)[0] <= CONTINUOUS_SAMPLE_TIME) {
				THROW_ERROR(S, "Continuous sample times not permitted.");
			}
		}
	}

	if(!IS_FLINT(DIRECTION_ARG)) {
        THROW_ERROR(S, "Direction argument must be a scalar integer.");
    }
    
    if(!IS_FLINT_IN_RANGE(DIRECTION_ARG,1,2)) {
        THROW_ERROR(S, "Direction must be Up or Down.");
    }
    
    if(!IS_FLINT_IN_RANGE(EVENT_TYPE_ARG,1,5)) {
        THROW_ERROR(S, "Clock Event type must be Rising Edge, Falling Edge, \
        Either Edge, Non-zero. or Free run");
    }
          

    if(OK_TO_CHECK_VAR(S, INITIALCOUNT_ARG)) {

		if(!IS_SCALAR_DOUBLE(INITIALCOUNT_ARG)) {
			THROW_ERROR(S, "Start Count must be a scalar");
		}
		
		/* Check the range of the inital count according to data type */
		{
			const int_T cnt_size = (int_T)(mxGetPr(COUNTER_SIZE_ARG)[0]);
			const real_T init = mxGetPr(INITIALCOUNT_ARG)[0];
			switch(cnt_size)
			{
			case CNT_8:
				if(init != (uint8_T)init) {
					THROW_ERROR(S, "Initial count is out of uint8 range.");
				}
				break;
			case CNT_16:
				if(init != (uint16_T)init) {
					THROW_ERROR(S, "Initial count is out of uint16 range.");
				}
				break;
			case CNT_32:
				if(init != (uint32_T)init) {
					THROW_ERROR(S, "Initial count is out of uint32 range.");
				}
				break;
			case CNT_USER_DEF:
				{
					if(OK_TO_CHECK_VAR(S, MAXCOUNT_ARG)) {
						
						real_T maxcount  = mxGetPr(MAXCOUNT_ARG)[0];
						
						if(init < 0) {
							THROW_ERROR(S, "Initial count must be greater than zero.");
						}
						if(maxcount < 0) {
							THROW_ERROR(S, "Max count must be greater than zero.");
						}
						if(init > maxcount) {
							THROW_ERROR(S, "Initial count must be less than max count");
						}
					}
				}  
			}
		}
	}

    {
        int_T ports = (int_T)mxGetPr(OUTPORTS_ARG)[0];
        
        if ((ports!=COUNT_PORT) && (ports!=HIT_PORT) && (ports!=COUNT_AND_HIT_PORTS)) {
            THROW_ERROR(S, "Output must be count, hit, or count and hit.");
        } 	
        
        if(ports != COUNT_PORT) {
			if(OK_TO_CHECK_VAR(S, HITVALUE_ARG)) {
				if(!IS_FLINT(HITVALUE_ARG)) {
					THROW_ERROR(S, "Hit Value must be a scalar");
				}
			}
        }
    }
    
    if(!IS_FLINT_IN_RANGE(RESETINPUT_ARG,0,1)) {
        THROW_ERROR(S, "Reset check box must be 0 or 1");
    }
    
    if(!IS_FLINT_IN_RANGE(FRAME_BASED_ARG,0,1)) {
        THROW_ERROR(S, "Framebased check box must be 0 or 1");
    }
}
#endif


#ifdef MATLAB_MEX_FILE
static char *MapDTypeIdToString(SimStruct *S, BuiltInDTypeId dtype)
{
	switch(dtype) {
	case SS_UINT8:
		return("SS_UINT8");   /* Note early return. */
		break;
	case SS_UINT16:
		return("SS_UINT16");  /* Note early return. */
		break;
	case SS_UINT32:
		return("SS_UINT32");  /* Note early return. */
		break;
	case SS_DOUBLE:
		return("SS_DOUBLE");  /* Note early return. */
		break;
	}
	ssSetErrorStatus(S, "Unsupported data type encountered");
	return("");
}


static BuiltInDTypeId getDataType(SimStruct *S, int_T cnt_size)
{
    BuiltInDTypeId dtype = SS_DOUBLE;  /* Assume double. */

    switch(cnt_size) {
		case CNT_8:
			dtype = SS_UINT8;
			break;
		case CNT_16:
			dtype = SS_UINT16;
			break;
		case CNT_32:
			dtype = SS_UINT32;
			break;
		case CNT_USER_DEF:
			{
				/* Check range of max value to determine data type */
				if(OK_TO_CHECK_VAR(S, MAXCOUNT_ARG)) {
					const real_T maxcount = mxGetPr(MAXCOUNT_ARG)[0];
					
					if(maxcount <= 255) {                 /* (2^8)-1  */
						dtype = SS_UINT8;
					} else if(maxcount <= 65536) {        /* (2^16)-1 */
						dtype = SS_UINT16;
					} else if(maxcount <= 4294967295UL) { /* (2^32)-1 */
						dtype = SS_UINT32;
					} else {
						dtype = SS_DOUBLE;
					}
				}
			}
			break;
    }

    return(dtype);
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S,  NUM_PARAMS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#endif
    
    /* Parameters which cannot change during simulation: */
    ssSetSFcnParamNotTunable(S,COUNTER_SIZE_ARGC);
    ssSetSFcnParamNotTunable(S,MAXCOUNT_ARGC);
    ssSetSFcnParamNotTunable(S,RESETINPUT_ARGC);
    ssSetSFcnParamNotTunable(S,FRAME_BASED_ARGC);
    ssSetSFcnParamNotTunable(S,OUTPORTS_ARGC);
    ssSetSFcnParamNotTunable(S,EVENT_TYPE_ARGC);
    ssSetSFcnParamNotTunable(S,SAMPLETIME_ARGC);
	ssSetSFcnParamNotTunable(S,OUT_FRAME_SIZE_ARGC);

	/* Direction Not tunable in RTW generated code. */
    if ((ssGetSimMode(S) == SS_SIMMODE_EXTERNAL) || 
        (ssGetSimMode(S) == SS_SIMMODE_RTWGEN)) {    
        
        ssSetSFcnParamNotTunable(S, DIRECTION_ARGC);
    }
	
    /* Tunable Parameters are INITIALCOUNT and HIT_VALUE */
    
    {
        const boolean_T free_run = (boolean_T)(mxGetPr(EVENT_TYPE_ARG)[0] == FREE_RUN);
        const int_T     outports = (int_T)(mxGetPr(OUTPORTS_ARG)[0]);
        const boolean_T cnt_port = (boolean_T)((outports != HIT_PORT) ? 1 : 0);
        const boolean_T hit_port = (boolean_T)((outports != COUNT_PORT) ? 1 : 0);
              real_T    Ts;

		/* Only get sampletime arg if edit box variable is defined
		 * and if block is in free_run mode.
		 */
		if ( OK_TO_CHECK_VAR(S, SAMPLETIME_ARG) && (free_run) ) { 
			Ts = mxGetPr(SAMPLETIME_ARG)[0];
		} else {
			Ts = INHERITED_SAMPLE_TIME;
		}


        ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);           
        
        /* Inputs - Clock Event is always an input. */
        {
            const boolean_T rst      = (boolean_T)(mxGetPr(RESETINPUT_ARG)[0] != 0.0);            
            const int_T numInports   = free_run ? (rst ? 1 : 0) : (rst ? 2 : 1);
        
            if (!ssSetNumInputPorts(S, numInports)) return;
            
            if (!free_run) {
                ssSetInputPortWidth(            S, INPORT_CLK, DYNAMICALLY_SIZED);
                ssSetInputPortDirectFeedThrough(S, INPORT_CLK, 1);
                ssSetInputPortComplexSignal(    S, INPORT_CLK, COMPLEX_NO);
                ssSetInputPortReusable(         S, INPORT_CLK, 1);
                ssSetInputPortOverWritable(     S, INPORT_CLK, 0);  
                ssSetInputPortSampleTime(       S, INPORT_CLK, INHERITED_SAMPLE_TIME);
                
                /* Reset port is ALWAYS a scalar.
                * -> Cannot reset channels independently in frame-based mode
                */
            }
            if(rst) {
                int_T const reset_port = free_run ? INPORT_RST-1 : INPORT_RST;
                ssSetInputPortWidth(            S, reset_port, 1);
                ssSetInputPortDirectFeedThrough(S, reset_port, 1);
                ssSetInputPortComplexSignal(    S, reset_port, COMPLEX_NO);
                ssSetInputPortReusable(         S, reset_port, 1);
                ssSetInputPortOverWritable(     S, reset_port, 0);
                ssSetInputPortSampleTime(       S, reset_port, INHERITED_SAMPLE_TIME);
            }
            
            /* We remove the IWork associated with the RST port if it is not used */
            ssSetNumIWork(S, (rst) ? NUM_IWORK : NUM_IWORK-1);
        }
        
        /* Outputs: */
        {
            const int_T numOutports = (cnt_port && hit_port) ? 2 : 1;
			      int_T outWidth    = 1;   /* Assume width = 1 */

   			if(free_run && OK_TO_CHECK_VAR(S, OUT_FRAME_SIZE_ARG)) {
				outWidth = (int_T)mxGetPr(OUT_FRAME_SIZE_ARG)[0];
			}

            if (!ssSetNumOutputPorts(S, numOutports)) return;
            
            ssSetOutputPortWidth(        S, OUTPORT_CNT, outWidth);
            ssSetOutputPortComplexSignal(S, OUTPORT_CNT, COMPLEX_NO);
            ssSetOutputPortSampleTime(   S, OUTPORT_CNT, Ts);
            /*
             * We rely on the fact that the output persists indefinitely between mdlOutput calls,
             * in the case where no trigger events occur.  Therefore, indicate that no blocks
             * attached to the output can overwrite the output signals.
             */
            ssSetOutputPortReusable(S, OUTPORT_CNT, 0);
            
            if (numOutports>1) {
                ssSetOutputPortWidth(        S, OUTPORT_HIT, outWidth);
                ssSetOutputPortComplexSignal(S, OUTPORT_HIT, COMPLEX_NO);
                ssSetOutputPortReusable(     S, OUTPORT_HIT, 0);
                ssSetOutputPortSampleTime(   S, OUTPORT_HIT, Ts);
            }
        }
		
		/* Set up DWORK_CNT data type based on COUNTER_SIZE parameter 
		 * or based on maxval if size is user defined.
		 */
		{
			const int_T cnt_size = (int_T)(mxGetPr(COUNTER_SIZE_ARG)[0]);
			
			if(!ssSetNumDWork(      S, NUM_DWORK)) return;
			
			ssSetDWorkWidth(        S, DWORK_CNT, 1);
			ssSetDWorkComplexSignal(S, DWORK_CNT, COMPLEX_NO);
			ssSetDWorkDataType(     S, DWORK_CNT, getDataType(S, cnt_size));
			ssSetDWorkName(         S, DWORK_CNT, "Count");
			ssSetDWorkUsedAsDState( S, DWORK_CNT, 1);			
		}
	}
	
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_USE_TLC_WITH_ACCELERATOR |
                 SS_OPTION_CALL_TERMINATE_ON_EXIT);
}


/* Set all ports to identical, discrete rates: */
#include "dsp_ctrl_ts.c"


#define MDL_START
static void mdlStart (SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    CallocSFcnCache(S, SFcnCache);
    
    /* Cache data type for later reference. */
    {
        SFcnCache *cache = ssGetUserData(S);
	const int_T cnt_size = (int_T)(mxGetPr(COUNTER_SIZE_ARG)[0]);
	cache->cnt_type = (BuiltInDTypeId)(getDataType(S, cnt_size));
    }
#endif
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{

	/* Set cnt to initial value with selected data type: */    
	{
		const SFcnCache     *cache    = ssGetUserData(S);
		const BuiltInDTypeId cnt_type = cache->cnt_type;
		const real_T         init_cnt = mxGetPr(INITIALCOUNT_ARG)[0];

		switch(cnt_type) {
			case SS_UINT8:
				*((uint8_T  *)ssGetDWork(S, DWORK_CNT)) = (uint8_T)init_cnt;
				break;
			case SS_UINT16:
				*((uint16_T *)ssGetDWork(S, DWORK_CNT)) = (uint16_T)init_cnt;
				break;
			case SS_UINT32:
				*((uint32_T *)ssGetDWork(S, DWORK_CNT)) = (uint32_T)init_cnt;
				break;
			case SS_DOUBLE:
				*((real_T *)ssGetDWork(S, DWORK_CNT)) = init_cnt;
				break;
		}
	}

	/* Initialize input trigger states: */
	{
		const int_T event_type = (int_T)mxGetPr(EVENT_TYPE_ARG)[0];
		if (event_type == RISING_EDGE || event_type == FALLING_EDGE || event_type == EITHER_EDGE ) {
			ssSetIWorkValue(S, PREV_CLK_STATE, UNINITIALIZED_ZCSIG);
		}
	}

	{
		const boolean_T rst = (boolean_T)(mxGetPr(RESETINPUT_ARG)[0] != 0.0);
		if (rst) {
			ssSetIWorkValue(S, PREV_RST_STATE,  UNINITIALIZED_ZCSIG);
		}
	}
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
	const int_T          event_type = (int_T)mxGetPr(EVENT_TYPE_ARG)[0];
	const boolean_T      EdgeTrig   = (boolean_T)(event_type == RISING_EDGE || \
                                          event_type == FALLING_EDGE || event_type == EITHER_EDGE );
    const boolean_T      FreeRun    = (boolean_T)(event_type == FREE_RUN);
	const boolean_T      UserDefMax = (boolean_T)(mxGetPr(COUNTER_SIZE_ARG)[0]==CNT_USER_DEF);

	const SFcnCache     *cache      = (SFcnCache *)ssGetUserData(S);
	const BuiltInDTypeId cnt_size   = cache->cnt_type;

	const int_T          outports   = (int_T)(mxGetPr(OUTPORTS_ARG)[0]);
	const boolean_T      cnt_port   = (boolean_T)(outports != HIT_PORT);
	const boolean_T      hit_port   = (boolean_T)(outports != COUNT_PORT);
	const boolean_T      rst_port   = (boolean_T)(mxGetPr(RESETINPUT_ARG)[0] == 1.0);
	const int_T          dir        = (int_T)(mxGetPr(DIRECTION_ARG)[0]);

	const real_T         hitval     = (hit_port) ? mxGetPr(HITVALUE_ARG)[0] : -1;   /* xxx */

        const int_T     InputFrameSize  = FreeRun ? 1 : ssGetInputPortWidth(S, INPORT_CLK);
	const int_T     OutputFrameSize = FreeRun ? (int_T)mxGetPr(OUT_FRAME_SIZE_ARG)[0] : 1;
	
	boolean_T            rst        = (boolean_T)0;  /* Assume no reset. */
	InputRealPtrsType    in_clk     = FreeRun ? NULL : ssGetInputPortRealSignalPtrs(S, INPORT_CLK);
	ZCDirection          zc_dir;

	
	/* Determine the triggering direction, if appropriate: */
	if (EdgeTrig) {
		zc_dir = (event_type == RISING_EDGE)
			? RISING_ZERO_CROSSING
			: (event_type == FALLING_EDGE) ? FALLING_ZERO_CROSSING
			: ANY_ZERO_CROSSING;        
	}

	/* Determine state of reset port, if appropriate: */
	if (rst_port) {
		const int_T port = FreeRun ? INPORT_RST-1 : INPORT_RST;
		if(EdgeTrig) {
			InputRealPtrsType in_rst = ssGetInputPortRealSignalPtrs(S, port);
			rst = (boolean_T)(rt_ZCFcn(zc_dir, (ZCSigState *)(ssGetIWork(S) + PREV_RST_STATE), **in_rst)
				!= NO_ZCEVENT);
		} else {
			/* NonZero trigger mode.  Note that while the clock is 
			 * in FreeRun mode that reset can only be triggered by 
			 * non-zero inputs to the reset port. */
			InputRealPtrsType in_rst = ssGetInputPortRealSignalPtrs(S, port);
			rst = (boolean_T)(**in_rst != 0.0);
		}
	}	
	
	/* The data type of the stored count value will differ based
	 * the range of the count chosen in the popup menu of the mask.  
	 * If UserDefined count size is chosen, the data type will be
	 * selected based on the range of the max count set in the dialog
	 */
	switch(cnt_size) {

        case SS_UINT8:
		UPDATE_CNT_AND_OUTPUTS(uint8_T, cnt_port, hit_port, UserDefMax, dir)
		break;
		
        case SS_UINT16:
		UPDATE_CNT_AND_OUTPUTS(uint16_T, cnt_port, hit_port, UserDefMax, dir)
		break;
		
        case SS_UINT32:
		UPDATE_CNT_AND_OUTPUTS(uint32_T, cnt_port, hit_port, UserDefMax, dir)
		break;
		
        case SS_DOUBLE:
		UPDATE_CNT_AND_OUTPUTS(real_T, cnt_port, hit_port, UserDefMax, dir)
		break;
	}
}


static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    FreeSFcnCache(S, SFcnCache);
#endif
}


#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    /*
     * Write out the parameters which do not change during execution:
     *    Count Type
     */
    const real_T     Direction  = mxGetPr(DIRECTION_ARG)[0];
    const real_T    *InitCount  = mxGetPr(INITIALCOUNT_ARG);
    const SFcnCache *cache      = (SFcnCache *)ssGetUserData(S);
    const char      *CountSize  = MapDTypeIdToString(S, cache->cnt_type);
    const real_T     MaxCount   = mxGetPr(MAXCOUNT_ARG)[0];
    const real_T     Outports   = mxGetPr(OUTPORTS_ARG)[0];
    const real_T     CountEvent = mxGetPr(EVENT_TYPE_ARG)[0];
    const boolean_T  free_run   = (boolean_T)(mxGetPr(EVENT_TYPE_ARG)[0] == FREE_RUN);
	const real_T     OutputFrameSize  = free_run ? mxGetPr(OUT_FRAME_SIZE_ARG)[0] : 1.0;

    /* On/Off parameter values */
    const real_T     CntPort    = (Outports != HIT_PORT);
    const real_T     HitPort    = (Outports != COUNT_PORT);
    const real_T     RstPort    = mxGetPr(RESETINPUT_ARG)[0];
    const real_T     Framebased = mxGetPr(FRAME_BASED_ARG)[0];
    const real_T     UserDefMax = (mxGetPr(COUNTER_SIZE_ARG)[0]==CNT_USER_DEF);

    const real_T     *HitValue    = mxGetPr(HITVALUE_ARG);
	const int_T       HitValueLen = mxGetNumberOfElements(HITVALUE_ARG);

    char *CntPortStr    = CntPort    ? "yes" : "no";
    char *HitPortStr    = HitPort    ? "yes" : "no";
    char *RstPortStr    = RstPort    ? "yes" : "no";
    char *FramebasedStr = Framebased ? "yes" : "no";
    char *UserDefMaxStr = UserDefMax ? "yes" : "no";

    real_T SampleTime;

    if (ssGetErrorStatus(S) != NULL) return;  /* In case MapDTypeIdToString() failed */

    /* Only get sampletime arg if edit box variable is defined
     * and if block is in free_run mode.
     */
    if ( OK_TO_CHECK_VAR(S, SAMPLETIME_ARG) && (free_run) ) { 
        SampleTime = mxGetPr(SAMPLETIME_ARG)[0];
    } else {
        SampleTime = INHERITED_SAMPLE_TIME;
    }
    
    /* Non-tunable parameters */
    if (!ssWriteRTWParamSettings(S, 11,
        
        SSWRITE_VALUE_NUM, "Direction", Direction,        
        
        SSWRITE_VALUE_QSTR, "CountSize",  CountSize,
        
        SSWRITE_VALUE_NUM, "MaxCount",   MaxCount,
        
        SSWRITE_VALUE_QSTR, "CntPort",    CntPortStr,
        
        SSWRITE_VALUE_QSTR, "HitPort",    HitPortStr,
        
        SSWRITE_VALUE_QSTR, "RstPort",    RstPortStr,
        
        SSWRITE_VALUE_QSTR, "FrameBased", FramebasedStr,
        
        SSWRITE_VALUE_QSTR, "UserDefMax", UserDefMaxStr,
        
        SSWRITE_VALUE_NUM, "CountEvent", CountEvent,

        SSWRITE_VALUE_NUM, "OutputFrameSize",  OutputFrameSize,
        
        SSWRITE_VALUE_NUM, "SampleTime", SampleTime)) {
        return;
    }
    
    /* We must write out the tunable parameters here
    * because RTW external mode needs access to them.
    */
	if (!ssWriteRTWParameters(S, 2,                                 
		
		SSWRITE_VALUE_VECT, "InitialCount",
		"Counter initial count", InitCount,  1,
		
		SSWRITE_VALUE_VECT, "HitValue",
		"Counter hit-value",  HitValue,   HitValueLen)) {
		return;
	}  
}

#endif


#ifdef MATLAB_MEX_FILE
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
{
    /* Channel-based mode: width must be 1.
     * Frame-based: width can be anything
     */
    const boolean_T frame_based = (boolean_T)(mxGetPr(FRAME_BASED_ARG)[0]==1);
    const int_T     outports    = (int_T)(mxGetPr(OUTPORTS_ARG)[0]);
    const boolean_T free_run    = (boolean_T)(mxGetPr(EVENT_TYPE_ARG)[0] == FREE_RUN);
    const int_T     reset_port  = free_run ? INPORT_RST-1 : INPORT_RST;

    ssSetInputPortWidth (S, port, inputPortWidth);
    
    if (free_run) {
        THROW_ERROR(S,"Port width error. There is no clock input for free running mode.");
    }

    if (!frame_based && (inputPortWidth != 1)) {
        THROW_ERROR(S, "Clk input must be a scalar in non-frame based mode.");
    }
    if( (port==reset_port) && (inputPortWidth != 1) ) {
        THROW_ERROR(S, "Reset input must be a scalar.");
    }		
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
{
	/* We should never get to this code. */

    ssSetOutputPortWidth (S, port, outputPortWidth);

	THROW_ERROR(S, "Output is not dynamically sized.");
}
#endif


#ifdef	MATLAB_MEX_FILE  
#include "simulink.c"    
#else
#include "cg_sfun.h"     
#endif

/* [EOF] sdspcount.c */
