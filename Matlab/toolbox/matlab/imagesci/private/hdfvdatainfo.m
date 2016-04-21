function vdinfo = hdfvdatainfo(filename,fileID,anID,dataset)
%VDATAINFO Information about Vdata set
%
%   VDINFO = VDATAINFO(FILENAME,FILEID,DATASET) returns a structure whose fields
%   contain information about an HDF Vdata data set.  FILENAME is a string
%   that specifies the name of the HDF file.  FILEID is the file identifier
%   returned by using fileid = hdfh('open',filename,permission). DATASET is
%   a string specifying the name of the Vdata or a number specifying the
%   zero based reference number of the data set. If DATASET is the name of
%   the data set and multiple data sets with that name exist in the file,
%   the first dataset is used.  
%
%   Assumptions: 
%               1.  The file has been open.  FILEID is a valid file
%                   identifier.
%               2.  The V and AN interfaces have been started.
%               3.  anID may be -1
%               4.  The file, V, and AN interfaces will be closed elsewhere.
%
%   The fields of VDINFO are:
%
%   Filename          A string containing the name of the file
%		   
%   Name              A string containing the name of the data set
%		   
%   DataAttributes    An array of structures with fields 'Name' and 'Value'
%                     describing the name and value of the attributes of the
%                     entire data set
%
%   Class             A string containing the class name of the data set
%		      
%   Fields            An array of structures with fields 'Name' and
%                     'Attributes' describing the fields of the Vdata
%		      
%   NumRecords        A number specifying the number of records of the data set   
%		      
%   IsAttribute       1 if the Vdata is an attribute, 0 otherwise
%
%   Label             A cell array containing an Annotation label
%
%   Description       A cell array containing an Annotation description
%		      
%   Type              A string describing the type of HDF object 
%
%   Ref               The reference number of the Vdata set

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:19 $

vdinfo = [];

if ~ischar(filename)
  error('MATLAB:hdfvdatainfo:badFilename', ...
        'FILENAME must be a string.');
end

msg ='Problem connecting to Vdata set. Data set may not exist or file may be corrupt.';
if isnumeric(dataset)
  ref = dataset;
elseif ischar(dataset)
  ref = hdfvs('find',fileID,dataset);
  if ref == 0
    warning('MATLAB:hdfvdatainfo:find', '%s', msg)
    return;
  end
else
  error('MATLAB:hdfvdatainfo:badDatatype', ...
        'DATASET must be a number or a string.');
end

vdID = hdfvs('attach',fileID,ref,'r');
if vdID == -1
  warning('MATLAB:hdfvdatainfo:attach', '%s', msg);
  return;
end

[class, status] = hdfvs('getclass',vdID);
hdfwarn(status) 

%Get Vdata information
[records, interlace, fieldListLong, size, name, status] = hdfvs('inquire',vdID);
hdfwarn(status) 
if status==-1
  name = '';
  records = '';
  fields = '';
else
  %Parse field names
  fieldnames = parselist(fieldListLong);
  fields =  cell2struct(fieldnames,'Name',1);

  attrcount = 0;
  for i = 1:length(fieldnames)  
    nfattrs = hdfvs('fnattrs',vdID,i);
    hdfwarn(nfattrs)
    for j=1:nfattrs
      [name,dataType,count,size,status] = hdfvs('attrinfo',vdID,i,j);
      hdfwarn(status)
      [attrdata, status] = hdfvs('getattr',vdID,i,j);
      hdfwarn(status) 
      fields(i).Attributes(j).Name = name;
      fields(i).Attributes(j).Value = attrdata;
      attrcount = attrcount+1;
    end
    if nfattrs==0
      fields(i).Attributes = [];
    end
  end
end

%Get general Vdata attributes
nattrs = hdfvs('nattrs',vdID);
hdfwarn(nattrs) 
if nattrs>0
  DataAttributes = repmat(struct('Name', '', 'Value', []), [1 nattrs]);
  for i = 1:(nattrs-attrcount)
    [name,dataType,count,size,status] = hdfvs('attrinfo',vdID,'vdata',i);  
    hdfwarn(status) 
    [attrdata, status] = hdfvs('getattr',vdID,'vdata',i);
    hdfwarn(status) 
    DataAttributes(i).Name = name;
    DataAttributes(i).Value = attrdata;
  end
else
  DataAttributes = [];
end
isattr = logical(hdfvs('isattr',vdID));

%Get annotations
tag = hdfml('tagnum','DFTAG_VS');
if anID ~= -1
  [label,desc] = hdfannotationinfo(anID,tag,ref);
end

%Detach from data set
status = hdfvs('detach',vdID);
hdfwarn(status)

%Populate output structure
vdinfo.Filename = filename;
vdinfo.Name = name;
vdinfo.Class = class;
vdinfo.Fields = fields;
vdinfo.NumRecords = records;
vdinfo.IsAttribute = isattr;
vdinfo.DataAttributes = DataAttributes;
vdinfo.Label = label;
vdinfo.Description = desc;
%  vdinfo.Tag = hdfml('tagnum','DFTAG_VS');
vdinfo.Ref = ref;
vdinfo.Type = 'Vdata set';
