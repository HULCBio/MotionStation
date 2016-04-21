function updategainC(Editor)
%UPDATEGAINC  Lightweight plot update when modifying the loop gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $  $Date: 2002/04/10 05:03:06 $

% RE: Assumes gain does not change sign

if strcmp(Editor.EditMode,'off') | strcmp(Editor.Visible,'off') | Editor.SingularLoop
    % Editor is inactive
    return
end

% Compute new mag data = loop gain * normalized open-loop gain
GainMag = getzpkgain(Editor.EditedObject,'mag');  % loop gain
MagData = unitconv(GainMag*Editor.Magnitude,'abs',Editor.Axes.YUnits{1});

% Update mag plot vertical position
set(Editor.HG.BodePlot(1),'Ydata',MagData); 
% REVISIT: Update XlimIncludeData
XFocus = getfocus(Editor);
set(Editor.HG.BodeShadow(1),'YData',MagData(Editor.Frequency >= XFocus(1) & Editor.Frequency <= XFocus(2)))

% Update pole/zero positions in mag plot
Editor.interpy(MagData);

% Update margins
showmargin(Editor)

% Update axis limits (also updates margin display)
updateview(Editor)