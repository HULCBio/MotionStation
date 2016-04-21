function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:50 $

% RE: Assumes parent waveform contains valid data
if strcmp(Event,'postlim') 
   rData = cd.Parent;
   [s1,s2] = size(cv.Points);
   YNorm = strcmp(cv.AxesGrid.YNormalization,'on');
   Xauto = strcmp(cv.AxesGrid.XlimMode,'auto');
   % Position dot and lines given finalized axes limits
   for ct=1:s1*s2
      % Parent axes and limits
      ax = cv.Points(ct).Parent;
      Xlim = get(ax,'Xlim');
      % Dot position
      XDot = cd.THigh(ct);
      YDot = cd.Amplitude(ct);
      % If rise time is above the upper X limit, then interpolate to find the closest point to be displayed
      if Xauto(ceil(ct/s1)) & XDot>Xlim(2)
         XDot = 0.9999*Xlim(2);
         Color = get(ax,'Color');
      else
         Color = get(cv.Points(ct),'Color');
      end
      % Take normalization into account
      if YNorm & isfinite(YDot)
         YDot = normalize(rData,YDot,Xlim,ct);
      end
      
      % Position objects
      set(double(cv.Points(ct)),'XData',XDot,'YData',YDot,'MarkerFaceColor',Color)
      if isfinite(XDot)
         Ylim = get(ax,'Ylim');
         set(double(cv.LowerVLines(ct)),...
            'XData',cd.TLow([ct,ct]),'YData',[Ylim(1) YDot],'Zdata',[-10 -10]) 
         set(double(cv.UpperVLines(ct)),...
            'XData',cd.THigh([ct,ct]),'YData',[Ylim(1) YDot],'Zdata',[-10 -10])  
         set(double(cv.HLines(ct)),'XData',...
            [Xlim(1) XDot],'YData',[YDot YDot],'Zdata',[-10 -10])
      else
         set(double([cv.LowerVLines(ct); cv.UpperVLines(ct); cv.HLines(ct)]),...
            'XData',[],'YData',[],'ZData',[])
      end
   end
end