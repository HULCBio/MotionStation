function [status,numReturnVars,warnStr] = hdfguiread(varargin)
%HDFGUIREAD Helper function for HDFTOOL to read data from an HDF/HDF-EOS
% file. This function should not be used in other M-code (scripts,
% functions, or command line).  Use HDFINFO and HDFREAD instead.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:59:56 $


import com.mathworks.toolbox.matlab.iofun.*;

map     = [];
data    = [];
status  = java.lang.Double(ImportPane.IMPORT_SUCCESS);
warnStr = '';
numReturnVars = java.lang.Double(1);

warnState = warning('off');
lastwarn('');

returninfo  = varargin{1};
datatype    = varargin{2};
filename    = varargin{3};
datasetname = varargin{4};
varname     = varargin{5};

%Check for valid variable name
s = isvarname(varname);
if s == 0
  status = java.lang.Double(ImportPane.INVALID_VARIABLE_NAME);
  return;
end

%Check if variable already exists
s = evalin('base',['exist(''' varname ''',''var'')']);
if s
  if Importer.getInstance.getShowModalDialogs
    selection = questdlg(sprintf('Variable %s already exists. Overwrite?',varname),...
                         'Warning!','Yes','No','Yes');
  else
    selection = 'yes';
  end
  switch lower(selection)
   case 'yes'
   case {'no','cancel'}
    status = java.lang.Double(ImportPane.VARIABLE_EXISTS);
    return;
  end
end

try
  switch datatype
   case HDFNodeTypeConstants.SDS_TYPE
    start  = [varargin{6}(:)];
    stride = [varargin{7}(:)];
    edge   = [varargin{8}(:)];
    data = hdfread(filename,...
		   datasetname,...
		   'Index',{start,stride,edge});
   case HDFNodeTypeConstants.VDATA_TYPE
    fields      = varargin{6};
    firstRecord = varargin{7};
    numRecords  = varargin{8};  
    data = hdfread(filename,datasetname,...
		   'Fields',fields,...
		   'FirstRecord',firstRecord,...
		   'NumRecords',numRecords);
   case HDFNodeTypeConstants.RASTER8_TYPE
    mapname = varargin{6};
    s = isvarname(mapname);
    if s == 0
      status = java.lang.Double(ImportPane.INVALID_VARIABLE_NAME);
      return;
    end
    [data,map] = hdfread(filename,datasetname);
   case HDFNodeTypeConstants.RASTER24_TYPE
    data = hdfread(filename,datasetname);
   case HDFNodeTypeConstants.POINT_LEVEL_TYPE
    level = varargin{6};
    fields = varargin{7};
    data = hdfread(filename,datasetname,...
		   'Level',level,...
		   'Fields',fields,...
		   varargin{8:end});
   case HDFNodeTypeConstants.GRID_FIELD_TYPE
    fields = varargin{6};
    data = hdfread(filename,...
		   datasetname,...
		   'Fields',fields,...
		   varargin{7:end});
   case HDFNodeTypeConstants.SWATH_FIELD_TYPE
    fields = varargin{6};
    data = hdfread(filename,...
		   datasetname,...
		   'Fields',...
		   fields,...
		   varargin{7:end});
  end
  assignin('base',varname,data);
  if ~isempty(map)
    assignin('base',mapname,map);
  end
catch
  status = java.lang.Double(ImportPane.INTERNAL_ERROR);
end

if returninfo
  hinfo = hdfquickinfo(filename,datasetname);
  assignin('base',[varname, '_info'],hinfo);
  numReturnVars = java.lang.Double(2);
end

%Check for warnings
warnStr = lastwarn;
if ~isempty(warnStr)
  status  = java.lang.Double(ImportPane.WARNING);
end
warning(warnState);
