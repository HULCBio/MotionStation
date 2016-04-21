function ezsurfc(f,varargin)
%EZSURFC General surface-contour plotter.
%   EZSURFC(f) plots a graph of f(x,y) using SURFC where f is a string
%   or a symbolic expression representing a mathematical function
%   involving two symbolic variables, say 'x' and 'y'.  The function
%   f is plotted over the default domain -2*pi < x < 2*pi, -2*pi < y <
%   2*pi.  The computational grid is chosen according to the amount of
%   variation that occurs.
% 
%   EZSURFC(f,DOMAIN) plots f over the specified DOMAIN instead of the
%   default DOMAIN = [-2*pi,2*pi,-2*pi,2*pi].  The DOMAIN can be the
%   4-by-1 vector [xmin,xmax,ymin,ymax] or the 2-by-1 vector [a,b] (to
%   plot over a < x < b, a < y < b).
%
%   If f is a function of the variables u and v (rather than x and
%   y), then the domain endpoints umin, umax, vmin, and vmax are
%   sorted alphabetically.  Thus, EZSURFC(u^2 - v^3,[0,1,3,6]) plots
%   u^2 - v^3 over 0 < u < 1, 3 < v < 6.
%
%   EZSURFC(x,y,z) plots the parametric surface x = x(s,t), y = y(s,t),
%   and z = z(s,t) over the square -2*pi < s < 2*pi and -2*pi < t < 2*pi.
%
%   EZSURFC(x,y,z,[smin,smax,tmin,tmax]) or EZSURFC(x,y,z,[a,b]) uses the
%   specified domain.
%
%   EZSURFC(...,fig) plots f over the default domain in the figure window
%   fig.
%
%   EZSURFC(...,'circ') plots f over a disk centered on the domain.
%
%   Examples:
%    syms x y u v s t
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezsurfc(f,[-pi,pi])
%    ezsurfc(x*exp(-x^2 - y^2))
%    ezsurfc(sin(u)*sin(v))
%    ezsurfc(imag(atan(x + i*y)),[-2,2])
%    ezsurfc(y/(1 + x^2 + y^2),[-5,5,-2*pi,2*pi])
%
%    ezsurfc((s-sin(s))*cos(t),(1-cos(s))*sin(t),s,[-2*pi,2*pi])
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%            EZSURFC, EZMESHC, SURFC.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 03:12:38 $

F = makeinline(f);
if (length(varargin) >= 2) & (isa(varargin{1},'sym') | isa(varargin{2},'sym'))
   y = makeinline(varargin{1}); z = makeinline(varargin{2});
   ezsurfc(F,y,z,varargin{3:end});
else
   ezsurfc(F,varargin{:});
end

%------------------------
function F = makeinline(f)
% MAKEINLINE Makes an inline function out of the input sym f.

% Find all variables in f except 'pi'.
vars = findsym(f);
% Deblank vars.
vars(findstr(vars,' ')) = [];
% Find the commas in the string list vars.
ind = findstr(vars,',');
% Place the symbols inbetween the commas into a cell array V.
nvars = length(ind) + 1;
if nvars == 1
   V{1} = vars;
else
   V{1} = vars(1:ind(1)-1); V{nvars} = vars(ind(nvars-1)+1:end);
   for j = 2:nvars-1
      V{j} = vars(ind(j-1)+1:ind(j)-1);
   end
end

F = inline(f.s,V{:});
