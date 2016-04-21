function f = iztrans(varargin)
%IZTRANS Inverse Z-transform.
%   f = IZTRANS(F) is the inverse Z-transform of the scalar sym F with
%   default independent variable z.  The default return is a function 
%   of n:  F = F(z) => f = f(n).  If F = F(n), then IZTRANS returns a
%   function of k: f = f(k).
%   f = IZTRANS(F,k) makes f a function of k instead of the default n.
%   Here m is a scalar sym.
%   f = IZTRANS(F,w,k) takes F to be a function of w instead of the
%   default symvar(F) and returns a function of k:  F = F(w) & f = f(k).
%
%   Examples:
%      iztrans(z/(z-2))        returns   2^n
%      iztrans(exp(x/z),z,k)   returns   x^k/k!
%
%   See also ZTRANS, LAPLACE, FOURIER.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/16 22:22:43 $

% Trap for errors in input first.
if nargin >= 4
    error('symbolic:sym:iztrans:errmsg1','IZTRANS can take at most 3 input variables');
end

% Make F a sym and extract the variable closest to 'x'.
F = sym(varargin{1});

% Find all symbolic variables in F.
vars = [ '{' findsym(F) '}' ];
% Determine whether z is in the expression.
varcheck = maple([ vars ' intersect {z}']);
% If z is a symbolic variable, make it the default.  Otherwise
% let the variable closest to x be the variable of integration.
if isequal(varcheck,'{z}')
   var = sym('z');
else
   var = findsym(F,1);
end

% If var is empty, then the default is var = 'z'.
if isempty(var)
   var = sym('z');
end

% determine whether F is a function of n or another variable.
n_test = strcmp(char(var),'n');

% If F = F(n), return f = f(k)
if nargin == 1 & n_test == 1
    z = var;
    n = 'k';
end

if nargin == 1 & n_test == 0
    z = var;
    n = 'n';
end

if nargin == 2
   z = var;
   if isempty(z), z = 'z'; end;
   n = sym(varargin{2});
end

if nargin == 3
   z = sym(varargin{2});
   n = sym(varargin{3});
end

f = maple('map','invztrans',F,z,n);

% Replace invztrans with iztrans
f = sym(strrep(char(f),'invztrans','iztrans'));
