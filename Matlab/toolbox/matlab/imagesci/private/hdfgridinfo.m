function gridinfo = hdfgridinfo(filename,fileID,gridname)
%HDFGRIDINFO Information about HDF-EOS Grid data.
%
%   GRIDINFO = HDFGRIDINFO(FILENAME,GRIDNAME) returns a structure whose
%   fields contain information about a Grid data set in an HDF-EOS
%   file. FILENAME is a string that specifies the name of the HDF-EOS file
%   and GRIDNAME is a string that specifyies the name of the Grid data set
%   in the file.
%
%   The fields of GRIDINFO are:
%
%   Filename       A string containing the name of the file
%
%   Name           A string containing the name of the Grid
%  
%   UpperLeft      A number specifying the upper left corner location
%                  in meters
%
%   LowerRight     A number specifying the lower right corner location
%                  in meters
%
%   Rows           An integer specifying the number of rows in the Grid
%   
%   Columns        An integer specifying the number of columns in the Grid
%
%   DataFields     An array of structures with fields 'Name', 'Rank', 'Dims',
%                  'NumberType', 'FillValue', and 'TileDims'. Each structure
%                  describes a data field in the Grid 
%
%   Attributes     An array of structures with fields 'Name' and 'Value'
%                  describing the name and value of the attributes of the
%                  Grid
%
%   Projection     A structure with fields 'ProjCode', 'ZoneCode',
%                  'SphereCode', and 'ProjParam' describing the Projection
%                  Code, Zone Code, Sphere Code and projection parameters of
%                  the Grid
%
%   Origin Code    A number specifying the origin code for the Grid
%
%   PixRegCode     A number specifying the pixel registration code
%
%   Type           A string describing the type of HDF/HDF-EOS
%                  object. 'HDF-EOS Grid' for Grid data sets
%

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:06 $

%Return empty for data set not found 
gridinfo = [];

error(nargchk(3,3,nargin, 'struct'));

if ~ischar(filename)
  error('MATLAB:hdfgridinfo:badFilename', 'FILENAME must be a string.');
end

if ~ischar(gridname)
  error('MATLAB:hdfgridinfo:badGridname', 'GRIDNAME must be a string.');
end

%Open interfaces, return early if opening the file or attaching to the grid
%fails
gridID = hdfgd('attach',fileID,gridname);
if gridID==-1

    warning('MATLAB:hdfgridinfo:openInterface', ...
            'Unable to open Grid interface for ''%s'' data set. File may be corrupt.', ...
            gridname)
    return
    
end

%Get upper left and lower right grid corners, # of rows and cols 
[Columns, Rows, UpperLeft, LowerRight, status] = hdfgd('gridinfo',gridID);
hdfwarn(status) 

%Get info on data fields. fieldListLong is a comma seperated list and
%numberType is a cell array of strings
[nfields, fieldListLong, ranktmp, numberType] = hdfgd('inqfields',gridID);
hdfwarn(nfields)
if nfields>0
  fieldList = parselist(fieldListLong);
  rank = cell(1,nfields);
  Dims = cell(1,nfields);
  FillValue = cell(1,nfields);
  tilecode = cell(1,nfields);
  tiledims = cell(1,nfields);
  for i=1:nfields
    fill = hdfgd('getfillvalue',gridID,fieldList{i});
    [rank{i},dimSizes,numberType{i},dimListLong] = hdfgd('fieldinfo',gridID,fieldList{i});
    dimList = parselist(dimListLong);
    Dims{i} = struct('Name',dimList(:),'Size',num2cell(dimSizes(:)));
    FillValue{i} = fill;
    %Get tile info 
    [tilecode{i},tiledims{i}] = hdfgd('tileinfo',gridID,fieldList{i});
    if isempty(tiledims{i}) 
      tiledims{i} = [];
    end
  end
  DataFields = struct('Name',fieldList(:),'Rank',rank(:),'Dims',Dims(:),...
		      'NumberType',numberType(:), 'FillValue', FillValue(:),...
		      'TileDims',tiledims(:));
else 
  DataFields = [];
end

%Get attribute information 
[nattrs, attrListLong] = hdfgd('inqattrs',gridID);
hdfwarn(nattrs)
if nattrs>0
  attrList = parselist(attrListLong);
  Attributes = cell2struct(attrList,'Name',1);
  for i=1:nattrs
    [Attributes(i).Value, status] = hdfgd('readattr',gridID,attrList{i});
    hdfwarn(status)
  end
else
  Attributes = [];
end

%Get projection information
[Projection.ProjCode,Projection.ZoneCode,Projection.SphereCode,Projection.ProjParam, status] = hdfgd('projinfo',gridID);
hdfwarn(status)

%Get origin code
OriginCode = hdfgd('origininfo',gridID);
hdfwarn(OriginCode)

%Get pixel region info
PixRegCode = hdfgd('pixreginfo',gridID);
hdfwarn(PixRegCode)

%Close interfaces
hdfgd('detach',gridID);

%Assign output structure
gridinfo.Filename     =	 filename;	 
gridinfo.Name         =	 gridname;	 
gridinfo.UpperLeft    =	 UpperLeft;	 
gridinfo.LowerRight   =	 LowerRight;	 
gridinfo.Rows         =	 Rows;	 
gridinfo.Columns      =	 Columns;	 
gridinfo.DataFields   =	 DataFields;	 
gridinfo.Attributes   =	 Attributes;	 
gridinfo.Projection   =	 Projection;	 
gridinfo.OriginCode   =  OriginCode;	 
gridinfo.PixRegCode   =	 PixRegCode;	 
gridinfo.Type         =  'HDF-EOS Grid';
return;










