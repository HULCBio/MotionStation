/*
 * SDSPSTWKS  Signal To-Workspace block for DSP Blockset.
 *
 * DSP Blockset S-Function to store signal data in workspace.
 *
 *   
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.25 $ $Date: 2002/04/19 02:57:19 $
 */
#define S_FUNCTION_NAME sdspstwks
#define S_FUNCTION_LEVEL 2

#include "dsp_sim.h"

enum {INPORT=0};
enum {VARNAME_ARGC=0, BUFSIZ_ARGC, DECI_ARGC, FRAME_ARGC, NCHANS_ARGC, NUM_PARAMS};

#define VARNAME_ARG (ssGetSFcnParam(S,VARNAME_ARGC))
#define BUFSIZ_ARG  (ssGetSFcnParam(S,BUFSIZ_ARGC))
#define DECI_ARG    (ssGetSFcnParam(S,DECI_ARGC))
#define FRAME_ARG   (ssGetSFcnParam(S,FRAME_ARGC))
#define NCHANS_ARG  (ssGetSFcnParam(S,NCHANS_ARGC))

/* PWork indices: */
enum {CURBUF_PTR=0, BUF_PTR, NUM_PWORK};

/* IWork indices: */
enum {DECI_TARGET_IDX=0, DECI_CNT_IDX, FILL_IDX, BUFSIZ_IDX, BUFINF_IDX, NUM_IWORK};

#define SDSPSTWKS_DEF_BUFSIZ 1024

#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    static char *msg;
    msg = NULL;
    
    if (!mxIsChar(VARNAME_ARG) ) {
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
    
    if (mxGetNumberOfElements(FRAME_ARG) != 1) {
        msg = "Frame must be a scalar";
        goto FCN_EXIT;
    }

    {
        const boolean_T frame = (boolean_T)(mxGetPr(FRAME_ARG)[0]==1);
        if(frame) {
            if (mxGetNumberOfElements(NCHANS_ARG) != 1) {
                msg = "Number of channels must be a scalar";
                goto FCN_EXIT;
            }         
        }
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
#else
	msg = "Real-time data logging is not supported for "
        "the 'Signal To Workspace' block";
	ssSetErrorStatus(S, msg);
#endif

    if (ssGetErrorStatus(S) != NULL) return;


    /*
     * Only the variable name (param 0) can be
     *   modified while simulation runs:
     */
    ssSetSFcnParamNotTunable(S,VARNAME_ARGC);
    ssSetSFcnParamNotTunable(S,BUFSIZ_ARGC);
    ssSetSFcnParamNotTunable(S,DECI_ARGC);
    ssSetSFcnParamNotTunable(S,FRAME_ARGC);
    ssSetSFcnParamNotTunable(S,NCHANS_ARGC);
    
    /* Inputs: */
    if (!ssSetNumInputPorts(S, 1)) return;

    ssSetInputPortWidth(            S, INPORT, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, INPORT, 1);
    ssSetInputPortComplexSignal(    S, INPORT, COMPLEX_INHERITED);
    ssSetInputPortReusable(        S, INPORT, 1);
    
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
    /* Check sizes if it is frame based.
     * The number of channels correspond to the number
     * of columns in the data.  So the nchans better
     * divide evenly into the number of elements!
     */
    static char    *msg;    
    const int_T     width   = ssGetInputPortWidth(S,INPORT);
    const int_T     nchans  = (int_T)mxGetPr(NCHANS_ARG)[0];
    const boolean_T frame   = (boolean_T)(mxGetPr(FRAME_ARG)[0]==1);
    const boolean_T cplx    = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    const int_T     bufinf  = mxIsInf(mxGetPr(BUFSIZ_ARG)[0]);
    int_T           bufsiz  = (int_T)mxGetPr(BUFSIZ_ARG)[0];
    msg = NULL;
    
    ssSetIWorkValue(S, BUFINF_IDX, bufinf);  /* Store whether buffer is infinite */
     

    if(frame) {
        if((width%nchans) != 0) {
            msg = "Number of channels must divide evenly into the input width.";
            goto FCN_EXIT;
        }
    }
		
	/* Use default initial buffersize if the user entered Inf
	 * and then grow the buffer as needed. Otherwise just use
	 * the buffer size specified.
	 */
	if(bufinf) {
		bufsiz = SDSPSTWKS_DEF_BUFSIZ;
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
    const boolean_T cX        = (boolean_T)(ssGetInputPortComplexSignal(S,INPORT) == COMPLEX_YES);
    int_T          *deci_cnt  = ssGetIWork(S) + DECI_CNT_IDX;
    int_T	    width     = ssGetInputPortWidth(S,INPORT);
    int_T           bufsiz    = ssGetIWorkValue(S, BUFSIZ_IDX);
    const boolean_T bufinf    = (boolean_T)ssGetIWorkValue(S, BUFINF_IDX);
    
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
        /** Real **/
        InputRealPtrsType uptr     = ssGetInputPortRealSignalPtrs(S,INPORT);
        real_T           *bufstart = ssGetPWorkValue(S, BUF_PTR);
        real_T           *bufend   = bufstart + bufsiz * width;				
        real_T           *currbuff = ssGetPWorkValue(S, CURBUF_PTR);
		int_T            vec_width = width; 
        
        while (vec_width-- > 0) {
            *currbuff++ = **uptr++;
        }
      
        if(currbuff == bufend) {
			if(!bufinf) {
				/* If we hit the end of a finite buffer, then wrap around to the start */
				currbuff = bufstart;
			} else {
				/* If the buffer size is infinite, we need to allocate more space
				 * when we reach end of the allocated buffer.  We'll increase it
				 * by another default buffer size each time we need more memory.
				 */
				int_T   offset = currbuff - bufstart;
                                real_T *bufstart_new;  
                                bufsiz *= 2;                            /* Double the buffer size  */
				ssSetIWorkValue(S, BUFSIZ_IDX, bufsiz); /* Store new buffer size */

				bufstart_new = (real_T *)realloc(bufstart, bufsiz * width * sizeof(real_T));
				if(bufstart_new!=NULL) {
					currbuff = bufstart_new + offset;         /* Reset current based on new start */
					ssSetPWorkValue(S, BUF_PTR, bufstart_new);/* Store new base address of buffer */
				} else {
					free(bufstart);                           /* Free original memory if reallc fails */
					ssSetErrorStatus(S, "Failed to reallocate memory");
					return;
				}
			}
        }
        ssSetPWorkValue(S, CURBUF_PTR, currbuff);  /* Store current pointer */
        
    } else {
        
        /** Complex **/
        InputPtrsType uptr      = ssGetInputPortSignalPtrs(S,INPORT);	
        creal_T      *bufstart  = (creal_T *)ssGetPWorkValue(S, BUF_PTR);
        creal_T      *bufend    = (creal_T *)bufstart + bufsiz * width;				
        creal_T      *currbuff  = (creal_T *)ssGetPWorkValue(S, CURBUF_PTR);
		int_T         vec_width = width; 
        
        while (vec_width-- > 0) {
            creal_T  cu = *((creal_T *)*uptr++);  
            currbuff->re     = cu.re;
            (currbuff++)->im = cu.im;
        }
        
        if(currbuff == bufend) {
			if(!bufinf) {
				/* If we hit the end of a finite buffer, then wrap around to the start */
				currbuff = bufstart;
			} else {
				/* If the buffer size is infinite, we need to allocate more space
				 * when we reach end of the allocated buffer.  We'll increase it
				 * by another default buffer size each time we need more memory.
				 */
				int_T    offset = currbuff - bufstart;
                                creal_T *bufstart_new;

                                bufsiz *= 2;                            /* Double the buffer size  */
				ssSetIWorkValue(S, BUFSIZ_IDX, bufsiz); /* Store new buffer size */

				bufstart_new = (creal_T *)realloc(bufstart, bufsiz * width * sizeof(creal_T));
				if(bufstart_new!=NULL) {
					currbuff = bufstart_new + offset;         /* Reset current based on new start */
					ssSetPWorkValue(S, BUF_PTR, bufstart_new);/* Store new base address of buffer */
				} else {
					free(bufstart);                           /* Free original memory if reallic fails */
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
    const boolean_T cX         = (boolean_T)(ssGetInputPortComplexSignal(S,0) == COMPLEX_YES);
    const boolean_T frame      = (boolean_T)(mxGetPr(FRAME_ARG)[0] != 0.0);
    const int_T     bufsiz     = ssGetIWorkValue(S, BUFSIZ_IDX);
    const int_T     vec_width  = ssGetInputPortWidth(S,0);
    const int_T     simsteps   = ssGetIWorkValue(S, FILL_IDX);  
    const int_T     nchans     = (frame) ? (int_T)mxGetPr(NCHANS_ARG)[0] : vec_width;
    const int_T     chansize   = vec_width/nchans;
    const int_T     stride     = (simsteps-1) * chansize;
    char           *matname;     /* name of array to construct in MATLAB WS    */
    mxArray        *pm;          /* array to create in MATLAB's base workspace */
    int_T           p;
    
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
        int_T mat_siz[2];

        mat_siz[0] = simsteps * chansize;
        mat_siz[1] = nchans;
        
        pm = mxCreateNumericArray(2, mat_siz, mxDOUBLE_CLASS, (cX) ? mxCOMPLEX : mxREAL);

    }
    
    /*
    * Transfer buffer data to array.
    *
    * For a filled buffer:
    *   currbuff points to the oldest sample in circular buffer
    * For a partially filled buffer:
    *   currbuff points to past end of linear data buffer
    */

    /* Frame-based must output the data in channels */

    if(!cX) {
        /* Real */
        real_T  *bufstart = ssGetPWorkValue(S, BUF_PTR);
        real_T  *currbuff = ssGetPWorkValue(S, CURBUF_PTR);
        real_T  *bufend   = bufstart + bufsiz * vec_width;
        real_T  *out      = mxGetPr(pm);
        real_T  *in       = currbuff;
        
        /* For partial buffer, adjust initial data pointer: */
        if (simsteps < bufsiz) {
            in = bufstart;
        }        
        
        for (p=0; p<simsteps; p++) {                
            int_T   cs;
            int_T   ch;
            real_T *out2 = out + p*chansize;
            
            for(ch=0; ch<nchans; ch++) {
                
                for(cs=0; cs<chansize; cs++) {
                    *out2++ = *in++;
                }
                
                out2 += stride;
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
        real_T   *out_Re   = mxGetPr(pm);   /* MATLAB requires separate pointers */
        real_T   *out_Im   = mxGetPi(pm);   /* for real and imaginary            */
        creal_T  *in       = currbuff;


        /* For partial buffer, adjust initial data pointer: */
        if (simsteps < bufsiz) {
            in = bufstart;
        }
 
        for (p=0; p<simsteps; p++) {                
            int_T   cs;
            int_T   ch;
            real_T *out2_Re = out_Re + (p * chansize);
            real_T *out2_Im = out_Im + (p * chansize);            

            for(ch=0; ch<nchans; ch++) {
                
                for(cs=0; cs<chansize; cs++) {
                    *out2_Re++ = in->re;
                    *out2_Im++ = (in++)->im;
                }
                out2_Re += stride;
                out2_Im += stride;
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
        
        /* NOTE: The command simget only returns the string 
         * "current" and does not give you the correct state
         * of the DstWorkspace parameter for the model.  This
         * is a bug with simget that should be fixed. xxx
         */
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
        *     current       caller
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


#define MDL_RTW
#if defined(MATLAB_MEX_FILE) || defined(NRT)
static void mdlRTW(SimStruct *S)
{
    int32_T bufsize = (int32_T)mxGetPr(BUFSIZ_ARG)[0];
    int32_T deci    = (int32_T)mxGetPr(DECI_ARG)[0];
    int32_T frame   = (int32_T)mxGetPr(FRAME_ARG)[0];
    int32_T nChans  = (int32_T)mxGetPr(NCHANS_ARG)[0];
    int32_T strlen  = (int32_T)(mxGetNumberOfElements(VARNAME_ARG)+1);
   
    /* Get string from MATLAB variable */
    char_T *varname = mxCalloc(strlen, sizeof(char_T));
    if(varname==NULL) {
        mexErrMsgTxt("Failed to allocate memory for variable name string.");
    }
    if(mxGetString(VARNAME_ARG, varname, strlen)) {
        mexErrMsgTxt("Failed to get variable name string.");
    }

    /* Write parameters out to the RTW file */
    ssWriteRTWParamSettings(S, 5,
             SSWRITE_VALUE_QSTR,  "VARNAME",
             varname,

             SSWRITE_VALUE_DTYPE_NUM,  "BUFSIZE",
             &bufsize,
             DTINFO(SS_INT32,0),

             SSWRITE_VALUE_DTYPE_NUM,  "DECIMATE",
             &deci,
             DTINFO(SS_INT32,0),
             
             SSWRITE_VALUE_DTYPE_NUM,  "FRAME",
             &frame,
             DTINFO(SS_INT32,0),

             SSWRITE_VALUE_DTYPE_NUM,  "NCHANS",
             &nChans,
             DTINFO(SS_INT32,0));

    mxFree(varname);
}
#endif


#ifdef  MATLAB_MEX_FILE    
#include "simulink.c"      
#else
#include "cg_sfun.h"       
#endif
