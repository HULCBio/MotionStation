function [oHadErr, oErrMsg, oRebuild, oReason, oUseChecksum] = ...
    configure_model_reference_target_status(iMdl, ...
                                            iMdlList, ...
                                            iTargetType, ...
                                            iVerbose, ...
                                            iOkayToPushNags, ...
                                            iStatus, ...
                                            iUpdateControl)
% Abstract
%   Determine if the input model (iMdl) should be rebuilt or not.
%   If it should rebuild, should we use the checksum to
%   skip unecessary rebuild or not (oUseChecksum = true).
%
% Inputs
%
%   iMdl     : (string)  name of the model to check
%   iMdlList : (cellstr) list of all the models in the hierarchy
%   iTargetType : (string) 'SIM' or 'RTW'
%   iVerbose : (bool) build is verbose
%   iOkayToPushNags : (bool) is ok to push nags?
%   iStatus : (int array) the build status of all the models so far,
%                         a 1 indicates the model was rebuilt
%   iUpdateControl: Rebuild target option
%
% Outputs
%
%   oRebuild : (logical) 
%          oRebuild == false => iMdl is up to date (no build is required)
%          oRebuild  == true => iMdl may be out of date, try to rebuild.
%
%   oReason : (string)   Explaination of the model status. Useful for
%                         display and error messages.
%   
%   oUseChecksum : (bool) Ignored if oRebuild is false.
%                         True if the build process should abort if
%                         the checksums match with the previous build.
%
%   Possible enahancements:  Currently we only report one reason that a rebuild
%   is needed, we should probably return all the reasons to make it easier
%   for the user.  Also, could we update the time stamp on the target if
%   we find that the checksums have matched?  This would avoid doing the
%   check the next time we try to build.
%

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $

  oHadErr      = false;
  oErrMsg      = '';
  oRebuild     = false;
  oReason      = '';
  oUseChecksum = false;

  
  if isequal(iUpdateControl, 'Force')
    oRebuild     = true;
    oUseChecksum = false;
    oReason      = 'Rebuild option is set to ''Always''';
  else
    %   locStatus:
    %       3: Must rebuild 
    %       2: Time stamp change detected, can use checksum to skip rebuild
    %       1: Can use checksum to skip rebuild
    %       0: Every thing is OK. No changes is detected.

    [oHadErr, oErrMsg, locStatus, oReason] = configure_model_reference_target_status_helper(...
        iMdl, iMdlList, iTargetType, iVerbose, iOkayToPushNags,iStatus);
    
    if oHadErr, return; end

    % Make sure oRebuild and oUseChecksum are set by the following logic
    switch locStatus
     case 0
      % No changes is detected.
      if isequal(iUpdateControl, 'IfOutOfDateOrStructuralChange')
        % Even though no change is detected, try to rebuild and
        % detect any checksum change
        oRebuild     = true;
        oUseChecksum = true;
        oReason = ['Checking for structural changes in ', iMdl, ' because ', ...
                   'the model reference rebuild option is set to ''', ...
                   'If any changes detected''', '. Structutal changes will ' ...
                   'cause the model reference ', iTargetType, ...
                   ' target to be rebuilt'];
      else
        oRebuild     = false;
        oUseChecksum = false;
        oReason = ['Model reference ', iTargetType, ' target for ', ...
                   iMdl, ' is up to date'];
      end
      
     case 1
      % Can use checksum to skip rebuild
      oRebuild     = true;
      oUseChecksum = true;
      
     case 2
      % Time stamp change detected, can use checksum to skip rebuild
      oRebuild = true;
      if isequal(iUpdateControl, 'IfOutOfDateOrStructuralChange')
        % Since time stamp change is detected, force a rebuild, and
        % do not do checksum comparison
        oUseChecksum = false;
      else
        oUseChecksum = true;
      end
      
     case 3
      % force to rebuild
      oRebuild = true;
      oUseChecksum = false;
      
     otherwise
      error('Invalid status in configure_model_reference_target_status');
    end
  end
  
%endfunction 
  
%function  configure_model_reference_target_status_helper ---------------------
%
% Outputs
%  oStatus = 
%   3: Must rebuild
%   2: Time stamp change detected, can use checksum to skip rebuild
%   1: Can use checksum to skip rebuild
%   0: Every thing is OK. No changes is detected.
%
% oReason: Explaination of the model status. Useful for
%                         display and error messages.
%
% Abstarct:
%   
%   Since we check for the worst cases first, we will return as soon as
%   we identify a valid value for the oState.
%
%   *** The following forces a rebuild (oStatus = 3)
%     3.1. If the target (model_msf.mexext) does not exist.
%     3.2. The binfo file does not exist.
%     3.3. If any of the user supplied dependencies have been updated.
%     3.4. If any of the global parameters have changed.
%     3.5. If any submodels have been rebuilt.
%     3.6. If any submodels are newer than the target.
%     3.7. If any of the files (.mex, .m, .tlc etc) associated with user
%        S-Functions used in iMdl are newer than the target.
%
%   *** The following sets the oStatus to 2
%     - 2.1. If the minfo file is newer than the target.  This can happen when
%         - the .mdl file is newer than the target.
%         - any libraries used in iMdl is newer than the target
%
%   *** The following sets the oStatus to 1
%     - 1.1. If model is set up to resolve all signal labels / state names.
%
function [oHadErr, oErrMsg, oStatus, oReason] = ...
    configure_model_reference_target_status_helper(iMdl, ...
                                            iMdlList, ...
                                            iTargetType, ...
                                            iVerbose, ...
                                            iOkayToPushNags, ...
                                            iStatus)
  % initialize oStatus to invalid values.
  oHadErr = false;
  oErrMsg = '';
  oStatus = -1;
  oReason = '';
  
  % Load cached info about this model (so that
  % we do not have to load this model again).
  anchorDir = pwd;
  minfo_cache=rtwprivate('rtwinfomatman',anchorDir,'load','minfo',iMdl,iTargetType);

  %%%%%%%%%%%%%%%% START OF oStatus = 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  oStatus = 3;  
  try
    binfo_cache = rtwprivate('rtwinfomatman', anchorDir,'loadNoConfigSet', ...
                             'binfo', iMdl, iTargetType);
  catch
    binfo_cache = [];
  end

  genCodeOnly = isfield(minfo_cache,'genCodeOnly') && minfo_cache.genCodeOnly;
  tgt = loc_get_model_reference_target_name(iMdl, iTargetType, genCodeOnly);
  tgtDate = sl_get_file_date(tgt);
  
  preamble = ['Model reference ', iTargetType, ' target (', tgt, ') for ', ...
              'model ', iMdl, ' is out of date because '];

  % Reason #3.1:
  %    If the target does not exist then it is out of date
  if isempty(tgtDate)
    oReason = [preamble, tgt, ' does not exist '];
    return;
  end

  % cache the tgt time stamp
  tgtDateNum = datenum(tgtDate);

  % Reason #3.2:
  % Either the binfo file does not exist.  This may mean
  % that the slprj directory has been deleted (since the
  % target still exists in Reason #1 check.
  if isempty(binfo_cache) || isempty(binfo_cache.modelInterface)
    oReason = [preamble, 'the binary information cache does not ', ...
               'contain necessary information.  This may indicate ', ...
               'the slprj directory has been removed or a previous build ', ...
               'of this model was not successful'];
    return;
  end
  
  
  % Reason #3.3:
  %   If any dependencies of mdl are newer than tgt, then tgt is out of date
  mdlDeps = minfo_cache.mdlDeps;
  [oHadErr, oErrMsg, newDep] = loc_check_for_newer_deps(iMdl, ...
                                                    mdlDeps, ...
                                                    tgtDateNum, ...
                                                    iVerbose, ...
                                                    iOkayToPushNags);
  if oHadErr, return; end

  if ~isempty(newDep)
    oReason = [preamble, newDep, ' (dependency of model ', ...
               iMdl, ') is newer than ', tgt];
    return;
  end
  
  % Reason #3.4:
  %   If the global variable checksums don't match, then tgt is out of date
  [isCompatible, globalVarList] = loc_globalvars_compatible(binfo_cache);

  if ~isCompatible
    oReason = [preamble, 'global variables used by this model ', ...
               'are incompatible with the variables that were ', ...
               'in the base workspace when the target was generated. ', ...
               'This model uses global variable(s): ''', globalVarList, ''''];
    return;
  end

  % Now check the status of the tgt w.r.t the models it imports
  % Note that list of imported model references in mdl should
  % have been cached by now.
  mdlRefs  = minfo_cache.modelRefs;
  nMdlRefs = length(mdlRefs);

  % check if any of the models in mdlRefs are out of date.
  for j = 1:nMdlRefs,

    mdlRef = mdlRefs{j};

    % mdlRef should be before mdl in iMdlList
    % => we have already determined the status of mdlRefTgt

    idx = strmatch(mdlRef, iMdlList, 'exact');
    % DEBUG ASSERT: idx != []

    mdlRefStatus = iStatus(idx);
    % DEBUG ASSERT: mdlRefStatus != -1

    % Reason #3.5:
    %  If any submodels have been rebuilt, then this model is out of date
    if mdlRefStatus == 1,
      % model referenced in iMdlList{i} has been rebuilt
      % => iMdlList{i} has been rebuilt
      oReason = [preamble, 'the referenced model ', mdlRef, ' has been rebuilt'];
      return;
    end

    % if we get here then the target for mdlRef is up to date ...
    % now check if mdlRfTgt is newer than tgt, in that case tgt is out of date
    mdlRefTgt = loc_get_model_reference_target_name(mdlRef, iTargetType,genCodeOnly);

    % Reason #3.6:
    %  If any submodels are newer than the target.
    mdlRefTgtDate = sl_get_file_date(mdlRefTgt);
    if isempty(mdlRefTgtDate)
      error(['Internal error: Model reference target ''', mdlRefTgt, ...
             ''' does not exist']);
    end
    if tgtDateNum < datenum(mdlRefTgtDate)
      oReason = [preamble, 'the target for the referenced model ', ...
                 mdlRef, ' (', mdlRefTgt , ') is newer than ', tgt];
      return;
    end

  end % of loop over mdlRefs

  % Reason #3.7:
  %   If any of the files (.mex, .m, .tlc etc) associated with
  %   user S-Functions used in iMdl are newer than the target.

  sfcnInfo = -1; % invalid value
  if ~isempty(binfo_cache), 
    sfcnInfo = binfo_cache.sfcnInfo; 
  end
  
  if isequal(sfcnInfo,-1)
    binfoMatFileName =  fullfile(anchorDir, binfo_cache.matFileName);
    oReason = [preamble, 'the information pertaining to S-Functions ', ...
               'used in model ', iMdl, ' in the model info file ''', ...
               binfoMatFileName, ''' is not up to date'];
    return;
  end
  if ~isempty(sfcnInfo)
    for i = 1:length(sfcnInfo)
      thisSfcnInfo =  sfcnInfo(i);
      sfcnName  = thisSfcnInfo.FunctionName;
      sfcnFile  = which(sfcnName); % m or mex file that implements sfcnName
      if isempty(sfcnFile)
        %% Do not report an error. We may not be able to find the s-function
        msg = ['S-Function ', sfcnName , ...
               ' (used in block ''', thisSfcnInfo.Block, ''') does not exist'];
        sl_disp_info(iOkayToPushNags, msg, iMdl, iVerbose);
        continue;
      end
      sfcnFiles = {sfcnFile};
      
      if ~isempty(thisSfcnInfo.TLCDir) % => inlined
        sfcnDir = fileparts(sfcnFile);
        tlcDir  = strrep(thisSfcnInfo.TLCDir, '<SFCNDIR>', sfcnDir);
        tlcFile = [tlcDir, filesep, sfcnName, '.tlc'];
        
        sfcnFiles = [sfcnFiles, {tlcFile}];
      end
      
      if ~isempty(thisSfcnInfo.Modules)
        sfcnFiles = [sfcnFiles, thisSfcnInfo.Modules];
      end

      for j = 1:length(sfcnFiles)
        sfcnFileDate = sl_get_file_date(sfcnFiles{j});
        
        if isempty(sfcnFileDate)
          %% Do not report an error. We may not be able to find
          %% s-function modules
          msg = ['File ', sfcnFiles{j}, ' associated with S-Function ''', ...
                 sfcnName, '''(used in ''', ...
                 thisSfcnInfo.Block, ''') does not exist'];
          sl_disp_info(iOkayToPushNags, msg, iMdl, iVerbose);
          continue;
        end

        if tgtDateNum < datenum(sfcnFileDate)
          oReason = [preamble, 'the file ', sfcnFiles{j}, ...
                     ' associated with S-Function ''', ...
                     sfcnName, ''' (used in ''', ...
                     thisSfcnInfo.Block, ''') is newer than ', tgt];
          return;
        end
      end
    end
  end
  
  %%%%%%%%%%%%%%%% START OF oStatus = 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  oStatus = 2;  
  
  % Reason 2.1:
  %   If minfo.mat is newer than tgt then tgt is out of date.  In this
  %   case, we can use the checksum to see if a build is really needed.
  %   Note that if mdl (or libs referenced in mdl) are newer than minfo.mat
  %   then we regenerate minfo.mat => minfo.mat will be newer than tgt.
  %   Hence we need not explicitly check if mdl (or libs) is newer than tgt.
  matFile = fullfile(anchorDir, minfo_cache.matFileName);
  [matFileExists, matFileNewer] = sl_file_is_newer(matFile, tgtDateNum);
  
  if ~matFileExists
    error(['Internal error: Information mat file ''', matFile, ...
           ''' does not exist']);
  end
  if matFileNewer
    oReason = [preamble, 'the model information cache has been ', ...
               'updated.  This may indicate the model or libaray files ', ...
               'have been resaved ', ...
               '(the model info file ''', matFile, ''' is ', ...
               'newer than ', tgt, ')'];
    return;
  end

  %%%%%%%%%%%%%%%% START OF oStatus = 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  oStatus = 1;  

  % Reason #1.1:
  %   If SignalResolutionControl is "TryResolveAll*" we can not trust the
  %   global varList checksum so we need to check the structural checksum.
  if ~isempty(findstr(minfo_cache.signalResolutionControl, 'TryResolveAll'))
    oReason = [preamble, 'it is configured to resolve signal objects for ', ...
               'all named signal and states. To speed up code generation ', ...
               'and eliminate this message, set SignalResolutionControl ', ...
               'to ''UseLocalSettings'' on the Diagnostics/Data Integrity ', ...
               'page of the Configuration Parameters dialog'];
    return;
  end
  
  %%%%%%%%%%%%%%%% START OF oStatus = 0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  oStatus = 0;  

%endfunction configure_model_reference_target_status


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oTarget = loc_get_model_reference_target_name(iMdl, iTargetType, genCodeOnly)
  % genCodeOnly is only valid for rtw target. For Sim target, we always generate
  % .dd (.mex)
  if strcmp(iTargetType, 'SIM')
    oTarget = rtwprivate('modelrefutil', iMdl, 'getSimTargetName');
  else
    oTarget = rtwprivate('modelrefutil', iMdl, 'getRTWTargetFullName', genCodeOnly);
  end

%endfunction



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [oHadErr, oErrMsg, oNewDep] = loc_check_for_newer_deps(iMdl, ...
                                                    iMdlDeps, ...
                                                    iTgtDateNum, ...
                                                    iVerbose, ...
                                                    iOkayToPushNags)
  oNewDep = '';
  oErrMsg = '';
  oHadErr = false;

  mdlDir = get_mdl_dir(iMdl);
  nMdlDeps = length(iMdlDeps);

  for i = 1:nMdlDeps
    dep = iMdlDeps{i};

    % if dep is of the form $MDL/xxx/d.m then replace
    % $MDL with the dir where iMDL is located.

    if ~isempty(regexp(dep, '^\$MDL.*', 'once'))
      dep = strrep(dep, '$MDL', mdlDir);
    end

    % locate dep first using dir and then look on the MATLAB path.
    depInfo = dir(dep);
    if isempty(depInfo)
      tmpDep = which(dep);
      if ~isempty(tmpDep), 
        dep     = tmpDep;
        depInfo = dir(dep); 
      end
    end

    if isempty(depInfo)
      oMsg = ['Ignoring dependency ''', dep, ''' for model ', ...
              iMdl, ' because it could not be found'];
      if iOkayToPushNags,
        loc_push_nag('Warning', oMsg, iMdl);
      end
      warning([oMsg, cr]);
      continue; % to the next entry in iMdlDeps
    end

    if length(depInfo) == 1

      % we should only get here for a single file
      if depInfo.isdir
        oHadErr = 1;
        oErrMsg = ['Internal error: Invalid dependency ', ...
                   dep, ' for model ', iMdl];
        if iOkayToPushNags,
          loc_push_nag('Error', oErrMsg, iMdl);
        end
        return;
      end

      sl_disp_info(iOkayToPushNags, ['Checking dependency ''', dep, ...
                          ''' for model ', iMdl], iMdl, iVerbose);

      [depExists, depIsNewer] = sl_file_is_newer(dep, iTgtDateNum);
      if ~depExists
        error(['Internal error: dependecy file ''', dep, ''' does not exist']);
      end
      
      if depIsNewer
        oNewDep = dep;
        return;
      end
      continue; % to the next entry in iMdlDeps
    end

    % if we are here, it mean that there are multiple entries in depInfo
    % this happens either when dep is a directory or if dep has wildcards
    % like 'a/b/*.m'

    deps = {depInfo(~[depInfo.isdir]).name}; % do not dive into sub-dirs of dep
    ndeps = length(deps);

    if ndeps == 0,
      sl_disp_info(iOkayToPushNags, ...
                   ['Ignoring directory dependency ''',dep,''' for model ', ...
                    iMdl, ' because it has no files'], iMdl, iVerbose);
      continue;
    end

    % append dep to the contents of dep, since dir does not do that for us
    if ~isdir(dep),
      [dep, tmp1, tmp2, tmp3] = fileparts(dep);
    end
    deps = strcat(repmat({[dep, filesep]}, 1, ndeps), deps);

    % recurse
    [oHadErr, oErrMsg, oNewDep] = loc_check_for_newer_deps(iMdl, ...
                                                      deps, ...
                                                      iTgtDateNum, ...
                                                      iVerbose, ...
                                                      iOkayToPushNags);
    if oHadErr || ~isempty(oNewDep) , return; end
  end

%endfunction loc_check_for_newer_deps

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isEqual, varList] = loc_globalvars_compatible(binfo_cache)

  % NOTE: binfo_cache.modelInterface.globalParamInfo can be empty if
  % there was a failure during the build process the last time this
  % model was built.
  if (isempty(binfo_cache) || isempty(binfo_cache.modelInterface))
    %% Since we check for this logic before checking the global variables,
    %% we should not reach to this point.
    isEqual = false;
    varList = '(unknown)';
    return;
  end

  globalParamInfo = binfo_cache.modelInterface.GlobalParamInfo;

  isEqual = true;

  varList = globalParamInfo.VarList;
  if ~isempty(varList)
    ignoreCSCs = binfo_cache.modelInterface.IgnoreCustomStorageClasses;
    checksum   = globalParamInfo.Checksum;

    % Create temporary model
    hTmp = new_system;

    % Set certain properties to ensure consistency:
    % - InlineParameters must be ON.
    % - Copy over IgnoreCustomStorageClasses from original model.
    hConfigSet = getActiveConfigSet(hTmp);
    hConfigSet.set_param('InlineParams', 'on');

    tmpIgnoreCSCs = double(strcmp(...
        hConfigSet.get_param('IgnoreCustomStorageClasses'), 'on'));

    if (tmpIgnoreCSCs ~= ignoreCSCs)
      % NOTE: Target must be ert-based to set IgnoreCustomStorageClasses.
      hConfigSet.switchTarget('ert.tlc', []);
      hConfigSet.set_param('IgnoreCustomStorageClasses', ignoreCSCs);
    end

    set_param(hTmp, 'GlobalParamsListForChecksumCheck', varList);
    isEqual = isequal(get_param(hTmp, 'ChecksumForGlobalParamsList'), checksum);
    bdclose(hTmp);

    isEqual = isEqual && loc_csc_compatible(binfo_cache);
  end

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isEqual = loc_csc_compatible(binfo_cache)
% Comparing custom storage class registration file timestamp.

  sOldTimeStamps = binfo_cache.cscTimeStamps;
  sNewTimeStamps = processcsc('GetCSCTimeStamps');

  isEqual = isequal(sOldTimeStamps, sNewTimeStamps);

%endfunction loc_csc_compatible()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loc_push_nag(iType, iMsg, iMdl)

  nag = create_nag('Simulink', iType, ...
                   'Model Reference Target Update', ...
                   iMsg, iMdl);
  slsfnagctlr('Naglog', 'push', nag);

%endfunction

% eof
