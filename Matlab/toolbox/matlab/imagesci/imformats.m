function varargout = imformats(varargin)
%IMFORMATS  Manage file format registry.
%   FORMATS = IMFORMATS returns a structure containing all of the values in
%   the file format registry.  The fields in this structure are:
%
%        ext         - A cell array of file extensions for this format
%        isa         - Function to determine if a file "IS A" certain type
%        info        - Function to read information about a file
%        read        - Function to read image data a file
%        write       - Function to write MATLAB data to a file
%        alpha       - 1 if the format has an alpha channel, 0 otherwise
%        description - A text description of the file format
% 
%   The values for the isa, info, read, and write fields must be functions
%   which are on the MATLAB search path or function handles.
%
%   FORMATS = IMFORMATS(FMT) searches the known formats for a format with
%   extension given in the string "FMT."  If found, a structure is returned
%   containing the characteristics and function names.  Otherwise an empty
%   structure is returned.
% 
%   FORMATS = IMFORMATS(FORMAT_STRUCT) sets the format registry to contain
%   the values in the "FORMAT_STRUCT" structure.  The output structure
%   FORMATS contains the new registry settings.  See the "Warning" statement
%   below.
% 
%   FORMATS = IMFORMATS('add', FORMAT_STRUCT) adds the values in the
%   "FORMAT_STRUCT" structure to the format registry.
%
%   FORMATS = IMFORMATS('factory') resets the file format registry to the
%   default format registry values.  This removes any user-specified
%   settings.
%
%   FORMATS = IMFORMATS('remove', FMT) removes the format with extension
%   FMT from the format registry.
%
%   FORMATS = IMFORMATS('update', FMT, FORMAT_STRUCT) change the format
%   registry values for the format with extension FMT to have the values
%   stored in FORMAT_STRUCT.
% 
%   IMFORMATS without any input or output arguments prettyprints a table of
%   file format information for the supported formats.
%
%   Warning:
%
%     Using IMFORMATS to change the format registry is an advanced feature.
%     Incorrect usage may prevent loading of image files.  Use IMFORMATS
%     with the 'factory' setting to return the format registry to a workable
%     state. 
%   
%   Note:
%
%     Changes to the format registry do not persist between MATLAB sessions.
%     To have a format always available when you start MATLAB, add the
%     appropriate IMFORMATS commands to the startup.m file in
%     $MATLAB/toolbox/local. 
%
%   See also IMREAD, IMWRITE, IMFINFO, FILEFORMATS, PATH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:59 $

% Verify correct number of arguments
error(nargchk(0, 3, nargin, 'struct'));
error(nargoutchk(0, 1, nargout, 'struct'));

% Declare format structure as persistent variable
persistent fmts;

% If format structure is empty (first time)
if (isempty(fmts))
  
    % Build default format structure
    fmts = build_registry;
    mlock
    
end

% Determine what to do based on number of input arguments
switch(nargin)
case 0
    % 0 inputs: Informational only
    
    if (nargout == 0)

        % Pretty-print the registry
        pretty_print_registry(fmts)
        
    else
      
        % Return the registry as a struct
        varargout{1} = fmts;
        
    end
    
case 1
    % 1 input: Look for specific format or modify registry
    
    if (isstruct(varargin{1}))
      
        % Change the registry to contain the structure
        fmts = update_registry(varargin{1});
        varargout{1} = fmts;
        
    elseif (isequal(lower(varargin{1}), 'factory'))
      
        % Reset the registry to the default values
        fmts = build_registry;
        varargout{1} = fmts;

    elseif (ischar(varargin{1}))
      
        % Look for a particular format in the registry
        varargout{1} = find_in_registry(fmts, varargin{1});
        
    else
      
        % Error out, wrong input argument type
        error('MATLAB:imformats:badInputType', ...
              'Input must be a structure or string.')
        
    end

otherwise
    % n inputs: Modify the registry using a command.

    command = varargin{1};
    
    switch (lower(command))
    case 'add'
        fmts = add_entry(fmts, varargin{2:end});
    case 'update'
        fmts = update_entry(fmts, varargin{2:end});
    case 'remove'
        fmts = remove_entry(fmts, varargin{2:end});
    otherwise
        error('MATLAB:imformats:unsupportedKeyword', ...
              'Unsupported keyword %s.', command)
    end
end

% Protect current file's persistent variables from CLEAR
mlock;


%%%
%%% Function build_registry
%%%
function fmts = build_registry
%BUILD_REGISTRY  Create the file format registry with default values

% Assemble the registry from hard-coded values
fmts(1).ext = {'bmp'};
fmts(1).isa = @isbmp;
fmts(1).info = @imbmpinfo;
fmts(1).read = @readbmp;
fmts(1).write = @writebmp;
fmts(1).alpha = 0;
fmts(1).description = 'Windows Bitmap (BMP)';

fmts(end + 1).ext = {'cur'};
fmts(end).isa = @iscur;
fmts(end).info = @imcurinfo;
fmts(end).read = @readcur;
fmts(end).write = '';
fmts(end).alpha = 1;
fmts(end).description = 'Windows Cursor resources (CUR)';

fmts(end + 1).ext = {'fts', 'fits'};
fmts(end).isa = @isfits;
fmts(end).info = @imfitsinfo;
fmts(end).read = @readfits;
fmts(end).write = '';
fmts(end).alpha = 0;
fmts(end).description = 'Flexible Image Transport System (FITS)';

fmts(end + 1).ext = {'gif'};
fmts(end).isa = @isgif;
fmts(end).info = @imgifinfo;
fmts(end).read = @readgif;
fmts(end).write = '';
fmts(end).alpha = 0;
fmts(end).description = 'Graphics Interchange Format (GIF)';

fmts(end + 1).ext = {'hdf'};
fmts(end).isa = @ishdf;
fmts(end).info = @imhdfinfo;
fmts(end).read = @readhdf;
fmts(end).write = @writehdf;
fmts(end).alpha = 0;
fmts(end).description = 'Hierarchical Data Format (HDF)';

fmts(end + 1).ext = {'ico'};
fmts(end).isa = @isico;
fmts(end).info = @imicoinfo;
fmts(end).read = @readico;
fmts(end).write = '';
fmts(end).alpha = 1;
fmts(end).description = 'Windows Icon resources (ICO)';

fmts(end + 1).ext = {'jpg', 'jpeg'};
fmts(end).isa = @isjpg;
fmts(end).info = @imjpginfo;
fmts(end).read = @readjpg;
fmts(end).write = @writejpg;
fmts(end).alpha = 0;
fmts(end).description = 'Joint Photographic Experts Group (JPEG)';

fmts(end + 1).ext = {'pbm'};
fmts(end).isa = @ispbm;
fmts(end).info = @impnminfo;
fmts(end).read = @readpnm;
fmts(end).write = @writepnm;
fmts(end).alpha = 0;
fmts(end).description = 'Portable Bitmap (PBM)';

fmts(end + 1).ext = {'pcx'};
fmts(end).isa = @ispcx;
fmts(end).info = @impcxinfo;
fmts(end).read = @readpcx;
fmts(end).write = @writepcx;
fmts(end).alpha = 0;
fmts(end).description = 'Windows Paintbrush (PCX)';

fmts(end + 1).ext = {'pgm'};
fmts(end).isa = @ispgm;
fmts(end).info = @impnminfo;
fmts(end).read = @readpnm;
fmts(end).write = @writepnm;
fmts(end).alpha = 0;
fmts(end).description = 'Portable Graymap (PGM)';

fmts(end + 1).ext = {'png'};
fmts(end).isa = @ispng;
fmts(end).info = @impnginfo;
fmts(end).read = @readpng;
fmts(end).write = @writepng;
fmts(end).alpha = 1;
fmts(end).description = 'Portable Network Graphics (PNG)';

fmts(end + 1).ext = {'pnm'};
fmts(end).isa = @ispnm;
fmts(end).info = @impnminfo;
fmts(end).read = @readpnm;
fmts(end).write = @writepnm;
fmts(end).alpha = 0;
fmts(end).description = 'Portable Any Map (PNM)';

fmts(end + 1).ext = {'ppm'};
fmts(end).isa = @isppm;
fmts(end).info = @impnminfo;
fmts(end).read = @readpnm;
fmts(end).write = @writepnm;
fmts(end).alpha = 0;
fmts(end).description = 'Portable Pixmap (PPM)';

fmts(end + 1).ext = {'ras'};
fmts(end).isa = @isras;
fmts(end).info = @imrasinfo;
fmts(end).read = @readras;
fmts(end).write = @writeras;
fmts(end).alpha = 1;
fmts(end).description = 'Sun Raster (RAS)';

fmts(end + 1).ext = {'tif', 'tiff'};
fmts(end).isa = @istif;
fmts(end).info = @imtifinfo;
fmts(end).read = @readtif;
fmts(end).write = @writetif;
fmts(end).alpha = 0;
fmts(end).description = 'Tagged Image File Format (TIFF)';

fmts(end + 1).ext = {'xwd'};
fmts(end).isa = @isxwd;
fmts(end).info = @imxwdinfo;
fmts(end).read = @readxwd;
fmts(end).write = @writexwd;
fmts(end).alpha = 0;
fmts(end).description = 'X Window Dump (XWD)';


%%%
%%% Function pretty_print_registry
%%%
function pretty_print_registry(fmts)
%PRETTY_PRINT_REGISTRY  Display a table showing the values in the registry

% Initialize variables to hold maximum sizes encountered.  The initial values
% are the minimum values needed for alignment with the header.
s.ext = 3;
s.isa = 3;
s.info = 4;
s.read = 4;
s.write = 5;
s.description = 11;

% Find the maximum lengths of each column
for p = 1:length(fmts)
    % Special case for multiple format extensions
    len = length([fmts(p).ext{:}]) + length(fmts(p).ext) - 1;
    s.ext = max(len, s.ext);
    
    % Remainder are single valued only
    s.isa = max(length(whoami(fmts(p).isa)), s.isa);
    s.info = max(length(whoami(fmts(p).info)), s.info);
    s.read = max(length(whoami(fmts(p).read)), s.read);
    s.write = max(length(whoami(fmts(p).write)), s.write);
    s.description = max(length(fmts(p).description), s.description);
end

% Assemble header for the table
hdr = ['EXT'   repmat(' ', 1, (s.ext - 3 + 2)), ...
       'ISA'   repmat(' ', 1, (s.isa - 3 + 2)), ...
       'INFO'  repmat(' ', 1, (s.info - 4 + 2)), ...
       'READ'  repmat(' ', 1, (s.read - 4 + 2)), ...
       'WRITE' repmat(' ', 1, (s.write - 5 + 2)), ...
       'ALPHA  ', ...
       'DESCRIPTION' repmat(' ', 1, max(0, (s.description - 11)))];

table{1} = hdr;
table{2} = repmat('-', 1, length(hdr));

% Add each format to the table line-by-line
for p = 1:length(fmts)
  
    % Extensions.
    exts = '';
    
    for q = 1:length(fmts(p).ext)
        exts = cat(2, exts, fmts(p).ext{q});
        exts = cat(2, exts, ' ');
    end
    
    exts(end) = '';
    
    table{p + 2} = sprintf('%s%s%s%s%s%s%s%s%s%s%d      %s', ...
             exts, ...
             repmat(' ', 1, (s.ext - length(exts) + 2)), ...
             whoami(fmts(p).isa), ...
             repmat(' ', 1, (s.isa - length(whoami(fmts(p).isa)) + 2)), ...
             whoami(fmts(p).info), ...
             repmat(' ', 1, (s.info - length(whoami(fmts(p).info)) + 2)), ...
             whoami(fmts(p).read), ...
             repmat(' ', 1, (s.read - length(whoami(fmts(p).read)) + 2)), ...
             whoami(fmts(p).write), ...
             repmat(' ', 1, (s.write - length(whoami(fmts(p).write)) + 2)), ...
             fmts(p).alpha, ...
             fmts(p).description);
    
end

% Print the table
disp(' ')
disp(sprintf('%s\n', table{:}));


%%%
%%% Function update_registry
%%%
function out = update_registry(in)
%UPDATE_REGISTRY  Change the format registry to the input value

out = in;

% Verify all required fields are in the input structure
if (~isfield(out, 'ext'))
    error('MATLAB:imformats:extFieldRequired', ...
          'Format structure must contain a field named ''ext''.')
end

if (~isfield(out, 'isa'))
    out(1).isa = '';
end

if (~isfield(out, 'info'))
    out(1).info = '';
end

if (~isfield(out, 'read'))
    out(1).read = '';
end

if (~isfield(out, 'write'))
    out(1).write = '';
end

if (~isfield(out, 'alpha'))
    out(1).alpha = [];
end

if (~isfield(out, 'description'))
    out(1).description = '';
end

% Verify individual fields
for p = 1:length(out)
    s = out(p);
    
    % Check that extensions are nonempty cell arrays of 1-D char arrays
    if (isempty(s.ext))
        error('MATLAB:imformats:extValueRequired', ...
              'All formats must specify at least one extension.')
    end
    
    % Convert extensions to lowercase and to cell array if necessary
    if (~iscell(s.ext))
        if (ischar(s.ext) && (size(s.ext, 1) == 1))
            out(p).ext = {lower(s.ext)};
        else
            error('MATLAB:imformats:extNotCell', ...
                  'Format extensions must be a cell array of 1-D character arrays.')
        end
    else
        % Check each element of a cell array passed in
        for q = 1:length(s.ext)
            if (~ischar(s.ext{q}) || (size(s.ext{q}, 1) ~= 1))
                error('MATLAB:imformats:extNotCell', ...
                      'Format extensions must be a cell array of 1-D character arrays.')
            end
            
            out(p).ext{q} = lower(s.ext{q});
        end
    end
    
    % Ensure all empty fields are char arrays, except alpha.
    if (isempty(s.isa))
        out(p).isa = '';
    end
    
    if (isempty(s.info))
        out(p).info = '';
    end
    
    if (isempty(s.read))
        out(p).read = '';
    end
    
    if (isempty(s.write))
        out(p).write = '';
    end
    
    if (isempty(s.description))
        out(p).description = '';
    end
    
    if (isempty(s.alpha))
        out(p).alpha = 0;
    end
    
   % Function fields (ISA, INFO, READ, WRITE) must be 1-D char arrays,
   % function handles, or empty.
    tf = [((ischar(s.isa)) || (isa(s.isa, 'function_handle')) || (isempty(s.isa))) ...
          ((ischar(s.info)) || (isa(s.info, 'function_handle')) || (isempty(s.info))) ...
          ((ischar(s.read)) || (isa(s.read, 'function_handle')) || (isempty(s.read))) ...
          ((ischar(s.write)) || (isa(s.write, 'function_handle')) || (isempty(s.write))) ...
          (size(s.isa, 2) == numel(s.isa)) ...
          (size(s.info, 2) == numel(s.info)) ...
          (size(s.read, 2) == numel(s.read)) ...
          (size(s.write, 2) == numel(s.write))];
    
    if (~all(tf))
        msg = sprintf('Format %s references a function which is not a 1-D string, function handle, or empty.', out(p).ext{1});
        error('MATLAB:imformats:badFunctionName', '%s', msg)
    end
    
    if (~(ischar(s.description)) && ~(isempty(s.description)))
        error('MATLAB:imformats:badDescription', ...
              'Description in format %s is not a string or empty.', ...
              out(p).ext{1})
    end
end

% Verify the alpha channel data is a scalar integer in [0,1]
try
    alphas = [out(:).alpha];
catch
    error('MATLAB:imformats:alphaScalarInt', ...
          'Alpha channel values must be scalar integers.')
end

if ((~isnumeric(alphas)) || ...
    (~all((alphas == 0) | (alphas == 1))) || ...
    (~(length(alphas) == length(out))))
  
    error('MATLAB:imformats:alphaValue', ...
          'All alpha channel values must be scalar values of 0 or 1.')
    
end


%%%
%%% Function find_in_registry
%%%
function [out, match] = find_in_registry(in, key)
%FIND_IN_REGISTRY  Find a particular format given

% Verify that key is a single, 1-D character array
if ((~ischar(key)) || (isempty(key)) || (size(key, 2) ~= numel(key)))
    error('MATLAB:imformats:formatNotCharVector', ...
          'Format specifier must be a 1-D character array.')
end

% Convert key to lowercase
key = lower(key);

% Look for the input format in the formats registry
match = false(1,length(in));
for p = 1:length(in)
    match(p) = any(strcmp(key, in(p).ext));
end

% Check whether the format was found
switch (sum(match))
case 0
    % Not found.
    out = struct([]);
case 1
    % One match found.
    out = in(match);
otherwise
    % Too many found.
    error('MATLAB:imformats:tooManyFormats', ...
          'Too many formats found for extension "%s".', key)
end


%%%
%%% Function whoami
%%%
function out = whoami(in)
%WHOAMI  Take a function handle or string and return the name as a string.

if (ischar(in))
    out = in;
elseif (isa(in, 'function_handle'))
    out = func2str(in);
else
    error('MATLAB:imformats:badFunctionName', ...
          'Input must be a function handle or character array.')
end



%%%
%%% Function add_entry
%%%
function fmts = add_entry(fmts, format_values)
%ADD_ENTRY  Add a format to the formats registry.

if (~isstruct(format_values))
    error('MATLAB:imformats:attributesNotStruct', ...
          'Format attributes must be stored in a structure.')
end

% Verify new format, but don't actually add it to the registry yet.
format_values = update_registry(format_values);

% Add to the registry.
fmts(end + 1) = format_values;



%%%
%%% Function update_entry
%%%
function fmts = update_entry(fmts, ext, new_values)
%UPDATE_ENTRY  Update a particular format in the registry.

if (~ischar(ext))
    error('MATLAB:imformats:extNotString', ...
          'Format extension must be a string.')
elseif (~isstruct(new_values))
    error('MATLAB:imformats:attributesNotStruct', ...
          'Format attributes must be stored in a structure.')
end

[old_values, indices] = find_in_registry(fmts, ext);

if (isempty(old_values))
    
    % If the format doesn't exist in the registry, just add it.
    fmts = add_entry(fmts, new_values);
    
else
    
    % Verify the new format and replace the old format.
    new_values = update_registry(new_values);
    fmts(find(indices)) = new_values;
    
end



%%%
%%% Function remove_entry
%%%
function fmts = remove_entry(fmts, ext)
%REMOVE_ENTRY  Remove a format from the registry.

if (~ischar(ext))
    error('MATLAB:imformats:extNotString', ...
          'Format extension must be a string.')
end

% Find format's location in the registry and remove it.
[old_values, indices] = find_in_registry(fmts, ext);

if (isempty(old_values))
    
    error('MATLAB:imformats:formatNotFound', ...
          'Format ''%s'' not found in registry.', ext)
    
else
    
    fmts(find(indices)) = [];
    
end
