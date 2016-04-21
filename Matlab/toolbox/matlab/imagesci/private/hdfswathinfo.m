function swathinfo = hdfswathinfo(filename,fileID,swathname)
%HDFSWATHINFO Information about HDF-EOS Swath data.
%
%   SWATHINFO = HDFSWATHINFO(FILENAME,SWATHNAME) returns a structure whose
%   fields contain information about a Swath data set in an HDF-EOS
%   file. FILENAME is a string that specifies the name of the HDF-EOS file
%   and SWATHNAME is a string that specifies the name of the Swath data set.
%
%   The fields of SWATHINFO are:
%
%   Filename           A string containing the name of the file
%		       
%   Name               A string containing the name of the data set
%		       
%   DataFields         An array of structures with fields 'Name', 'Rank', 'Dims',
%                      'NumberType', and 'FillValue'.  Each structure
%                      describes a Data field in the Swath 
%
%   GeolocationFields  An array of structures with fields 'Name', 'Rank', 'Dims',
%                      'NumberType', and 'FillValue'.  Each structure
%                      describes a Geolocation field in the Swath 
%
%   MapInfo            A structure with fields 'Map', 'Offset', and
%                      'Increment' describing the relationship between the
%                      data and geolocation fields. 
%
%   IdxMapInfo         A structure with 'Map' and 'Size' describing the
%                      relationship between the indexed elements of the
%                      geolocation mapping
%
%   Attributes         An array of structures with fields 'Name' and 'Value'
%                      describing the name and value of the swath attributes 
%                      
%   Type               A string describing the type of HDF/HDF-EOS object.
%                     'HDF-EOS Swath' for Swath data sets

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:17 $

swathinfo = [];

error(nargchk(3,3,nargin, 'struct'));
if ~ischar(filename)
  error('MATLAB:hdfswathinfo:filenameType', 'FILENAME must be a string.');
end
if ~ischar(swathname)
  error('MATLAB:hdfswathinfo:swathnameType', 'SWATHNAME must be a string.');
end

msg = sprintf('Error opening Swath interface to ''%s''.  The Swath may not exist or the file may be corrupt.',swathname);
%Open Swath interfaces
swathID = hdfsw('attach',fileID,swathname);
if swathID==-1
  warning('MATLAB:hdfswathinfo:interfaceOpen', '%s', msg);
  return;
end

%Get Data Field information
[nfields, fieldListLong] = hdfsw('inqdatafields',swathID);
hdfwarn(nfields)
if nfields>0
  fieldList = parselist(fieldListLong);
  
  rank = cell(1, nfields);
  numberType = cell(1, nfields);
  Dims = cell(1, nfields);
  FillValue = cell(1, nfields);
  
  for i=1:nfields
    fill = hdfsw('getfillvalue',swathID,fieldList{i});
    [rank{i},dimSizes,numberType{i},dimListLong] = hdfsw('fieldinfo',swathID,fieldList{i});
    dimList = parselist(dimListLong);
    Dims{i} = struct('Name',dimList(:),'Size',num2cell(dimSizes(:)));
    FillValue{i} = fill;
  end
  DataFields = struct('Name',fieldList(:),'Rank',rank(:),'Dims',Dims(:),...
		      'NumberType',numberType(:),'FillValue', FillValue(:));
else
  DataFields = [];
end

%Get Geolocation information
[ngeofields, fieldListLong, ranktmp, numbertype] = hdfsw('inqgeofields',swathID);
hdfwarn(ngeofields)

Dims = cell(1, ngeofields);
FillValue = cell(1, ngeofields);
rank = cell(1, ngeofields);

if ngeofields>0
  fieldList = parselist(fieldListLong);
  for i=1:ngeofields
    fill = hdfsw('getfillvalue',swathID,fieldList{i});
    [rank{i},dimSizes,numberType,dimListLong] = hdfsw('fieldinfo',swathID,fieldList{i});
    dimList = parselist(dimListLong);
    Dims{i} = struct('Name',dimList(:),'Size',num2cell(dimSizes(:)));
    FillValue{i} = fill;
  end
  GeolocationFields = struct('Name',fieldList(:),'Rank',rank(:),'Dims',Dims(:),'NumberType',numbertype(:),'FillValue',FillValue(:));
else
  GeolocationFields = [];
end

%Get Geolocation relations
[nmaps, dimMapLong, offset, increment] = hdfsw('inqmaps',swathID);
if nmaps>0
  dimMap = parselist(dimMapLong);
  MapInfo = struct('Map',dimMap(:),'Offset',num2cell(offset(:)),'Increment',num2cell(increment(:)));
else 
  MapInfo = [];
end

%Get index mapping relations
[nmaps, idxMapLong, idxSizes] = hdfsw('inqidxmaps',swathID);
hdfwarn(nmaps)
if nmaps>0
  idxMap = parselist(idxMapLong);
  IdxMapInfo = struct('Map',idxMap(:),'Size',num2cell(idxSizes(:)));
else 
  IdxMapInfo = [];
end

%Retrieve attribute information
[nattr, attrListLong] = hdfsw('inqattrs',swathID);
hdfwarn(nattr)
if nattr>0
  attrList = parselist(attrListLong);
  Attributes = cell2struct(attrList,'Name',1);
  for i=1:nattr
    [Attributes(i).Value, status] = hdfsw('readattr',swathID,attrList{i});
    hdfwarn(status)
  end
else 
  Attributes = [];
end

%Close interfaces
hdfsw('detach',swathID);

%Populate output structure
swathinfo.Filename         = filename;
swathinfo.Name             = swathname;         
swathinfo.DataFields       = DataFields;       
swathinfo.GeolocationFields= GeolocationFields;
swathinfo.MapInfo          = MapInfo;
swathinfo.IdxMapInfo       = IdxMapInfo;
swathinfo.Attributes       = Attributes;
swathinfo.Type             = 'HDF-EOS Swath';
return;




