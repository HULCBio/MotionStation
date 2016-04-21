function m = csvread(filename, r, c, rng)
%CSVREAD Read a comma separated value file.
%   M = CSVREAD('FILENAME') reads a comma separated value formatted file
%   FILENAME.  The result is returned in M.  The file can only contain
%   numeric values.
%
%   M = CSVREAD('FILENAME',R,C) reads data from the comma separated value
%   formatted file starting at row R and column C.  R and C are zero-
%   based so that R=0 and C=0 specifies the first value in the file.
%
%   M = CSVREAD('FILENAME',R,C,RNG) reads only the range specified
%   by RNG = [R1 C1 R2 C2] where (R1,C1) is the upper-left corner of
%   the data to be read and (R2,C2) is the lower-right corner.  RNG
%   can also be specified using spreadsheet notation as in RNG = 'A1..B7'.
%
%   CSVREAD fills empty delimited fields with zero.  Data files where
%   the lines end with a comma will produce a result with an extra last 
%   column filled with zeros.
%
%   See also CSVWRITE, DLMREAD, DLMWRITE, LOAD, FILEFORMATS, TEXTSCAN.

%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.17.4.1 $  $Date: 2004/03/26 13:26:21 $

% Validate input args
if nargin==0, error('Not enough input arguments.'); end

% Get Filename
if ~isstr(filename), error('Filename must be a string.'); end

% Make sure file exists
if ~isequal(exist(filename), 2), error('File not found.'), end

%
% Call dlmread with a comma as the delimiter
%
if nargin < 2
    r = 0;
end
if nargin < 3
    c = 0;
end
if nargin < 4
    m=dlmread(filename, ',', r, c);
else
    m=dlmread(filename, ',', r, c, rng);
end
