function hgset_refresh(Editor,varargin)
% HG side effects of changing the Refresh mode.

%   $Revision: 1.8 $  $Date: 2002/04/10 04:57:50 $
%   Copyright 1986-2002 The MathWorks, Inc.

% Set erase mode for moving objects
HG = Editor.HG;
MovingHandles = [HG.ClosedLoop ; HG.Locus ; HG.Compensator];
if strcmp(Editor.RefreshMode,'quick')
    % Use XOR for because of red squares, otherwise erase the locus lines...
    set(MovingHandles,'EraseMode','xor')
else
    set(MovingHandles,'EraseMode','normal')
end
