function h = compose(varargin);
%COMPOSE Functional composition.
%   COMPOSE(f,g) returns f(g(y)) where f = f(x) and g = g(y). 
%   Here x is the symbolic variable of f as defined by FINDSYM and 
%   y is the symbolic variable of g as defined by FINDSYM.
%
%   COMPOSE(f,g,z) returns f(g(z)) where f = f(x), g = g(y), and
%   x and y are the symbolic variables of f and g as defined by 
%   FINDSYM. 
%
%   COMPOSE(f,g,x,z) returns f(g(z)) and makes x the independent 
%   variable for f.  That is, if f = cos(x/t), then COMPOSE(f,g,x,z)
%   returns cos(g(z)/t) whereas COMPOSE(f,g,t,z) returns cos(x/g(z)).
%  
%   COMPOSE(f,g,x,y,z) returns f(g(z)) and makes x the independent
%   variable for f and y the independent variable for g.  For
%   f = cos(x/t) and g = sin(y/u), COMPOSE(f,g,x,y,z) returns
%   cos(sin(z/u)/t) whereas COMPOSE(f,g,x,u,z) returns cos(sin(y/z)/t).
% 
%   Examples:
%    syms x y z t u;
%    f = 1/(1 + x^2); g = sin(y); h = x^t; p = exp(-y/u);
%    compose(f,g)         returns   1/(1+sin(y)^2) 
%    compose(f,g,t)       returns   1/(1+sin(t)^2)
%    compose(h,g,x,z)     returns   sin(z)^t
%    compose(h,g,t,z)     returns   x^sin(z)
%    compose(h,p,x,y,z)   returns   exp(-z/u)^t 
%    compose(h,p,t,u,z)   returns   x^exp(-y/z) 
%
%   See also FINVERSE, FINDSYM, SUBS.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/04/15 03:09:42 $

% Set up the functions f and g as symbolic objects and find
% their symbolic variables varf and varg, respectively.
f = sym(varargin{1}); varf = sym(findsym(f,1));
g = sym(varargin{2}); varg = sym(findsym(g,1));
B = sym([]);
% If either f or g is identically constant, then assign f
% the variable x and g the variable y.
if isequal(varf,B)
      varf = sym('x');
end
if isequal(varg,B)
      varg = sym('y');
end

% First consider the case where f = f(x), g = g(y) and we
% wish to compute h = f(g(y)).
if nargin == 2
    varh = varg;

elseif nargin == 3
% This is the case where f = f(x), g = g(y), and h = f(g(t)).
    varh = sym(varargin{3});  % This is the variable "t".

elseif nargin == 4
% Here, f = f(varargin{3}, v), g = g(y) and h = f(g(z), v).
    varf = sym(varargin{3});
    varh = sym(varargin{4}); % The variable "z".
    K = maple(['{' char(findsym(g)) '}' 'intersect' '{' char(varh) '}']);
    K(find(K == '{')) = []; K(find(K == '}')) = [];
    if ~isempty(K)
       g = subs(g,K,varh);
       varg = sym(K);
    end

elseif nargin == 5
% In this case, f = f(varargin{3}, v), g = g(varargin{4}, w), and
% h = f(g(z,w), v).
    varf = sym(varargin{3}); % The independent variable for f
    varg = sym(varargin{4}); % The independent variable for g
    varh = sym(varargin{5}); % The variable "z".
end
   
maple(['F := ' varf.s ' -> ' f.s ';']);           % F = f(x, v)
maple(['G := ' varg.s ' -> ' g.s ';']);           % G = g(y, w)
maple(['H := ' varh.s ' -> F(G(' varh.s '));']);  % H = f(g(z, w), v)
% Return the composed functions as a symbolic object.
h = sym(maple(['H(' varh.s ')']));

% Clear out the remaining variables in the Maple workspace.
maple( 'F := ''F'';');
maple( 'G := ''G'';');
maple( 'H := ''H'';');
