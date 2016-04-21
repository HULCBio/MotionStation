function L = laplace(varargin)
%LAPLACE Laplace transform.
%   L = LAPLACE(F) is the Laplace transform of the scalar sym F with
%   default independent variable t.  The default return is a function
%   of s.  If F = F(s), then LAPLACE returns a function of t:  L = L(t).
%   By definition L(s) = int(F(t)*exp(-s*t),0,inf), where integration
%   occurs with respect to t.
%
%   L = LAPLACE(F,t) makes L a function of t instead of the default s:
%   LAPLACE(F,t) <=> L(t) = int(F(x)*exp(-t*x),0,inf).
%
%   L = LAPLACE(F,w,z) makes L a function of z instead of the
%   default s (integration with respect to w).
%   LAPLACE(F,w,z) <=> L(z) = int(F(w)*exp(-z*w),0,inf).
%
%   Examples:
%      syms a s t w x
%      laplace(t^5)           returns   120/s^6
%      laplace(exp(a*s))      returns   1/(t-a)
%      laplace(sin(w*x),t)    returns   w/(t^2+w^2)
%      laplace(cos(x*w),w,t)  returns   t/(t^2+x^2)
%      laplace(x^sym(3/2),t)  returns   3/4*pi^(1/2)/t^(5/2)
%      laplace(diff(sym('F(t)')))   returns   laplace(F(t),t,s)*s-F(0)
%
%   See also ILAPLACE, FOURIER, ZTRANS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/16 22:22:47 $

% Trap for errors in input first.
if nargin >= 4
    error('symbolic:sym:laplace:errmsg1','LAPLACE can take at most 3 input variables');
end

% Make F a sym and extract the variable closest to 'x'.
F = sym(varargin{1});

% Find all symbolic variables in F.
vars = [ '{' findsym(F) '}' ];
% Determine whether t is in the expression.
varcheck = maple([ vars ' intersect {t}']);
% If t is a symbolic variable, make it the default.  Otherwise
% let the variable closest to x be the variable of integration.
if isequal(varcheck,'{t}')
   var = sym('t');
else
   var = findsym(F,1);
end

% If var is empty, then the default is var = 't'.
if isempty(var)
   var = sym('t');
end
% determine whether F is a function of s or another variable.
s_test = strcmp(char(var),'s');

% If F = F(s), then return L = L(t)
if nargin == 1 & s_test == 1
    t = var;
    s = 't';
end

if nargin == 1 & s_test == 0
    t = var;
    s = 's';
end

if nargin == 2
   t = var;
   if isempty(t), t = 't'; end;
   s = sym(varargin{2});
end

if nargin == 3
    t = sym(varargin{2});
    s = sym(varargin{3});
end

L = maple('map','laplace',F,t,s);
