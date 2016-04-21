function [oHadErr, oErrMsg] = build_standalone_rtw_target(iMdl, iBuildArgs)
%
% Abstract
%   Build the appropriate RTW target for iMdl.
%

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $
  oHadErr = false;
  oErrMsg = '';
  aState = [];
  
  try
    minfo = rtwprivate('rtwinfomatman',pwd,'update','minfo',iMdl,'NONE');

    if ~isempty(minfo.modelRefs)
      % Make sure target of model reference blocks are up to date.
      iMdlRefBuildArgs = iBuildArgs;
      
      % Check if we need to build a SIM or RTW target for submodels.
      targetName = strtok(get_param(iMdl, 'RTWSystemTargetFile'),'.');
      %% Model reference targets are updated by simulink for accelerator
      if ~strcmp(targetName, 'accel')
        iMdlRefBuildArgs.ModelReferenceTargetType = 'RTW';
        [oHadErr,oErrMsg]=update_model_reference_targets(iMdl,iMdlRefBuildArgs);
        if oHadErr, return; end
      end
    end
    
    %iBuild must have the following settings
    %iBuildArgs.ModelReferenceTargetType = 'NONE';
    %iBuildArgs.UpdateTopModelReferenceTarget = false;

    aState = build_target('Setup', iMdl);
    build_target('RunBuildCmd', iMdl, iBuildArgs);
  catch
    oHadErr = true;
    oErrMsg = lasterr('');
  end

  if oHadErr,
    okayToPushNags = false; % assume
    if isfield(iBuildArgs,'OkayToPushNags'),
      okayToPushNags = iBuildArgs.OkayToPushNags;
    end
    if okayToPushNags,
      nag = create_nag('RTW', 'Error', 'Build', oErrMsg, iMdl);
      slsfnagctlr('Naglog', 'push', nag);
    end
  end

  if ~isempty(aState),
    build_target('Cleanup', aState);
  end

%endfunction

% eof
