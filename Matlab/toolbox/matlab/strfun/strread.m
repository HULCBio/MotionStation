function varargout = strread(varargin)
%STRREAD Read formatted data from string.
%    A = STRREAD('STRING')
%    A = STRREAD('STRING','',N)
%    A = STRREAD('STRING','',param,value, ...)
%    A = STRREAD('STRING','',N,param,value, ...) reads numeric data from
%    the STRING into a single variable.  If the string contains any text data,
%    an error is produced.
%
%    [A,B,C, ...] = STRREAD('STRING','FORMAT')
%    [A,B,C, ...] = STRREAD('STRING','FORMAT',N)
%    [A,B,C, ...] = STRREAD('STRING','FORMAT',param,value, ...)
%    [A,B,C, ...] = STRREAD('STRING','FORMAT',N,param,value, ...) reads
%    data from the STRING into the variables A,B,C,etc.  The type of each
%    return argument is given by the FORMAT string.  The number of return
%    arguments must match the number of conversion specifiers in the FORMAT
%    string.  If there are fewer fields in the string than matching conversion
%    specifiers in the format string, an error is produced.
%
%    If N is specified, the format string is reused N times.  If N is -1 (or
%    not specified) STRREAD reads the entire string.
%
%    Example
%
%      s = sprintf('a,1,2\nb,3,4\n');
%      [a,b,c] = strread(s,'%s%d%d','delimiter',',')
%
%   See TEXTREAD for more examples and definition of terms.
%
%   See also TEXTREAD, SSCANF, FILEFORMATS, STRTOK.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $ $Date: 2004/03/08 02:02:18 $

%   Implemented as a mex file.

% do some preliminary error checking
if nargin < 1
    error(nargchk(1,inf,nargin));
end

if nargout == 0
    nlhs = 1;
else
    nlhs = nargout;
end
num = numel(varargin{1});
if  num < 4095 % 4095 is dataread's buffer limit
    [varargout{1:nlhs}]=dataread('string',varargin{:});
else % Unicode chars are two bytes
    [varargout{1:nlhs}]=dataread('string',varargin{:},'bufsize',2*num );
end
