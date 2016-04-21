function updategainC(Editor)
%UPDATEGAINC  Lightweight plot update when modifying the loop gain.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 05:06:16 $

% Return if Editor is inactive.
if strcmp(Editor.EditMode, 'off') | ...
      strcmp(Editor.Visible, 'off') | Editor.SingularLoop
  return
end

% Compute new mag data = loop gain * normalized open-loop gain
Gain = getzpkgain(Editor.EditedObject,'mag');  % abs zpk gain
MagData = mag2dB(Gain * Editor.Magnitude);
PhaseData = unitconv(Editor.Phase, 'deg', Editor.Axes.XUnits);

% Update mag plot vertical position
set(Editor.HG.NicholsPlot, 'Ydata', MagData); 
% REVISIT: Update XlimIncludeData
InFocus = (Editor.Frequency>=Editor.FreqFocus(1) & Editor.Frequency<=Editor.FreqFocus(2));
set(Editor.HG.NicholsShadow, 'YData', MagData(InFocus))

% Update pole/zero positions in Nichols plot (in current units)
Editor.interpxy(MagData, PhaseData);

% Update margins
showmargin(Editor)

% Update axis limits (also updates margin display)
updateview(Editor) 
