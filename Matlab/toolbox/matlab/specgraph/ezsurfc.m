function hh = ezsurfc(varargin)
%EZSURFC Easy to use combination surf/contour plotter.
%   EZSURFC(f) plots a graph of f(x,y) using SURFC where f is a string
%   or a symbolic expression representing a mathematical expression
%   involving two symbolic variables, say 'x' and 'y'.  The function
%   f is plotted over the default domain -2*pi < x < 2*pi, -2*pi < y < 2*pi.
%   The computational grid is chosen according to the amount of
%   variation that occurs.
% 
%   EZSURFC(f,DOMAIN) plots f over the specified DOMAIN instead of the
%   default DOMAIN = [-2*pi,2*pi,-2*pi,2*pi].  The DOMAIN can be the
%   4-by-1 vector [xmin,xmax,ymin,ymax] or the 2-by-1 vector [a,b] (to
%   plot over a < x < b, a < y < b).
%
%   If f is a function of the variables u and v (rather than x and
%   y), then the domain endpoints umin, umax, vmin, and vmax are
%   sorted alphabetically.  Thus, EZSURFC('u^2 - v^3',[0,1,3,6]) plots
%   u^2 - v^3 over 0 < u < 1, 3 < v < 6.
%
%   EZSURFC(x,y,z) plots the parametric surface x = x(s,t), y = y(s,t),
%   and z = z(s,t) over the square -2*pi < s < 2*pi and -2*pi < t < 2*pi.
%
%   EZSURFC(x,y,z,[smin,smax,tmin,tmax]) or EZSURFC(x,y,z,[a,b]) uses the
%   specified domain.
%
%   EZSURFC(...,N) plots f over the default domain using an N-by-N grid.
%   The default value for N is 60.
%
%   EZSURFC(...,'circ') plots f over a disk centered on the domain.
%
%   EZSURFC(AX,...) plots into AX instead of GCA.
%
%   H = EZSURFC(...) returns handles to the plotted object in H.
%
%   Examples:
%   f is typically an expression, but it can also be specified
%   using @ or an inline function:
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezsurfc(f,[-pi,pi])
%    ezsurfc('x*exp(-x^2 - y^2)')
%    ezsurfc('sin(u)*sin(v)')
%    ezsurfc('imag(atan(x + i*y))',[-2,2])
%    ezsurfc('y/(1 + x^2 + y^2)',[-5,5,-2*pi,2*pi])
%
%    ezsurfc('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezsurfc(h)
%    ezsurfc(@peaks)
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%            EZSURF, EZMESHC, SURFC.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2002/10/24 02:14:02 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

if ~isempty(cax)
    h = ezgraph3(cax,'surfc',args{:});
else
    h = ezgraph3('surfc',args{:});
end

if nargout > 0
    hh = h;
end

