function Range = yextent(Editor,type)
%YEXTENT  Finds Y extent of visible data.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:03:55 $

% Current X limits (in rad/sec)
PlotAxes = getaxes(Editor.Axes);
Xlims = unitconv(get(PlotAxes(1),'Xlim'),Editor.Axes.XUnits,'rad/sec');

switch type
case 'mag'
    Ydata = Editor.Magnitude(Editor.Frequency>=Xlims(1) & Editor.Frequency<=Xlims(2));
    if strcmp(Editor.ClosedLoopVisible,'on')
        Ydata = [Ydata ; Editor.ClosedLoopMagnitude(...
            Editor.ClosedLoopFrequency>=Xlims(1) & Editor.ClosedLoopFrequency<=Xlims(2))];
    end
case 'phase'
    Ydata = Editor.Phase(Editor.Frequency>=Xlims(1) & Editor.Frequency<=Xlims(2));
    if strcmp(Editor.ClosedLoopVisible,'on')
        Ydata = [Ydata ; Editor.ClosedLoopPhase(...
            Editor.ClosedLoopFrequency>=Xlims(1) & Editor.ClosedLoopFrequency<=Xlims(2))];
    end
end

Range = [min(Ydata) , max(Ydata)];
