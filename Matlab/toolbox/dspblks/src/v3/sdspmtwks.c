/*
 * SCMTXWKS  Matrix To-Workspace block for DSP Blockset.
 *
 * DSP Blockset S-Function to store matrix data in workspace.
 * This SIMULINK S-function stores its input as a 3-D matrix workspace
 * variable; it is called by the Matrix To Workspace block in
 * the DSP Blockset.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.23 $ $Date: 2002/04/19 02:57:15 $
 */

#define S_FUNCTION_NAME sdspmtwks
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0};
enum {VARNAME_ARGC=0, BUFSIZ_ARGC, DECI_ARGC, MATSIZ_ARGC, NUM_PARAMS};

#define VARNAME_ARG (ssGetSFcnParam(S,VARNAME_ARGC))
#define BUFSIZ_ARG  (ssGetSFcnParam(S,BUFSIZ_ARGC))
#define DECI_ARG    (ssGetSFcnParam(S,DECI_ARGC))
#define MATSIZ_ARG  (ssGetSFcnParam(S,MATSIZ_ARGC))

/* PWork indices: */
enum {CURBUF_PTR=0, BUF_PTR, NUM_PWORK};

/* IWork indices: */
enum {DECI_TARGET_IDX=0, DECI_CNT_IDX, FILL_IDX, BUFSIZ_IDX, NUM_IWORK};

#define SDSPMTWKS_DEF_BUFSIZ 1024

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    static char *msg;
    msg = NULL;
    
    if (!mxIsChar(VARNAME_ARG)) {
        msg = "Matrix name must be a string";
        goto FCN_EXIT;
    }
    /* Should check that name is a valid MATLAB variable name */
    
    if (mxGetNumberOfElements(BUFSIZ_ARG) != 1) {
        msg = "Maximum row count must be a scalar";
        goto FCN_EXIT;
    }
    if (mxGetNumberOfElements(DECI_ARG) != 1) {
        msg = "Decimation value must be a scalar integer";
        goto FCN_EXIT;
    }
    
    {
        real_T dval = mxGetPr(DECI_ARG)[0];
        int_T  ival = (int_T)dval;
        
        if ((dval < 1) || (dval != ival)) {
            msg = "Decimation must be a positive integer.";
            goto FCN_EXIT;
        }
        
		if( !mxIsInf(mxGetPr(BUFSIZ_ARG)[0]) ) {
			real_T *dptr = mxGetPr(BUFSIZ_ARG);
			if(dptr==NULL) {
				msg = "Invalid Maxrows argument";
				goto FCN_EXIT;
			}
			ival = (int_T)*dptr;
			if ((*dptr < 1) || (*dptr != ival)) {
				msg = "Maximum row count must be a positive integer";
				goto FCN_EXIT;
			}
		} 
    }
    
    /* Matrix size MUST be a 1x2 vector, and the number of elements
    * must equal vec_width
    */
    if ((mxGetM(MATSIZ_ARG) != 1) || (mxGetN(MATSIZ_ARG) != 2)) {
        msg = "Matrix size must be a 2-element row vector";
        goto FCN_EXIT;
    }
    
FCN_EXIT:
    ssSetErrorStatus(S, msg);
}
#endif


static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NUM_PARAMS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;
    mdlCheckParameters(S);
    if (ssGetErrorStatus(S) != NULL) return;
#else
    mexWarnMsgTxt("Real-time data logging is not supported for "
        "the 'Matrix To Workspace' block");
#endif
    
    /*
     * Only the variable name (param 0) can be
     *   modified while simulation runs:
     */
    ssSetSFcnParamNotTunable(S,VARNAME_ARGC);
    ssSetSFcnParamNotTunable(S,BUFSIZ_ARGC);
    ssSetSFcnParamNotTunable(S,DECI_ARGC);
    ssSetSFcnParamNotTunable(S,MATSIZ_ARGC);
    
    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;

    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT, 1);
    ssSetInputPortOverWritable(     S, INPORT, 0);

    /* Outputs: */
    if (!ssSetNumOutputPorts(S,0)) return;   

    ssSetNumIWork(      S, NUM_IWORK);
    ssSetNumPWork(      S, NUM_PWORK);
    ssSetNumSampleTimes(S, 1);
    
    /* NOTE: Because this function interacts with the MATLAB
     * workspace, we cannot set SS_OPTION_EXCEPTION_FREE_CODE.
     * However, the runtime option is just fine.
     */
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    static char *msg;
    const int_T     width  = ssGetInputPortWidth(S,INPORT);
    const boolean_T cplx   = (ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    const int_T     ii     = (int_T) (mxGetPr(MATSIZ_ARG)[0]); /* Rows */
    const int_T     jj     = (int_T) (mxGetPr(MATSIZ_ARG)[1]); /* Cols */
	int_T           bufsiz = (int_T)mxGetPr(BUFSIZ_ARG)[0];
    msg = NULL;
    
    /* Check that input matrix size matches block parameters */
    if(ssGetInputPortWidth(S,0) != ii*jj) {
        msg = "Size of input port is not consistent with block parameters.";
        goto FCN_EXIT;
    }
    
	/* Use default initial buffersize if the user entered Inf
	 * and then grow the buffer as needed. Otherwise just use
	 * the buffer size specified.
	 */
	if(mxIsInf(mxGetPr(BUFSIZ_ARG)[0])) {
		bufsiz = SDSPMTWKS_DEF_BUFSIZ;
	}

	/* Allocate our buffer and store the pointer in PWORK */
	if(cplx) {
		creal_T *buffer = (creal_T *)calloc(bufsiz * width, sizeof(creal_T));
		if(buffer==NULL) {
			msg = "Failed to allocate memory for ToWorkSpace Buffer";
			goto FCN_EXIT;
		}
		ssSetPWorkValue(S, BUF_PTR, buffer);   /* Store base address of buffer */
		ssSetPWorkValue(S, CURBUF_PTR, buffer);/* Set current buffer pointer to base */
	} else {
		real_T  *buffer = (real_T *)calloc(bufsiz * width, sizeof(real_T));
		if(buffer==NULL) {
			msg = "Failed to allocate memory for ToWorkSpace Buffer";
			goto FCN_EXIT;
		}
		ssSetPWorkValue(S, BUF_PTR, buffer);    /* Store base address of buffer */
		ssSetPWorkValue(S, CURBUF_PTR, buffer); /* Set current buffer pointer to base */
	}
	   
	ssSetIWorkValue(S, BUFSIZ_IDX, bufsiz);

	{
		int_T   deci   = (int_T) mxGetPr(DECI_ARG)[0];    
		
		/* Initialize the buffer fill counter: */
		ssSetIWorkValue(S, FILL_IDX, 0);
		
		/*
		* Set DECI_CNT to 1 so that the first sample gets stored, regardless of
		* the decimation value.  Otherwise, we will suffer unnecessary latency.
		*/
		ssSetIWorkValue(S, DECI_TARGET_IDX, deci);
		ssSetIWorkValue(S, DECI_CNT_IDX, 1);
		
	}

FCN_EXIT:
    ssSetErrorStatus(S, msg);

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    const boolean_T cX       = (ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    int_T          *deci_cnt = ssGetIWork(S) + DECI_CNT_IDX;
    int_T           width    = ssGetInputPortWidth(S,INPORT); 
    int_T           bufsiz   = ssGetIWorkValue(S, BUFSIZ_IDX);
    
    /*
    * If the decimation counter isn't zero on entry, return.
    * Otherwise, acquire the input vector into the buffer.
    */
    if (--(*deci_cnt) != 0) {
        return;
    }
    
    /* Reset decimation counter: */
    *deci_cnt = ssGetIWorkValue(S, DECI_TARGET_IDX);    
    
    /* Copy the input vector to the buffer: */		           
    
    if(!cX) {
        /* Real */
        InputRealPtrsType uptr     = ssGetInputPortRealSignalPtrs(S,INPORT);
        real_T           *bufstart = ssGetPWorkValue(S, BUF_PTR);
        real_T           *bufend   = bufstart + bufsiz * width;				
        real_T           *currbuff = ssGetPWorkValue(S, CURBUF_PTR);
        int_T            vec_width = width; 

        while (vec_width-- > 0) {
            *currbuff++ = **uptr++;
        }
        
        if(currbuff == bufend) {
			if(!mxIsInf(mxGetPr(BUFSIZ_ARG)[0])) {
				/* If we hit the end of a finite buffer, then wrap around to the start */
				currbuff = bufstart;
			} else {
				/* If the buffer size is infinite, we need to allocate more space
				 * when we reach end of the allocated buffer.  We'll increase it
				 * by another default buffer size each time we need more memory.
				 */
				int_T offset = currbuff - bufstart;
                bufsiz += SDSPMTWKS_DEF_BUFSIZ;         /* Increase buffer size  */
				ssSetIWorkValue(S, BUFSIZ_IDX, bufsiz); /* Store new buffer size */

				bufstart = (real_T *)realloc(bufstart, bufsiz * width * sizeof(real_T));
				if(bufstart!=NULL) {
					currbuff = bufstart + offset;         /* Reset current based on new start */
					ssSetPWorkValue(S, BUF_PTR, bufstart);/* Store new base address of buffer */
				} else {
					free(bufstart);
					ssSetErrorStatus(S, "Failed to reallocate memory");
					return;
				}
			}
        }
        ssSetPWorkValue(S, CURBUF_PTR, currbuff);  /* Store pointer */
        
    } else {
        
        /* Complex */
        InputPtrsType uptr      = ssGetInputPortSignalPtrs(S,INPORT);	
        creal_T      *bufstart  = (creal_T *)ssGetPWorkValue(S, BUF_PTR);
        creal_T      *bufend    = (creal_T *)bufstart + bufsiz * width;				
        creal_T      *currbuff  = (creal_T *)ssGetPWorkValue(S, CURBUF_PTR);
        int_T         vec_width = width;

        while (vec_width-- > 0) {
            *currbuff++ = *((creal_T *)(*uptr++));
        }
        
        if(currbuff == bufend) {
			if(!mxIsInf(mxGetPr(BUFSIZ_ARG)[0])) {
				/* If we hit the end of a finite buffer, then wrap around to the start */
				currbuff = bufstart;
			} else {
				/* If the buffer size is infinite, we need to allocate more space
				 * when we reach end of the allocated buffer.  We'll increase it
				 * by another default buffer size each time we need more memory.
				 */
				int_T offset = currbuff - bufstart;
                bufsiz += SDSPMTWKS_DEF_BUFSIZ;         /* Increase buffer size  */
				ssSetIWorkValue(S, BUFSIZ_IDX, bufsiz); /* Store new buffer size */

				bufstart = (creal_T *)realloc(bufstart, bufsiz * width * sizeof(creal_T));
				if(bufstart!=NULL) {
					currbuff = bufstart + offset;         /* Reset current based on new start */
					ssSetPWorkValue(S, BUF_PTR, bufstart);/* Store new base address of buffer */
				} else {
					free(bufstart);
					ssSetErrorStatus(S, "Failed to reallocate memory");
					return;
				}
			}
        }
        ssSetPWorkValue(S, CURBUF_PTR, currbuff);  /* Store pointer */		
    }
    
    /*
    * Update the buffer fill counter.  If buffer has been
    * filled, leave fill counter equal to the buffer size:
    */
    {
        int_T *fill_idx = ssGetIWork(S) + FILL_IDX;
        if (*fill_idx < bufsiz) {
            (*fill_idx)++;  /* Increment fill count */
        }
    }
}


static void mdlTerminate(SimStruct *S)
{
#ifdef MATLAB_MEX_FILE
    const boolean_T cX           = (ssGetInputPortComplexSignal(S,0) == COMPLEX_YES);
    const int_T     bufsiz       = ssGetIWorkValue(S, BUFSIZ_IDX);
    const int_T     vec_width    = ssGetInputPortWidth(S,INPORT);
    const int_T     rows         = (int_T)(mxGetPr(MATSIZ_ARG)[0]);
    const int_T     cols         = (int_T)(mxGetPr(MATSIZ_ARG)[1]);
    int_T           pages        = ssGetIWorkValue(S, FILL_IDX);  /* 3rd dimension */
    char           *matname;     /* name of array to construct in MATLAB WS    */
    mxArray        *pm;          /* array to create in MATLAB's base workspace */
    
    /* Get name of array to create in MATLAB workspace: */
    {
        const mxArray *pmat     = VARNAME_ARG;
        int_T          name_len = mxGetNumberOfElements(pmat) + 1;
        
        matname = (char *)mxCalloc(name_len, sizeof(char));
        mxGetString(pmat, matname, name_len);
    }
    
    /*
    * Create result array in MATLAB's base workspace.
    * # cols = the # of vector entries 
    * # rows = number of actual samples collected, or buffer size
    *          whichever is greater
    */
    {
        int_T mat_siz[3];
        mat_siz[0] = rows;
        mat_siz[1] = cols;
        mat_siz[2] = pages;
        
        pm = mxCreateNumericArray(3, mat_siz, mxDOUBLE_CLASS, (cX) ? mxCOMPLEX : mxREAL);
        
    }
    
    /*
    * Transfer buffer data to array.
    * Must transpose the data so vector runs along the row
    *
    * For a filled buffer:
    *   currbuff points to the oldest sample in circular buffer
    * For a partially filled buffer:
    *   currbuff points to past end of linear data buffer
    */
    if(!cX) {
        /* Real */
        real_T  *bufstart = ssGetPWorkValue(S, BUF_PTR);
        real_T  *currbuff = ssGetPWorkValue(S, CURBUF_PTR);
        real_T  *bufend   = bufstart + bufsiz * vec_width;
        real_T  *in       = currbuff;
        real_T  *out      = mxGetPr(pm);
        const int_T  ele  = rows*cols;
        int_T        j;
        
        /* For partial buffer, adjust initial data pointer: */
        if (pages < bufsiz) {
            in = bufstart;
        }
        
        for (j=0; j<pages; j++) {
            int_T i = ele;
            
            while(i-- > 0) {
                *out++ = *in++;
            }
            if (in == bufend) {
                in = bufstart;
            }
        }			
        
    } else {
        /* Complex */
        creal_T  *bufstart = (creal_T *)ssGetPWorkValue(S, BUF_PTR);
        creal_T  *currbuff = (creal_T *)ssGetPWorkValue(S, CURBUF_PTR);
        creal_T  *bufend   = bufstart + bufsiz * vec_width;
        creal_T  *in       = currbuff;
        real_T   *out_Re   = mxGetPr(pm);   /* MATLAB requires separate pointers */
        real_T   *out_Im   = mxGetPi(pm);   /* for real and imaginary            */
        const int_T  ele   = rows*cols;
        
        /* For partial buffer, adjust initial data pointer: */
        if (pages < bufsiz) {
            in = bufstart;
        }
        
        while(pages-- > 0) {
            int_T i = ele;
            
            while(i-- > 0) {
                *out_Re++ = in->re;
                *out_Im++ = in->im;
                in++;
            }
            
            if (in == bufend) {
                in = bufstart;
            }
        }
    }
    
    {
        /* Determine the Destination Workspace and output the data */
        
        char_T    *workspace;
        int_T      buflen;
        int_T      status;	
        mxArray   *input_array[2];       
        mxArray   *output_array[1];
        mxArray   *model[1];
        
        /* Get the string for the current root model */
        mexCallMATLAB(1, model, 0, NULL, "bdroot");
        
        /* Get the desitination workspace for output */	
        input_array[0] = model[0];
        input_array[1] = mxCreateString("DstWorkSpace");
        
        mexCallMATLAB(1, output_array, 2, input_array, "simget");           
        
        buflen = mxGetNumberOfElements(output_array[0]) + 1;
        
        workspace = mxCalloc(buflen, sizeof(char));
        if(workspace == NULL) {
            mexErrMsgTxt("Allocation failure when writing matrix to workspace.");
        }
        
        status = mxGetString(output_array[0], workspace, buflen);
        if(status != 0) {
            mexErrMsgTxt("Failed to determine destination workspace.");
        }
        
        /*
        * Put the output matrix into the workspace specified by DstWorksSpace
        *
        *    (Simulink)     (MATLAB)
        *   DstWorkspace  Where we put array
        *   ------------  ------------------
        *     base          base
        *     caller        caller
        *     parent        caller
        */
        {
            char_T *dest_str = (!strcmp(workspace,"base") ||
                !strcmp(workspace,"BASE")) ? "base" : "caller";
            if (mexPutVariable(dest_str, matname, pm) != 0) {
                mexErrMsgTxt("Failed to transfer matrix to the requested workspace.");
            }
            
        }
        
	free(ssGetPWorkValue(S, BUF_PTR) );
        mxFree(matname);         /* Free the name allocation */
        mxFree(workspace);
        mxDestroyArray(input_array[0]);
        mxDestroyArray(input_array[1]);
        mxDestroyArray(output_array[0]);
    }
#endif
}

#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
