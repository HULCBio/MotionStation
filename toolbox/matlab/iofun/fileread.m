function out=fileread(filename)
%FILEREAD Return contents of file as string vector.
%
% See also FREAD, TEXTSCAN, LOAD, WEB

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.5.4.3 $  $Date: 2004/03/26 13:26:25 $

% Validate input args
if nargin==0, error('Not enough input arguments.'); end

% get filename
if ~ischar(filename), error('Filename must be a string.'); end

% do some validation
if isempty(filename), error('Filename must not be empty.'); end

% make sure file exists
if ~isequal(exist(filename), 2), error('File not found.'), end

% open the file
fid = fopen(filename);
if fid == (-1)
    error(['Could not open file ', filename ,'.']);
end

% set file pointer to EOF
fseek(fid,0,1); 
% get the number of bytes from start of file
numBytes = ftell(fid); 
% set file pointer back at start of file
fseek(fid,0,-1); 
% read file
out=fread(fid,[1,numBytes],'char=>char');

% close file
fclose(fid);
