/**
 *
 * File: geotiff_ifc.h
 *
 * Purpose: Header file used to define the AugGTIFDefn struct to hold a definition of a 
 * coordinate system in normalized form for passing to MATLAB
 * and to defined the libgeotiff interface functions to read and write
 * this structure.
 *
 * $Date: 2003/05/03 18:05:48 $
 * $Id: geotiff_utils.h,v 1.1.8.1 2003/05/03 18:05:48 batserve Exp $
 *
 */

#ifndef GEOTIFF_IFC_H
#define GEOTIFF_IFC_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <geotiff.h>
#include <geo_normalize.h>
#include <geovalues.h>
#include <geo_tiffp.h>
#include <geo_keyp.h>
#include <xtiffio.h>
#include <cpl_serv.h>
#include <projects.h>
#include <mex.h>

/**
 * CORNER_UL defines the Upper left corner index
 */
#define CORNER_UL 0

/**
 * CORNER_LL defines the Lower left corner index
 */
#define CORNER_LL 1

/**
 * CORNER_LR defines the Lower right corner index
 */
#define CORNER_LR 2

/**
 * CORNER_UR defines the Upper right corner index
 */
#define CORNER_UR 3

/**
 * The Corners stuct holds the data of the corner arrays.
 * The Image, PCS, and Lat/Lon corner coordintes values are stored 
 * counter-clockwise in the following manner:
 * Index:  Position
 * 0       UL
 * 1       LL
 * 2       LR
 * 3       UR
 *
 * The corner coordinates are stored as doubles in the following variables:
 * X[4] are the Image X corner coordinates
 * Y[4] are the Image Y corner coordinates
 * PCSX[4] are the projected corner coordinates for X
 * PCSY[4] are the projected corner coordinates for Y
 * long[4] are the corner longitude values 
 * lat[4] are the corner latitude values
 *
 * The PCS and long/lat values will be the same if the model is geographic.
 */
  typedef struct {
    int     X[4];
    int     Y[4];
    double  PCSX[4];
    double  PCSY[4];
    double  LONG[4];
    double  LAT[4];
  } GTIFCorners;

/**
 * The GTIFCodes holds only the GeoTiff codes information from GTIFDefn
 */
  typedef struct {

    /** From GTModelTypeGeoKey tag.  Can have the values ModelTypeGeographic
        or ModelTypeProjected. */
    short  Model;

    /** From ProjectedCSTypeGeoKey tag.  For example PCS_NAD27_UTM_zone_3N.*/
    short  PCS;

    /** From GeographicTypeGeoKey tag.  For example GCS_WGS_84 or
        GCS_Voirol_1875_Paris.  Includes datum and prime meridian value. */
    short  GCS;

    /** From ProjLinearUnitsGeoKey.  For example Linear_Meter. */
    short  UOMLength;

    /** The angular units of the GCS. */
    short  UOMAngle;
    
    /** Datum from GeogGeodeticDatumGeoKey tag. For example Datum_WGS84 */
    short  Datum;

    /** Prime meridian from GeogPrimeMeridianGeoKey.  For example PM_Greenwich
        or PM_Paris. */
    short  PM;

    /** Ellipsoid identifier from GeogELlipsoidGeoKey.  For example
        Ellipse_Clarke_1866. */
    short  Ellipsoid;

    /** Projection id from ProjectionGeoKey.  For example Proj_UTM_11S. */
    short ProjCode;

    /** EPSG identifier for underlying projection method.  From the EPSG
        TRF_METHOD table.  */
    short Projection;

    /** GeoTIFF identifier for underlying projection method.  While some of
      these values have corresponding vlaues in EPSG (Projection field),
      others do not.  For example CT_TransverseMercator. */
    short CTProjection;

    /** Projection parameter identifier.  For example ProjFalseEastingGeoKey.
        The value will be 0 for unused table entries. */
    int   ProjParmId[MAX_GTIF_PROJPARMS]; 

    /** Special zone map system code (MapSys_UTM_South, MapSys_UTM_North,
        MapSys_State_Plane or KvUserDefined if none apply. */
    int   MapSys;

  } GTIFCodes;


/**
 * The AugGTIFDefn holds a definition of a coordinate system in normalized form 
 * for passing back to MATLAB.
 * The AugGTIFDefn is augmented from GTIFDefn found in geo_normalize.h 
 * This struct is modified from GTIFDefn in the following manner:
 *   All short codes are moved to an included GTIFCodes structure.
 *   All short codes (except ProjCode) are added to included their 
 *   translations to char*
 *   Added fields:
 *     TiePointCount
 *     TiePoints
 *     PixelScaleCount
 *     PixelScale
 *     TransMatrixCount
 *     TransMatrix
 *     ImageWidth
 *     ImageHeight
 *
 */
  typedef struct {
    /** From GTModelTypeGeoKey tag.  Can have the values ModelTypeGeographic
        or ModelTypeProjected. */
    char*  Model;

    /** From ProjectedCSTypeGeoKey tag.  For example PCS_NAD27_UTM_zone_3N.*/
    char*  PCS;

    /** From GeographicTypeGeoKey tag.  For example GCS_WGS_84 or
        GCS_Voirol_1875_Paris.  Includes datum and prime meridian value. */
    char*  GCS;        

    /** From ProjLinearUnitsGeoKey.  For example Linear_Meter. */
    char*  UOMLength;

    /** One UOMLength = UOMLengthInMeters meters. */
    double UOMLengthInMeters;

    /** The angular units of the GCS. */
    char*  UOMAngle;

    /** One UOMAngle = UOMLengthInDegrees degrees. */
    double UOMAngleInDegrees;
    
    /** Datum from GeogGeodeticDatumGeoKey tag. For example Datum_WGS84 */
    char*  Datum;

    /** Prime meridian from GeogPrimeMeridianGeoKey.  For example PM_Greenwich
        or PM_Paris. */
    char*  PM;

    /** Decimal degrees of longitude between this prime meridian and
        Greenwich.  Prime meridians to the west of Greenwich are negative. */
    double PMLongToGreenwich;

    /** Ellipsoid identifier from GeogELlipsoidGeoKey.  For example
        Ellipse_Clarke_1866. */
    char*  Ellipsoid;

    /** The length of the semi major ellipse axis in meters. */
    double SemiMajor;

    /** The length of the semi minor ellipse axis in meters. */
    double SemiMinor;

    /** EPSG identifier for underlying projection method.  From the EPSG
        TRF_METHOD table.  */
    char* Projection;

    /** GeoTIFF identifier for underlying projection method.  While some of
      these values have corresponding vlaues in EPSG (Projection field),
      others do not.  For example CT_TransverseMercator. */
    char* CTProjection;   

    /** Number of projection parameters in ProjParm and ProjParmId. */
    int nParms;

    /** Projection parameter value.  The identify of this parameter
        is established from the corresponding entry in ProjParmId.  The
        value will be measured in meters, or decimal degrees if it is a
        linear or angular measure. */
    double ProjParm[MAX_GTIF_PROJPARMS];

    /** Projection parameter identifier.  For example ProjFalseEastingGeoKey.
        The value will be 0 for unused table entries. */
    char* ProjParmId[MAX_GTIF_PROJPARMS]; 

    /** The number of tie points */
    int TiePointCount;

    /** The TiePoint values */
    double TiePoints[MAX_GTIF_PROJPARMS];

    /** The Pixel Scale count */
    int PixelScaleCount;

    /** The Pixel Scale values */
    double PixelScale[MAX_GTIF_PROJPARMS];

    /** The transform matrix count */
    int TransMatrixCount;

    /** The transform matrix values */
    double TransMatrix[MAX_GTIF_PROJPARMS];

    /** The WorldFile matrix */
    double WorldFileMatrix[6];

    /** Special zone map system code (MapSys_UTM_South, MapSys_UTM_North,
        MapSys_State_Plane or KvUserDefined if none apply. */
    char* MapSys;

    /** UTM, or State Plane Zone number, zero if not known. */
    int Zone;

    /** The Image width */
    int ImageWidth;

    /** The Image height */
    int ImageHeight;

    /** The Image corners */
    GTIFCorners Corners;

    /** The GeoTiff Codes structure */
    GTIFCodes GTIFCodes;
  } AugGTIFDefn;

/**
 * The GEO Tiff Tags
 */
  #define NUM_GEO_TIFF_TAGS 7
  static short int GeoTiffTags[NUM_GEO_TIFF_TAGS] = {
     TIFFTAG_GEOPIXELSCALE,
     TIFFTAG_INTERGRAPH_MATRIX,
     TIFFTAG_GEOTIEPOINTS,
     TIFFTAG_GEOTRANSMATRIX,
     TIFFTAG_GEOKEYDIRECTORY,
     TIFFTAG_GEODOUBLEPARAMS,
     TIFFTAG_GEOASCIIPARAMS};

/**
 * initAugGTIFDefn will initialize a AugGTIFDefn to default values.
 *
 * @return The AugGTIFDefn is returned as a pointer. 
 */
  AugGTIFDefn *initAugGTIFDefn();

/**
 * printAugGTIFDefn will print the input AugGTIFDefn values
 * @param AugGTIFDefn is passed const and not modified. 
 */
  void printAugGTIFDefn(const AugGTIFDefn GS);

/**
 * printAugGTIFDefnCorner will print the input GTIFCorner values.
 *
 * @param name is the corner coordinate name, for example 'Upper Left'
 * @param index is the index into the corner array, for example CORNER_UL
 * @param AugGTIFDefn is passed const and not modified
 * and contains the corner coordinates.
 */
  void printAugGTIFDefnCorner(char* name, int index, const AugGTIFDefn GS) ;

/**
 *  read_geotiff will return a AugGTIFDefn pointer that is constructed
 *  from the GeoTiff data found in the input filename.
 *
 *  The input filename must be formatted as GeoTiff.
 *
 *  @param fname the input filename
 *  @return the AugGTIFDefn pointer obtained by processing the file.
 */
  AugGTIFDefn* read_geotiff(char *fname);

/**
 * write_geotiff will write the AugGTIFDefn structure into an existing
 * TIFF file. 
 *
 * @param a pointer to a TIFF file that exists 
 * @param GS the AugGTIFDefn structure to write 
 *
 */
  void write_geotiff(TIFF* tif, const AugGTIFDefn *GS);


/**
 * setProjParmIds will set the GTIF ProjParmIds
 *
 * @param gtif the GTIF pointer to the file
 * @param GS the AugGTIFDefn pointer
 */
  void setProjParmIds(GTIF *gtif, const AugGTIFDefn *GS);

/**
 *  getAugGTIFDefn will return a AugGTIFDefn pointer that is constructed
 *  from the GeoTiff data read from the TIFF pointer
 *
 *  @param tif is the TIFF pointer from an opened GeoTiff file.
 *  @return the AugGTIFDefn pointer obtained by processing the file.
 */
 AugGTIFDefn* getAugGTIFDefn(TIFF *tif);

/**
 * fillAugGTIFDefnCorners will fill the AugGTIFDefnCorners with the corner data.
 *
 * @param gtif is the GTIF pointer and is not modified.
 * @param defn is the GTIFDefn pointer and is not modified.
 * @param corners will contain the corner data and is modified.
 * @param xsize is the image width
 * @param ysize is the image height
 */
  void fillAugGTIFDefnCorners(GTIF *gtif, GTIFDefn *defn, GTIFCorners *Corners, 
                             int xsize, int ysize);

/**
 * fillAugGTIFDefnCorner will fill the AugGTIFDefnCorners with a particular corner data.
 *
 * @param gtif is the GTIF pointer and is not modified.
 * @param defn is the GTIFDefn pointer and is not modified.
 * @param corners will contain the corner data and is modified.
 * @param index is the corner location, typically given by the corner definitions, ie CORNER_UL
 * @param xsize is the image width
 * @param ysize is the image height
 */
 void fillAugGTIFDefnCorner(GTIF *gtif, GTIFDefn *defn, GTIFCorners *Corners,
                            int index, int xval, int yval);

/**
 * AugGTIFImageToPCS augments GTIFImageToPCS by changing the input arguement gtif
 * from GTIF* to a char* (filename) and changing the x,y arguements from pointers 
 * to passing by value.  The returned type is changed from void to double*
 *
 *
 * @param fname is the GTIF filename 
 * @param x is the X-Image coordinate 
 * @param y is the Y-Image coordinate 
 *
 * @return a pointer to X,Y in PCS
 */
  double* AugGTIFImageToPCS( char* fname , double x, double y );

/**
 * Read the worldfile and write to a GeoTiff file
 *
 * @param worldfile the worlfile to read
 * @param the TIFF pointer to a GeoTiff file
 */
  void ApplyWorldFile(const char *worldfile, TIFF *out);

/**
 * Get the WorldFile matrix from the GeoTiff file
 *
 * @return a pointer to the 6 WorldFile coefficients
 */
  double* getWorldFileMatrix( GTIF * gtif );

/**
 * Get the GEO Tiff Tags
 */
  short int* getGeoTiffTags();

/**
 * Construct AugGTIFDefn pointer from an mxArray
 * @param mxGTIFDef the mxArray pointer to MATLAB structure
 * @return a pointer to a AugGTIFDefn structure representing
 *         the GTIF definition
 */
AugGTIFDefn* mxArray2GTIFDef(const mxArray* mxGTIFDef);

/**
 * Construct a GTIFDefn object from an AugGTIFDefn pointer
 * @param GS the AugGTIFDefn pointer
 * @return the GTIFDefn object
 */
GTIFDefn AugGTIFDefnToGTIFDefn( const AugGTIFDefn *GS);

/**
 * Calculate latitude and longitude values from spatial
 * coordinates 
 * @param psDefn the GTIFDefn pointer
 * @param nPoints the number of X and Y points
 * @param padfX the X input array
 * @param padfY the Y input array
 * @param lon the output longitude array
 * @param lat the output latitude array
 */
int mxGTIFProj4ToLatLong( GTIFDefn * psDefn, int nPoints,
                        double *padfX, double *padfY, 
                        double *lon, double *lat);

/**
 * Calculate X and Y values from latitude and longitude
 * coordinates 
 * @param psDefn the GTIFDefn pointer
 * @param nPoints the number of X and Y points
 * @param lon the input longitude array
 * @param lat the input latitude array
 * @param padfX the output X input array
 * @param padfY the output Y input array
 */
int mxGTIFProj4FromLatLong( GTIFDefn * psDefn, int nPoints,
                        double *lon, double *lat,
                        double *padfX, double *padfY);
    
#endif /* ndef GEOTIFF_IFC_H */ 
