/*
 * cdfutilc.c
 *
 * Utility routines for CDF.
 *
 * Calls the CDF library which is distributed by the National Space Science
 * Data Center and available from
 * ftp://nssdcftp.gsfc.nasa.gov/standards/cdf/dist/cdf27/unix/cdf27-dist-all.tar.gz 
 * 
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:48 $
 */


#include "cdf.h"
#include "cdfutils.h"
#include "mex.h"

void msg_handler(CDFstatus status) {

    char msg_text[CDF_STATUSTEXT_LEN + 1];

    /* Get status message from CDF library. */
    CDFlib(SELECT_, CDF_STATUS_, status,
           GET_, STATUS_TEXT_, msg_text,
           NULL_);

    if (status < CDF_WARN) {
        
        /* Error status. */
        CDFlib(CLOSE_, CDF_, NULL_);
        mexErrMsgTxt(msg_text);
    
    } else if (status < CDF_OK) {

        mexWarnMsgTxt(msg_text);

    }
        
}


mxArray * epoch_to_ML_datestr(double epoch_date) {

    char datestr[EPOCHx_STRING_MAX];

    encodeEPOCHx(epoch_date, 
                 "<dom.02>-<month>-<year> <hour>:<min>:<sec>.<fos>",
                 datestr);

    return mxCreateString(datestr);

}


