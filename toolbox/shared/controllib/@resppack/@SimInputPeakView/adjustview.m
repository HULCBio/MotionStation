function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might interfer  
%  with limit picking.
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlimit') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:19:31 $

% RE: Each input wave is repeated Ny times (once per output channel)

if strcmp(Event,'postlim')
   % Position dot and lines given finalized axes limits
   ax = cv.Points(1).Parent;
   Xlim = get(ax,'Xlim');
   rData = cd.Parent;  % parent response's data
   % Adjust dot position based on the X limits
   XDot = cd.Time(1);
   YDot = cd.PeakResponse(1);
   InScope = (strcmp(cv.AxesGrid.XLimMode{1},'manual') | (XDot>=Xlim(1) & XDot<=Xlim(2)));
   if InScope
      Color = get(cv.Points(1),'Color');
   else
      if ~isnan(YDot) & ~isempty(rData.Amplitude)
          XDot = max(Xlim(1),min(Xlim(2),XDot));
          YDot = interp1(rData.Time,rData.Amplitude,XDot);
      end
      Color = get(ax,'Color');  % open circle
      set(double([cv.HLines;cv.VLines]),'XData',[NaN NaN])     
   end
   
   % Position dot and lines given finalized axes limits
   YNorm = strcmp(cv.AxesGrid.YNormalization,'on');
   for ct=1:length(cv.Points)
      % Take normalization into account
      if YNorm & ~isnan(YDot)
         Y = normalize(rData,YDot,Xlim,ct);
      else
         Y = YDot;
      end
      Ylim = get(cv.Points(ct).Parent,'Ylim');
      
      % Position object
      set(double(cv.Points(ct)),'XData',XDot,'YData',Y,'MarkerFaceColor',Color)
      if InScope
         if  ~isnan(YDot)
             set(double(cv.HLines(ct)),'XData',[rData.Time(1),XDot],'YData',[Y,Y])     
             set(double(cv.VLines(ct)),'XData',[XDot XDot],'YData',[Ylim(1) Y])
         else
             set(double([cv.HLines;cv.VLines]),'XData',[NaN NaN])  
         end
      end 
   end
end