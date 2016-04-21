function oString = setup_for_visual(args)
%
% Function: setup_for_visual =====================================================
% Abstract:
%
%       Configure the build process for Visual (normal mode of operaton) or
%       (other, slightly hacky mode of operation) return a string giving
%       suggestions for how to set the "MSDevDir" or "DevEnvDir" environment
%       variable
%
%       When configuring the build process for Visual, this function wraps the
%       raw make command, args.makeCmd (e.g. 'nmake -f model.mk MAT_FILE=1') in
%       a batch (.bat) file that sets up some environment variables needed
%       during the build process.
%-------------------------------------------------------------------------------
%

% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.5.4.2 $

  if isfield(args, 'EnvVarSuggestions')

    [dummy, oString] = LocGetEnvVarSuggestions(LocGetMSD);

  else

    oString = LocNormalSetup(args);

  end

%endfunction setup_for_visual


function oMakeCmd = LocNormalSetup(args)

  msd = LocGetMSD;
  b.msDevDir = LocGetMSDevDir(args.makeCmd, args.compilerEnvVal, msd);
  b.msVcDir  = '';
  b.vcvars32 = '';
  b.vcver    = '';

  if ~isempty(b.msDevDir)
     for i=1:length(msd)

      % If "i" is the correct DevStudio, the DevStudio root directory can be had by
      % stripping msd{i}.IDERelLoc off the end of b.msDevDir.  If "i" is not the
      % correct DevStudio, b.devstudio will end up empty.

      b.devstudio = LocPrefix(b.msDevDir, msd{i}.IDERelLoc);

      % If "i" is the correct DevStudio, b.msDevDir:
      %
      %    (a) contains the batch file msd{i}.VarsBatRel and
      %    (b) ends in msd{i}.IDERelLoc.

      if ~isempty(dir([b.msDevDir, msd{i}.VarsBatRel])) && ...
            ~isempty(b.devstudio)

        b.msVcDir  = [b.devstudio msd{i}.VCRelLoc];

        % Here we set the variable b.vcvars32 to our own version of msd{i}.VarsBatRel,
        % which, unlike the original, fills in various environment variables
        % based on other environment variables "passed in" rather than having
        % these variables hard-coded and based on an installation location.

        b.vcvars32 = [matlabroot, ...
                    '\toolbox\rtw\rtw\private\vcvars32_' msd{i}.HundredsVers '.bat'];

        b.vcver = msd{i}.OnesVers;
      end
    end % for
  end

  if ~isempty(b.msVcDir)
    oMakeCmd = LocWriteBatFile(args.makeCmd, args.modelName, args.verbose, b);
  else
    LocIssueMSDevError(b.msDevDir, msd);
  end

%endfunction LocNormalSetup


function makeCmdOut = LocWriteBatFile(makeCmd, modelName, verbose, b)
% Emit batch file code for an RTW build under MSVC

  endl = sprintf('\n');

  cmdFile = ['.\',modelName, '.bat'];
  cmdFileFid = fopen(cmdFile,'wt');
  if ~verbose
    fprintf(cmdFileFid, '@echo off\n');
  end
  fprintf(cmdFileFid, 'set MATLAB=%s\n', matlabroot); % for mpc555pil
  fprintf(cmdFileFid, 'set MSVCDir=%s\n',b.msVcDir);
  if ~strcmp(b.vcver,'7.0')
    fprintf(cmdFileFid, 'set MSDevDir=%s\n',b.msDevDir);
  end

  LocEnvCheck(cmdFileFid, 'INCLUDE', [b.msVcDir  '\include']);
  LocEnvCheck(cmdFileFid, 'PATH',    [b.msVcDir  '\bin']);

  fprintf(cmdFileFid, 'goto make\n');
  fprintf(cmdFileFid, ':vcvars32\n');

  if strcmp(b.vcver,'6.0')

    fprintf(cmdFileFid,'set VSCommonDir=%s\n', [b.devstudio '\common']);

  elseif strcmp(b.vcver,'7.0')

    % Normally in in a real vsvars32.bat file in an MSVC7 installation,
    % "FrameworkDir" (not to be confused with "FrameworkSDKDir") is something
    % like "C:\WINNT\Microsoft.NET\Framework".  Here we set it to a directory
    % "Framework" in the root DevStudio directory.  This is arbitrary: it is
    % just where we happened to copy "C:\WINNT\Microsoft.NET\Framework" to from
    % a real MSVC7 installation when making a single directory we could point to
    % it to switch compilers when testing compilers.  I'm not sure the path to
    % Framework is really needed.  It was initially needed to get a path to
    % MSVCR70.DLL, but now there is a copy of that in <matlabroot>\bin\win32,
    % which, by virtue of being in the same directory as the executable
    % (matlab.exe), is on the DLL search path.

    fprintf(cmdFileFid, '%s', ...
            ['set VSINSTALLDIR='    b.msDevDir                  endl ...
             'set VCINSTALLDIR='    b.devstudio                 endl ...
             'set FrameworkSDKDir=' b.devstudio '\FrameworkSDK' endl ...
             'set FrameworkDir='    b.devstudio '\Framework'    endl]);
  end

  fprintf(cmdFileFid, '%s\n', ['call "', b.vcvars32,'"']);
  fprintf(cmdFileFid, ':make\n%s\n', [makeCmd ' VISUAL_VER=' b.vcver]);

  % The program nmake.exe does not print an error message to stdout in certain
  % circumstances so here we make sure that some printed manifestation of an
  % error will be emitted if an error occurs.  In particular, nmake prints no
  % error message if a DLL cannot be found since this error is reported by a
  % Windows system dialog that appears who knows where.

  fprintf(cmdFileFid, '%s\n', ['@if not errorlevel 0 echo The make command returned ' ...
                        'an error of %errorlevel%']);

  fclose(cmdFileFid);
  makeCmdOut = cmdFile;

%endfunction LocWriteBatFile


function LocEnvCheck(cmdFileFid, var, val)
% Emit batch file code to check that environment variable "var" has value "val".

  fprintf(cmdFileFid, '%s\n', ...
    [matlabroot,'\rtw\bin\win32\envcheck ' var ' "' val '"']);
  fprintf(cmdFileFid, '%s\n', 'if errorlevel 1 goto vcvars32');

%endfunction LocEnvCheck

function LocIssueMSDevError(msDevDir, msd)
% Issue an error saying that no MSDev installation is found

  [checkEnvVal correctSetting] = LocGetEnvVarSuggestions(msd);

  issue_inv_comp_env_val_error('MSDevDir or DevEnvDir', ...
                               msDevDir, checkEnvVal, correctSetting);

%endfunction LocIssueMSDevError


function [oVCVarsBats, oMSDevDirs] = LocGetEnvVarSuggestions(msd)
% Issue an error saying that no MSDev installation is found

  oVCVarsBats = '';
  oMSDevDirs = '';
  for i=1:length(msd)

    endStr = ['(for Visual C/C++ ' msd{i}.OnesVers ')' sprintf('\n')];

    ideLocVar =  ['%' msd{i}.IDELocVar '%'];

    varsBatLoc = ['  ' ideLocVar msd{i}.VarsBatRel];

    setCmd =     ['  set ' ideLocVar '=<VisualRoot>' msd{i}.IDERelLoc];

    oVCVarsBats = [oVCVarsBats sprintf('%-45s',varsBatLoc) endStr];

    oMSDevDirs = [oMSDevDirs sprintf('%-45s',setCmd) endStr];
  end

%endfunction LocGetEnvVarSuggestions


function msDevDir = LocGetMSDevDir(makeCmd, compilerEnvVal, msd)
% Try to get a value for the developer studio IDE executable directory by
% various means

  m = LocGetMSDevDirFromRootFromCmd(msd, makeCmd, 'DEVSTUDIO_LOC');

  if isempty(m)

    m = parsestrforvar(makeCmd, 'MSDevDir_LOC');

  end
  if isempty(m)

    m = LocGetMSDevDirFromRoot(msd, compilerEnvVal, [], true);

  end
  if isempty(m)

    m = parse_mexopts_for_envval('_vc.tmf');

  end
  if isempty(m)

    m = LocGetMSDevDirFromRootFromEnv(msd, 'VISUAL_STUDIO');

  end
  if isempty(m)

    m = LocGetMSDevDirFromRootFromEnv(msd, 'DEVSTUDIO');

  end
  if isempty(m)

    m = getenv('MSDevDir');

  end
  if isempty(m)

    m = getenv('DevEnvDir');

  end

  msDevDir = LocRemUpDir(lower(m));

%endfunction LocGetMSDevDir


function msd = LocGetMSD()
% Returns a data structure describing the variations in file naming and
% directory structure in various versions of MSVC.

  msd{1}.IDERelLoc = '\sharedide';
  msd{2}.IDERelLoc = '\common\msdev98';
  msd{3}.IDERelLoc = '\common7\ide';

  msd{1}.IDELocVar = 'MSDevDir';
  msd{2}.IDELocVar = 'MSDevDir';
  msd{3}.IDELocVar = 'DevEnvDir';

  msd{1}.VarsBatRel = '\..\vc\bin\vcvars32.bat';
  msd{2}.VarsBatRel = '\..\..\vc98\bin\vcvars32.bat';
  msd{3}.VarsBatRel = '\..\tools\vsvars32.bat';

  msd{1}.VCRelLoc = '\vc';
  msd{2}.VCRelLoc = '\vc98';
  msd{3}.VCRelLoc = '\vc7';

  msd{1}.HundredsVers = '500';
  msd{2}.HundredsVers = '600';
  msd{3}.HundredsVers = '700';

  msd{1}.OnesVers = '5.0';
  msd{2}.OnesVers = '6.0';
  msd{3}.OnesVers = '7.0';

%endfunction LocGetMSD

function m = LocGetMSDevDirFromRootFromCmd(msd, iCmd, iSrcVar)

  m = LocGetMSDevDirFromRoot(msd, parsestrforvar(iCmd, iSrcVar), iSrcVar);

%endfunction


function m = LocGetMSDevDirFromRootFromEnv(msd, iSrcVar)

  m = LocGetMSDevDirFromRoot(msd, getenv(iSrcVar), iSrcVar);

%endfunction


function oMSDevDir = LocGetMSDevDirFromRoot(msd, iRoot, iSrcVar, silent)
%
% Try to get a value for the MSDev IDE dir from the MSDev root dir
%
  if nargin < 4
    silent = false;
  end
  oMSDevDir = '';

  if ~isempty(iRoot)

    iRoot = lower(iRoot);

    for i=1:length(msd)
      IDEAbsLoc = [iRoot msd{i}.IDERelLoc];
      if exist(IDEAbsLoc, 'dir')
        oMSDevDir = IDEAbsLoc;
      end % if
    end % for

    if isempty(oMSDevDir)
      if silent
        oMSDevDir = iRoot;
        return
      end

      aba = '(angle brackets added):';
      inst = 'an installation of Microsoft Developer Studio';
      action = ['to find ' inst];


      error(['RTW is unable ' action ' in the following directory ' aba ...
             sprintf('\n\n    ') ...
             '<' iRoot '>.' ...
             sprintf('\n\n') ...
             'RTW was attempting ' action ' in this directory because its name '...
             'was found in the following environment variable ' aba ...
             sprintf('\n\n    ') ...
             '<' iSrcVar '>.' ...
             sprintf('\n\n') ...
             'This error could be caused by this variable ' ...
             sprintf('\n\n    ') ...
             'not pointing to ' inst ',' ...
             sprintf('\n\n    ') ...
             'pointing too "deep" (too many directory levels down) ' ...
             'into ' inst ', or' ...
             sprintf('\n\n    ') ...
             'pointing to ' inst ' whose version is not ' ...
             'supported by RTW.  For example, RTW no longer supports ' ...
             'Microsoft Visual C/C++ Version 4.2.'...
            ]);
    end
  end

%endfunction LocGetMSDevDirFromRoot

function y = LocRemUpDir(x)
%
% Simpify ".." expressions out of the the path "x".
%
  slash = '[\\/]';
  word = '\w+';
  dot = '\.';

  y = regexprep(x, [slash word slash dot dot], '');

%endfunction LocRemUpDir


function r = LocPrefix(str, suffix)
% If "suffix" is a suffix of "str", return str without "suffix".  Otherwise
% return the empty string.

  r = '';
  startLocs = strfind(str, suffix);
  st = length(str);
  su = length(suffix);

  if ~isempty(startLocs) && (st - su + 1 == startLocs(end))
    r = str(1:startLocs(end)-1);
  end

%endfunction LocPrefix
