function buildRes = tlc_c(h,...
                          modelName, rtwroot, systemTargetFile, ...
                          dispOpts, tlcArgs, buildDir, codeFormat, ...
                          iMdlRefBuildArgs, anchorDir, iChecksum)
  %TLC_C Private Real-Time Workshop function to generate C code from a model.
  %
  % This is a back-end function for use with the Real-Time Workshop.
  % It is not intended to be directly used or modified. This function is
  % responsible for managing the creation of the *.c and *.h files in the
  % Real-Time Workshop build directory. It will also remove old *.c and *.h
  % files.
  %
  % The normal operation of the Real-Time Workshop assumes that all *.c and *.h
  % files with in the Real-Time Workshop build directory are created during the
  % the TLC process of the Real-Time Workshop build procedure. Third-party
  % targets may also create *.c and *.h files in the build directory. To
  % prevent the Real-Time Workshop from deleting or altering these files,
  % the must be explicitly marked as target specific files by the presence
  % of the string 'target specific file' in the first line of the *.c or *.h
  % file. For example,
  %
  %      /*  COMPANY-NAME target specific file
  %       *
  %       *    This file is created for use with the COMPANY-NAME target. It
  %       *    is used for ...
  %       */
  %      ...
  %
  % This function is designed to be invoked by make_rtw.
  % All arguments (modelName, rtwroot, systemTargetFile, RTWVerbose,
  % tlcArgs, buildDir, codeFormat) are assumed to be present.
  %
  % TLC_C uses rtwgen to generate the model.rtw file which is then converted
  % to C code by the Target Language Compiler.
  %
  % Returns a structure with the following fields:
  %  buildRes.rtwFile
  %       The name of the generated model.rtw file.
  %  buildRes.modules
  %       A string list of additional C modules that were
  %       created excluding the model.c file.
  %  buildRes.noninlinedSFcns
  %       A cell array of S-functions to be compiled and linked with.
  %  buildRes.listSFcns
  %       A cell array of inlined and noninlined S-functions.
  %  buildRes.noninlinednonSFcns
  %       A cell array of functions to be compiled and linked with.
  %  buildRes.buildNotNeeded
  %       A boolean indicating the build was not needed because the
  %       generated code was up to date.
  % See also MAKE_RTW.

  %    Copyright 1994-2004 The MathWorks, Inc.
  %    $Revision: 1.147.4.20 $ $Date: 2004/04/04 03:38:06 $

  %-------------------------------------------%
  % If we have stateflow S-functions, build   %
  % the .tlc files for Version 1.1 and later. %
  % Version 1.06 generates C code             %
  % Do this before rtwgen call so that SF can %
  % cache away optimization info.
  %-------------------------------------------%

  if(~strcmp(codeFormat,'Accelerator_S-Function'))
    sf_rtw('buildStateflowTarget',modelName,codeFormat);
  end

  if isempty(buildDir)
    % This should never occur - make_rtw issues an error if buildDir
    % wasn't specified in the system target file.
    error('Fatal error, buildDir passed to tlc_c is empty');
  end

  %---------------------------------------------------------------------------%
  % create the TFL instance (if it doesn't exist), then clear all of the usage%
  % counts on the Function implementations.  This must be done prior to       %
  % rtwgen(), because the acutual usage of each function implementation is    %
  % counted.  this allows later build optimizations which include only        %
  % generating functions that are used.                                       %
  %---------------------------------------------------------------------------%
  hRtwFcnLib = get_param(modelName,'TargetFcnLibHandle');
  resetFcnImplementationCounts(hRtwFcnLib);

  %---------------%
  % Invoke rtwgen %
  %---------------%
  try
    %% Stash away pre-build dir for use with compile
    preBuildDir = pwd;
    [sfcnsCell,buildInfo,modelrefInfo] = rtwgen(modelName, ...
                                                'PostponeTerm', 'off', ...
                                                'WriteDataRefs', 'on', ...
                                                'CaseSensitivity','on',...
                                                'Language', 'C', ...
                                                'OutputDirectory',buildDir, ...
                                                'MdlRefBuildArgs',iMdlRefBuildArgs);
    buildRes.rtwFile   = [modelName,'.rtw'];
    buildRes.listSFcns = sfcnsCell;
    buildRes.modelrefInfo = modelrefInfo;
    buildRes.buildNotNeeded = false;

    % forget about the string passing in this function; rtwgen may modify configuration
    % set; we need to get the truth.
    cs = getActiveConfigSet(modelName);
    tlcArgs = cs.getStringRepresentation('tlc_options');

    %-----------------------------------------------------------%
    % Get S-functions info:                                     %
    %   sfcnsIncCell       - TLC include paths,                 %
    %   noninlinedSFcns    - noninlined S-functions and modules %
    %   haveStateflowSFcns - 0 or 1                             %
    %-----------------------------------------------------------%

    buildRes.noninlinedSFcns = buildInfo{1};
    buildRes.noninlinednonSFcns = {};
    % buildInfo{1} is a (unique) list of non-inlined S-function names and
    % any additional modules.  Migrate the "additional modules" from the
    % 'buildRes.noninlinedSFcns' to 'buildRes.noninlinednonSFcns'.  To do this,
    % scan for 'SfunctionModules' in the list of s-functions (buildRes.listSFcns)
    % that are exact matches of an entry in buildRes.noninlinedSFcns.

    for i=1:length(buildRes.listSFcns)
      % Only need to search for match in s-functions with 'SfunctionModules'
      if ~isempty(buildRes.listSFcns{i}{4})
        idxTobeCopied = [];
        sfcnBuildName = ...
            deblank(get_param(buildRes.listSFcns{i}{1}, 'SfunctionModules'));
        for j=1:length(buildRes.noninlinedSFcns)
          if(strcmp(sfcnBuildName, buildRes.noninlinedSFcns{j}))
            idxTobeCopied(length(idxTobeCopied)+1)=j;
          end
        end
        % get to-be-removed non-inlinedSFcn list.
        tobeRemoved = {};
        for i=1:length(idxTobeCopied)
          tobeRemoved{i} = buildRes.noninlinedSFcns{idxTobeCopied(i)};
        end
        % remove it
        buildRes.noninlinedSFcns = ...
            setdiff(buildRes.noninlinedSFcns,tobeRemoved);
        buildRes.noninlinednonSFcns = ...
            [buildRes.noninlinednonSFcns,tobeRemoved];
      end
    end
    % done manipulating: buildRes.noninlinedSFcns, buildRes.noninlinednonSFcns

    sfcnsIncCell             = buildInfo{2};
    haveStateflowSFcns       = buildInfo{3} > 0;  % numStateflowSFcns > 0
    currentChecksum          = buildInfo{4};

    targetType = iMdlRefBuildArgs.ModelReferenceTargetType;

    %% If the checksum has not been previously saved, or if the current
    %% checksum does not match the saved checksum, resave the binary file
    %% and rebuild otherwise abort the build procedure.
    if ~isequal(currentChecksum, iChecksum)
      infoStruct = rtwinfomatman(anchorDir, 'addChecksum','binary',modelName,...
                                 targetType, currentChecksum);
    else
      buildRes.buildNotNeeded = true;
      dh = dispOpts.DispHook;
      if strcmpi(targetType, 'NONE')
        msg = sprintf(['\n### Generated code for %s is up to date ',...
                      'because no structural changes exist.'], modelName);
        feval(dh{:},msg);
      else
        msg = sprintf(['\n### Model Reference %s target for %s ',...
                      'is up to date because no structural changes exist.'], ...
                      targetType, modelName);
        
        feval(dh{:},msg);
      end
      DoTermRTWgen(modelName, preBuildDir);
      return;
    end

    % If we are building a model reference target, save a info about
    % s-functions, (such as the sfcn.m or sfcn.dll and sfcn.tlc and
    % any s-function modules that implement the s-function), ot the
    % minfo matfile. We check the time stamp these files to check if
    % we need to rebuild the model referece target. Note that we skip
    % s-functions that live inside matlab/toolbox dir, because are
    % a part of the product that do not change, hence no point checking
    % their time stamps.

    if ~isequal(targetType,'NONE'),
      sfcnInfo = []; idx = 0;
      mlTbxDir = [matlabroot,filesep,'toolbox'];
      for i=1:length(sfcnsCell)
        sfcn = sfcnsCell{i}{2};
        sfcnFile = which(sfcn); % m or mex file that implements sfcn
        sfcnDir  = fileparts(sfcnFile);
        if (findstr(mlTbxDir,sfcnFile) == 1), continue; end
        % skip this sfcn if it is already in sfcnInfo
        if ~isempty(sfcnInfo)
          sfcns = {sfcnInfo(:).FunctionName};
          if ~isempty(strmatch(sfcn,sfcns,'exact')), continue; end
        end
        tlcDir  = '';
        modules = {};
        if sfcnsCell{i}{3} == 1 % => inlined
          tlcDir = sfcnsCell{i}{5};
          if isempty(tlcDir)
            tlcDir = '.';
          else
            tlcDir = strrep(tlcDir,sfcnDir,'<SFCNDIR>');
          end;
          % Add S-Function modules to sfcnFiles
          if ~isempty(sfcnsCell{i}{4})
            modules = ConvertDelimStrToCells(sfcnsCell{i}{4});
          end
        end
        idx = idx+1;
        sfcnInfo(idx).Block = getfullname(sfcnsCell{i}{1});
        sfcnInfo(idx).FunctionName = sfcn;
        sfcnInfo(idx).TLCDir       = tlcDir;
        sfcnInfo(idx).Modules      = modules;
      end
      rtwinfomatman(anchorDir, 'saveSfcnInfo', 'binfo', ...
                    modelName, targetType, sfcnInfo);
    end

    %---------------------------------%
    % Cleanup the RTW build directory %
    %---------------------------------%
    CleanupBuildDir(buildDir, modelName)

    %---------------------%
    % RTW before_tlc hook %
    %---------------------%
    BeforeTLCBuild(h);
    cs = getActiveConfigSet(modelName);
    isERT = strcmp(cs.getProp('IsERTTarget'), 'on');
    if isERT
      make_ecoder_hook('before_tlc',h,cs);
    end

    %------------%
    % Invoke TLC %
    %------------%
    mdlRefTargetType = iMdlRefBuildArgs.ModelReferenceTargetType;
    indentCmd = InvokeTLC(dispOpts, buildDir, modelName, rtwroot, ...
                          systemTargetFile, tlcArgs, sfcnsIncCell, ...
                          mdlRefTargetType,haveStateflowSFcns, ...
                          h.GeneratedTLCSubDir);

    %-----------------------------------------------------------------------%
    % Invoke the implementation callbacks of the Target Function Library.   %
    % May generate code for functions that were accessed during code gen.   %
    %-----------------------------------------------------------------------%
    genDirForTFL = rtwprivate('rtwattic','AtticData','genDirForTFL');
    runFcnImpCallbacks(hRtwFcnLib, modelName, dispOpts, genDirForTFL);
    
    %----------------------------------------------%
    % CD into build directory for indent and build %
    %----------------------------------------------%
    cd(buildDir);

    %-------------------------------------------------------------------------%
    %  For S-function/Accelerator targets, clear the mex file and del the obj %
    %-------------------------------------------------------------------------%
    ClearModelMexAndDeleteObject(modelName, codeFormat, mdlRefTargetType);

    %--------------------------------------------------------------------------%
    % Get modules to indent, build. This doesn't include target specific files %
    %--------------------------------------------------------------------------%
    [moduleList,moduleHeaderList] = GetModulesFromBuildDir(modelName);

    evalc([indentCmd, moduleList],'');  % ignore indent errors
    evalc([indentCmd, moduleHeaderList],'');

    %-------------------------%
    % Create return arguments %
    %-------------------------%

    % Create string list of all modules, including Simulink and Stateflow:
    buildRes.modules = GetBuildModuleList(h, ...
                                          haveStateflowSFcns,...
                                          moduleList,...
                                          sfcnsCell,...
                                          codeFormat,...
                                          mdlRefTargetType);
    DoTermRTWgen(modelName, preBuildDir);
  catch
    %% Switch back to pre-build dir so that we can find all
    %% S-functions and do their terminate
    DoTermRTWgen(modelName, preBuildDir);
    error(lasterr);
  end

%endfunction tlc_c


%----------------------------------------------------------------------%
%                         Local functions                              %
%----------------------------------------------------------------------%

% Function: CleanupBuildDir ====================================================
% Abstract:
%   Delete generated files from a previous build.
%
%   It is assumed that all files were generated by this file
%   unless the file contains in the *first* line:
%      target specific file
%   For example:
%      /*  COMPANY-NAME target specific file
%       *
%       *    This file is created for use with the blah target. It
%       *    is used for ...
%       */
%      ...
%
function CleanupBuildDir(buildDir, modelName)
  cWd = pwd;
  cd(buildDir);

  % On PC, delete .pdb files if DEVSTUDIO_LOC specified.
  % DEVSTUDIO_LOC is an internal compiler definition location
  % the MathWorks uses for testing various versions of the
  % compilers. The .pdb files created by Visual C/C++ are
  % not compatible between different versions of Visual C/C++
  if ~isunix,
    makeCmd = get_param(modelName,'RTWMakeCommand');
    if (length(makeCmd) > 13) && ...
          ~isempty(findstr(makeCmd,'DEVSTUDIO_LOC=')) && ...
          ~isempty(dir('*.pdb'))
      dos('del *.pdb');
    end
  end

  %
  % Delete any existing *.c and *.h files that are generated by
  % TLC.
  %
  DeleteBuildDirFiles('*.c')
  DeleteBuildDirFiles('*.h')
  DeleteBuildDirFiles('*.txt')
  %
  % For the ERT target, delete any generated ert_main object or source files
  %
  if ispc,
    ext='.obj';
  else
    ext='.o';
  end
  objFile = ['ert_main', ext];
  DeleteBuildDirFiles(objFile)

  cd(cWd);

% endfunction CleanupBuildDir


% Function: DeleteBuildDirFiles
% Abstract:
%     Delete specified files from the build directory
%
function DeleteBuildDirFiles(specifiedFiles)
  files = dir(specifiedFiles);

  for fileIdx = 1:length(files)
    deleteFile = true; % assume

    file = files(fileIdx).name;
    fid  = fopen(file,'r');
    if fid == -1,
      error('%s', ['Unable to open ',file]);
    end
    line = fgetl(fid);
    if ischar(line) && ~isempty(findstr('target specific file',line))
      deleteFile = false;
    end
    fclose(fid);

    if deleteFile
      rtw_delete_file(file);
    end
  end

% Function: IsSFcnOrAcceleratorOrModelrefSimTarget =======================
% Abstract:
%     Indicate if the code format is either of the following:
%             'S-Function'
%             'Accelerator_S-Function'
%             'Model reference sim' target
%
function isSFcnFmt = IsSFcnOrAcceleratorOrModelrefSimTarget(modelName, ...
                                                    codeFormat, mdlRefTargetType)
  isSFcnFmt    = ~isempty(findstr(codeFormat,'S-Function')) || ...
      strcmpi(mdlRefTargetType, 'SIM');

%endfunction IsSFcnOrAcceleratorOrModelrefSimTarget



% Function: GetTLCIncludePath ==================================================
% Abstract:
%    Setup and return include path for TLC
%
function incDir = GetTLCIncludePath(rtwroot, systemTargetFile,sfcnsIncCell, ...
                                    buildDir, generatedTLCSubDir, ...
                                    haveStateflowSFcns)
  incDir = {};

  k = findstr(systemTargetFile,filesep);
  if ~isempty(k)
    incDir{end+1} = ['-I', systemTargetFile(1:k(end)-1)];
  end
  for i=1:length(sfcnsIncCell)
    incDir{end+1} = ['-I' sfcnsIncCell{i}];
  end
  scriptDir = buildDir;

  incDir{end+1} = ['-I' fullfile(buildDir,generatedTLCSubDir)];

  mlscriptDir = fullfile(scriptDir,'mlscript');

  if exist(mlscriptDir,'dir'),
    incDir{end+1} = ['-I', mlscriptDir];
  end

  incDir{end+1} = ['-I', fullfile(rtwroot, 'c', 'tlc','mw')];
  incDir{end+1} = ['-I', fullfile(rtwroot, 'c', 'tlc','lib')];
  incDir{end+1} = ['-I', fullfile(rtwroot, 'c', 'tlc','blocks')];
  incDir{end+1} = ['-I', fullfile(rtwroot, 'c', 'tlc','fixpt')];
  % vijay: due to eml and other considerations, add this directory 
  % unconditionally
  incDir{end+1} = ['-I', fullfile(matlabroot, 'stateflow', 'c','tlc')];
  

%endfunction GetTLCIncludePath



% Function: GetTLCcmd ==========================================================
% Abstract:
%   Generate the tlc command used to generate code.
%
function tlcCmd = GetTLCcmd(buildDir, generatedTLCSubDir, modelName, ...
  systemTargetFile, tlcArgs, rtwroot, sfcnsIncCell, haveStateflowSFcns)

  %-----------------------------%
  % Create include path for TLC %
  %-----------------------------%
  incDir = GetTLCIncludePath(rtwroot, systemTargetFile, sfcnsIncCell, ...
                             buildDir, generatedTLCSubDir, haveStateflowSFcns);

  tlcCmd = {'tlc'};
  tlcCmd{end+1} = '-r';
  tlcCmd{end+1} = [buildDir,filesep,modelName, '.rtw'];
  tlcCmd{end+1} = systemTargetFile;
  tlcCmd{end+1} = ['-O',buildDir];
  tlcCmd{end+1} = ['-aReleaseVersion=',release_version];

  tlcDebugOn = strcmp(get_param({modelName}, 'TLCDebug'), 'on');
  if tlcDebugOn,
    tlcCmd{end+1} = '-dc';
 end

  tlcCoverageOn = strcmp(get_param({modelName}, 'TLCCoverage'), 'on');
  if tlcCoverageOn,
    tlcCmd{end+1} = '-dg';
  end

  tlcAssertionOn = strcmp(get_param({modelName}, 'TLCAssertion'), 'on');
  if tlcAssertionOn,
    tlcCmd{end+1} = '-da';
  end

  % The eval below is used to invoke MATLAB's quoting mechanism for command line
  % style invocation of functions, e.g. "f a" instead of "f('a')".  This quoting
  % mechanism does what we want here since it adds quotes if not already
  % present. It assumes tlcArgs is in MATLAB format, i.e. special characters
  % like ';' have been quoted.  For example,
  %
  %     CurlyBracketOperator '-aFoo="x y"' -aGoo=1
  %
  % returns {'-aFoo="x y"', '-aGoo=1'}.

  eval(['CurlyBracketOperator ' tlcArgs ';']);

  tlcArgsAsCellArray = ans; % Note that here we are using the value of "ans"
                            % written by the call to "eval" above.  Thus, keep
                            % the eval right before the use of ans, i.e. do not
                            % insert code betwen the eval and the use of ans.

  tlcCmd = {tlcCmd{:}, incDir{:}, tlcArgsAsCellArray{:}};

% endfunction GetTLCcmd

%endfunction: ConfigForTLC


function y = CurlyBracketOperator(varargin)

  y = varargin;


% Function: InvokeTLC ==========================================================
% Abstract:
%   Invoke TLC to generate the *.c, *.h files.
%   This will also do TLC profiling if requested.
%   This is also the funnel for TLC coverage logging.
%
function indentCmd = InvokeTLC(dispOpts, buildDir, modelName, rtwroot, ...
                               systemTargetFile, tlcArgs, sfcnsIncCell, ...
                               mdlRefTargetType,haveStateflowSFcns, ...
                               generatedTLCSubDir)
  dh = dispOpts.DispHook;
  if dispOpts.rtwVerbose
    feval(dh{:},['### Invoking Target Language Compiler on ',modelName,'.rtw']);
  end

  %---------------------%
  % Build TLC arguments %
  %---------------------%
  tlcCmd = GetTLCcmd(buildDir, generatedTLCSubDir, modelName, ...
                     systemTargetFile, tlcArgs, rtwroot, sfcnsIncCell, ...
                     haveStateflowSFcns);

  % -p0 is special to mean "turn it off". Specifically useful for demos

  tlcCmd = strrep(tlcCmd,'-p0','-p10000000');

  if dispOpts.rtwVerbose,
    if isempty(strmatch('-p',tlcCmd)),
      tlcCmd{end+1} = '-p10000';
    end
    feval(dh{:}, PrettyPrint(tlcCmd));
  end

  if ~isunix,
    bufstate = cmd_window_buffering('off');
  end

  tlcProfilerOn = strcmp(get_param({modelName}, 'TLCProfiler'), 'on');
  if tlcProfilerOn,
    %
    % TLC Profiling
    %
    htmlFile = [modelName,'.html'];
    htmlFile = [buildDir, filesep, htmlFile];
    feval(dh{:},['### Generating TLC profile: ', htmlFile]);

    tlch = tlc('new');
    tlc('startprofiler',tlch);

    tlcCmdProfArgs = {'execcmdline', tlch};
  else
    tlcCmdProfArgs = {};
  end

  try
    %
    % See if we should force TLC coverage to be on
    %
    tlcLogsSaveDir = evalin('base', ...
                            'rtw_mathworks_tlc_logs_dir__', '''''');
    lasterr(''); % Clear lasterr if the variable didn't exist in the base.
    if ~isempty(tlcLogsSaveDir)
      tlcCmd = strrep(tlcCmd,'-aGenerateReport=1','-aGenerateReport=0');
      tlcCmd{end+1} = '-dg';
    end

    indentCmd = 'c_indent ';
    if ~isempty(strmatch('-aGenerateComments=0',tlcCmd))
      indentCmd = [indentCmd '-nocomments '];
    end

    feval(tlcCmd{1}, tlcCmdProfArgs{:}, tlcCmd{2:end});

    % The feval above used to have dispOpts.PutsHook as its final argument but this
    % caused memory corruption in tests like test/ toolbox/ simulink/
    % code_reuse/ tcr_trg_enbl so I removed it, bailing for now on capturing TLC
    % output. -- bdenckla

    SaveTlcCommand(tlcCmd, modelName, buildDir);

    %
    % Save log files
    %
    if ~isempty(tlcLogsSaveDir)
      stowe_away_tlc_logs_for_testing(modelName,buildDir,tlcLogsSaveDir);
    end

  catch
    if tlcProfilerOn
      tlc('close', tlch);
    end
    % Clear TLC compiler from memory to release TLC memory caches
    clear tlc_new;
    error('%s', lasterr); % continue with error processing
  end

  if tlcProfilerOn,
    tlc('stopprofiler', tlch);
    h = tlc('getprofiler', tlch);

    % generate HTML report from profiler data with the given report name
    slprofreport(h, buildDir, modelName);

    % close TLC server handle and delete all profiler data
    tlc('close', tlch);
  end

  % Clear TLC compiler from memory to release TLC memory caches
  clear tlc_new;
  
  if ~isempty(strmatch('-aCompactFilePackaging=1',tlcCmd))
    % xxx cleanup compact file packaging. TLC shouldn't be creating
    %     _prm.h, _reg.h, _common.h, _export.h
    rtw_delete_file(fullfile(buildDir,[modelName,'_prm.h']));
    rtw_delete_file(fullfile(buildDir,[modelName,'_reg.h']));
    rtw_delete_file(fullfile(buildDir,[modelName,'_common.h']));
    rtw_delete_file(fullfile(buildDir,[modelName,'_export.h']));
  end


  if ~isunix,
    cmd_window_buffering(bufstate);
  end

% endfunction InvokeTLC


% Function: SaveTlcCommand ===================================================
% Abstract:
%   If the .rtw file will be saved, also save the tlc command and a script that
%   can be used to re-invoke it.
%
function SaveTlcCommand(tlccmd, iModelName, iBuildDir)

  deleteRTWFile = strcmp(get_param(iModelName,'RTWRetainRTWFile'),'off');
  if ~deleteRTWFile
    funcname = 'runtlccmd';
    matFileName = fullfile(iBuildDir, 'tlccmd.mat');
    mFileName = fullfile(iBuildDir, [funcname '.m']);
    save(matFileName, 'tlccmd');
    fcntext = GetFcn(funcname, iModelName, iBuildDir, tlccmd);
    WriteLinesToFile(mFileName, fcntext);
  end

function f = GetFcn(iFuncName, iModelName, iBuildDir, iTlcCmd)
  c = GetComment(iFuncName, iModelName, iTlcCmd);
  f = {...
      ['function ' iFuncName], ...
      c{:},...
      [''], ...
      ['   mdl = ''' iModelName ''';'], ...
      [''], ...
      ['   sysopen = ~isempty(strmatch(mdl, find_system(''type'', '...
       '''block_diagram''), ''exact''));'], ...
      [''], ...
      ['   if ~sysopen'], ...
      [''], ...
      ['      disp([mfilename '': Error: model '' mdl '' is not open. '...
       'Please open model '' mdl '' and then run '' mfilename '' again'...
       '.'']);'], ...
      [''], ...
      ['   else'], ...
      [''], ...
      ['      rtwprivate(''rtwattic'', ''setBuildDir'', ''' iBuildDir ''');'], ...
      ['      load tlccmd.mat;'], ...
      ['      savedpwd = pwd;'], ...
      ['      cd ..;'], ...
      ['      feval(tlccmd{:});'], ...
      ['      rtwprivate rtwattic clean;'], ...
      ['      cd(savedpwd);'], ...
      [''], ...
      ['   end'] ...
      };

function c = GetComment(iFuncName, iModelName, iTlcCmd)
  c = strcat({sprintf('\t')}, iTlcCmd);
  c = {...
      [upper(iFuncName) ' - run tlc command (regenerate C code from .rtw '...
       'file) for model ' iModelName], ...
      ['This function will run the tlc command stored in the variable '], ...
      ['"tlccmd" in tlccmd.mat, whose contents is as follows:'], ...
      [''],...
      c{:} ...
      };
  c = strcat({'% '}, c);


function WriteLinesToFile(iFileName, iLines)
  [fid errmsg] = fopen(iFileName, 'w');
  if ~isempty(errmsg)
    error('Error opening %s: %s', iFileName, errmsg);
  end
  for i=1:length(iLines)
    fprintf(fid,'%s\n', iLines{i});
  end
  fcloseStatus = fclose(fid);
  if fcloseStatus ~= 0
    error('Error closing %s', iFileName);
  end


% Function: GetBaseModelFile ===================================================
% Abstract:
%   Return the base model file name.
%   Normally this is the name of the model except
%     - for the S-function target it is model_sf
%     - for the Accelerator target it is model_acc
%
function baseModelFile = GetBaseModelFile(modelName, codeFormat, mdlRefTargetType)

  switch codeFormat
   case 'S-Function'
    baseModelFile = [modelName,'_sf'];
   case 'Accelerator_S-Function'
    baseModelFile = [modelName,'_acc'];
   otherwise
    if strcmpi(mdlRefTargetType, 'SIM')
      ext = modelrefutil(modelName,'getBinExt');
      baseModelFile = [modelName,ext];
    elseif strcmpi(mdlRefTargetType, 'RTW')
      baseModelFile = '';
    else
      baseModelFile = modelName;
    end
  end

%endfunction GetBaseModelFile



% Function: ClearModelMexAndDeleteObject =======================================
% Abstract:
%   For accelerator, S-function target, we need to clear the MEX-file
%   prior to continuing with the build process.
%
function ClearModelMexAndDeleteObject(modelName, codeFormat,mdlRefTargetType)

  if IsSFcnOrAcceleratorOrModelrefSimTarget(modelName,codeFormat,mdlRefTargetType)

    mexfile = GetBaseModelFile(modelName, codeFormat, mdlRefTargetType);
    clear(mexfile);

    try
      if ispc,
        ext='.obj';
      else
        ext='.o';
      end
      objFile = [mexfile, ext];
      if exist(objFile,'file'),
        rtw_delete_file(objFile);
      end
    catch
      lasterr('');
    end
  end

%endfunction ClearModelMexAndDeleteObject



% Function: GetModulesFromBuildDir =============================================
% Abstract:
%   Read the build directory for .c and .h files to be indented, etc.
%
function [moduleList, moduleHeaderList] = GetModulesFromBuildDir(modelName)

  %
  % source list
  %
  moduleList = '';

  cfiles = dir('*.c');
  for fileIdx = 1:length(cfiles)
    addFile = true; % assume

    file = cfiles(fileIdx).name;
    fid  = fopen(file,'r');
    if fid == -1,
      error('%s', ['Unable to open ',file]);
    end
    line = fgetl(fid);
    if ischar(line) && ~isempty(findstr('target specific file',line))
      addFile = false;
    end
    fclose(fid);

    % When makefile does not support ModelReference(i.e. oldstyple) , it will
    % explicitly list rt_nonfinite.c in makefile. As such, do not add to MODULES.
    if strcmp(file,'rt_nonfinite.c')
      tmfVersion = get_tmf_version(modelName);
      if strcmp(tmfVersion,'Standalone')
        addFile = false;
      end
    end

    if addFile
      moduleList = [moduleList, file,' '];
    end
  end

  moduleList(end) = []; % delete trailing white space

  %
  % Header list
  %
  moduleHeaderList = '';

  hfiles = dir('*.h');
  for fileIdx = 1:length(hfiles)
    addFile = true; % assume

    file = hfiles(fileIdx).name;
    fid  = fopen(file,'r');
    if fid == -1,
      error('%s', ['Unable to open ',file]);
    end
    line = fgetl(fid);
    if ischar(line) && ~isempty(findstr('target specific file',line))
      addFile = false;
    end
    fclose(fid);

    if addFile
      moduleHeaderList = [moduleHeaderList, file,' '];
    end
  end

  moduleHeaderList(end) = []; % delete trailing white space

%endfunction GetModulesFromBuildDir



% Function: ConvertDelimStrToCells =============================================
% Abstract:
%     Converts a white-space delimited string to a row cell array
%     of individual strings.
%
function cellList=ConvertDelimStrToCells(strList)

  [s,f]=regexp(strList,'\S+');
  cellList = {};
  for i=1:length(s)
    cellList{i} = strList(s(i):f(i));
  end

%endfunction ConvertDelimStrToCells



% Function: ConvertCellsToDelimStr =============================================
% Abstract:
%    Convert a cell array of strings to one space-delimited string.
%    Note that one delimiter will also be appended to the end of
%    the string being returned.
%
function str = ConvertCellsToDelimStr(cellStr)

  cellStr=cellStr(:);  % force into a column vector of strings

  % Construct cell array of delimiters (spaces),
  % to be appended to the end of each string in cellStr
  spaces={' '};
  spaces=spaces(ones(size(cellStr)));

  % Interleave delimiters with strings, and concatenate into one string
  cellStr = [cellStr spaces]';
  str = [cellStr{:}];

  % Force result to be an empty string, and not an empty array,
  % if no inputs.  This silences warnings from functions such
  % as strrep, which prefer '' on input, and not [].
  if isempty(str), str=''; end

%endfunction ConvertCellsToDelimStr



% Function: Add_C_ExtToNames ===================================================
% Abstract:
%       Append a '.c' extension to each file in the moduleFileList list.
%       If a file already has an extension specified, leave it as-is.
%       The file list is a cell array of strings.
%
function namesWithExt = Add_C_ExtToNames(nameList)

  namesWithExt = nameList;
  for i=1:length(nameList),
    name = nameList{i};
    [nPath, nName, nExt] = fileparts(name);
    if isempty(nExt),
      namesWithExt{i} = [name '.c'];
    end
  end

%endfunction Add_C_ExtToNames



% Function: GetBuildModuleList =================================================
% Abstract:
%   Get the module list, which excludes the 'main module' (model.c, model_sf.c,
%   or model_acc.c).
%
function buildModuleList = GetBuildModuleList(h, haveStateflowSFcns,...
                                              moduleList, sfcnsCell, codeFormat, ...
                                              mdlRefTargetType)
  modelName = h.ModelName;
  buildModuleList = moduleList;  % .c files in the build directory excluding explicitly
                                 % marked 'target specific file' files.
  
%  dboissy says:
%  For the main model the list of source files comes from the
%  configset.  This is not the case for libraries though.  As of
%  R14 there is no concept of a configset for libraries.  Therefore
%  the RTW target persists for libraries only.
  if haveStateflowSFcns
    sfUserModuleStr = sf_rtw('get_sf_user_modules',modelName);
    if ~isempty(sfUserModuleStr)
      buildModuleList = [buildModuleList, ' ', sfUserModuleStr];
	end
  end

  % Add in an sources explicitly specified via the 
  %   LibAddToModelSources()
  % TLC function.

  fid = fopen('modelsources.txt','r');
  if fid == -1,
    error('%s', ['Unable to open ', 'modelsources.txt']);
  end
  sources = fgetl(fid);
  if ischar(sources) && ~isempty(sources)
    buildModuleList = [buildModuleList, ' ',sources];
  end
  fclose(fid);

  %
  % Convert the string list to a cell list
  %
  buildModuleCell = ConvertDelimStrToCells(buildModuleList);


  %
  % Add in Accelerator/S-Function target modules (required for build)
  %
  if IsSFcnOrAcceleratorOrModelrefSimTarget(modelName,codeFormat, mdlRefTargetType),
    for i = 1:length(sfcnsCell)
      if (sfcnsCell{i}{3} == 1)
        % The {i}{3}'th entry is 1 if the S-function is inlined.
        % The {i}{4}'th entry is a whitespace-delimited string
        % containing one or more names of code modules which are
        % required during compilation.
        moduleStr   = sfcnsCell{i}{4};
        if ~isempty(moduleStr)
          sfcnModules = ConvertDelimStrToCells(moduleStr);
          sfcnModules = Add_C_ExtToNames(sfcnModules);
          buildModuleCell = [buildModuleCell sfcnModules];
        end
      end
    end
  end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% dboissy says:              %
	% Add modules from configset %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Get custom code settings from configset
	cs          = getActiveConfigSet(modelName);
	rtwSettings = cs.getComponent('any', 'Real-Time Workshop');

	% Parse custom code settings in an effort to resolve file names
	custCodeFiles   = rtw_resolve_custom_code(h, rtwSettings.CustomInclude, ...
                                                  rtwSettings.CustomSource, ...
                                                  rtwSettings.CustomLibrary);
	buildModuleCell = [buildModuleCell custCodeFiles.parsedSrcFileNames];

  %
  % Build a unique list of sources. We will have duplicates because
  % modelsources.txt lists .c files found in the build directory (plus
  % other .c files, e.g. files in simulink/src for sb2sl).
  %
  buildModuleCell = unique(buildModuleCell);

  %
  % Remove .c files that are not considered modules:
  %  - Remove main module (model.c) because it is explicitly specified
  %    in the .tmf file.
  %  - Remove the model_pt.c and model_bio.c files because they are really
  %    include files.
  %  - Remove the model_sf.c because this is for the ert S-function
  %    format and is explicitly specified in the .tmf file.
  %
  baseFileName = GetBaseModelFile(modelName,codeFormat, mdlRefTargetType);
  ignoreModules = {};
  if ~isempty(baseFileName)
    ignoreModules{end+1} = [baseFileName, '.c'];
  end

  ignoreModules{end+1} = [modelName,'_pt.c'];
  ignoreModules{end+1} = [modelName,'_bio.c'];

  if strcmp(codeFormat,'Embedded-C')
    ignoreModules{end+1} = [modelName,'_sf.c'];
    ignoreModules{end+1} = 'ert_main.c';
  end

  buildModuleCell = setdiff(buildModuleCell,ignoreModules);

  %
  % Convert the buildModuleCell back to a buildModuleList string.
  %
  buildModuleList = ConvertCellsToDelimStr(buildModuleCell);

%endfunction GetBuildModuleList

function y = PrettyPrint(x)

% Turn a cell array of strings, e.g. {'tlc', 'blah1', 'blah2', 'blah3'} into a
% single string formatted to look like
%
%      tlc
%      blah1
%      blah2
%      blah3

  y = strcat({sprintf('\t')}, x, {sprintf('\n')});
  y = [y{:}];


% Function: DoTermRTWgen =======================================================
% Abstract:
%   Terminate rtwgen
%
function DoTermRTWgen(modelName, preBuildDir)
  %% Switch back to pre-build dir so that we can find all
  %% S-functions and do their terminate
  rtDir = cd(preBuildDir);
  rtwgen(modelName, 'TerminateCompile', 'on');
  cd(rtDir);
%endfunction DoTermRTWgen

% [EOF] tlc_c.m
