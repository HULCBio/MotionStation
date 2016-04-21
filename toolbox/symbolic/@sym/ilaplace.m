function F = ilaplace(varargin)
%ILAPLACE Inverse Laplace transform.
%   F = ILAPLACE(L) is the inverse Laplace transform of the scalar sym L
%   with default independent variable s.  The default return is a
%   function of t.  If L = L(t), then ILAPLACE returns a function of x:
%   F = F(x).
%   By definition, F(t) = int(L(s)*exp(s*t),s,c-i*inf,c+i*inf)
%   where c is a real number selected so that all singularities 
%   of L(s) are to the left of the line s = c, i = sqrt(-1), and 
%   the integration is taken with respect to s.
%
%   F = ILAPLACE(L,y) makes F a function of y instead of the default t:
%       ILAPLACE(L,y) <=> F(y) = int(L(y)*exp(s*y),s,c-i*inf,c+i*inf).
%   Here y is a scalar sym.
%
%   F = ILAPLACE(L,y,x) makes F a function of x instead of the default t:
%   ILAPLACE(L,y,x) <=> F(y) = int(L(y)*exp(x*y),y,c-i*inf,c+i*inf),
%   integration is taken with respect to y.
%
%   Examples:
%      syms s t w x y
%      ilaplace(1/(s-1))              returns   exp(t)
%      ilaplace(1/(t^2+1))            returns   sin(x)
%      ilaplace(t^(-sym(5/2)),x)      returns   4/3/pi^(1/2)*x^(3/2)
%      ilaplace(y/(y^2 + w^2),y,x)    returns   cos(w*x)
%      ilaplace(sym('laplace(F(x),x,s)'),s,x)   returns   F(x)
%
%   See also LAPLACE, IFOURIER, IZTRANS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $  $Date: 2004/04/16 22:22:36 $

% Trap for errors in input first
if nargin >= 4
    error('symbolic:sym:ilaplace:errmsg1','ILAPLACE can take at most 3 input variables');
end

% Make L a sym and extract the variable closest to 'x'.
L = sym(varargin{1});

% Find all symbolic variables in L.
vars = [ '{' findsym(L) '}' ];
% Determine whether s is in the expression.
varcheck = maple([ vars ' intersect {s}']);
% If s is a symbolic variable, make it the default.  Otherwise
% let the variable closest to x be the variable of integration.
if isequal(varcheck,'{s}')
   var = sym('s');
else
   var = findsym(L,1);
end

%If var is empty, then the default is var = 's'.
if isempty(var)
   var = sym('s');
end

% determine whether L is a function of t or another variable.
t_test = strcmp(char(var),'t');

% If L = L(t), then return F = F(x)
if nargin == 1 & t_test == 1
    s = var;
    t = 'x';
end

if nargin == 1 & t_test == 0
    s = var;
    t = 't';
end

if nargin == 2
   s = var;
   if isempty(s), s = 's'; end;
   t = sym(varargin{2});
end

if nargin == 3
    s = sym(varargin{2});
    t = sym(varargin{3});
end

F = maple('map','invlaplace',L,s,t);
% Replace invlaplace with ilaplace.
F = sym(strrep(char(F),'invlaplace','ilaplace'));
