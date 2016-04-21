function fileinfo = hdfinfo(varargin)
%HDFINFO Information about HDF 4 or HDF-EOS 2 file
%
%   FILEINFO = HDFINFO(FILENAME) returns a structure whose fields contain
%   information about the contents an HDF or HDF-EOS file.  FILENAME is a
%   string that specifies the name of the HDF file. HDF-EOS files are
%   described as HDF files.
%
%   FILEINFO = HDFINFO(FILENAME,MODE) reads the file as an HDF file if MODE
%   is 'hdf', or as an HDF-EOS file if MODE is 'eos'.  If MODE is 'eos',
%   only HDF-EOS data objects are queried.  To retrieve information on the
%   entire contents of a hybrid HDF-EOS file, MODE must be 'hdf' (default).
%   
%   The set of fields in FILEINFO depends on the individual file.  Fields
%   that may be present in the FILEINFO structure are:
%
%   HDF objects:
%   
%   Filename   A string containing the name of the file
%   
%   Vgroup     An array of structures describing the Vgroups
%   
%   SDS        An array of structures describing the Scientific Data Sets
%   
%   Vdata      An array of structures describing the Vdata sets
%   
%   Raster8    An array of structures describing the 8-bit Raster Images
%   
%   Raster24   An array of structures describing the 24-bit Raster Images
%   
%   HDF-EOS objects:
%
%   Point      An array of structures describing HDF-EOS Point data
%   
%   Grid       An array of structures describing HDF-EOS Grid data
%   
%   Swath      An array of structures describing HDF-EOS Swath data
%   
%   The data set structures above share some common fields.  They are (note,
%   not all structures will have all these fields):
%   
%   Filename          A string containing the name of the file
%                     
%   Type              A string describing the type of HDF object 
%   	              
%   Name              A string containing the name of the data set
%                     
%   Attributes        An array of structures with fields 'Name' and 'Value'
%                     describing the name and value of the attributes of the
%                     data set
%                     
%   Rank              A number specifying the number of dimensions of the
%                     data set
%
%   Ref               The reference number of the data set
%
%   Label             A cell array containing an Annotation label
%
%   Description       A cell array containing an Annotation description
%
%   Fields specific to each structure are:
%   
%   Vgroup:
%   
%      Class      A string containing the class name of the data set
%
%      Vgroup     An array of structures describing Vgroups
%                 
%      SDS        An array of structures describing Scientific Data sets
%                 
%      Vdata      An array of structures describing Vdata sets
%                 
%      Raster24   An array of structures describing 24-bit raster images  
%                 
%      Raster8    An array of structures describing 8-bit raster images
%                 
%      Tag        The tag of this Vgroup
%                 
%   SDS:
%              
%      Dims       An array of structures with fields 'Name', 'DataType',
%                 'Size', 'Scale', and 'Attributes'.  Describing the
%                 dimensions of the data set.  'Scale' is an array of numbers
%                 to place along the dimension and demarcate intervals in
%                 the data set.
%              
%      DataType   A string specifying the precision of the data
%              
%
%      Index      Number indicating the index of the SDS
%   
%   Vdata:
%   
%      DataAttributes    An array of structures with fields 'Name' and 'Value'
%                        describing the name and value of the attributes of the
%                        entire data set
%   
%      Class             A string containing the class name of the data set
%		      
%      Fields            An array of structures with fields 'Name' and
%                        'Attributes' describing the fields of the Vdata
%                        
%      NumRecords        A number specifying the number of records of the data
%                        set   
%                        
%      IsAttribute       1 if the Vdata is an attribute, 0 otherwise
%      
%   Raster8 and Raster24:
%
%      Name           A string containing the name of the image
%   
%      Width          An integer indicating the width of the image
%                     in pixels
%      
%      Height         An integer indicating the height of the image
%                     in pixels
%      
%      HasPalette     1 if the image has an associated palette, 0 otherwise
%                     (8-bit only)
%      
%      Interlace      A string describing the interlace mode of the image
%                     (24-bit only)
%
%   Point:
%
%      Level          A structure with fields 'Name', 'NumRecords',
%                     'FieldNames', 'DataType' and 'Index'.  This structure
%                     describes each level of the Point
%      
%   Grid:
%     
%      UpperLeft      A number specifying the upper left corner location
%                     in meters
%      
%      LowerRight     A number specifying the lower right corner location
%                     in meters
%      
%      Rows           An integer specifying the number of rows in the Grid
%      
%      Columns        An integer specifying the number of columns in the Grid
%      
%      DataFields     An array of structures with fields 'Name', 'Rank', 'Dims',
%                     'NumberType', 'FillValue', and 'TileDims'. Each structure
%                     describes a data field in the Grid fields in the Grid
%      
%      Projection     A structure with fields 'ProjCode', 'ZoneCode',
%                     'SphereCode', and 'ProjParam' describing the Projection
%                     Code, Zone Code, Sphere Code and projection parameters of
%                     the Grid
%      
%      Origin Code    A number specifying the origin code for the Grid
%      
%      PixRegCode     A number specifying the pixel registration code
%      
%   Swath:
%		       
%      DataFields         An array of structures with fields 'Name', 'Rank', 'Dims',
%                         'NumberType', and 'FillValue'.  Each structure
%                         describes a Data field in the Swath 
%
%      GeolocationFields  An array of structures with fields 'Name', 'Rank', 'Dims',
%                         'NumberType', and 'FillValue'.  Each structure
%                         describes a Geolocation field in the Swath 
%   
%      MapInfo            A structure with fields 'Map', 'Offset', and
%                         'Increment' describing the relationship between the
%                         data and geolocation fields. 
%   
%      IdxMapInfo         A structure with 'Map' and 'Size' describing the
%                         relationship between the indexed elements of the
%                         geolocation mapping
%   
% 
%   Example:  
%             % Retrieve info about example.hdf
%             fileinfo = hdfinfo('example.hdf');
%             % Retrieve info about Scientific Data Set in example
%             data_set_info = fileinfo.SDS;
%	     
%   See also HDFTOOL, HDFREAD, HDF.  
  
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:55 $

[filename, mode] = parseInputs(varargin{:});

%  Open the interfaces. The private functions will expect the interfaces to be
%  open and closed by this function.   This is done for performance; opening
%  and closing these interfaces is expensive.    
if strcmp(lower(mode),'hdf')  
  fileID = hdfh('open',filename,'read',0);
  if fileID==-1
    error('MATLAB:hdfinfo:fileOpen', 'Unable to open file.');
  end
  sdID = hdfsd('start',filename,'read');
  if sdID==-1
    warning('MATLAB:hdfinfo:sdInterfaceStart', ...
            'Unable to start SD interface. Scientific Data Set information is unavailable.');
  end
  vstatus = hdfv('start',fileID);
  if vstatus==-1
    warning('MATLAB:hdfinfo:vInterfaceStart', ...
            'Unable to start V interface.  Vgroup and Vdata information is unavailable.');
  end
  anID = hdfan('start',fileID);
  if anID == -1
    warning('MATLAB:hdfinfo:anInterfaceStart', ...
            'Unable to start AN interface.  Annotation information is unavailable.');
  end
elseif strcmp(lower(mode),'eos')
  gdID = hdfgd('open',filename,'read');
  if gdID==-1
    warning('MATLAB:hdfinfo:gdInterfaceStart', ...
            'Unable to start GD interface.  Grid information is unavailable.');
  end
  swID = hdfsw('open',filename,'read');
  if swID==-1
    warning('MATLAB:hdfinfo:swInterfaceStart', ...
            'Unable to start SW interface.  Swath information is unavailable.');
  end
  ptID = hdfpt('open',filename,'read');
  if ptID==-1
    warning('MATLAB:hdfinfo:ptInterfaceStart', ...
            'Unable to start PT interface.  Point information is unavailable.');
  end
end

%Get attributes that apply to entire file
fileAttribute = '';
if ~strcmp(lower(mode),'eos') 
  if sdID ~= -1
    [ndatasets,nGlobalAttrs,status] = hdfsd('fileinfo',sdID);
    hdfwarn(status)
    if nGlobalAttrs>0
      for i=1:nGlobalAttrs
	[fileAttribute(i).Name,sdsDataType,count,status] = hdfsd('attrinfo',sdID,i-1);
	hdfwarn(status)
	[fileAttribute(i).Value, status] = hdfsd('readattr',sdID,i-1);
	hdfwarn(status)
      end
    end
  end
end

% HDF-EOS files are typically "hybrid", meaning they contain HDF-EOS and
% HDF data objects.  It is impossible to distinguish the additional HDF
% objects that may be in an HDF-EOS file from HDF-EOS object.  The only way
% to read these is to look at the entire file as an HDF file.  
if strcmp(mode,'eos')
  if gdID ~= -1
    grid = GridInfo(filename,gdID);
  end
  if swID ~= -1
    swath = SwathInfo(filename,swID);
  end
  if ptID ~= -1
    point = PointInfo(filename,ptID);
  end
else
  %Get Vgroup structures
  if vstatus ~= -1
    [Vgroup,children] = VgroupInfo(filename,fileID,sdID,anID);
  else
    Vgroup = [];
  end
  
  %Get SDS structures
  if sdID ~= -1
    Sds = SdsInfo(filename,sdID,anID,children);
    else
    Sds = [];
  end
  
  %Get Vdata structures
  if vstatus ~= -1
    vdinfo = VdataInfo(filename,fileID,anID);
  else
    vdinfo = [];
  end

  %Get 8-bit image structures
  raster8 = Raster8Info(filename,children,anID);

  %Get 24-bit image structures
  raster24 = Raster24Info(filename,children,anID);

  %Get file annotations
  if anID ~= -1
    [label, desc] = annotationInfo(anID);
  else
    label = {};
    desc = {};
  end
end

%Populate output structure
hinfo.Filename = filename;
if strcmp(mode,'eos')
  if ~isempty(point)
    hinfo.Point = point;
  end
  if ~isempty(grid)
    hinfo.Grid = grid;
  end
  if ~isempty(swath)
    hinfo.Swath = swath;
  end
else
  if ~isempty(fileAttribute)
    hinfo.Attributes = fileAttribute;
  end
  if ~isempty(Vgroup)
    hinfo.Vgroup = Vgroup;
  end
  if ~isempty(Sds)
    hinfo.SDS = Sds;
  end
  if ~isempty(vdinfo)
    hinfo.Vdata = vdinfo;
  end
  if ~isempty(raster8)
    hinfo.Raster8 = raster8;
  end
  if ~isempty(raster24)
    hinfo.Raster24 = raster24;
  end
  if ~isempty(label)
    hinfo.Label = label;
  end
  if ~isempty(desc)
    hinfo.Description = desc;
  end
end

%Close interfaces
if strcmp(mode,'hdf')
  if sdID ~= -1
    status = hdfsd('end',sdID);
    hdfwarn(status)
  end
  if vstatus ~= -1
    status = hdfv('end',fileID);
    hdfwarn(status)
  end
  if anID ~= -1
    status = hdfan('end',anID);
    hdfwarn(status)
  end
  if fileID ~= -1
    status = hdfh('close',fileID);
    hdfwarn(status)
  end
elseif strcmp(mode,'eos')  
  if gdID ~= -1
    hdfgd('close',gdID);
  end
  if swID ~= -1
    hdfsw('close',swID);
  end
  if ptID ~= -1
    hdfpt('close',ptID);
  end
end

fileinfo = hinfo;


%===============================================================
function [filename, mode] = parseInputs(varargin)

%Check input arguments
error(nargchk(1,2,nargin, 'struct'));

if ischar(varargin{1})
  filename = varargin{1};
  %Get full path of the file
  fid = fopen(filename);
  if fid~=-1
    filename = fopen(fid);  
    fclose(fid);
  else
    error('MATLAB:hdfinfo:fileNotFound', 'File not found.');
  end
else
  error('MATLAB:hdfinfo:badFilename', 'FILENAME must be a string.');
end

if nargin == 1
  mode = 'hdf';
elseif nargin == 2
  if strcmp(lower(varargin{2}),'eos');
    mode = 'eos';
  elseif strcmp(lower(varargin{2}),'hdf')
    mode = 'hdf';
  else
    error('MATLAB:hdfinfo:badMode', ...
          'Invalid value for MODE.  MODE must be either ''eos'' or ''hdf''.');
  end
end

if ~hdfh('ishdf',filename)
  error('MATLAB:hdfinfo:invalidFile', ...
        '%s is not a valid HDF file.', filename);
end


%================================================================
function [Vgroup, children] = VgroupInfo(filename,fileID,sdID,anID)
Vgroup = [];

%Find top level (lone) Vgroups
[refArray,maxsize] = hdfv('lone',fileID,0);
[refArray,maxsize] = hdfv('lone',fileID,maxsize);
hdfwarn(maxsize)

children.Tag = [];
children.Ref = [];
%Get Vgroup structures (including children)
for i=1:maxsize
  [Vgrouptemp, child] = hdfvgroupinfo(filename,refArray(i),fileID, sdID, anID);
  if ~isempty(Vgrouptemp.Filename)
    Vgroup = [Vgroup Vgrouptemp];
  end
  if ~isempty(child.Tag)
    children.Tag = [children.Tag, child.Tag];
    children.Ref = [children.Ref, child.Ref];
  end
end
return;
%================================================================
function vdinfo = VdataInfo(filename,fileID,anID)
vdinfo = [];

[refArray, maxsize] = hdfvs('lone',fileID,0);
[refArray, maxsize] = hdfvs('lone',fileID,maxsize);
hdfwarn(maxsize)
for i=1:length(refArray)
  vdtemp = hdfvdatainfo(filename,fileID,anID,refArray(i));
  %Ignore Vdata's that are attributes
  %Ignore Vdata's that are Attr0.0 class, this is consistent with the 
  %NCSA's Java HDF Viewer
  if ~vdtemp.IsAttribute && ~strcmp(vdtemp.Class,'Attr0.0')
    vdinfo = [vdinfo vdtemp];
  end
end
return;

%================================================================
function Sds = SdsInfo(filename,sdID,anID,children)
%Initialize output to empty
Sds = [];

%Get number of data sets in file. SDS index is zero based
[ndatasets,nGlobalAttrs, status] = hdfsd('fileinfo',sdID);
hdfwarn(status)
for i=1:ndatasets
  sdsID = hdfsd('select',sdID,i-1);
  if sdID == -1
    warning('MATLAB:hdfinfo:sdRetrieve', ...
            'Unable to retrieve Scientific Data Set information.');
    return;
  end
  ref = hdfsd('idtoref',sdsID);
  hdfwarn(ref)
  status = hdfsd('endaccess',sdsID);
  hdfwarn(status)
  %Don't add to hinfo structure if it is already part of a Vgroup
  %Assuming that the tag used for SDS is consistent for each file
  if ~(isused(hdfml('tagnum','DFTAG_NDG'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_SD'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_SDG'),ref,children) )
    [sds, IsScale] = hdfsdsinfo(filename,sdID,anID,i-1);
    %Ignore dimension scales
    if ~IsScale
      Sds =[Sds sds];    
    end
  end
end
return;
%================================================================
function raster8 = Raster8Info(filename,children,anID)
raster8 = [];

%Get number of 8-bit raster images
nimages = hdfdfr8('nimages',filename);

for i=1:nimages
  % It wouldn't seem like this call does anything, but it really does.
  [width, height, hasmap, status] = hdfdfr8('getdims',filename);
  ref = hdfdfr8('lastref');
  rinfotemp = hdfraster8info(filename,ref,anID);
  if ~(isused(hdfml('tagnum','DFTAG_RIG'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_RI'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_CI'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_CI8'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_RI8'),ref,children))
    raster8 = [raster8 rinfotemp];
  end
end

%Restart the DFR8 interface
status = hdfdfr8('restart');
hdfwarn(status)
return;

%================================================================
function raster24 = Raster24Info(filename,children,anID)
raster24 = [];
%Get number of 24-bit raster images
nimages = hdfdf24('nimages',filename);

for i=1:nimages
  % It wouldn't seem like this call does anything, but it really does.
  [width, height, hasmap, status] = hdfdf24('getdims',filename);
  ref = hdfdf24('lastref');
  rinfotemp = hdfraster24info(filename,ref,anID);
  if ~(isused(hdfml('tagnum','DFTAG_RIG'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_RI'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_CI'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_CI8'),ref,children) || ...
       isused(hdfml('tagnum','DFTAG_RI8'),ref,children))
       raster24 = [raster24 rinfotemp];
  end
end

%Restart the DF24 interface
status = hdfdf24('restart');
hdfwarn(status)
return;
%================================================================x
function pinfo = PointInfo(filename,fileID)
pinfo = [];

[numPoints, pointListLong] = hdfpt('inqpoint',filename);
if numPoints>0
  pointList = parselist(pointListLong);
  for i=1:numPoints
    pinfotemp = hdfpointinfo(filename,fileID,pointList{i});
    pinfo = [pinfo pinfotemp];
  end
end
return;


%================================================================x
function swinfo = SwathInfo(filename,fileID)
swinfo = [];

[numSwaths, swathListLong] = hdfsw('inqswath',filename);
if numSwaths>0
  swathList = parselist(swathListLong);
  for i=1:numSwaths
    swinfotemp = hdfswathinfo(filename,fileID,swathList{i});
    swinfo = [swinfo swinfotemp];
  end
end
return;

%================================================================x
function gdinfo = GridInfo(filename,fileID)
gdinfo = [];

[numGrids, gridListLong] = hdfgd('inqgrid',filename);
if numGrids>0
  gridList = parselist(gridListLong);
  for i=1:numGrids
    gdinfotemp = hdfgridinfo(filename,fileID,gridList{i});
    gdinfo = [gdinfo gdinfotemp];
  end
end
return;

%================================================================
function [label,desc] = annotationInfo(anID)
% Retrieves annotations for the file.  
label ={};
desc = {};

[numFileLabel,numFileDesc,numDataLabel,numDataDesc,status] = hdfan('fileinfo',anID);
hdfwarn(status)
if status==0
  if numFileLabel>0
    for i=1:numFileLabel
      FileLabelID = hdfan('select',anID,i-1,'file_label');
      hdfwarn(FileLabelID)
      if FileLabelID~=-1
	length = hdfan('annlen',FileLabelID);
	hdfwarn(length)
	[label{i},status] = hdfan('readann',FileLabelID,length);
	hdfwarn(status)
	status = hdfan('endaccess',FileLabelID);
	hdfwarn(status) 
      end
    end
  end
  if numFileDesc>0
    for i=1:numFileDesc
      FileDescID = hdfan('select',anID,i-1,'file_desc');
      hdfwarn(FileDescID)
      if FileDescID~=-1
	length = hdfan('annlen',FileDescID);
	hdfwarn(length)
	[desc{i},status] = hdfan('readann',FileDescID,length);
	hdfwarn(status)
	status = hdfan('endaccess',FileDescID);
	hdfwarn(status) 
      end
    end
  end
end
return;

%================================================================
function used = isused(tag,ref,used)
if isempty(used.Tag) && isempty(used.Ref)
  used = 0;
else
  tagIdx = find(used.Tag == tag );
  if isempty(tagIdx)
    used = 0;
  else
    refIdx = find(used.Ref == ref);
    if isempty(refIdx)
      used = 0;
    else
      used = 1;
    end
  end
end




