/*
 * SDSPSTACK DSP Blockset stack block (LIFO register)
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.19.4.1 $  $Date: 2004/01/25 22:39:41 $
 */

#define S_FUNCTION_NAME sdspstack
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

/* Define stack arguments: */
enum {TRIGTYPE_ARGC=0, DEPTH_ARGC, PUSHFULL_ARGC, PES_ARGC,
      ESO_ARGC, FSO_ARGC, NSO_ARGC, CLRI_ARGC, CLRONRST_ARGC, NUM_PARAMS};

#define TRIGTYPE_ARG (ssGetSFcnParam(S,TRIGTYPE_ARGC))
#define DEPTH_ARG    (ssGetSFcnParam(S,DEPTH_ARGC))
#define PUSHFULL_ARG (ssGetSFcnParam(S,PUSHFULL_ARGC))
#define PES_ARG      (ssGetSFcnParam(S,PES_ARGC))
#define ESO_ARG      (ssGetSFcnParam(S,ESO_ARGC))
#define FSO_ARG      (ssGetSFcnParam(S,FSO_ARGC))
#define NSO_ARG      (ssGetSFcnParam(S,NSO_ARGC))
#define CLRI_ARG     (ssGetSFcnParam(S,CLRI_ARGC))
#define CLRONRST_ARG (ssGetSFcnParam(S,CLRONRST_ARGC))

enum {DWORK_STACK=0, MAX_NUM_DWORKS};
enum {DATAIN_PORT=0, PUSH_PORT, POP_PORT, CLR_PORT, NUM_INPORTS};
enum {DATAOUT_PORT=0, SO1_PORT, SO2_PORT, SO3_PORT, NUM_OUTPORTS};

/* Only 4 IWork's are required unless the CLR port is enabled */
enum {TOP_IDX=0, STACK_DEPTH, PREV_PUSH_STATE, PREV_POP_STATE, PREV_CLR_STATE, NUM_IWORK};
enum {STK_PTR_IDX=0, NUM_PWORK};

typedef enum {PES_IGNORE=1, PES_WARNING, PES_ERROR} PopEmptyMode;
typedef enum {PFS_DYNAMIC=1, PFS_IGNORE, PFS_WARNING, PFS_ERROR} PushFullMode;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    
    if(!IS_FLINT_IN_RANGE(TRIGTYPE_ARG,1,3)) {
        THROW_ERROR(S,"Trigger type must be 1=rising, 2=falling, or 3=either");
    }    
    if(!IS_FLINT_IN_RANGE(PUSHFULL_ARG,1,4)) {
        THROW_ERROR(S, "Overflow argument must be 1-4");
    }    
    if(!IS_FLINT_GE(DEPTH_ARG,1)) {
        THROW_ERROR(S, "Stack depth must be an integer > 0");
    }    
    if(!IS_FLINT_IN_RANGE(PES_ARG,1,3)) {
        THROW_ERROR(S, "Pop empty stack mode must be 1=IGNORE, 2=WARNING, or 3=ERROR");
    }    
    if(!IS_FLINT_IN_RANGE(ESO_ARG,0,1)) {
        THROW_ERROR(S, "Empty stack output mode must be 0 or 1");
    }    
    if(!IS_FLINT_IN_RANGE(FSO_ARG,0,1)) {
         THROW_ERROR(S, "Full stack output mode must be 0 or 1");
    }
    if(!IS_FLINT_IN_RANGE(NSO_ARG,0,1)) {
        THROW_ERROR(S, "Number of stack entries output mode must be 0 or 1");
    }
    if(!IS_FLINT_IN_RANGE(CLRI_ARG,0,1)) {
        THROW_ERROR(S, "Clear input mode must be 0 or 1");
    }
    if(!IS_FLINT_IN_RANGE(CLRONRST_ARG,0,1)) {
        THROW_ERROR(S, "Clear on Reset mode must be 0 or 1");
    }
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

        
    ssSetSFcnParamNotTunable(S, DEPTH_ARGC);
    ssSetSFcnParamNotTunable(S, PUSHFULL_ARGC);
    ssSetSFcnParamNotTunable(S, ESO_ARGC);   /* empty-stack output       */
    ssSetSFcnParamNotTunable(S, FSO_ARGC);   /* full-stack output        */
    ssSetSFcnParamNotTunable(S, NSO_ARGC);   /* num stack entries output */
    ssSetSFcnParamNotTunable(S, CLRI_ARGC);  /* clear stack input        */
    
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);


    /* Inputs: There's at least 3, but there might be a 4th... */
    {
        const boolean_T clr = (boolean_T)(mxGetPr(CLRI_ARG)[0] != 0.0);
        const int_T num_inp = (clr == 0) ? 3 : 4;
        
        if (!ssSetNumInputPorts(S, num_inp)) return;

        ssSetInputPortWidth(            S, DATAIN_PORT, DYNAMICALLY_SIZED);
        ssSetInputPortDirectFeedThrough(S, DATAIN_PORT, 1);
        ssSetInputPortComplexSignal(    S, DATAIN_PORT, COMPLEX_INHERITED);
        ssSetInputPortSampleTime(       S, DATAIN_PORT, INHERITED_SAMPLE_TIME);

        ssSetInputPortWidth(            S, PUSH_PORT, 1);
        ssSetInputPortDirectFeedThrough(S, PUSH_PORT,   1);
        ssSetInputPortComplexSignal(    S, PUSH_PORT, COMPLEX_NO);
        ssSetInputPortSampleTime(       S, PUSH_PORT, INHERITED_SAMPLE_TIME);
        
        ssSetInputPortWidth(            S, POP_PORT,  1);
        ssSetInputPortDirectFeedThrough(S, POP_PORT,    1);
        ssSetInputPortComplexSignal(    S, POP_PORT, COMPLEX_NO);
        ssSetInputPortSampleTime(       S, POP_PORT, INHERITED_SAMPLE_TIME);

        if (num_inp > 3) {
            ssSetInputPortWidth(            S, CLR_PORT, 1);
            ssSetInputPortDirectFeedThrough(S, CLR_PORT, 1);
            ssSetInputPortComplexSignal(    S, CLR_PORT, COMPLEX_NO);
            ssSetInputPortSampleTime(       S, CLR_PORT, INHERITED_SAMPLE_TIME);
        }

        /* We remove the IWork associated with the CLR port if it is not used */
        ssSetNumIWork(S, clr ? NUM_IWORK : NUM_IWORK-1);
    }

    /* Outputs: */
    {
        const boolean_T eso = (boolean_T)(mxGetPr(ESO_ARG)[0] != 0.0);
        const boolean_T fso = (boolean_T)(mxGetPr(FSO_ARG)[0] != 0.0);
        const boolean_T nso = (boolean_T)(mxGetPr(NSO_ARG)[0] != 0.0);
        
        /* Determine number of output ports: */
        int_T num_outp = 1;
        if (eso) num_outp++;
        if (fso) num_outp++;
        if (nso) num_outp++;
        
        if (!ssSetNumOutputPorts(S, num_outp)) return;
        
        ssSetOutputPortWidth(        S, DATAOUT_PORT, DYNAMICALLY_SIZED);
        ssSetOutputPortComplexSignal(S, DATAOUT_PORT, COMPLEX_INHERITED);
        ssSetOutputPortSampleTime(   S, DATAOUT_PORT, INHERITED_SAMPLE_TIME);
        
        if (num_outp > 1) {
            ssSetOutputPortWidth(        S, SO1_PORT, 1);
            ssSetOutputPortComplexSignal(S, SO1_PORT, COMPLEX_NO);
            ssSetOutputPortSampleTime(   S, SO1_PORT, INHERITED_SAMPLE_TIME);

            if (num_outp > 2) {
                ssSetOutputPortWidth(        S, SO2_PORT, 1);
                ssSetOutputPortComplexSignal(S, SO2_PORT, COMPLEX_NO);
                ssSetOutputPortSampleTime(   S, SO2_PORT, INHERITED_SAMPLE_TIME);

                if (num_outp > 3) {
                    ssSetOutputPortWidth(        S, SO3_PORT, 1);
                    ssSetOutputPortComplexSignal(S, SO3_PORT, COMPLEX_NO);
                    ssSetOutputPortSampleTime(   S, SO3_PORT, INHERITED_SAMPLE_TIME);
                }
            }
        }
    }

    if(!ssSetNumDWork(  S, DYNAMICALLY_SIZED)) return;
   
    ssSetNumPWork(      S, DYNAMICALLY_SIZED);
    ssSetOptions(       S, SS_OPTION_EXCEPTION_FREE_CODE );
}


/* Set all ports to the identical, discrete rates: */
#include "dsp_ctrl_ts.c"

#define MDL_START
static void mdlStart(SimStruct *S)
{
    const int_T depth = (int_T)(mxGetPr(DEPTH_ARG)[0]);

    /* Set the initial stack depth.
     * Note: We only can do this once, since depth might change if
     *       the 'reallocate on full stack' option has been selected.
     *       The user's value would no longer be correct during an
     *       enabled subsystem re-intialization call.
     */
    ssSetIWorkValue(S, STACK_DEPTH, depth);

    /* If PushFullMode is PFS_DYNAMIC, we need to allocate a dynamic buffer */
    {
        const PushFullMode pfm = (PushFullMode)((int_T)mxGetPr(PUSHFULL_ARG)[0]);
        if (pfm == PFS_DYNAMIC) {
            const int_T     numEle    = ssGetInputPortWidth(S, DATAIN_PORT);
            const boolean_T cplx      = (boolean_T)(ssGetInputPortComplexSignal(S, DATAIN_PORT) == COMPLEX_YES);
            const int_T     allocSize = numEle * depth * (cplx ? sizeof(creal_T) : sizeof(real_T));
            void           *stack     = (void *)malloc(allocSize);

            ssSetPWorkValue(S, STK_PTR_IDX, stack);
            if (stack == NULL) {
                THROW_ERROR(S, "Failed to allocate stack");
            }
        }
    }
}


#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)
{
    const boolean_T clri  = (boolean_T)(mxGetPr(CLRI_ARG)[0] != 0.0);
    const boolean_T eso   = (boolean_T)(mxGetPr(ESO_ARG)[0] != 0.0);
    const boolean_T cor   = (boolean_T)(mxGetPr(CLRONRST_ARG)[0] != 0.0);

    /* Initialize stack to empty state: */
    ssSetIWorkValue(S, TOP_IDX, 0);

    /* Initialize input trigger states: */
    ssSetIWorkValue(S, PREV_PUSH_STATE, UNINITIALIZED_ZCSIG);
    ssSetIWorkValue(S, PREV_POP_STATE,  UNINITIALIZED_ZCSIG);
    if (clri) {
        ssSetIWorkValue(S, PREV_CLR_STATE,  UNINITIALIZED_ZCSIG);
    }
    
    if (eso) {
        /* empty stack output */
        real_T *esoOut = ssGetOutputPortRealSignal(S, SO1_PORT);
        *esoOut = 1.0;
    }

    /* Reset output port data if ClearOnReset selected */
    if (cor) {
        const boolean_T cplx = (boolean_T)(ssGetOutputPortComplexSignal(S, DATAOUT_PORT) == COMPLEX_YES);
        int_T           N    = ssGetOutputPortWidth(S,DATAOUT_PORT);

        if (!cplx) {
           real_T *dataOut = ssGetOutputPortRealSignal(S,DATAOUT_PORT);
           while(N-- > 0) {
               *dataOut++ = 0.0;
           }

        } else {
           creal_T *dataOut = (creal_T *)ssGetOutputPortSignal(S,DATAOUT_PORT);
           while(N-- > 0) {
               dataOut->re     = 0.0;
               (dataOut++)->im = 0.0;

           }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T clri = (boolean_T)(mxGetPr(CLRI_ARG)[0] != 0.0);
    ZCEventType     push, pop; 
	ZCEventType 	clr = NO_ZCEVENT;
    
    {
        /* Determine triggering operation: */
        int_T       mask_dir = (int_T)mxGetPr(TRIGTYPE_ARG)[0];
        ZCDirection zc_dir   = (mask_dir==1) ? RISING_ZERO_CROSSING :
                               (mask_dir==2) ? FALLING_ZERO_CROSSING : ANY_ZERO_CROSSING;
        
        /* Push event */
        InputRealPtrsType trig_in = ssGetInputPortRealSignalPtrs(S, PUSH_PORT);
        push = rt_ZCFcn(zc_dir, (ZCSigState *)(ssGetIWork(S) + PREV_PUSH_STATE), **trig_in);
        
        /* Pop event */
        trig_in = ssGetInputPortRealSignalPtrs(S, POP_PORT);
        pop = rt_ZCFcn(zc_dir, (ZCSigState *)(ssGetIWork(S) + PREV_POP_STATE), **trig_in);
        
        /* Clr event */
        if (clri) {
            trig_in = ssGetInputPortRealSignalPtrs(S, CLR_PORT);
            clr = rt_ZCFcn(zc_dir, (ZCSigState *)(ssGetIWork(S) + PREV_CLR_STATE), **trig_in);
        }
        
        if (!(push || pop || (clri && clr))) return;
    }
    
    {
        const boolean_T    cplx = (boolean_T)(ssGetInputPortComplexSignal(S, DATAIN_PORT) == COMPLEX_YES);
        const PushFullMode pfm  = (PushFullMode)((int_T)mxGetPr(PUSHFULL_ARG)[0]);
        const PopEmptyMode pes  = (PopEmptyMode)((int_T)mxGetPr(PES_ARG)[0]);
        const boolean_T    eso  = (boolean_T)(mxGetPr(ESO_ARG)[0] != 0.0);
        const boolean_T    fso  = (boolean_T)(mxGetPr(FSO_ARG)[0] != 0.0);
        const boolean_T    nso  = (boolean_T)(mxGetPr(NSO_ARG)[0] != 0.0);
        const int_T        N    = ssGetInputPortWidth(S,DATAIN_PORT);
        
        int_T         depth    = ssGetIWorkValue(S, STACK_DEPTH);
        int_T        *top_idx  = ssGetIWork(S) + TOP_IDX;
        
        if (clri && clr) {
            /* Clear the stack */
            
#ifdef SHRINK_STACK_REALLOC
            /* Shrink allocation if it exceeds base size: */
            if (pfm == PFS_DYNAMIC) {
                const int_T init_depth = (int_T)(mxGetPr(DEPTH_ARG)[0]);
                if (depth > init_depth) {
                    /* Free current stack */
                    const int_T allocSize = init_depth * N * (cplx ? sizeof(creal_T) : sizeof(real_T));
                    void *stk = (void *)ssGetPWorkValue(S, STK_PTR_IDX);
                    
                    stk = (void *)realloc(stk, allocSize);
                    ssSetPWorkValue(S, STK_PTR_IDX, stk);
                    if (stk == NULL) {
                        THROW_ERROR(S, "Failed to shrink stack");
                    }
                    /* Update the new stack depth */
                    depth = init_depth;
                    ssSetIWorkValue(S, STACK_DEPTH, depth);
                }
            }
#endif
            /* Reset stack pointer: */
            ssSetIWorkValue(S, TOP_IDX, 0);

            /* Reset output port data if ResetOnClear selected */
            {
                const boolean_T cor = (boolean_T)(mxGetPr(CLRONRST_ARG)[0] != 0.0);
                if (cor) {
                    const boolean_T cplx = (boolean_T)(ssGetOutputPortComplexSignal(S, DATAIN_PORT) == COMPLEX_YES);
                    int_T           N    = ssGetOutputPortWidth(S,DATAIN_PORT);
                    if (!cplx) {
                       real_T *dataOut = ssGetOutputPortRealSignal(S,DATAOUT_PORT);
                       while(N-- > 0) {
                           *dataOut++ = 0.0;
                       }
                    } else {
                       creal_T *dataOut = (creal_T *)ssGetOutputPortSignal(S,DATAOUT_PORT);
                       while(N-- > 0) {
                           dataOut->re     = 0.0;
                           (dataOut++)->im = 0.0;
                       }
                    }
                }
            }
            
            /* Update optional output ports */
            {
                real_T *outp;
                
                if (eso) {
                    /* stack is now empty */
                    outp  = ssGetOutputPortRealSignal(S,SO1_PORT);
                    *outp = 1.0;
                }
                if (fso  && (pfm != PFS_DYNAMIC)) {
                    /* stack is not full
                     * NOTE: you can never have a "full" stack if dynamic stack is selected
                     */
                    int_T   fso_port = eso ? SO2_PORT : SO1_PORT;
                    outp  = ssGetOutputPortRealSignal(S, fso_port);
                    *outp = 0.0;
                }
                if (nso) {
                    /* Num stack entries: */
                    int_T nso_port;
                    if (eso && fso) {
                        nso_port = SO3_PORT;
                    } else if (eso || fso) {
                        nso_port = SO2_PORT;
                    } else {
                        nso_port = SO1_PORT;
                    }
                    outp  = ssGetOutputPortRealSignal(S, nso_port);
                    *outp = 0.0;
                }
            }
        }
        
        if (push) {
            if (*top_idx == depth) {
                /* Attempt to fill stack beyond current depth */
                
                if (pfm == PFS_DYNAMIC) {
                    /* Extend allocation dynamically:
                     *
                     * - allocate new buffer, length=2*depth
                     * - check for NULL
                     * - copy depth entries from orig to new
                     * - new depth = 2*orig depth
                     * - record new alloc ptr
                     * - free orig alloc
                     */
                    const int_T oldAllocSize = depth * N * (cplx ? sizeof(creal_T) : sizeof(real_T));
                    const int_T newAllocSize = 2 * oldAllocSize;

                    char_T     *orig_stack   = (char_T *)ssGetPWorkValue(S, STK_PTR_IDX);
                    char_T     *new_stack    = (char_T *)malloc(newAllocSize);
                    
                    if (new_stack == NULL) {
                        THROW_ERROR(S, "Failed to reallocate stack");
                    }

                    memcpy(new_stack, orig_stack, oldAllocSize);

                    depth *= 2; /* update depth value */
                    ssSetIWorkValue(S, STACK_DEPTH, depth);
                    ssSetPWorkValue(S, STK_PTR_IDX, new_stack);
                    free(orig_stack);
                     
                    /* Continue on to the push operation */
                    
                } else {
                    /* Non-extending allocation: */
#ifdef MATLAB_MEX_FILE
                    static char msg[] = "Attempt to push full stack";
                    if (pfm == PFS_WARNING) {
                        mexWarnMsgTxt(msg);
                    } else if (pfm == PFS_ERROR) {
                        ssSetErrorStatus(S, msg);
                    }
#endif
                    return;
                }
            } /* if (*top_idx == depth) */
            
            /* copy input elements into stack: */
            {
                if (cplx) {
                    /* Complex data */

                    InputPtrsType dataIn = ssGetInputPortSignalPtrs(S, DATAIN_PORT);
                    creal_T *stk;

                    /* Point to start of stack allocation: */
                    if (pfm == PFS_DYNAMIC) {
                        /* Dynamic stack: */
                        stk = (creal_T *)ssGetPWorkValue(S, STK_PTR_IDX);
                    } else {
                        /* Fixed stack: */
                        stk = (creal_T *)ssGetDWork(S, DWORK_STACK);
                    }
                
                    /* Point to next available entry in stack: */
                    stk += *top_idx * N;
                
                    /* Copy input to stack: */
                    {
                        int_T i = N;
                        while(i-- > 0) {
                            *stk++ = *((creal_T *)(*dataIn++));  /* Copy re and im parts */
                        }
                    }
                    

                } else {
                    /* Real data */

                    InputRealPtrsType dataIn = ssGetInputPortRealSignalPtrs(S, DATAIN_PORT);
                    real_T *stk;

                    /* Point to start of stack allocation: */
                    if (pfm == PFS_DYNAMIC) {
                        /* Dynamic stack: */
                        stk = (real_T *)ssGetPWorkValue(S, STK_PTR_IDX);
                    } else {
                        /* Fixed stack: */
                        stk = (real_T *)ssGetDWork(S, DWORK_STACK);
                    }

                    /* Point to next available entry in stack: */
                    stk += *top_idx * N;

                    /* Copy input to stack: */
                    {
                        int_T i = N;
                        while(i-- > 0) {
                            *stk++ = **dataIn++;
                        }
                    }
                }

                /* Bump stack pointer: */
                (*top_idx)++;
                
                if (eso) {
                    /* stack is no longer empty */
                    real_T *esoOut = ssGetOutputPortRealSignal(S,SO1_PORT);
                    *esoOut = 0.0;
                }
                
                if (fso  && (pfm != PFS_DYNAMIC)) {
                    /* full stack output
                     * NOTE: you can never have a "full" stack if dynamic stack is selected
                     * (i.e., "Dynamic" mode)
                     */
                    int_T fso_port = eso ? SO2_PORT : SO1_PORT;
                    real_T *fsoOut = ssGetOutputPortRealSignal(S, fso_port);
                    *fsoOut = (*top_idx == depth);
                }
                
                if (nso) {
                    /* # stack entries has changed */
                    int_T nso_port;
                    real_T *nsoOut;
                    if (eso && fso) {
                        nso_port = SO3_PORT;
                    } else if (eso || fso) {
                        nso_port = SO2_PORT;
                    } else {
                        nso_port = SO1_PORT;
                    }
                    nsoOut = ssGetOutputPortRealSignal(S, nso_port);
                    *nsoOut = *top_idx;
                }
            }
        }
                
        if (pop) {
            if (*top_idx == 0) {
                /* Attempt to pop empty stack */
#ifdef MATLAB_MEX_FILE
                static char msg[] = "Attempt to pop empty stack";
                if (pes == PES_WARNING) {
                    mexWarnMsgTxt(msg);
                } else if (pes == PES_ERROR) {
                    ssSetErrorStatus(S, msg);
                }
#endif
                return;
            }
            
            /* Copy stack contents to output: */
            {
                if (cplx) {
                    creal_T *dataOut = (creal_T *)ssGetOutputPortSignal(S,DATAOUT_PORT);
                    creal_T *stk;
                
                    /* Point to start of stack allocation: */
                    if (pfm == PFS_DYNAMIC) {
                        /* Dynamic stack: */
                        stk = (creal_T *)ssGetPWorkValue(S, STK_PTR_IDX);
                    } else {
                        /* Fixed stack: */
                        stk = (creal_T *)ssGetDWork(S, DWORK_STACK);
                    }
                
                    /* Decrement stack to last filled entry in stack: */
                    (*top_idx)--;
                    stk += *top_idx * N;
                    {
                        int_T i = N;
                        while(i-- > 0) {
                            *dataOut++ = *stk++;  /* Copy re and im parts */
                        }
                    }

                } else {
                    real_T *dataOut = ssGetOutputPortRealSignal(S,DATAOUT_PORT);
                    real_T *stk;
                
                    /* Point to start of stack allocation: */
                    if (pfm == PFS_DYNAMIC) {
                        /* Dynamic stack: */
                        stk = (real_T *)ssGetPWorkValue(S, STK_PTR_IDX);
                    } else {
                        /* Fixed stack: */
                        stk = (real_T *)ssGetDWork(S, DWORK_STACK);
                    }
                
                    /* Decrement stack to last filled entry in stack: */
                    (*top_idx)--;
                    stk += *top_idx * N;
                    {
                        int_T i = N;
                        while(i-- > 0) {
                            *dataOut++ = *stk++;
                        }
                    }
                }
                
                if (eso) {
                    /* empty stack output */
                    real_T *esoOut = ssGetOutputPortRealSignal(S,SO1_PORT);
                    *esoOut = (*top_idx == 0);
                }

                if (fso && (pfm != PFS_DYNAMIC)) {
                    /* stack is no longer full
                     * NOTE: you can never have a "full" stack if dynamic stack is selected
                     */
                    int_T fso_port = eso ? SO2_PORT : SO1_PORT;
                    real_T *fsoOut = ssGetOutputPortRealSignal(S,fso_port);
                    *fsoOut = 0.0;
                }
                
                if (nso) {
                    /* # stack entries has changed */
                    int_T nso_port;
                    real_T *nsoOut;
                    if (eso && fso) {
                        nso_port = SO3_PORT;
                    } else if (eso || fso) {
                        nso_port = SO2_PORT;
                    } else {
                        nso_port = SO1_PORT;
                    }
                    nsoOut = ssGetOutputPortRealSignal(S, nso_port);
                    *nsoOut = *top_idx;
                }
            }
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
    /* If PushFullMode is PFS_DYNAMIC, we need to free allocation */
    const PushFullMode pfm = (PushFullMode)((int_T)mxGetPr(PUSHFULL_ARG)[0]);
    if (pfm == PFS_DYNAMIC) {
        void *stk  = ssGetPWorkValue(S, STK_PTR_IDX);
        if (stk != NULL) {
            free(stk);
        }
    }
}


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                 int_T inputPortWidth)
{
    ssSetInputPortWidth(S,port,inputPortWidth);
    ssSetOutputPortWidth(S,DATAOUT_PORT,inputPortWidth);
}

# define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                  int_T outputPortWidth)
{
    ssSetOutputPortWidth(S,port,outputPortWidth);
    ssSetInputPortWidth(S, DATAIN_PORT, outputPortWidth);
}
#endif


#if defined(MATLAB_MEX_FILE)
#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
    /*
     * Allocate stack space
     * depth * input_width number of elements
     */
    const PushFullMode pfm     = (PushFullMode)((int_T)mxGetPr(PUSHFULL_ARG)[0]);
 
    if (pfm == PFS_DYNAMIC) {
        /* Dynamic allocation - uses malloc/free */
        ssSetNumPWork(S, 1); /* Dynamic allocation */
        if(!ssSetNumDWork(S, 0)) return; /* No preallocation   */
 
    } else {
        /* Fixed allocation - uses DWork */
        
        const int_T     N         = ssGetInputPortWidth(S,DATAIN_PORT);
        const int_T     depth     = (int_T)(mxGetPr(DEPTH_ARG)[0]);
        const int_T     AllocSize = depth * N;
        const CSignal_T stackComplexity = ssGetInputPortComplexSignal(S, DATAIN_PORT);

        ssSetNumPWork(S, 0);  /* No dynamic allocation */

        if(!ssSetNumDWork(      S, MAX_NUM_DWORKS)) return;
        ssSetDWorkWidth(        S, DWORK_STACK, AllocSize);
        ssSetDWorkComplexSignal(S, DWORK_STACK, stackComplexity);
        ssSetDWorkName(         S, DWORK_STACK, "Stack");
        ssSetDWorkUsedAsDState( S, DWORK_STACK, 1);
    }
}
#endif


/* Enable mdlRTW function when the TLC is written */
#if 0

#if defined(MATLAB_MEX_FILE) || defined(NRT)
#define MDL_RTW
static void mdlRTW(SimStruct *S)
{
    const boolean_T emptyOut = (boolean_T)(mxGetPr(ESO_ARG)[0]  != 0);
    const boolean_T fullOut  = (boolean_T)(mxGetPr(FSO_ARG)[0]  != 0);
    const boolean_T numOut   = (boolean_T)(mxGetPr(NSO_ARG)[0]  != 0);
    const boolean_T clearIn  = (boolean_T)(mxGetPr(CLRI_ARG)[0] != 0);
    const int32_T   clrOnrst = (int32_T)(mxGetPr(CLRONRST_ARG)[0] != 0);
    const int32_T   depth    = (int32_T)mxGetPr(DEPTH_ARG)[0];
    const int32_T   trig     = (int32_T)mxGetPr(TRIGTYPE_ARG)[0];
    const int32_T   push     = (int32_T)mxGetPr(PUSHFULL_ARG)[0];
    const int32_T   pop      = (int32_T)mxGetPr(PES_ARG)[0];
    char pushFull[7];
    
    switch(push) {        
    case 1: sprintf(pushFull,"%s","Dynamic"); break;
    case 2: sprintf(pushFull,"%s","Ignore "); break;
    case 3: sprintf(pushFull,"%s","Warning"); break;
    case 4: sprintf(pushFull,"%s","Error  "); break;
    default: THROW_ERROR(S, "Invalid parameter for PushFullStack.");
    }
    
    if (ssGetErrorStatus(S) != NULL) return;  /* In case MapDTypeIdToString() failed */

    /* Non-tunable parameters:
     *  DEPTH_ARGC, PUSHFULL_ARGC, ESO_ARGC, FSO_ARGC, NSO_ARGC, CLRI_ARGC
     */
    if (!ssWriteRTWParamSettings(S, 6,
        
        SSWRITE_VALUE_DTYPE_NUM, "Depth", &depth,
        DTINFO(SS_INT32,COMPLEX_NO),  
        
        SSWRITE_VALUE_STR, "PushFull", pushFull,
        
        SSWRITE_VALUE_DTYPE_NUM, "EmptyOutport", &emptyOut,
        DTINFO(SS_BOOLEAN,COMPLEX_NO),
        
        SSWRITE_VALUE_DTYPE_NUM, "FullOutport", &fullOut,
        DTINFO(SS_BOOLEAN,COMPLEX_NO),
        
        SSWRITE_VALUE_DTYPE_NUM, "NumEntriesOutport", &numOut,
        DTINFO(SS_BOOLEAN,COMPLEX_NO),
        
        SSWRITE_VALUE_DTYPE_NUM, "ClearInport", &clearIn,
        DTINFO(SS_BOOLEAN,COMPLEX_NO) 
        )) {
        
        return;
    }

    /* We must write out the tunable parameters here
     * because RTW external mode needs access to them.
     *
     * TRIGTYPE_ARGC, PES_ARGC, CLRONRST_ARGC
     */

    if (!ssWriteRTWParameters(S, 3,
        
        SSWRITE_VALUE_DTYPE_VECT,"TrigType","",&trig,1,
        DTINFO(SS_INT32,COMPLEX_NO), 

        SSWRITE_VALUE_DTYPE_VECT,"PopEmpty","",&pop,1,
        DTINFO(SS_INT32,COMPLEX_NO), 

        SSWRITE_VALUE_DTYPE_VECT,"ClearOnReset","",&clrOnrst,1,
        DTINFO(SS_INT32,COMPLEX_NO)
        
        )) {
        
        return;
    }
}
#endif
#endif  /* #if 0 */

#include "dsp_cplxhs11.c"

#include "dsp_trailer.c"

/* [EOF] sdspstack.c */
