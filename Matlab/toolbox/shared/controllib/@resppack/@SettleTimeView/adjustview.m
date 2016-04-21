function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:21 $

% RE: Assumes parent waveform contains valid data
if strcmp(Event,'postlim')
   rData = cd.Parent;
   YNorm = strcmp(cv.AxesGrid.YNormalization,'on');
   Xauto = strcmp(cv.AxesGrid.XlimMode,'auto');
   % Position dot and lines given finalized axes limits
   [s1,s2] = size(cv.Points);
   for ct=1:s1*s2
      % Parent axes and limits
      ax = cv.Points(ct).Parent;
      Xlim = get(ax,'Xlim');
      % Adjust dot position based on the X limits
      XDot = cd.Time(ct);
      YDot = cd.YSettle(ct);
      OutScope = (Xauto(ceil(ct/s1)) && (XDot>Xlim(2)));
      if OutScope
         XDot = 0.9999*Xlim(2);
         YDot = interp1(rData.Time,rData.Amplitude(:,ct),XDot);
         Color = get(ax,'Color');
      else
         Color = get(cv.Points(ct),'Color');
      end
      
      if cd.YSettle(ct) < cd.DCGain(ct)
         YUpper = cd.YSettle(ct);
         YLower = 2*cd.DCGain(ct) - cd.YSettle(ct);
      else
         YUpper = 2*cd.DCGain(ct) - cd.YSettle(ct);
         YLower = cd.YSettle(ct);
      end
      % Take normalization into account
      if YNorm & isfinite(YDot)
         YDot = normalize(rData,YDot,Xlim,ct);
         YUpper = normalize(rData,YUpper,Xlim,ct);
         YLower = normalize(rData,YLower,Xlim,ct);
      end
      
      % Position objects
      set(double(cv.Points(ct)),'XData',XDot,'YData',YDot,'MarkerFaceColor',Color)
      if OutScope | isnan(XDot)
         set(double([cv.VLines(ct);cv.UpperHLines(ct);cv.LowerHLines(ct)]),...
            'XData',[],'YData',[],'Zdata',[])
      else
         Ylim = get(ax,'Ylim');
         set(double(cv.VLines(ct)),'XData',[XDot XDot],'YData',[Ylim(1), YDot])
         if NormalRefresh
            set(double(cv.UpperHLines(ct)),...
               'XData',Xlim,'YData',[YUpper,YUpper],'ZData',[-10 -10])     
            set(double(cv.LowerHLines(ct)),...
               'XData',Xlim,'YData',[YLower,YLower],'ZData',[-10 -10]) 
         else
            set(double([cv.UpperHLines(ct);cv.LowerHLines(ct)]),...
               'XData',[],'YData',[],'Zdata',[])
         end
      end
   end
end