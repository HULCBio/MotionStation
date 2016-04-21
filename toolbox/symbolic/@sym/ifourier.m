function f = ifourier(varargin)
%IFOURIER Inverse Fourier integral transform.
%   f = IFOURIER(F) is the inverse Fourier transform of the scalar sym F
%   with default independent variable w.  The default return is a
%   function of x.  The inverse Fourier transform is applied to a
%   function of w and returns a function of x: F = F(w) => f = f(x).
%   If F = F(x), then IFOURIER returns a function of t: f = f(t). By
%   definition, f(x) = 1/(2*pi) * int(F(w)*exp(i*w*x),w,-inf,inf) and the 
%   integration is taken with respect to w.
%
%   f = IFOURIER(F,u) makes f a function of u instead of the default x:
%   IFOURIER(F,u) <=> f(u) = 1/(2*pi) * int(F(w)*exp(i*w*u,w,-inf,inf).  
%   Here u is a scalar sym (integration with respect to w).
%
%   f = IFOURIER(F,v,u) takes F to be a function of v instead of the
%   default w:  IFOURIER(F,v,u) <=>
%   f(u) = 1/(2*pi) * int(F(v)*exp(i*v*u,v,-inf,inf),
%   integration with respect to v.
%
%   Examples:
%    syms t u w x
%    ifourier(w*exp(-3*w)*sym('Heaviside(w)'))   returns   1/2/pi/(3-i*t)^2
%
%    ifourier(1/(1 + w^2),u)   returns
%         1/2*exp(-u)*Heaviside(u)+1/2*exp(u)*Heaviside(-u)
%
%    ifourier(v/(1 + w^2),v,u)   returns   i/(1+w^2)*Dirac(1,-u)
%         
%    ifourier(sym('fourier(f(x),x,w)'),w,x)   returns   f(x)
%
%   See also FOURIER, ILAPLACE, IZTRANS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.22.4.2 $  $Date: 2004/04/16 22:22:35 $

% Trap for the errors in input first.

if nargin >= 4
    error('symbolic:sym:ifourier:errmsg1','IFOURIER can take at most 3 input variables');
end

% Make F a sym and extract the variable closest to 'x'.
F = sym(varargin{1});

% Find all symbolic variables in F.
vars = [ '{' findsym(F) '}' ];
% Determine whether w is in the expression.
varcheck = maple([ vars ' intersect {w}']);
% If w is a symbolic variable, make it the default.  Otherwise
% let the variable closest to x be the variable of integration.
if isequal(varcheck,'{w}')
   var = sym('w');
else
   var = findsym(F,1);
end

% If var is empty, then the default is var = 'w'
if isempty(var)
   var = sym('w');
end
% determine whether F is a function of x or another variable.
x_test = strcmp(char(var),'x');

% If F = F(x), return f = f(t)
if nargin == 1 & x_test == 1
    w = var;
    x = 't';
end

% If F is not a function of x, then return f = f(x).
if nargin == 1 & x_test == 0
    w = var;
    x = 'x';
end

if nargin == 2
   w = var;
   if isempty(w), w = 'w'; end;
   x = sym(varargin{2});
end

if nargin == 3
    w = sym(varargin{2});
    x = sym(varargin{3});
end

f = maple('map','invfourier',F,w,x);

% Replace invfourier with ifourier
f = sym(strrep(char(f),'invfourier','ifourier'));
