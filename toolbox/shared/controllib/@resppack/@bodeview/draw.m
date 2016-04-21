function draw(this, Data, NormalRefresh)
%DRAW  Draws Bode response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:33 $

AxGrid = this.AxesGrid;

% Input and output sizes
[Ny, Nu] = size(this.MagCurves);
if Data.Ts
  nf = unitconv(pi/abs(Data.Ts),'rad/sec',AxGrid.XUnits);
else
  nf = NaN;
end
Freq = unitconv(Data.Frequency,Data.FreqUnits,AxGrid.XUnits);
Mag = unitconv(Data.Magnitude,Data.MagUnits,AxGrid.YUnits{1});
Phase = unitconv(Data.Phase,Data.PhaseUnits,AxGrid.YUnits{2});

% Eliminate zero frequencies in log scale
if strcmp(AxGrid.Xscale{1},'log')
  idxf = find(Freq>0);
  Freq = Freq(idxf);
  if ~isempty(Mag)
    Mag = Mag(idxf,:);
  end
  if ~isempty(Phase)
    Phase = Phase(idxf,:);
  end
end

% Mag curves
for ct = 1:Ny*Nu
   % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
   set(double(this.MagCurves(ct)), 'XData', Freq, 'YData', Mag(:,ct));
end

% Mag Nyquist lines (invisible to limit picker)
YData = unitconv(infline(0,Inf),'abs',AxGrid.YUnits{1});
XData = nf(:,ones(size(YData)));
set(this.MagNyquistLines,'XData',XData,'YData',YData)  

% Phase curves
if isempty(Phase)
  set([this.PhaseCurves(:);this.PhaseNyquistLines(:)], ...
      'XData', [], 'YData', [])
else
  if strcmp(this.UnwrapPhase, 'off')
    Pi = unitconv(pi,'rad',AxGrid.YUnits{2});
    Phase = mod(Phase+Pi,2*Pi) - Pi;
  end

  for ct = 1:Ny*Nu
    % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
    set(double(this.PhaseCurves(ct)), 'XData', Freq, 'YData', Phase(:,ct));
  end
  % Phase Nyquist lines (invisible to limit picker)
  YData = infline(-Inf,Inf);
  XData = nf(:,ones(size(YData)));
  set(this.PhaseNyquistLines,'XData',XData,'YData',YData)  
end
