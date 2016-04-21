
function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might interfer  
%  with limit picking.
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): J. Glass, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:30 $

% RE: Assumes parent waveform contains valid data
if strcmp(Event,'postlim')
   % Position dot and lines given finalized axes limits
   YNorm = strcmp(cv.AxesGrid.YNormalization,'on');
   Xauto = strcmp(cv.AxesGrid.XlimMode,'auto');
   rData = cd.Parent; % parent response's data
   [s1,s2] = size(cv.Points);
   for ct=1:s1*s2
      % Parent axes and limits
      ax = cv.Points(ct).Parent;
      Xlim = get(ax,'Xlim');
      Ylim = get(ax,'Ylim');
      
      % Adjust dot position based on finalized X limits
      XDot = cd.Time(ct);
      YDot = cd.PeakResponse(ct);
      OutScope = (Xauto(ceil(ct/s1)) & (XDot<Xlim(1) | XDot>Xlim(2)));
      if OutScope
          % Peak reached outside auto limits: display open circle 
          % at x=Xlim(1) or x=Xlim(2)
          XDot = max(Xlim(1),min(Xlim(2),XDot));
          if ~isempty(rData.Time) & ~isempty(rData.Amplitude)
              YDot = interp1(rData.Time,rData.Amplitude(:,ct),XDot);
          else
              XDot = NaN;
              YDot = NaN;
          end
          Color = get(ax,'Color');   % open circle         
      else
          Color = get(cv.Points(ct),'Color');
      end
      
      % Take normalization into account
      if YNorm & isfinite(YDot) & ~isempty(rData.Time) & ~isempty(rData.Amplitude)
          YDot = normalize(rData,YDot,Xlim,ct);
      end
      
      % Position object
      set(double(cv.Points(ct)),'XData',XDot,'YData',YDot,'MarkerFaceColor',Color)
      if OutScope | isnan(XDot)
          % Hide lines if dot is an open circle
          set(double([cv.HLines(ct),cv.VLines(ct)]),'XData',[],'YData',[],'Zdata',[])     
      else
          set(double(cv.HLines(ct)),...
             'XData',[rData.Time(1),XDot],'YData',[YDot,YDot],'Zdata',[-10 -10])     
          set(double(cv.VLines(ct)),...
             'XData',[XDot XDot],'YData',[Ylim(1) YDot],'Zdata',[-10 -10])
      end
  end
end