function [m, descr] = wk1finfo(filename)
%WK1FINFO Determine if file contains Lotus WK1 worksheet.
%   [A, DESCR] = WK1FINFO('FILENAME')
%
%   A is non-empty if FILENAME contains a readable Lotus worksheet.
%
%   DESCR contains a description of the contents or an error message.
%
%   See also WK1READ, WK1WRITE, CSVREAD, CSVWRITE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%
%   $Revision: 1.6 $  $Date: 2002/06/17 13:27:16 $

%
% include WK1 constants
%
wk1const;

% Validate input args
if nargin==0, error('Not enough input arguments.'); end

% Get Filename
if ~isstr(filename), error('Filename must be a string.'); end

% do some validation
if isempty(filename), error('Filename must not be empty.'); end

% put extension on
if all(filename~='.') filename = [filename '.wk1']; end

% Make sure file exists
if ~isequal(exist(filename), 2), error('File not found.'), end

% open the file Lotus uses Little Endian Format ONLY
fid = fopen(filename,'rb', 'l');
if fid == (-1)
    error(['Could not open file ', filename ,'.']);
end

% Read Lotus WK1 BOF
header = fread(fid, 6,'uchar');
if(header' ~= LOTWK1BOFSTR)
    m = '';
    descr = 'Not a Lotus 123 Worksheet';
    fclose(fid);
    return;
end

m = 'WK1';
descr = 'Lotus 123 Spreadsheet';
