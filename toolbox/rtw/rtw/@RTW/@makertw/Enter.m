function Enter(h)
%   ENTER is the method get called inside make_rtw method when entering
%   process.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/15 00:23:47 $

% run 'entry' rtw hook and issue start build message
  if ~h.InitRTWOptsAndGenSettingsOnly
    if ~isempty(h.MakeRTWHookMFile)
      feval(h.MakeRTWHookMFile,'entry',h.ModelName,[],[],[],h.BuildArgs);
    else
      if strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM')
        targetInfo = 'Updating model reference SIM target';
      elseif strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'RTW')
        targetInfo = 'Updating model reference RTW target';
      else
        targetInfo = 'Starting Real-Time Workshop build procedure';
      end
      msg = sprintf('\n### %s for model: %s', targetInfo, h.ModelName);
      feval(h.DispHook{:}, msg);
    end
  end
  
%endfunction
