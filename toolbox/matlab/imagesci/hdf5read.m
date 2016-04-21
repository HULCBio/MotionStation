function [data, attributes] = hdf5read(varargin)
%HDF5READ Reads data from HDF5 files.
%
%   HDF5READ reads data from a data set in an HDF5 file.  If the
%   name of the data set is known, then HDF5READ will search the file
%   for the data.  Otherwise, use HDF5INFO to obtain a structure
%   describing the contents of the file. The fields of the structure
%   returned by HDF5INFO are structures describing the data sets 
%   contained in the file.  A structure describing a data set may be
%   extracted and passed directly to HDF5READ.  These options are 
%   described in detail below.
%
%   DATA = HDF5READ(FILENAME,DATASETNAME) returns in the variable DATA
%   all data from the file FILENAME for the data set named DATASETNAME.  
%   
%   ATTR = HDF5READ(FILENAME,ATTRIBUTENAME) returns in the variable ATTR
%   all data from the file FILENAME for the attribute named ATTRIBUTENAME.  
%
%   [DATA, ATTR] = HDF5READ(..., 'ReadAttributes', BOOL) returns the
%   data information for the data set as well as the associated attribute
%   information contained within that data set.  By default, BOOL is
%   false.
%
%   DATA = HDF5READ(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDFINFO (see example).
%   
%   Example:
%
%     % Read a dataset based on an HDF5INFO structure.
%     info = hdf5info('example.h5');
%     dset = hdf5read(info.GroupHierarchy.Groups(2).Datasets(1));
%
%   See also HDF5INFO, HDF5WRITE, HDF5COPYRIGHT.TXT.

%   binky
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:07 $

%
% Process arguments.
%

if (nargin < 1)
    error('MATLAB:hdf5read:notEnoughInputs', ...
          'HDF5READ requires at least one input argument.')
end

if (nargout > 8)
    error('MATLAB:hdf5read:tooManyOutputs', ...
          'HDF5READ requires eight or fewer output arguments.')
end

[readAttributes, datasetName, filename, msg] = parse_inputs(varargin{:});
if (~isempty(msg))
    error('MATLAB:hdf5read:inputParsing', '%s', msg);
end

%
% Verify existence of filename.
%

% Get full filename.
fid = fopen(filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([filename '.h5']);
    
    if (fid == -1)
        fid = fopen([filename '.h5']);
    end
    
end

if (fid == -1)
    error('MATLAB:hdf5read:fileOpen', 'Couldn''t open file (%s).', filename)
else
    filename = fopen(fid);
    fclose(fid);
end

% Read the data
[data, attributes] = hdf5readc(filename, datasetName, readAttributes);

% parse_inputs : get the name of the file, the dataset name, and
% whether or not to read attribute value 

function [readAttributes, datasetName, filename, msg] = ...
        parse_inputs(varargin)

readAttributes = false;
datasetName = '';
filename = '';
msg = [];

if ischar(varargin{1})
    filename = varargin{1};

    if (nargin > 1)
        if ischar(varargin{2})
            datasetName = varargin{2};
        else
            msg = 'Dataset or attribute name must be a char array';
            return;
        end
        varargin = {varargin{3:end}};
    else
        msg = 'Dataset or attribute name not supplied with filename';
        return;
    end
elseif isa(varargin{1}, 'struct')
    try
        hinfo = varargin{1};
        filename = hinfo.Filename;
        datasetName = hinfo.Name;
        varargin = {varargin{2:end}};
    catch
        msg = ['Input is not a scalar part of the info struct ' ...
               'returned by HDF5INFO'];
        return
    end
else
    msg = ['First input argument to HDF5READ must be a filename ' ...
           'or part of a valid info struct'];
    return
end

% Parse arguments based on their number.
if (nargin > 1)
    
    paramStrings = {'readattributes', ...
                    };
    
    % For each pair
    for k = 1:2:length(varargin)
        param = varargin{k};
        if (~ischar(varargin{k}))
            msg = 'Parameter name must be a string.';
            return
        end
        param = lower(param);
        
        idx = strmatch(param, paramStrings);
        
        if (isempty(idx))
            msg = sprintf('Unrecognized parameter name "%s".', param);
            return
        elseif (length(idx) > 1)
            msg = sprintf('Ambiguous parameter name "%s".', param);
            return
        end
        
        switch (paramStrings{idx})
        case 'readattributes'
           readAttributes = varargin{k+1};
           if ~islogical(readAttributes)
               msg = sprintf(['''ReadAttributes'' must be a logical ' ...
                              'type.']);
               return
           end
        end
    end
end


