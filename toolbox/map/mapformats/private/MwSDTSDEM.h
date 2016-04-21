#ifndef _MwSDTSDEM_H
#define _MwSDTSDEM_H

#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <cctype>

#include <io/sio_8211Converter.h>
#include <builder/sb_Spatial.h>
#include "MwSDTS.h"


using namespace std;

// This  class represents an SDTS DEM transfer set.
// It's data members are information that are specific
// to a SDTS DEM data set and it also includes the 
// demValues which contains the actual elevationd data.
class MwSDTSDEM : public MwSDTS
{

 public:

  MwSDTSDEM();
  MwSDTSDEM(const string &filename);
  ~MwSDTSDEM();
 
  // This method calls the open method in the
  // MwSDTS class (base).
  bool open(const string &filename);

  bool loadInfo();

  // Reads data from the cell module file into demValues
  // The cell module file name is typically ????CEL0.DDF
  bool loadCell();  

  bool         _isRaster, _loaded;

  // This functions are used to returning the mxArray
  // containing the Info structure and elevation data.
  mxArray *getMxInfoStruct();
  mxArray *getMxDemData();

 private:

  double        *demValues;
  double       _demFillValue;
  double       _demVoidValue;
  bool         _haveFillValue;
  bool         _haveVoidValue;
  bool         _deleteDemValues;

  long         _numRows, _numCols;
  
  double       _xHorizRes, _yHorizRes;
  double       _xOrigin, _yOrigin;
  double       _xScaleFactor, _yScaleFactor;

  double       _minValue, _maxValue;
  
  double       _xTopLeft, _yTopLeft;
  double       *xSpatialOutline, *ySpatialOutline;
  sb_Spatials  spatialOutline;
  int         _zoneNum;
  string      _projection;
  string      _horizDatum, _vertDatum;
  
  string      _horizUnits, _vertUnits;

  // This is the converter dictionary containing
  // the appropriate format for the elevation data
  // and spatial address.
  sio_8211_converter_dictionary converters;
  sio_8211Converter_BI16  _converter_bi16;
  sio_8211Converter_BI32  _converter_bi32;
  
  // This is a helper function for loading data from
  // the raster module.
  // This is used in the event that using the "get" 
  // member of the sb_Accessor class fails.
  bool getRasterModule();

  bool getDoubleFromSf(sc_Subfield const& subf,
                             double &val);
  
};

#endif // _MwSDTSDEM_H
