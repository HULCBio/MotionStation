% Function: CleanupForExit =====================================================
% Abstract:
%	- Restore state of the lock and dirty flags
%       - Restore working directory
%       - Leave the attic clean

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/15 00:23:44 $

function CleanupForExit(h)

% Unlock active configuration set & simprm dialog
  configSet = getActiveConfigSet(h.ModelName);
  unlock(configSet);
  hDlg = get_param(h.ModelName, 'SimPrmDialog');
  if ~isempty(hDlg) & isa(hDlg, 'DAStudio.Dialog')
    refresh(hDlg);
  end
  
  %  LogFileManager(h,'flush');
  if ~isempty(h.StartDirToRestore)
    cd(h.StartDirToRestore);
  end

  if ~strcmp(get_param(h.ModelHandle, 'Lock'), h.OrigLockFlag),
    set_param(h.ModelHandle,'Lock', h.OrigLockFlag);
  end

  if ~strcmp(get_param(h.ModelHandle, 'StartTime'), h.OrigStartTime)
    % restore original start time
    set_param(h.ModelHandle, 'StartTime', h.OrigStartTime);
  end
  
  % restore RTWCodeReuse flag
  feature('RTWCodeReuse', h.CodeReuse);
  
  % Restore the old configuration set.  When building model reference
  % code, we use a special configuration set, so we need to restore
  % the original active configuration set.
  actConfigSet = getActiveConfigSet(h.ModelName);
  if h.OldConfigSetInactive
    setActiveConfigSet(h.ModelName, h.OldConfigSetName);
    detachConfigSet(h.ModelName, actConfigSet.Name);
  end
  
  rtwprivate('rtwattic', 'clean');

  % put to the end to make sure "Dirty" status get restored
  h.CleanupDirtyFlag(h.ModelHandle,h.OrigDirtyFlag);
  set_param(h.modelName, 'MakeRTWSettingsObject',[]);
  
%endfunction CleanupForExit
