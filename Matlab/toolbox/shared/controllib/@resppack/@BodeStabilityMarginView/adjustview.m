function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might interfer  
%  with limit picking.
%
%  ADJUSTVIEW(cVIEW,cDATA'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:42 $
if ~isempty(cv.MagPoints) && strcmpi(Event,'postlim')
   rData = cd.Parent;
   AxGrid = cv.AxesGrid;
   ZerodB = unitconv(1,'abs',AxGrid.YUnits{1});
   Pi = unitconv(pi,'rad',AxGrid.YUnits{2});
   % Convert Response Data Frequency from Data Units to Axis Grid XUnits
   Freq = unitconv(rData.Frequency,rData.FreqUnits,AxGrid.XUnits);
   ind = find(Freq ~= 0);
   Phase = unitconv(rData.Phase,rData.PhaseUnits,AxGrid.YUnits{2});
   if strcmp(cv.Parent.UnwrapPhase, 'off')
      Phase = mod(Phase+Pi,2*Pi) - Pi;
   end
   
   % Clear all data
   set(double([cv.MagLines;cv.MagCrossLines;cv.PhaseLines;cv.PhaseCrossLines]),...
      'xdata',[NaN NaN], 'ydata', [NaN NaN])
   set(double([cv.MagPoints;cv.PhasePoints]),'xdata',NaN, 'ydata', NaN)
   
   % Axis limits
   XlimG = get(cv.MagPoints(1).Parent,'Xlim');
   XlimG = [max(Freq(1),XlimG(1)),min(Freq(end),XlimG(2))];
   XlimP = get(cv.PhasePoints(1).Parent,'Xlim');
   XlimP = [max(Freq(1),XlimP(1)),min(Freq(end),XlimP(2))];

   % Gain margin dots in scope
   GMFrequency = unitconv(cd.GMFrequency,'rad/s',AxGrid.XUnits);
   isValidGM = (isfinite(cd.GainMargin) & cd.GainMargin~=0);
   idxGM = find(GMFrequency>=XlimG(1) & GMFrequency<=XlimG(2) & isValidGM);
   nGM = length(idxGM);
   if nGM>0
      XDot = GMFrequency(idxGM);
      % Convert Gain Margin from abs to Axis Grid YUnits{1}
      YDot = unitconv(1./cd.GainMargin(idxGM),'abs', AxGrid.YUnits{1});
      for ct=1:nGM
         set(double(cv.MagPoints(ct)),'XData',XDot(ct),'YData',YDot(ct),...
            'MarkerFaceColor',cv.MagPoints(1).Color,'UserData',idxGM(ct))
         set(double(cv.MagLines(ct)),...
            'XData',[XDot(ct) XDot(ct)],'YData',[ZerodB YDot(ct)]) 
      end
   end
   
   % Remaining gain margins displayed as open circles (with data marker summary
   % of all margins left out of the display)
   idxL = find(GMFrequency<XlimG(1) & isValidGM);
   idxR = find(GMFrequency>XlimG(2) & isValidGM);
   isne = [~isempty(idxL) ~isempty(idxR)];
   if any(isne)
      XDot = XlimG;
      Mag = unitconv(rData.Magnitude,rData.MagUnits,AxGrid.YUnits{1});
      if strcmp(AxGrid.XScale,'log')
         YDot = interp1(log(Freq(ind)),Mag(ind),log(XDot));  
      else
         YDot = interp1(Freq,Mag,XDot);  
      end 
      if isne(1)
         set(double(cv.MagPoints(nGM+1)),'XData',XDot(1),'YData',YDot(1),...
            'MarkerFaceColor','none','UserData',idxL)
      end
      if isne(2)
         set(double(cv.MagPoints(nGM+isne(1)+1)),'XData',XDot(2),'YData',YDot(2),...
            'MarkerFaceColor','none','UserData',idxR)
      end
   end
   
   % Phase margin dots in scope
   PMFrequency = unitconv(cd.PMFrequency,'rad/s',AxGrid.XUnits);
   isValidPM = isfinite(cd.PhaseMargin);
   idxPM = find(PMFrequency>=XlimP(1) & PMFrequency<=XlimP(2) & isValidPM);
   nPM = length(idxPM);
   if nPM>0
      XDot = PMFrequency(idxPM);
      Pm = unitconv(cd.PhaseMargin(idxPM),'deg',AxGrid.YUnits{2});
      if strcmp(AxGrid.XScale,'log')
         PhaseWcp = interp1(log(Freq(ind)),Phase(ind),log(XDot));  
      else
         PhaseWcp = interp1(Freq,Phase,XDot);  
      end 
      PmLine = Pi * round((PhaseWcp-Pm)/Pi);
      YDot = PmLine + Pm;
      for ct=1:nPM
         set(double(cv.PhasePoints(ct)),'XData',XDot(ct),'YData',YDot(ct),...
            'MarkerFaceColor',cv.PhasePoints(1).Color,'UserData',idxPM(ct))
         set(cv.PhaseLines(ct),...
            'XData',[XDot(ct) XDot(ct)],'YData',[PmLine(ct) YDot(ct)]) 
         set(double(cv.PhaseCrossLines(ct)),...
            'XData',XlimP,'YData',[PmLine(ct) PmLine(ct)])
      end
   end
   
   % Remaining gain margins displayed as open circles (with data marker summary
   % of all margins left out of the display)
   idxL = find(PMFrequency<XlimP(1) & isValidPM);
   idxR = find(PMFrequency>XlimP(2) & isValidPM);
   isne = [~isempty(idxL) ~isempty(idxR)];
   XDot = XlimP;
   if any(isne)
      if strcmp(AxGrid.XScale,'log')
         YDot = interp1(log(Freq(ind)),Phase(ind),log(XDot));  
      else
         YDot = interp1(Freq,Phase,XDot);  
      end 
      if isne(1)
         set(double(cv.PhasePoints(nPM+1)),'XData',XDot(1),'YData',YDot(1),...
            'MarkerFaceColor','none','UserData',idxL)
      end
      if isne(2)
         set(double(cv.PhasePoints(nPM+isne(1)+1)),'XData',XDot(2),'YData',YDot(2),...
            'MarkerFaceColor','none','UserData',idxR)
      end
   end

   % 0dB line
   if nGM>0 || nPM>0
      set(double(cv.MagCrossLines(1)),'XData',XlimG,'YData',[ZerodB ZerodB])
   end
   
end
