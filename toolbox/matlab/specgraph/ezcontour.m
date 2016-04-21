function hh = ezcontour(varargin)
%EZCONTOUR Easy to use contour plotter.
%   EZCONTOUR(f) plots the contour lines of f(x,y) using CONTOUR where
%   f is a string or symbolic expression representing a mathematical
%   function of two variables, say 'x' and 'y'.  The function f is 
%   plotted over the default domain -2*pi < x < 2*pi, -2*pi < y < 2*pi.
%   The computational grid is chosen according to the amount
%   of variation that occurs.
%
%   EZCONTOUR(f,DOMAIN) plots f over the specified DOMAIN instead of the
%   default DOMAIN = [-2*pi,2*pi,-2*pi,2*pi].  The DOMAIN can be the
%   4-by-1 vector [xmin,xmax,ymin,ymax] or the 2-by-1 vector [a,b] (to
%   plot over a < x < b, a < y < b).
%
%   If f is a function of the variables u and v (rather than x and y),
%   then the domain endpoints umin, umax, vmin, and vmax are sorted
%   alphabetically.  Thus, EZCONTOUR('u^2 - v^3',[0,1],[3,6]) plots the
%   contour lines for u^2 - v^3 over 0 < u < 1, 3 < v < 6.
%
%   EZCONTOUR(...,N) plots f over the default domain using an N-by-N grid.
%   The default value for N is 60.
%
%   EZCONTOUR(AX,...) plots into AX instead of GCA.
%
%   H = EZCONTOUR(...) returns handles to contour objects in H.
%
%   Examples:
%   f is typically an expression, but it can also be specified
%   using @ or an inline function:
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezcontour(f,[-pi,pi])
%    ezcontour('sin(sqrt(x^2+y^2))/sqrt(x^2+y^2)',[-6*pi,6*pi])
%    ezcontour('x*exp(-x^2 - y^2)')
%    ezcontour('-3*z/(1 + t^2 - z^2)',[-4,4],120)
%    ezcontour('sin(u)*sin(v)',[-2*pi,2*pi])
%
%    h = @(x,y)x.*y - x;
%    ezcontour(h)
%    ezcontour(@peaks)
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOURF, EZSURF, EZMESH,
%            EZSURFC, EZMESHC, CONTOUR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2004/04/10 23:31:44 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

if ~isempty(cax)
    h = ezgraph3(cax,'contour',args{:});
else
    h = ezgraph3('contour',args{:});
end

cax = ancestor(h(1),'axes');
rotate3d(cax,'off');

if nargout > 0
    hh = h;
end