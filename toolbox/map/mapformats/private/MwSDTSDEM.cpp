
#include "mex.h"
#include <string>
#include <strstream>
#include <cctype>
#include <algorithm>
#include <stdlib.h>
#include "MwSDTSDEM.h"

#include <builder/sb_Xref.h>
#include <builder/sb_Iref.h>
#include <builder/sb_Rsdf.h>
#include <builder/sb_Ddsh.h>
#include <builder/sb_Ddom.h>
#include <builder/sb_Spdm.h>
#include <builder/sb_Cell.h>
#include <builder/sb_Spatial.h>
#include <io/sio_ConverterFactory.h>
#include <io/sio_Reader.h>

MwSDTSDEM::MwSDTSDEM():
// DEM fill and void values are typically -32766
// otherwise we can read from the DDOM module
    _demFillValue(-32766), 
    _demVoidValue(-32766),
    _haveFillValue(true),
    _haveVoidValue(true),
    _numRows(0),
    _numCols(0),
    _xHorizRes(0.0),
    _yHorizRes(0.0),
    _xTopLeft(0.0),
    _yTopLeft(0.0),
    _minValue(0.0),
    _maxValue(0.0),
    _zoneNum(0),
    _deleteDemValues(false),
    _loaded(false),
    _isRaster(true)
{}

MwSDTSDEM::MwSDTSDEM(const string &filename)
{
  MwSDTSDEM();
  open(_catdFilename);

}

MwSDTSDEM::~MwSDTSDEM()
{
  //delete[] demvalues;
  if (_deleteDemValues)
    mxFree(demValues);
}

static
char
toupper_( char c ) 
{ 
    return toupper( c ); 
} // toupper_


bool MwSDTSDEM::open(const string &filename)
{
  if(!MwSDTS::open(filename))
    return false;

  if (!MwSDTS::loadInfo())
    return false;
  
  transform(_profileID.begin(), _profileID.end(), _profileID.begin(), 
            toupper_);
  
  if (string::npos == _profileID.find("RASTER")) {
    _isRaster = false;
  }

  return true;
}


bool MwSDTSDEM::loadInfo()
{
  sb_Xref xrefMod;
  sb_Iref irefMod;
  sb_Rsdf rsdfMod;
  sb_Ddsh ddshMod;
  sb_Ddom ddomMod;
  sb_Spdm spdmMod;
  
  string tZoneNum;

  bool skipRsdf = false;

  // If the SDTS data set is non-Raster i.e.
  // it is not identified as conforming to the
  // raster profile, we return.
  if (!_isRaster)
    return true;

  
  if (!moduleFiles->get(ddshMod)) {
    _errMsgTxt = "Can not access Data Dictionary/Schema Module!";
    return false;
  }
  
  if (!moduleFiles->get(irefMod)) {
    _errMsgTxt = "Can not access Internal Spatial Reference Module!";
    return false;
  }

  sb_Utils::addConverter( ddshMod, converters );
  sb_Utils::addConverter( irefMod, converters );
  
  
  if (!moduleFiles->get(xrefMod)) {
    _errMsgTxt = "Can not access External Spatial Reference Module!";
    return false;
  }

  // If the reading the Raster Definition Module using sb_Accessor fails,
  // call getRasterModule.
  if (!moduleFiles->get(rsdfMod)) {
    if(!getRasterModule()) { 
      return false;
    }
    skipRsdf = true;
  }
  
  if (!moduleFiles->get(ddomMod)) {
    _errMsgTxt = "Can not access Data Dictionary/Domain Module!";
    return false;
  }

  if (!moduleFiles->get(spdmMod)) {
      _errMsgTxt = "Can not access the Spatial Domain Module!";
      return false;
  }

  xrefMod.getReferenceSystemName(_projection);
  if (_projection == "UTM" || _projection == "UPS") {
    _horizUnits = "METERS";
  }
  xrefMod.getHorizontalDatum(_horizDatum);
  //xrefMod.getVerticalDatum(_vertDatum);
  xrefMod.getZoneReferenceNumber(tZoneNum);
  _zoneNum = atoi(tZoneNum.c_str());
  irefMod.getXComponentHorizontalResolution(_xHorizRes);
  irefMod.getYComponentHorizontalResolution(_yHorizRes);
  irefMod.getScaleFactorX(_xScaleFactor);
  irefMod.getScaleFactorY(_yScaleFactor);
  irefMod.getXOrigin(_xOrigin);
  irefMod.getYOrigin(_yOrigin);
  if (!skipRsdf) {
    rsdfMod.getRowExtent(_numRows);
    rsdfMod.getColumnExtent(_numCols);
    rsdfMod.getSpatialAddress(_xTopLeft, _yTopLeft);
  }
  ddshMod.getUnit(_vertUnits);

  int counter = 0;
  string chkString;
  sc_Subfield sField;
  double val;

  while (moduleFiles->get(ddomMod)) {
    
    ddomMod.getDomainValue(sField);
    getDoubleFromSf(sField, val);
    
    ddomMod.getRangeOrValue(chkString);
    if (chkString == "MIN") {
      _minValue = val;
    }
    if (chkString == "MAX") {
      _maxValue = val;
    }
  }

  spdmMod.getDomainSpatialAddress(spatialOutline);
  
  xSpatialOutline = (double *) mxCalloc(spatialOutline.size()*2, sizeof(double));
  ySpatialOutline = xSpatialOutline + spatialOutline.size();

  for (int i = 0 ; i < spatialOutline.size() ; i++) {
      getDoubleFromSf(spatialOutline[i].x(), xSpatialOutline[i]);
      getDoubleFromSf(spatialOutline[i].y(), ySpatialOutline[i]);
  }
  
  return true;
}


mxArray *MwSDTSDEM::getMxInfoStruct()
{
  mxArray *tmpMstruct;
  mxArray *tmpMsubStruct;
  int numMainfields;
  int numRasterfields;
  
  const char *mainfields [] = {
                               "Title",
			       "ProfileID",
			       "ProfileVersion",
			       "MapDate",
			       "DataCreationDate",
			       "ProfileStruct"
                               };

  const char *rasterfields [] = {
			       "HorizontalDatum",
			       "VerticalDatum",
			       "ZoneNumber",
			       "ReferenceSystem",
			       "XHorizResolution",
			       "YHorizResolution",
			       "NumberOfRows",
			       "NumberOfCols",
			       "HorizontalUnits",
			       "VerticalUnits",
			       "XOrigin",
			       "YOrigin",
			       "XScaleFactor",
			       "YScaleFactor",
			       "XTopLeft",
			       "YTopLeft",
			       "MinimumValue",
			       "MaximumValue",
			       "FillValue",
			       "VoidValue", 
                               "BoundingBox",
                               };

  numMainfields = sizeof(mainfields)/sizeof(*mainfields);
  numRasterfields = sizeof(rasterfields)/sizeof(*rasterfields);
  tmpMstruct = mxCreateStructMatrix(1,1,numMainfields, mainfields);

  //Title
  mxSetField(tmpMstruct, 0, mainfields[0], mxCreateString(_title.c_str()));
  
  //ProfileID
  mxSetField(tmpMstruct, 0, mainfields[1], mxCreateString(_profileID.c_str()));
  
  //ProfileVer
  mxSetField(tmpMstruct, 0, mainfields[2], mxCreateString(_profileVer.c_str()));
  
  //MapDate
  mxSetField(tmpMstruct, 0, mainfields[3], mxCreateString(_mapDate.c_str()));
  
  //CreationDate
  mxSetField(tmpMstruct, 0, mainfields[4], mxCreateString(_creationDate.c_str()));
  
  if (!_isRaster) {
    mxSetField(tmpMstruct, 0, mainfields[5], 
	       mxCreateString("NULL"));
    return tmpMstruct;
  }
	       
  //ProfileStruct
  tmpMsubStruct = mxCreateStructMatrix(1, 1, numRasterfields, rasterfields);

  //HDatum
  mxSetField(tmpMsubStruct, 0, rasterfields[0], mxCreateString(_horizDatum.c_str()));

  //VDatum
  mxSetField(tmpMsubStruct, 0, rasterfields[1], mxCreateString(_vertDatum.c_str()));
  
  //ZoneNum
  mxSetField(tmpMsubStruct, 0, rasterfields[2], mxCreateDoubleScalar((double)_zoneNum));
  
  //Projection
  mxSetField(tmpMsubStruct, 0, rasterfields[3], mxCreateString(_projection.c_str()));
  
  //XHRes
  mxSetField(tmpMsubStruct, 0, rasterfields[4], mxCreateDoubleScalar(_xHorizRes));
  
  //YHRes
  mxSetField(tmpMsubStruct, 0, rasterfields[5], mxCreateDoubleScalar(_yHorizRes));
  
  //NumRows
  mxSetField(tmpMsubStruct, 0, rasterfields[6], mxCreateDoubleScalar((double)_numRows));
  
  //NumCols
  mxSetField(tmpMsubStruct, 0, rasterfields[7], mxCreateDoubleScalar((double)_numCols));
  
  //HUnits
  mxSetField(tmpMsubStruct, 0, rasterfields[8], mxCreateString(_horizUnits.c_str()));

//HUnits
  mxSetField(tmpMsubStruct, 0, rasterfields[9], mxCreateString(_vertUnits.c_str()));
  
  //XOrigin
  mxSetField(tmpMsubStruct, 0, rasterfields[10], mxCreateDoubleScalar(_xOrigin));
  
  //YOrigin
  mxSetField(tmpMsubStruct, 0, rasterfields[11], mxCreateDoubleScalar(_yOrigin));

  //XScaleFactor
  mxSetField(tmpMsubStruct, 0, rasterfields[12], mxCreateDoubleScalar(_xScaleFactor));
  
  //YScaleFactor
  mxSetField(tmpMsubStruct, 0, rasterfields[13], mxCreateDoubleScalar(_yScaleFactor));
  
  //xTopLeft
  mxSetField(tmpMsubStruct, 0, rasterfields[14], mxCreateDoubleScalar(_xTopLeft));
  
  //yTopLeft
  mxSetField(tmpMsubStruct, 0, rasterfields[15], mxCreateDoubleScalar(_yTopLeft));
  
  //MinimumValue
  mxSetField(tmpMsubStruct, 0, rasterfields[16], mxCreateDoubleScalar(_minValue));
  
  //MaximumValue
  mxSetField(tmpMsubStruct, 0, rasterfields[17], mxCreateDoubleScalar(_maxValue));


  //FillValue
  mxSetField(tmpMsubStruct, 0, rasterfields[18], _haveFillValue ? 
             mxCreateDoubleScalar(_demFillValue) : mxCreateDoubleMatrix(0,0,mxREAL));

  //VoidValue
  mxSetField(tmpMsubStruct, 0, rasterfields[19], _haveVoidValue ?
             mxCreateDoubleScalar(_demVoidValue) : mxCreateDoubleMatrix(0,0,mxREAL));
  
  //BoundingBox
  mxArray * tmpBbox = mxCreateDoubleMatrix(0,0,mxREAL);
  mxSetPr(tmpBbox, xSpatialOutline);
  mxSetM(tmpBbox, spatialOutline.size());
  mxSetN(tmpBbox, 2);
  mxSetField(tmpMsubStruct, 0, rasterfields[20], tmpBbox);
  
  mxSetField(tmpMstruct, 0, mainfields[5], tmpMsubStruct);

  return tmpMstruct;
}

mxArray *MwSDTSDEM::getMxDemData()
{
  mxArray *tempArray;

  tempArray = mxCreateDoubleMatrix(0,0,mxREAL);
  mxSetPr(tempArray, demValues);

  // The matrix is transposed since the cells are
  // arranged in a row major order.
  mxSetM(tempArray, _numCols);
  mxSetN(tempArray, _numRows);
  _deleteDemValues = false;

  return tempArray;
}


bool MwSDTSDEM::loadCell()
{

    vector<long> cellData;
    int index = 0;

    sc_Record const *record_;
    sc_Record record;
  
    ifstream ifs;
    string tmpStr;
    strstream tmpSs;
    
    // Won't load if the data has already been loaded.
    // However that doesn't constitute a failure.
    if (_loaded)
      return true;
  
    demValues = (double *)mxCalloc(_numCols * _numRows, sizeof(double));
    _deleteDemValues = true;

    back_insert_iterator<vector<long> > iterVec(cellData);

    sb_Cell< vector<long> > cellMod(index);

    tmpStr = _catdFilename;
    strstream tmp_ss;
    tmpSs << "CEL" << index <<ends;
    tmpStr.replace(tmpStr.find("CATD"), 4, tmpSs.str());
    
#ifndef ARCH_MAC
    ifs.open( tmpStr.c_str(), ios::binary );
#else
    ifs.open( tmpStr.c_str() );
#endif /* MAC */

    if (!ifs.is_open()) {
        tmpSs << "Could not open the file " << tmpStr << ends;
        _errMsgTxt = tmpSs.str();
        return false;
    }
    
    sio_8211Reader reader( ifs, &converters );
    sio_8211ForwardIterator fIter(reader);
  
    sc_Record::const_iterator cvls_field;
    sc_Field::const_iterator elevation_subfield;
  
    int samples = 0;
    int recordCounter = 0;

    while (!fIter.done() && (recordCounter <_numRows)) {

        try {
            if (!fIter.get(record)) {
                break;
            }
        }
        catch(...) {
            _errMsgTxt = "Unable to read record. \nThe cell module might "
                "be corrupted.";
            return false;
        }

#ifdef DEBUG
        mexPrintf("Step 2 %d\n", samples);        
        mexPrintf("count is %d\n", samples);
#endif //DEBUG

        cellMod.setRecord(record);
        try {
            cellMod.loadData(iterVec);
        }
        catch(...) {
            _errMsgTxt = "Unable to read data from record. \nThe cell module might "
                "be corrupted.";
            return false;
        }
        
#ifdef DEBUG
        mexPrintf("Step 3 %d\n", samples);
	mexPrintf("%%%%%%% The cellData size is %d %%%%%%%%%%", cellData.size());
#endif //DEBUG
        
	if (cellData.size() != _numCols) {
	  mexPrintf("Something is wrong!!!\n");
	  mexPrintf("The size of the cellData is %d ", cellData.size());
	  mexPrintf("and the number of Columns is %d.\n", _numCols);
	}

        for (int i = 0; i < cellData.size() ; i++) {
            demValues[recordCounter * _numCols + i] = (double)cellData[i];
        }
        cellData.clear();
        ++fIter;
	++recordCounter;
    } //while (!fIter.done())
    
    if (recordCounter != _numRows) {
	  mexPrintf("Something is wrong!!!\n");
	  mexPrintf("The number of rows is %d ", _numRows );
	  mexPrintf("and the number of records read is %d.\n", recordCounter);
        _errMsgTxt = "Could not read from entire cell module.";
        ifs.close();
        return false;
    }
    
#ifdef DEBUG
    mexPrintf("\n\nThe number of samples is %ld\n", samples);
#endif //DEBUG

    _loaded = true;
    
    ifs.close();
    return true;
}


bool MwSDTSDEM::getRasterModule() 
{
  ifstream ifs;
  string tmpStr = _catdFilename;
  tmpStr.replace(tmpStr.find("CATD"), 4, "RSDF");
  
  ifs.open(tmpStr.c_str(), ios::in);
  
  if (!ifs.is_open()) {
    _errMsgTxt = "Can not open the Raster Module file!";
    return false;
  }
  
  sio_8211Reader reader(ifs, &converters);
  sio_8211ForwardIterator modIter(reader);
  sc_Record record;
  sc_Record::const_iterator curfield;
  sc_Field::const_iterator cursubfield;
  
  //  while (!modIter.done()) {
  if (!modIter.get(record)) {
    _errMsgTxt = "Can not get record from Raster Module!";
    return false;
  }
  if (!sb_Utils::getFieldByMnem( record, "RSDF", curfield)) {
    _errMsgTxt = "This is not a raster definition record.";
    return false;
  }
  if (sb_Utils::getSubfieldByMnem( *curfield, "RWXT", cursubfield)) {
    cursubfield->getI( _numRows );
  }
  if (sb_Utils::getSubfieldByMnem( *curfield, "CLXT", cursubfield)) {
    cursubfield->getI( _numCols );
  }

  if (sb_Utils::getFieldByMnem( record, "SADR", curfield)) {
    if (sb_Utils::getSubfieldByMnem(*curfield, "X", cursubfield))
      sb_Utils::getDoubleFromSubfield(cursubfield, _xTopLeft);

    if (sb_Utils::getSubfieldByMnem(*curfield, "Y", cursubfield))
      sb_Utils::getDoubleFromSubfield(cursubfield, _yTopLeft);
  }
  else {
      _errMsgTxt = "Could not find the SADR field.";
  }
  
  ifs.close();
  return true;
}

// This is a modification of the sb_Utils::getDoubleFromSubfield function
// to work with sc_Subfields instead of the sc_SubfieldCntr::const_iterator.

bool
MwSDTSDEM::getDoubleFromSf(sc_Subfield const& subf,
                                double& dataOut )
{

  bool rc;
  unsigned long tempULong;
  long tempLong;
  sc_Subfield::SubfieldType sType = subf.getSubfieldType();

  switch(sType) {

    // Not supported at this time.
    // convert string class to double
  case(sc_Subfield::is_A):
  case(sc_Subfield::is_C):
    return false;
    break;

    // convert long to double
  case(sc_Subfield::is_I):
    rc = subf.getI( tempLong );
    dataOut = double(tempLong);
    break;
  case(sc_Subfield::is_BI8):
    rc = subf.getBI8( tempLong );
    dataOut = double(tempLong);
    break;
  case(sc_Subfield::is_BI16):
    rc = subf.getBI16( tempLong );
    dataOut = double(tempLong);
    break;
  case(sc_Subfield::is_BI24):
    rc = subf.getBI24( tempLong );
    dataOut = double(tempLong);
    break;
  case(sc_Subfield::is_BI32):
    rc = subf.getBI32( tempLong );
    dataOut = double(tempLong);
    break;

    // Convert unsigned long to double
  case(sc_Subfield::is_BUI8):
    rc = subf.getBUI8( tempULong );
    dataOut = double(tempULong );
    break;
  case(sc_Subfield::is_BUI16):
    rc = subf.getBUI16( tempULong );
    dataOut = double(tempULong );
    break;
  case(sc_Subfield::is_BUI24):
    rc = subf.getBUI24( tempULong );
    dataOut = double(tempULong );
    break;
  case(sc_Subfield::is_BUI32):
    rc = subf.getBUI32( tempULong );
    dataOut = double(tempULong );
    break;

    //convert double to double
  case(sc_Subfield::is_R):
    rc = subf.getR( dataOut );
    break;
  case(sc_Subfield::is_S):
    rc = subf.getS( dataOut );
    break;

    // non-implimented return false
  case(sc_Subfield::is_B):
  case(sc_Subfield::is_BUI):
  case(sc_Subfield::is_BFP32):
  case(sc_Subfield::is_BFP64):
    rc = false;
    break;
		
    // Shouldn't get here, except in an error situation
  default:
    rc = false;
  }

  return rc;
}
