function ezsurf(f,varargin)
%EZSURF General surface plotter.
%   EZSURF(f) plots a graph of f(x,y) using SURF where f is a string
%   or a symbolic expression representing a mathematical function
%   involving two symbolic variables, say 'x' and 'y'.  The function
%   f is plotted over the default domain -2*pi < x < 2*pi, -2*pi < y <
%   2*pi.  The computational grid is chosen according to the amount of
%   variation that occurs.
% 
%   EZSURF(f,DOMAIN) plots f over the specified DOMAIN instead of the
%   default DOMAIN = [-2*pi,2*pi,-2*pi,2*pi].  The DOMAIN can be the
%   4-by-1 vector [xmin,xmax,ymin,ymax] or the 2-by-1 vector [a,b] (to
%   plot over a < x < b, a < y < b).
%
%   If f is a function of the variables u and v (rather than x and
%   y), then the domain endpoints umin, umax, vmin, and vmax are
%   sorted alphabetically.  Thus, EZSURF(u^2 - v^3,[0,1,3,6]) plots
%   u^2 - v^3 over 0 < u < 1, 3 < v < 6.
%
%   EZSURF(x,y,z) plots the parametric surface x = x(s,t), y = y(s,t),
%   and z = z(s,t) over the square -2*pi < s < 2*pi and -2*pi < t < 2*pi.
%
%   EZSURF(x,y,z,[smin,smax,tmin,tmax]) or EZSURF(x,y,z,[a,b]) uses the
%   specified domain.
%
%   EZSURF(...,fig) plots f over the default domain in the figure window
%   fig.
%
%   EZSURF(...,'circ') plots f over a disk centered on the domain.
%
%   Examples:
%    syms x y s t
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezsurf(f,[-pi,pi])
%    ezsurf(sin(sqrt(x^2+y^2))/sqrt(x^2+y^2),[-6*pi,6*pi])
%    ezsurf(x*exp(-x^2 - y^2))
%    ezsurf(x*(y^2)/(x^2 + y^4))
%    ezsurf(x*y,'circ')
%    ezsurf(real(atan(x + i*y)))
%    ezsurf(exp(-x)*cos(t),[-4*pi,4*pi,-2,2])
%
%    ezsurf(s*cos(t),s*sin(t),t)
%    ezsurf(s*cos(t),s*sin(t),s)
%    ezsurf(exp(-s)*cos(t),exp(-s)*sin(t),t,[0,8,0,4*pi])
%    ezsurf(cos(s)*cos(t),cos(s)*sin(t),sin(s),[0,pi/2,0,3*pi/2])
%    ezsurf((s-sin(s))*cos(t),(1-cos(s))*sin(t),s,[-2*pi,2*pi])
%    ezsurf((1-s)*(3+cos(t))*cos(4*pi*s), (1-s)*(3+cos(t))*sin(4*pi*s), ...
%              3*s + (1 - s)*sin(t), [0,2*pi/3,0,12] )
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%            EZSURFC, EZMESHC, SURF.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 03:12:40 $

for k = 1:length(varargin)
   if isa(varargin{k},'sym'), varargin{k} = varargin{k}.s; end
end
ezsurf(f.s,varargin{:});
