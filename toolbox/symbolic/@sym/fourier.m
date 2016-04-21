function F = fourier(varargin)
%FOURIER Fourier integral transform.
%   F = FOURIER(f) is the Fourier transform of the sym scalar f
%   with default independent variable x.  The default return is
%   a function of w.
%   If f = f(w), then FOURIER returns a function of t:  F = F(t).
%   By definition, F(w) = int(f(x)*exp(-i*w*x),x,-inf,inf), where
%   the integration above proceeds with respect to x (the symbolic
%   variable in f as determined by FINDSYM).
%
%   F = FOURIER(f,v) makes F a function of the sym v instead of 
%       the default w:
%   FOURIER(f,v) <=> F(v) = int(f(x)*exp(-i*v*x),x,-inf,inf).
%
%   FOURIER(f,u,v) makes f a function of u instead of the
%       default x. The integration is then with respect to u.
%   FOURIER(f,u,v) <=> F(v) = int(f(u)*exp(-i*v*u),u,-inf,inf).
%
%   Examples:
%    syms t v w x
%    fourier(1/t)   returns   i*pi*(Heaviside(-w)-Heaviside(w))
%    fourier(exp(-x^2),x,t)   returns   pi^(1/2)*exp(-1/4*t^2)
%    fourier(exp(-t)*sym('Heaviside(t)'),v)   returns   1/(1+i*v)
%    fourier(diff(sym('F(x)')),x,w)   returns   i*w*fourier(F(x),x,w)
%
%   See also IFOURIER, LAPLACE, ZTRANS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $  $Date: 2004/04/16 22:22:30 $pjcosta

% Trap for errors in input first.
if nargin >= 4
    error('symbolic:sym:fourier:errmsg1','FOURIER can take at most 3 input variables');
end

% Make f a sym and extract the variable closest to 'x'.
f = sym(varargin{1});

% In this function, no special processing need be done as x is the
% first variable returned by findsym(expr,1), provided x is a symbolic
% variable within the expression expr.
var = findsym(f,1);
% If var is empty, then the default is var = 'x'.
if isempty(var)
   var = sym('x');
end

% determine whether f is a function of w or another variable.
w_test = strcmp(char(var),'w');

% If f = f(w), then return F = F(t)
if nargin == 1 & w_test == 1
    x = var;
    w = 't';
end

% If f is not a function of w, then return F = F(w). 
if nargin == 1 & w_test == 0
    x = var;
    w = 'w';
end

if nargin == 2
   x = var;
   if isempty(x), x = 'x'; end;
   w = sym(varargin{2});
end

if nargin == 3
    x = sym(varargin{2});
    w = sym(varargin{3});
end

F = maple('map','fourier',f,x,w);
