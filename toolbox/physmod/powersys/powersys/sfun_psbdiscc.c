/*
 * Power System Blockset discrete implementation of state-space system.
 * See simulink/src/sfuntmpl_doc.c
 *
 * By Gilbert Sybille (IREQ) and Roger Champagne (ETS)
 * Revision: 1.10.1.6 (ETS revision number)
 * Date: 2000-05-18 09:55:45-04
 * 
 * Updated by P.Brunelle, 13-feb-2001,29-01-2002
 * Copyright 1997-2002 TransEnergie Technologies Inc., under sublicense
 * from Hydro-Quebec, and The MathWorks, Inc.
 * $Revision: 1.1.6.1 $ 
 * File : sfun_psbdiscc.c
 */

#define S_FUNCTION_NAME sfun_psbdiscc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "mex.h"
#endif

#include <stdlib.h> /* for calloc, free */
#include <string.h> /* for memcpy */

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define A_PARAM(S)    ssGetSFcnParam(S, 0)
#define B_PARAM(S)    ssGetSFcnParam(S, 1)
#define C_PARAM(S)    ssGetSFcnParam(S, 2)
#define D_PARAM(S)    ssGetSFcnParam(S, 3)
#define XO_PARAM(S)   ssGetSFcnParam(S, 4)
#define RS_PARAM(S)   ssGetSFcnParam(S, 5)
#define TSW_PARAM(S)  ssGetSFcnParam(S, 6)
#define TS_PARAM(S)   ssGetSFcnParam(S, 7)
#define YISW_PARAM(S) ssGetSFcnParam(S, 8)

#define NPARAMS 9

/*====================*
 * S-function methods *
 *====================*/

#undef MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    Validate our parameters to verify they are okay.
 */
static void mdlCheckParameters(SimStruct *S) {}
#endif /* MDL_CHECK_PARAMETERS */

/* Function: mdlInitializeSizes =============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
   {
    int_T nStates  = mxGetM(A_PARAM(S));
    int_T nInputs  = mxGetN(B_PARAM(S));
    int_T nOutputs = mxGetM(C_PARAM(S));
    int_T nSwitch  = mxGetM(RS_PARAM(S));

    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */

#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    } 
#endif

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, nStates);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, nInputs+nSwitch);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, nOutputs);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 5);
    ssSetNumPWork(S, 16);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


/* Function: mdlInitializeSampleTimes =======================================
 *
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{  
    real_T *Ts = mxGetPr(TS_PARAM(S));
    ssSetSampleTime(S, 0, *Ts);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
#if defined(MDL_START)

static void mdlStart(SimStruct *S)
{
    real_T          *A         = NULL;
    real_T          *B         = NULL;
    real_T          *C         = NULL;
    real_T          *D         = NULL;
    real_T          *DxCol     = NULL;
    real_T          *BDcol     = NULL;
    real_T          *tmp1      = NULL;
    real_T          *tmp2      = NULL;
    real_T          *xtmp      = NULL;
    real_T          *yswitch   = NULL;
    int_T           *Chopper   = NULL;
    int_T           *vtsw      = NULL;
    int_T           *idxSwChng = NULL;
    int_T           *sw_state  = NULL;
    int_T           *swChng    = NULL;
    int_T           *IndicesSortiesSwitches = NULL;

    const int_T     nStates   = mxGetM(A_PARAM(S));
    const int_T     nInputs   = mxGetN(B_PARAM(S));
    const int_T     nOutputs  = mxGetM(C_PARAM(S));
    const int_T     nSwitch   = mxGetM(RS_PARAM(S));
    const int_T     nOutputs2 = nOutputs-nSwitch;
    
    /*
     * Allocate memory for this s-function.
     * If we don't need to allocate a certain variable, then it is left
     * as NULL as it was initialized. Be careful not to allocate zero
     * sized data since the behavior of this is undefined.
     */
    if (nStates > 0) {
        if ((A=(real_T*)calloc(nStates*nStates,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
    }

    if (nStates > 0 && nInputs > 0) {
        if ((B=(real_T*)calloc(nStates*nInputs,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
    }

    if (nOutputs > 0 && nStates > 0) {
        if ((C=(real_T*)calloc(nOutputs*nStates,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
    }

    if (nOutputs > 0 && nInputs > 0) {
        if ((D=(real_T*)calloc(nOutputs*nInputs,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
    }

    if (nOutputs > 0) {
        if ((DxCol=(real_T*)calloc(nOutputs,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
        
        if ((Chopper=(int_T*)calloc(nOutputs,sizeof(int_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }        
    }

    if (nStates > 0) {
        if ((BDcol=(real_T*)calloc(nStates,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }

        if ((tmp1=(real_T*)calloc(nStates,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
        
    }

    if (nInputs > 0) {
        if ((tmp2=(real_T*)calloc(nInputs,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
    }

    if (nSwitch > 0) {
        if ((vtsw=(int_T*)calloc(nSwitch,sizeof(int_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
        
        if ((sw_state=(int_T*)calloc(nSwitch,sizeof(int_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
    }

    if (nStates > 0) {
        if ((xtmp=(real_T*)calloc(nStates,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
    }

    if (nSwitch > 0) {
        if ((yswitch=(real_T*)calloc(nSwitch,sizeof(real_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }

        if ((idxSwChng=(int_T*)calloc(nSwitch,sizeof(int_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }

        if ((swChng=(int_T*)calloc(nSwitch,sizeof(int_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }
        
        if ((IndicesSortiesSwitches=(int_T*)calloc(nSwitch,sizeof(int_T))) == NULL) {
            ssSetErrorStatus(S,"Memory allocation error in mdlStart");
            return;
        }        
    }

    ssGetPWork(S)[0]=A;
    ssGetPWork(S)[1]=B;
    ssGetPWork(S)[2]=C;
    ssGetPWork(S)[3]=D;
    ssGetPWork(S)[4]=DxCol;
    ssGetPWork(S)[5]=BDcol;
    ssGetPWork(S)[6]=tmp1;
    ssGetPWork(S)[7]=tmp2;
    ssGetPWork(S)[8]=vtsw;
    ssGetPWork(S)[9]=sw_state;
    ssGetPWork(S)[10]=xtmp;
    ssGetPWork(S)[11]=yswitch;
    ssGetPWork(S)[12]=idxSwChng;
    ssGetPWork(S)[13]=swChng;
    ssGetPWork(S)[14]=Chopper;
    ssGetPWork(S)[15]=IndicesSortiesSwitches;

    ssSetIWorkValue(S,0,nStates);
    ssSetIWorkValue(S,1,nInputs);  
    ssSetIWorkValue(S,2,nOutputs);
    ssSetIWorkValue(S,3,nSwitch);
    ssSetIWorkValue(S,4,nOutputs2);
}
#endif /* MDL_START */

#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ===================================== */

static void mdlInitializeConditions(SimStruct *S)
{
    real_T           *xopr     = (real_T*)mxGetPr(XO_PARAM(S));    
    real_T           *tswpr    = (real_T*)mxGetPr(TSW_PARAM(S));
    real_T           *apr      = (real_T*)mxGetPr(A_PARAM(S));
    real_T           *bpr      = (real_T*)mxGetPr(B_PARAM(S));
    real_T           *cpr      = (real_T*)mxGetPr(C_PARAM(S));
    real_T           *dpr      = (real_T*)mxGetPr(D_PARAM(S));
    real_T           *rsw      = (real_T*)mxGetPr(RS_PARAM(S));
    real_T           *etas     = (real_T*)mxGetPr(YISW_PARAM(S));
    real_T           *x0       = (real_T*)ssGetRealDiscStates(S);

    real_T           *A        = (real_T*)ssGetPWork(S)[0]; 
    real_T           *B        = (real_T*)ssGetPWork(S)[1]; 
    real_T           *C        = (real_T*)ssGetPWork(S)[2]; 
    real_T           *D        = (real_T*)ssGetPWork(S)[3]; 
    int_T            *vtsw     = (int_T*) ssGetPWork(S)[8]; 
    int_T            *sw_state = (int_T*) ssGetPWork(S)[9]; 
    real_T           *yswitch  = (real_T*)ssGetPWork(S)[11];
    int_T            *Chopper  = (int_T*) ssGetPWork(S)[14];
    int_T            *IndicesSortiesSwitches  = (int_T*) ssGetPWork(S)[15];

    const int_T      nStates   = ssGetIWorkValue(S,0);
    const int_T      nInputs   = ssGetIWorkValue(S,1);
    const int_T      nOutputs  = ssGetIWorkValue(S,2);
    const int_T      nSwitch   = ssGetIWorkValue(S,3);
    const int_T      nOutputs2 = ssGetIWorkValue(S,4);

    int_T            i, j;

    memcpy(x0, xopr, nStates*sizeof(real_T));

    /* Copy and transpose A and B */
    for(i=0; i<nStates; i++) {
        for(j=0; j<nStates; j++)
            A[i*nStates + j] = apr[i + j*nStates];
        for(j=0; j<nInputs; j++)
            B[i*nInputs + j] = bpr[i + j*nStates];
    }

    /* Copy and transpose C and D */
    for(i=0; i<nOutputs; i++) {
        for(j=0; j<nStates; j++)
            C[i*nStates + j] = cpr[i + j*nOutputs];
        for(j=0; j<nInputs; j++)
            D[i*nInputs + j] = dpr[i + j*nOutputs];     
        /* Create the Chopper vector used in the Output calculations: ones(nOutputs,1);*/
        Chopper[i] = 1;
	}

    for (i=0; i<nSwitch; i++) {
        sw_state[i] = 0; 
        vtsw[i] = (int_T) tswpr[i];
        yswitch[i] = 1/rsw[i];
        IndicesSortiesSwitches[i] = etas[i]-1;  /* numeros de sortie qui mesure un courant de switch (-1 car indices en langage C)*/
    }
}

/* Function: mdlOutputs =====================================================
 * Abstract:
 *      y = Cx + Du 
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs     = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *y        = ssGetOutputPortRealSignal(S,0);
    real_T            *x        = ssGetRealDiscStates(S);

    const int_T       nStates   = ssGetIWorkValue(S,0);
    const int_T       nInputs   = ssGetIWorkValue(S,1);
    const int_T       nOutputs  = ssGetIWorkValue(S,2);
    const int_T       nSwitch   = ssGetIWorkValue(S,3);
    const int_T       nOutputs2 = ssGetIWorkValue(S,4);

    real_T            *A        = (real_T*)ssGetPWork(S)[0]; 
    real_T            *B        = (real_T*)ssGetPWork(S)[1]; 
    real_T            *C        = (real_T*)ssGetPWork(S)[2]; 
    real_T            *D        = (real_T*)ssGetPWork(S)[3]; 
    real_T            *DxCol    = (real_T*)ssGetPWork(S)[4]; 
    real_T            *BDcol    = (real_T*)ssGetPWork(S)[5]; 
    real_T            *tmp1     = (real_T*)ssGetPWork(S)[6]; 
    real_T            *tmp2     = (real_T*)ssGetPWork(S)[7]; 
    int_T             *vtsw     = (int_T*) ssGetPWork(S)[8]; 
    int_T             *sw_state = (int_T*) ssGetPWork(S)[9]; 
    real_T            *yswitch  = (real_T*)ssGetPWork(S)[11];
    int_T             *idxSwChng= (int_T*) ssGetPWork(S)[12];
    int_T             *swChng   = (int_T*) ssGetPWork(S)[13];
    int_T             *Chopper  = (int_T*) ssGetPWork(S)[14];
    int_T             *IndicesSortiesSwitches = (int_T*)ssGetPWork(S)[15]; 

    int_T             i, j, k, ki, indice, idx2, idx3, nSw, kSw, nbSwChng=0;
    real_T            accum, temp;

    /* Check if switches have changed states *******************************/ 
    for (j=0; j<nSwitch; j++) {
        if ((int_T)U(nInputs+j) != sw_state[j]) {
            swChng[j] = (int_T)U(nInputs+j) - sw_state[j];
            sw_state[j] = (int_T)U(nInputs+j);
            idxSwChng[nbSwChng++] = j;
        }
    }

    for(k=0; k<nbSwChng; k++) {
        nSw = idxSwChng[k];
        kSw = swChng[nSw];

        /* for each switch that changed status, set the Chopper parameter to 0(when open) or 1(when closed). */
        /* if the switch is closed the y[i] output will not be affected. */ 
        indice = IndicesSortiesSwitches[nSw]; /* indice = output that measure the switch current */ 
        if ( indice != -1 ) {                 /* look if y[indice] is measuring a switch current      */
            Chopper[indice] = sw_state[nSw];  /* means that y[indice] is measuring the sitch current  */
        }
        
        /* Compute DxCol ***************************************************/
        temp = 1/(1-D[nSw*(nInputs+1)]*yswitch[nSw]*kSw);
        for(i=0; i<nOutputs; i++)
            DxCol[i]=D[i*nInputs+nSw]*yswitch[nSw]*temp*kSw;
        DxCol[nSw] = temp;

        /* Compute BDcol ***************************************************/
        for(i=0; i<nStates; i++)
            BDcol[i]=B[i*nInputs + nSw]*yswitch[nSw]*kSw;

        /* Copy row nSw of C into tmp1 and zero it out in C */
        memcpy(tmp1, &C[nSw*nStates], nStates*sizeof(real_T));
        memset(&C[nSw*nStates], '\0', nStates*sizeof(real_T));

        /* Copy row nSw of D into tmp2 and zero it out in D */
        memcpy(tmp2, &D[nSw*nInputs], nInputs*sizeof(real_T));
        memset(&D[nSw*nInputs], '\0', nInputs*sizeof(real_T));

        /* C = C + DxCol * tmp1, D = D + DxCol * tmp2 **********************/
        for(i=0; i<nOutputs; i++) {
            idx2 = i*nStates;
            for(j=0; j<nStates; j++)
                C[idx2 + j] += DxCol[i] * tmp1[j];

            idx2 = i*nInputs;
            for(j=0; j<nInputs; j++)
                D[idx2 + j] += DxCol[i] * tmp2[j];
        }

        /* A = A + BdCol*C(nSw,:), B = B + BdCol*D(nSw,:) ******************/
        for(i=0; i<nStates; i++) {
            idx2 = i*nStates; idx3 = nSw*nStates;
            for(j=0; j<nStates; j++)
                A[idx2 + j] += BDcol[i] * C[idx3 + j];

            idx2 = i*nInputs; idx3 = nSw*nInputs;
            for(j=0; j<nInputs; j++)
                B[idx2 + j] += BDcol[i] * D[idx3 + j];
        }

    } /* end for k */

    /* Compute outputs: Vsw and misc outputs*/
    for (i=0; i<nOutputs; i++) {
        for (j=0, accum=0.0; j<nStates; j++)
            accum += C[i*nStates + j] * x[j];
        for (j=0; j<nInputs; j++)
            accum += D[i*nInputs + j] * U(j); 
        y[i] = accum * Chopper[i];   /* Chopper parameter will force zero if y[i] is a switch current (during open status) */;
    }
}

#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *      x(k+1) = Ax(k) + Bu(k)
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{ 
    InputRealPtrsType uPtrs    = ssGetInputPortRealSignalPtrs(S,0);
    real_T            *x       = ssGetRealDiscStates(S);

    const real_T      *A       = (real_T*)ssGetPWork(S)[0]; 
    const real_T      *B       = (real_T*)ssGetPWork(S)[1];
    real_T            *xtmp    = (real_T*)ssGetPWork(S)[10];

    const int_T       nStates  = ssGetIWorkValue(S,0);
    const int_T       nInputs  = ssGetIWorkValue(S,1);
    const int_T       nSwitch  = ssGetIWorkValue(S,3);

    int_T      i, j;
    real_T     accum;

    for (i=0; i<nStates; i++) {
        for (j=0, accum=0.0; j<nStates; j++)
            accum += A[i*nStates + j] * x[j];
        for (j=nSwitch; j<nInputs; j++)
            accum += B[i*nInputs + j] * U(j);
        xtmp[i] = accum;
    }

    memcpy(x, xtmp, nStates*sizeof(real_T));
}

/* Function: mdlTerminate ===================================================
 */
static void mdlTerminate(SimStruct *S)
{
    int_T i;

    for(i=0; i<ssGetNumPWork(S); i++)
        if(ssGetPWorkValue(S,i) != NULL)
            free(ssGetPWorkValue(S,i));
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
