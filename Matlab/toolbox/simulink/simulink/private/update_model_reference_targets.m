function [oHadErr, oErrMsg] = update_model_reference_targets(iMdl, iBuildArgs)
%
% Abstract
%   Update the targets of all the model references used from within iMdl.
%   Checks the 'UpdateModelReferenceTargets' setting on iMdl to determine
%   what to do. For example, if the above setting is 'IfOutOfDate' then
%   we first look up all the out of date targets and then up date them.
%
% Syntax
%
%   update_model_reference_targets(iMdl, iBuildArgs)
%
% Inputs
%
%   iMdl       : (string) The name of the model to update references in.
%
%   iBuildArgs : (struct) Options to control and query the update process.
%
%  Outputs
%
%   oHadErr    :   (bool)   true if there have been any errors, false otherwise.
%   oErrMsg    :   (string) string explaining what the error is, if oHadErr.
%
% Notes:
%    1.  We can enhance this function by getting a list from
%        get_ordered_model_references which tells us the top nodes of any up to
%        date models.  This is useful since we know the child model references
%        will be compatible with the top node.
%
%   $Revision: 1.1.8.15 $

  oErrMsg = '';
  oHadErr = false; % assume

  % Nothing to do if ModelReference feature is not enabled.
  if slfeature('ModelReference')==0, return; end

  targetType = iBuildArgs.ModelReferenceTargetType;

  if strcmp(targetType, 'RTW')
    % Make sure model reference SIM targets are up to date
    simMdlrefBuildArgs = iBuildArgs;
    simMdlrefBuildArgs.ModelReferenceTargetType = 'SIM';
    [oHadErr, oErrMsg] = loc_update_model_reference_targets(iMdl, ...
                                                      simMdlrefBuildArgs);
    if(oHadErr) return; end;
  end

  [oHadErr, oErrMsg] = loc_update_model_reference_targets(iMdl, iBuildArgs);
  if(oHadErr)  return; end;

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function: loc_update_model_reference_targets
%   See comments in update_model_reference_targets
%
function [oHadErr, oErrMsg] = loc_update_model_reference_targets(iMdl, ...
                                                    iBuildArgs)

  oErrMsg = '';
  oHadErr = false; % assume

  okayToPushNags = false; % assume
  if isfield(iBuildArgs,'OkayToPushNags'),
    okayToPushNags = iBuildArgs.OkayToPushNags;
  end

  verbose = false; % assume
  if isfield(iBuildArgs,'Verbose'),
    verbose = iBuildArgs.Verbose;
  end


  % Refresh the models blocks at this level, return if there are
  % any errors, throw the warnings to the nag and commandline.
  [oHadErr, oErrMsg] = loc_refresh_model_blocks(iMdl, okayToPushNags);
  if oHadErr
    return;
  end

  targetType = iBuildArgs.ModelReferenceTargetType;

  updateControl = get_param(iMdl, 'UpdateModelReferenceTargets');

  % If we are to assume that all model reference targets are up to date,
  % quickly return out of here, with out even looking to see if there are
  % any model references. This saves time (the reason for this setting).

  if isequal(updateControl, 'AssumeUpToDate'),
    updateMsg = get_param(iMdl, 'CheckModelReferenceTargetMessage');

    warn = false;
    err = false;
    if strcmpi(updateMsg, 'warning')
      warn = true;
    elseif strcmpi(updateMsg, 'error')
      err = true;
    end

    % If we aren't warning or erroring out for out of date
    % submodels, then simply return here.
    if ~warn && ~err
      msg = ['Model reference Rebuild option is set to ''Never''.  ', ...
             'Assuming all model references are up to date.'];
      sl_disp_info(okayToPushNags, msg, iMdl, true);
      return;
    end
  end

  % Do a depth first search to get a list of all the model references
  % The depth first search ensures that all the references from within
  % a certain model are above it in the list. This property of the list
  % (hence the name ordered) is used in the checking and updating code
  % below.
  %
  % Note that in get_ordered_model_references we also cache the list
  % of models in each of the models we visit in a info mat file. This
  % helps speed up the latter part (we do not need to do a find_system
  % following all library links).

  lasterr('');
  try
    [mdlRefs, pathToMdlRefs, dirtyFlags] ...
        = get_ordered_model_references(iMdl,targetType,{},{},{},[]);
  catch
    oHadErr = true;
    oErrMsg = lasterr('');
    if okayToPushNags,
      loc_push_nag('Error', oErrMsg, iMdl);
    end
    return;
  end

  % Do we need to update the model reference target of the top model?
  updateTopMdlRefTgt = false; % assume
  if isfield(iBuildArgs,'UpdateTopModelReferenceTarget'),
    updateTopMdlRefTgt = iBuildArgs.UpdateTopModelReferenceTarget;
  end

  if ~updateTopMdlRefTgt,
    % Checks to perform on top model before updating model references.
    % - InlineParameters must be ON.
    if ((length(mdlRefs) > 1) && ...
        (strcmp(get_param(iMdl, 'RTWInlineParameters'), 'off')))
      oHadErr = true;
      oErrMsg = ['Invalid setting for RTWInlineParameters in model ''%s'' ', ...
                 'because this model contains one or more Model blocks.  ', ...
                 'The inline parameters option must be ''on'' for models ', ...
                 'that reference other models.  To set the inline parameters ', ...
                 'option, go to the Optimization page of the Configuration ', ...
                 'Parameters dialog'];
      oErrMsg = sprintf(oErrMsg, get_param(iMdl, 'Name'));
      if okayToPushNags, loc_push_nag('Error', oErrMsg, iMdl); end
      return;
    end
    
    % the last entry in mdlRefs is the top model (iMdl), remove it from the list
    mdlRefs       = mdlRefs(1:end-1);
    pathToMdlRefs = pathToMdlRefs(1:end-1);
    dirtyFlags    = dirtyFlags(1:end-1);
  elseif dirtyFlags(end)
    % If a model has unsaved changes, then we cannot allow the model reference
    % target to be updated. This makes sure that if the model is subsequently
    % closed without saving the changes, the target will have a
    % newer time stamp than the model but inconsistent.
    oHadErr = true;
    oErrMsg = ['Can not update the model reference target of ', iMdl,  ...
               ' because it has unsaved changes'];
    if okayToPushNags, loc_push_nag('Error', oErrMsg, iMdl); end
    return;
  end

  nMdlRefs = length(mdlRefs);

  % nothing to do if there are no model references in iMdl
  if nMdlRefs == 0, return; end
  
  % If any of the referenced models has unsaved changes (i.e., is dirty)
  % then we cannot update its model reference target. Check for this case
  % and error out

  if any(dirtyFlags)
    dirtyIdx = find(dirtyFlags);
    msgs = {};
    for i = 1:length(dirtyIdx),
      idx = dirtyIdx(i);
      mdl = mdlRefs{idx};
      pathToMdl = pathToMdlRefs{idx};

      msgs{i} = ['Can not update the model reference target of ', mdl,  ...
                 ' used in ''', pathToMdl, ''' because it has unsaved changes'];
      if okayToPushNags, loc_push_nag('Error', msgs{i}, mdl); end
    end
    oHadErr = true;
    oErrMsg = strcat_with_separator(msgs, cr);
    return;
  end

  % Error out here if any of the model have setting that are in-compatible with 
  % model reference. It is better to error out here before generating any code.
  [oHadErr, oErrMsg] = loc_err_if_mdls_have_invalid_settings(mdlRefs, ...
                                                    targetType, ...
                                                    okayToPushNags);
  if oHadErr, return; end
  
  if isequal(updateControl, 'AssumeUpToDate')
    msg = 'Model reference Rebuild option is set to ''Never''';
    sl_disp_info(okayToPushNags, msg, iMdl, true);
  end
  
  % Loop over the models references and up-date their targets.
  status = repmat(0, nMdlRefs, 1);
  reason = repmat({''}, nMdlRefs, 1);
  for i = 1:nMdlRefs
    mdl = mdlRefs{i};
    pathToMdl = pathToMdlRefs{i};

    if ~isempty(pathToMdl)
      msg = ['Checking the status of model reference ', targetType, ...
             ' target for model ', mdl, ' used in ''', pathToMdl, '''', cr];
    else
      % generating model reference target for the top model
      msg = ['Checking the status of model reference ', targetType, ...
             ' target for model ', mdl, cr];
    end
    sl_disp_info(okayToPushNags, msg, mdl, verbose);

    [oHadErr, oErrMsg, rebuild, reason{i}, useChecksum] = ...
        configure_model_reference_target_status(mdl, mdlRefs, targetType, ...
                                                verbose, okayToPushNags, ...
                                                status, updateControl);
    if oHadErr, return; end
     
    % Update the status of targets
    if ~rebuild
      % => mdl is up-to-date
      status(i) = 0;
      sl_disp_info(okayToPushNags, reason{i}, mdl, verbose);
    elseif ~isequal(updateControl, 'AssumeUpToDate'),
      % Rebuild is true, try to rebuild

      %% Do not tie this to verbose. For the first version,
      %% always indicate why we are rebuilding the model reference targets
      sl_disp_info(okayToPushNags, reason{i}, mdl, true);
      
      % Skip the checksum check if anything was out of date
      iBuildArgs.UseChecksum = useChecksum;
      
      [oHadErr, oErrMsg, rtwCodeWasGenerated] = ...
          build_model_reference_target(mdl, iMdl, iBuildArgs);
      if oHadErr, return; end
      
      % Determine if the code was really built, or if the
      % build was aborted because checksums matched.
      if rtwCodeWasGenerated
        status(i) = 1;
      else
        status(i) = 0;
      end
    else
      % Rebuild is true, set the status to true. No need to display
      % any message. All messages for models that are not up to date 
      % will be reported below
      status(i) = 1;
    end
  end

  % Not allowed to update the targets => make a nice
  % error message from all the reasons and bail out.
  if isequal(updateControl, 'AssumeUpToDate'),
    outOfDateIdx = find(status ~= 0);
    nOutOfDate = length(outOfDateIdx);

    if nOutOfDate == 0,
      msg = ['All model reference ', targetType, ' targets are up to date'];
      sl_disp_info(okayToPushNags, msg, iMdl, true);
      return;
    end
    
    if err
      msgType = 'Error';
      oHadErr = true;
    else
      msgType = 'Warning';
    end
    
    oErrMsg = '';   
    sp = '';
    for i = 1:nOutOfDate,
      idx = outOfDateIdx(i);
      mdl = mdlRefs{idx};

      oErrMsg = [oErrMsg, sp, reason{idx}];
      sp = cr;
      
      if okayToPushNags,
        loc_push_nag(msgType, reason{idx}, mdl);
      end
    end
    
    if strcmp(msgType,'Warning')
      warning('ModelReference:OutOfDate', '%s', oErrMsg);
      oErrMsg = '';
    end
    return;
  end

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [oHadErr, oErrMsg] = loc_err_if_mdls_have_invalid_settings(iMdls, ...
                                                    iTargetType, ...
                                                    iOkayToPushNags)

  oHadErr = false; oErrMsg = '';
  nMdls = length(iMdls);
  for i = 1:nMdls,
    mdl = iMdls{i};
    anchorDir = pwd;
    cache = rtwprivate('rtwinfomatman',anchorDir,'load','model',mdl,iTargetType);

    % Error out of if mdl has links to libraries that have unsaved changes.
    libMdls  = cache.libDeps;
    nLibMdls = length(libMdls);
    errMsgs  = {};
    for j=1:nLibMdls
      lib = libMdls{j};
      if ~isModelClosed(lib) && isequal(get_param(lib,'Dirty'),'on')
        errMsgs{end+1} = ['Can not update the model reference target of ', ...
                          mdl, ' because it has links to library ', lib, ...
                          ' that has unsaved changes'];
        if iOkayToPushNags, loc_push_nag('Error', errMsgs{end}, lib); end
        oHadErr = true;
      end
    end

    % Error out if mdl is using a variable step solver
    if cache.usingVarStepSolver
      errMsgs{end+1} = ['Can not create the model reference ', ...
                        iTargetType, ' target for ''', mdl, ''' because ', ...
                        'the model is using a variable-step solver. ', ...
                        'Variable-step solvers are not supported ', ...
                        'for referenced models'];
      if iOkayToPushNags, loc_push_nag('Error', errMsgs{end}, mdl); end
      oHadErr = true;
    end
  end

  if oHadErr
    oErrMsg = strcat_with_separator(errMsgs, cr);
  end

%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loc_push_nag(iType, iMsg, iMdl)

  nag = create_nag('Simulink', iType, ...
                   'Model Reference Target Update', ...
                   iMsg, iMdl);
  slsfnagctlr('Naglog', 'push', nag);

%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call into Simulink to refresh the model blocks.  This allows
% an IO/Version mismatch error to be caught sooner when we
% are generating standalone code for a top model.
function [oHadErr, oErrMsg] = loc_refresh_model_blocks(iMdl, iOkayToPushNags)

  oHadErr = false;
  oErrMsg = '';

  io = get_param(iMdl, 'ModelReferenceIOMismatchMessage');
  ver = get_param(iMdl, 'ModelReferenceVersionMismatchMessage');

  % No need to call back into Simulink unless the message is warn/error
  if ~strcmpi(io,'none') || ~strcmpi(ver, 'none')
    object = get_param(iMdl, 'Object');
    sysTargetFile = get_param(iMdl,'RTWSystemTargetFile');
    if ~strcmpi(sysTargetFile, 'accel.tlc')
      try
        object.refreshModelBlocks();
      catch
        oHadErr = true;
        oErrMsg = lasterr();
      end
    end
  end

%endfunction

% eof
