function [sdinfo, IsScale] = hdfsdsinfo(filename, sdID, anID, dataset)
%HDFSDSINFO Information about HDF Scientific Data Set. 
%
%   [SDINFO, IsScale]=SDSINFO(FILENAME,DATASET) returns a structure SDINFO whose
%   fields contain information about an HDF Scientific Data
%   Set(SDS). IsScale is a true (1) if the SDS is a dimension scale, false
%   (0) otherwise. FILENAME is a string that specifies the name of the HDF
%   file.  SDID is the sds identifier returned by hdfsd('start',... ANID is
%   the annotation identifier returned by hdfan('start',... DATASET is a
%   string specifying the name of the SDS or a number specifying the zero
%   based index of the data set. If DATASET is the name of the data set and
%   multiple data sets with that name exist in the file, the first dataset
%   is used.
%
%   Assumptions: 
%               1.  The file has been open.
%               2.  The SD and AN interfaces have been started.  
%               3.  anID may be -1
%               3.  The SD and AN interfaces and file will be closed elsewhere.
%
%   The fields of SDINFO are:
%
%   Filename          A string containing the name of the file
%		   
%   Type              A string describing the type of HDF object 
%
%   Name              A string containing the name of the data set
%		   
%   Rank              A number specifying the number of dimensions of the
%                     data set
%		   
%   DataType          A string specifying the precision of the data
%
%   Attributes        An array of structures with fields 'Name' and 'Value'
%                     describing the name and value of the attributes of the
%                     data set
%              
%      Dims           An array of structures with fields 'Name', 'DataType',
%                     'Size', 'Scale', and 'Attributes'.  Describing the the
%                     dimensions of the data set.  'Scale' is an array of numbers
%                     to place along the dimension and demarcate intervals in
%                     the data set.
%
%   Label             A cell array containing an Annotation label
%
%   Description       A cell array containing an Annotation descriptoin
%		   
%   Index             Number indicating the index of the SDS

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:15 $

sdinfo = struct('Filename',[],'Type',[],'Name',[],'Rank',[],'DataType',[],'Attributes',[],'Dims',[],'Label',[],'Description',[],'Index',[]);

error(nargchk(4, 4, nargin, 'struct'));

if ~ischar(filename)
  error('MATLAB:hdfsdsinfo:badFilename', ...
        'FILENAME must be a string.');
end

msg ='Problem connecting to Scientific Data set. File may be corrupt or data set may not exist.';
%User may input name or index to the SDS
if isnumeric(dataset)
  index = dataset;
elseif ischar(dataset)
  index = hdfsd('nametoindex',sdID,dataset);
  if index == -1
    warning('MATLAB:hdfsdsinfo:nametoindex', '%s', msg);
    return;
  end
else
  error('MATLAB:hdfsdsinfo:badDatasetType', ...
        'DATASET must be a number or a string.');
end

sdsID = hdfsd('select',sdID,index);
if sdsID == -1
  warning('MATLAB:hdfsdsinfo:select', '%s', msg);
  return;
end

%Convert index to reference number 
ref = hdfsd('idtoref',sdsID);
hdfwarn(ref)

%Get lots of info
[sdsName, rank, dimSizes, sddataType, nattrs, status] = hdfsd('getinfo',sdsID);
hdfwarn(status)

%Get SD attribute information. The index for readattr is zero based.
if nattrs>0
  arrayAttribute = repmat(struct('Name', '', 'Value', []), [1 nattrs]);
  for i = 1:nattrs
    [arrayAttribute(i).Name,attrDataType,count,status] = hdfsd('attrinfo',sdsID,i-1);
    hdfwarn(status)
    [arrayAttribute(i).Value, status] = hdfsd('readattr',sdsID,i-1);
    hdfwarn(status)
  end
else
  arrayAttribute = [];
end
  
IsScale = logical(hdfsd('iscoordvar',sdsID));

%If it is not a dimension scale, get dimension information
%Dimension numbers are 0 based (?)
if IsScale == 0
  
  Scale = cell(1, rank);
  dimName = cell(1, rank);
  DataType = cell(1, rank);
  Size = cell(1, rank);
  Name = cell(1, rank);
  Value = cell(1, rank);
  Attributes = cell(1, rank);
  
  for i=1:rank
    dimID = hdfsd('getdimid',sdsID,i-1);
    %Use sizes from SDgetinfo because this size may be Inf
    [dimName{i}, sizeDim,DataType{i}, nattrs, status] = hdfsd('diminfo',dimID);
    hdfwarn(status)
    if strcmp(DataType{i},'none')
      Scale{i} = 'none';
    elseif isinf(sizeDim)
      Scale{i} = 'unknown';
    else
      try
        Scale{i} = hdfsd('getdimscale',dimID);
      catch
        Scale{i} = 'none';
      end
    end
    Size{i} = dimSizes(i);
    if nattrs>0
      for j=1:nattrs
	[Name{j},dataType,count,status] = hdfsd('attrinfo',dimID,j-1);
	hdfwarn(status)
	[Value{j}, status] = hdfsd('readattr',dimID,j-1);
	hdfwarn(status)
      end
      Attributes{i} = struct('Name',Name(:),'Value',Value(:));
    else
      Attributes = [];
    end
  end
  dims = struct('Name',dimName(:),'DataType',DataType(:),'Size',Size(:),'Scale',Scale(:),'Attributes',Attributes(:));
else
  dims = [];
end

%Get any associtated annotations
tag = hdfml('tagnum','DFTAG_NDG');
if anID ~= -1
  [label,desc] = hdfannotationinfo(anID,tag,ref);
  if isempty(label) || isempty(desc)
    tag = hdfml('tagnum','DFTAG_SD');
    [label,desc] = hdfannotationinfo(anID,tag,ref);
  end
end

%Close interfaces
status = hdfsd('endaccess',sdsID);
hdfwarn(status)

%Populate output structure
sdinfo.Filename = filename;
sdinfo.Name = sdsName;
sdinfo.Index = index;
sdinfo.Rank = rank;
sdinfo.DataType = sddataType;
if ~isempty(arrayAttribute)
  sdinfo.Attributes = arrayAttribute;
end
if ~isempty(dims)
  sdinfo.Dims = dims;
end
sdinfo.Label = label;
sdinfo.Description = desc;
%sdinfo.IsScale = IsScale;
sdinfo.Type = 'Scientific Data Set';
