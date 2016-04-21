/*
 * SDTSMEX.CPP
 * 
 * This is the mex interface to the SDTS++ Library for reading SDTS
 * information and data into MATLAB.
 * In its current implementation, there is only support for reading
 * raster data sets.
 *
 * SYNTAX:
 *   [INFO, DATA] = SDTSMEX(FILENAME);
 *
 * DESCRIPTION:
 *   SDTSMEX returns a MATLAB structure, INFO containing information
 *   about the data set.  Optionally, it will return the DEM data 
 *   contained in the data set.  
 *   FILENAME is the name of the Catalog/Directory Module file for the
 *   SDTS transfer, including the path to the file if it is not in the
 *   current directory.  The Catalog/Directory module file name will 
 *   contain the base name (4 characters) followed by "CATD.DDF" e.g. 
 *     7783CATD.DDF.
 *
 * $Revision : $
 * $Date: 2003/08/01 18:23:48 $
 */

#include <string>
#include <cctype>
#include "mex.h"
#include "MwSDTSDEM.h"

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  std::string filename;
  MwSDTSDEM tObj;
  bool readdata;

  // Check arguments
  if (nrhs != 1)
    mexErrMsgIdAndTxt("Mapping:sdtsmex:invalidNumInArgs",
		      "Invalid number of input arguments.");
  
  if(nlhs > 2)
    mexErrMsgIdAndTxt("Mapping:sdtsmex:invalidNumOutArg",
		      "Too many output arguments.");
  
  readdata = (nlhs == 2);
  
  filename.assign(mxArrayToString(prhs[0]));
  
  // Open catalog file and load modules
  if(!tObj.open(filename))
    mexErrMsgIdAndTxt("Mapping:sdtsmex:SDTSerr",
		      tObj.getErrMsgTxt().c_str());
  
  string tmpStr;
  if (!tObj.loadInfo()) {
    tmpStr = tObj.getErrMsgTxt();
    mexErrMsgIdAndTxt("Mapping:sdtsmex:SDTSerr", tmpStr.c_str());
  }
			  
  
  plhs[0] = tObj.getMxInfoStruct();
  
  if (!readdata || !tObj._isRaster) {
    if (readdata)
      plhs[1] = mxCreateDoubleMatrix(0,0,mxREAL);
    return;
  }
  
  // load the elevation data from the cell module
  if (!tObj.loadCell())  
    mexErrMsgIdAndTxt("Mapping:sdtsmex:SDTSerr",
		      tObj.getErrMsgTxt().c_str());
  
  plhs[1] = tObj.getMxDemData();
  
  return;

}
