function out = binvec2dec(vec)
% BINVEC2DEC Convert binary vector to decimal number.
%
%    BINVEC2DEC(B) interprets the binary vector B and returns the
%    equivalent decimal number.  The least significant bit is 
%    represented by the first column.
%
%    Non-zero values will be mapped to 1, e.g. [1 2 3 0] maps
%    to [1 1 1 0].
% 
%    Note: The binary vector cannot exceed 52 values.
%
%    Example:
%       binvec2dec([1 1 1 0 1]) returns 23
%
%    See also DEC2BINVEC, BIN2DEC.
%

%    MP 11-11-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.7.2.4 $  $Date: 2003/08/29 04:40:41 $

% Error if B is not defined.
if isempty(vec)
   error('daq:binvec2dec:argcheck', 'B must be defined.  Type ''daqhelp binvec2dec'' for more information.');
end

% Error if B is not a double.
if (~isa(vec, 'double') && ~isa(vec, 'logical'))
   error('daq:binvec2dec:argcheck', 'B must be a binvec.');
end

% Non-zero values map to 1.
vec = vec~=0;

% Convert the binvec [0 0 1 1] to a binary string '1100';
h = deblank(num2str(fliplr(vec)'))';

% Convert the binary string to a decimal number.
out = bin2dec(h);



