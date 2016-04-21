/*
 * GTIFINFO.MEX
 * 
 * This is a MEX function to read and return the GeoTiff information 
 * embedded in the TIFF tags of a file.   This function is intended 
 * to be a thin-layer between MATLAB and the GeoTiff libraries and 
 * returns the GeoTiff information with limited modification.
 * 
 *
 * Syntax
 *
 * S = GTIFINFO(FILENAME)
 *
 * Description
 *
 * S = GTIFINFO(FILENAME) reads the GeoTiff FILENAME and returns the 
 * GeoTiff cartographic information in a MATLAB structure S .
 *
 * Input Parameter
 * FILENAME is a string that specifies the name of the GeoTiff file. 
 *
 * Copyright 2002 The MathWorks, Inc. 
 * $Revision: 1.1.10.2 $
 * $Date: 2003/08/01 18:23:41 $
 *
 */

#include "geotiff_utils.h"
#include "tiff_utils.h"

/** 
 * Buffer for error handler
 */
static char *ERROR_BUFFER;

/**
 * ErrHandler resets TIFF output to the provided function.
 */
static void ErrHandler(const char *, const char *, va_list);

/**
 * WarnHandler resets TIFF output to the provided function.
 */
static void WarnHandler(const char *, const char *, va_list);

/**
 * getMXGTIFDef returns a mxArray representing the AugGTIFDefn 
 * structure.
 *
 * @param GS the input Augmented GTIF definition
 * @return mxArray the MATLAB structure
 */
static mxArray* getMxGTIFDef(const AugGTIFDefn* GS);

/**
 * getMXGTIFCodes will construct an mxArray representing
 * the GTIFCodes structure in the AugGTIDefn pointer.
 *
 * @param GS the input Augmented GTIF definition
 * @return mxArray the MATLAB structure for the GTIFCodes
 *
 */
static mxArray* getMxGTIFCodes(const AugGTIFDefn* GS);

/**
 * getMXGTIFCorners will construct an mxArray representing
 * the GTIFCorners structure in the AugGTIDefn pointer.
 *
 * @param GS the input Augmented GTIF definition
 * @return mxArray the MATLAB structure for the GTIFCorners
 *
 */
static mxArray* getMxGTIFCorners(const AugGTIFDefn* GS);

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {
    
/* The Augmented GeoTiff definition structure to return to MATLAB */
    AugGTIFDefn *GS;

/* The input filename */
    char *filename;

/* The input EPSG directory name */
    char *epsgDirName;

/* The input PROJ directory name */
    char *projDirName;

/**
 * Check the number of input arguments
 */
    if ( nrhs != 3 ) 
      mexErrMsgIdAndTxt("map:geotiffinfo:invalidInputs",
                        "Illegal number of input arguments.");

/**
 * Set the handlers to write TIFF warnings and error with MEX functions
 */
    TIFFSetErrorHandler(ErrHandler);
    TIFFSetWarningHandler(WarnHandler);
    ERROR_BUFFER = NULL;

/**
 * Get the input names and set the EPSG and PROJ directory names
 */
    filename    = getTIFFFilename(prhs[0]);
    epsgDirName = getTIFFFilename(prhs[1]);
    projDirName = getTIFFFilename(prhs[2]);
    setMW_EpsgDirName(epsgDirName);
    setMW_ProjDirName(projDirName);

/*
 *  mexPrintf("Filename is %s\n", filename); 
 *  mexPrintf("EPSG dirname is %s\n", epsgDirName); 
 *  mexPrintf("Proj dirname is %s\n", projDirName); 
 */

/**
 * Read the GeoTiff keys 
 */
    GS = read_geotiff(filename);
    if (ERROR_BUFFER != NULL) {
      mxFree((void *) filename);
      mexErrMsgIdAndTxt("map:geotiffinfo:tiffError",
                        ERROR_BUFFER);
    }

/**
 * Get the Mex GTIFDef structure to return to MATLAB
 */
    plhs[0] = getMxGTIFDef(GS);
    
/**
 * Free memory
 */
    _GTIFFree(GS);
    return;
}


/*******************************************/
static void ErrHandler(const char *module, 
                       const char *fmt, va_list ap)
{

    char *cp;
    char *buf;

    buf = cp = (char *) mxMalloc(2048 * sizeof(char));

    if (module != NULL) {
      sprintf(cp, "%s: ", module);
      cp = (char *) strchr(cp, '\0');
    }

    vsprintf(cp, fmt, ap);
    strcat(cp, ".");

    ERROR_BUFFER = buf;
}

/*******************************************/
void WarnHandler(const char *module,
                 const char *fmt, va_list ap)
{
    char *cp;
    char *buf;
    buf = cp = (char *) mxMalloc(2048 * sizeof(char));

    vsprintf(cp, fmt, ap);
    strcat(cp, ".");

    mexWarnMsgIdAndTxt("map:geotiffinfo:tiffWarning",buf);
    mxFree((void *) buf);
}


static mxArray* getMxGTIFDef(const AugGTIFDefn* GS) {
    mxArray *mxGTIFDef;
    mxArray *mxGTIFCodes;
    mxArray *mxGTIFCorners;
    int nfields;
    const char *fnames[] = {
                            "Model",
                            "PCS",
                            "GCS",
                            "UOMLength",
                            "UOMLengthInMeters",
                            "UOMAngle",
                            "UOMAngleInDegrees",
                            "Datum",
                            "PM",
                            "PMLongToGreenwich",
                            "Ellipsoid",
                            "SemiMajor",
                            "SemiMinor",
                            "Projection",
                            "CTProjection",
                            "ProjParm",
                            "ProjParmId",
                            "TiePoints",
                            "PixelScale",
                            "TransMatrix",
                            "WorldFileMatrix",
                            "MapSys",
                            "Zone",
                            "Width",
                            "Height",
                            "GTIFCornerCoords",
                            "GeoTIFFCodes"
                           };
    const int *dims;
    int dimension[2];
    mxArray *dblArray;
    mxArray *cellArray;
    double *dblVal;
    int i;

    nfields = (sizeof(fnames)/sizeof(*fnames));
    dimension[0] = 1;
    dimension[1] = 1;
    dims = &dimension[0];

/**
 * Create the return MATLAB structure 
 * representing the AugGTIFDefn structure
 */
    mxGTIFDef = mxCreateStructMatrix(1, 1, nfields, fnames);
    mxGTIFCorners = getMxGTIFCorners(GS);
    mxGTIFCodes = getMxGTIFCodes(GS);

    mxSetField(mxGTIFDef, 0, "GTIFCornerCoords", mxGTIFCorners);
    mxSetField(mxGTIFDef, 0, "GeoTIFFCodes", mxGTIFCodes);
    mxSetField(mxGTIFDef, 0, "Model", mxCreateString(GS->Model)); 
    mxSetField(mxGTIFDef, 0, "PCS", mxCreateString(GS->PCS)); 
    mxSetField(mxGTIFDef, 0, "GCS", mxCreateString(GS->GCS)); 
    mxSetField(mxGTIFDef, 0, "UOMLength", mxCreateString(GS->UOMLength)); 
    mxSetField(mxGTIFDef, 0, "UOMAngle", mxCreateString(GS->UOMAngle)); 
    mxSetField(mxGTIFDef, 0, "Datum", mxCreateString(GS->Datum)); 
    mxSetField(mxGTIFDef, 0, "PM", mxCreateString(GS->PM)); 
    mxSetField(mxGTIFDef, 0, "Ellipsoid", mxCreateString(GS->Ellipsoid)); 
    mxSetField(mxGTIFDef, 0, "Projection", mxCreateString(GS->Projection)); 
    mxSetField(mxGTIFDef, 0, "CTProjection", mxCreateString(GS->CTProjection)); 
    mxSetField(mxGTIFDef, 0, "MapSys", mxCreateString(GS->MapSys)); 
    mxSetField(mxGTIFDef, 0, "UOMLengthInMeters", 
                             mxCreateDoubleScalar(GS->UOMLengthInMeters));
    mxSetField(mxGTIFDef, 0, "UOMAngleInDegrees", 
                             mxCreateDoubleScalar(GS->UOMAngleInDegrees));
    mxSetField(mxGTIFDef, 0, "PMLongToGreenwich", 
                             mxCreateDoubleScalar(GS->PMLongToGreenwich));
    mxSetField(mxGTIFDef, 0, "SemiMajor", 
                             mxCreateDoubleScalar(GS->SemiMajor));
    mxSetField(mxGTIFDef, 0, "SemiMinor", 
                             mxCreateDoubleScalar(GS->SemiMinor));
    mxSetField(mxGTIFDef, 0, "Zone", 
                             mxCreateDoubleScalar(GS->Zone));
    mxSetField(mxGTIFDef, 0, "Width", 
                             mxCreateDoubleScalar(GS->ImageWidth));
    mxSetField(mxGTIFDef, 0, "Height", 
                             mxCreateDoubleScalar(GS->ImageHeight));

    dimension[0] = GS->nParms;
    dimension[1] = 1;
    cellArray = mxCreateCellMatrix(GS->nParms, 1); 
    for (i = 0 ; i < GS->nParms; i++) {
       mxSetCell(cellArray, i, mxCreateString(GS->ProjParmId[i]));  
     }
    mxSetField(mxGTIFDef, 0, "ProjParmId", cellArray);

    dblArray = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < GS->nParms; i++)
      dblVal[i] =  GS->ProjParm[i];
    mxSetField(mxGTIFDef, 0, "ProjParm", dblArray);

    dimension[0] = GS->TiePointCount;
    dimension[1] = 1;
    if (dimension[0] == 0) dimension[1] = 0;
    dblArray = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < GS->TiePointCount; i++)
      dblVal[i] =  GS->TiePoints[i];
    mxSetField(mxGTIFDef, 0, "TiePoints", dblArray);

    dimension[0] = GS->PixelScaleCount;
    dimension[1] = 1;
    if (dimension[0] == 0) dimension[1] = 0;
    dblArray = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < GS->PixelScaleCount; i++)
      dblVal[i] =  GS->PixelScale[i];
    mxSetField(mxGTIFDef, 0, "PixelScale", dblArray);

    dimension[0] = GS->TransMatrixCount;
    dimension[1] = 1;
    if (dimension[0] == 0) dimension[1] = 0;
    dblArray = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < GS->TransMatrixCount; i++)
      dblVal[i] =  GS->TransMatrix[i];
    mxSetField(mxGTIFDef, 0, "TransMatrix", dblArray);

    dimension[0] = 6;
    dimension[1] = 1;
    dblArray = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < 6; i++) {
      dblVal[i] =  GS->WorldFileMatrix[i];
    }
    mxSetField(mxGTIFDef, 0, "WorldFileMatrix", dblArray);

    return mxGTIFDef;

}

static mxArray* getMxGTIFCodes(const AugGTIFDefn* GS) {
    mxArray *mxGTIFCodes;
    int nfields;
    const char *fnames[] = {
                            "Model",
                            "PCS",
                            "GCS",
                            "UOMLength",
                            "UOMAngle",
                            "Datum",
                            "PM",
                            "Ellipsoid",
                            "ProjCode",
                            "Projection",
                            "CTProjection",
                            "MapSys",
                            "ProjParmId"
                           };
    const int *dims;
    int dimension[2];
    mxArray *dblArray;
    double *dblVal;
    int i;

    /* nfields = 13; */
    nfields = (sizeof(fnames)/sizeof(*fnames));
    dimension[0] = 1;
    dimension[1] = 1;
    dims = &dimension[0];

/**
 * Create the return MATLAB structure 
 * representing the GTIFCodes structure
 */
    mxGTIFCodes = mxCreateStructMatrix(1, 1, nfields, fnames);
    mxSetField(mxGTIFCodes, 0, "Model", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.Model));
    mxSetField(mxGTIFCodes, 0, "PCS", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.PCS));
    mxSetField(mxGTIFCodes, 0, "GCS", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.GCS));
    mxSetField(mxGTIFCodes, 0, "UOMLength", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.UOMLength));
    mxSetField(mxGTIFCodes, 0, "UOMAngle", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.UOMAngle));
    mxSetField(mxGTIFCodes, 0, "Datum", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.Datum));
    mxSetField(mxGTIFCodes, 0, "PM", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.PM));
    mxSetField(mxGTIFCodes, 0, "Ellipsoid", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.Ellipsoid));
    mxSetField(mxGTIFCodes, 0, "ProjCode", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.ProjCode));
    mxSetField(mxGTIFCodes, 0, "Projection", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.Projection));
    mxSetField(mxGTIFCodes, 0, "CTProjection", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.CTProjection));
    mxSetField(mxGTIFCodes, 0, "MapSys", 
               mxCreateDoubleScalar((double)GS->GTIFCodes.MapSys));

    dimension[0] = GS->nParms;
    dimension[1] = 1;
    if (dimension[0] == 0) dimension[1] = 0;
    dblArray = mxCreateNumericArray(2, dims,mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < GS->nParms; i++)
      dblVal[i] =  (double)GS->GTIFCodes.ProjParmId[i];
    mxSetField(mxGTIFCodes, 0, "ProjParmId", dblArray);

    return mxGTIFCodes;
}

static mxArray* getMxGTIFCorners(const AugGTIFDefn* GS) {
    mxArray *mxGTIFCorners;
    int nfields;
    const char *fnames[] = {
                            "X",
                            "Y",
                            "PCSX",
                            "PCSY",
                            "LON",
                            "LAT",
                           };
    const int *dims;
    int dimension[2];
    mxArray *dblArray;
    double *dblVal;
    int i;

    nfields = (sizeof(fnames)/sizeof(*fnames));
    dimension[0] = 4;
    dimension[1] = 1;
    dims = &dimension[0];

/**
 * Create the return MATLAB structure 
 * representing the GTIFCorners struct
 */
    mxGTIFCorners = mxCreateStructMatrix(1, 1, nfields, fnames);

    dblArray = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < 4; i++)
      dblVal[i] =  GS->Corners.X[i];
    mxSetField(mxGTIFCorners, 0, "X", dblArray);

    dblArray = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < 4; i++)
      dblVal[i] =  GS->Corners.Y[i];
    mxSetField(mxGTIFCorners, 0, "Y", dblArray);

    dblArray = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < 4; i++)
      dblVal[i] =  GS->Corners.PCSX[i];
    mxSetField(mxGTIFCorners, 0, "PCSX", dblArray);

    dblArray = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < 4; i++)
      dblVal[i] =  GS->Corners.PCSY[i];
    mxSetField(mxGTIFCorners, 0, "PCSY", dblArray);

    dblArray = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < 4; i++)
      dblVal[i] =  GS->Corners.LAT[i];
    mxSetField(mxGTIFCorners, 0, "LAT", dblArray);

    dblArray = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    dblVal = mxGetData(dblArray);
    for (i = 0 ; i < 4; i++)
      dblVal[i] =  GS->Corners.LONG[i];
    mxSetField(mxGTIFCorners, 0, "LON", dblArray);

    return mxGTIFCorners;
}
