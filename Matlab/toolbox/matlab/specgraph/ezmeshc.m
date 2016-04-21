function hh = ezmeshc(varargin)
%EZMESHC Easy to use combination mesh/contour plotter.
%   EZMESHC(f) plots a graph of f(x,y) using MESHC where f is a string
%   or a symbolic expression representing a mathematical expression
%   involving two symbolic variables, say 'x' and 'y'.  The function
%   f is plotted over the default domain -2*pi < x < 2*pi, -2*pi < y < 2*pi.
%   The computational grid is chosen according to the amount of
%   variation that occurs.
% 
%   EZMESHC(f,DOMAIN) plots f over the specified DOMAIN instead of the
%   default DOMAIN = [-2*pi,2*pi,-2*pi,2*pi].  The DOMAIN can be the
%   4-by-1 vector [xmin,xmax,ymin,ymax] or the 2-by-1 vector [a,b] (to
%   plot over a < x < b, a < y < b).
%
%   If f is a function of the variables u and v (rather than x and
%   y), then the domain endpoints umin, umax, vmin, and vmax are
%   sorted alphabetically.  Thus, EZMESHC('u^2 - v^3',[0,1,3,6]) plots
%   u^2 - v^3 over 0 < u < 1, 3 < v < 6.
%
%   EZMESHC(x,y,z) plots the parametric surface x = x(s,t), y = y(s,t),
%   and z = z(s,t) over the square -2*pi < s < 2*pi and -2*pi < t < 2*pi.
%
%   EZMESHC(x,y,z,[smin,smax,tmin,tmax]) or EZMESHC(x,y,z,[a,b]) uses the
%   specified domain.
%
%   EZMESHC(...,N) plots f over the default domain using an N-by-N grid.
%   The default value for N is 60.
%
%   EZMESHC(...,'circ') plots f over a disk centered on the domain.
%
%   EZMESHC(AX,...) plots into AX instead of GCA.
%
%   H = EZMESHC(...) returns handles to plotted objects in H.
%
%   Examples:
%   f is typically an expression, but it can also be specified
%   using @ or an inline function:
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezmeshc(f,[-pi,pi])
%    ezmeshc('x*exp(-x^2 - y^2)')
%    ezmeshc('sin(u)*sin(v)')
%    ezmeshc('imag(atan(x + i*y))',[-2,2])
%    ezmeshc('y/(1 + x^2 + y^2)',[-5,5,-2*pi,2*pi])
%
%    ezmeshc('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezmeshc(h)
%    ezmeshc(@peaks)
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%            EZSURF, EZSURFC, MESHC.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2002/10/24 02:13:57 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

if ~isempty(cax)
    h = ezgraph3(cax,'meshc',args{:});
else
    h = ezgraph3('meshc',args{:});
end

if nargout > 0
    hh = h;
end
