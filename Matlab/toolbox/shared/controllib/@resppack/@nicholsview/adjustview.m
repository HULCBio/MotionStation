function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'prelim') hides HG objects that might interfer with 
%  limit picking.
%
%  ADJUSTVIEW(VIEW,DATA,'postlimit') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:29 $

switch Event
   case 'prelim'
      % Frequency focus
      if Data.SoftFocus
         % Quasi integrator or pure gain
         for ct = 1:prod(size(View.Curves))
            % Make sure there is always some data to show if data is outside
            % the +/-40 dB range used to show the integrators.
            Magnitude = Data.Magnitude(:,ct);
            InFocus = Magnitude >= 0.01 * min(1,max(Magnitude)) & ...
               Magnitude <= 100  * max(1,min(Magnitude));
            LocalClip(View.Curves(ct), InFocus)
         end
      else
         InFocus = Data.Frequency >= Data.Focus(1) & ...
            Data.Frequency <= Data.Focus(2);
         for ct = 1:prod(size(View.Curves))
            LocalClip(View.Curves(ct), InFocus)
         end
      end   
      
   case 'postlim'
      % Restore nichols curves to their full extent
      draw(View, Data)
end


% --------------------------------------------------------------------------- %
% Local Functions
% --------------------------------------------------------------------------- %
function LocalClip(Curves, Include)
for h = Curves
   xdata = get(h, 'XData');
   ydata = get(h, 'YData');
   if length(ydata) == length(Include)  % watch for NaN
      idx = find(Include);
      set(double(h),'XData', xdata(idx), 'YData', ydata(idx))
   end
end
