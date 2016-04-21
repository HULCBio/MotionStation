function hh = ezcontourf(varargin)
%EZCONTOURF Easy to use filled contour plotter.
%   EZCONTOURF(f) plots the contour lines of f(x,y) using CONTOURF where
%   f is a string or symbolic expression representing a mathematical
%   function of two variables, say 'x' and 'y'.  The function f is 
%   plotted over the default domain -2*pi < x < 2*pi, -2*pi < y < 2*pi.
%   The computational grid is chosen according to the amount
%   of variation that occurs.
%
%   EZCONTOURF(f,DOMAIN) plots f over the specified DOMAIN instead of the
%   default DOMAIN = [-2*pi,2*pi,-2*pi,2*pi].  The DOMAIN can be the
%   4-by-1 vector [xmin,xmax,ymin,ymax] or the 2-by-1 vector [a,b] (to
%   plot over a < x < b, a < y < b).
%
%   If f is a function of the variables u and v (rather than x and y),
%   then the domain endpoints umin, umax, vmin, and vmax are sorted
%   alphabetically.  Thus, EZCONTOURF(u^2 - v^3,[0,1],[3,6]) plots the
%   contour lines for u^2 - v^3 over 0 < u < 1, 3 < v < 6.
%
%   EZCONTOURF(...,N) plots f over the default domain using an N-by-N grid.
%   The default value for N is 60.
%
%   EZCONTOURF(AX,...) plots into AX instead of GCA.
%
%   H = EZCONTOURF(...) returns handles to contour objects in H.
%
%   Examples:
%   f is typically an expression, but it can also be specified
%   using @ or an inline function:
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezcontourf(f,[-pi,pi])
%    ezcontourf('sin(sqrt(x^2+y^2))/sqrt(x^2+y^2)',[-6*pi,6*pi])
%    ezcontourf('x*exp(-x^2 - y^2)')
%    ezcontourf('-3*z/(1 + t^2 - z^2)',[-4,4],120)
%    ezcontourf('sin(u)*sin(v)',[-2*pi,2*pi])
%
%    h = @(x,y)x.*y - x;
%    ezcontourf(h)
%    ezcontourf(@peaks)
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZSURF, EZMESH,
%            EZSURFC, EZMESHC, CONTOURF.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2004/04/10 23:31:45 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

if ~isempty(cax)
    h = ezgraph3(cax,'contourf',args{:});
else
    h = ezgraph3('contourf',args{:});
end

cax = ancestor(h(1),'axes');
rotate3d(cax,'off');

if nargout > 0
    hh = h;
end