function clear(Editor)
%CLEAR  Clears root locus plot.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 04:58:11 $

% RE: Clear only objects managed directly by the root locus editor (excludes constraints,...)

HG = Editor.HG;
DeleteH = [...
        HG.ClosedLoop(:);...
        HG.Compensator(:);...
        HG.Locus(:);...
        HG.System(:)];
delete(DeleteH(ishandle(DeleteH)))

% Delete custom grid
cleargrid(Editor.Axes)

% REVISIT
set(HG.LocusShadow,'XData',[],'YData',[],'ZData',[])