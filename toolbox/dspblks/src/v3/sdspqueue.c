/*
 * SDSPQUEUE Implements a FIFO register
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.20.4.1 $  $Date: 2004/01/25 22:39:40 $
 */

#define S_FUNCTION_NAME sdspqueue
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
enum {TRIGTYPE_ARGC=0, REG_SIZE_ARGC, PUSHFULL_ARGC, PES_ARGC,
      ESO_ARGC, FSO_ARGC, NSO_ARGC, CLRI_ARGC, CLRONRST_ARGC, NUM_PARAMS};

#define TRIGTYPE_ARG (ssGetSFcnParam(S,TRIGTYPE_ARGC))
#define REG_SIZE_ARG (ssGetSFcnParam(S,REG_SIZE_ARGC))
#define PUSHFULL_ARG (ssGetSFcnParam(S,PUSHFULL_ARGC))
#define PES_ARG      (ssGetSFcnParam(S,PES_ARGC))
#define ESO_ARG      (ssGetSFcnParam(S,ESO_ARGC))
#define FSO_ARG      (ssGetSFcnParam(S,FSO_ARGC))
#define NSO_ARG      (ssGetSFcnParam(S,NSO_ARGC))
#define CLRI_ARG     (ssGetSFcnParam(S,CLRI_ARGC))
#define CLRONRST_ARG (ssGetSFcnParam(S,CLRONRST_ARGC))

enum {DWORK_REGISTER=0, NUM_DWORK};
enum {DATAIN_PORT=0, PUSH_PORT, POP_PORT, CLR_PORT, NUM_INPORTS};
enum {DATAOUT_PORT=0, SO1_PORT, SO2_PORT, SO3_PORT, NUM_OUTPORTS};

/* Only 4 IWork's are required unless the CLR port is enabled */
enum {START_IDX=0, NEXT_IDX, REGISTER_SIZE,
      PREV_PUSH_STATE, PREV_POP_STATE, PREV_CLR_STATE, NUM_IWORK};
enum {REG_PTR_IDX=0, NUM_PWORK};

typedef enum {PES_IGNORE=1, PES_WARNING, PES_ERROR} PopEmptyMode;
typedef enum {PFS_DYNAMIC=1, PFS_IGNORE, PFS_WARNING, PFS_ERROR} PushFullMode;


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    real_T d;
    int_T  i;
    
    if (mxGetNumberOfElements(TRIGTYPE_ARG) != 1) {
        THROW_ERROR(S, "Trigger type must be a scalar")
    }
    d = mxGetPr(TRIGTYPE_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || ((i!=1)&&(i!=2)&&(i!=3))) {
        THROW_ERROR(S, "Trigger type must be 1=rising, 2=falling, or 3=either");
    }
    
    if (mxGetNumberOfElements(PUSHFULL_ARG) != 1) {
        THROW_ERROR(S, "Overflow argument must be a scalar");
    }
    d = mxGetPr(PUSHFULL_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || ((i!=1)&&(i!=2)&&(i!=3)&&(i!=4))) {
        THROW_ERROR(S, "Overflow argument must be 1-4");
    }
    
    if (mxGetNumberOfElements(REG_SIZE_ARG) != 1) {
        THROW_ERROR(S, "Register size argument must be a scalar");
    }
    d = mxGetPr(REG_SIZE_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || (i<1)) {
        THROW_ERROR(S, "Register size must be an integer > 0");
    }
    
    if (mxGetNumberOfElements(PES_ARG) != 1) {
        THROW_ERROR(S, "Pop empty register mode must be a scalar");
    }
    d = mxGetPr(PES_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || ((i!=1)&&(i!=2)&&(i!=3))) {
        THROW_ERROR(S, "Pop empty register mode must be 1=IGNORE, 2=WARNING, or 3=ERROR");
    }
    
    if (mxGetNumberOfElements(ESO_ARG) != 1) {
        THROW_ERROR(S, "Empty register output must be a scalar");
    }
    d = mxGetPr(ESO_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || ((i!=0)&&(i!=1))) {
        THROW_ERROR(S, "Empty register output mode must be 0 or 1");
    }
    
    if (mxGetNumberOfElements(FSO_ARG) != 1) {
        THROW_ERROR(S, "Full regiser output must be a scalar");
    }
    d = mxGetPr(FSO_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || ((i!=0)&&(i!=1))) {
        THROW_ERROR(S, "Full register output mode must be 0 or 1");
    }
    
    if (mxGetNumberOfElements(NSO_ARG) != 1) {
        THROW_ERROR(S, "Number of register entries output must be a scalar");
    }
    d = mxGetPr(NSO_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || ((i!=0)&&(i!=1))) {
        THROW_ERROR(S, "Number of register entries output mode must be 0 or 1");
    }
    
    if (mxGetNumberOfElements(CLRI_ARG) != 1) {
        THROW_ERROR(S, "Clear input must be a scalar");
    }
    d = mxGetPr(CLRI_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || ((i!=0)&&(i!=1))) {
        THROW_ERROR(S, "Clear input mode must be 0 or 1");
    }

    if (mxGetNumberOfElements(CLRONRST_ARG) != 1) {
        THROW_ERROR(S, "Clear on Resest must be a scalar");
    }
    d = mxGetPr(CLRONRST_ARG)[0];
    i = (int_T)d;
    if ((d!=i) || ((i!=0)&&(i!=1))) {
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
    
    ssSetSFcnParamNotTunable(S, REG_SIZE_ARGC);
    ssSetSFcnParamNotTunable(S, PUSHFULL_ARGC); /* pushfull mode (dynamic alloc) */
    ssSetSFcnParamNotTunable(S, ESO_ARGC);      /* empty-stack output       */
    ssSetSFcnParamNotTunable(S, FSO_ARGC);      /* full-stack output        */
    ssSetSFcnParamNotTunable(S, NSO_ARGC);      /* num stack entries output */
    ssSetSFcnParamNotTunable(S, CLRI_ARGC);     /* clear stack input        */
    
    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    /* Inputs: */
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
        
        if (num_inp>3) {
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
        boolean_T eso = (boolean_T)(mxGetPr(ESO_ARG)[0] != 0.0);
        boolean_T fso = (boolean_T)(mxGetPr(FSO_ARG)[0] != 0.0);
        boolean_T nso = (boolean_T)(mxGetPr(NSO_ARG)[0] != 0.0);

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
    const int_T reg_size = (int_T)(mxGetPr(REG_SIZE_ARG)[0]);

    /* Set the initial register size.
     * Note: We only can do this once, since depth might change if
     *       the 'reallocate on full register' option has been selected.
     *       The user's value would no longer be correct during an
     *       enabled subsystem re-intialization call.
     */
    ssSetIWorkValue(S, REGISTER_SIZE, reg_size);

    /* If PushFullMode is PFS_DYNAMIC, we need to allocate a dynamic buffer */
    {
        const PushFullMode pfm = (PushFullMode)((int_T)(mxGetPr(PUSHFULL_ARG)[0]));
        if (pfm == PFS_DYNAMIC) {
            const int_T     numEle    = ssGetInputPortWidth(S,DATAIN_PORT);
            const boolean_T cplx      = (boolean_T)(ssGetInputPortComplexSignal(S, DATAIN_PORT) == COMPLEX_YES);
            const int_T     allocSize = numEle * reg_size * (cplx ? sizeof(creal_T) : sizeof(real_T));
            void           *reg       = (void *)malloc(allocSize);

            ssSetPWorkValue(S, REG_PTR_IDX, reg);
            if (reg == NULL) {
                THROW_ERROR(S, "Failed to allocate register");
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
    
    /* Initialize: */
    ssSetIWorkValue(S, START_IDX,       0);
    ssSetIWorkValue(S, NEXT_IDX,        0);
    ssSetIWorkValue(S, PREV_PUSH_STATE, UNINITIALIZED_ZCSIG);
    ssSetIWorkValue(S, PREV_POP_STATE,  UNINITIALIZED_ZCSIG);

    if (clri) {
        ssSetIWorkValue(S, PREV_CLR_STATE,  UNINITIALIZED_ZCSIG);
    }

    if (eso) {
        /* empty stack output */
        real_T *esoOut = ssGetOutputPortRealSignal(S,SO1_PORT);
        *esoOut = 1.0;
    }

    /* Reset output port data if ClearOnReset selected */
    if (cor) {
        const boolean_T cplx = (boolean_T)(ssGetInputPortComplexSignal(S, DATAIN_PORT) == COMPLEX_YES);
        int_T           N    = ssGetInputPortWidth(S,DATAIN_PORT);

        if (!cplx) {
           real_T *dataOut = ssGetOutputPortRealSignal(S,DATAOUT_PORT);
           while(N-- > 0) {
               *dataOut++ = 0.0;
           }

        } else {
           creal_T *dataOut = (creal_T *)ssGetOutputPortSignal(S,DATAOUT_PORT);
		  creal_T cZero;
		  cZero.re = 0.0;
		  cZero.im = 0.0;
          while(N-- > 0) {
               *dataOut++ = cZero;
           }
        }
    }
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T clri = (boolean_T)(mxGetPr(CLRI_ARG)[0] != 0.0);
    ZCEventType     push, pop, clr;

    {
        /* Determine triggering operation: */
        int_T       mask_dir = (int_T)mxGetPr(TRIGTYPE_ARG)[0];
        ZCDirection zc_dir   = (mask_dir==1) ? RISING_ZERO_CROSSING :
        (mask_dir==2) ? FALLING_ZERO_CROSSING : ANY_ZERO_CROSSING;
        /* Push event */
        InputRealPtrsType trig_in = ssGetInputPortRealSignalPtrs(S, PUSH_PORT);
        push = rt_ZCFcn(zc_dir, (ZCSigState *)ssGetIWork(S) + PREV_PUSH_STATE, **trig_in);
        
        /* Pop event */
        trig_in = ssGetInputPortRealSignalPtrs(S, POP_PORT);
        pop = rt_ZCFcn(zc_dir, (ZCSigState *)ssGetIWork(S) + PREV_POP_STATE, **trig_in);
        
        /* Clr event */
        if (clri) {
            trig_in = ssGetInputPortRealSignalPtrs(S, CLR_PORT);
            clr = rt_ZCFcn(zc_dir, (ZCSigState *)ssGetIWork(S) + PREV_CLR_STATE, **trig_in);
        }
        
        if (!(push || pop || (clri && clr))) return;
    }
    
    {
        const boolean_T    cplx       = (boolean_T)(ssGetInputPortComplexSignal(S, DATAIN_PORT) == COMPLEX_YES);
        const PushFullMode pfm        = (PushFullMode)((int_T)(mxGetPr(PUSHFULL_ARG)[0]));
        const PopEmptyMode pes        = (PopEmptyMode)((int_T)(mxGetPr(PES_ARG)[0]));
        const boolean_T    eso        = (boolean_T)(mxGetPr(ESO_ARG)[0] != 0.0);
        const boolean_T    fso        = (boolean_T)(mxGetPr(FSO_ARG)[0] != 0.0);
        const boolean_T    nso        = (boolean_T)(mxGetPr(NSO_ARG)[0] != 0.0);
        const int_T        N          = ssGetInputPortWidth(S,DATAIN_PORT);
        int_T              start      = ssGetIWorkValue(S, START_IDX);
        int_T	           next	 	  = ssGetIWorkValue(S, NEXT_IDX);
        int_T              reg_size   = ssGetIWorkValue(S, REGISTER_SIZE);
        int_T              numEntries = (next >= start) ? (next-start)
                                                        : next + (reg_size-start);
        
        if (clri && clr) {
            /* Clear the register */
            
            /* Reset stack pointer: */
            numEntries = 0;
            start = 0; ssSetIWorkValue(S, START_IDX, 0);
            next  = 0; ssSetIWorkValue(S, NEXT_IDX,  0);

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
                       creal_T cZero;
					   cZero.re = 0.0;
					   cZero.im = 0.0;
					   while(N-- > 0) {
                           *dataOut++ = cZero;
                       }
                    }
                }
            }

            /* Update output ports */
            {
                real_T *outp;
                
                if (eso) {
                    /* register is now empty */
                    outp  = ssGetOutputPortRealSignal(S,SO1_PORT);
                    *outp = 1.0;
                }
                if (fso  && (pfm != PFS_DYNAMIC)) {
                    /* register is not full
                     * NOTE: you can never have a "full" register if dynamic stack is selected
                     */
                    int_T   fso_port = eso ? SO2_PORT : SO1_PORT;
                    outp  = ssGetOutputPortRealSignal(S, fso_port);
                    *outp = 0.0;
                }
                if (nso) {
                    /* Num register entries: */
                    int_T nso_port;
                    if (eso && fso) {
                        nso_port = SO3_PORT;
                    } else if (eso || fso) {
                        nso_port = SO2_PORT;
                    } else {
                        nso_port = SO1_PORT;
                    }
                    outp  = ssGetOutputPortRealSignal(S, nso_port);
                    *outp = numEntries;
                }
            }
        }
        
        if (push) {
            if (numEntries == reg_size) {
                /* Attempt to fill register beyond current reg_size */
                
                if (pfm == PFS_DYNAMIC) {
                    /* Extend allocation dynamically:
                     *
                     * - allocate new buffer, length=2*reg_size
                     * - check for NULL
                     * - copy reg_size entries from orig to new
                     *   starting at the top of the new register
                     * - new new reg_size = 2*orig reg_size
                     * - record new alloc ptr
                     * - free orig alloc
                     */
                    const int_T oldAllocSize = reg_size * N * (cplx ? sizeof(creal_T) : sizeof(real_T));
                    const int_T newAllocSize = 2 * oldAllocSize;

                    void *orig_reg = (void *)ssGetPWorkValue(S, REG_PTR_IDX);
                    void *new_reg  = (void *)malloc(newAllocSize);
            
                    if (new_reg == NULL) {
                        THROW_ERROR(S, "Failed to reallocate register");
                    }
                    
                    /* Copy register contents to new register
                     * Start copying to the start of the new register
                     */
                    {
                        int_T i;
                        int_T sN = start * N;
                        int_T rN = reg_size * N;

                        if (cplx) {
                            /* Complex */
                            creal_T *porig_reg = (creal_T *)orig_reg;
                            creal_T *pnew_reg  = (creal_T *)new_reg;

                            for (i=0; i<rN; i++) {
                                pnew_reg[i] = porig_reg[(i+sN) % rN];
                            }

                        } else {
                            /* Real */
                            real_T *porig_reg = (real_T *)orig_reg;
                            real_T *pnew_reg  = (real_T *)new_reg;
                    
                            for (i=0; i<rN; i++) {
                                pnew_reg[i] = porig_reg[(i+sN) % rN];
                            }
                        }
                    }
                    
                    ssSetIWorkValue(S, START_IDX,     0);
                    ssSetIWorkValue(S, NEXT_IDX,      reg_size);
                    ssSetIWorkValue(S, REGISTER_SIZE, reg_size*2);
                    ssSetPWorkValue(S, REG_PTR_IDX,   new_reg);
                    free(orig_reg);
                    
                    reg_size *= 2; /* update reg_size value for code following */
                    
                } else {
                    /* Non-extending allocation: */
#ifdef MATLAB_MEX_FILE
                    static char msg[] = "Attempt to add to full register";
                    if (pfm == PFS_WARNING) {
                        mexWarnMsgTxt(msg);
                    } else if (pfm == PFS_ERROR) {
                        ssSetErrorStatus(S, msg);
                    }
#endif
                    return;
                }
            } /* if (numEntries == reg_size) */
            
            /* Copy input elements into register: */
            {
                if (cplx) {
                    /* Complex data */

                    InputPtrsType dataIn = ssGetInputPortSignalPtrs(S,DATAIN_PORT);
                    creal_T *reg;
                
                    /* Point to start of stack allocation: */
                    if (pfm == PFS_DYNAMIC) {
                        /* Dynamic stack: */
                        reg = (creal_T *)ssGetPWorkValue(S, REG_PTR_IDX);
                    } else {
                        /* Fixed stack: */
                        reg = (creal_T *)ssGetDWork(S, DWORK_REGISTER);
                    }
                
                    /* Point to next available entry in stack: */
                    reg += (next % reg_size) * N;
                
                    /* Register will not wrap during copy of input vector */
                    {
                        int_T i = N;
                        while(i-- > 0) {
                            *reg++ = *((creal_T *)(*dataIn++));
                        }
                    }

                } else {
                    /* Real data */

                    InputRealPtrsType dataIn = ssGetInputPortRealSignalPtrs(S,DATAIN_PORT);
                    real_T *reg;
                
                    /* Point to start of stack allocation: */
                    if (pfm == PFS_DYNAMIC) {
                        /* Dynamic stack: */
                        reg = (real_T *)ssGetPWorkValue(S, REG_PTR_IDX);
                    } else {
                        /* Fixed stack: */
                        reg = (real_T *)ssGetDWork(S, DWORK_REGISTER);
                    }
                
                    /* Point to next available entry in stack: */
                    reg += (next % reg_size) * N;
                
                    /* Register will not wrap during copy of input vector */
                    {
                        int_T i = N;
                        while(i-- > 0) {
                            *reg++ = **dataIn++;
                        }
                    }
                }

                /* Bump register pointer: */
                ssSetIWorkValue(S, NEXT_IDX, next+1);  /* don't unwrap index! */
                
                if (eso) {
                    /* register is no longer empty */
                    real_T *esoOut = ssGetOutputPortRealSignal(S,SO1_PORT);
                    *esoOut = 0.0;
                }

                if (fso  && (pfm != PFS_DYNAMIC)) {
                    /* full register output
                     * NOTE: you can never have a "full" register if dynamic alloc is selected
                     */
                    int_T fso_port = eso ? SO2_PORT : SO1_PORT;
                    real_T *fsoOut = ssGetOutputPortRealSignal(S, fso_port);
                    *fsoOut = (numEntries+1 == reg_size);
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
                    *nsoOut = numEntries+1;
                }
            }
        }
        
        if (pop) {
            if (numEntries == 0) {
                /* Attempt to pop empty register */
#ifdef MATLAB_MEX_FILE
                static char msg[] = "Attempt to pop empty register";
                if (pes == PES_WARNING) {
                    mexWarnMsgTxt(msg);
                } else if (pes == PES_ERROR) {
                    ssSetErrorStatus(S, msg);
                }
#endif
                return;
            }
            
            /* Copy register contents to output: */
            {
                if (cplx) {
                    creal_T *dataOut = (creal_T *)ssGetOutputPortSignal(S,DATAOUT_PORT);
                    creal_T *reg;
                
                    /* Point to start of register allocation: */
                    if (pfm == PFS_DYNAMIC) {
                        /* Dynamic stack: */
                        reg = (creal_T *)ssGetPWorkValue(S, REG_PTR_IDX);
                    } else {
                        /* Fixed register: */
                        reg = (creal_T *)ssGetDWork(S, DWORK_REGISTER);
                    }
                
                    /* Point to oldest sample in register */
                    reg += (start % reg_size) * N;
                
                    /* Register will not wrap during copy of input vector */
                    {
                        int_T i = N;
                        while(i-- > 0) {
                            *dataOut++ = *reg++;  /* Copy re and im parts */
                        }
                    }

                } else {
                    real_T *dataOut = ssGetOutputPortRealSignal(S,DATAOUT_PORT);
                    real_T *reg;
                
                    /* Point to start of register allocation: */
                    if (pfm == PFS_DYNAMIC) {
                        /* Dynamic stack: */
                        reg = (real_T *)ssGetPWorkValue(S, REG_PTR_IDX);
                    } else {
                        /* Fixed register: */
                        reg = (real_T *)ssGetDWork(S, DWORK_REGISTER);
                    }
                
                    /* Point to oldest sample in register */
                    reg += (start % reg_size) * N;
                
                    /* Register will not wrap during copy of input vector */
                    {
                        int_T i = N;
                        while(i-- > 0) {
                            *dataOut++ = *reg++;
                        }
                    }
                }

                /* Update register pointer: */
                if (start+1 == reg_size) {
                    ssSetIWorkValue(S, START_IDX, 0);
                
                    /* Only NOW may we update next index for modulo: */
                    ssSetIWorkValue(S, NEXT_IDX, next % reg_size);
                } else {
                    ssSetIWorkValue(S, START_IDX, start+1);
                }

                
                if (eso) {
                    /* empty register output */
                    real_T *esoOut = ssGetOutputPortRealSignal(S,SO1_PORT);
                    *esoOut = (numEntries-1 == 0);
                }
                if (fso && (pfm != PFS_DYNAMIC)) {
                /* register is no longer full
                * NOTE: you can never have a "full" register if dynamic alloc is selected
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
                    *nsoOut = numEntries-1;
                }
            }
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
    /* If PushFullMode is PFS_DYNAMIC, we need to free allocation */
    const PushFullMode pfm = (PushFullMode)((int_T)(mxGetPr(PUSHFULL_ARG)[0]));
    if (pfm == PFS_DYNAMIC) {
        real_T *reg  = ssGetPWorkValue(S, REG_PTR_IDX);
        if (reg != NULL) {
            free(reg);
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
* reg_size * input_width number of elements
    */
    const PushFullMode pfm = (PushFullMode)((int_T)(mxGetPr(PUSHFULL_ARG)[0]));
    if (pfm == PFS_DYNAMIC) {
        /* Dynamic allocation - uses malloc/free */
        ssSetNumPWork(S, 1);
        if(!ssSetNumDWork(S, 0)) return;
    } else {
        /* Fixed allocation - uses RWork */
        
        const int_T      N               = ssGetInputPortWidth(S,DATAIN_PORT);
        const int_T      reg_size        = (int_T)(mxGetPr(REG_SIZE_ARG)[0]);
        const int_T      AllocSize       = reg_size * N;
        const CSignal_T  stackComplexity = ssGetInputPortComplexSignal(S, DATAIN_PORT);

        ssSetNumPWork(S,   0);

        if(!ssSetNumDWork(      S, NUM_DWORK)) return;
        ssSetDWorkWidth(        S, DWORK_REGISTER, AllocSize);
        ssSetDWorkComplexSignal(S, DWORK_REGISTER, stackComplexity);
    }
}
#endif


#include "dsp_cplxhs11.c"

#include "dsp_trailer.c"

/* [EOF] sdspqueue.c */
