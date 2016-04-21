function updatelim(h);
%UPDATELIM Update plotting limits for this data set

%   $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:38 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Get limits from plotted points
h.xlim = [min(h.plotx) max(h.plotx)];
ylim = [min(h.ploty) max(h.ploty)];

% Consider bounds as well
if ~isempty(h) && ishandle(h)
   ydata = get(h.boundline,'YData');
   if ~isempty(ydata)
      ylim = [min(ylim(1), min(ydata)),   max(ylim(2),max(ydata))];
   end
end

h.ylim = ylim;
