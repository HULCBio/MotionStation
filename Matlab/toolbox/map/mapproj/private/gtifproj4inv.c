/*
 * GTIFPROJ4INV.MEX
 * 
 * This is a mex interface to the PROJ.4 library which
 * will return latitude and longitude values from 
 * X and Y inputs.
 * 
 *  The syntax:
 *  [LAT, LON] = GTIFPROJ4INV(GTIF, X, Y, ESPGDIRNAME, PROJDIRNAME)
 *
 * GTIF is the GTIFFINFO structure.
 * X is an array of the spatial X coordinates.
 * Y is an array of the spatial Y coordinates.
 * LAT is the returned latitude array.
 * LON is the returned longitude array.
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
 * Copyright 1996-2003 The MathWorks, Inc. 
 * $Revision: 1.1.6.1 $
 * $Date: 2003/08/01 18:24:18 $
 */

#include "geotiff_utils.h"
#include "tiff_utils.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    
/* The input data from MATLAB */
    const mxArray *xArray, *yArray;
    const mxArray *mxGTIFDef;

/* The output data for MATLAB */
    double *lat, *lon;

/* The Augmented GeoTiff definition structure */
    AugGTIFDefn *GS;

/* The GTIFDefn object */
    GTIFDefn gtif;

/* The index of the inputs */
    int index;

/* The X data for input */
    double *X;

/* The Y data for input */
    double *Y;

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
    /* mexPrintf("Using local version of gfwdtran\n"); */
    if (nrhs != 5) {
       mexErrMsgIdAndTxt( "map:gtifproj4inv:incorrectInputArgCount",
                          "Incorrect number of input arguments.");
    }      
    if (nlhs != 2) {
        mexErrMsgIdAndTxt( "map:gtifproj4inv:incorrectOutputArgCount",
                           "Incorrect number of output arguments.");
    }      

/**
 * Assign the inputs from the input MATLAB arguments
 */
    index = 0;
    mxGTIFDef = prhs[index];

    index++;
    xArray    = prhs[index];

    index++;
    yArray    = prhs[index];

    index++;
    epsgDirName = getTIFFFilename(prhs[index]);
    index++;
    projDirName = getTIFFFilename(prhs[index]);
    setMW_EpsgDirName(epsgDirName);
    setMW_ProjDirName(projDirName);

/**
 * Get the X and Y data
 */
    X = (double*)mxGetData(xArray);
    Y = (double*)mxGetData(yArray);
    npts = mxGetNumberOfElements(xArray);

/**
 * Set up the lat and lon return values
 */ 
    dimension[0] = 1;
    dimension[1] = npts;
    dims = &dimension[0];
    plhs[0] = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    lat = (double*)mxGetData(plhs[0]);
    lon = (double*)mxGetData(plhs[1]);

/**
 * Create the GTIFDefn object
 */
    GS  = mxArray2GTIFDef(mxGTIFDef);
    gtif = AugGTIFDefnToGTIFDefn(GS);

/**
 * Convert the X and Y values to LAT and LON values
 */
    mxGTIFProj4ToLatLong( &gtif, npts, X, Y, lon, lat);

/**
 * Free memory
 */
    _GTIFFree(GS);
    return;
}

