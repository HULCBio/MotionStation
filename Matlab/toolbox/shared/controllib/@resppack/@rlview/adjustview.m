function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'prelim') clips unbounded branches of the locus
%  using the XFocus and YFocus info in DATA before invoking the limit
%  picker.
%
%  ADJUSTVIEW(VIEW,DATA,'postlimit') restores the full branch extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $Date: 2004/04/11 00:23:01 $

switch Event
case 'prelim'
   % Clip portion of branches extending beyond XFocus and YFocus
   for b=View.Locus'
      xdata = get(b,'XData');
      ydata = get(b,'YData');
      idx = (xdata>=Data.XFocus(1) & xdata<=Data.XFocus(2) & ...
         ydata>=Data.YFocus(1) & ydata<=Data.YFocus(2));
      set(double(b),'Xdata',xdata(idx),'YData',ydata(idx))
   end
   
case 'postlim'
   % Restore branches to their full extent
   draw(View,Data)
end