function info = cdfinfo(filename)
%CDFINFO Get details about a CDF file.
%   INFO = CDFINFO(FILE) gives information about a Common Data Format
%   (CDF) file.  INFO is a structure containing the following fields:
%
%     Filename             A string containing the name of the file
%
%     FileModDate          A string containing the modification date of
%                          the file
%
%     FileSize             An integer indicating the size of the file in
%                          bytes
%
%     Format               A string containing the file format (CDF)
%
%     FormatVersion        A string containing the version of the CDF
%                          library used to create the file
%
%     FileSettings         A structure containing library settings used
%                          to create the file
%
%     Subfiles             A cell array of filenames which contain the
%                          CDF file's data if it is a multifile CDF
%
%     Variables            A cell array containing details about the
%                          variables in the file (see below)
%
%     GlobalAttributes     A structure containing the global metadata
%
%     VariableAttributes   A structure containing metadata for the
%                          variables
%
%   The "Variables" field contains a cell array of details about the
%   variables in the CDF file.  Each row represents a variable in the
%   file.  The columns are:
%
%     (1) The variable's name as a string.
%
%     (2) The dimensions of the variable according to MATLAB's SIZE
%         function. 
%
%     (3) The number of records assigned for this variable.
%
%     (4) The variable's data type as it is stored in the CDF file.
%
%     (5) The record and dimension variance settings for the variable.
%         The value to the left of the slash designates whether values
%         vary by record; the values to the right designate whether
%         values vary at each dimension.
%
%     (6) The sparsity of the variables records.  Allowable values are
%         'Full', 'Sparse (padded)', and 'Sparse (nearest)'.
%
%   The "GlobalAttributes" and "VariableAttributes" structures contain a
%   field for each attribute.  Each field's name corresponds to the name
%   of the attribute, and the field contains a cell array containing the
%   entry values for the attribute.  For variable attributes, the first
%   column of the cell array contains the Variable names associated with
%   the entries, and the second contains the entry values.
%
%   NOTE: Attribute names which CDFINFO uses for field names in
%   "GlobalAttributes" and "VariableAttributes" may not match the names
%   of the attributes in the CDF file exactly.  Because attribute names
%   can contain characters which are illegal in MATLAB field names, they
%   may be translated into legal field names.  Illegal characters which
%   appear at the beginning of attributes are removed; other illegal
%   characters are replaced with underscores ('_').  If an attribute's
%   name is modified, the attribute's internal number is appended to the
%   end of the field name.  For example, '  Variable%Attribute ' might
%   become 'Variable_Attribute_013'.
%
%   NOTE: CDFINFO creates temporary files when accessing CDF files.  The
%   current working directory must be writeable.
%
%   See also CDFREAD, CDFWRITE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:57:58 $


%
% Process arguments.
%

if (nargin < 1)
    error('MATLAB:cdfinfo:inputArguments', 'CDFINFO requires at least one input argument.')
end

if (nargout > 2)
    error('MATLAB:cdfinfo:outputArguments', 'CDFINFO requires two or fewer output argument.')
end

% CDFlib creates temporary files in the current directory.  Make sure PWD is
% writable.
%[attrib_success, attrib_mode] = fileattrib(pwd);
%
%if (~attrib_mode.UserWrite)
%    error('Cannot create temporary files.  The current directory must be writable.')
%end


%
% Verify existence of filename.
%

% Get full filename.
fid = fopen(filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([filename '.cdf']);
    
    if (fid == -1)
        fid = fopen([filename '.CDF']);
    end
    
end

if (fid == -1)
    error('MATLAB:cdfinfo:fileOpen', 'Couldn''t open file (%s).', filename)
else
    filename = fopen(fid);
    fclose(fid);
end


%
% Record the file details.
%

d = dir(filename);

% Set the positions of the fields.
info.Filename = d.name;
info.FileModDate = d.date;
info.FileSize = d.bytes;
info.Format = 'CDF';
info.FormatVersion = '';
info.FileSettings = [];
info.FileSettings = {};
info.Subfiles = {};
info.Variables = {};
info.GlobalAttributes = [];
info.VariableAttributes = [];

% CDFlib's OPEN_ routine is flakey when the extension ".cdf" is used.
% Strip the extension from the file before calling the MEX-file.

if ((length(filename) > 4) && (isequal(lower(filename((end-3):end)), '.cdf')))
    filename((end-3):end) = '';
end


% Get the attribute, variable, and library details.
tmp = cdfinfoc(filename);

% Process file attributes.
info.FileSettings = parse_file_info(tmp.File);
info.FormatVersion = info.FileSettings.Version;
info.FileSettings = rmfield(info.FileSettings, 'Version');

% Handle multifile CDF's.
if isequal(info.FileSettings.Format, 'Multifile')

    d = dir([filename '.v*']);
    
    for p = 1:length(d)
        info.Subfiles{p} = d(p).name;
    end
    
end

% Process variable table.
vars = tmp.Variables;
types = vars(:, 4);
sp = vars(:, 6);

for p = 1:length(types)
    types{p} = find_datatype(types{p});
    sp{p} = find_sparsity(sp{p});
end

vars(:, 4) = types;
vars(:, 6) = sp;

info.Variables = vars;

% Assign rest.
info.GlobalAttributes = tmp.GlobalAttributes;
info.VariableAttributes = tmp.VariableAttributes;



function out = parse_file_info(in)

out = in;

% Format.
if (in.Format == 2)
    out.Format = 'Multifile';
else
    out.Format = 'Single-file';
end

% Encoding.
out.Encoding = find_encoding(in.Encoding);

% Majority.
if (in.Majority == 1)
    out.Majority = 'Row';
else
    out.Majority = 'Column';
end

% Version.
out.Version = sprintf('%d.%d.%d', in.Version, in.Release, in.Increment);
out = rmfield(out, {'Release', 'Increment'});

% Compression.
[comp_type, comp_param, comp_pct] = find_compression(in.Compression, ...
                                                  in.CompressionParam, ...
                                                  in.CompressionPercent);

out.Compression = comp_type;
out.CompressionParam = comp_param;
out.CompressionPercent = comp_pct;



function str = find_datatype(num)

switch (num)
case {1, 41}
    str = 'int8';
case {2}
    str = 'int16';
case {4}
    str = 'int32';
case {11}
    str = 'uint8';
case {12}
    str = 'uint16';
case {14}
    str = 'uint32';
case {21, 44}
    str = 'single';
case {22, 45}
    str = 'double';
case {31}
    str = 'epoch';
case {51, 52}
    str = 'char';
end



function str = find_sparsity(num)

switch (num)
case 0
    str = 'Full';
case 1
    str = 'Sparse (padded)';
case 2
    str = 'Sparse (nearest)';
end



function str = find_encoding(num)

switch (num)
case 1
    str = 'Network';
case 2
    str = 'Sun';
case 3
    str = 'Vax';
case 4
    str = 'DECStation';
case 5
    str = 'SGI';
case 6
    str = 'IBM-PC';
case 7
    str = 'IBM-RS';
case 8
    str = 'Host';
case 9
    str = 'Macintosh';
case 11
    str = 'HP';
case 12
    str = 'NeXT';
case 13
    str = 'Alpha OSF1';
case 14
    str = 'Alpha VMS d';
case 15
    str = 'Alpha VMS g';
case 16
    str = 'Alpha VMS i';
end



function [ctype, param, pct] = find_compression(ctype, param, pct)

switch (ctype)
case 0

    ctype = 'Uncompressed';
    param = '';
    pct = [];

case 1
    
    ctype = 'Run-length encoding';
    
    if (param == 0)
        param = 'Encoding of zeros';
    else
        param = '';
    end
    
case 2
    
    ctype = 'Huffman';
    
    if (param == 0)
        param = 'Optimal encoding trees';
    else
        param = '';
    end
    
case 3
    
    ctype = 'Adaptive Huffman';
    
    if (param == 0)
        param = 'Optimal encoding trees';
    else
        param = '';
    end
    
case 4
    
    ctype = 'Rice';
    param = '';
    
case 5
    
    ctype = 'Gzip';
    
end
