function CleanupDirtyFlag(h, hMdl,origDirtyFlag)
% CLEANUPDIRTYFLAG:
%   Method restore the state of the dirty flag.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2002/09/23 16:27:00 $

dirtyFlag = get_param(hMdl, 'Dirty');
if ~strcmp(dirtyFlag, origDirtyFlag)
    set_param(hMdl,'Dirty', origDirtyFlag);
end
%endfunction CleanupDirtyFlag
