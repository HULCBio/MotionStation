function sysName = HilBlkGetParentSystemName(blk)
% Return top-level system name for specified block.
% This is needed because GCS is current rather than
% parameterized, and because 
% get_param(blk,'parent") only goes up one level.
% This function goes up to the top level and
% returns the model name.

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:41 $

sysName = get_param(blk,'Parent');

while isSubsys(sysName),
    sysName = get_param(sysName,'Parent');
end


%--------------------------------------------
function bool = isSubsys(sysName)
% 1: system is top-level mdl
% 0: system is a subsystem in the model

% One way to do it:  Does the obj have a "Dirty" flag?
paramList = get_param(sysName,'ObjectParameters');
bool = ~isfield(paramList,'Dirty');

% EOF HilBlkGetParentSystemName.m

