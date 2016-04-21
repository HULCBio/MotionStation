function h = refcurve(p)
%REFCURVE Add a reference curve (polynomial) to a plot.
%   REFCURVE(P) adds a line with the given polynomial coefficients 
%   to the current figure.
%   H = REFCURVE(P) returns the handle to the line object
%   in H.
%   REFCURVE with no arguments plots the function Y = 0.
%   Example: 
%       y = p(1)*x^d + p(2)*x^(d-1) + ... + p(d)*x + p(d+1)
%       Shows a polynomial of degree, d.
%       Note that p(1) goes with the highest order term.
%
%   See also POLYFIT, POLYVAL.   

%   B.A. Jones 2-3-95
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.1 $  $Date: 2004/01/24 09:36:48 $

if nargin == 0
   p = zeros(2,1);
end

xlimits = get(gca,'Xlim');
ylimits = get(gca,'Ylim');

np = get(gcf,'NextPlot');
set(gcf,'NextPlot','add');

xdat = linspace(xlimits(1),xlimits(2),100);
ydat = polyval(p,xdat);
maxy = max(ydat);
miny = min(ydat);

if maxy > ylimits(2)
  if miny < ylimits(1)
     set(gca,'YLim',[miny maxy]);
  else
     set(gca,'YLim',[ylimits(1) maxy]);
  end
else
  if miny < ylimits(1)
     set(gca,'YLim',[miny ylimits(2)]);
  end
end

if nargout == 1
   h = line(xdat,ydat);
   set(h,'LineStyle','-');
else
   hh = line(xdat,ydat);
   set(hh,'LineStyle','-');
end

set(gcf,'NextPlot',np);
