function clear(Editor)
%CLEAR  Clears Bode plot.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 04:56:44 $

% RE: 1) Clear only objects managed directly by the Bode editor (excludes constraints,...)
%     2) Does not clear non-generic objects (e.g., stability margin markers)

HG = Editor.HG;
Handles = [HG.BodePlot(:);...
        HG.Compensator.Magnitude;...
        HG.Compensator.Phase;...
        HG.System.Magnitude;...
        HG.System.Phase];

% Delete HG objects
delete(Handles(ishandle(Handles)))

% REVISIT
set(HG.BodeShadow,'XData',[],'YData',[],'ZData',[])
