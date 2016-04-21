function adjustview(View,Data,Event,NormalRefresh)
% Adjusts view prior to and after picking the axes limits. 

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:37 $
if strcmp(Event,'postlim') && strcmp(View.AxesGrid.YNormalization,'on')
   % Draw normalized data once X limits are finalized
   if isempty(Data.Amplitude)
      set(double(View.Curves),'XData',[],'YData',[])
   else
      Nu = size(Data.Amplitude,2);
      Xlims = get(View.Curves(1).Parent,'Xlim');
      switch View.Style
         case 'line'
            YData = normalize(Data,Data.Amplitude,Xlims);
         case 'stairs'
            [T,Y] = stairs(Data.Time,Data.Amplitude);
            YData = normalize(Data,Y,Xlims);
      end
      for ct=1:Nu
         set(double(View.Curves(ct)),'XData',Data.Time,'YData',YData(:,ct))
      end
   end
end
