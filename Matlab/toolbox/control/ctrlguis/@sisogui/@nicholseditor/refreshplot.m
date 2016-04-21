function refreshplot(Editor,eventData,W,S,InitPhase,PZinit,PZnew)
%REFRESHPLOT  Refreshes Nichols plot when F varies (config 4 only).

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 05:05:48 $

LoopData = Editor.LoopData;
GainC = getzpkgain(LoopData.Compensator,'mag');
GainF = getzpkgain(LoopData.Filter,'mag');

% Update filter gain
if nargin<6
   % gain update
   F  = GainF * S.F;
else
   [MagF,PhaseF] = subspz(Editor,W,abs(S.F),(180/pi)*angle(S.F),PZinit,PZnew);
   F = GainF * MagF .* exp((1i*pi/180)*PhaseF);
end

% Calculate open-loop response for loop configuration 4      
CG = S.C .* S.G;
ReturnDiff = 1 - F .* S.G .* S.H;
if ~any(ReturnDiff)
   return
end
OL = CG ./ ReturnDiff;

% RE: Update editor properties (used by INTERPY)
Mag   = abs(OL);
Phase = unwrap(angle(OL));
Phase = Phase + (InitPhase-round(Phase(1)/pi)) * pi;  % eliminate 360 jumps
Editor.Magnitude = Mag;
Editor.Phase = unitconv(Phase,'rad','deg');

% Update Nichols plot
MagData   = mag2dB(GainC*Mag);
PhaseData = unitconv(Phase, 'rad', Editor.Axes.XUnits);
set(Editor.HG.NicholsPlot, 'Xdata', PhaseData, 'Ydata', MagData)

% Interpolate X and Y values to move compensator/plant zero/pole locations
Editor.interpxy(MagData, PhaseData);

% Update stability margins (using interpolation)
Editor.refreshmargin;