/*
 * File: sfun_psbdqc.c
 *       -------------
 *
 *  SFUN_PSBDQ  is a SimPowerSystems S function used for  
 *              "phasor type" simulation of an electrical system 
 * 
 *  It is used for fast transient stability simulations
 *  involving machine dynamics.
 *
 *  Input and output signals:
 *  ------------------------
 *  The S function uses (2*NINPUT+NSWITCH) inputs where NINPUT
 *  is the number of inputs of the state-space system
 *  (voltage and current inputs)and NSWITCH is the number of
 *  switches.
 *  The first 2*NINPUT inputs are the real and imaginary parts of
 *  input phasors.
 *  The last NSWITCH inputs are the switch status (0 =open; 1=closed).
 *  The function  returns (2*NOUTPUT) signals
 *  (real and imaginary parts of output phasors).
 *  
 *
 *    Input arguments:
 *    ---------------
 *    t,x,u,flag   : Standard input arguments of an S function
 *    H            : Transfer fuction; Complex matrix(NOUTPUT,NINPUT)
 *                   with all switches open
 *    Rswitch      : Vector (NSWITCH) of switch resistances in the closed state
 *    InputsNonZero: Vector of input numbers which are not zero
 *                   during simulation
 *
 *   See also  POWER2SYS CIRC2SS
 *
 *   Author:    G. Sybille (IREQ) January 2001,
 *   C version from original "m" file: R. Roussel (IREQ) May 2003,
 *            
 *   Copyright 1997-2003 TransEnergie Technologies Inc., under sublicense
 *   from Hydro-Quebec, and The MathWorks, Inc.
 *   $Revision: 1.1.8.2 $
 *
 */

#ifndef NDEBUG
#include <stdio.h>
#endif

#include <string.h>
#include <math.h> 

/*
 * You must specify the S_FUNCTION_NAME as the name of your S-function.
 */

#define S_FUNCTION_NAME  sfun_psbdqc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define NPARAMS 3

#define H_IDX 0
#define H_PARAM(S) ssGetSFcnParam(S,H_IDX)
 
#define Rswitch_IDX 1
#define Rswitch_PARAM(S) ssGetSFcnParam(S,Rswitch_IDX)
 
#define InputsNonZero_IDX 2
#define InputsNonZero_PARAM(S) ssGetSFcnParam(S,InputsNonZero_IDX)

/*
 * Work vectors sizes and indexes definitions
 */

/* Integer work vector */

#define N_IWORKS        4

#define NINPUT          0
#define NOUTPUT         1
#define NSWITCH         2
#define NINZ            3

/* Real work vector */

#define N_RWORKS        6

#define R_WORK_0        0
#define R_WORK_1        1
#define R_WORK_2        2
#define R_WORK_3        3
#define R_WORK_4        4
#define R_WORK_5        5

/* Pointer work vector */

#define N_PWORKS        15

#define SW_STATES_IND   0
#define SW_STATES1_IND  1
#define SW_STATES2_IND  2
#define Y_SWITCHES_IND  3
#define I_MATRIX_IND    4
#define H_IND           5
#define H1_IND          6
#define H2_IND          7
#define HSW_IND         8
#define SWS_ON_IND      9
#define TMP_MAT_IND     10
#define MM_LU_IND       11
#define MM_PIV_IND      12
#define MM_X_IND        13
#define HINIT_IND       14

#define PS_CMULT_RE(X,Y) ( (X).re * (Y).re - (X).im * (Y).im)
#define PS_CMULT_IM(X,Y) ( (X).re * (Y).im + (X).im * (Y).re)
#define PS_CMULT_YCONJ_RE(X,Y) ( (X).re * (Y).re + (X).im * (Y).im)
#define PS_CMULT_YCONJ_IM(X,Y) (-(X).re * (Y).im + (X).im * (Y).re)
#define PS_CQABS(X) (fabs((X).re) + fabs((X).im))
#define PS_CMAGSQ(X) ((X).re * (X).re + (X).im * (X).im)
#define PS_CRECIP(B,C) { const real_T _s = 1.0 / PS_CQABS(B); real_T _d; creal_T _bs; _bs.re = (B).re * _s; _bs.im = (B).im * _s; _d = 1.0 / PS_CMAGSQ(_bs); (C).re = ( _s * _bs.re) * _d; (C).im = (-_s * _bs.im) * _d; }
#define PS_CDIV(A,B,C) { if ((B).im == 0.0) { (C).re = (A).re / (B).re; (C).im = (A).im / (B).re; } else { const real_T _s = 1.0 / PS_CQABS(B); real_T _d; creal_T _as, _bs; _as.re = (A).re * _s; _as.im = (A).im * _s; _bs.re = (B).re * _s; _bs.im = (B).im * _s; _d = 1.0 / PS_CMAGSQ(_bs); (C).re = PS_CMULT_YCONJ_RE(_as, _bs) * _d; (C).im = PS_CMULT_YCONJ_IM(_as, _bs) * _d; } }

#ifndef TRUE
# define TRUE (1)
#endif
#ifndef FALSE
# define FALSE (0)
#endif


static
/* Function: PS_BackwardSubstitutionCC_Dbl =====================================
 * Abstract: Backward substitution: Solving Ux=b 
 *           U: complex, double
 *           b: complex, double
 *           U is an upper (or unit upper) triangular full matrix.
 *           The entries in the lower triangle are ignored.
 *           U is a NxN matrix
 *           X is a NxP matrix
 *           B is a NxP matrix
 */
void PS_BackwardSubstitutionCC_Dbl(creal_T   *pU,
                                   creal_T   *pb,
                                   creal_T   *x,
                                   int_T     N,
                                   int_T     P,
                                   boolean_T unit_upper)
{
    int_T i, k;

    for(k=P; k>0; k--) {
        creal_T *pUcol = pU;
        for(i=0; i<N; i++) {
            creal_T *xj = x + k*N-1;
            creal_T s = {0.0, 0.0};
            creal_T *pUrow = pUcol--;

            {
                int_T j = i;
                while(j-- > 0) {
                    /* Compute: s += L * xj, in complex */
                    creal_T cU = *pUrow;
                    pUrow -= N;

                    s.re += PS_CMULT_RE(cU, *xj);
                    s.im += PS_CMULT_IM(cU, *xj);
                    xj--;
                }
            }

            if (unit_upper) {
                creal_T cb = *pb--;
                xj->re = cb.re - s.re;
                (xj--)->im = cb.im - s.im;
            } else {
                /* Complex divide: *xj = cdiff / *cL */
                creal_T cb = *pb--;
                creal_T cU = *pUrow;
                creal_T cdiff;
                cdiff.re = cb.re - s.re;
                cdiff.im = cb.im - s.im;

                PS_CDIV(cdiff, cU, *xj);
                xj--;
            }
        }
    }
}

static
/* Function: PS_ForwardSubstitutionCC_Dbl ======================================
 * Abstract: Forward substitution: solving Lx=b 
 *           L: Complex, double
 *           b: Complex, double
 *           L is a lower (or unit lower) triangular full matrix.
 *           The entries in the upper triangle are ignored.
 *           L is a NxN matrix
 *           X is a NxP matrix
 *           B is a NxP matrix
 */
void PS_ForwardSubstitutionCC_Dbl(creal_T   *pL,
                                  creal_T   *pb,
                                  creal_T   *x,
                                  int_T     N,
                                  int_T     P,
                                  int32_T   *piv,
                                  boolean_T unit_lower)
{

    int_T i, k;

    for (k=0; k<P; k++) {
        creal_T *pLcol = pL;
        for(i=0; i<N; i++) {
            creal_T *xj = x + k*N;
            creal_T s = {0.0, 0.0};
            creal_T *pLrow = pLcol++;

            {
                int_T j = i;
                while(j-- > 0) {
                    /* Compute: s += L * xj, in complex */
                    creal_T cL = *pLrow;
                    pLrow += N;

                    s.re += PS_CMULT_RE(cL, *xj);
                    s.im += PS_CMULT_IM(cL, *xj);
                    xj++;
                }
            }

            if (unit_lower) {
                creal_T cb = *(pb+piv[i]);
                xj->re = cb.re - s.re;
                (xj++)->im = cb.im - s.im;
            } else {
                /* Complex divide: *xj = cdiff / *cL */
                creal_T cb = *(pb+piv[i]);
                creal_T cL = *pLrow;
                creal_T cdiff;
                cdiff.re = cb.re - s.re;
                cdiff.im = cb.im - s.im;

                PS_CDIV(cdiff, cL, *xj);
                xj++;
            }
        }
        pb += N;
    }
}

static
/* Function: PS_lu_cplx ========================================================
 * Abstract: A is complex.
 *
 */
void PS_lu_cplx(creal_T *A,     /* in and out                         */
                const int_T n,  /* number or rows = number of columns */
                int32_T *piv)   /* pivote vector                      */
{
    int_T k;

    /* initialize row-pivot indices: */
    for (k = 0; k < n; k++) {
        piv[k] = k;
    }

    /* Loop over each column: */
    for (k = 0; k < n; k++) {
        const int_T kn = k*n;
        int_T p = k;

        /*
         * Scan the lower triangular part of this column only
         * Record row of largest value
         */
        {
            int_T i;
            real_T Amax = PS_CQABS(A[p+kn]);     /* approx mag-squared value */

            for (i = k+1; i < n; i++) {
                real_T q = PS_CMAGSQ(A[i+kn]);
                if (q > Amax) {p = i; Amax = q;}
            }
        }

        /* swap rows if required */
        if (p != k) {
            int_T j;
            for (j = 0; j < n; j++) {
                creal_T c;
                const int_T pjn = p+j*n;
                const int_T kjn = k+j*n;

                c = A[pjn];
                A[pjn] = A[kjn];
                A[kjn] = c;
            }

            /* Swap pivot row indices */
            {
                int32_T t = piv[p]; piv[p] = piv[k]; piv[k] = t;
            }
        }

        /* column reduction */
        {
            creal_T Adiag;
            int_T i, j;

            Adiag = A[k+kn];

            if (!((Adiag.re == 0.0) && (Adiag.im == 0.0))) {
                /* non-zero diagonal entry */
                /*
                 * divide lower triangular part of column by max
                 * First, form reciprocal of Adiag:
                 *	    recip = conj(Adiag)/(|Adiag|^2)
                 */
                PS_CRECIP(Adiag, Adiag);

                /* Multiply: A[i+kn] *= Adiag: */
                for (i = k+1; i < n; i++) {
                    real_T t = PS_CMULT_RE(A[i+kn], Adiag);
                    A[i+kn].im = PS_CMULT_IM(A[i+kn], Adiag);
                    A[i+kn].re = t;
                }

                /* subtract multiple of column from remaining columns */
                for (j = k+1; j < n; j++) {
                    int_T j_n = j*n;
                    for (i = k+1; i < n; i++) {
                        /* Multiply: c = A[i+kn] * A[k+j_n]: */
                        creal_T c;
                        c.re = PS_CMULT_RE(A[i+kn], A[k+j_n]);
                        c.im = PS_CMULT_IM(A[i+kn], A[k+j_n]);

                        /* Subtract A[i+j_n] -= A[i+kn]*A[k+j_n]: */
                        A[i+j_n].re -= c.re;
                        A[i+j_n].im -= c.im;
                    }
                }
            }
        }
    }
}

static
/* Function: PS_MatDivCC_Dbl ===================================================
 * Abstract: 
 *           Calculate inv(In1)*In2 using LU factorization.
 */
void PS_MatDivCC_Dbl(creal_T   *Out,
                     creal_T   *In1,
                     creal_T   *In2,
                     creal_T   *lu,
                     int32_T   *piv,
                     creal_T   *x,
                     const int dims[3])
{
    int N = dims[0];
    int N2 = N * N;
    int P = dims[2];
    int NP = N * P;
    const boolean_T unit_upper = FALSE;
    const boolean_T unit_lower = TRUE;

    (void)memcpy(lu, In1, N2*sizeof(real_T)*2);

    PS_lu_cplx(lu, N, piv);

    PS_ForwardSubstitutionCC_Dbl(lu, In2, x, N, P, piv,unit_lower);

    PS_BackwardSubstitutionCC_Dbl(lu + N2 -1, x + NP -1, Out, N, P, unit_upper);
}

static
/*
 * Function: PS_MatMultCC_Dbl
 * Abstract:
 *      2-input matrix multiply function
 *      Input 1: Complex, double-precision
 *      Input 2: Complex, double-precision
 */
void PS_MatMultCC_Dbl(creal_T       *y,
                      const creal_T *A,
                      const creal_T *B,
                      const int     dims[3])
{
    int k;
    for(k=dims[2]; k-- > 0; ) {
        const creal_T *A1 = A;
        int i;
        for(i=dims[0]; i-- > 0; ) {
            const creal_T *A2 = A1++;
            const creal_T *B1 = B;
            creal_T acc;
            int j;
            acc.re = (real_T)0.0;
            acc.im = (real_T)0.0;
            for(j=dims[1]; j-- > 0; ) {

                creal_T A2_val = *A2;
                creal_T B1_val = *B1++;
                acc.re += PS_CMULT_RE(A2_val, B1_val);
                acc.im += PS_CMULT_IM(A2_val, B1_val);
                A2 += dims[0];
            }
            *y++ = acc;
        }
        B += dims[1];
    }
}

/*====================*
 * S-function methods *
 *====================*/


/*=====================================*
 * Configuration and execution methods *
 *=====================================*/

/* Function: mdlInitializeSizes ===============================================
 */

static void mdlInitializeSizes(SimStruct *S)
{
    int_T nInputs      = mxGetN(H_PARAM(S));
    int_T nOutputs     = mxGetM(H_PARAM(S));
    int_T nSwitch      = mxGetM(Rswitch_PARAM(S));

    int_T nInputPorts  = 1;  /* number of input ports  */
    int_T nOutputPorts = 1;  /* number of output ports */
    int_T needsInput   = 1;  /* direct feed through    */
    
    int_T inputPortWidth;
    int_T outputPortWidth;

    int_T inputPortIdx  = 0;
    int_T outputPortIdx = 0;
    
    inputPortWidth = (2 * nInputs) + nSwitch;
    outputPortWidth = 2 * nOutputs;

    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */

    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /*
         * If the the number of expected input parameters is not equal
         * to the number of parameters entered in the dialog box return.
         * Simulink will generate an error indicating that there is a
         * parameter mismatch.
         */
        return;
    }

    ssSetSFcnParamTunable(S, H_IDX, false);
    ssSetSFcnParamTunable(S, Rswitch_IDX, false);
    ssSetSFcnParamTunable(S, InputsNonZero_IDX, false);


    /* Register the number and type of states the S-Function uses */

    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */


    /*
     * Configure the input ports. First set the number of input ports. 
     */
    if (!ssSetNumInputPorts(S, nInputPorts))
        return;    

    if(!ssSetInputPortVectorDimension(S, inputPortIdx, inputPortWidth))
        return;

    ssSetInputPortDirectFeedThrough(S, inputPortIdx, needsInput);

    /*
     * Configure the output ports. First set the number of output ports.
     */
    if (!ssSetNumOutputPorts(S, nOutputPorts))
        return;

    /*
     * Set output port dimensions for each output port index starting at 0.
     * See comments for setting input port dimensions.
     */
    if(!ssSetOutputPortVectorDimension(S,outputPortIdx,outputPortWidth))
        return;

    /*
     * Set the number of sample times.
     */

    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */

    /*
     * Set size of the work vectors.
     *
     * Real work vector
     *
     *  [0]     Work value 0
     *  [1]     Work value 1
     *  [2]     Work value 2
     *  [3]     Work value 3
     *  [4]     Work value 4
     *  [5]     Work value 5
     *
     * Integer work vector
     *
     *  [0]     Number of inputs
     *  [1]     Number of outputs
     *  [2]     Number of switches
     *  [3]     Number of non zero inputs
     *
     * Pointer work vector
     *
     *  [0]     Switch states
     *  [1]     Switch states 1
     *  [2]     Switch states 2
     *  [3]     Yswicth
     *  [4]     Identity matrix
     *  [5]     H
     *  [6]     H1
     *  [7]     H2
     *  [8]     Hsw
     *  [9]     SWS_ON
     *  [10]    TMP_MAT
     *  [11]    MM_LU
     *  [12]    MM_PIV
     *  [13]    MM_X
     *  [14]    HINIT_IND
     */
    ssSetNumRWork(         S, N_RWORKS);	/* number of real work */
						/* vector elements   */
    ssSetNumIWork(         S, N_IWORKS);	/* number of integer */
    						/* work vector elements*/
    ssSetNumPWork(         S, N_PWORKS);	/* number of pointer work */
    						/* vector elements*/
    ssSetNumModes(         S, 0);		/* number of mode work */
    						/* vector elements   */
    ssSetNumNonsampledZCs( S, 0);		/* number of nonsampled */
    						/* zero crossings   */

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);

} /* end mdlInitializeSizes */


/* Function: mdlInitializeSampleTimes =========================================
 *
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
#ifndef NDEBUG
    printf("mdlInitializeSampleTimes:\n");
#endif

    /* Register one pair for each sample time */
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

} /* end mdlInitializeSampleTimes */

#define MDL_START

  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution.
   */
  static void mdlStart(SimStruct *S)
  {
    int     i;
    int     j;
    int     k;

    int_T   nInputs      = mxGetN(H_PARAM(S));
    int_T   nOutputs     = mxGetM(H_PARAM(S));
    int_T   nSwitch      = mxGetM(Rswitch_PARAM(S));
    int_T   inzLen       = mxGetN(InputsNonZero_PARAM(S));
    real_T  *RSwitches   = (real_T *)mxGetPr(Rswitch_PARAM(S));
    real_T  *HinitR      = (real_T *)mxGetPr(H_PARAM(S));
    real_T  *HinitI      = (real_T *)mxGetPi(H_PARAM(S));
    void    **pWork      = NULL;

    int     *swStates    = NULL;
    int     *swStates1   = NULL;
    int     *swStates2   = NULL;
    int     *swsOn       = NULL;

    real_T  *I           = NULL;
    real_T  *Ysw         = NULL;
    
    creal_T *Hinit       = NULL;
    creal_T *H           = NULL;
    creal_T *H1          = NULL;
    creal_T *H2          = NULL;
    creal_T *Hsw         = NULL;
    creal_T *tmpMat      = NULL;
    creal_T *mm_lu       = NULL;
    creal_T *mm_x        = NULL;
    int32_T *mm_piv      = NULL;

#ifndef NDEBUG    
    printf("mdlStart:\n");
#endif

    ssSetIWorkValue(S,NINPUT,nInputs);
    ssSetIWorkValue(S,NOUTPUT,nOutputs);
    ssSetIWorkValue(S,NSWITCH,nSwitch);
    ssSetIWorkValue(S,NINZ,inzLen);

    /* Allocate memory for work arrays */
          
    pWork = (void **)calloc(N_PWORKS, sizeof(void *));

    if(pWork == NULL)
        goto allocError;

    if(nSwitch > 0)
    {
        swStates  = (int *)malloc(nSwitch * sizeof(int));
        swStates1 = (int *)malloc(nSwitch * sizeof(int));
        swStates2 = (int *)malloc(nSwitch * sizeof(int));
        swsOn     = (int *)calloc(nSwitch, sizeof(int));
        Ysw       = (real_T *)malloc(nSwitch * sizeof(real_T));

        if(swStates == NULL ||
           swStates1 == NULL ||
           swStates2 == NULL ||
           swsOn == NULL ||
           Ysw == NULL)
            goto allocError;
    }


    /* Initialize switches states and admittances */

    for(i = 0; i < nSwitch; ++i)
    {
        swStates2[i] = swStates1[i] = swStates[i] = -1;
        Ysw[i] = 1.0/RSwitches[i];
    }

    H      = (creal_T *)malloc(nInputs * nOutputs * sizeof(creal_T));

    if(H == NULL)
        goto allocError;

    if(nSwitch > 0)
    {
        I      = (real_T *)calloc(nOutputs * nOutputs, sizeof(real_T));
        Hinit  = (creal_T *)malloc(nInputs * nOutputs * sizeof(creal_T));
        H1     = (creal_T *)malloc(nInputs * nOutputs * sizeof(creal_T));
        H2     = (creal_T *)malloc(nInputs * nOutputs * sizeof(creal_T));
        Hsw    = (creal_T *)malloc(nInputs * nOutputs * sizeof(creal_T));
        tmpMat = (creal_T *)calloc(nOutputs * nOutputs, sizeof(creal_T));
        mm_lu  = (creal_T *)calloc(nOutputs * nOutputs, sizeof(creal_T));
        mm_x   = (creal_T *)calloc(nInputs * nOutputs, sizeof(creal_T));
        mm_piv = (int32_T *)calloc(nOutputs, sizeof(int32_T));

        if(I == NULL ||
           Hinit == NULL ||
           H1 == NULL ||
           H2 == NULL ||
           Hsw == NULL ||
           tmpMat == NULL ||
           mm_lu == NULL ||
           mm_x == NULL ||
           mm_piv == NULL)
            goto allocError;

        for(j = 0; j < nOutputs; ++j)
            I[(j * nOutputs) + j] = 1.0;

    }
 


    /* Initialize past states matrixes */

    if(HinitR != NULL)
    {
        for(i = 0; i < nOutputs * nInputs ; ++i)
            H[i].re = HinitR[i];
    }
    else
    {
        for(i = 0; i < nOutputs * nInputs ; ++i)
            H[i].re = 0.0;
    }
    
    if(HinitI != NULL)
    {
        for(i = 0; i < nOutputs * nInputs ; ++i)
            H[i].im = HinitI[i];
    }
    else
    {
        for(i = 0; i < nOutputs * nInputs ; ++i)
            H[i].im = 0.0;
    }
    
    if(nSwitch > 0)
    {
        memcpy((void*)Hinit,(void*)H, nInputs * nOutputs * sizeof(creal_T));
        memcpy((void*)H1,(void*)H, nInputs * nOutputs * sizeof(creal_T));
        memcpy((void*)H2,(void*)H, nInputs * nOutputs * sizeof(creal_T));
    }

    pWork[SW_STATES_IND]  = (void *)swStates;
    pWork[SW_STATES1_IND] = (void *)swStates1;
    pWork[SW_STATES2_IND] = (void *)swStates2;
    pWork[SWS_ON_IND]     = (void *)swsOn;
    pWork[Y_SWITCHES_IND] = (void *)Ysw;
    pWork[I_MATRIX_IND]   = (void *)I;
    pWork[H_IND]          = (void *)H;
    pWork[H1_IND]         = (void *)H1;
    pWork[H2_IND]         = (void *)H2;
    pWork[HSW_IND]        = (void *)Hsw;
    pWork[TMP_MAT_IND]    = (void *)tmpMat;
    pWork[MM_LU_IND]      = (void *)mm_lu;
    pWork[MM_PIV_IND]     = (void *)mm_piv;
    pWork[MM_X_IND]       = (void *)mm_x;
    pWork[HINIT_IND]      = (void *)Hinit;

    ssGetPWork(S)         = pWork;

    return;

allocError:

    ssSetErrorStatus(S,"Memory allocation error in \"mdlStart\"!");
  }


#define U0(element) (*(uPtrs0)[element])  /* Pointer to Input Port0 */

/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    void    **pWork     = (void **)ssGetPWork(S);

    int     i, j, k;
    int     ir;
    int     ic;
    int     iic;
    int     nSwitches   = ssGetIWorkValue(S, NSWITCH);
    int     nInputs     = ssGetIWorkValue(S, NINPUT);
    int     nOutputs    = ssGetIWorkValue(S, NOUTPUT);
    int_T   inzLen      = ssGetIWorkValue(S, NINZ);
    real_T  *inz        = (real_T *)mxGetData(InputsNonZero_PARAM(S));
    int     *swStates   = (int *)pWork[SW_STATES_IND];
    int     *swStates1  = (int *)pWork[SW_STATES1_IND];
    int     *swStates2  = (int *)pWork[SW_STATES2_IND];
    int     *swsOn      = (int *)pWork[SWS_ON_IND];

    real_T  *I          = (real_T*)pWork[I_MATRIX_IND];
    real_T  *Ysw        = (real_T *)pWork[Y_SWITCHES_IND];
    creal_T *H          = (creal_T *)pWork[H_IND];
    creal_T *H1         = (creal_T *)pWork[H1_IND];
    creal_T *H2         = (creal_T *)pWork[H2_IND];
    creal_T *Hsw        = (creal_T *)pWork[HSW_IND];
    creal_T *tmpMat     = (creal_T *)pWork[TMP_MAT_IND];

    creal_T *Hinit      = (creal_T *)pWork[HINIT_IND];

    InputRealPtrsType
            uPtrs0      = (InputRealPtrsType)ssGetInputPortRealSignalPtrs(S,0);
    real_T  *y          = ssGetOutputPortRealSignal(S,0);
#ifndef NDEBUG

    static int firstTime = 1;
    
    if(firstTime)
    {
        firstTime = 0;

        printf("mdlOutputs:\n");
    }
#endif


    /* Determine if switches had changed states */

    for(i = 0, j = 2 * nInputs;
        i < nSwitches && U0(j) == swStates[i];
        ++i, ++j);

    if(i < nSwitches)
    {
        /* One or more switches changed state */

        int nSwitchOn = 0;

        /* Count "On" switches */

        for(i = 0, j = 2 * nInputs; i < nSwitches; ++i, ++j)
        {
            if((swStates[i] = (int)U0(j)) == 1)
                swsOn[nSwitchOn++] = i;
        }

        if(nSwitchOn == 0)
        {
            /* No switches are "on" */
            /* Use initial H matrix */

            memcpy((void *)H, (void *)Hinit, nInputs*nOutputs*sizeof(creal_T));
        }
        else
        {
            /* Some switches are "on" */
            /* Check for a known past pattern */

            if(memcmp((void *)swStates, (void *)swStates1,
                      nSwitches*sizeof(int)) == 0)
            {
                /* Use H1 */
                
                memcpy((void *)H, (void *)H1, nInputs*nOutputs*sizeof(creal_T));
            }
            else if(memcmp((void *)swStates, (void *)swStates2,
                           nSwitches*sizeof(int)) == 0)
            {
                /* Use H2 */

                memcpy((void *)H, (void *)H2, nInputs*nOutputs*sizeof(creal_T));
            }
            else
            {
                /*
                 * New configuration, calculate H
                 *
                 * H = inv(I - Hinit*Hsw)*Hinit
                 *
                 */

                int noSw;
                int dims_1[3];
                int dims_2[3];

                creal_T *mm_lu = (creal_T *)pWork[MM_LU_IND];
                creal_T *mm_x = (creal_T *)pWork[MM_X_IND];
                int32_T *mm_piv = (int32_T *)pWork[MM_PIV_IND];

                dims_1[0] = nOutputs;
                dims_1[1] = nInputs;
                dims_1[2] = nOutputs;
                
                dims_2[0] = nOutputs;
                dims_2[1] = nOutputs;
                dims_2[2] = nInputs;


                /* First, initialize Hsw */
                
                memset((void *)Hsw, 0, nInputs*nOutputs*sizeof(creal_T));

                for(i = 0; i < nSwitchOn; ++i)
                {
                    noSw = swsOn[i];
                    
                    Hsw[(noSw*nInputs) + noSw].re = Ysw[noSw];
                }

                /* Product: tmpMat <- Hinit*Hsw */
                {
                    PS_MatMultCC_Dbl((creal_T *)&tmpMat[0],
                                     (creal_T *)&Hinit[0],
                                     (creal_T *)&Hsw[0], &dims_1[0]);
                }


                /* Sum: tmpMat <- I-tmpMat (tmpMat = H*Hsw) */
                {
                    int_T i1;

                    for (i1=0; i1 < nOutputs*nOutputs ; i1++)
                    {
                        tmpMat[i1].re = I[i1] - tmpMat[i1].re;
                        tmpMat[i1].im = - tmpMat[i1].im;
                    }
                }

                /*
                 * Matrix inverse an multiply:
                 *     H <- inv(tmpMat)*Hinit  (tmpMat = I-Hinit*Hsw)
                 */

                {
 
                    PS_MatDivCC_Dbl((creal_T *)&H[0], (creal_T *)&tmpMat[0],
                                    (creal_T *)&Hinit[0], mm_lu, mm_piv, mm_x,
                                    &dims_2[0]);
                }

                /* Update past switch states and H matrixes */

                memcpy((void *)swStates2, (void *)swStates1,
                       nSwitches*sizeof(int));
                memcpy((void *)swStates1, (void *)swStates,
                       nSwitches*sizeof(int));

                memcpy((void *)H2, (void *)H1,
                       nInputs*nOutputs*sizeof(creal_T));
                memcpy((void *)H1, (void *)H, nInputs*nOutputs*sizeof(creal_T));
            }
        }
    }

    /*
     * Calculate outputs using non zero inputs
     *
     *    Yr = H.re*Ur - H.im*Ui
     *    Yi = H.re+Ui + H.im*Ur
     */

    /* Initialize outputs to 0.0 */

    memset((void *)y, 0, 2 * nOutputs * sizeof(real_T));

    /* Ouputs only for non zero inputs */

    for(ir = 0; ir < nOutputs; ++ir)
    {
        for(j = 0; j < inzLen; ++j)
        {
            ic = ((int)inz[j]) - 1;
            y[ir] += (H[ic*nOutputs + ir].re * U0(ic)) -
                     (H[ic*nOutputs + ir].im * U0(ic + nInputs));
            y[ir + nOutputs] += (H[ic*nOutputs + ir].re * U0(ic + nInputs)) +
                                (H[ic*nOutputs + ir].im * U0(ic));
        }
    }

} /* end mdlOutputs */



/* Function: mdlTerminate =====================================================
 */
static void mdlTerminate(SimStruct *S)
{
    int i;

#ifndef NDEBUG
    printf("mdlTerminate:\n");
#endif

    for (i = 0; i<ssGetNumPWork(S); i++)
    {
        if (ssGetPWorkValue(S,i) != NULL)
        {
            free(ssGetPWorkValue(S,i));
        }
    }

    if(ssGetPWork(S) != NULL)
        free(ssGetPWork(S));
}


#undef MDL_RTW  /* Change to #undef to remove function */
#if defined(MDL_RTW) && defined(MATLAB_MEX_FILE)
  /* Function: mdlRTW =========================================================
   * Abstract:
   *
   *    This function is called when the Real-Time Workshop is generating
   *    the model.rtw file. In this method, you can call the following
   *    functions which add fields to the model.rtw file.
   *
   *    1) The following creates Parameter records for your S-functions.
   *       nParams is the number of tunable S-function parameters.
   *
   *       if ( !ssWriteRTWParameters(S, nParams,
   *
   *                                  SSWRITE_VALUE_[type],paramName,stringInfo,
   *                                  [type specific arguments below]
   *
   *                                 ) ) {
   *           return; (error reporting will be handled by SL)
   *       }
   *
   *       Where SSWRITE_VALUE_[type] can be one of the following groupings
   *       (and you must have "nParams" such groupings):
   *
   *         SSWRITE_VALUE_VECT,
   *           const char_T *paramName,
   *           const char_T *stringInfo,
   *           const real_T *valueVect,
   *           int_T        vectLen
   *
   *         SSWRITE_VALUE_2DMAT,
   *           const char_T *paramName,
   *           const char_T *stringInfo,
   *           const real_T *valueMat,
   *           int_T        nRows,
   *           int_T        nCols
   *
   *         SSWRITE_VALUE_DTYPE_VECT,
   *           const char_T   *paramName,
   *           const char_T   *stringInfo,
   *           const void     *valueVect,
   *           int_T          vectLen,
   *           int_T          dtInfo
   *
   *         SSWRITE_VALUE_DTYPE_2DMAT,
   *           const char_T   *paramName,
   *           const char_T   *stringInfo,
   *           const void     *valueMat,
   *           int_T          nRows,
   *           int_T          nCols,
   *           int_T          dtInfo
   *
   *         SSWRITE_VALUE_DTYPE_ML_VECT,
   *           const char_T   *paramName,
   *           const char_T   *stringInfo,
   *           const void     *rValueVect,
   *           const void     *iValueVect,
   *           int_T          vectLen,
   *           int_T          dtInfo
   *
   *         SSWRITE_VALUE_DTYPE_ML_2DMAT,
   *           const char_T   *paramName,
   *           const char_T   *stringInfo,
   *           const void     *rValueMat,
   *           const void     *iValueMat,
   *           int_T          nRows,
   *           int_T          nCols,
   *           int_T          dtInfo
   *
   *       Notes:
   *       1. nParams is an integer and stringInfo is a string describing
   *          generalinformation about the parameter such as how it was derived.
   *       2. The last argument to this function, dtInfo, is obtained from the
   *          DTINFO macro (defined in simstruc.h) as:
   *                 dtInfo = DTINFO(dataTypeId, isComplexSignal);
   *          where dataTypeId is the data type id and isComplexSignal is a
   *          boolean value specifying whether the parameter is complex.
   *
   *       See simulink/include/simulink.c for the definition (implementation)
   *       of this function and simulink/src/sfun_multiport.c for an example
   *       of using this function.
   *
   *    2) The following creates SFcnParameterSetting record for S-functions
   *       (these can be derived from the non-tunable S-function parameters).
   *
   *       if ( !ssWriteRTWParamSettings(S, nParamSettings,
   *
   *                                     SSWRITE_VALUE_[whatever], settingName,
   *                                     [type specific arguments below]
   *
   *                                    ) ) {
   *           return; (error reporting will be handled by SL)
   *       }
   *
   *       Where SSWRITE_VALUE_[type] can be one of the following groupings
   *       (and you must have "nParamSettings" such groupings):
   *       Also, the examples in the right hand column below show how the
   *       ParamSetting appears in the .rtw file
   *
   *         SSWRITE_VALUE_STR,              - Used to write (un)quoted strings
   *           const char_T *settingName,      example:
   *           const char_T *value,              Country      USA
   *
   *         SSWRITE_VALUE_QSTR,             - Used to write quoted strings
   *           const char_T *settingName,      example:
   *           const char_T *value,              Country      "U.S.A"
   *
   *         SSWRITE_VALUE_VECT_STR,         - Used to write vector of strings
   *           const char_T *settingName,      example:
   *           const char_T *value,              Countries    ["USA", "Mexico"]
   *           int_T        nItemsInVect
   *
   *         SSWRITE_VALUE_NUM,              - Used to write numbers
   *           const char_T *settingName,      example:
   *           const real_T value                 NumCountries  2
   *
   *
   *         SSWRITE_VALUE_VECT,             - Used to write numeric vectors
   *           const char_T *settingName,      example:
   *           const real_T *settingValue,       PopInMil        [300, 100]
   *           int_T        vectLen
   *
   *         SSWRITE_VALUE_2DMAT,            - Used to write 2D matrices
   *           const char_T *settingName,      example:
   *           const real_T *settingValue,       PopInMilBySex  Matrix(2,2)
   *           int_T        nRows,                   [[170, 130],[60, 40]]
   *           int_T        nCols
   *
   *         SSWRITE_VALUE_DTYPE_NUM,        - Used to write numeric vectors
   *           const char_T   *settingName,    example: int8 Num 3+4i
   *           const void     *settingValue,   written as: [3+4i]
   *           int_T          dtInfo
   *
   *
   *         SSWRITE_VALUE_DTYPE_VECT,       - Used to write data typed vectors
   *           const char_T   *settingName,    example: int8 CArray [1+2i 3+4i]
   *           const void     *settingValue,   written as:
   *           int_T          vectLen             CArray  [1+2i, 3+4i]
   *           int_T          dtInfo
   *
   *
   *         SSWRITE_VALUE_DTYPE_2DMAT,      - Used to write data typed 2D
   *           const char_T   *settingName     matrices
   *           const void     *settingValue,   example:
   *           int_T          nRow ,            int8 CMatrix  [1+2i 3+4i; 5 6]
   *           int_T          nCols,            written as:
   *           int_T          dtInfo               CMatrix         Matrix(2,2)
   *                                                [[1+2i, 3+4i]; [5+0i, 6+0i]]
   *
   *
   *         SSWRITE_VALUE_DTYPE_ML_VECT,    - Used to write complex matlab data
   *           const char_T   *settingName,    typed vectors example:
   *           const void     *settingRValue,  example: int8 CArray [1+2i 3+4i]
   *           const void     *settingIValue,      settingRValue: [1 3]
   *           int_T          vectLen              settingIValue: [2 4]
   *           int_T          dtInfo
   *                                             written as:
   *                                                CArray    [1+2i, 3+4i]
   *
   *         SSWRITE_VALUE_DTYPE_ML_2DMAT,   - Used to write matlab complex
   *           const char_T   *settingName,    data typed 2D matrices
   *           const void     *settingRValue,  example
   *           const void     *settingIValue,      int8 CMatrix [1+2i 3+4i; 5 6]
   *           int_T          nRows                settingRValue: [1 5 3 6]
   *           int_T          nCols,               settingIValue: [2 0 4 0]
   *           int_T          dtInfo
   *                                              written as:
   *                                              CMatrix         Matrix(2,2)
   *                                                [[1+2i, 3+4i]; [5+0i, 6+0i]]
   *
   *       Note, The examples above show how the ParamSetting is written out
   *       to the .rtw file
   *
   *       See simulink/include/simulink.c for the definition (implementation)
   *       of this function and simulink/src/sfun_multiport.c for an example
   *       of using this function.
   *
   *    3) The following creates the work vector records for S-functions
   *
   *       if (!ssWriteRTWWorkVect(S, vectName, nNames,
   *
   *                            name, size,   (must have nNames of these pairs)
   *                                 :
   *                           ) ) {
   *           return;  (error reporting will be handled by SL)
   *       }
   *
   *       Notes:
   *         a) vectName must be either "RWork", "IWork" or "PWork"
   *         b) nNames is an int_T (integer), name is a const char_T* (const
   *            char pointer) and size is int_T, and there must be nNames number
   *            of [name, size] pairs passed to the function.
   *         b) intSize1+intSize2+ ... +intSizeN = ssGetNum<vectName>(S)
   *            Recall that you would have to set ssSetNum<vectName>(S)
   *            in one of the initialization functions (mdlInitializeSizes
   *            or mdlSetWorkVectorWidths).
   *
   *       See simulink/include/simulink.c for the definition (implementation)
   *       of this function, and ... no example yet :(
   *
   *    4) Finally the following functions/macros give you the ability to write
   *       arbitrary strings and [name, value] pairs directly into the .rtw
   *       file.
   *
   *       if (!ssWriteRTWStr(S, const_char_*_string)) {
   *          return;
   *       }
   *
   *       if (!ssWriteRTWStrParam(S, const_char_*_name, const_char_*_value)) {
   *          return;
   *       }
   *
   *       if (!ssWriteRTWScalarParam(S, const_char_*_name, 
   *                                  const_void_*_value,
   *                                  DTypeId_dtypeId)) {
   *          return;
   *       }
   *
   *       if (!ssWriteRTWStrVectParam(S, const_char_*_name,
   *                                   const_char_*_value,
   *                                   int_num_items)) {
   *          return;
   *       }
   *
   *       if (!ssWriteRTWVectParam(S, const_char_*_name, const_void_*_value,
   *                                int_data_type_of_value, int_vect_len)){
   *          return;
   *       }
   *
   *       if (!ssWriteRTW2dMatParam(S, const_char_*_name, const_void_*_value,
   *                        int_data_type_of_value, int_nrows, int_ncols)){
   *          return;
   *       }
   *
   *       The 'data_type_of_value' input argument for the above two macros is
   *       obtained using
   *          DTINFO(dTypeId, isComplex),
   *       where
   *          dTypeId: can be any one of the enum values in BuitlInDTypeID
   *                   (SS_DOUBLE, SS_SINGLE, SS_INT8, SS_UINT8, SS_INT16,
   *                   SS_UINT16, SS_INT32, SS_UINT32, SS_BOOLEAN defined
   *                   in simstuc_types.h)
   *          isComplex: is either 0 or 1, as explained in Note-2 for
   *                    ssWriteRTWParameters.
   *
   *       For example DTINFO(SS_INT32,0) is a non-complex 32-bit signed
   *       integer.
   *
   *       If isComplex==1, then it is assumed that 'const_void_*_value' array
   *       has the real and imaginary parts arranged in an interleaved manner
   *       (i.e., Simulink Format).
   *
   *       If you prefer to pass the real and imaginary parts as two seperate
   *       arrays, you should use the follwing macros:
   *
   *       if (!ssWriteRTWMxVectParam(S, const_char_*_name,
   *                                  const_void_*_rvalue, const_void_*_ivalue,
   *                                  int_data_type_of_value, int_vect_len)){
   *          return;
   *       }
   *
   *       if (!ssWriteRTWMx2dMatParam(S, const_char_*_name,
   *                                   const_void_*_rvalue, const_void_*_ivalue,
   *                                   int_data_type_of_value,
   *                                   int_nrows, int_ncols)){
   *          return;
   *       }
   *
   *       See simulink/include/simulink.c and simstruc.h for the definition 
   *       (implementation) of these functions and simulink/src/ml2rtw.c for 
   *       examples of using these functions.
   *
   */
  static void mdlRTW(SimStruct *S)
  {
  }
#endif /* MDL_RTW */


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif


