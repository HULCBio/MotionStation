function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'prelim') hides HG objects that might interfer with 
%  limit picking.
%
%  ADJUSTVIEW(VIEW,DATA,'critical') prepares view for zooming in around the
%  critical point (handled by NYQUISTPLOT:UPDATELIMS)
%
%  ADJUSTVIEW(VIEW,DATA,'postlimit') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:51 $

if ~NormalRefresh
   return
end

switch Event
case 'prelim'
   % Hide arrows
   set(double([View.PosArrows(:);View.NegArrows(:)]),'XData',[],'YData',[])
   % Frequency focus
   if Data.SoftFocus
      % Quasi integrator or pure gain: Show only data near (-1,0)
      for ct=1:prod(size(View.PosCurves))
         gap = 1+Data.Response(:,ct);
         curves = [View.PosCurves(ct),View.NegCurves(ct)];
         if ~any(diff(gap))
            % Pure gain
            set(double(curves),'XData',NaN,'YData',NaN)
         else
            % Include data within radius 10 or 1.5 x min. distance to (-1,0)
            distcp = abs(gap);
            LocalClipBranch(curves,(distcp < max(10,1.5*min(distcp))))
         end
      end
   else
      InFocus = (Data.Frequency>=Data.Focus(1) & Data.Frequency<=Data.Focus(2));
      for ct=1:prod(size(View.PosCurves))
         LocalClipBranch([View.PosCurves(ct),View.NegCurves(ct)],InFocus)
      end
   end   
   
case 'critical'
   % Zoom in region around critical point
   % Hide arrows
   set(double([View.PosArrows(:);View.NegArrows(:)]),'XData',[],'YData',[])
   % Hide data outside ball of radius max(4,1.5 x min. distance to (-1,0))
   for ct=1:prod(size(View.PosCurves))
      gap = 1+Data.Response(:,ct);
      curves = [View.PosCurves(ct),View.NegCurves(ct)];
      if ~any(diff(gap))
         % Pure gain
         set(double(curves),'XData',NaN,'YData',NaN)
      else
         distcp = abs(gap);
         LocalClipBranch(curves,(distcp < max(4,1.5*min(distcp))))
      end
   end
   
case 'postlim'
   % Restore nyquist curves to their full extent
   draw(View,Data)
   % Position and adjust arrows
   drawarrow(View)
   
end

%---------------------------- Local Functions --------------------

function LocalClipBranch(curves,Include)

for h=curves
   xdata = get(h,'XData');
   ydata = get(h,'YData');
   if length(xdata)==length(Include)  % watch for NaN
      idx = find(Include);
      set(double(h),'XData',xdata(idx),'YData',ydata(idx))
   end
end
