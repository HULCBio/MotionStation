/*
 * cdfutilc.h
 *
 * Utility routines for CDF.
 *
 * Calls the CDF library which is distributed by the National Space Science
 * Data Center and available from
 * ftp://nssdcftp.gsfc.nasa.gov/standards/cdf/dist/cdf27/unix/cdf27-dist-all.tar.gz 
 * 
 * Copyright 1984-2001 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:49 $
 */


#ifndef CDF_H
#define CDF_H

#include "cdf.h"
#include "mex.h"

void      msg_handler(CDFstatus);
mxArray * epoch_to_ML_datestr(double);

#endif
