function y = update(h)
% UPDATE  Update boundedline based on axes limits.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.15.2.2 $  $Date: 2004/02/01 21:38:21 $


hAxes = get(h,'parent');

% Compute a step size that results in n points, n determined
% from Granularity, being plotted.  Then build an array of these points.
gran = h.Granularity;
xlims = get(hAxes,'xlim');
h.XLim = xlims;
x = linspace(xlims(2), xlims(1), gran)';

% Add real x values, if known, so interpolants will pass through data
ua = h.UserArgs;
if iscell(ua) && length(ua)>=1
   dshandle = ua{2};
   if ~isempty(dshandle) && ishandle(dshandle)
      if isa(h.fit,'cftool.fit')
         xdata = getxdata(dshandle,h.fit.outlier);
      else
         xdata = getxdata(dshandle,'');
      end
      x = sort([x(:); xdata(:)]);
   end
end

if ~isempty(h.Function)

   % If requested, try to compute confidence bounds
   ci = [];
   y = [];
   ws = warning('off', 'all');
   if isequal(h.ShowBounds,'on') && h.dfe>0
      try
         [ci,y] = predint(h.Function, x, h.ConfLevel);
      catch
      end
   end
   
   % Compute predictions if the previous code didn't yield any
   if isempty(y) && ~isempty(x)
      y = feval(h.Function, x);
   end
   warning(ws);

   if isempty(ci)
      set(h.BoundLines(1),'XData',[],'YData',[]);
      set(h.BoundLines(2),'XData',[],'YData',[]);
      h.YLim = [min(y) max(y)];
   else
      set(h.BoundLines(1),'XData',x,'YData',ci(:,1));
      set(h.BoundLines(2),'XData',x,'YData',ci(:,2));
      h.YLim = [min(min(y),min(ci(:))) max(max(y),max(ci(:)))];
   end

   % Set the XData to be the points evenly spaced
   % between the X Limits.
   % Set the YData to be the result of the function
   % applied to the XData.
   set(h, 'xdata', x, 'ydata', y);
end

% Opaque array methods need to know how many left-hand-sides were
% requested, so we must always return one argument.
y = [];


