function refreshplot(Editor,eventData,W,S,InitPhase,isort,PZinit,PZnew)
%REFRESHPLOT  Refreshes open-loop plot when F's gain or p/z change (config 4 only)

%   Author(s): N. Hickey, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:03:22 $

% RE: InitPhase = phase at origin (as multiple of 180). Used to prevent 360 jumps in phase
%     when computing initial phase with ANGLE.
LoopData = Editor.LoopData;
GainC = getzpkgain(Editor.EditedObject,'mag');
nf = length(Editor.Frequency);

% Update filter gain
if nargin<7
   % gain update
   F  = getzpkgain(LoopData.Filter,'mag') * S.F;
else
   [MagF,PhaseF] = subspz(Editor,W,abs(S.F),(180/pi)*angle(S.F),PZinit,PZnew);
   F = MagF .* exp((1i*pi/180)*PhaseF);
end

% Calculate open-loop response for loop configuration 4      
CG = S.C .* S.G;
ReturnDiff = 1 - F .* S.G .* S.H;
if ~any(ReturnDiff)
   return
end
OL = CG ./ ReturnDiff;

% RE: Update editor properties (used by INTERPY)
OLMag   = abs(OL);
OLPhase(isort,:) = unwrap(angle(OL(isort)));
OLPhase = OLPhase + (InitPhase - round(OLPhase(1)/pi)) * pi;  % eliminate 360 jumps
Editor.Magnitude = OLMag(1:nf);   % normalized open-loop gain
Editor.Phase = unitconv(OLPhase(1:nf),'rad','deg');

% Update open-loop mag and phase plot
OLMag   = unitconv(GainC*OLMag,'abs',Editor.Axes.YUnits{1});
OLPhase = unitconv(OLPhase,'rad',Editor.Axes.YUnits{2});
set(Editor.HG.BodePlot(1),'Ydata',OLMag(1:nf));
set(Editor.HG.BodePlot(2),'Ydata',OLPhase(1:nf));

% Update Y coordinate of x and o of compensator C
hPZmag = Editor.HG.Compensator.Magnitude;
for ct=1:length(hPZmag)
   set(hPZmag(ct),'Ydata',OLMag(nf+ct))
end
nf = nf + length(hPZmag);
hPZphase = Editor.HG.Compensator.Phase;
for ct=1:length(hPZphase)
   set(hPZphase(ct),'Ydata',OLPhase(nf+ct))
end

% Update stability margins (using interpolation)
Editor.refreshmargin;
