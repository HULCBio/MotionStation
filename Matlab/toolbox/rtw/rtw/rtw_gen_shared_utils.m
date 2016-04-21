function val = rtw_gen_shared_utils(modelName)
%RTW_GEN_SHARED_UTILS Returns whether the build will be using shared utilities.
%
%       For a given model's build, return whether generate code can go to the
%       shared utilities directory or just to the model build directory.  The
%       shared utilities directory is currently used when a model is being
%       referenced by another model (for either either SIM and RTW code gen) or
%       during an RTW build when the model is the top model and it has reference
%       blocks.  For a model unrelated to model reference, it's specified at 
%       Real-Time Workshop Interface page, utility function generation
%       option: selecting 'Auto' means files are generated locally; and
%       selecting 'Shared location' will force the files to be generated
%       into a shared directory.
%
%       Copyright 2003-2004 The MathWorks, Inc.
%       $Revision: 1.1.6.3 $

  % assume a model build unrelated to Model Reference.
  val = false; 
  
  h = get_param(modelName, 'MakeRTWSettingsObject');
  
  if isempty(h)
      % return false when the info isn't available. 
      return;
  end

  if strcmp(uget_param(modelName,'UtilityFuncGeneration'),'Shared location')
      mdlForceSharedLoc = true;
  else
      mdlForceSharedLoc = false;
  end
  
  infoStruct = rtwprivate('rtwinfomatman',h.StartDirToRestore,'load','binary', ...
                          h.ModelName,h.MdlRefBuildArgs.ModelReferenceTargetType);

  if ~strcmp(h.MdlRefBuildArgs.ModelReferenceTargetType,...
             'NONE')  || ~isempty(infoStruct.modelRefs) || mdlForceSharedLoc
    val = true;
  end
%endfunction rtw_gen_shared_utils
