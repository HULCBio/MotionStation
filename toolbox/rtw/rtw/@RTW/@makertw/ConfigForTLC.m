function [tlcArgs,gensettings,rtwVerbose,codeFormat] = ConfigForTLC(h)
% CONFIGUREFORTLC:
%	Configure the
%          RTWGenSettings
%       and
%          RTWOptions
%       as well as other items needed for running TLC.
%
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2004/04/15 00:23:45 $

% Order of combines:
%   1) Common opts
%   2) System target file
%   3) RTWOptions parameter
% We do the first three in reverse order due to the way
% private/combinestruct.m works.  See comments in that file for more
% information.
%   4) RTWMakeCommand arguments for backwards compatibility

% Get code generation options from the existing system target file.
[optionsTargetFile, gensettings] = rtwprivate('tfile_optarr',h.SystemTargetFileId);
fclose(h.SystemTargetFileId); % we don't need the target file any more


% For Tornado target or other STF that have CodeFormat as an RTW
% option, check RTW options for whether RealTime or
% RealTimeMalloc CodeFormat will be used, then set UsingMalloc flag in
% gensettings appropriately.
% Need this here when one STF is used for two CodeFormats since we
% need to propagate UsingMalloc flag to RTW gensettings for Simulink
% to be aware of it.
overloadCodeFormat = '';
if isfield(gensettings,'UsingMalloc') & ...
        strcmp(gensettings.UsingMalloc,'if_RealTimeMalloc')
    tmpoptions = get_param(h.ModelHandle,'RTWOptions');
    if length(findstr(tmpoptions,'RealTimeMalloc')) > 0
        gensettings.UsingMalloc = 'yes';
        overloadCodeFormat = 'RealTimeMalloc';
    else
        gensettings.UsingMalloc = 'no';
    end
end

% Clean up extra options that does not belong to the target or the commont options
configset = getActiveConfigSet(h.ModelHandle);
configset.extraOptions = '';
rtwOptions = get_param(h.ModelHandle, 'RTWOptions');

rtwOptionsArray = rtwprivate('optstr_struct', rtwOptions);
optionsArray    = rtwOptionsArray;

%--------------------------------------------------------------------------%
% Get the TargetType (RT or NRT) and Language from the system target file  %
%     %assign TargetType  = "<RT | NRT>" 	  		               %
%     %assign Language    = "<lang>"                                       %
%--------------------------------------------------------------------------%

[tlcTargetType,tlcLanguage, codeFormat, matFileLogging, ...
        maxStackSize, maxStackVariableSize, divideStackByRate] = ...
    LocGetOptionsFromTargetFile(h, h.SystemTargetFileName, rtwOptionsArray);

% Tornado target overlaods CodeFormat (see 'if_RealTimeMalloc' above)
if ~strcmp(overloadCodeFormat,'')
    codeFormat = overloadCodeFormat;
end

gensettings = CacheBuildDirectory(h,gensettings);

gensettings.MaxStackSize         = num2str(maxStackSize);
gensettings.MaxStackVariableSize = num2str(maxStackVariableSize);
gensettings.DivideStackByRate    = num2str(divideStackByRate);

currentDirtyFlag = get_param(h.ModelHandle,'Dirty');
set_param(h.ModelHandle, 'RTWGenSettings',gensettings);
CleanupDirtyFlag(h, h.ModelHandle,currentDirtyFlag)

%---------------------------------------%
% Get target type from specified solver %
%---------------------------------------%
modelName = h.ModelName;

targetType = LocMapSolverToTargetType(h, h.ModelHandle, ...
    get_param(h.ModelHandle,'Solver'), ...
    tlcTargetType);

%language=h.languageDir;
%language(1) = char(h.languageDir(1)-32);
language = 'C';
if ~strcmp(tlcLanguage,language)
    error('%s', ['The system target file is configured for language ', ...
            tlcLanguage, ...
            ' whereas ', modelName, ' is configured for ', language]);
end

% Get RTWVerbose settings from the rtw options
%check optionsArray to see if RTWVerbose has been defined already
if (rtwprivate('isval', optionsArray, 'name', 'RTWVerbose'))
    location = rtwprivate('array_index', optionsArray, 'name', 'RTWVerbose');
    rtwVerbose = str2num(optionsArray(location).value);
else
    % If the user explicitly set this variable, then we set it above;
    % Else, we set it to the default (which is also the default in
    % commonsetup.ttlc)
    rtwVerbose = 1;
end


%-------------------%
% Setup TLC options %
%-------------------%

extraOptions = [];

opt.name = 'InlineParameters';
opt.value = strcmp(get_param(h.ModelHandle,'RTWInlineParameters'),'on');
extraOptions = [extraOptions ' -a' opt.name '=' num2str(opt.value)];

mdlRef = strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'NONE') == 0;
if (matFileLogging == 0) || mdlRef
  % Don't really need to turn off MatFileLogging in the configset
  % for model reference since this is done elsewhere, but we do
  % need to turn off the global TLC variable, so we'll turn off the
  % configset setting at the same time for completeness.  If we 
  % eventually get rid fo the global TLC var, we can get rid of that
  % superfluous code below effecting the configset setting
  set_param(configset, 'MatFileLogging', 'off');
  extraOptions = [extraOptions ' -aMatFileLogging=0'];
else
  set_param(configset, 'MatFileLogging', 'on');
  extraOptions = [extraOptions ' -aMatFileLogging=1'];
end

extraOptions = fliplr(deblank(fliplr(deblank(extraOptions))));
extraOptionsArray = rtwprivate('optstr_struct', extraOptions);
% Give precedence to options specified in dialog box or target file.
optionsArray = rtwprivate('combinestruct', optionsArray, extraOptionsArray, 'name');

% Do not change the settings for model reference. This may conflict with
% the configset settings specified for the model reference.
if ~mdlRef
  tlcArgsFromMakeArgs = LocMapMakeVarsToTLCVars(h, h.BuildArgs);
  tlcArgsFromMakeArgs = fliplr(deblank(fliplr(deblank(tlcArgsFromMakeArgs))));
  tlcFromMakeArray = rtwprivate('optstr_struct', tlcArgsFromMakeArgs);
  % TLC options from makefile are of highest precedence
  optionsArray = rtwprivate('combinestruct', optionsArray, tlcFromMakeArray, 'name');
  % If MatFileLogging was set, make sure config set is updated
  for i = 1:length(tlcFromMakeArray)
    if strcmp(tlcFromMakeArray(i).name, 'MatFileLogging')
      set_param(configset, 'MatFileLogging', str2num(tlcFromMakeArray(i).value));
    end
  end
end

% get the custom tlc options
% xxx(mdt) - TLCOptions is not necessarily unique
tlcArgs = getProp(getActiveConfigSet(h.ModelHandle), 'TLCOptions');
tlcArgs = [rtwprivate('struct_optstr', optionsArray) ' ' tlcArgs];
% After all the arguments are parsed, set the consolidated InlineParameters
% flag and the RTWOptions string in the model via the set_param API. This is
% required to make TLC and rtwgen look at the same values for these
% attributes

idx = findstr(tlcArgs,'-aInlineParameters=1');
val = 'on';
if isempty(idx),
    val = 'off';
end
set_param(h.ModelHandle, 'RTWInlineParameters', val);

currentDirtyFlag = get_param(h.ModelHandle,'Dirty');
setRTWOptions(getActiveConfigSet(h.ModelHandle), tlcArgs);
tlcArgs = configset.getStringRepresentation('tlc_options');
CleanupDirtyFlag(h, h.ModelHandle,currentDirtyFlag);

%endfunction: ConfigForTLC

function gensettings = CacheBuildDirectory(h,gensettings)
  if isfield(gensettings,'BuildDirSuffix')
    if strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType, 'NONE')
      gensettings.RelativeBuildDir = [h.ModelName, gensettings.BuildDirSuffix];
      h.BuildDirectory = fullfile(GetBuildDirRoot(h.ModelHandle),...
                          gensettings.RelativeBuildDir);

      h.GeneratedTLCSubDir = 'tlc';
      % count how many '/' exists in gensettings.BuildDirSuffix
      buildDirDepth = length(strfind(gensettings.BuildDirSuffix,filesep));
      if buildDirDepth > 0
        % some targets may generate code in different depth from
        % anchorDir, i.e., hc12 target will generate in
        % <pwd>/<model>_hc12rt/sources.
        relativePathToAnchor = '..';
        for dotCounter=1: buildDirDepth
          relativePathToAnchor = [relativePathToAnchor, filesep,'..'];
        end
        infoStruct = rtwprivate('rtwinfomatman',pwd,'updateField','minfo', ...
                                h.ModelName,'NONE','relativePathToAnchor', ...
                                relativePathToAnchor);
      end
    else
      infoStruct = rtwprivate('rtwinfomatman',pwd,'load','minfo', ...
                              h.ModelName, ...
                              h.MdlRefBuildArgs.ModelReferenceTargetType);
      gensettings.RelativeBuildDir = infoStruct.srcCoreDir;
      h.BuildDirectory = fullfile(pwd, gensettings.RelativeBuildDir);
      h.GeneratedTLCSubDir = fullfile('tmwinternal','tlc');
    end
  else
    error(['Unable to locate rtwgensettings.BuildDirSuffix '...
           'within system target file']);
  end
%end CacheBuildDirectory


%%%%%%%%%%%%%%%%%%  HELPERS  %%%%%%%%%%%%%%%%%%
function y = GetBuildDirRoot(iModelHandle)
  try
    y = get_param(iModelHandle, 'RTWBuildDirRoot');
  catch
    y = '';
  end
  
  if isempty(y)
    y = pwd;
  end
  
%endfunction GetBuildDirRoot
