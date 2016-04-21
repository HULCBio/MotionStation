function s=dec2bin(d,n)
%DEC2BIN Convert decimal integer to a binary string.
%   DEC2BIN(D) returns the binary representation of D as a string.
%   D must be a non-negative integer smaller than 2^52. 
%
%   DEC2BIN(D,N) produces a binary representation with at least
%   N bits.
%
%   Example
%      dec2bin(23) returns '10111'
%
%   See also BIN2DEC, DEC2HEX, DEC2BASE.

%   Hans Olsson, hanso@dna.lth.se 3-23-95
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2004/04/10 23:32:35 $

%
% Input checking
%
if nargin==0, error('Not enough input arguments.'); end
if isempty(d), s = ''; return, end

d = d(:); % Make sure d is a column vector.
d = double(d);

if (nargin<2)
  n=1; % Need at least one digit even for 0.
else
  n = double(n);	
  if ~isscalar(n) || n<0, error('N must be a positive scalar.'); end
  n = round(n); % Make sure n is an integer.
end;

%
% Actual algorithm
%
[f,e]=log2(max(d)); % How many digits do we need to represent the numbers?
s=char(rem(floor(d*pow2(1-max(n,e):0)),2)+'0');
