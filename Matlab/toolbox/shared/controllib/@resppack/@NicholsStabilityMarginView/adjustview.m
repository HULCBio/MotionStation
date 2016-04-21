function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 

%  Author(s): John Glass, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:03 $

if ~isempty(cv.MagPoints) && strcmp(Event,'postlim')
   AxGrid = cv.AxesGrid;
   rData = cd.Parent;
   ZerodB = unitconv(1,'abs',AxGrid.YUnits);
   Pi = unitconv(pi,'rad',AxGrid.XUnits);
   % Current limits
   ax = cv.MagPoints(1).Parent;
   Xlim = get(ax,'Xlim'); 
   Ylim = get(ax,'Ylim');
   LOffset = 0;   LowShift = 0;
   ROffset = 0;   HighShift = 0;
   
   % Clear all data
   set(double([cv.MagLines;cv.MagCrossLines;cv.PhaseLines;cv.PhaseCrossLines]),...
      'Xdata',[NaN NaN],'Ydata',[NaN NaN])
   set(double([cv.MagPoints;cv.PhasePoints]),'Xdata',NaN,'Ydata',NaN)
   
   % Convert Magnitude Data from Response Data Units to Axis Grid YUnits
   Mag = unitconv(rData.Magnitude, rData.MagUnits, AxGrid.YUnits);
   % Convert Phase Data from Response Data Units to Axis Grid XUnits
   Phase = unitconv(rData.Phase, rData.PhaseUnits, AxGrid.XUnits);
   if strcmp(cv.Parent.UnwrapPhase, 'off')
      Phase = mod(Phase+Pi,2*Pi) - Pi;
   end
   % Convert Frequency Data from Response Data Units to rad/sec
   Freq = unitconv(rData.Frequency,rData.FreqUnits,'rad/sec');
   nf = length(Freq);
   if nf<2
      return
   end
   
   % Locate phase crossings for gain margin dots
   %GMFrequency = max(Freq(1),min(Freq(end),cd.GMFrequency));
   isValidGM = (isfinite(cd.GainMargin) & cd.GainMargin~=0);
   GMFrequency = cd.GMFrequency;
   XDot = reshape(interp1(Freq,Phase,GMFrequency),size(GMFrequency));
   XDot = Pi * (1+2*round(XDot/2/Pi-0.5)); % -180 mod 360
  
   % Gain margin dots in scope (within both axis limits and frequency range)
   % RE: Automatically filters out XDot=NaN
   idxGM = find(XDot>=Xlim(1) & XDot<=Xlim(2) & isValidGM);
   nGM = length(idxGM);
   YDot = unitconv(1./cd.GainMargin(idxGM),'abs',AxGrid.YUnits);  
   for ct=1:nGM
      X = XDot(idxGM(ct));
      Y = YDot(ct);
      if Y>=Ylim(1) && Y<=Ylim(2)
         set(double(cv.MagPoints(ct)),'XData',X,'YData',Y,...
            'MarkerFaceColor',cv.MagPoints(1).Color,'UserData',idxGM(ct))
      else
         Y = max(Ylim(1),min(Y,Ylim(2)));
         set(double(cv.MagPoints(ct)),'XData',X,'YData',Y,...
            'MarkerFaceColor','none','UserData',idxGM(ct))
      end
      set(double(cv.MagLines(ct)),'XData',[X X],'YData',[ZerodB Y])
      set(double(cv.PhaseCrossLines(ct)),'XData',[X X],'YData',Ylim)
   end
   
   % Gain margins at frequencies outside the data range
   % RE: May happen, e.g., for user-defined frequency range
   idxOut = find(GMFrequency<Freq(1) & isValidGM);
   if ~isempty(idxOut)
      set(double(cv.MagPoints(nGM+1)),'XData',Phase(1),'YData',Mag(1),...
         'MarkerFaceColor','none','UserData',idxOut)
      nGM = nGM+1;   LowShift = 1;
   end
   idxOut = find(GMFrequency>Freq(nf) & isValidGM);
   if ~isempty(idxOut)
      set(double(cv.MagPoints(nGM+1)),'XData',Phase(nf),'YData',Mag(nf),...
         'MarkerFaceColor','none','UserData',idxOut)
      nGM = nGM+1;   HighShift = 1;
   end
   
   % Remaining gain margins displayed as open circles (with data marker summary
   % of all margins left out of the display)
   idxL = find(XDot<Xlim(1) & isValidGM);
   idxR = find(XDot>Xlim(2) & isValidGM);
   if ~isempty(idxL)
      [XDot,YDot] = LocalPositionDot('left',Xlim,Ylim,Phase,Mag,LOffset);
      set(double(cv.MagPoints(nGM+1)),'XData',XDot,'YData',YDot,...
         'MarkerFaceColor','none','UserData',idxL)
      nGM = nGM+1;
      LOffset = 0.02;
   end
   if ~isempty(idxR)
      [XDot,YDot] = LocalPositionDot('right',Xlim,Ylim,Phase,Mag,ROffset);
      set(double(cv.MagPoints(nGM+1)),'XData',XDot,'YData',YDot,...
         'MarkerFaceColor','none','UserData',idxR)
      ROffset = 0.02;
   end
  
   % Locate phase reference lines (PmLine) for phase margin dots
   Pm = unitconv(cd.PhaseMargin, 'deg', AxGrid.XUnits);
   isValidPM = isfinite(cd.PhaseMargin);
   PMFrequency = cd.PMFrequency;
   XDot = reshape(interp1(Freq,Phase,PMFrequency),size(PMFrequency));
   PmLine = Pi * round((XDot-Pm)/Pi);
   
   % Phase margin dots in scope (within both axis limits and frequency range)
   idxPM = find(isfinite(XDot) & isValidPM & XDot>=Xlim(1) & XDot<=Xlim(2));
   nPM = length(idxPM);
   for ct=1:nPM
      X = XDot(idxPM(ct));
      if X>=Xlim(1) && X<=Xlim(2)
         set(double(cv.PhasePoints(ct)),'XData',X,'YData',ZerodB,...
            'MarkerFaceColor',cv.PhasePoints(1).Color,'UserData',idxPM(ct))    
      else
         X = max(Xlim(1),min(X,Xlim(2)));
         set(double(cv.PhasePoints(ct)),'XData',X,'YData',ZerodB,...
            'MarkerFaceColor','none','UserData',idxPM(ct))
      end
      set(double(cv.PhaseLines(ct)),...
         'XData',[PmLine(idxPM(ct)) X],'YData',[ZerodB ZerodB])
   end
   
   % Phase margins at frequencies outside the data range
   idxOut = find(PMFrequency<Freq(1) & isValidPM);
   if ~isempty(idxOut)
      set(double(cv.PhasePoints(nPM+1)),'XData',Phase(1+LowShift),'YData',Mag(1+LowShift),...
         'MarkerFaceColor','none','UserData',idxOut)
      nPM = nPM+1;
   end
   idxOut = find(PMFrequency>Freq(nf) & isValidPM);
   if ~isempty(idxOut)
      set(double(cv.PhasePoints(nPM+1)),'XData',Phase(nf-HighShift),'YData',Mag(nf-HighShift),...
         'MarkerFaceColor','none','UserData',idxOut)
      nPM = nPM+1;
   end

   % Remaining phase margins displayed as open circles (with data marker summary
   % of all margins left out of the display)
   idxL = find(XDot<Xlim(1) & isValidPM);
   idxR = find(XDot>Xlim(2) & isValidPM);
   if ~isempty(idxL)
      [XDot,YDot] = LocalPositionDot('left',Xlim,Ylim,Phase,Mag,LOffset);
      set(double(cv.PhasePoints(nPM+1)),'XData',XDot,'YData',YDot,...
         'MarkerFaceColor','none','UserData',idxL)
      nPM = nPM+1;
   end
   if ~isempty(idxR)
      [XDot,YDot] = LocalPositionDot('right',Xlim,Ylim,Phase,Mag,ROffset);
      set(double(cv.PhasePoints(nPM+1)),...
         'XData',XDot,'YData',YDot,...
         'MarkerFaceColor','none','UserData',idxR)
   end
   
end 

%-------------------- local functions -------------------------------

function [XDot,YDot] = LocalPositionDot(LeftRight,Xlim,Ylim,Xdata,Ydata,Offset)
% Find leftmost or rightmost visible point on the plot
if strcmpi(LeftRight(1),'l')
   Xcross = Xlim(1) + Offset*(Xlim(2)-Xlim(1));
else
   Xcross = Xlim(2) - Offset*(Xlim(2)-Xlim(1));
end
ns = length(Xdata);
% Locate all crossings with X=XCROSS
dX = Xdata-Xcross;
idxc = find(dX(1:ns-1)~=dX(2:ns) & dX(1:ns-1).*dX(2:ns)<=0);
Ycross = Ydata(idxc+1) - dX(idxc+1) .* ...
   (Ydata(idxc+1)-Ydata(idxc))./(Xdata(idxc+1)-Xdata(idxc));
Ycross = Ycross(Ycross>=Ylim(1) & Ycross<=Ylim(2));
if ~isempty(Ycross)
   XDot = Xcross;  YDot = Ycross(1);
else
   % No crossing
   idxvis = find(Xdata>=Xlim(1) & Xdata<=Xlim(2) & Ydata>=Ylim(1) & Ydata<=Ylim(2));
   if isempty(idxvis)
      XDot = NaN;  YDot = NaN;
   elseif strcmpi(LeftRight(1),'l')
      [XDot,imin] = min(Xdata(idxvis));
      YDot = Ydata(idxvis(imin));
   else
      [XDot,imax] = max(Xdata(idxvis));
      YDot = Ydata(idxvis(imax));
   end
end