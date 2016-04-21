function make_rtw(h, varargin)
% MAKE_RTW is the main method of RTW.makertw class. It executes same
% functionality as original make_rtw function.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.20 $  $Date: 2004/04/15 00:24:00 $

  h.OldConfigSetInactive = 0;

  % check directory
  CheckDir(h);

  % Parse the build arguments %
  ParseBuildArgs(h, varargin);

  % Initialize the name of the current config set.
  modelName = h.ModelName;
  cs = getActiveConfigSet(modelName);
  h.OldConfigSetName = cs.Name;
  
  % Assume that the RTW code will be generated, if this is
  % not true, the parameter will be set to 'off' later in this file.
  set_param(modelName, 'RTWCodeWasGenerated','on');
  
  % Cache original data
  CacheOriginalData(h);

  % prepare for accelerator mode and s-function generation
  PrepareAcceleratorAndSFunction(h);
  
  %
  % All the build procedure is wrapped in a try .. catch so that if any errors
  % occur in this function or in any of the other functions called from here,
  % they all fall through to the catch, where we restore the cached lock and
  % dirty flags and re-echo the error that occured during try.
  %
  try
    isMdlRefSim = strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM');
    if isMdlRefSim
      setup_config_set_for_model_reference(h, true);  
      cs = getActiveConfigSet(modelName);
    end
    
    %% Make sure model reference SIM is using modelrefsim.tlc
    if strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM')
      tmpTg = cs.getProp('SystemTargetFile');
      if ~strcmp(cs.getProp('SystemTargetFile'), 'modelrefsim.tlc')
        errmsg = ['Internal error: Model reference sim target ', ...
                  '(modelrefsim.tlc != ', tmpTg,')'];
        error(errmsg);
      end
    end

    set_param(modelName, 'MakeRTWSettingsObject',h);

    anchorDir = pwd;

    % Get the system target file
    GetSystemTargetFile(h);

    inbat = rtwprivate('rtwinbat');
    notMdlRef = strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'NONE');
    isERT = strcmp(cs.getProp('IsERTTarget'), 'on');

    % Call user defined RTW hook entry method, and issue start build message by
    % default
    Enter(h);
    if isERT
      if ~isMdlRefSim && (~ecoderinstalled(h.ModelName) ...
                          || ~exist('ec_mpt_enabled', 'file'))
        error(['You must install Real-Time Workshop Embedded Coder ',...
               'in order to generate code for an ERT-based Real-Time ',...
               'Workshop target.  The current target is: ', h.SystemTargetFilename])
      end
      make_ecoder_hook('entry',h,cs);
    end

    hardware = cs.getComponent('Hardware Implementation');
    hf = rtwprivate('get_rtw_info_hook_file_name',modelName);
    if strcmp(hardware.TargetUnknown, 'off') & hf.FileExists & ~inbat && notMdlRef
      %  warning(['An obsolete rtw_info_hook file "' hf.HookFileName '" is found.', ...
      %           '  Information in this file is not used in this code generation.']);
      disp(['Note: An obsolete rtw_info_hook file "' hf.HookFileName '" is found.', ...
            '  Information in this file is not used in this code generation.']);
      
    end
    
    if strcmp(hardware.TargetUnknown, 'on')
      if hf.FileExists
        disp(['Note: The target hardware implementation details has been read ',...
              'automatically from the RTW hook file: ', ...
              hf.HookFileName, '.  You need to save the model to migrate this ',...
              'information permanently.']);
        slprivate('setHardwareDevice', hardware, 'Target', '32-bit Generic');
        rtwprivate('importHardwareFromHook', hardware, hf.HookFileName, modelName);
      else
        warnmsg = sprintf(['\nReal-Time Workshop utilizes device specific information (e.g., ', ...
                           'microprocessor word sizes) to reproduce a bit true representation ', ...
                           'of the diagram.  This information is not specified in this model. ', ...
                           'If you continue, Real-Time Workshop will use a 32-bit Generic ',...
                           'target setting.\n\n']);
        if ~inbat && notMdlRef
          %warning(warnmsg);
          disp(warnmsg);
          slprivate('setHardwareDevice', hardware, 'Target', '32-bit Generic');
        else
          slprivate('setHardwareDevice', hardware, 'Target', '32-bit Generic');
        end
      end
    end
    
    % Update the model's configuration set (if building model reference target)
    % if necessary and compare the config set of this model to any submodels
    % that exist.
    if ~h.InitRTWOptsAndGenSettingsOnly
      setup_config_set_for_model_reference(h, false);
    end
    cs = getActiveConfigSet(modelName);
    
    % Configure the RTWGenSettings and RTWOptions as well as other items
    % needed for running TLC.
    [tlcArgs, gensettings, rtwVerbose, codeFormat] = ConfigForTLC(h);

    % Lock down active configuration set; after this point,
    % most set_param will not be successful
    configSet = getActiveConfigSet(h.ModelName);
    lock(configSet);
    hDlg = get_param(h.ModelName, 'SimPrmDialog');
    if ~isempty(hDlg) & isa(hDlg, 'DAStudio.Dialog')
      refresh(hDlg);
    end

    % if not specified init RTWGenSettings and RTWOptions only
    if ~h.InitRTWOptsAndGenSettingsOnly

      % Continue with build configuration
      PrepareBuildArgs(h, tlcArgs, gensettings, rtwVerbose);

      % Focus on command window on PC
      if (ispc)
  	system_dependent('ShowCommandWindow')
      end

      dispOpts.rtwVerbose = rtwVerbose;
      dispOpts.DispHook   = h.DispHook;

      % Get the saved checksum either from the buildArgs (ie it was
      % passed into slbuild), or load it from the binary mat file.
      % Pass the checksum into tlc_c to compare against the current
      % checksum after rtwgen to see if we need to generate code.
      [checksum, infoStruct] = ...
          LocGetChecksumAndInfoStruct(h, anchorDir, ~notMdlRef);

      % Save matfile
      curinfoStruct = rtwprivate('rtwinfomatman',anchorDir,'saveAndcheckSharedUtils','binary', ...
                                 h.ModelName,h.MdlRefBuildArgs.ModelReferenceTargetType);

	
	  % Cache away for Stateflow
	  h.BuildOpts.codeFormat = codeFormat;
	  
      %-----------------------------------------------------------------------%
      % Invoke the Target Language Compiler to generate the specific language %
      %-----------------------------------------------------------------------%
      buildRes = tlc_c(h,...
                       h.ModelName, ...
                       h.RTWRoot, ...
                       h.SystemTargetFilename, ...
                       dispOpts, ...
                       tlcArgs, ...
                       h.BuildDirectory, ...
                       codeFormat,...
                       h.MdlRefBuildArgs, ...
                       anchorDir, checksum);

      % If we don't need to build then resave the old infoStruct
      % in the binary file.  Also set the bd parameter to false
      % to indicate that the build was aborted.  This parameter
      % is read in
      %  toolbox/simulink/simulink/private/update_model_reference_targets.m
      if buildRes.buildNotNeeded
        set_param(modelName, 'RTWCodeWasGenerated','off');
        if ~isempty(infoStruct)
          curinfoStruct = rtwprivate('rtwinfomatman',anchorDir,'save','binary', ...
                                     h.ModelName, ...
                                     h.MdlRefBuildArgs.ModelReferenceTargetType,...
                                     infoStruct);
        end
      else

        % Call user defined RTW hook after_tlc_build method
        AfterTLCBuild(h);
        if isERT
          make_ecoder_hook('after_tlc',h,cs);
        end

        % Generate HTML report if neccesary
        genHTMLreport(h);

        % buildRes = { rtwFile, modules, noninlinedSFcns, listSFcns }
        h.BuildOpts = CreateBuildOpts(h, h.ModelHandle, h.SystemTargetFilename, ...
                                      h.RTWRoot, rtwVerbose, h.CompilerEnvVal, ...
                                      buildRes,codeFormat);

        % Call user defined RTW hook before_make method
        BeforeMake(h);
        if isERT
          make_ecoder_hook('before_make',h,cs);
        end

        % creates a makefile from the templateMakefile which is then used by
        % make to create the image
        rtw_c(h,...
              h.ModelName, ...
              h.RTWRoot, ...
              h.TemplateMakefile, ...
              h.BuildOpts, ...
              h.BuildArgs,...
              curinfoStruct);

        % Call user defined RTW hook after_make method
        AfterMake(h);
        if isERT
          make_ecoder_hook('after_make',h,cs);
        end

        % Call user defined RTW hook exit method
        Exit(h);
        if isERT
          make_ecoder_hook('exit',h,cs);
        end

      end
    end
  catch

    % An error occured above, clean up and error out again, echoing the last
    % error.  Also, since this is not a valid build, clear out the checksum
    % from the binary info file so we will try to rebuild the next time.
    checksum = [];
    curinfoStruct = rtwprivate('rtwinfomatman',anchorDir,'addChecksum','binary', ...
                               h.ModelName,h.MdlRefBuildArgs.ModelReferenceTargetType,...
                               checksum);
    set_param(modelName, 'RTWCodeWasGenerated','off');
    CleanupForExit(h);
    error('%s', lasterr);
  end

  % Restore settings (locked and dirty flags, start time, and code reuse
  % feature) before exit and restore working directory.
  CleanupForExit(h);

%endfunction make_rtw


%------------------------------------------------------------------------------
function [oChecksum, oInfoStruct] = LocGetChecksumAndInfoStruct(h, anchorDir, ...
                                                    isMdlRef)
  oChecksum   = [];
  oInfoStruct = [];

  %% For model reference targets, we try to load the checksum
  %% from the saved binary info file.  But if a checksum was
  %% passed into this function, then use that value for the comparison.
  %% If the buildargs says not to use the checksum then return an empty array.
  if h.MdlRefBuildArgs.UseChecksum && ...
        (isMdlRef || ~isempty(h.MdlRefBuildArgs.StoredChecksum))
    oChecksum = h.MdlRefBuildArgs.StoredChecksum;

    try
      oInfoStruct = rtwprivate('rtwinfomatman',anchorDir,'load','binary', ...
                               h.ModelName,h.MdlRefBuildArgs.ModelReferenceTargetType);
      if isempty(oChecksum)
        oChecksum = oInfoStruct.checkSum;
      end
    catch
      oInfoStruct = [];
    end
  end
  
%endfunction
