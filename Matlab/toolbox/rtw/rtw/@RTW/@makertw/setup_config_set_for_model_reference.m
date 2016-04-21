function setup_config_set_for_model_reference(h, onlySetupSimTargetConfigSet)
% SETUP_CONFIG_SET_FOR_MODEL_REFERENCE
% This function is invoked two times:
% (1) At the start of make_rtw to setup the configSet for model reference
%     SIM target. This is required, because we use modelrefsim.tlc
%     for systemTargetFile.In addition, we would like to skip any rtw hook 
%     files. In this case, we create a temporary configset for model reference
%     SIM target, and attach it to the model.
% 
% (2) prior to invoking TLC to generate code for a model.
%   In this function we do the following things
%    0. Set up a temporary configuration set based on the config set of the
%       model. Note that, for Model reference sim target, this configset
%       is created and attched by an earlier call to this function
%       (onlySetupSimTargetConfigSet=true).
%       If we are generating code for model reference target, then this
%       temporary config set is used as the model's active config set, other
%       wise the temporary config set is used for checking the parent/child
%       config set compatibility.
%
%    1. If we are generating a model reference target (either SIM or RTW) then
%       report config set properties that are incompatible with model reference.
%       The process of checking and reporting incompatibilites also massages
%       some of the config set property values, so that the config set is
%       compatible with model reference. The latter massaging step is done if
%       we are building a standalone RTW target so that the massaged config
%       set is used in step 2 below.
%
%    2. Verify that the configuration sets of any models referenced from
%       this model are compatible with this model's configuration set.

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.9 $

  lasterr('');
  try
    mdlRefTgtType  = h.MdlRefBuildArgs.ModelReferenceTargetType;
    mdl            = h.ModelName;
    okayToPushNags = h.MdlRefBuildArgs.OkayToPushNags;

    if onlySetupSimTargetConfigSet
      if ~isequal(mdlRefTgtType,'SIM')
        error('invalid call to setup_config_set_for_model_reference');
      end
      %% Only setup sim target configset
      configSet = loc_create_tmp_configset(h, mdl);
      loc_setup_config_set_for_mdl_ref_sim_target(configSet);
      loc_attach_tmp_configset(mdl, configSet, h);
    else
      
      rtwTargetType  = strtok(get_param(mdl, 'RTWSystemTargetFile'),'.');
      
      reportConfigSetMdlRefIncompat      = true; % assume
      reportParentChildConfigSetIncompat = true; % assume
      
      % If are here generating code for accelerator, then we have nothing
      % to do: no massaging of the config set of this model and no checking
      % the config set of this model with config sets of models referenced
      % in this model.
      if isequal(rtwTargetType, 'accel'), return; end
      
      if isequal(mdlRefTgtType, 'NONE')
        
        % We are doing RTW build for mdl in any of the various targets
        % (ERT, GRT, RSIM, etc).
        
        % We have nothing to do if there are no model refencences in mdl
        minfo = rtwprivate('rtwinfomatman',pwd,'load','minfo',mdl,mdlRefTgtType);
        if length(minfo.modelRefs) == 0, return; end
        
        % Since we are here doing an RTW build for mdl (and we have an early
        % return above for accelerator) we know that model reference target
        % type for models referenced in this model is RTW
        mdlRefTgtType = 'RTW';
        
        % We check the compatibility of this model's config set only
        % if we are building a model reference target for this model.
        reportConfigSetMdlRefIncompat = false;
        
      end
      
      %% STEP 0: Create a temporary Config Set
      if isequal(mdlRefTgtType,'SIM')
        %% When this function is called with onlySetupSimTargetConfigSet=true,
        %% we attached a temporary sim target configSet. 
        configSet = getActiveConfigSet(mdl);
      else
        configSet = loc_create_tmp_configset(h, mdl);
      end
      
      
      %% STEP 1: Setup config set for model reference sim target
      if isequal(mdlRefTgtType, 'SIM')
        % Any incompat between parent/child config set props are reported by
        % the child in its mdlStart function ... we do not handle this here.
        reportParentChildConfigSetIncompat = false;
        
        loc_setup_config_set_for_mdl_ref_sim_target(configSet);
      end
      
      if (isequal(h.MdlRefBuildArgs.ModelReferenceTargetType, 'SIM') || ...
          isequal(h.MdlRefBuildArgs.ModelReferenceTargetType, 'RTW'))
        set_param(configSet, 'RTWVerbose', h.MdlRefBuildArgs.Verbose);
      end
            
      %% STEP 2: If we are building a model reference target, check and report
      %% (and massage) config set prop values that are incompatible with model
      %% reference. If we are build a standalone RTW target, then only do the
      %% massaging (do not report errors) so that the massaged config set can be
      %% used for parent/child comparison
      
      nagType = get_param(mdl, 'ModelReferenceCSMismatchMessage');
      if ~reportConfigSetMdlRefIncompat, nagType = 'none'; end
      
      errMsg = loc_check_and_massage_configset(mdl, ...
                                               mdlRefTgtType, ...
                                               nagType, ...
                                               reportConfigSetMdlRefIncompat, ...
                                               okayToPushNags, ...
                                               configSet, ...
                                               '');
      if ~isempty(errMsg), error(errMsg); end
      
      %% STEP 3:
      
      if reportParentChildConfigSetIncompat
        info = rtwprivate('rtwinfomatman',pwd,'load','minfo',mdl,mdlRefTgtType);
        mdlRefs  = info.modelRefs;
        nMdlRefs = length(mdlRefs);
        
        for i = 1:nMdlRefs
          mdlRef = mdlRefs{i};
          bi=rtwprivate('rtwinfomatman',pwd,'load','binfo',mdlRef,mdlRefTgtType);
          mdlRefConfigSet = bi.configSet;
          [hadErr, errMsg] = slprivate('compare_configuration_sets', ...
                                       mdl, configSet, ...
                                       mdlRef, mdlRefConfigSet, ...
                                       mdlRefTgtType);
          if hadErr,
            errMsg = loc_handle_nag('Error', errMsg, mdl, okayToPushNags, '');
            error(errMsg);
          end
        end
      end
      
      % If we are here to build the model reference target for mdl, then
      % attach configSet (that we have setup and checked to be compatible
      % with mldRefTgtType) to mdl and set it to be the active config set.
      % Note that we cannot use the modified value in mdlRefTgtType here.
      if isequal(h.MdlRefBuildArgs.ModelReferenceTargetType,'RTW')
        loc_attach_tmp_configset(mdl, configSet, h);
      end
    end
    
  catch
    
    msg = ['Error encountered when creating the model reference ', ...
           mdlRefTgtType, ' target for ', mdl, ' : ', lasterr];
    errMsg = loc_handle_nag('Error', msg, mdl, okayToPushNags, '');
    error(errMsg);

  end

%endfunction setup_config_set_for_model_reference

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loc_setup_config_set_for_mdl_ref_sim_target(ioConfigSet)
  
% Setup properties in the RTW Component
  ioRTW = ioConfigSet.getComponent('Real-Time Workshop');

  ioRTW.SystemTargetFile = 'modelrefsim.tlc';
  ioRTW.TemplateMakefile = 'modelrefsim_default_tmf';
  ioRTW.MakeCommand      = 'make_rtw';
  ioRTW.GenCodeOnly      = 'off';
  ioRTW.TLCOptions       = '';
  
  lifeSpan = get_param(ioConfigSet, 'LifeSpan');
  
  % Setup properties in the RTW->Code Appearance Component
  oldCap = ioRTW.getComponent('Code Appearance');
  ignoreCSC = oldCap.IgnoreCustomStorageClasses;

  % Setup properties in the RTW->Target Component
  oldTgt = ioRTW.getComponent('Target');
  if isa(oldTgt, 'Simulink.ERTTargetCC')
    % If the model RTW target is already set to be ERT, then use the
    % combineOutputUpdate setting as specified on the ERT options by
    % the user. For all other targets set combineOutputUpdate to off.
    combineOutputUpdate = oldTgt.CombineOutputUpdateFcns;
  else
    combineOutputUpdate = 'off';
  end

  ert = Simulink.ERTTargetCC;
  cap = Simulink.CodeAppCC;

  ert.CombineOutputUpdateFcns = combineOutputUpdate;
  ert.GenerateSampleERTMain   = 'off';
  ert.RTWCAPISignals          = 'on';
  ert.RTWCAPIStates           = 'on';

  % For model reference sim target, we do not need to use
  % ert template files
  ert.ERTSrcFileBannerTemplate = '';
  ert.ERTHdrFileBannerTemplate = '';
  ert.ERTDataSrcFileTemplate   = '';
  ert.ERTDataHdrFileTemplate   = '';
  ert.ERTCustomFileTemplate    = '';
  
  o = ioRTW.attachComponent(ert); clear o;

  % To generate faster code and unreadable code
  cap.GenerateComments        = 'off';

  cap.IgnoreCustomStorageClasses = ignoreCSC;
  cap.MaxIdLength             = 100;
  o = ioRTW.attachComponent(cap); clear o;

  hw = ioConfigSet.getComponent('Hardware Implementation');
  slprivate('setHardwareDevice',hw, 'Target', 'MATLAB Host');

  opt = ioConfigSet.getComponent('Optimization');
  set_param(opt, 'ZeroInternalMemoryAtStartup', 'on');
  set_param(opt, 'ZeroExternalMemoryAtStartup', 'on');
  set_param(opt, 'InitFltsAndDblsToZero', 'on');
  set_param(opt, 'LifeSpan', lifeSpan);
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ioErrMsg = loc_check_and_massage_configset(iMdl, ...
                                                    iMdlRefTgtType, ...
                                                    iNagType, ...
                                                    iReportIncompat, ...
                                                    iOkayToPushNags, ...
                                                    configSet, ...
                                                    ioErrMsg)

  hadErrors = false; % assume

  try
    % Note: it would be nice to do this in c in the checkMdlRefCompliance
    % function, but since the value of these properties depends on the original 
    % values of other properties (which may be modified) we cannot do that 
    % (we'd need to be sure of the order that the checks happened in and that 
    % just seems error prone)
    %
    % Before we do the compliance checking, look up some values to decide
    % how to set some properties "behind the scenes"
    % if logging states & MATFileLogging, then turn on RTWCAPIStates
    %
    origConfigSet = getActiveConfigSet(iMdl);
    dataComponent = origConfigSet.getComponent('Data Import/Export');
    RTWComponent = origConfigSet.getComponent('Real-Time Workshop');
    targetComponent = RTWComponent.getComponent('Target');
    turnOnRTWCAPIStates = false;
    
    if ( (strcmp(dataComponent.SaveState,'on') || ...
          strcmp(dataComponent.SaveFinalState,'on')) &&  ...
         strcmp(targetComponent.MatFileLogging,'on') )
      turnOnRTWCAPIStates = true;
    end
    
    hadErrors = ~configSet.checkMdlRefCompliance(iMdlRefTgtType, ...
                                                 iNagType, ...
                                                 iReportIncompat, ...
                                                 get_param(iMdl, 'Name'));
    

    % If the target supports RTWCAPIStates set the RTWCAPIStates appropriately
    % If it doesn't and the user is asking us to log states, warn them that 
    % we cannot
    newRTW = configSet.getComponent('Real-Time Workshop');
    newTarget = newRTW.getComponent('Target');
    if newTarget.hasProp('RTWCAPIStates')
      if turnOnRTWCAPIStates
        newTarget.setProp('RTWCAPIStates','on');
      elseif ~isequal(iMdlRefTgtType,'SIM')
        % Do not turn it off for sim target - whether we log or not
        % is controlled by the model that references this one so we
        % need to generate code assuming we are logging (and so not combine
        % output & update and any other optimizations affected by this)
        newTarget.setProp('RTWCAPIStates','off');
      end
    else
      if turnOnRTWCAPIStates
        warning('This target does not support state logging for model reference');
      end
    end  
    
  catch
    hadErrors = true;
  end

  if hadErrors
    err = sllasterror;
    if isempty(err)
      err = lasterror;
      errmsg = err.message;
    else
      errmsg = err.Message;
    end
    ioErrMsg = loc_handle_nag(iNagType, ...
                              errmsg, ...
                              iMdl, ...
                              iOkayToPushNags, ...
                              ioErrMsg);
  end

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ioErrMsg = loc_handle_nag(iType, iMsg, iMdl, iOkayToPushNags, ioErrMsg)

  if iOkayToPushNags
    nag = slprivate('create_nag','Simulink', iType, ...
                    'Model Reference Configuration Check', iMsg, iMdl);
    slsfnagctlr('Naglog', 'push', nag);
  end

  ioErrMsg = [ioErrMsg, sprintf('\n'), iMsg];

%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oConfigSet = loc_create_tmp_configset(h, iMdl)
% cache away the name of the current active config set
  oldConfigSet = getActiveConfigSet(iMdl);
  h.OldConfigSetName = oldConfigSet.Name;
  
  % Now create a new config set by cloing the current
  % configuration set and giving it a unique name.
  oConfigSet = oldConfigSet.copy;
  oConfigSet.Name = 'Model Reference Config Set';
  % Make new config set name unique by appending a digit if needed.
  idx = 1;
  csName = getConfigSet(iMdl, oConfigSet.Name);
  while ~isempty(csName)
    oConfigSet.Name = ['Model Reference Config Set' num2str(idx)];
    csName = getConfigSet(iMdl, oConfigSet.Name);
    idx = idx + 1;
  end
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loc_attach_tmp_configset(iMdl, iConfigSet, h)
  attachConfigSet(iMdl, iConfigSet);
  setActiveConfigSet(iMdl, iConfigSet.Name);
  h.OldConfigSetInactive = 1;
%endfunction
