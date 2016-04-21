/* Copyright 1984-2002 The MathWorks, Inc.  */

/*
 * hdfml.c --- support file for HDF.MEX
 *
 * This module supports the HDF ML interface.  This interface is not
 * really a part of the HDF API; rather, it controls certain aspects
 * of the MATLAB gateway to the HDF API. The only public
 * function is hdfML(), which is called by mexFunction().
 * hdfML looks at the second input argument to determine which
 * private function should get control.
 *
 * Syntaxes
 * ========
 * hdf('ML', 'closeall')
 * hdf('ML', 'listinfo')
 * nbytes = hdf('ML', 'sizeof', data_type)
 * tagnum = hdf('ML', 'tagnum', tagstr)
 * hdf('ML','defaultchartype', char_type)
 *
 */

/* $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:02:15 $ */

static char rcsid[] = "$Id: hdfml.c,v 1.1.6.1 2003/12/13 03:02:15 batserve Exp $";

#include <string.h>

/* Main HDF library header file */
#include "hdf.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfml.h"

/*
 * hdfMLcloseall
 *
 * Purpose: terminate access to all open HDF identifiers and clean
 *          up the identifier tracking lists.
 *
 * MATLAB usage:
 * hdf('ML', 'closeall')
 */
static void hdfMLcloseall(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
	if (nlhs > 0)
            mexErrMsgTxt("Too many output arguments.");
		
    haQuietCleanup();
}

/*
 * hdfMLlistinfo
 *
 * Purpose: print information about the state of the gateway
 *          identifier lists to the MATLAB command window.
 *
 * MATLAB usage:
 * hdf('ML', 'listinfo')
 */
static void hdfMLlistinfo(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
	if (nlhs > 0)
	    mexErrMsgTxt("Too many output arguments.");
		
    haPrintIDListInfo();
}

/*
 * hdfMLtagnum
 *
 * Purpose: return integer corresponding to tag string
 *
 * MATLAB usage:
 * tagnum = hdf('ML','tagnum',tagstr)
 * 
 */
static void hdfMLtagnum(int nlhs,
           mxArray *plhs[],
           int nrhs,
           const mxArray *prhs[])
{
    struct {
    	char *name;
        uint16 value;
    } tagPairs[] = {
        {"DFREF_WILDCARD",DFREF_WILDCARD},
        {"DFTAG_WILDCARD",DFTAG_WILDCARD},
        {"DFTAG_NULL",DFTAG_NULL},
        {"DFTAG_LINKED",DFTAG_LINKED},
        {"DFTAG_VERSION",DFTAG_VERSION},
        {"DFTAG_COMPRESSED",DFTAG_COMPRESSED},
        {"DFTAG_VLINKED",DFTAG_VLINKED},
        {"DFTAG_VLINKED_DATA",DFTAG_VLINKED_DATA},
        {"DFTAG_CHUNKED",DFTAG_CHUNKED},
        {"DFTAG_CHUNK",DFTAG_CHUNK},
        {"DFTAG_FID",DFTAG_FID},
        {"DFTAG_FD",DFTAG_FD},
        {"DFTAG_TID",DFTAG_TID},
        {"DFTAG_TD",DFTAG_TD},
        {"DFTAG_DIL",DFTAG_DIL},
        {"DFTAG_DIA",DFTAG_DIA},
        {"DFTAG_NT",DFTAG_NT},
        {"DFTAG_MT",DFTAG_MT},
        {"DFTAG_FREE",DFTAG_FREE},
        {"DFTAG_ID8",DFTAG_ID8},
        {"DFTAG_IP8",DFTAG_IP8},
        {"DFTAG_RI8",DFTAG_RI8},
        {"DFTAG_CI8",DFTAG_CI8},
        {"DFTAG_II8",DFTAG_II8},
        {"DFTAG_ID",DFTAG_ID},
        {"DFTAG_LUT",DFTAG_LUT},
        {"DFTAG_RI",DFTAG_RI},
        {"DFTAG_CI",DFTAG_CI},
        {"DFTAG_NRI",DFTAG_NRI},
        {"DFTAG_RIG",DFTAG_RIG},
        {"DFTAG_LD",DFTAG_LD},
        {"DFTAG_MD",DFTAG_MD},
        {"DFTAG_MA",DFTAG_MA},
        {"DFTAG_CCN",DFTAG_CCN},
        {"DFTAG_CFM",DFTAG_CFM},
        {"DFTAG_AR",DFTAG_AR},
        {"DFTAG_DRAW",DFTAG_DRAW},
        {"DFTAG_RUN",DFTAG_RUN},
        {"DFTAG_XYP",DFTAG_XYP},
        {"DFTAG_MTO",DFTAG_MTO},
        {"DFTAG_T14",DFTAG_T14},
        {"DFTAG_T105",DFTAG_T105},
        {"DFTAG_SDG",DFTAG_SDG},
        {"DFTAG_SDD",DFTAG_SDD},
        {"DFTAG_SD",DFTAG_SD},
        {"DFTAG_SDS",DFTAG_SDS},
        {"DFTAG_SDL",DFTAG_SDL},
        {"DFTAG_SDU",DFTAG_SDU},
        {"DFTAG_SDF",DFTAG_SDF},
        {"DFTAG_SDM",DFTAG_SDM},
        {"DFTAG_SDC",DFTAG_SDC},
        {"DFTAG_SDT",DFTAG_SDT},
        {"DFTAG_SDLNK",DFTAG_SDLNK},
        {"DFTAG_NDG",DFTAG_NDG},
        {"DFTAG_CAL",DFTAG_CAL},
        {"DFTAG_FV",DFTAG_FV},
        {"DFTAG_BREQ",DFTAG_BREQ},
        {"DFTAG_SDRAG",DFTAG_SDRAG},
        {"DFTAG_EREQ",DFTAG_EREQ},
        {"DFTAG_VG",DFTAG_VG},
        {"DFTAG_VH",DFTAG_VH},
        {"DFTAG_VS",DFTAG_VS},
        {"DFTAG_RLE",DFTAG_RLE},
        {"DFTAG_IMC",DFTAG_IMC},
        {"DFTAG_IMCOMP",DFTAG_IMCOMP},
        {"DFTAG_JPEG",DFTAG_JPEG},
        {"DFTAG_GREYJPEG",DFTAG_GREYJPEG},
        {"DFTAG_JPEG5",DFTAG_JPEG5},
        {"DFTAG_GREYJPEG5",DFTAG_GREYJPEG5},
    };

    int numPairs = sizeof(tagPairs) / sizeof(*tagPairs);
    int i = 0;
    uint16 tagnum = 0;
    int found = 0;
    char *tagStr;

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);

    tagStr = haGetString(prhs[2],"Tag string");

    for (i = 0; i < numPairs; i++)
    {
        if (strcmp(tagStr, tagPairs[i].name) == 0)
        {
            tagnum = tagPairs[i].value;
            found = 1;
            break;
        }
    }

    if (found == 1)
    {
        plhs[0] = haCreateDoubleScalar(tagnum);
    }
    else
    {
        plhs[0] = EMPTY;
    }
    mxFree(tagStr);
}

/*
 * hdfMLsizeof
 *
 * Purpose: return number of bytes for a given data_type
 *
 * MATLAB usage:
 * nbytes = hdf('ML', 'sizeof', data_type)
 */
static void hdfMLsizeof(int nlhs,
                          mxArray *plhs[],
                          int nrhs,
                          const mxArray *prhs[])
{
    int32 data_type;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    data_type = haGetDataType(prhs[2]);
    
    plhs[0] = haCreateDoubleScalar(DFKNTsize(data_type));
}

/*
 * hdfMLdefaultchartype
 *
 * Purpose: Map MATLAB strings to unsigned 8-bit 
 * characters or signed 8-bit characters.  The default 
 * is signed 8-bit characters (char8).
 *
 * MATLAB usage:
 * hdf('ML','defaultchartype','uchar8')
 * hdf('ML','defaultchartype','char8')
 */
static void hdfMLdefaultchartype(int nlhs,
                                   mxArray *plhs[],
                                   int nrhs,
                                   const mxArray *prhs[])
{
    char *type;
    intn stat;
  
    haNarginChk( 3, 3, nrhs);
    haNargoutChk( 0, 0, nlhs);

    type = haGetString(prhs[2],"Character type" );

    if ( strcmp(type,"uchar8") == 0 )
        stat = haMakeUChar8First();
    else if ( strcmp(type,"char8") == 0 )
        stat = haMakeChar8First();
    else
        mexErrMsgTxt("Character type must be 'uchar8' or 'char8'.\n");

    if ( stat == FAIL )
        mexWarnMsgTxt("Failed to change default character type.\n");

    mxFree(type);
}


/*
 * hdfML
 *
 * Purpose: Function switchyard for the ML part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which ML function to call
 * Outputs: none
 * Return:  none
 */
void hdfML(int nlhs,
           mxArray *plhs[],
           int nrhs,
           const mxArray *prhs[],
           char *functionStr)
{
    typedef void (MATLAB_FCN)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);
    struct {
    	char *name;
    	MATLAB_FCN *func;
    } MLFcns[] = {
        {"closeall",    hdfMLcloseall},
        {"listinfo",    hdfMLlistinfo},
        {"tagnum",      hdfMLtagnum},
        {"sizeof",      hdfMLsizeof},
        {"defaultchartype", hdfMLdefaultchartype}
    };
    int numFcns = sizeof(MLFcns) / sizeof(*MLFcns);
    int i;
    bool found = false;
    
    for (i = 0; i < numFcns; i++)
    {
        if (haStrcmpi(functionStr,MLFcns[i].name)==0)
        {
            (*(MLFcns[i].func))(nlhs, plhs, nrhs, prhs);
            found = true;
            break;
        }
    }

    if (! found)
    {
        mexErrMsgTxt("Unknown HDF ML interface function.");
    }
}
