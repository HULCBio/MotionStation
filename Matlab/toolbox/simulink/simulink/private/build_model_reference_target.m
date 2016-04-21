function [oHadErr,oErrMsg,oRTWCodeWasGenerated] = ...
    build_model_reference_target(iMdl,iTopMdl,iBuildArgs)
%

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $

  oErrMsg = '';
  oHadErr = false; % assume
  oRTWCodeWasGenerated = true;
  aState  = [];

  [aState, oHadErr, oErrMsg] = LocSetup(iMdl, iTopMdl, iBuildArgs);

  if ~oHadErr
    try
      build_target('RunBuildCmd', iMdl, iBuildArgs);
    catch
      oHadErr = true;
      oErrMsg = lasterr('');
    end
  end
  
  % Determine if the code was actually generated
  oRTWCodeWasGenerated = isequal(get_param(iMdl, 'RTWCodeWasGenerated'), 'on');
  
  if oHadErr,
    okayToPushNags = false; % assume
    if isfield(iBuildArgs,'OkayToPushNags'),
      okayToPushNags = iBuildArgs.OkayToPushNags;
    end
    if okayToPushNags,
      nag = create_nag('Simulink', 'Error', ...
                       'Model Reference Target Update', oErrMsg, iMdl);
      slsfnagctlr('Naglog', 'push', nag);
    end
  end

  if ~isempty(aState),
    LocCleanup(aState);
  end

%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [oState, oHadErr, oErrMsg] = LocSetup(iMdl, iTopMdl, iBuildArgs)

  oHadErr = false;
  oErrMsg = '';

  oState = build_target('Setup', iMdl);
  oState.mMdlRefPrms = {};
  oState.configSet = [];
  oState.dirty = get_param(iMdl, 'Dirty');
  targetType = iBuildArgs.ModelReferenceTargetType;
  
  set_param(iMdl, 'ModelReferenceTargetType', targetType);

%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocCleanup(iState)

  set_param(iState.mModel, 'ModelReferenceTargetType', 'NONE');
  set_param(iState.mModel, 'Dirty', iState.dirty);
  build_target('Cleanup', iState);

%endfunction
