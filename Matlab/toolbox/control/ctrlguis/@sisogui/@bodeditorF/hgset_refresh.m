function hgset_refresh(Editor,varargin)
% HG side effects of changing the Refresh mode.

%   $Revision: 1.6 $  $Date: 2002/04/10 05:04:01 $
%   Copyright 1986-2002 The MathWorks, Inc.

% Build list of moving objects
HG = Editor.HG;
MovingHandles = cat(1,...
    HG.BodePlot(:),...
    HG.Compensator.Magnitude,...
	HG.Compensator.Phase);

% Set erase mode for moving objects
if strcmp(Editor.RefreshMode,'quick')
    % Use XOR for because of red squares, otherwise erase the locus lines...
    set(MovingHandles,'EraseMode','xor')
else
    set(MovingHandles,'EraseMode','normal')
end
