function hgset_refresh(Editor, varargin)
% HG side effects of changing the Refresh mode.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $ $Date: 2004/04/10 23:14:10 $

% Set editor position in host figure
HG = Editor.HG;

% Build list of moving objects
MovingHandles = cat(1, ...
		    HG.System, ...
		    HG.NicholsPlot, ...
		    HG.Compensator);

% Add gain/phase margin objects
if strcmp(Editor.MarginVisible, 'on'),
  GPM = HG.Margins;
  MovingHandles = cat(1, MovingHandles, ...
		      GPM.MagDot, GPM.PhaDot, GPM.MagLine, GPM.PhaLine, GPM.Text);
  hLines = [];
else
  hLines = [];
end

% Set erase mode for moving objects
if strcmp(Editor.RefreshMode, 'quick')
  set(MovingHandles, 'EraseMode', 'xor')
  set(hLines, 'EraseMode', 'background')
else
  set([MovingHandles ; hLines], 'EraseMode', 'normal');
end
