function [q,r]=deconv(b,a)
%DECONV Deconvolution and polynomial division.
%   [Q,R] = DECONV(B,A) deconvolves vector A out of vector B.  The result
%   is returned in vector Q and the remainder in vector R such that
%   B = conv(A,Q) + R.
%
%   If A and B are vectors of polynomial coefficients, deconvolution
%   is equivalent to polynomial division.  The result of dividing B by
%   A is quotient Q and remainder R.
%
%   Class support for inputs B,A:
%      float: double, single
%
%   See also CONV, RESIDUE.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.12.4.2 $  $Date: 2004/03/09 16:16:14 $

error(nargchk(2,2,nargin));
if a(1)==0
    error('MATLAB:deconv:ZeroCoef1', 'First coefficient of A must be non-zero.')
end
[mb,nb] = size(b);
nb = max(mb,nb);
na = length(a);
if na > nb
   q = zeros(superiorfloat(b,a));
   r = b;
else
   % Deconvolution and polynomial division are the same operations
   % as a digital filter's impulse response B(z)/A(z):
   q = filter(b, a, [1 zeros(1,nb-na)]);
   if mb ~= 1
      q = q(:);
   end
   if nargout>1,
      r = b - conv(a,q);
   end
end
