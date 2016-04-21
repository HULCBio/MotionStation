function msg = lengthcheck(F,value)
%LENGTHCHECK  Check length of QFFT.
%   MSG = LENGTHCHECK(F) checks that F.length is an appropriate value for the
%   length property where F is a QFFT object.
%
%   MSG = LENGTHCHECK(F,L) checks that length L is an appropriate value for the
%   F.length property where F is a QFFT object.  
%
%   The length must be a power of the radix.  If the length is wrong, then an
%   appropriate error message is returned in MSG.  If the length is right, then
%   MSG is empty.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:25:20 $

if nargin<2
  value = F.length;
end
msg = '';
if ~isnumeric(value)
  error('Length must be numeric.');
end
if prod(size(value))~=1
  error('Length must be a scalar.');
end
if value<1
  error('Length must be positive.');
end
if floor(value)~=value
  error('Length must be an integer.');
end
base = F.radix;
L = log2(value)/log2(base);
if L ~= floor(L)
  msg = ['Length must be a power of ',num2str(base),'.'];
end
