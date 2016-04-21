/* ==========================================================================
 * phonebook.c 
 * example for illustrating how to manipulate structure and cell array
 *
 * takes a (MxN) structure matrix and returns a new structure (1x1)
 * containing corresponding fields: for string input, it will be (MxN)
 * cell array; and for numeric (noncomplex, scalar) input, it will be (MxN)
 * vector of numbers with the same classID as input, such as int, double
 * etc..
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 *==========================================================================*/
/* $Revision: 1.6 $ */

#include "mex.h"
#include "string.h"

#define MAXCHARS 80   /* max length of string contained in each field */

/*  the gateway routine.  */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const char **fnames;       /* pointers to field names */
    const int  *dims;
    mxArray    *tmp, *fout;
    char       *pdata;
    int        ifield, jstruct, *classIDflags;
    int        NStructElems, nfields, ndim;

    /* check proper input and output */
    if(nrhs!=1)
      mexErrMsgTxt("One input required.");
    else if(nlhs > 1)
      mexErrMsgTxt("Too many output arguments.");
    else if(!mxIsStruct(prhs[0]))
      mexErrMsgTxt("Input must be a structure.");
    /* get input arguments */
    nfields = mxGetNumberOfFields(prhs[0]);
    NStructElems = mxGetNumberOfElements(prhs[0]);
    /* allocate memory  for storing classIDflags */
    classIDflags = mxCalloc(nfields, sizeof(int));

    /* check empty field, proper data type, and data type consistency;
     and get classID for each field. */
    for(ifield=0; ifield<nfields; ifield++) {
	for(jstruct = 0; jstruct < NStructElems; jstruct++) {
	    tmp = mxGetFieldByNumber(prhs[0], jstruct, ifield);
	    if(tmp == NULL) {
		mexPrintf("%s%d\t%s%d\n", "FIELD: ", ifield+1, "STRUCT INDEX :", jstruct+1);
		mexErrMsgTxt("Above field is empty!"); 
	    } 
	    if(jstruct==0) {
		if( (!mxIsChar(tmp) && !mxIsNumeric(tmp)) || mxIsSparse(tmp)) { 
		    mexPrintf("%s%d\t%s%d\n", "FIELD: ", ifield+1, "STRUCT INDEX :", jstruct+1);
		    mexErrMsgTxt("Above field must have either string or numeric non-sparse data.");
		}
		classIDflags[ifield]=mxGetClassID(tmp); 
	    } else {
		if (mxGetClassID(tmp) != classIDflags[ifield]) {
		    mexPrintf("%s%d\t%s%d\n", "FIELD: ", ifield+1, "STRUCT INDEX :", jstruct+1);
		    mexErrMsgTxt("Inconsistent data type in above field!"); 
		} else if(!mxIsChar(tmp) && 
			  ((mxIsComplex(tmp) || mxGetNumberOfElements(tmp)!=1))){
		    mexPrintf("%s%d\t%s%d\n", "FIELD: ", ifield+1, "STRUCT INDEX :", jstruct+1);
		    mexErrMsgTxt("Numeric data in above field must be scalar and noncomplex!"); 
		}
	    }
	}
    }

    /* allocate memory  for storing pointers */
    fnames = mxCalloc(nfields, sizeof(*fnames));
    /* get field name pointers */
    for (ifield=0; ifield< nfields; ifield++){
	fnames[ifield] = mxGetFieldNameByNumber(prhs[0],ifield);
    }
    /* create a 1x1 struct matrix for output  */
    plhs[0] = mxCreateStructMatrix(1, 1, nfields, fnames);
    mxFree(fnames);
    ndim = mxGetNumberOfDimensions(prhs[0]);
    dims = mxGetDimensions(prhs[0]);
    for(ifield=0; ifield<nfields; ifield++) {
	/* create cell/numeric array */
	if(classIDflags[ifield] == mxCHAR_CLASS) {
	    fout = mxCreateCellArray(ndim, dims);
	}else {
	    fout = mxCreateNumericArray(ndim, dims, classIDflags[ifield], mxREAL);
	    pdata = mxGetData(fout);
	}
	/* copy data from input structure array */
	for (jstruct=0; jstruct<NStructElems; jstruct++) {
	    tmp = mxGetFieldByNumber(prhs[0],jstruct,ifield);
	    if( mxIsChar(tmp)) {
		mxSetCell(fout, jstruct, mxDuplicateArray(tmp));
	    }else {
		size_t     sizebuf;
		sizebuf = mxGetElementSize(tmp);
		memcpy(pdata, mxGetData(tmp), sizebuf);
		pdata += sizebuf;
	    }
	}
	/* set each field in output structure */
	mxSetFieldByNumber(plhs[0], 0, ifield, fout);
    }
    mxFree(classIDflags);
    return;
}
    
