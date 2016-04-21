function t = strcat(varargin)
%STRCAT Concatenate strings.
%   T = STRCAT(S1,S2,S3,...) horizontally concatenates corresponding
%   rows of the character arrays S1, S2, S3 etc. All input arrays must
%   have the same number of rows (or any can be a single string). When
%   the inputs are all character arrays, the output is also a character
%   array.
%
%   When any of the inputs is a cell array of strings, STRCAT returns
%   a cell array of strings formed by concatenating corresponding
%   elements of S1, S2, etc. The inputs must all have the same size
%   (or any can be a scalar). Any of the inputs can also be character
%   arrays.
%
%   Trailing spaces in character array inputs are ignored and do not
%   appear in the output. This is not true for inputs that are cell
%   arrays of strings. Use the concatenation syntax [S1 S2 S3 ...]
%   to preserve trailing spaces.
%
%   Example
%       strcat({'Red','Yellow'},{'Green','Blue'})
%   returns
%       'RedGreen'    'YellowBlue'
%
%   See also STRVCAT, CAT, CELLSTR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.4 $  $Date: 2004/04/10 23:32:53 $

%   The cell array implementation is in @cell/strcat.m

if nargin<1
    error('MATLAB:strfun:Nargin','Not enough input arguments.'); end

% initialise return arguments
t = '';

% get number of rows of each input
rows = cellfun('size',varargin,1);
% get number of dimensions of each input
twod = (cellfun('ndims',varargin) == 2);

% return empty string when all inputs are empty
if all(rows == 0)
    return;
end
if ~all(twod)
    error('MATLAB:strfun:InputDimension',...
        'All the inputs must be two dimensional.');
end

% Remove empty inputs
k = (rows == 0);
varargin(k) = [];
rows(k) = [];
maxrows = max(rows);
% Scalar expansion

for i=1:length(varargin),
    if rows(i)==1 && rows(i)<maxrows
        varargin{i} = varargin{i}(ones(1,maxrows),:);
        rows(i) = maxrows;
    end
end

if any(rows~=rows(1)),
    error('MATLAB:strcat:NumberOfInputRows',...
        'All the inputs must have the same number of rows or a single row.');
end

n = rows(1);
space = sum(cellfun('prodofsize',varargin));
s0 =  blanks(space);
scell = cell(1,n);
notempty = true(1,n);
s = '';
for i = 1:n
    s = s0;
    str = varargin{1}(i,:);
    if ~isempty(str) && (str(end) == 0 || isspace(str(end)))
        str = char(deblank(str));
    end
    pos = length(str);
    s(1:pos) = str;
    pos = pos + 1;
    for j = 2:length(varargin)
        str = varargin{j}(i,:);
        if ~isempty(str) && (str(end) == 0 || isspace(str(end)))
            str = char(deblank(str));
        end
        len = length(str);
        s(pos:pos+len-1) = str;
        pos = pos + len;
    end
    s = s(1:pos-1);
    notempty(1,i) = ~isempty(s);
    scell{1,i} = s;
end
if n > 1
    t = char(scell{notempty});
else
    t = s;
end