function mpc_deletetask(varargin)
% MPC_DELETETASK DeleteFcn callback for MPC block

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/02/06 00:25:14 $   

% 1) Remove any related task from the GUI

% Get the workspace handle
[frame, h] = slctrlexplorer;

if nargin>0 
    blockpath = varargin{1};
else
    blockpath = gcb;
end

% Delete the task (listeners are still active, as they are stored in the
% mask's appdata and the mask is still alive)

if ~isempty(h),
    mpctask=h.find('-class','mpcnodes.MPCGUI','Block',blockpath);
    if ~isempty(mpctask),
        disconnect(mpctask);
        delete(mpctask);
    end
end

blkh = gcbh;

% 2) Destroy the mask
oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig = findobj('Type','figure', 'Tag','MPC_mask');
set(0,'ShowHiddenHandles',oldsh');
f = findobj(fig, 'flat', 'UserData',blkh);

if ~isempty(f)
    close(f);
end
