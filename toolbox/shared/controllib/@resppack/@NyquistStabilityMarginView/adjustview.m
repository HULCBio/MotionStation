function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might interfer  
%  with limit picking.
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:13 $
if ~isempty(cv.MagPoints) && strcmp(Event,'postlim')
   AxGrid = cv.AxesGrid;
   Xlim = get(cv.MagPoints(1).Parent,'Xlim'); 
   
   % Clear all data
   set(double([cv.MagLines;cv.PhaseLines]),'Xdata',[NaN NaN],'Ydata',[NaN NaN])
   set(double([cv.MagPoints;cv.PhasePoints]),'Xdata',NaN,'Ydata',NaN)
   
   % Locate phase crossings for gain margin dots
   idxValid = find(isfinite(cd.GainMargin) & cd.GainMargin~=0);
   XDot = -1./cd.GainMargin(idxValid);
   
   % Gain margin markers in focus
   idxGM = find(XDot>=Xlim(1) & XDot<=Xlim(2));
   nGM = length(idxGM);
   for ct=1:nGM
      X = XDot(idxGM(ct));
      set(double(cv.MagPoints(ct)),'XData',X,'YData',0,...
         'MarkerFaceColor',cv.MagPoints(1).Color,'UserData',idxValid(idxGM(ct)))
      set(double(cv.MagLines(ct)),'XData',[-1 X],'YData',[0 0])
   end
   
   % Gain margin markers out of focus
   idxL = find(XDot<Xlim(1));
   if ~isempty(idxL)
      set(double(cv.MagPoints(nGM+1)),'XData',Xlim(1),'YData',0,...
         'MarkerFaceColor','none','UserData',idxValid(idxL))
      nGM = nGM+1;
   end
   idxR = find(XDot>Xlim(2));
   if ~isempty(idxR)
      set(double(cv.MagPoints(nGM+1)),'XData',Xlim(2),'YData',0,...
         'MarkerFaceColor','none','UserData',idxValid(idxR))
   end
   
   % Phase margin markers
   idxPM = find(isfinite(cd.PhaseMargin));
   Pm = (pi/180) * cd.PhaseMargin(idxPM); % in rad
   for ct=1:length(Pm)
      XDot = cos(pi+Pm(ct));
      YDot = sin(pi+Pm(ct));
      set(double(cv.PhasePoints(ct)),...
         'XData',XDot,'YData',YDot,'UserData',idxPM(ct))    
      set(double(cv.PhaseLines(ct)),'XData',[0 XDot],'YData',[0 YDot])
   end    
end
