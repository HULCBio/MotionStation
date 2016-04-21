function h = refline(slope,intercept)
%REFLINE Add a reference line to a plot.
%   REFLINE(SLOPE,INTERCEPT) adds a line with the given SLOPE and
%   INTERCEPT to the current figure.
%
%   REFLINE(SLOPE) where SLOPE is a two element vector adds the line
%        y = SLOPE(2) + SLOPE(1)*x 
%   to the figure. (See POLYFIT.)
%
%   H = REFLINE(SLOPE,INTERCEPT) returns the handle to the line object
%   in H.
%
%   REFLINE with no input arguments superimposes the least squares line on 
%   each line object in the current figure (Except LineStyles '-','--','.-'.)
%
%   See also POLYFIT, POLYVAL.   

%   B.A. Jones 2-2-95
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.1 $  $Date: 2004/01/24 09:36:49 $

if nargin == 0
  lh = findobj(get(gca,'Children'),'Type','line');
  if nargout == 1, 
     h = [];
  end
  count = 0;
  for k = 1:length(lh)
      xdat = get(lh(k),'Xdata');
      ydat = get(lh(k),'Ydata');
      datacolor = get(lh(k),'Color');
      style = get(lh(k),'LineStyle');
      if ~strcmp(style,'-') & ~strcmp(style,'--') & ~strcmp(style,'-.')
         count = count + 1;
         beta = polyfit(xdat,ydat,1);
         newline = refline(beta);
         set(newline,'Color',datacolor);
         if nargout == 1
            h(count) = newline;    
         end
      end
   end
   if count == 0
      disp('No allowed line types found. Nothing done.');
   end
   return;
end

if nargin == 1
   if max(size(slope)) == 2
      intercept=slope(2);
      slope = slope(1);
   else
      intercept = 0;
   end
end

xlimits = get(gca,'Xlim');
ylimits = get(gca,'Ylim');

np = get(gcf,'NextPlot');
set(gcf,'NextPlot','add');

xdat = xlimits;
ydat = intercept + slope.*xdat;
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
