function [k,e] = ellipke(m,tol)
%ELLIPKE Complete elliptic integral.
%   [K,E] = ELLIPKE(M) returns the value of the complete elliptic
%   integrals of the first and second kinds, evaluated for each
%   element of M.  As currently implemented, M is limited to 0 <= M <= 1.
%   
%   [K,E] = ELLIPKE(M,TOL) computes the complete elliptic integrals to
%   the accuracy TOL instead of the default TOL = EPS.
%
%   Some definitions of the complete elliptic integrals use the modulus
%   k instead of the parameter m.  They are related by m = k^2.
%
%   See also ELLIPJ.

%   L. Shure 1-9-88
%   Modified to include the second kind by Bjorn Bonnevier
%   from the Alfven Laboratory, KTH, Stockholm, Sweden
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.18.4.3 $  $Date: 2004/04/15 00:06:43 $

%   ELLIPKE uses the method of the arithmetic-geometric mean
%   described in [1].

%   References:
%   [1] M. Abramowitz and I.A. Stegun, "Handbook of Mathematical
%       Functions" Dover Publications", 1965, 17.6.

if nargin<1
  error('MATLAB:ellipke:NotEnoughInputs','Not enough input arguments.'); 
end
if nargin<2, tol = eps; end
if ~isreal(m),
    error('MATLAB:ellipke:ComplexInputs', 'Input arguments must be real.')
end
if isempty(m), k = zeros(size(m)); e = k; return, end
if any(m(:) < 0) || any(m(:) > 1), 
  error('MATLAB:ellipke:MOutOfRange', 'M must be in the range 0 <= M <= 1.');
end

a0 = 1;
b0 = sqrt(1-m);
s0 = m;
i1 = 0; mm = 1;
while mm > tol
    a1 = (a0+b0)/2;
    b1 = sqrt(a0.*b0);
    c1 = (a0-b0)/2;
    i1 = i1 + 1;
    w1 = 2^i1*c1.^2;
    mm = max(w1(:));
    s0 = s0 + w1;
    a0 = a1;
    b0 = b1;
end
k = pi./(2*a1);
e = k.*(1-s0/2);
im = find(m ==1);
if ~isempty(im)
    e(im) = ones(length(im),1);
    k(im) = inf;
end

