function info = hdf5info(filename, varargin)
%HDF5INFO Get information about an HDF5 file.
%   
%   FILEINFO = HDF5INFO(FILENAME) returns a structure whose fields contain
%   information about the contents of an HDF5 file.  FILENAME is a
%   string that specifies the name of the HDF file. 
% 
%   FILEINFO = HDF5INFO(..., 'ReadAttributes', BOOL) allows the user to
%   specify whether or not to read in the values of the attributes in
%   the HDF5 file.  The default value for BOOL is true.
%
%   See also HDF5READ, HDF5WRITE, HDF5COPYRIGHT.TXT.

%   binky
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:06 $

%
% Process arguments.
%

if (nargin < 1)
    error('MATLAB:hdf5info:notEnoughInputs', ...
          'HDF5INFO requires at least one input argument.')
end

if (nargout > 4)
    error('MATLAB:hdf5info:tooManyOutputs', ...
          'HDF5INFO requires four or fewer output arguments.')
end

[read_attribute_values, msg] = parse_inputs(varargin{:});
if (~isempty(msg))
    error('MATLAB:hdf5info:inputParsing', '%s', msg);
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
    error('MATLAB:hdf5info:fileOpen', 'Couldn''t open file (%s).', filename)
else
    filename = fopen(fid);
    fclose(fid);
end

% Get file info and mode in which the file was opened.

d = dir(filename);

% Set the positions of the fields.
info.Filename = d.name;
info.LibVersion = '';
info.Offset = [];
info.FileSize = d.bytes;
info.GroupHierarchy = struct([]);

% Get the version of the library that wrote out the file, the offset, 
% and the group hierarchy!
[info.Offset, info.GroupHierarchy, majnum, minnum, relnum] = hdf5infoc(filename, read_attribute_values);

info.LibVersion = [num2str(majnum) '.' num2str(minnum) '.' num2str(relnum)];

% parse_inputs : get the name of the file and whether or not to read
% attribute values

function [read_attribute_values, msg] = ...
        parse_inputs(varargin)

read_attribute_values = true;
msg = '';

% Parse arguments based on their number.
if (nargin > 0)
    
    paramStrings = {'readattributes'};
    
    % For each pair
    for k = 1:2:length(varargin)
        param = lower(varargin{k});
            
        if (~ischar(param))
            msg = 'Parameter name must be a string.';
            return
        end
        
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
           read_attribute_values = varargin{k+1};
           if ~islogical(read_attribute_values)
               msg = sprintf('''ReadAttributes'' must be a logical type.');
           end
        end
    end
end


