function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:53 $

if strcmp(Event,'postlim') & strcmp(View.AxesGrid.YNormalization,'on')
   % Draw normalized data once X limits are finalized
   switch View.Style
   case 'line'
      for ct=1:prod(size(View.Curves))
         Xlims = get(View.Curves(ct).Parent,'Xlim');
         YData = normalize(Data,Data.Amplitude(:,ct),Xlims,ct);
         if ~isempty(Data.Amplitude)
             set(double(View.Curves(ct)),'XData',Data.Time,'YData',YData)
         else
             set(double(View.Curves(ct)),'XData',[],'YData',[])
         end
      end 
   case 'stairs'
      for ct=1:prod(size(View.Curves))
         Xlims = get(View.Curves(ct).Parent,'Xlim');
         [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
         Y = normalize(Data,Y,Xlims,ct);
         if ~isempty(Data.Amplitude)
             set(double(View.Curves(ct)),'XData',T,'YData',Y);
         else
             set(double(View.Curves(ct)),'XData',[],'YData',[])
         end   
      end
   end
end

