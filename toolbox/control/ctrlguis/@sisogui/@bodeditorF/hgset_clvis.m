function hgset_clvis(Editor,junk)
% Toggles visibility of closed-loop plots.

%   $Revision: 1.4 $  $Date: 2001/08/10 21:08:00 $
%   Copyright 1986-2001 The MathWorks, Inc.

if strcmp(Editor.ClosedLoopVisible,'on')
	% Redraw to show closed-loop response
	Editor.update;
else
	% Hide closed-loop plot
    % REVISIT: simplify
    HG = Editor.HG;
	if size(HG.BodePlot,2)>1 & all(ishandle(HG.BodePlot(:,2)))
		delete(HG.BodePlot(:,2))
        HG.BodePlot = HG.BodePlot(:,1);
        Editor.HG = HG;
	end
end
