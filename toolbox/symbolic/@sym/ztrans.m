function F = ztrans(varargin)
%ZTRANS Z-transform.
%   F = ZTRANS(f) is the Z-transform of the scalar sym f with default
%   independent variable n.  The default return is a function of z:
%   f = f(n) => F = F(z).  The Z-transform of f is defined as: 
%      F(z) = symsum(f(n)/z^n, n, 0, inf),
%   where n is f's symbolic variable as determined by FINDSYM.  If
%   f = f(z), then ZTRANS(f) returns a function of w:  F = F(w).
%
%   F = ZTRANS(f,w) makes F a function of the sym w instead of the
%   default z:  ZTRANS(f,w) <=> F(w) = symsum(f(n)/w^n, n, 0, inf).
%
%   F = ZTRANS(f,k,w) takes f to be a function of the sym variable k:
%   ZTRANS(f,k,w) <=> F(w) = symsum(f(k)/w^k, k, 0, inf).
%
%   Examples:
%      syms k n w z
%      ztrans(2^n)           returns  z/(z-2)
%      ztrans(sin(k*n),w)    returns  sin(k)*w/(1-2*w*cos(k)+w^2)
%      ztrans(cos(n*k),k,z)  returns  z*(-cos(n)+z)/(-2*z*cos(n)+z^2+1)
%      ztrans(cos(n*k),n,w)  returns  w*(-cos(k)+w)/(-2*w*cos(k)+w^2+1)
%      ztrans(sym('f(n+1)')) returns  z*ztrans(f(n),n,z)-f(0)*z
%
%   See also IZTRANS, LAPLACE, FOURIER.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $  $Date: 2004/04/16 22:23:22 $

% Trap for errors in input first.
if nargin >= 4
    error('symbolic:sym:ztrans:errmsg1','ZTRANS can take at most 3 input variables');
end

% Make f a sym and extract the variable closest to 'x'.
f = sym(varargin{1});

% Find all symbolic variables in f.
vars = [ '{' findsym(f) '}' ];
% Determine whether n is in the expression.
varcheck = maple([ vars ' intersect {n}']);
% If n is a symbolic variable, make it the default.  Otherwise
% let the variable closest to x be the variable of integration.
if isequal(varcheck,'{n}')
   var = sym('n');
else
   var = findsym(f,1);
end

% If var is empty, then the default is var = 'n'.
if isempty(var)
   var = sym('n');
end

% determine whether f is a function of z or another variable.
z_test = strcmp(char(var),'z');

%   If f = f(z), return F = F(w)
if nargin == 1 & z_test == 1
    n = var;
    z = 'w';
end

if nargin == 1 & z_test == 0
    n = var;
    z = 'z';
end

if nargin == 2
   n = var;
   if isempty(n), n = 'n'; end;
   z = sym(varargin{2});
end

if nargin == 3
    n = sym(varargin{2});
    z = sym(varargin{3});
end


F = maple('map','ztrans',f,n,z);
