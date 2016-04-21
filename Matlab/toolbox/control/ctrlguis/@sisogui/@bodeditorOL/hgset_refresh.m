function hgset_refresh(Editor,varargin)
% HG side effects of changing the Refresh mode.

%   $Revision: 1.13.4.2 $  $Date: 2004/04/10 23:14:08 $
%   Copyright 1986-2004 The MathWorks, Inc.

% Set editor position in host figure
HG = Editor.HG;

% Build list of moving objects
MovingHandles = cat(1,...
	HG.System.Magnitude,...
	HG.System.Phase,...
	HG.BodePlot,...
	HG.Compensator.Magnitude,...
	HG.Compensator.Phase);

% Add gain/phase margin objects
if strcmp(Editor.MarginVisible,'on'),
  GMH = HG.GainMargin;
  PMH = HG.PhaseMargin;
  MovingHandles = cat(1,MovingHandles,...
		      GMH.Dot,GMH.vLine,GMH.Text,PMH.Dot,PMH.vLine,PMH.Text);
  hLines = [GMH.hLine;PMH.hLine];
else
  hLines = [];
end

% Set erase mode for moving objects
if strcmp(Editor.RefreshMode,'quick')
    % Use XOR for because of red squares, otherwise erase the locus lines...
    set(MovingHandles,'EraseMode','xor')
    set(hLines,'EraseMode','background')
else
    set([MovingHandles;hLines],'EraseMode','normal')
end
