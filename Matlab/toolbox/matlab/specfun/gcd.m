function [g,c,d] = gcd(a,b)
%GCD    Greatest common divisor.
%   G = GCD(A,B) is the greatest common divisor of corresponding
%   elements of A and B.  The arrays A and B must contain non-negative
%   integers and must be the same size (or either can be scalar).
%   GCD(0,0) is 0 by convention; all other GCDs are positive integers.
%
%   [G,C,D] = GCD(A,B) also returns C and D so that G = A.*C + B.*D.
%   These are useful for solving Diophantine equations and computing
%   Hermite transformations.
%
%   See also LCM.
 
%   Algorithm: See Knuth Volume 2, Section 4.5.2, Algorithm X.
%   Author:    John Gilbert, Xerox PARC
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.14.4.1 $  $Date: 2003/05/01 20:43:46 $
 
% Do scalar expansion if necessary
if length(a) == 1
   a = a(ones(size(b)));
elseif length(b) == 1
   b = b(ones(size(a)));
end

if ~isequal(size(a),size(b))
    error('MATLAB:gcd:InputSizeMismatch', 'Inputs must be the same size.')
else
    siz = size(a);
    a = a(:); b = b(:);
end;

if ~isequal(round(a),a) || ~isequal(round(b),b)
    error('MATLAB:gcd:NonIntInputs', 'Requires integer input arguments.')
end
 
for k = 1:length(a)
   u = [1 0 abs(a(k))];
   v = [0 1 abs(b(k))];
   while v(3)
       q = floor( u(3)/v(3) );
       t = u - v*q;
       u = v;
       v = t;
   end
 
   c(k) = u(1) * sign(a(k));
   d(k) = u(2) * sign(b(k));
   g(k) = u(3);
end

c = reshape(c,siz);
d = reshape(d,siz);
g = reshape(g,siz);
