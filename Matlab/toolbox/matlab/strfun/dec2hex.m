function h = dec2hex(d,n)
%DEC2HEX Convert decimal integer to hexadecimal string.
%   DEC2HEX(D) returns a 2-D string array where each row is the
%   hexadecimal representation of each decimal integer in D.
%   D must contain non-negative integers smaller than 2^52.  
%
%   DEC2HEX(D,N) produces a 2-D string array where each
%   row contains an N digit hexadecimal number.
%
%   Example
%       dec2hex(2748) returns 'ABC'.
%    
%   See also HEX2DEC, HEX2NUM, DEC2BIN, DEC2BASE.

%   Author: L. Shure
%   Revised by: CMT 1-22-95
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.3 $  $Date: 2004/04/10 23:32:36 $

bits32 = 4294967296;       % 2^32


if ~isreal(d) || any(d < 0) || any(d ~= fix(d))
  error('First argument must contain non-negative integers.')
end
if ~isreal(d)
	warning('MATLAB:dec2hex:TooLargeArg',...
		'Imaginary parts of the inputs are ignored.');
end
if any(d > 1/eps)
	warning('MATLAB:dec2hex:TooLargeArg',...
		['At least one of the input numbers is larger than the largest',...
		'FLINT (2^52).\n         Results may be unpredictable.']);
end
if isempty(d)
    h = ''; 
    return
end
d = d(:); % Make sure d is a column vector.

numD = numel(d);

if nargin==1,
  n = 1; % Need at least one digit even for 0.
end

[f,e] = log2(double(max(d)));
n = max(n,ceil(e/4));
n0 = n;

if numD>1
    n = n*ones(numD,1);
end

%For small enough numbers, we can do this the fast way.
if all(d<bits32),
  h = sprintf('%0*X',[n,d]');
else
%Division acts differently for integers 
  d = double(d);
  d1 = floor(d/bits32);
  d2 = rem(d,bits32);
  h = sprintf('%0*X%08X',[n-8,d1,d2]');
end

h = reshape(h,n0,numD)';
