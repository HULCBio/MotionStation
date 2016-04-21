/*
 * File : barplot.c
 * Abstract:
 *  An example C-file S-function for accessing simulink signals
 *  without using the standard block inputs.  In this case, a floating
 *  bar-plot style scope is implemented.  The signals that are selected
 *  on the diagram (via the mouse) are displayed by the scope.  The
 *  companion file <matlabroot>\toolbox\simulink\blocks\barplotm.m
 *  receives the signal data and plots it.  See the demo model,
 *  <matlabroot>\toolbox\simulink\simdemos\sfcndemo_barplot.mdl.
 *
 *
 * See simulink/src/sfuntmpl_doc.c, simulink/src/include/sigmapdef.h.
 *
 * Copyright 1990-2004 The MathWorks, Inc.
 * $Revision: 1.6.4.5 $
 */


#define S_FUNCTION_NAME  barplot
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "sigmapdef_sfcn.h"

/*================*
 * Build checking *
 *================*/
#if !defined(MATLAB_MEX_FILE)
/*
 * This file cannot be used directly with the Real-Time Workshop.
 */
# error This_file_can_be_used_only_during_simulation_inside_Simulink
#endif


/*
 * Define the user data.
 */
typedef struct UD_tag {
    int  nPortObjs;    /* current # of ports */
    void **portObjs;   /* current port list  */

    mxArray *figTag;        /* tag of hg window used for plotting     */
    mxArray *dataCell;      /* cell array used to pass data to m-code */
    mxArray *sigNameCell;   /* cell array containing port names       */

    SL_SigList *sigList; /* signal list corresponding to current ports */
} UD;

#define YLIM_PIDX (0)
#define YLIM_PARAM(S) ssGetSFcnParam(S,YLIM_PIDX)

#define IS_BIT_SET(uword32,bit) ((uword32 & bit) != 0)

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *  Validate our parameters.
 */
static void mdlCheckParameters(SimStruct *S)
{
    int    i;
    int    nEls;
    double *pr;
    
    /*
     * The ylimites must have an even number of elements and the mins
     * must be less than the maxes.  This is not a very sophisticated
     * user interface.  The ylims are entered as a vector where successive
     * pairs of elements are used as the limits for successive axes.
     */
    if (!mxIsDouble(YLIM_PARAM(S))) {
        ssSetErrorStatus(S,"YLim parameter must be of type 'double'");
        return;
    }

    nEls = mxGetNumberOfElements(YLIM_PARAM(S));
    if ((nEls < 2) || ((nEls % 2) != 0)) {
        ssSetErrorStatus(S,"YLim parameter have an even number of elements");
        return;

    }

    pr = mxGetPr(YLIM_PARAM(S));
    for (i=0; i<nEls; i+=2) {
        double yMin = pr[i];
        double yMax = pr[i+1];

        if (yMin >= yMax) {
            ssSetErrorStatus(S,"YMin must be less than YMax");
            return;
        }
    }
}
#endif /* MDL_CHECK_PARAMETERS */


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *   Setup sizes of the various vectors.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 1);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    {
        int iParam = 0;
        int nParam = ssGetNumSFcnParams(S);

        for ( iParam = 0; iParam < nParam; iParam++ )
        {
            ssSetSFcnParamTunable( S, iParam, SS_PRM_SIM_ONLY_TUNABLE );
        }
    }

    if (!ssSetNumInputPorts(S, 0)) return;
    if (!ssSetNumOutputPorts(S,0)) return;

    ssSetNumSampleTimes(S, 1);
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


#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    Do startup tasks.
   */
static void mdlStart(SimStruct *S)
{
    /*
     * Create user container.
     */
    UD *ud = (UD *)calloc(1,sizeof(UD));
    if (ud == NULL) mexErrMsgTxt("Out of memory");

    /*
     * Create & initialize the figure tag.
     */
    ud->figTag = mxCreateString(ssGetPath(S)); /* long jumps */
    if (ud->figTag == NULL) mexErrMsgTxt("Out of memory");
    mexMakeArrayPersistent(ud->figTag);

    ssSetUserData(S,ud);
}
#endif /*  MDL_START */


/* Function: mdlOutputs ========================================================
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    return;
}


/* Function: AllRegionsSameN ===================================================
 * Abstract:
 *  Returns true if all regions have the same number of columns.
 */
static boolean_T AllRegionsSameN(SL_SigRegion *sigReg)
{
    boolean_T    matrix  = (gsr_M(sigReg) != -1);
    int          baseN   = matrix ? gsr_N(sigReg) : gsr_nEls(sigReg);

    while((sigReg = gsr_NextReg(sigReg)) != NULL) {
        int n;
        int nEls = gsr_nEls(sigReg);

        if (nEls == 0) continue; /* ignore unavailable regions */
        
        matrix  = (gsr_M(sigReg) != -1);
        n = matrix ? gsr_N(sigReg) : nEls;
        if (n != baseN) {
            return(false);
        }
    }
    return(true);
} /* end AllRegionsSameN */


/* Function: PopulateDataCell ==================================================
 * Abstract:
 *  Cycle through the signals in the signap map and package the signal data
 *  from the current time step into the data cell array.  This array will
 *  be passed to barplotm.m for display.  Note that if the signal consists
 *  of multiple "tie wrapped" signals that have the same number of columns,
 *  they are concatenated together into one matrix.
 */
static void PopulateDataCell(
    SimStruct  *S,
    mxArray    *dataCell,
    SL_SigList *sigList)
{
    int i;
    int nSigs = gsl_nSigs(sigList);

    for (i=0; i<nSigs; i++) {
        SL_SigRegion *sigReg     = gsl_FirstReg(S,sigList,i);
        mxArray      *mat        = mxGetCell(dataCell,i);
        int          nCols       = mxGetN(mat);
        double       *pr         = mxGetPr(mat);
        boolean_T    tieWrap     = gsl_TieWrap(S,sigList,i);
        int          nSigRegions = gsl_nSigRegions(S,sigList,i);
        boolean_T    allSameN    = AllRegionsSameN(sigReg);
        boolean_T    matrixStyle = tieWrap && ((nSigRegions == 1) || allSameN);

        if (matrixStyle) {
            int nColsDone   = 0;
            while (nColsDone != nCols) {
                do {
                    if (gsr_nEls(sigReg) > 0) {
                        int        j;
                        boolean_T  matrix  = (gsr_M(sigReg) != -1);
                        int        m       = matrix ? gsr_M(sigReg) : 1;
                        int        offset  = m*nColsDone;
                        int        dType   = gsr_DataType(sigReg);
                        int        elSize  = gsr_DataTypeSize(sigReg);
                        const char *data   = gsr_data(sigReg)+(offset * elSize);
                        
                        if (dType == SS_DOUBLE) {
                            for (j=0; j<m; j++) {
                                double val = *(double *)data;
                                
                                *pr = val;
                                
                                pr++;
                                data += elSize;
                            }
                        } else {
                            const boolean_T doDiff           = false;
                            const boolean_T satOnIntOverFlow = false;
                            
                            ssCallConvertBuiltInDType(
                                S,m,satOnIntOverFlow,doDiff,dType,
                                data,SS_DOUBLE,pr);
                            pr += m;
                        }
                    }
                } while(sigReg = gsr_NextReg(sigReg), sigReg != NULL);
                
                nColsDone++;
                sigReg = gsl_FirstReg(S,sigList,i);
            }
        } else {
            do {
                if (gsr_nEls(sigReg) > 0) {
                    int        j;
                    int        nEls    = gsr_nEls(sigReg);
                    int        dType   = gsr_DataType(sigReg);
                    int        elSize  = gsr_DataTypeSize(sigReg);
                    const char *data   = gsr_data(sigReg);
                    
                    if (dType == SS_DOUBLE) {
                        for (j=0; j<nEls; j++) {
                            double val = *(double *)data;
                            
                            *pr = val;
                            
                            pr++;
                            data += elSize;
                        }
                    } else {
                        const boolean_T doDiff           = false;
                        const boolean_T satOnIntOverFlow = false;
                        
                        ssCallConvertBuiltInDType(
                            S,nEls,satOnIntOverFlow,doDiff,dType,
                            data,SS_DOUBLE,pr);
                        pr += nEls;
                    }
                }
            } while(sigReg = gsr_NextReg(sigReg), sigReg != NULL);

            /* 
             * Check that we stayed in bounds of allocated mem.
             */
            if ((mxGetPr(mat) + nCols) != pr) {
                mexErrMsgTxt("Fatal memory overrun");
            }
        }
    }
} /* end PopulateDataCell */


/* Function: SumM ==============================================================
 * Abstract:
 *  Return the total number of rows across all regions.
 */
static int SumM(SL_SigRegion *sigReg)
{
    int          sumM    = 0;
    
    do {
        boolean_T matrix = (gsr_M(sigReg) != -1);
        int       m      = matrix ? gsr_M(sigReg) : 1;
        
        sumM += m;
    } while(sigReg = gsr_NextReg(sigReg), sigReg != NULL);
    
    return(sumM);
}


/* Function: CreateMatrixForSig ================================================
 * Abstract:
 *  Create a matrix to hold the data for a signal.  If it makes sense to plot
 *  the data as groups of bars (see bar.m), then the data is packaged into
 *  a single matrix with all columns being the same width.  Otherwise, we
 *  create a vector of values and each element is displayed as a bar.
 */
static mxArray *CreateMatrixForSig(SimStruct *S,
                                   const UD *ud,
                                   const int lstIdx)
{
    int          m,n;
    mxArray      *mat;
    SL_SigList   *sigList    = ud->sigList;
    boolean_T    tieWrap     = gsl_TieWrap(S,sigList,lstIdx);
    int          nSigRegions = gsl_nSigRegions(S,sigList,lstIdx);
    SL_SigRegion *sigReg     = gsl_FirstReg(S,sigList,lstIdx);
    boolean_T    allSameN    = AllRegionsSameN(sigReg);
    boolean_T    matrixStyle = tieWrap && ((nSigRegions == 1) || allSameN);
    
    if (matrixStyle) {
        boolean_T    matrix  = (gsr_M(sigReg) != -1);
        
        m = SumM(sigReg);
        n = matrix ? gsr_N(sigReg) : gsr_nEls(sigReg);
    } else {
        m = 1;
        n = gsl_NumElements(S,ud->sigList,lstIdx);
    }

    mat = mxCreateDoubleMatrix(m, n, mxREAL); /* lngjmps */
    return(mat);
}


/* Function: HandleUnavailSigs =================================================
 * Abstract:
 *  Unselected any unavailable signals as we are not able to display them.
 */
static void HandleUnavailSigs(SimStruct *S, SL_SigList *sigList)
{
    const bool probeMode = true;
    int        i;
    int        nSigs;
    
    if (sigList == NULL) goto EXIT_POINT;
    nSigs = gsl_nSigs(sigList);
    
    for (i=0; i<nSigs; i++) {
        SL_SigRegion *sigReg = gsl_FirstReg(S, sigList,i);

        do {
            if (!IS_BIT_SET(gsr_status(sigReg),SLREG_AVAIL) &&
                !IS_BIT_SET(gsr_status(sigReg),SLREG_GROUND)) {
                if (probeMode) {
                    /*
                     * The graphical "port" selected by the user is
                     * stored in the map (not in the region).  We
                     * want to clear the graphically selected line.
                     */
                    void *mapPortObj = (void *)gsl_PortObj(sigList,i);
                    ssCallUnselectSigFcn(S,mapPortObj);
                } else {
                    /* not implemented */
                }
                break;
            }
        } while((sigReg = gsr_NextReg(sigReg)) != NULL);
    }

EXIT_POINT:
    return;
}


#define MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
/* Function: mdlUpdate ======================================================
 * Abstract:
 *  Build the signal list, package the signal values into a cell array
 *  and call into Matlab to do the plotting.
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{
    void       **portObjs;
    int        nPortObjs;
    boolean_T  changed       = false;
    const char *errmsg       = NULL;
    UD         *ud           = (UD *)ssGetUserData(S);
    void       **oldPortObjs = ud->portObjs;
    int        nOldPortObjs  = ud->nPortObjs;
    void       *block        = ssGetOwnerBlock(S);

    /*
     * Build selected signal list.
     * xxx Currently ineffiecient because called every time through the loop.
     *     We should be able to do this as needed (i.e., when signal selections
     *     change) based on some sort of callback mechanism.
     */
    errmsg = ssCallSelectedSignalsFcn(S,
        block,SIGSET_GRAPH,&portObjs,&nPortObjs);
    if (errmsg != NULL) goto EXIT_POINT;

    if (nPortObjs != nOldPortObjs) {
        changed = true;
    } else {
        int i;
        for (i=0; i<nPortObjs; i++) {
            if (portObjs[i] != oldPortObjs[i]) {
                changed = true;
                break;
            }
        }
    }

    if (changed) {
        /*
         * Update the user data port cache.
         */
        ud->nPortObjs = nPortObjs;

        ssCallGenericDestroyFcn(S,oldPortObjs);
        ud->portObjs = portObjs;
        portObjs = NULL; /* don't free at exit_point */

        /*
         * Destroy old signal info.
         */
        ssCallSigListDestroyFcn(S,ud->sigList);
        ud->sigList = NULL;

        mxDestroyArray(ud->dataCell);
        ud->dataCell = NULL;

        mxDestroyArray(ud->sigNameCell);
        ud->sigNameCell = NULL;

        /*
         * Create the new signal info.
         */
        if (ud->nPortObjs != 0) {
            int          i;
            int          nSigs;
            unsigned int excludeFlags = SLREG_FRAME | SLREG_COMPLEX;

            /*
             * Create signal list.
             */
            errmsg = ssCallSigListCreateFcn(S,
                block,ud->nPortObjs,ud->portObjs,
                excludeFlags, (void **)&ud->sigList);
            if (errmsg != NULL) goto EXIT_POINT;
            nSigs = ud->sigList->nSigs;

            ssCallSigListUnavailSigAlertFcn(S,ud->sigList);
            HandleUnavailSigs(S,ud->sigList);

            /*
             * Create data cell array and child matrices.
             */
            ud->dataCell = mxCreateCellMatrix(1,nSigs); /* lngjmps */
            if (ud->dataCell == NULL) {
                errmsg = "Out of memory";
                goto EXIT_POINT;
            }

            for (i=0; i<nSigs; i++) {
                mxArray *mat = CreateMatrixForSig(S,ud,i); /* lngjmps */
                if (mat == NULL) {
                    errmsg = "Out of memory";
                    goto EXIT_POINT;
                }
                mxSetCell(ud->dataCell,i,mat);
            }

            mexMakeArrayPersistent(ud->dataCell);

            /*
             * Create signal name cell array and the child strings.
             */
            ud->sigNameCell = mxCreateCellMatrix(1,nSigs); /* lngjmps */
            if (ud->sigNameCell == NULL) {
                errmsg = "Out of memory";
                goto EXIT_POINT;
            }

            for (i=0; i<nSigs; i++) {
                void       *portObj = (void *)gsl_PortObj(ud->sigList,i);
                const char *name    = ssCallGetPortNameFcn(S,portObj);
                mxArray    *mat     = mxCreateString(name); /* lngjmps */
                if (mat == NULL) {
                    errmsg = "Out of memory";
                    goto EXIT_POINT;
                }
                mxSetCell(ud->sigNameCell,i,mat);
            }

            mexMakeArrayPersistent(ud->sigNameCell);
        }
    }

    /*
     * Call barplotm.m.
     */
    if (ud->nPortObjs != 0) {
        int     fail;
        mxArray *prhs[4];

        PopulateDataCell(S,ud->dataCell,ud->sigList);

        prhs[0] = ud->figTag;
        prhs[1] = ud->dataCell;
        prhs[2] = (mxArray *)YLIM_PARAM(S);
        prhs[3] = ud->sigNameCell;

        /* Call matlab. */
        fail = mexCallMATLAB(0,NULL,4,prhs,"barplotm");
        if (fail) {
            errmsg = "Error calling 'barplot.m'";
            goto EXIT_POINT;
        }
    }

EXIT_POINT:
    ssCallGenericDestroyFcn(S,portObjs);
    if (errmsg != NULL) {
        mxDestroyArray(ud->dataCell);
        ud->dataCell = NULL;

        ssCallSigListDestroyFcn(S,ud->sigList);
        ud->sigList = NULL;

        mxDestroyArray(ud->sigNameCell);
        ud->sigNameCell = NULL;

        mexErrMsgTxt(errmsg);
    }
}
#endif /* MDL_UPDATE */


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UD *ud = ssGetUserData(S);
    
    ssCallGenericDestroyFcn(S,ud->portObjs);
    mxDestroyArray(ud->figTag);
    mxDestroyArray(ud->dataCell);
    mxDestroyArray(ud->sigNameCell);

    ssCallSigListDestroyFcn(S,ud->sigList);

    free(ud);
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
