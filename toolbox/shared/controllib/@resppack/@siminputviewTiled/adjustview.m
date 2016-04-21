function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:42 $

if strcmp(Event,'postlim') & strcmp(View.AxesGrid.YNormalization,'on')
   % Draw normalized data once X limits are finalized
   switch View.Style
   case 'line'
      if ~isempty(Data.Amplitude)
          Xlims = get(View.Curves(1).Parent,'Xlim');
          YData = normalize(Data,Data.Amplitude,Xlims);
          set(double(View.Curves),'XData',Data.Time,'YData',YData)
      else
          set(double(View.Curves),'XData',[],'YData',[])
      end
   case 'stairs'
      if ~isempty(Data.Amplitude) 
          Xlims = get(View.Curves(1).Parent,'Xlim');
          [T,Y] = stairs(Data.Time,Data.Amplitude);
          Y = normalize(Data,Y,Xlims);
          set(double(View.Curves),'XData',T,'YData',Y);
      else
          set(double(View.Curves),'XData',[],'YData',[])
      end
   end
end
