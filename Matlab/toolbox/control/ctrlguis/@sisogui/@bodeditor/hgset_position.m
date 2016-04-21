function hgset_position(Editor,Position)
% HG rendering of editor's Position property.

%   $Revision: 1.5 $  $Date: 2001/08/10 21:07:59 $
%   Copyright 1986-2001 The MathWorks, Inc.

HG = Editor.HG;
PlotAxes = Editor.hgget_axeshandle;
MagOn = strcmp(Editor.MagVisible,'on');
PhaseOn = strcmp(Editor.PhaseVisible,'on');

% Sets editor position in host figure.
if MagOn & ~PhaseOn,
    % Only mag visible
    set(PlotAxes(1),'Position',Position)
elseif PhaseOn & ~MagOn
    % Only phase visible
    set(PlotAxes(2),'Position',Position)
else
    % Both visible
    MagPos = Position;
    MagPos(4) = 0.55 * Position(4);
    MagPos(2) = Position(2) + Position(4) - MagPos(4);
    set(PlotAxes(1),'Position',MagPos)
    
    PhasePos = Position;
    PhasePos(4) = 0.4 * Position(4);
    set(PlotAxes(2),'Position',PhasePos)
end
