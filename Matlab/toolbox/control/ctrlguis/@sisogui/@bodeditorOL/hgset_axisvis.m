function hgset_axisvis(Editor)
% Toggles visibility of mag/phase plots.

%   $Revision: 1.7 $  $Date: 2001/08/10 21:07:59 $
%   Copyright 1986-2001 The MathWorks, Inc.

% RE: Do not assume editor is visible (not necessarily true when loading session)
if strcmp(Editor.Visible,'on')
    MagVis = Editor.MagVisible;
    PhaseVis = Editor.PhaseVisible;
else
    MagVis = 'off';
    PhaseVis = 'off';
end
    
% Axis and child visibility
PlotAxes = Editor.hgget_axeshandle;
set([PlotAxes(1);get(PlotAxes(1),'children')],'Visible',MagVis)
set([PlotAxes(2);get(PlotAxes(2),'children')],'Visible',PhaseVis)

% Adjust visibility of plant poles and zeros
if strcmp(Editor.ShowSystemPZ,'off')
    set([Editor.HG.System.Magnitude;Editor.HG.System.Phase],'Visible','off')
end
    

