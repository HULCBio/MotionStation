function updategainC(Editor)
%UPDATEGAINC  Lightweight plot update when modifying C's gain.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 05:04:11 $

if ~strcmp(Editor.EditMode,'off') & ...
		strcmp(Editor.Visible,'on') & ...
		strcmp(Editor.ClosedLoopVisible,'on')
	% Editor is idle+visible and closed-loop plot is visible
	Editor.update;
end