/**
 * File: geotiff_ifc.c
 * 
 * Purpose:  Interface routine to the GeoTiff library
 *
 * $Date: 2003/08/01 18:23:38 $
 * $Id: geotiff_utils.c,v 1.1.8.2 2003/08/01 18:23:38 batserve Exp $
 *
 */
#include "geotiff_utils.h"
#define UV projUV

AugGTIFDefn* initAugGTIFDefn() {
    AugGTIFDefn *GS = 0;
    int i;
    if (GS == 0) 
      GS = (AugGTIFDefn*)_GTIFcalloc( sizeof(AugGTIFDefn));
    GS->Model = "";
    GS->PCS = "";
    GS->GCS = "";
    GS->UOMLength = "";
    GS->UOMLengthInMeters = 0.0;
    GS->UOMAngle = "";
    GS->UOMAngleInDegrees = 0.0;
    GS->Datum = "";
    GS->PM = "";
    GS->PMLongToGreenwich =0.0;
    GS->Ellipsoid = "";
    GS->SemiMajor = 0.0;
    GS->SemiMinor = 0.0;
    GS->GTIFCodes.ProjCode = 0;
    GS->Projection = "";
    GS->CTProjection = "";
    GS->nParms = 0;
    GS->TiePointCount = 0;
    GS->PixelScaleCount = 0;
    GS->TransMatrixCount = 0;
    GS->MapSys = "";
    GS->Zone = 0;
    for (i = 0; i < MAX_GTIF_PROJPARMS; i++) {
       GS->ProjParm[i] = 0;
       GS->ProjParmId[i] = "";
       GS->TiePoints[i] = 0.0;
       GS->PixelScale[i] = 0.0;
       GS->TransMatrix[i] = 0.0;
    }
    GS->ImageWidth = 0;
    GS->ImageHeight= 0;
    return GS;
}

void printAugGTIFDefn(const AugGTIFDefn GS) {
    int i;
    printf("Model: %s\n", GS.Model); 
    printf("PCS: %s\n", GS.PCS); 
    printf("GCS: %s\n", GS.GCS);
    printf("UOMLength: %s\n",GS.UOMLength); 
    printf("UOMLengthInMeters: %g\n", GS.UOMLengthInMeters); 
    printf("UOMAngle: %s\n", GS.UOMAngle); 
    printf("UOMAngleInDegrees: %g\n", GS.UOMAngleInDegrees); 
    printf("Datum: %s\n", GS.Datum); 
    printf("PM: %s\n", GS.PM); 
    printf("PMLongToGreenwich: %g\n", GS.PMLongToGreenwich); 
    printf("Ellipsoid: %s\n", GS.Ellipsoid); 
    printf("SemiMajor: %g\n", GS.SemiMajor); 
    printf("SemiMinor: %g\n", GS.SemiMinor); 
    printf("Projection: %s\n", GS.Projection); 
    printf("CTProjection: %s\n", GS.CTProjection); 
    printf("nParms: %d\n", GS.nParms); 
    for (i=0; i<GS.nParms; i++) {
       printf("ProjParmId[%d]: %s\n", i, GS.ProjParmId[i]);
       printf("ProjParm[%d]:  %g\n", i, GS.ProjParm[i]);
    }
    printf("TiePointCount: %d\n", GS.TiePointCount); 
    for (i=0; i<GS.TiePointCount; i++) {
       printf("TiePoints[%d]: %g\n", i, GS.TiePoints[i]);
    }
    printf("PixelScaleCount: %d\n", GS.PixelScaleCount); 
    for (i=0; i<GS.PixelScaleCount; i++) {
       printf("PixelScale[%d]: %g\n", i, GS.PixelScale[i]);
    }
    printf("TransMatrixCount: %d\n", GS.TransMatrixCount); 
    for (i=0; i<GS.TransMatrixCount; i++) {
       printf("TransMatrix[%d]: %g\n", i, GS.TransMatrix[i]);
    }
    printf("MapSys: %s\n", GS.MapSys); 
    printf("Zone: %d\n", GS.Zone); 
    printf("ImageWidth: %d\n", GS.ImageWidth); 
    printf("ImageHeight: %d\n", GS.ImageHeight); 
    printf("Corner Coordinates: \n");
    printAugGTIFDefnCorner("Upper Left  ", CORNER_UL, GS);
    printAugGTIFDefnCorner("Lower Left  ", CORNER_LL, GS);
    printAugGTIFDefnCorner("Lower Right ", CORNER_LR, GS);
    printAugGTIFDefnCorner("Upper Right ", CORNER_UR, GS);
    printf("\n\nGeoTiff Codes: \n");
    printf("ModelCode: %d\n", GS.GTIFCodes.Model); 
    printf("PCSCode: %d\n", GS.GTIFCodes.PCS); 
    printf("GCSCode: %d\n", GS.GTIFCodes.GCS); 
    printf("UOMLengthCode: %d\n", GS.GTIFCodes.UOMLength); 
    printf("UOMAngleCode: %d\n", GS.GTIFCodes.UOMAngle); 
    printf("DatumCode: %d\n", GS.GTIFCodes.Datum); 
    printf("PMCode: %d\n", GS.GTIFCodes.PM); 
    printf("EllipsoidCode: %d\n", GS.GTIFCodes.Ellipsoid); 
    printf("ProjCode: %d\n", GS.GTIFCodes.ProjCode); 
    printf("ProjectionCode: %d\n", GS.GTIFCodes.Projection); 
    printf("CTProjectionCode: %d\n", GS.GTIFCodes.CTProjection); 
    printf("MapSysCode: %d\n", GS.GTIFCodes.MapSys); 
    for (i=0; i<GS.nParms; i++) 
       printf("ProjParmIdCode[%d]: %d\n", i, GS.GTIFCodes.ProjParmId[i]);
}
void printAugGTIFDefnCorner(char* name, int index, const AugGTIFDefn GS) {
    /*
    printf("%s ( %4d, %4d )  ( %11.3f , %11.3f )  ( %g , %g )\n", 
            name,
            GS.Corners.X[index], GS.Corners.Y[index],
            GS.Corners.PCSX[index], GS.Corners.PCSY[index],
            GS.Corners.LONG[index], GS.Corners.LAT[index]);
    */
    printf("%s ( %4d, %4d )  ( %11.3f, %11.3f ) ", 
            name,
            GS.Corners.X[index], GS.Corners.Y[index],
            GS.Corners.PCSX[index], GS.Corners.PCSY[index]);
    printf("( %g, %g )  \n                                            ( %s , %s )  \n", 
            GS.Corners.LONG[index], GS.Corners.LAT[index],
            GTIFDecToDMS(GS.Corners.LONG[index],"Long", 2), 
            GTIFDecToDMS(GS.Corners.LAT[index], "Lat",  2));
}

AugGTIFDefn* read_geotiff(char *fname) {

/* the output module */
   static const char module[] = "read_geotiff";

/* TIFF-level descriptor  */
   TIFF 	*tif=(TIFF*)0;  

/* The returned AugGTIFDefn pointer */
   AugGTIFDefn* GS=(AugGTIFDefn*)0;

/**
 * Open the file and read the GeoTIFF information.
 * Use the TIFF library to open the file.
 */
   tif=XTIFFOpen(fname,"r");
   if (!tif) {
     TIFFError(module, "Failure in read_geotiff!");
     TIFFError(module, "Unable to open: %s\n", fname);
     if (tif) XTIFFClose(tif);
     return GS;
   }

/* Get the AugGTIFDefn data from the file  */
   GS = getAugGTIFDefn(tif);

/* All finished so close the file */
   XTIFFClose(tif);

/* Return the AugGTIFDefn data */
   return GS;
}

void write_geotiff(TIFF *tif, const AugGTIFDefn *GS) {


/* status value */
   int status;

#ifdef GEOTIFF_DEBUG
/* code test value */
   short code;
   double dcode;
#endif

/* GeoKey-level descriptor  */
   GTIF	*gtif=(GTIF*)0; 

/**
 * The GTIFDefn structure containing the GeoTiff information
 * but in TIFF code (short) format.
 */
   GTIFDefn	psDefn;

/**
 * Construct the gtif pointer from the TIFF pointer
 */
   gtif = GTIFNew(tif);
   if (!gtif) {
      if (gtif) GTIFFree(gtif);
      TIFFWarning(TIFFFileName(tif), "Failed to allocate a new GTIF structure");
      return;
   }

/**
 * Construct a default GTIFDefn structure 
 * which will contain the GeoTiff data in coded format
 */
   if( !GTIFGetDefn( gtif, &psDefn ) ) {
      TIFFWarning(TIFFFileName(tif), 
                  "Failed to allocate a new GTIFDefn structure");
      if (gtif) GTIFFree(gtif);
      return;
   }

/**
 * Copy the Model code into the GTIF key
 */
   psDefn.Model = GS->GTIFCodes.Model; 
   status = 
     GTIFKeySet(gtif, GTModelTypeGeoKey, TYPE_SHORT, 1, psDefn.Model);

/**
 * Copy the PCS code into the GTIF key
 */
   psDefn.PCS= GS->GTIFCodes.PCS; 
   status = 
     GTIFKeySet(gtif, ProjectedCSTypeGeoKey, TYPE_SHORT, 1, psDefn.PCS);

/**
 * Copy the ProjCode into the GTIF key
 */
   psDefn.ProjCode= GS->GTIFCodes.ProjCode; 
   status = 
     GTIFKeySet(gtif, ProjectionGeoKey, TYPE_SHORT, 1, psDefn.ProjCode);

/**
 * Copy the GCS into the GTIF key
 */
   psDefn.GCS = GS->GTIFCodes.GCS; 
   status = 
     GTIFKeySet(gtif, GeographicTypeGeoKey, TYPE_SHORT, 1, psDefn.GCS);

/**
 * Copy the UOMAngle into the GTIF key
 */
   psDefn.UOMAngle = GS->GTIFCodes.UOMAngle; 
   status = 
     GTIFKeySet(gtif, GeogAngularUnitsGeoKey, TYPE_SHORT, 1, psDefn.UOMAngle);

/**
 * Copy the UOMLength into the GTIF key
 */
   psDefn.UOMLength = GS->GTIFCodes.UOMLength; 
   status = 
     GTIFKeySet(gtif, ProjLinearUnitsGeoKey, TYPE_SHORT, 1, psDefn.UOMLength);

/**
 * Copy the Datum into the GTIF key
 */
   psDefn.Datum = GS->GTIFCodes.Datum; 
   status = 
     GTIFKeySet(gtif, GeogGeodeticDatumGeoKey, TYPE_SHORT, 1, psDefn.Datum);

/**
 * Copy the Ellipsoid into the GTIF key
 */
   psDefn.Ellipsoid = GS->GTIFCodes.Ellipsoid; 
   status = 
     GTIFKeySet(gtif, GeogEllipsoidGeoKey, TYPE_SHORT, 1, psDefn.Ellipsoid);

/**
 * Copy the PM into the GTIF key
 */
   psDefn.PM = GS->GTIFCodes.PM; 
   status = 
     GTIFKeySet(gtif, GeogPrimeMeridianGeoKey, TYPE_SHORT, 1, psDefn.PM);

/**
 * Copy the PMLongToGreenwich into the GTIF key
 */
   psDefn.PMLongToGreenwich = GS->PMLongToGreenwich; 
   status = 
     GTIFKeySet(gtif, GeogPrimeMeridianLongGeoKey, TYPE_DOUBLE, 1, psDefn.PMLongToGreenwich);


/**
 * Copy the CTProjection into the GTIF key
 */
   psDefn.CTProjection = GS->GTIFCodes.CTProjection; 
   status = 
     GTIFKeySet(gtif, ProjCoordTransGeoKey, TYPE_SHORT, 1, psDefn.CTProjection);

/**
 * Copy the TiePoints, PixelScale and TransMatrix into the GTIF key
 */
   if (GS->TiePointCount != 0)
     TIFFSetField(gtif->gt_tif,TIFFTAG_GEOTIEPOINTS, 
                               GS->TiePointCount,GS->TiePoints);
   if (GS->PixelScaleCount!= 0)
     TIFFSetField(gtif->gt_tif,TIFFTAG_GEOPIXELSCALE, 
                               GS->PixelScaleCount,GS->PixelScale);
   if (GS->TransMatrixCount!= 0)
     TIFFSetField(gtif->gt_tif,TIFFTAG_GEOTRANSMATRIX, 
                               GS->TransMatrixCount,GS->TransMatrix);


#ifdef GEOTIFF_DEBUG
   GTIFKeyGet(gtif,GTModelTypeGeoKey,&(code),0,1);
   printf("The model code should be: %d \n", psDefn.Model);
   printf("The model code is: %d \n", code);

   GTIFKeyGet(gtif,ProjectedCSTypeGeoKey, &(code),0,1);
   printf("The PCS code should be: %d \n", psDefn.PCS);
   printf("The PCS code is: %d \n", code);

   GTIFKeyGet(gtif, ProjectionGeoKey, &(code), 0, 1 );
   printf("The ProjCode should be: %d \n", psDefn.ProjCode);
   printf("The ProjCode is: %d \n", code);

   GTIFKeyGet(gtif, GeographicTypeGeoKey, &(code), 0, 1 );
   printf("The GCS code should be: %d \n", psDefn.GCS);
   printf("The GCS code is: %d \n", code);

   GTIFKeyGet(gtif, GeogAngularUnitsGeoKey, &(code), 0, 1);
   printf("The UOMAngle code should be: %d \n", psDefn.UOMAngle);
   printf("The UOMAngle code is: %d \n", code);

   GTIFKeyGet(gtif,ProjLinearUnitsGeoKey,&(code),0,1);
   printf("The UOMLength code should be: %d \n", psDefn.UOMLength);
   printf("The UOMLength code is: %d \n", code);

   GTIFKeyGet(gtif, GeogGeodeticDatumGeoKey, &(code), 0, 1 );
   printf("The Datum code should be: %d \n", psDefn.Datum);
   printf("The Datum code is: %d \n", code);

   GTIFKeyGet(gtif, GeogEllipsoidGeoKey, &(code), 0, 1 );
   printf("The Ellipsoid code should be: %d \n", psDefn.Ellipsoid);
   printf("The Ellipsoid code is: %d \n", code);

   GTIFKeyGet(gtif, GeogPrimeMeridianGeoKey, &(code), 0, 1 );
   printf("The PM code should be: %d \n", psDefn.PM);
   printf("The PM code is: %d \n", code);

   GTIFKeyGet(gtif, GeogPrimeMeridianLongGeoKey, &(dcode), 0, 1 );
   printf("The PMLongToGreenwich code should be: %g \n", psDefn.PMLongToGreenwich);
   printf("The PMLongToGreenwich code is: %g \n", dcode);

   GTIFKeyGet(gtif,ProjCoordTransGeoKey, &(code),0,1);
   printf("The CTProjection code should be: %d \n", psDefn.CTProjection);
   printf("The CTProjection code is: %d \n", code);
#endif

/**
 * Copy the ProjParmIds into the GTIF key
 */
   setProjParmIds(gtif, GS);

/**
 * All finished, now write the keys
 */
   gtif->gt_flags |= FLAG_FILE_MODIFIED;
   status=GTIFWriteKeys(gtif);
   GTIFFree(gtif);
}

	
void setProjParmIds(GTIF *gtif, const AugGTIFDefn *GS) {

#ifdef GEOTIFF_DEBUG
   int i;
   for (i=0; i<GS->nParms; i++) {
     printf("ProjParm[%d]: %g\n", i, GS->ProjParm[i]);
   }
#endif

   switch( GS->GTIFCodes.CTProjection ) {
       case CT_CassiniSoldner:
       case CT_NewZealandMapGrid:
         /* psDefn->ProjParmId[0] = ProjNatOriginLatGeoKey; */
         GTIFKeySet(gtif, ProjNatOriginLatGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[0]);
         /* psDefn->ProjParmId[1] = ProjNatOriginLongGeoKey; */
         GTIFKeySet(gtif, ProjNatOriginLongGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[1]);
         /* psDefn->ProjParmId[5] = ProjFalseEastingGeoKey; */
         GTIFKeySet(gtif, ProjFalseEastingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[5]);
         /* psDefn->ProjParmId[6] = ProjFalseNorthingGeoKey; */
         GTIFKeySet(gtif, ProjFalseNorthingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[6]);
       break;

       case CT_ObliqueMercator:
         /* psDefn->ProjParmId[0] = ProjCenterLatGeoKey; */
         GTIFKeySet(gtif, ProjCenterLatGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[0]);
         /* psDefn->ProjParmId[1] = ProjCenterLongGeoKey; */
         GTIFKeySet(gtif, ProjCenterLongGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[1]);
         /* psDefn->ProjParmId[2] = ProjAzimuthAngleGeoKey; */
         GTIFKeySet(gtif, ProjAzimuthAngleGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[2]);
         /* psDefn->ProjParmId[3] = ProjRectifiedGridAngleGeoKey; */
         GTIFKeySet(gtif, ProjRectifiedGridAngleGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[3]);
         /* psDefn->ProjParmId[4] = ProjScaleAtCenterGeoKey; */
         GTIFKeySet(gtif, ProjScaleAtCenterGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[4]);
         /* psDefn->ProjParmId[5] = ProjFalseEastingGeoKey; */
         GTIFKeySet(gtif, ProjFalseEastingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[5]);
         /* psDefn->ProjParmId[6] = ProjFalseNorthingGeoKey */
         GTIFKeySet(gtif, ProjFalseNorthingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[6]);
       break;

       case CT_ObliqueMercator_Laborde:
         /* psDefn->ProjParmId[0] = ProjCenterLatGeoKey; */
         GTIFKeySet(gtif, ProjCenterLatGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[0]);
         /* psDefn->ProjParmId[1] = ProjCenterLongGeoKey; */
         GTIFKeySet(gtif, ProjCenterLongGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[1]);
         /* psDefn->ProjParmId[2] = ProjAzimuthAngleGeoKey; */
         GTIFKeySet(gtif, ProjAzimuthAngleGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[2]);
         /* psDefn->ProjParmId[4] = ProjScaleAtCenterGeoKey; */
         GTIFKeySet(gtif, ProjScaleAtCenterGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[4]);
         /* psDefn->ProjParmId[5] = ProjFalseEastingGeoKey; */
         GTIFKeySet(gtif, ProjFalseEastingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[5]);
         /* psDefn->ProjParmId[6] = ProjFalseNorthingGeoKey */
         GTIFKeySet(gtif, ProjFalseNorthingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[6]);
       break;


       case CT_LambertConfConic_1SP:
       case CT_Mercator:
       case CT_ObliqueStereographic:
       case CT_PolarStereographic:
       case CT_TransverseMercator:
       case CT_TransvMercator_SouthOriented:
         /* psDefn->ProjParmId[0] = ProjNatOriginLatGeoKey; */
         GTIFKeySet(gtif, ProjNatOriginLatGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[0]);
         /* GTIFKeyGet(gtif, ProjNatOriginLatGeoKey, &(dcode), 0, 1 ); */
         /* printf("dcode: %g\n", dcode); */
         /* psDefn->ProjParmId[1] = ProjNatOriginLongGeoKey; */
         GTIFKeySet(gtif, ProjNatOriginLongGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[1]);

         /* psDefn->ProjParmId[4] = ProjScaleAtNatOriginGeoKey; */
         GTIFKeySet(gtif, ProjScaleAtNatOriginGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[4]);

         /* psDefn->ProjParmId[5] = ProjFalseEastingGeoKey; */
         GTIFKeySet(gtif, ProjFalseEastingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[5]);

         /* psDefn->ProjParmId[6] = ProjFalseNorthingGeoKey; */
         GTIFKeySet(gtif, ProjFalseNorthingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[6]);
       break;

       case CT_LambertConfConic_2SP:
         /* psDefn->ProjParmId[0] = ProjFalseOriginLatGeoKey; */
         GTIFKeySet(gtif, ProjFalseOriginLatGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[0]);
         /*  psDefn->ProjParmId[1] = ProjFalseOriginLongGeoKey; */
         GTIFKeySet(gtif, ProjFalseOriginLongGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[1]);
         /* psDefn->ProjParmId[2] = ProjStdParallel1GeoKey; */
         GTIFKeySet(gtif, ProjStdParallel1GeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[2]);
         /* psDefn->ProjParmId[3] = ProjStdParallel2GeoKey; */
         GTIFKeySet(gtif, ProjStdParallel2GeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[3]);
         /* psDefn->ProjParmId[5] = ProjFalseEastingGeoKey; */
         GTIFKeySet(gtif, ProjFalseEastingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[5]);
         /* psDefn->ProjParmId[6] = ProjFalseNorthingGeoKey; */
         GTIFKeySet(gtif, ProjFalseNorthingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[6]);
       break;

       case CT_SwissObliqueCylindrical:
         /* psDefn->ProjParmId[0] = ProjCenterLatGeoKey; */
         GTIFKeySet(gtif, ProjCenterLatGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[0]);
         /* psDefn->ProjParmId[1] = ProjCenterLongGeoKey; */
         GTIFKeySet(gtif, ProjCenterLongGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[1]);
         /* psDefn->ProjParmId[5] = ProjFalseEastingGeoKey; */
         GTIFKeySet(gtif, ProjFalseEastingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[5]);
         /* psDefn->ProjParmId[6] = ProjFalseNorthingGeoKey */
         GTIFKeySet(gtif, ProjFalseNorthingGeoKey, 
                    TYPE_DOUBLE, 1, GS->ProjParm[6]);
       break;
   }
}

AugGTIFDefn* getAugGTIFDefn(TIFF *tif) {

/* the output module */
   static const char module[] = "read_geotiff";

/* GeoKey-level descriptor  */
   GTIF	*gtif=(GTIF*)0; 

/**
 * The GTIFDefn structure containing the GeoTiff information
 * but in TIFF code (short) format.
 */
   GTIFDefn	psDefn;

/* The returned AugGTIFDefn pointer */
   AugGTIFDefn* GS=(AugGTIFDefn*)0;

   int		i;
   char *modelName = "unknown";
   int tiepoint_count, count, transform_count;
   double *tiepoints;
   double *pixel_scale;
   double *transform;
   double *worldmatrix;
   tiff_t *tifp; 
   char *mapSys = "";
   char *sangle="";
   int xsize, ysize;
   /* static char *strUserDefined = "UserDefined"; */
   static char *strUserDefined = "";

/**
 * Construct the gtif pointer from the TIFF pointer
 */
   gtif = GTIFNew(tif);
   if (!gtif) { 
      /* fprintf(stderr,"Failure in getAugGTIFDefn!\n"); */
      /* fprintf(stderr,"Failed in GTIFNew\n"); */
      if (gtif) GTIFFree(gtif);
      TIFFError(module, "Unable to allocate a GTIF pointer.\n");
      return GS;
   }

/**
 * Construct the GTIFDefn structure 
 * which will contain the GeoTiff data in coded format
 */
   if( !GTIFGetDefn( gtif, &psDefn ) ) {
      /* fprintf(stderr,"Failure in getAugGTIFDefn!\n"); */
      /* fprintf(stderr,"Unable to allocate a GTIFtDefn\n"); */
      if (gtif) GTIFFree(gtif);
      TIFFError(module, "Unable to allocate a GTIF structure.\n");
      return GS;
   }

/**
 * Create then initialize the GS AugGTIFDefn with default values
 */
   GS = initAugGTIFDefn();
   if (GS == 0) {
      /* fprintf(stderr,"Failure in getAugGTIFDefn!\n"); */
      /* fprintf(stderr,"Unable to allocate a AugGTIFDefn\n"); */
      if (gtif) GTIFFree(gtif);
      TIFFError(module, "Unable to allocate a GeoTiff structure.\n");
      return GS;
   }

      
/**
 * Obtain the Model Field string name
 */
   GS->GTIFCodes.Model = psDefn.Model;
   if (psDefn.Model == ModelTypeGeographic)
     modelName = "ModelTypeGeographic";
   else if (psDefn.Model == ModelTypeProjected)
     modelName = "ModelTypeProjected";
   GS->Model = modelName;


/**
 * Obtain the PCS string name
 */
   GS->GTIFCodes.PCS = psDefn.PCS;
   if( GTIFKeyGet(gtif,ProjectedCSTypeGeoKey, &(psDefn.PCS),0,1) == 1
         && psDefn.PCS != KvUserDefined ) {

     char   *pszPCSName = "name unknown";
/*
 * 114 version
     GTIFGetPCSInfo( psDefn.PCS, &pszPCSName,
                   &(psDefn.UOMLength), &(psDefn.UOMAngle),
                   &(psDefn.GCS), &(psDefn.ProjCode) );
 */
     short pnProjOp;
     pnProjOp = 1;
     GTIFGetPCSInfo( psDefn.PCS, &pszPCSName,
                   &(pnProjOp), &(psDefn.UOMLength), 
                   &(psDefn.GCS));
     GS->PCS= pszPCSName;
   }
   else if( psDefn.PCS == KvUserDefined ) {
     GS->PCS= strUserDefined;
   }

                  
/**
 * Obtain the GCS string name
 */
   GS->GTIFCodes.GCS= psDefn.GCS;
   if ( psDefn.GCS != KvUserDefined ) {
     char   *pszName = "(unknown)";
     GTIFGetGCSInfo( psDefn.GCS, &pszName, 
                                 &(psDefn.Datum), 
                                 &(psDefn.PM), 
                                 &(psDefn.UOMAngle));
     GS->GCS= pszName;
   }
   else if( psDefn.GCS == KvUserDefined ) {
     GS->GCS= strUserDefined;
   }

/**
 * Obtain the UOMLength string value
 */
   GS->GTIFCodes.UOMLength= psDefn.UOMLength;
   if ( psDefn.UOMLength != KvUserDefined ) {
     char   *pszName = NULL;
     GTIFGetUOMLengthInfo( psDefn.UOMLength, &pszName, NULL );
     GS->UOMLength = pszName;
   }
   else if( psDefn.UOMLength == KvUserDefined ) {
     GS->UOMLength = strUserDefined;
   }

/**
 * Obtain the UOMLengthInMeters double value
 */
   GS->UOMLengthInMeters = psDefn.UOMLengthInMeters;

/**
 * Obtain the UOMAngle string value
 */
   GS->GTIFCodes.UOMAngle= psDefn.UOMAngle;
   GTIFGetUOMAngleInfo( psDefn.UOMAngle, 
                        &sangle,
                        &(psDefn.UOMAngleInDegrees) );
   GS->UOMAngle = sangle;


/**
 * Obtain the UOMAngleInDegrees double value
 */
   GS->UOMAngleInDegrees = psDefn.UOMAngleInDegrees;

/**
 * Obtain the Datum string value
 */
   GS->GTIFCodes.Datum= psDefn.Datum;
   if ( psDefn.Datum != KvUserDefined ) {
     char   *pszName = "(unknown)";
     GTIFGetDatumInfo( psDefn.Datum, &pszName, NULL );
     GS->Datum = pszName;
   }
   else if( psDefn.Datum == KvUserDefined ) {
     GS->Datum = strUserDefined;
   }


/**
 * Obtain the PM string value
 */
   GS->GTIFCodes.PM= psDefn.PM;
   if ( psDefn.PM != KvUserDefined ) {
     char   *pszName = NULL;
     GTIFGetPMInfo( psDefn.PM, &pszName, NULL );
     GS->PM = pszName;
   }
   else if( psDefn.PM == KvUserDefined ) {
     GS->PM = strUserDefined;
   }

/**
 * Obtain the PMLongToGreenwich double value
 */
   GS->PMLongToGreenwich = psDefn.PMLongToGreenwich;

/** 
 * Obtain the ellipsoid string value
 */
   GS->GTIFCodes.Ellipsoid= psDefn.Ellipsoid;
   if ( psDefn.Ellipsoid != KvUserDefined ) {
     char   *pszName = "(unknown)";
     GTIFGetEllipsoidInfo( psDefn.Ellipsoid, &pszName, NULL, NULL );
     GS->Ellipsoid = pszName;
   }
   else if( psDefn.Ellipsoid == KvUserDefined ) {
     GS->Ellipsoid = strUserDefined;
   }

/**
 * Obtain the SemiMajor double value
 */
   GS->SemiMajor = psDefn.SemiMajor;

/**
 * Obtain the SemiMinor double value
 */
   GS->SemiMinor = psDefn.SemiMinor;

/**
 *  Obtain the ProjCode short value
 */
   GS->GTIFCodes.ProjCode = psDefn.ProjCode;

/**
 *  Obtain the Projection string value
 */
   GS->GTIFCodes.Projection= psDefn.Projection;
   if ( psDefn.ProjCode != KvUserDefined ) {
     char   *pszTRFName = "";
     GTIFGetProjTRFInfo( psDefn.ProjCode, &pszTRFName, NULL, NULL );
     GS->Projection = pszTRFName;
   }
   else if( psDefn.ProjCode == KvUserDefined ) {
     GS->Projection = strUserDefined;
   }

/** 
 * Obtain the CTProjection string value
 */
   GS->GTIFCodes.CTProjection = psDefn.CTProjection;
   if ( psDefn.CTProjection != KvUserDefined ) {
     char	*pszName = GTIFValueName(ProjCoordTransGeoKey,
                                     psDefn.CTProjection);
     if( pszName == NULL ) pszName = "";
     GS->CTProjection = pszName;
   }
   else if( psDefn.CTProjection == KvUserDefined ) {
     GS->CTProjection = strUserDefined;
   }

/**
 * Obtain the nParms integer value
 */
   GS->nParms = psDefn.nParms;


/**
 * Obtain the ProjParmId string values
 */
   for ( i = 0; i < psDefn.nParms; i++ ) {
      GS->GTIFCodes.ProjParmId[i] = psDefn.ProjParmId[i];
      GS->ProjParmId[i] = GTIFKeyName((geokey_t) psDefn.ProjParmId[i]);
   }

/**
 * Obtain the ProjParm float values
 */
   for ( i = 0; i < psDefn.nParms; i++ ) {
      GS->ProjParm[i] = psDefn.ProjParm[i];
   }

/**
 * Obtain the TiePoints
 */
   tifp = gtif->gt_tif;
   if (!(gtif->gt_methods.get)(tifp, GTIFF_TIEPOINTS,
                                 &tiepoint_count, &tiepoints ))
     tiepoint_count = 0;
   else {
     GS->TiePointCount = tiepoint_count;
     for (i=0; i<tiepoint_count; i++) {
       GS->TiePoints[i] =  tiepoints[i];
     }
   }

/**
 * Obtain the PixelScale
 */
   if (!(gtif->gt_methods.get)(tifp, GTIFF_PIXELSCALE,
                                 &count, &pixel_scale))
     count = 0;
   else {
     GS->PixelScaleCount = count;
     for (i=0; i<count; i++) {
       GS->PixelScale[i] =  pixel_scale[i];
     }
   }

/**
 * Obtain the TransMatrix
 */
   if (!(gtif->gt_methods.get)(tifp, GTIFF_TRANSMATRIX,
                                 &transform_count, &transform))
     transform_count = 0;
   else {
     GS->TransMatrixCount = transform_count;
     for (i=0; i<transform_count; i++)
       GS->TransMatrix[i] =  transform[i];
   }

/**
 * Obtain the WorldFileMatrix
 */
   worldmatrix = getWorldFileMatrix(gtif);
   for (i=0; i<6; i++) {
     GS->WorldFileMatrix[i] = worldmatrix[i];
   }
   free( worldmatrix );


/**
 * Obtain the MapSys 
 */
   
   GS->GTIFCodes.MapSys= psDefn.MapSys;
   if (psDefn.MapSys == MapSys_UTM_North)
     mapSys = "UTM_NORTH";
   else if (psDefn.MapSys == MapSys_UTM_South)
     mapSys = "UTM_SOUTH";
   else if (psDefn.MapSys == MapSys_State_Plane_27)
     mapSys = "STATE_PLANE_27";
   else if (psDefn.MapSys == MapSys_State_Plane_83)
     mapSys = "STATE_PLANE_83";
   GS->MapSys = mapSys;

/**
 * Obtain the the Zone information
 */
   GS->Zone =  psDefn.Zone;

/**
 * Obtain the ImageWidth and ImageHeight
 */
  TIFFGetField( tif, TIFFTAG_IMAGEWIDTH,  &xsize);
  TIFFGetField( tif, TIFFTAG_IMAGELENGTH, &ysize);
  GS->ImageWidth = xsize;
  GS->ImageHeight= ysize;

/**
 * Fill the Corner values
 */
  fillAugGTIFDefnCorners(gtif, &psDefn, &GS->Corners,  xsize,  ysize);

/**
 * free the create GTIF pointer since it is no longer needed
 */
   GTIFFree(gtif);

/* Return the AugGTIFDefn pointer */
   return GS;
		
}

void fillAugGTIFDefnCorner(GTIF *gtif, GTIFDefn *defn, GTIFCorners *Corners,
                          int index, int ix, int iy) {

   double x, y;
/* Try to transform the coordinate into PCS space */
   Corners->X[index] = ix;
   Corners->Y[index] = iy;
   x = (double) ix;
   y = (double) iy;
   if ( !GTIFImageToPCS( gtif, &x, &y ) ) return;
   Corners->PCSX[index] = x; 
   Corners->PCSY[index] = y; 

   if ( defn->Model == ModelTypeGeographic ) {
     Corners->LONG[index] = x; 
     Corners->LAT[index]  = y; 
     return;
   }


   if( GTIFProj4ToLatLong( defn, 1, &x, &y ) ) { 
     Corners->LONG[index] = x; 
     Corners->LAT[index]  = y; 
   }

}



void fillAugGTIFDefnCorners(GTIF *gtif, GTIFDefn *defn, GTIFCorners *Corners, 
                           int xsize, int ysize) {

/* Fill Upper Left  corner:  0.0,   0.0 */
   fillAugGTIFDefnCorner( gtif, defn, Corners, CORNER_UL, 0.0, 0.0);

/* Fill Lower Left  corner:  0.0,   ysize */
   fillAugGTIFDefnCorner( gtif, defn, Corners, CORNER_LL, 0.0, ysize);

/* Fill Lower Right corner:  xsize, ysize */
   fillAugGTIFDefnCorner( gtif, defn, Corners, CORNER_LR, xsize,  ysize);

/* Fill Upper Right corner:  xsize, 0.0 */
   fillAugGTIFDefnCorner( gtif, defn, Corners, CORNER_UR, xsize, 0.0);
}


double* AugGTIFImageToPCS( char* fname , double x, double y ) {

/* TIFF-level descriptor  */
   TIFF 	*tif=(TIFF*)0;  

/* GeoKey-level descriptor  */
   GTIF	*gtif=(GTIF*)0; 

/* The Returned image coordinates (X,Y) */
   double* imageCoords = malloc(2*sizeof(double));
   imageCoords[0] = x;
   imageCoords[1] = y;

/**
 * Open the file and read the GeoTIFF information.
 * Use the TIFF library to open the file.
 */
   tif=XTIFFOpen(fname,"r");
   if (!tif) {
     fprintf(stderr,"Failure in AugGTIFImageToPCS!\n");
     fprintf(stderr,"Unable to open: %s\n", fname);
     if (tif) XTIFFClose(tif);
     return imageCoords;
   }

/**
 * Construct the gtif pointer from the TIFF pointer
 */
   gtif = GTIFNew(tif);
   if (!gtif) {
      fprintf(stderr,"Failure in AugGTIFImageToPCS!\n");
      fprintf(stderr,"Failed in GTIFNew\n");
      if (gtif) GTIFFree(gtif);
      return imageCoords;
   }

/* Perform the conversion */
   GTIFImageToPCS(gtif, &imageCoords[0], &imageCoords[1]);
   return imageCoords;
}


void ApplyWorldFile(const char *worldfilename, TIFF *out) {
    FILE	*tfw;
    double	pixsize[3], xoff, yoff, tiepoint[6], x_rot, y_rot;

    /* 
     * Read the world file.  Note we currently ignore rotational coefficients!
     */
    tfw = fopen( worldfilename, "rt" );
    if( tfw == NULL )
    {
        perror( worldfilename );
        return;
    }

    fscanf( tfw, "%lf", pixsize + 0 );
    fscanf( tfw, "%lf", &y_rot );
    fscanf( tfw, "%lf", &x_rot );
    fscanf( tfw, "%lf", pixsize + 1 );
    fscanf( tfw, "%lf", &xoff );
    fscanf( tfw, "%lf", &yoff );

    fclose( tfw );

    /*
     * Write out pixel scale, and tiepoint information.
     */
    if( x_rot == 0.0 && y_rot == 0.0 )
    {
        pixsize[1] = ABS(pixsize[1]);
        pixsize[2] = 0.0;
        TIFFSetField(out, GTIFF_PIXELSCALE, 3, pixsize);

        tiepoint[0] = 0.5;
        tiepoint[1] = 0.5;
        tiepoint[2] = 0.0;
        tiepoint[3] = xoff;
        tiepoint[4] = yoff;
        tiepoint[5] = 0.0;
        TIFFSetField(out, GTIFF_TIEPOINTS, 6, tiepoint);
    }
    else
    {
        double	adfMatrix[16];
        
        memset(adfMatrix,0,sizeof(double) * 16);
        
        adfMatrix[0] = pixsize[0];
        adfMatrix[1] = x_rot;
        adfMatrix[3] = xoff - (pixsize[0]+x_rot) * 0.5;
        adfMatrix[4] = y_rot;
        adfMatrix[5] = pixsize[1];
        adfMatrix[7] = yoff - (pixsize[1]+y_rot) * 0.5;
        adfMatrix[15] = 1.0;
        
        TIFFSetField( out, TIFFTAG_GEOTRANSMATRIX, 16, adfMatrix );
    }
}

double* getWorldFileMatrix( GTIF * gtif ) {
    int		i;
    /* double	adfCoeff[6], x, y; */
    double	x, y;
    double* adfCoeff = malloc(6*sizeof(double));
    short int error;

/*
 * Compute the coefficients.
 */
    error = 0;
    for (i=0; i<6; i++)
      adfCoeff[i] = 0.0;

    x = 0.5;
    y = 0.5;
    if ( !GTIFImageToPCS( gtif, &x, &y ) ) 
      error = 1;

    adfCoeff[4] = x;
    adfCoeff[5] = y;

    x = 1.5;
    y = 0.5;
    if ( !GTIFImageToPCS( gtif, &x, &y ) )
      error = 1;

    adfCoeff[0] = x - adfCoeff[4];
    adfCoeff[1] = y - adfCoeff[5];

    x = 0.5;
    y = 1.5;
    if ( !GTIFImageToPCS( gtif, &x, &y ) )
      error = 1;

    adfCoeff[2] = x - adfCoeff[4];
    adfCoeff[3] = y - adfCoeff[5];

/*
 * If any error, set all to 0.0
 */
   if (error) 
     for (i = 0; i<6; i++)
       adfCoeff[i] = 0.0;

/*
 * return the coefficients.
 */
   return adfCoeff;

}

short int*  getGeoTiffTags() {
   return GeoTiffTags;
}


AugGTIFDefn* mxArray2GTIFDef(const mxArray* mxGTIFDef) {

/* status value */
   int status;

/* code test value */
   short code;
   double dcode;

/**
 * The GTIFDefn structure containing the GeoTiff information
 * but in TIFF code (short) format.
 */
   AugGTIFDefn *GS;

/* The field number */
   int ifield;

/* The data obtained from the mxGTIDef structure */
   short *sdata;
   double *ddata;
   mxArray *mxdata;

/* The dimension variables */
   const int *dims;
   int ndim;
   int i;
   int npts;

/* The codes structure */
   mxArray *mxGTIFCodes;

/**
 * Verify the input is a structure 
 *  and obtain the GeoTiff Codes structure
 */
   if (!mxIsStruct(mxGTIFDef))
     mexErrMsgTxt("The input GeoTiff data is not a structure!");

   ifield = mxGetFieldNumber(mxGTIFDef, "GeoTIFFCodes");
   if (ifield < 0)
     mexErrMsgTxt("Error unable to obtain the GeoTIFFCodes!");

   mxGTIFCodes = mxGetFieldByNumber(mxGTIFDef, 0, ifield);
   if (mxGTIFCodes == NULL)
     mexErrMsgTxt("Error unable to obtain the GeoTIFFCodes!");

/**
 * Construct a default GTIFDefn structure 
 * which will contain the GeoTiff data in coded format
 */
   GS = initAugGTIFDefn();
   if( GS == 0 ) 
      mexErrMsgTxt("Unable to allocate a GTIF definition!");

/**
 * Copy the Model code into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"Model");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield);
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != NULL) GS->GTIFCodes.Model = *sdata;
   }

/**
 * Copy the PCS code into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"PCS");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != NULL) GS->GTIFCodes.PCS = *sdata; 
   }

/**
 * Copy the ProjCode into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"ProjCode");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != 0) GS->GTIFCodes.ProjCode = *sdata; 
   }

/**
 * Copy the GCS into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"GCS");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != 0) GS->GTIFCodes.GCS = *sdata; 
   }


/**
 * Copy the UOMAngle into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"UOMAngle");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != 0) GS->GTIFCodes.UOMAngle = *sdata; 
   }

/**
 * Copy the UOMLength into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"UOMLength");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != 0) GS->GTIFCodes.UOMLength = *sdata; 
   }

/**
 * Copy the UOMLengthInMeters into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFDef,"UOMLengthInMeters");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFDef, 0, ifield );
     ddata = (real_T *) mxGetData(mxdata);
     if (ddata != 0) GS->UOMLengthInMeters = *ddata; 
   }

/**
 * Copy the Datum into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"Datum");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != 0) GS->GTIFCodes.Datum = *sdata; 
   }

/**
 * Copy the Ellipsoid into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"Ellipsoid");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != 0) GS->GTIFCodes.Ellipsoid = *sdata; 
   }


/**
 * Copy the SemiMajor into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFDef,"SemiMajor");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFDef, 0, ifield );
     ddata = (real_T *) mxGetData(mxdata);
     if (ddata != 0) GS->SemiMajor = *ddata;
   }

/**
 * Copy the SemiMinor into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFDef,"SemiMinor");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFDef, 0, ifield );
     ddata = (real_T *) mxGetData(mxdata);
     if (ddata != 0) GS->SemiMinor = *ddata;
   }


/**
 * Copy the PM into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"PM");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != 0) GS->GTIFCodes.PM = *sdata; 
   }

/**
 * Copy the PMLongToGreenwich into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFDef,"PMLongToGreenwich");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFDef, 0, ifield );
     ddata = (real_T *) mxGetData(mxdata);
     if (ddata != 0) GS->PMLongToGreenwich = *ddata; 
   }

/**
 * Copy the CTProjection into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFCodes,"CTProjection");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFCodes, 0, ifield );
     sdata = (int16_T *) mxGetData(mxdata);
     if (sdata != 0) GS->GTIFCodes.CTProjection = *sdata; 
   }

/**
 * Copy the TiePoints, PixelScale and TransMatrix into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFDef,"TiePoints");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFDef, 0, ifield );
     ddata = (real_T *) mxGetData(mxdata);
     if (ddata != NULL) {
       ndim = mxGetNumberOfDimensions(mxdata);
       dims = mxGetDimensions(mxdata);
       if (ndim == 2) {
         npts = dims[0] * dims[1];
         GS->TiePointCount = npts;
         for (i = 0; i<npts; i++) 
           GS->TiePoints[i] = ddata[i];
       }
     }
   }

   ifield = mxGetFieldNumber(mxGTIFDef,"PixelScale");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFDef, 0, ifield );
     ddata = (real_T *) mxGetData(mxdata);
     if (ddata != NULL) {
       ndim = mxGetNumberOfDimensions(mxdata);
       dims = mxGetDimensions(mxdata);
       if (ndim == 2) {
         npts = dims[0] * dims[1];
         GS->PixelScaleCount = npts;
         for (i = 0; i<npts; i++) 
           GS->PixelScale[i] = ddata[i];
       }
     }
   }

   ifield = mxGetFieldNumber(mxGTIFDef,"TransMatrix");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFDef, 0, ifield );
     ddata = (real_T *) mxGetData(mxdata);
     if (ddata != NULL) {
       ndim = mxGetNumberOfDimensions(mxdata);
       dims = mxGetDimensions(mxdata);
       if (ndim == 2) {
         npts = dims[0] * dims[1];
         GS->TransMatrixCount = npts;
         for (i = 0; i<npts; i++) 
           GS->TransMatrix[i] = ddata[i];
       }
     }
   }

/**
 * Copy the ProjParmIds into the GTIF key
 */
   ifield = mxGetFieldNumber(mxGTIFDef,"ProjParm");
   if (ifield >= 0) {
     mxdata = mxGetFieldByNumber(mxGTIFDef, 0, ifield );
     ddata = (real_T *) mxGetData(mxdata);
     if (ddata != NULL) {
       ndim = mxGetNumberOfDimensions(mxdata);
       dims = mxGetDimensions(mxdata);
       if (ndim == 2) {
         npts = dims[0] * dims[1];
         GS->nParms = npts;
         for (i = 0; i<npts; i++) 
           GS->ProjParm[i] = ddata[i];
       }
     }
   }
   return GS;

}

GTIFDefn AugGTIFDefnToGTIFDefn( const AugGTIFDefn *GS) {

   int i;
/**
 * The GTIFDefn structure containing the GeoTiff information
 * but in TIFF code (short) format.
 */
   GTIFDefn	psDefn;

/**
 * Copy the Model code into the GTIF key
 */
   psDefn.Model = GS->GTIFCodes.Model; 

/**
 * Copy the PCS code into the GTIF key
 */
   psDefn.PCS= GS->GTIFCodes.PCS; 

/**
 * Copy the GCS into the GTIF key
 */
   psDefn.GCS = GS->GTIFCodes.GCS; 

/**
 * Copy the UOMLength into the GTIF key
 */
   psDefn.UOMLength = GS->GTIFCodes.UOMLength; 

/**
 * Copy the UOMLengthInMeters into the GTIF key
 */
   psDefn.UOMLengthInMeters = GS->UOMLengthInMeters; 

/**
 * Copy the UOMAngle into the GTIF key
 */
   psDefn.UOMAngle = GS->GTIFCodes.UOMAngle; 

/**
 * Copy the UOMAngleInDegress into the GTIF key
 */
   psDefn.UOMAngleInDegrees = GS->UOMAngleInDegrees; 

/**
 * Copy the Datum into the GTIF key
 */
   psDefn.Datum = GS->GTIFCodes.Datum; 

/**
 * Copy the PM into the GTIF key
 */
   psDefn.PM = GS->GTIFCodes.PM; 

/**
 * Copy the PMLongToGreenwich into the GTIF key
 */
   psDefn.PMLongToGreenwich = GS->PMLongToGreenwich; 

/**
 * Copy the Ellipsoid into the GTIF key
 */
   psDefn.Ellipsoid = GS->GTIFCodes.Ellipsoid; 

/**
 * Copy the SemMajor into the GTIF key
 */
   psDefn.SemiMajor = GS->SemiMajor; 

/**
 * Copy the SemiMinor into the GTIF key
 */
   psDefn.SemiMinor = GS->SemiMinor; 

/**
 * Copy the ProjCode into the GTIF key
 */
   psDefn.ProjCode= GS->GTIFCodes.ProjCode; 

/**
 * Copy the Projection into the GTIF key
 */
   psDefn.Projection = GS->GTIFCodes.Projection; 

/**
 * Copy the CTProjection into the GTIF key
 */
   psDefn.CTProjection = GS->GTIFCodes.CTProjection; 

/**
 * Copy the number of params into the GTIF key
 */
   psDefn.nParms = GS->nParms; 

/**
 * Copy the projection parameters and ids
 */
   for (i=0; i<GS->nParms; i++) {
     psDefn.ProjParm[i] = GS->ProjParm[i];
     psDefn.ProjParmId[i] = GS->GTIFCodes.ProjParmId[i];
   }

/**
 * Copy the MapZys
 */
   psDefn.Zone = GS->GTIFCodes.MapSys; 

/**
 * Copy the Zone
 */
   psDefn.Zone = GS->Zone; 

   return psDefn;
}
/************************************************************************/
/*                         mxGTIFProj4ToLatLong()                       */
/*                                                                      */
/*      Convert projection coordinates to lat/long for a particular     */
/*      definition.                                                     */
/************************************************************************/

int mxGTIFProj4ToLatLong( GTIFDefn * psDefn, int nPoints,
                        double *padfX, double *padfY,
                        double *lon, double *lat)

{
    char	*pszProjection, **papszArgs;
    PJ		*psPJ;
    int		i;
    
/* -------------------------------------------------------------------- */
/*      Get a projection definition.                                    */
/* -------------------------------------------------------------------- */
    pszProjection = GTIFGetProj4Defn( psDefn );
    /* fprintf(stderr,"Projection: %s\n", pszProjection);  */

    if( pszProjection == NULL )
        return FALSE;

/* -------------------------------------------------------------------- */
/*      Parse into tokens for pj_init(), and initialize the projection. */
/* -------------------------------------------------------------------- */
    
    papszArgs = CSLTokenizeStringComplex( pszProjection, " +", TRUE, FALSE );
    free( pszProjection );

    psPJ = pj_init( CSLCount(papszArgs), papszArgs );

    CSLDestroy( papszArgs );

    if( psPJ == NULL )
    {
        return FALSE;
    }

/* -------------------------------------------------------------------- */
/*      Process each of the points.                                     */
/* -------------------------------------------------------------------- */
    for( i = 0; i < nPoints; i++ )
    {
        UV	sUV;

        sUV.u = padfX[i];
        sUV.v = padfY[i];

        sUV = pj_inv( sUV, psPJ );

        lon[i] = sUV.u * RAD_TO_DEG;
        lat[i] = sUV.v * RAD_TO_DEG;
    }

    pj_free( psPJ );

    return TRUE;
}

/************************************************************************/
/*                         mxGTIFProj4FromLatLong()                     */
/*                                                                      */
/*      Convert projection coordinates from x,y for a particular        */
/*      definition.                                                     */
/************************************************************************/

int mxGTIFProj4FromLatLong( GTIFDefn * psDefn, int nPoints,
                        double *lon, double *lat,
                        double *padfX, double *padfY)

{
    char	*pszProjection, **papszArgs;
    PJ		*psPJ;
    int		i;
    
/* -------------------------------------------------------------------- */
/*      Get a projection definition.                                    */
/* -------------------------------------------------------------------- */
    pszProjection = GTIFGetProj4Defn( psDefn );
    /* fprintf(stderr,"Projection: %s\n", pszProjection);  */

    if( pszProjection == NULL )
        return FALSE;

/* -------------------------------------------------------------------- */
/*      Parse into tokens for pj_init(), and initialize the projection. */
/* -------------------------------------------------------------------- */
    
    papszArgs = CSLTokenizeStringComplex( pszProjection, " +", TRUE, FALSE );
    free( pszProjection );

    psPJ = pj_init( CSLCount(papszArgs), papszArgs );

    CSLDestroy( papszArgs );

    if( psPJ == NULL )
    {
        return FALSE;
    }

/* -------------------------------------------------------------------- */
/*      Process each of the points.                                     */
/* -------------------------------------------------------------------- */
    for( i = 0; i < nPoints; i++ )
    {
        UV	sUV;

        sUV.u = lon[i] * DEG_TO_RAD;
        sUV.v = lat[i] * DEG_TO_RAD;

        sUV = pj_fwd( sUV, psPJ );

        padfX[i] = sUV.u;
        padfY[i] = sUV.v;
    }

    pj_free( psPJ );

    return TRUE;
}
