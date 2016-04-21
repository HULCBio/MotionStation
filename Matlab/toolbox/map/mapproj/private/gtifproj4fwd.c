/*
 * GTIFPROJ4FWD.MEX
 * 
 * This is a mex interface to the PROJ.4 library which
 * will return spatial X and Y coordinates from 
 * latitude and longitude inputs.
 * 
 *  The syntax:
 *  [X, Y] = GTIFPROJ4FWD(GTIF, LON, LAT, ESPGDIRNAME, PROJDIRNAME)
 *
 * GTIF is the GTIFFINFO structure.
 * LAT is the array of latitude array.
 * LON is the array longitude array.
 * X is the returned array of spatial X coordinates.
 * Y is the returned array of spatial Y coordinates.
 * EPSGDIRNAME is the name of the EPSG directory
 * PROJDIRNAME is the name of the EPSG directory
 *
 * The field names of the GTIFINFO structure are defined in
 * the following table:
 *
 *  Field Name Data Type Size
 * Model char variable
 * PCS char variable
 * GCS char variable
 * UOMLength char variable
 * UOMAngle char variable
 * UOMAngleInMeters double variable
 * UOMAngleInDegrees double 
 * Datum char variable 
 * PM char variable 
 * PMLongToGreenwich double 
 * Ellipsoid char variable 
 * SemiMajor double 
 * SemiMinor double 
 * Projection char variable 
 * CTProjection char variable 
 * ProjParm double N-by-1 
 * ProjParmId char cell N-by-variable 
 * TiePoints double N-by-1 
 * PixelScale double N-by-1 
 * TransMatrix double N-by-1 
 * MapSys char variable 
 * Zone double 
 * Width double 
 * Height double 
 * GTIFCornerCoords structure 
 * GeoTiffCodes structure (INT16)
 * (The GeoTiffCodes MUST be INT16.)
 *
 *
 * All of the fields in the GTIFINFO structure are currently not required.
 * The minimum requirement for a GeoTiff file to be written is that
 * the GeoTiffCodes field is a structure.
 *
 * The following fields are required:
 * GeoTiffCodes (all fields)
 * GeoTiffCodes.UOMLength
 * GeoTiffCodes.UOMLengthInMeters
 * GeoTiffCodes.CTProjection
 * GeoTiffCodes.Ellipsoid
 * ProjParm
 * SemiMajor (if set will use)
 * SemiMior  (if set will use)
 *
 * All other fields are currently not used.
 *
 *
 * Copyright 1996-2003 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $
 * $Date: 2003/08/01 18:24:17 $
 */

#include "geotiff_utils.h"
#include "tiff_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    
/* The input data from MATLAB */
    const mxArray *latArray;
    const mxArray *lonArray;
    const mxArray *mxGTIFDef;

/* The output data for MATLAB */
    double *x, *y;

/* The Augmented GeoTiff definition structure */
    AugGTIFDefn *GS;

/* The GTIFDefn object */
    GTIFDefn gtif;

/* The index of the inputs */
    int index;

/* The X data for input */
    double *LAT;

/* The Y data for input */
    double *LON;

/* The input EPSG directory name */
    char *epsgDirName;

/* The input PROJ directory name */
    char *projDirName;


/* The dimension variables */
    const int *dims;
    int dimension[2];
    int ndim;
    int npts;

/* A counter */
    int i;
    
/**
 * Check the number of input arguments
 */
    /*mexPrintf("Using local version of geofwdtran\n"); */
    if (nrhs != 5) {
        mexErrMsgIdAndTxt( "map:gtifproj4fwd:incorrectInputArgCount",
                           "Incorrect number of input arguments.");
    }      
    if (nlhs != 2) {
        mexErrMsgIdAndTxt( "map:gtifproj4fwd:incorrectOutputArgCount",
                           "Incorrect number of output arguments.");
    }      

/**
 * Assign the inputs from the input MATLAB arguments
 */
    index = 0;
    mxGTIFDef = prhs[index];

    index++;
    lonArray    = prhs[index];

    index++;
    latArray    = prhs[index];

    index++;
    epsgDirName = getTIFFFilename(prhs[index]);
    index++;
    projDirName = getTIFFFilename(prhs[index]);
    setMW_EpsgDirName(epsgDirName);
    setMW_ProjDirName(projDirName);

/**
 * Get the X and Y data
 */
    LON = (double*) mxGetData(lonArray);
    LAT = (double*) mxGetData(latArray);
    npts = mxGetNumberOfElements(lonArray);

/**
 * Set up the lat and lon return values
 */ 
    dimension[0] = 1;
    dimension[1] = npts;
    dims = &dimension[0];
    plhs[0] = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    x = (double*) mxGetData(plhs[0]);
    y = (double*) mxGetData(plhs[1]);

/**
 * Create the GTIFDefn object
 */
    GS  = mxArray2GTIFDef(mxGTIFDef);
    gtif = AugGTIFDefnToGTIFDefn(GS);
    /* mexPrintf("CTProjection : %d\n",gtif.CTProjection);  */

/**
 * Convert the X and Y values to LAT and LON values
 */
    mxGTIFProj4FromLatLong( &gtif, npts, LON, LAT, x, y);

/**
 * Free memory
 */
    _GTIFFree(GS);
    return;
}

