function [sn,cn,dn] = ellipj(u,m,tol)
%ELLIPJ Jacobi elliptic functions.
%   [Sn,Cn,Dn] = ELLIPJ(U,M) returns the values of the Jacobi
%   elliptic functions SN, CN and DN, evaluated for corresponding
%   elements of argument U and parameter M.  The arrays U and M must
%   be the same size (or either can be scalar).  As currently
%   implemented, M is limited to 0 <= M <= 1. 
%
%   [Sn,Cn,Dn] = ELLIPJ(U,M,TOL) computes the elliptic functions to
%   the accuracy TOL instead of the default TOL = EPS.  
%
%   Some definitions of the Jacobi elliptic functions use the modulus
%   k instead of the parameter m.  They are related by m = k^2.
%
%   See also ELLIPKE.

%   L. Shure 1-9-88
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.15.4.1 $  $Date: 2003/05/01 20:43:33 $

%   ELLIPJ uses the method of the arithmetic-geometric mean
%   described in [1].
%
%   References:
%   [1] M. Abramowitz and I.A. Stegun, "Handbook of Mathematical
%       Functions" Dover Publications", 1965, Ch. 16-17.6.

if nargin<3, tol = eps; end
if nargin<2
  error('MATLAB:ellipj:NotEnoughInputs','Not enough input arguments.'); 
end

if ~isreal(u) || ~isreal(m)
    error('MATLAB:ellipj:ComplexInputs', 'Input arguments must be real.')
end

[mm,nm] = size(m);
[mu,nu] = size(u);
if length(m)==1, m = m(ones(size(u))); end
if length(u)==1, u = u(ones(size(m))); end
if ~isequal(size(m),size(u)) 
  error('MATLAB:ellipj:InputSizeMismatch', 'U and M must be the same size.'); 
end

mmax = numel(u);

cn = zeros(size(u));
sn = cn;
dn = sn;
m = m(:).';    % make a row vector
u = u(:).';

if any(m < 0) || any(m > 1), 
  error('MATLAB:ellipj:MOutOfRange', 'M must be in the range 0 <= M <= 1.');
end

% pre-allocate space and augment if needed
chunk = 10;
a = zeros(chunk,mmax);
c = a;
b = a;
a(1,:) = ones(1,mmax);
c(1,:) = sqrt(m);
b(1,:) = sqrt(1-m);
n = zeros(1,mmax);
i = 1;
while any(abs(c(i,:)) > tol)
    i = i + 1;
    if i > size(a,1)
      a = [a; zeros(chunk,mmax)];
      b = [b; zeros(chunk,mmax)];
      c = [c; zeros(chunk,mmax)];
    end
    a(i,:) = 0.5 * (a(i-1,:) + b(i-1,:));
    b(i,:) = sqrt(a(i-1,:) .* b(i-1,:));
    c(i,:) = 0.5 * (a(i-1,:) - b(i-1,:));
    in = find((abs(c(i,:)) <= tol) & (abs(c(i-1,:)) > tol));
    if ~isempty(in)
      [mi,ni] = size(in);
      n(in) = repmat((i-1), mi, ni);
    end
end
phin = zeros(i,mmax);
phin(i,:) = (2 .^ n).*a(i,:).*u;
while i > 1
    i = i - 1;
    in = find(n >= i);
    phin(i,:) = phin(i+1,:);
    if ~isempty(in)
      phin(i,in) = 0.5 * ...
      (asin(c(i+1,in).*sin(rem(phin(i+1,in),2*pi))./a(i+1,in)) + phin(i+1,in));
    end
end
sn(:) = sin(rem(phin(1,:),2*pi));
cn(:) = cos(rem(phin(1,:),2*pi));
dn(:) = sqrt(1 - m .* (sn(:).').^2);

% special case m = 1 
m1 = find(m==1);
sn(m1) = tanh(u(m1));
cn(m1) = sech(u(m1));
dn(m1) = sech(u(m1));
