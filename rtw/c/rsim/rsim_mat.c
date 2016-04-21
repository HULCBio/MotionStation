/******************************************************************
 *    
 *  File: rsim_mat.c                      
 *
 *  $Revision: 1.20.4.5 $
 *
 *  Abstract:
 *      - provide matfile handling for reading and writing matfiles
 *        for use with rsim stand-alone, non-real-time simulation 
 *      - provide functions for swapping rtP vector for parameter tuning
 *
 * Copyright 1994-2003 The MathWorks, Inc.
 ******************************************************************/

/* INCLUDES */
#include  <stdio.h>
#include  <stdlib.h>
#include  <string.h>
#include  <math.h>
#include  <float.h>

#undef RSIM_WITH_SL_SOLVER
#define TYPEDEF_MX_ARRAY

#include  "mat.h"
#include  "simstruc.h"
#include  "rsim.h"

/* external variables */
extern const char  *gblFromWorkspaceFilename;
extern const char  *gblParamFilename;

extern const int_T gblNumToFiles;
extern FNamePair   *gblToFNamepair;

extern const int_T gblNumFrFiles;
extern FNamePair   *gblFrFNamepair;

#define INVALID_DTYPE_ID (-10)


static PrmStructData gblPrmStruct;


/*==================*
 * Visible routines *
 *==================*/


/* Function: rt_RSimRemapToFileName ============================================
 * Abstract:
 *      Used by the Rapid Simulation Target (rsim) to remap during model
 *      start, the MAT-file from which this block writes to. The list
 *      of all to file names is assumed to be unique.  This routine will
 *      search the list that maps the original to file name specified in
 *      the model to a new output name. When found, the fileName pointer
 *      is updated to point to this location.
 */
void rt_RSimRemapToFileName(const char **fileName)
{
    int_T i;
    for (i=0; i<gblNumToFiles; i++) {
	if (gblToFNamepair[i].newName != NULL &&
            strcmp(*fileName, gblToFNamepair[i].oldName)==0) {
            *fileName = gblToFNamepair[i].newName; /* remap */
            gblToFNamepair[i].remapped = 1;
            break;
        }
    }
} /* end rt_RSimRemapToFileName */



/* Function: rt_ReadFromfileMatFile ============================================
 *
 * Abstract: 
 *      This function opens a "fromfile" matfile containing a TU matrix.
 *      The first row of the TU matrix contains a time vector, while 
 *      successive rows contain one or more U vectors. This function
 *      expects to find one and only one matrix in the
 *      matfile which must be named "TU". 
 *
 *      originalWidth    = only the number of U channels (minimum is 1)
 *      nptsPerSignal    = the length of the T vector.
 *      nptsTotal        = total number of point in entire TU matrix.
 *                         npoints equals: nptsPerChannel * (nchannels + 1)
 *
 * Returns:
 *	NULL    : success
 *      non-NULL: error message
 */
const char *rt_ReadFromfileMatFile(const char *origFileName, 
                                   int originalWidth,
                                   FrFInfo * frFInfo) 
{
    static char  errmsg[1024];
    MATFile      *pmat;
    mxArray      *tuData_mxArray_ptr = NULL; 
    const double *matData;
    size_t       nbytes;
    int          nrows, ncols;
    int          rowIdx, colIdx;
    const char   *matFile;

    errmsg[0] = '\0'; /* assume success */

    /******************************************************************
     * Remap the "original" MAT-filename if told to do by user via a *
     * -f command line switch.                                        *
     ******************************************************************/
    {
        int_T i;
      
        frFInfo->origFileName  = origFileName;
        frFInfo->originalWidth = originalWidth;
        frFInfo->newFileName   = origFileName; /* assume */

        for (i=0; i<gblNumFrFiles; i++) {
            if (gblFrFNamepair[i].newName != NULL && \
                strcmp(origFileName, gblFrFNamepair[i].oldName)==0) {
                frFInfo->newFileName = gblFrFNamepair[i].newName; /* remap */
                gblFrFNamepair[i].remapped = 1;
                break;
            }
        }
    }

    if ((pmat=matOpen(matFile=frFInfo->newFileName,"rb")) == NULL) {
        (void)sprintf(errmsg,"could not open MAT-file '%s' containing "
                      "From File Block data", matFile);
        goto EXIT_POINT;
    }

    if ( (tuData_mxArray_ptr=matGetNextVariable(pmat,NULL)) == NULL) {
        (void)sprintf(errmsg,"could not locate a variable in MAT-file '%s'",
                      matFile);
        goto EXIT_POINT;
    }

    nrows=mxGetM(tuData_mxArray_ptr);
    if ( nrows<2 ) {
        (void)sprintf(errmsg,"\"From File\" matrix variable from MAT-file "
                      "'%s' must contain at least 2 rows", matFile);
        goto EXIT_POINT;
    }

    ncols=mxGetN(tuData_mxArray_ptr);
    if ( ncols<2 ) {
        (void)sprintf(errmsg,"\"From File\" matrix variable in MAT-file '%s' "
                      "must contain at least 2 columns", matFile);
        goto EXIT_POINT;
    }

    frFInfo->nptsPerSignal = ncols;    
    frFInfo->nptsTotal     = nrows * ncols;

    /* Don't count Time as part of output vector width */
    if (frFInfo->originalWidth != nrows) {
        /* Note, origWidth is determined by fromfile.tlc */    
        (void)sprintf(errmsg,"\"From File\" number of rows in MAT-file "
                      "'%s' must match original number of rows", matFile);
        goto EXIT_POINT;
    }

    matData = mxGetPr(tuData_mxArray_ptr);

    /*
     * Verify that the time vector is monotonically increasing.
     */
    {
        int i;
        for (i=1; i<ncols; i++) {
            if (matData[i*nrows] < matData[(i-1)*nrows]) {
                (void)sprintf(errmsg,"Time in \"From File\" MAT-file "
                              "'%s' must be monotonically increasing", 
                              matFile);
                goto EXIT_POINT;
            }
        }
    }

    /*
     * It is necessary to have the same number of input signals as
     * in the original model. It is NOT necessary for the signals to
     * have the same signal length as in the original model. They
     * can be substantially larger if desired. 
     */
    nbytes = (size_t)(nrows * ncols * (size_t)sizeof(double));

    if ((frFInfo->tuDataMatrix = (double*)malloc(nbytes)) == NULL) {
        (void)sprintf(errmsg,"memory allocation error "
                      "(rt_ReadFromfileMatFile %s)", matFile);
        goto EXIT_POINT;
    }

    /* Copy and transpose data into "tuDataMatrix" */
    for (rowIdx=0; rowIdx<frFInfo->originalWidth; rowIdx++) {  
        for (colIdx=0; colIdx<frFInfo->nptsPerSignal; colIdx++) {
            frFInfo->tuDataMatrix[colIdx + rowIdx*frFInfo->nptsPerSignal] = 
                matData[rowIdx + colIdx*frFInfo->originalWidth];
        }
    }


EXIT_POINT:

    if (pmat!=NULL) {
        matClose(pmat);
    }

    if (tuData_mxArray_ptr != NULL) {
        mxDestroyArray(tuData_mxArray_ptr);
    }

    return (errmsg[0] != '\0'? errmsg: NULL);

} /* end rt_ReadFromfileMatFile */


/* Function: rt_FreeRSimParamStructs ===========================================
 * Abstract: 
 *      Free and NULL the fields of all 'PrmStructData' structures.
 */
void rt_FreeRSimParamStructs(PrmStructData *paramStructure)
{
    if (paramStructure != NULL) {
        int         i;
        int         nTrans       = paramStructure->nTrans;
        DTParamInfo *dtParamInfo = paramStructure->dtParamInfo;

        if (dtParamInfo != NULL) {
            for (i=0; i<nTrans; i++) {
                /*
                 * Must free "stolen" parts of matrices with
                 * mxFree (they are allocated with mxCalloc).
                 */
                mxFree(dtParamInfo[i].rVals);
                mxFree(dtParamInfo[i].iVals);
            }
            free(dtParamInfo);
        }

        paramStructure->nTrans      = 0;
        paramStructure->dtParamInfo = NULL;
    }
} /* end rt_FreeRSimParamStructs */


/* Function: rt_ReadParamStructureMatfile=======================================
 * Abstract:
 *  Reads a matfile containing a new parameter structure.  It also reads the
 *  model checksum and compares this with the RTW generated code's checksum
 *  before inserting the new parameter structure.
 *
 * Returns:
 *	NULL    : success
 *	non-NULL: error string
 */
const char *rt_ReadParamStructureMatfile(PrmStructData **prmStructOut,
                                         int           cellParamIndex)
{
    int           nTrans;
    int           i;
    MATFile       *pmat              = NULL;
    mxArray       *pa                = NULL;
    const mxArray *paParamStructs    = NULL;
    PrmStructData *paramStructure    = NULL; 
    const char    *result            = NULL; /* assume success */

    paramStructure = &gblPrmStruct;
                                             
    /**************************************************************************
     * Open parameter MAT-file, read checksum, swap rtP data for type Double *
     **************************************************************************/

    if ((pmat=matOpen(gblParamFilename,"rb")) == NULL) {
        result = "could not find MAT-file containing new parameter data";
        goto EXIT_POINT;
    }

    /*
     * Read the param variable. The variable name must be passed in 
     * from the generated code.  
     */
    if ((pa=matGetNextVariable(pmat,NULL)) == NULL ) {
        result = "error reading new parameter data from MAT-file "
            "(matGetNextVariable)";
        goto EXIT_POINT;
    } 

    /* Should be 1x1 structure */
    if (!mxIsStruct(pa) ||
        mxGetM(pa) != 1 || mxGetN(pa) != 1 ) {
        result = "parameter variables must be a 1x1 structure";
        goto EXIT_POINT;
    }

    /* look for modelChecksum field */
    {
        const double  *newChecksum;
        const mxArray *paModelChecksum;

        if ((paModelChecksum = mxGetField(pa, 0, "modelChecksum")) == NULL) {
            result = "parameter variable must contain a modelChecksum field";
            goto EXIT_POINT;
        }

        /* check modelChecksum field */
        if (!mxIsDouble(paModelChecksum) || mxIsComplex(paModelChecksum) ||
            mxGetNumberOfDimensions(paModelChecksum) > 2 ||
            mxGetM(paModelChecksum) < 1 || mxGetN(paModelChecksum) !=4 ) {
            result = "invalid modelChecksum in parameter MAT-file";
            goto EXIT_POINT;
        }

        newChecksum = mxGetPr(paModelChecksum);

        paramStructure->checksum[0] = newChecksum[0];
        paramStructure->checksum[1] = newChecksum[1];
        paramStructure->checksum[2] = newChecksum[2];
        paramStructure->checksum[3] = newChecksum[3];
    }

    /*
     * Get the "parameters" field from the structure.  It is an
     * array of structures.
     */
    if ((paParamStructs = mxGetField(pa, 0, "parameters")) == NULL) {
        result = "parameter variable must contain a parameters field";
        goto EXIT_POINT;
    }

    /*
     * If the parameters field is a cell array then pick out the cell
     * array pointed to by the cellParamIndex
     */
    if ( mxIsCell(paParamStructs) ) {
        paParamStructs = mxGetCell(paParamStructs, cellParamIndex);
        if (paParamStructs == NULL) {
            result = "Invalid parameter field in parameter structure";
            goto EXIT_POINT;
        }
    }

    nTrans = mxGetNumberOfElements(paParamStructs);
    if (nTrans == 0) goto EXIT_POINT;

    /*
     * Validate the array fields - only check the first element of the
     * array since all elements of a structure array have the same
     * fields.
     *
     * It is assumed that if the proper data fields exists, that the
     * data is correct.
     */
    {
        mxArray *dum;

        if ((dum = mxGetField(paParamStructs, 0, "dataTypeName")) == NULL) {
            result = "parameters struct must contain a dataTypeName field";
            goto EXIT_POINT;
        }

        if ((dum = mxGetField(paParamStructs, 0, "dataTypeId")) == NULL) {
            result = "parameters struct must contain a dataTypeId field";
            goto EXIT_POINT;
        }
        
        if ((dum = mxGetField(paParamStructs, 0, "complex")) == NULL) {
            result = "parameters struct must contain a complex field";
            goto EXIT_POINT;
        }
        
        if ((dum = mxGetField(paParamStructs, 0, "dtTransIdx")) == NULL) {
            result = "parameters struct must contain a dtTransIdx field";
            goto EXIT_POINT;
        }

        if ((dum = mxGetField(paParamStructs, 0, "values")) == NULL) {
            result = "parameters struct must contain a values field";
            goto EXIT_POINT;
        }
    }

    /*
     * Allocate the DTParamInfo's.
     */
    paramStructure->dtParamInfo = (DTParamInfo *)
        calloc(nTrans,sizeof(DTParamInfo));
    if (paramStructure->dtParamInfo == NULL) {
        result = "Memory allocation error";
        goto EXIT_POINT;
    }

    paramStructure->nTrans = nTrans;

    /*
     * Get the new parameter data for each data type.
     */
    paramStructure->numParams = 0;
    for (i=0; i<nTrans; i++) {
        double      *pr;
        mxArray     *mat;
        DTParamInfo *dtprmInfo = &paramStructure->dtParamInfo[i];
        
        /*
         * Grab the datatype id.
         */
        mat = mxGetField(paParamStructs,i,"dataTypeId");
        pr  = mxGetPr(mat);
        
        dtprmInfo->dataType = (int)pr[0];

        /*
         * Grab the complexity.
         */
        mat = mxGetField(paParamStructs,i,"complex");
        pr  = mxGetPr(mat);
        
        dtprmInfo->complex = (bool)pr[0];

        /*
         * Grab the data type transition index.
         */
        mat = mxGetField(paParamStructs,i,"dtTransIdx");
        pr  = mxGetPr(mat);
        
        dtprmInfo->dtTransIdx = (int)pr[0];

        /*
         * Grab the data and any attributes.  We "steal" the data
         * from the mxArray.
         */
        mat = mxGetField(paParamStructs,i,"values");

        dtprmInfo->elSize = mxGetElementSize(mat);
        dtprmInfo->nEls   = mxGetNumberOfElements(mat);

        dtprmInfo->rVals  = mxGetData(mat);
        dtprmInfo->iVals  = mxGetImagData(mat);
        mxSetData(mat,NULL);
        mxSetImagData(mat,NULL);

        /*
         * Increment total element count.
         */
        paramStructure->numParams += dtprmInfo->nEls;
    }

EXIT_POINT:
    mxDestroyArray(pa);

    if (pmat != NULL) {
        matClose(pmat); pmat = NULL;
    }

    if (result != NULL) {
        rt_FreeRSimParamStructs(paramStructure);
        paramStructure = NULL;
    }
    *prmStructOut = paramStructure;
    return(result);
} /* end rt_ReadParamStructureMatfile */


extern const char* gblSolverOptsFilename;
extern int         gblSolverOptsArrIndex;


/*******************************************************************************
 *
 * Rountine to load solver options.
 * The options listed below can be changed as
 * the start of execution using the -S flag
 *
 *            Solver
 *            RelTol
 *            MinStep
 *            MaxStep
 *            InitialStep
 *            Refine
 *            MaxOrder
 *              ExtrapolationOrder        --  used by ODE14x
 *              NumberNewtonIterations    --  used by ODE14x
 */
void rsimLoadSolverOpts(SimStruct* S)
{
    MATFile*    matf;
    mxArray*    pa;
    mxArray*    sa;
    int         idx    = 0;
    const char* result = NULL;

    if (gblSolverOptsFilename == NULL) return;

    if ((matf=matOpen(gblSolverOptsFilename,"rb")) == NULL) {
        result = "could not find MAT-file containing new parameter data";
        goto EXIT_POINT;
    }

    if ((pa=matGetNextVariable(matf,NULL)) == NULL ) {
        result = "error reading new solver options from MAT-file";
        goto EXIT_POINT;
    }

    /* Should be structure */
    if ( !mxIsStruct(pa) || (mxGetN(pa) > 1 && mxGetM(pa) > 1) ) {
        result = "solver options should be a vector of structures";
        goto EXIT_POINT;
    }

    if (gblSolverOptsArrIndex > 0) idx = gblSolverOptsArrIndex;

    if (idx >= 0 && mxGetNumberOfElements(pa) <= idx) {
        result = "options array size is less than the specified array index";
        goto EXIT_POINT;
    }

    /* Solver */
    {
        const char* opt = "Solver";
        static char solver[256] = "\0";
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if (mxGetString(sa, solver, 256) != 0) {
                result = "xxx later";
                goto EXIT_POINT;
            }
            ssSetSolverName(S, solver);
        }
    }

    /* RelTol */
    {
        const char* opt = "RelTol";
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option RelTol";
                goto EXIT_POINT;
            }
            ssSetSolverRelTol(S, mxGetPr(sa)[0]);
        }
    }

    /* AbsTol */
    {
        const char* opt = "AbsTol";
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            double* aTol = ssGetSolverAbsTol(S);
            int     nx   = ssGetNumContStates(S);
            int     n    = mxGetNumberOfElements(sa);

            if ( !mxIsDouble(sa) || (n != 1 && n != nx) ) {
                result = "error reading solver option AbsTol";
                goto EXIT_POINT;
            }
            if (n == 1) {
                int i;
                for (i = 0; i < nx; i++) {
                    aTol[i] = mxGetPr(sa)[0];
                }
            } else {
                int i;
                for (i = 0; i < nx; i++) {
                    aTol[i] = mxGetPr(sa)[i];
                }
            }
        }
    }

    /* MinStep */
    {
        const char* opt = "MinStep";
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option MinStep";
                goto EXIT_POINT;
            }
            ssSetMinStepSize(S, mxGetPr(sa)[0]);
        }
    }

    /* MaxStep */
    {
        const char* opt = "MaxStep";
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option MaxStep";
                goto EXIT_POINT;
            }
            ssSetMaxStepSize(S, mxGetPr(sa)[0]);
        }
    }

    /* FixedStep */
    {
        const char* opt = "FixedStep";
        double newFixedStepSize;
        double n;
        
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option FixedStep";
                goto EXIT_POINT;
            }
        }

        if (ssGetFixedStepSize(S) == 0){
            result = "error: cannot change the Fixed Step Size when using a "
                "Variable Step Solver";
            goto EXIT_POINT;
        }
        
        newFixedStepSize = mxGetPr(sa)[0];
        n = ssGetFixedStepSize(S)/newFixedStepSize;

        if ((fabs(n - floor(n))/n)>DBL_EPSILON){
            result = "error: the quotient of the old fixed step size divided \n"
                "  by the new fixed step size must be a positive integer value";
            goto EXIT_POINT;
        }
        
        ssSetStepSize(S, newFixedStepSize);
    }
   
    /* InitialStep */
    {
        const char* opt = "InitialStep";
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option InitialStep";
                goto EXIT_POINT;
            }
            ssSetStepSize(S, mxGetPr(sa)[0]);
        }
    }

    /* MaxOrder */
    {
        const char* opt = "MaxOrder";
        int         maxOrder;
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option MaxOrder";
                goto EXIT_POINT;
            }
            maxOrder = (int) (mxGetPr(sa)[0]);
            ssSetSolverMaxOrder(S, maxOrder);
        }
    }

    /* ExtrapolationOrder -- used by ODE14x, only */
    {
        const char* opt = "ExtrapolationOrder";
        int         extrapolationOrder;
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option ExtrapolationOrder";
                goto EXIT_POINT;
            }
            extrapolationOrder = (int) (mxGetPr(sa)[0]);
            ssSetSolverExtrapolationOrder(S, extrapolationOrder);
        }
    }

    /* NumberNewtonIterations -- used by ODE14x, only */
    {
        const char* opt = "NumberNewtonIterations";
        int         numberIterations;
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option ExtrapolationOrder";
                goto EXIT_POINT;
            }
            numberIterations = (int) (mxGetPr(sa)[0]);
            ssSetSolverNumberNewtonIterations(S, numberIterations);
        }
    }

    /* Refine */
    {
        const char* opt = "Refine";
        int         refine;
        if ( (sa=mxGetField(pa,idx,opt)) != NULL ) {
            if ( !mxIsDouble(sa) || mxGetNumberOfElements(sa) != 1 ) {
                result = "error reading solver option Refine";
                goto EXIT_POINT;
            }
            refine = (int) (mxGetPr(sa)[0]);
            ssSetSolverRefineFactor(S, refine);
        }
    }

  EXIT_POINT:

    if (matf != NULL) {
        matClose(matf); matf = NULL;
    }

    ssSetErrorStatus(S, result);
    return;

} /* rsimLoadSolverOpts */


/* EOF rsim_mat.c */
