function boo = isActive(this,Model)
% Checks if the signal source is activated.

%   $Revision: 1.1.6.2 $ $Date: 2004/03/10 21:56:29 $
%   Copyright 1986-2004 The MathWorks, Inc.
blk = find_system(Model,'FollowLinks','on','LookUnderMasks','all',...
      'RegExp','on','BlockType','SubSystem','LogID',this.LogID);
PC = get_param(blk{1},'PortConnectivity');
boo = any(ishandle([PC.SrcBlock]));
