/* Copyright 1984-2002 The MathWorks, Inc.  */
/* $Revision: 1.1.6.1 $ */

static char rcsid[] = "$Id: hdfeh.c,v 1.1.6.1 2003/12/13 03:01:56 batserve Exp $";

/* Main HDF library header file */
#include "hdf.h"

/* HDF-EOS header file */
#include "HdfEosDef.h"

/* MATLAB API header file */
#include "mex.h"

/* HDFMEX utility functions */
#include "hdfutils.h"

#include "hdfeh.h"

/*
 * GetConversionCode
 *
 * Purpose: Given MATLAB string array, return HDF access mode flag value
 *
 * Inputs:  inStr --- MATLAB string array
 * Outputs: none
 * Return:  HDF access mode flag value; errors out if none found
 */
static
intn GetConversionCode(const mxArray *inStr)
{
    static struct 
    {
        char *conversionStrLong;
        char *conversionStrShort;
        intn conversionCode;
    }
    angleConversionCodes[] = 
    {
        {"hdfe_rad_deg",   "rad_deg",    HDFE_RAD_DEG},
        {"hdfe_deg_rad",   "deg_rad",    HDFE_DEG_RAD},
        {"hdfe_dms_deg",   "dms_deg",    HDFE_DMS_DEG},
        {"hdfe_deg_dms",   "deg_dms",    HDFE_DEG_DMS},
        {"hdfe_rad_dms",   "rad_dms",    HDFE_RAD_DMS},
        {"hdfe_dms_rad",   "dms_rad",    HDFE_DMS_RAD},
        {"",               "",          -1}    /* this one must be last! */
    };

#define BUFLEN 32
    char buffer[BUFLEN];
    intn conversionCode;
    int k = 0;
    bool codeFound = false;

    if (!mxIsChar(inStr))
    {
        mexErrMsgTxt("Angle conversion code must be a string.");
    }
    
    mxGetString(inStr, buffer, BUFLEN);
    while (angleConversionCodes[k].conversionStrLong != NULL)
    {
        if ((haStrcmpi(buffer, angleConversionCodes[k].conversionStrShort) == 0) ||
            (haStrcmpi(buffer, angleConversionCodes[k].conversionStrLong) == 0))
        {
            conversionCode = angleConversionCodes[k].conversionCode;
            codeFound = true;
            break;
        }
        k++;
    }
    
    if (! codeFound)
    {
        mexErrMsgTxt("Invalid angle conversion code.");
    }

    return(conversionCode);
}


/*
 * hdfEHconvang
 *
 * Purpose: gateway to EHconvAng()
 *          Returns angle in desired units
 *
 * MATLAB usage:
 * newangle = hdf('EH','convang',angle,conversion_code)
 *            conversion_codes are HDFE_RAD_DEG, HDFE_DEG_RAD,
 *            HDFE_DMS_DEG, HDFE_DEG_DMS, HDFE_RAD_DMS, and HDFE_DMS_RAD.
 */
static void hdfEHconvang(int nlhs,
                            mxArray *plhs[],
                            int nrhs,
                            const mxArray *prhs[])
{
    float64 in_angle;
    float64 out_angle;
    intn conversion_code;
    
    haNarginChk(4, 4, nrhs);
    haNargoutChk(0, 1, nlhs);
    
    in_angle = haGetDoubleScalar(prhs[2], "Angle");
    conversion_code = GetConversionCode(prhs[3]);
    
    out_angle = EHconvAng(in_angle, conversion_code);
    
    plhs[0] = haCreateDoubleScalar(out_angle);
}

#define VERSION_LENGTH 16  /* according to example in reference doc */

/*
 * hdfEHgetversion
 *
 * Purpose: gateway to EHgetversion()
 *          Returns HDF-EOS version string in an HDF-EOS file.
 *
 * MATLAB usage:
 * [version,status] = hdf('EH','getversion',fid)
 */
static void hdfEHgetversion(int nlhs,
                               mxArray *plhs[],
                               int nrhs,
                               const mxArray *prhs[])
{
    int32 fid;
    intn status;
    char version[VERSION_LENGTH];

    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 2, nlhs);
    
    fid = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    
    status = EHgetversion(fid, version);
    
    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    else
    {
        plhs[0] = mxCreateString(version);
    }
    
    if (nlhs > 1)
    {
        plhs[1] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfEHidinfo
 *
 * Purpose: gateway to EHidinfo()
 *          Get HDF file IDs.
 *
 * MATLAB usage:
 * [hdf_fid, sd_fid, status] = hdf('EH','idinfo',fid)
 */
static void hdfEHidinfo(int nlhs,
                           mxArray *plhs[],
                           int nrhs,
                           const mxArray *prhs[])
{
    int32 fid;
    int32 hdf_fid;
    int32 sd_fid;
    intn status;
    
    haNarginChk(3, 3, nrhs);
    haNargoutChk(0, 3, nlhs);
    
    fid = (int32) haGetDoubleScalar(prhs[2], "File identifier");
    
    status = EHidinfo(fid, &hdf_fid, &sd_fid);
    
    if (status == FAIL)
    {
        plhs[0] = EMPTY;
    }
    else
    {
        plhs[0] = haCreateDoubleScalar((double) hdf_fid);
    }
    
    if (nlhs > 1)
    {
        if (status == FAIL)
        {
            plhs[0] = EMPTY;
        }
        else
        {
            plhs[0] = haCreateDoubleScalar((double) sd_fid);
        }
    }
    
    if (nlhs > 2)
    {
        plhs[2] = haCreateDoubleScalar((double) status);
    }
}

/*
 * hdfEH
 *
 * Purpose: Function switchyard for the HDF-EOS EH part of the HDF gateway.
 *
 * Inputs:  nlhs --- number of left-side arguments
 *          plhs --- left-side arguments
 *          nrhs --- number of right-side arguments
 *          prhs --- right-side arguments
 *          functionStr --- string specifying which EH function to call
 * Outputs: none
 * Return:  none
 */
void hdfEH(int nlhs,
              mxArray *plhs[],
              int nrhs,
              const mxArray *prhs[],
              char *functionStr)
{
    typedef void (MATLAB_FCN)(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[]);
    static struct {
    	char *name;
    	MATLAB_FCN *func;
    } EHFcns[] = {
        {"convang",           hdfEHconvang},
        {"getversion",        hdfEHgetversion},
        {"idinfo",            hdfEHidinfo}
    };
    static int numFunctions = sizeof(EHFcns) / sizeof(*EHFcns);
    int i = 0;
    bool found = false;

    for (i = 0; i < numFunctions; i++)
    {
        if (strcmp(functionStr,EHFcns[i].name)==0)
        {
            (*(EHFcns[i].func))(nlhs, plhs, nrhs, prhs);
            found = true;
            break;
        }
    }

    if (! found)
    {
        mexErrMsgTxt("Unknown HDF-EOS EH interface function.");
    }
}
