/*  File    : table3.c
 *  Abstract:
 *
 *      S-function source for 3-D Lookup Table block.
 *
 *      For more details about S-functions, see simulink/src/sfuntmpl_doc.c
 *
 *  Copyright 1990-2004 The MathWorks, Inc.
 *  $Revision: 1.15.4.3 $
 */

#include <float.h>

#define S_FUNCTION_NAME table3
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define X_VEC_IDX 0
#define X_VEC_PARAM(S) ssGetSFcnParam(S,X_VEC_IDX)
 
#define Y_VEC_IDX 1
#define Y_VEC_PARAM(S) ssGetSFcnParam(S,Y_VEC_IDX)
 
#define Z_VEC_IDX 2
#define Z_VEC_PARAM(S) ssGetSFcnParam(S,Z_VEC_IDX)
 
#define TAB_IDX 3
#define TAB_PARAM(S) ssGetSFcnParam(S,TAB_IDX)
 
#define NPARAMS 4

#define X_VEC mxGetPr( X_VEC_PARAM(S) )
#define Y_VEC mxGetPr( Y_VEC_PARAM(S) )
#define Z_VEC mxGetPr( Z_VEC_PARAM(S) )
#define TAB   mxGetPr( TAB_PARAM(S) )

/* Give the inputs some names */
#define X_REF_IN U(0)
#define Y_REF_IN U(1)
#define Z_REF_IN U(2)

/*
 * Macros to define the lengths of the vectors in the sense of MATLAB's
 * LENGTH command
 */
#define LENGTH_X    MAX( mxGetM(X_VEC_PARAM(S)), mxGetN(X_VEC_PARAM(S)) )
#define LENGTH_Y    MAX( mxGetM(Y_VEC_PARAM(S)), mxGetN(Y_VEC_PARAM(S)) )
#define LENGTH_Z    MAX( mxGetM(Z_VEC_PARAM(S)), mxGetN(Z_VEC_PARAM(S)) )
#define LENGTH_TAB  MAX( mxGetM(TAB_PARAM(S)),   mxGetN(TAB_PARAM(S)) )
 
/*
 * create 2nd level of macros for setting/getting the work values based
 * on relevant names
 */
#define OLD_REF(IND)             ssGetRWorkValue( S, IND )
#define OLD_INDEX(IND)           ssGetIWorkValue( S, IND )
 
#define SET_OLD_REF(IND,VAL)     ssSetRWorkValue(S,IND,VAL)
#define SET_OLD_INDEX(IND,VAL)   ssSetIWorkValue(S,IND,VAL)

/* misc defines */
#if !defined(TRUE)
# define TRUE  1
#endif
#if !defined(FALSE)
#define FALSE 0
#endif

#define INF DBL_MAX      /* infinity for double precision on this system */

#undef MAX
#define MAX(A, B)  ((A) > (B) ? (A) : (B)) /* compute the max of 2 numbers */

#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))

/*======================*
 * Supporting Functions *
 *======================*/


/* Function: Table1 ===========================================================
 * Abstract:
 *    Return interpolated Y value
 */
static real_T Table1
(
 const real_T *Xvec,  /* vector of X values                               */
 const real_T *Yvec,  /* vector of Y values                               */
 real_T       Xin,    /* the desired X value (reference signal)           */
 int_T        OffSet  /* offset for the X and Y vectors (0 for no offset) */
 )
{
    real_T xLow = Xvec[ OffSet ];
    real_T xHi  = Xvec[ OffSet + 1 ];
    real_T yLow = Yvec[ OffSet ];
    real_T yHi  = Yvec[ OffSet + 1 ];
 
    if ( Xin == xHi ) {
        return yHi;
    } else {
        return yLow + ( ( ( yHi - yLow ) * ( Xin - xLow ) ) / ( xHi - xLow ) );
    }
} /* end Table 1 */
 
 

/* Function: GetIndex =========================================================
 * Abstract:
 *      Returns the lowindex for interpolation
 */
static int GetIndex
(
 const real_T     *Xvec,     /* ptr to independent values                    */
 int              L,         /* length of X                                  */
 real_T           Xin,       /* the desired X value (reference signal)       */
 int_T            SearchDir, /* search direction                             */
 const  SimStruct *S,        /* the simstruct                                */
 int_T            WorkIndex  /* the index into the work vectors to retrieve
                                appropriate old indices                      */
 )
{
    int_T i;
    int_T LowIndex = 0; /* Initialize to quiet compiler warnings */
    int_T OldIndex;
 
    /*
     * retrieve the index from the previous search
     * start search here, for speed
     */
 
    OldIndex = OLD_INDEX(WorkIndex);
 
    /*
     * determine "bracketing" numbers
     */
 
    if (SearchDir > 0) {
        for (i = OldIndex; i < L; i++) {
            if ( Xvec[i] >= Xin ) {
                LowIndex = i - 1;
                break;
            }
        }
    } else {
        for (i = OldIndex; i >= 0; i--) {
            if ( Xvec[i] < Xin ) {
                LowIndex = i;
                break;
            }
        }
    }
 
    /*
     * store the index from this time step in a work vector
     */
    if (i == L) {
        /*
         * stepped over top boundary
         */
        SET_OLD_INDEX(WorkIndex,L-1);
    } else if (i < 0) {
        /*
         * stepped over lower boundary
         */
        SET_OLD_INDEX(WorkIndex,0);
    } else {
        /*
         * no problem, just use i
         */
        SET_OLD_INDEX(WorkIndex,i);
    }
 
    /*
     * check for out of range cases to setup for extrapolation
     */
 
    if ( i == L  )                     LowIndex = L-2;
    if ( i == -1 )                     LowIndex = 0;
    if ( (i == 0) && (SearchDir > 0) ) LowIndex = 0;
 
    return LowIndex;

} /* end GetIndex */
 
 

/* Function: GetArrayElement ==================================================
 * Abstract:
 *      Return the value at mat(row,col).
 *
 *      This function returns the array element corresponeding to the row and
 *      col indices (C-Style:start with 0) that are entered.  The inputs are
 *      the dimensions of the table (M & N), the desired row and column (row,
 *      col), and the pointer to the real data of the matrix (array) indices
 *      (zero based).
 *     the value at mat(row,col).
 */
static real_T GetArrayElement
(
 int_T        M,    /* the number of rows in the array    */
 int_T        N,    /* the number of columns in the array */
 int_T        row,  /* the row index                      */
 int_T        col,  /* the column index                   */
 const real_T *mat, /* pointer to the array real data     */
 SimStruct    *S
 )
{
 
    if ((row >= M) ||
        (col >= N) ||
        (row < 0)  ||
        (col < 0)  ) {
        ssSetErrorStatus(S,"Input indices exceed array dimensions");
        return(0.0);
    }
 
    return mat[ ( col * M ) + row ];

} /* end GetArrayElement */
 
 

/* Function: Table2 ===========================================================
 * Abstract:
 *      This function implements a 2-D table.  Pass in the pointers to the
 *      x and y vectors, the index of the lower bracketing numbers for
 *      x and y, the desired x and y values, a pointer to the real data of
 *      the table and the pointer to the table matrix (Array) structure.
 *      The interpolated value is returned.
 *
 * Return:
 *      the interpolated value
 */
static real_T Table2
(
 const real_T  *Xvec,    /* data that describes the X dim of the table       */
 const real_T  *Yvec,    /* data that describes the Y dim of the table       */
 int_T         XLowIndex,/* where to start searching from in the X direction */
 int_T         YLowIndex,/* where to start searching from in the Y direction */
 real_T        Xin,
 real_T        Yin,
 const real_T  *tab,     /* pointer to real data of the table                */
 const mxArray *TabPtr,
 SimStruct     *S
 )
{
    int_T i, j;
    real_T ytemp[2], TempTab[2];
 
    /*
     * First build a table by using TABLE1 to get values at the bracketing y
     * numbers based on the desired x value (Xin).  The result is TempTab.
     */
 
    for ( i=0; i<2; i++ ) {
        for ( j=0; j<2; j++ ) {
            ytemp[j] = GetArrayElement( mxGetM( TabPtr ), mxGetN( TabPtr ),
                                        YLowIndex + i, XLowIndex + j, tab, S );
            if (ssGetErrorStatus(S) != NULL) {
                return(0.0);
            }
        }
        TempTab[i] = Table1( Xvec + XLowIndex, ytemp, Xin, 0 );
    }
 
    /* use Table 1 to interpolate TempTab based on the desired Y value (Yin) */
 
    return Table1( Yvec + YLowIndex, TempTab, Yin, 0 );
 
}  /* end Table2 */


#if defined(MATLAB_MEX_FILE)
  /* Function: IsVector =======================================================
   * Abstract:
   *    This function returns TRUE if the array is a vector and FALSE
   *      otherwise. The input argument is a pointer to a matrix (Array)
   */
  static int IsVector( const mxArray *mat )
  {
      int_T m = mxGetM(mat);
      int_T n = mxGetN(mat);
      if ( (m != 1) && (n != 1) ) {     /* one of the dimensions must be 1 */
          return FALSE;
      } else {
          return TRUE;
      }
  } /* end IsVector */
 
 
 
  /* Function: IsMonotonoc ====================================================
   * Abstract:
   *    This function returns TRUE if the vector is monotinic and FALSE
   *      otherwise. Pass in a pointer to the real data, and the length of
   *      the vector.
   */
  static int IsMonotonic(const real_T *v, int_T l)
  {
      int_T i;
      for ( i=2; i<l; i++) {
          if ( v[i-1] >= v[i] ) {
              return FALSE;
          }
      }
      return TRUE;
 
  } /* IsMonotonic */
#endif /* defined(MATLAB_MEX_FILE) */

 
/*====================*
 * S-function methods *
 *====================*/
 
#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
  /* Function: mdlCheckParameters =============================================
   * Abstract:
   *    Validate our parameters to verify they are okay.
   *      X, Y, and Z must be vectors
   *      X, Y, and Z must be monotonically increasing
   *      The table must not be a 1x1 table.
   *      The number of rows in the table must match the length of Y.
   *      The number of columns in the table must match length(X)*length(Z)
   */
  static void mdlCheckParameters(SimStruct *S)
  {
      /* Check if all parameters are valid */
      if ( !IS_PARAM_DOUBLE(X_VEC_PARAM(S)) || 
           !IS_PARAM_DOUBLE(Y_VEC_PARAM(S)) || 
           !IS_PARAM_DOUBLE(Z_VEC_PARAM(S)) ||
           !IS_PARAM_DOUBLE(TAB_PARAM(S)) ) {
           ssSetErrorStatus(S,"All parameters to S-function must be of type "
                            "double");
              return;
      }


      /* Check that first three parameters (X, Y, Z) are vectors */
      {
          if (!IsVector(X_VEC_PARAM(S)) ||
              !IsVector(Y_VEC_PARAM(S)) ||
              !IsVector(Z_VEC_PARAM(S))) {
              ssSetErrorStatus(S,"1st three parameters to S-function "
                               "\"X, Y, Z\" must be double vectors");
              return;
          }
      }

      /* Check that first three parameters (X, Y, Z) are monotonic */
      {
          if (!IsMonotonic(X_VEC,
                 MAX(mxGetM(X_VEC_PARAM(S)), mxGetN(X_VEC_PARAM(S)))) ||
              !IsMonotonic(Y_VEC,
                 MAX(mxGetM(Y_VEC_PARAM(S)), mxGetN(Y_VEC_PARAM(S)))) ||
              !IsMonotonic(Z_VEC,
                 MAX(mxGetM(Z_VEC_PARAM(S)), mxGetN(Z_VEC_PARAM(S))))) {
              ssSetErrorStatus(S,"1st three parameters to S-function "
                               "\"X, Y, Z\" must be monotonic");
              return;
          }
      }
 
      /* Check 4th parameter: Table (TAB) parameter */
      {
 
          if ((mxGetM(TAB_PARAM(S)) == 1) && (mxGetN(TAB_PARAM(S)) == 1)) {
              ssSetErrorStatus(S,"4th parameter to S-function "
                               "\"Table\" cannot be scalar");
              return;
          }
 
          if (mxGetM(TAB_PARAM(S)) != LENGTH_Y) {
              ssSetErrorStatus(S,"2nd & 4th parameters to S-function "
                               " inconsistency: "
                               "The number of rows in the output table "
                               "\"(Parameter 4)\" must equal the length of "
                               "Y \"Parameter 2)\"");
              return;
          }
 
          if (mxGetN(TAB_PARAM(S)) != (LENGTH_X*LENGTH_Z)) {
              ssSetErrorStatus(S,"1st, 3rd, & 4th parameters to S-function "
                               " inconsistency: "
                               "The number of columns in the output table "
                               "\"(Parameter 4)\" must equal "
                               "length(x)*length(z) \"{Parameters 1, 3}\"");
              return;
          }
      }
  }
#endif /* MDL_CHECK_PARAMETERS */
 


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }
#endif

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
        }
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 3);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 3);
    ssSetNumIWork(S, 3);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize table lookup indices
 */
static void mdlInitializeConditions(SimStruct *S)
{
    /* intialize OLD_INDICES to 0 */
    SET_OLD_INDEX( 0,0 );
    SET_OLD_INDEX( 1,0 );
    SET_OLD_INDEX( 2,0 );
 
    /*
     * initialize OLD_REF values to be < the input at time 0 to ensure correct
     * search direction.
     */
    SET_OLD_REF(0, -INF );
    SET_OLD_REF(1, -INF );
    SET_OLD_REF(2, -INF );
}
 
 

/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = f(U(XINDEX),U(YINDEX))
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
    real_T *y = ssGetOutputPortRealSignal(S,0);
    int_T  lowIndices[3];    /* lower bracketing #'s for x, y and z vects */
    int_T  vectorLengths[3];
    int_T  i;
    int_T  searchDir;
    int_T  nTabEntry;
    real_T ytemp[2];
    const real_T *levelPtr;
    const real_T *vectors[3];     /* ptrs to x, y and z vectors */
 
    UNUSED_ARG(tid); /* not used in single tasking mode */

    /* build array of pointers to X, Y & Z vectors */
    vectors[0] = X_VEC;
    vectors[1] = Y_VEC;
    vectors[2] = Z_VEC;
 
    /* determine vector lengths */
    vectorLengths[0] = mxGetM(X_VEC_PARAM(S)) * mxGetN(X_VEC_PARAM(S));
    vectorLengths[1] = mxGetM(Y_VEC_PARAM(S)) * mxGetN(Y_VEC_PARAM(S));
    vectorLengths[2] = mxGetM(Z_VEC_PARAM(S)) * mxGetN(Z_VEC_PARAM(S));
 
    /* number of elements in each 2-D table */
    nTabEntry = vectorLengths[0] * vectorLengths[1];
 
    /* The lower of the bracketing indices for the X, Y and Z vectors */
    for (i=0; i<3; i++ ) {
 
        /* determine search direction by comparing old & new ref values */
        searchDir = -1;
 
        if ( U(i) >= OLD_REF(i) ) {
            searchDir = 1;
        }
 
        lowIndices[i] = GetIndex( vectors[i], vectorLengths[i],
                                  U(i), searchDir, S, i );
 
        SET_OLD_REF( i, U(i) );
    }
 
    /*
     * levelPtr points to the 1st element of lower of the 2 bracketing
     * 2-D tables
     */
    levelPtr = TAB + ( nTabEntry * lowIndices[2] );
 
    /*
     * Build a 1-D table problem by doing a 2-D table look-up on bracketing
     * 2-D planes.  The result is the ytemp array.
     */
    ytemp[0] = Table2(X_VEC, Y_VEC, lowIndices[0], lowIndices[1],
                      X_REF_IN, Y_REF_IN, levelPtr, TAB_PARAM(S), S);
 
    ytemp[1] = Table2(X_VEC,
                      Y_VEC, lowIndices[0], lowIndices[1],
                      X_REF_IN, Y_REF_IN, levelPtr + nTabEntry,
                      TAB_PARAM(S), S);
 
    /*
     * Perform a 1-D table look-up of ytemp based on the z values
     */
    y[0] = Table1( Z_VEC + lowIndices[2], ytemp, Z_REF_IN, 0 );
}



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
