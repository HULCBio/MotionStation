function makeCmdOut = setup_for_intel(args)
%
% Function: SetupForIntel ========================================================
% Abstract:
%       Configure the build process for Intel
%
%       This function wraps the raw make command, args.makeCmd (e.g. 'gmake -f
%       model.mk MAT_FILE=1') in a batch (.bat) file that sets up some
%       environment variables needed during the build process.
%

% Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:25:04 $
  
  makeCmd        = args.makeCmd;
  modelName      = args.modelName;
  verbose        = args.verbose;

  % args.compilerEnvVal not used

  ic_info = LocGetIntelCompilerInfo(args);
  
  if ~isempty(ic_info.root_dir)
    if isempty(dir([ic_info.Bin]))
      error(['Unable to locate Intel compiler in ' ...
             ic_info.Bin,sprintf('\n'), ...
             'Please make sure that you have Intel compiler installed ' ...
             'using MATLAB installer.']);
    end
    
    cmdFile = ['.\',modelName, '.bat'];
    cmdFileFid = fopen(cmdFile,'wt');
    if ~verbose
      fprintf(cmdFileFid, '@echo off\n');
    end
    fprintf(cmdFileFid, 'set MATLAB=%s\n', matlabroot);
    fprintf(cmdFileFid, 'set INTEL=%s\n', ic_info.root_dir);
    fprintf(cmdFileFid, 'set MSVCDir=%s\n',ic_info.msvc.VCRelLoc);

    endl = sprintf('\n\n');

    % make sure the  the PATH, LIB and INCLUDE dirs include the necesary dirs
    LocEnvCheck(cmdFileFid, 'PATH', ic_info.Bin);
    LocEnvCheck(cmdFileFid, 'PATH', ic_info.msvc.IDERelLoc);
    LocEnvCheck(cmdFileFid, 'PATH', ic_info.msvc.BinLoc);

    LocEnvCheck(cmdFileFid, 'INCLUDE', ic_info.Inc);
    LocEnvCheck(cmdFileFid, 'INCLUDE', ic_info.msvc.IncLoc);

    LocEnvCheck(cmdFileFid, 'LIB', ic_info.Lib);
    LocEnvCheck(cmdFileFid, 'LIB', ic_info.msvc.LibLoc);

    % if the env vars have been set, we can go to make, otherwise, we need to
    % set up the PATH, INCLUDE, and LIB vars
    fprintf(cmdFileFid, '\ngoto make\n');
    fprintf(cmdFileFid, '\n:setuppath\n');

    fprintf(cmdFileFid, '%s', ...
            ['set PATH=%PATH%;' ic_info.Bin ...
             ';' ic_info.msvc.IDERelLoc  ...
             ';' ic_info.msvc.BinLoc endl ...
             'set INCLUDE=%INCLUDE%;'  ic_info.Inc ...
             ';' ic_info.msvc.IncLoc endl ...
             'set LIB=' ic_info.Lib ...
             ';' ic_info.msvc.LibLoc ';' endl]);
    

    % now output the make command
    fprintf(cmdFileFid, '\n:make\n');
    fprintf(cmdFileFid, '%s\n', makeCmd );
    fclose(cmdFileFid);
    makeCmdOut = cmdFile;
  else
    if isempty(ic_info.root_dir)
      error(['Unable to locate Intel compiler in ' ic_info.root_dir, sprintf('\n'), ...
             'Please make sure that you have Intel Compiler installed.']);
    end
    makeCmdOut = makeCmd;  % No change
  end

%endfunction setup_for_intel

function LocEnvCheck(cmdFileFid, var, val)
% Emit batch file code to check that environment variable "var" has value "val".

  fprintf(cmdFileFid, '%s\n', ...
    [matlabroot,'\rtw\bin\win32\envcheck ' var ' "' val '"']);
  fprintf(cmdFileFid, '%s\n', 'if errorlevel 1 goto setuppath');

%endfunction LocEnvCheck

function ic_info = LocGetIntelCompilerInfo(args)
% Returns a data structure describing the variations in file naming and
% directory structure in various versions of the intel compiler

  % make sure we have the additional mexopts
  if isempty(args.mexOpts)
      [intel_root_dir, suffix, mexOpts] = parse_mexopts_for_envval('');
  else
    mexOpts = args.mexOpts;
  end

  % check for an override on the command line first
  intel_dir = parsestrforvar(args.makeCmd, 'INTEL_LOC');
  if ~exist(intel_dir, 'dir') 
    intel_dir = '';
  end

  % normally the intel compiler directory is in the compilerEnvVal.
  if (isempty(intel_dir))
    intel_dir = args.compilerEnvVal;
  end
  
  % if all else fails, use the dir from the mexopts file
  if (isempty(intel_dir))
      intel_dir = intel_root_dir;
  end
  
  % get the MSVC info, since the intel compiler requires it
  ic_info.msvc = LocGetMSVC(args.makeCmd, mexOpts);

  % now that we have all the info, fill in the struct
  ic_info.Vers =    '7.1';
  ic_info.root_dir = intel_dir;
  ic_info.Bin =  [ic_info.root_dir '\Bin'];
  ic_info.Inc =  [ic_info.root_dir '\Include'];
  ic_info.Lib =  [ic_info.root_dir '\Lib'];

%endfunction LocGetIntelCompilerInfo

function msdt = LocGetMSDTable()
% Returns a data structure describing the variations in file naming and
% directory structure in various versions of MSVC.  Note: the Intel compiler
% only supports Version 6.0 and up.

  msdt{1}.Vers = '6.0';
  msdt{2}.Vers = '7.1';

  msdt{1}.IDERelLoc = '\common\msdev98\bin';
  msdt{2}.IDERelLoc = '\common7\ide';

  msdt{1}.VCRelLoc = '\vc98';
  msdt{2}.VCRelLoc = '\vc7';

  msdt{1}.IncLoc = '\include';
  msdt{2}.IncLoc = '\include';
  
  msdt{1}.BinLoc = '\bin';
  msdt{2}.BinLoc = '\bin';
  
  msdt{1}.LibLoc = '\lib';
  msdt{2}.LibLoc = '\lib';
  
%endfunction LocGetMSDTable

function msvc = LocGetMSVC(makeCmd,mexOpts)
  
  msdTable =  LocGetMSDTable();
  
  msvcRoot = parsestrforvar(makeCmd, 'DEVSTUDIO_LOC');

  msvc = LocGetMSVCFromRootDir(msdTable,msvcRoot, 'DEVSTUDIO_LOC');
  
  if (isempty(msvc))
    msvcRoot = LocRemUpDir([mexOpts.msvcdir '\..']);
    msvc = LocGetMSVCFromRootDir(msdTable,msvcRoot, 'mexopts');
  end
  

%endfunction LocGetMSVC
  
function msvc = LocGetMSVCFromRootDir(msdTable,msvcRoot, iSrcVar)

  msvc = [];
  if (~isempty(msvcRoot))
    for i=1:length(msdTable)
      VCRelLoc = [msvcRoot msdTable{i}.VCRelLoc];
      if exist(VCRelLoc, 'dir') 
        msvc.VCRelLoc =  VCRelLoc;
        msvc.IDERelLoc = [msvcRoot  msdTable{i}.IDERelLoc];
        msvc.IncLoc =    [msvc.VCRelLoc msdTable{i}.IncLoc];
        msvc.BinLoc =    [msvc.VCRelLoc msdTable{i}.BinLoc];
        msvc.LibLoc =    [msvc.VCRelLoc msdTable{i}.LibLoc];
      end % if
    end % for

    if (isempty(msvc))
    
      aba = '(angle brackets added):';
      inst = 'an installation of Microsoft Developer Studio';
      action = ['to find ' inst];
      
      if (iSrcVar == 'mexopts')
        VarErrStr = 'MSVCDir variable defined in mexopts.bat';
      else
        VarErrStr = ['environment variable ' aba ...
             sprintf('\n\n    ') ...
             '<' iSrcVar '>.'];
      end
      
      
      error(['RTW is unable ' action ' in the following directory ' aba ...
             sprintf('\n\n    ') ...
             '<' msvcRoot '>.' ...
             sprintf('\n\n') ...
             'RTW was attempting ' action ' in this directory because its name '...
             'was found in the following ' VarErrStr ...
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
    end % isempty(msvc)
  end %~isempty(msvcRoot)
  
    
%endfunction LocGetMSVCFromRootDir
  
function y = LocRemUpDir(x)
%
% Simpify ".." expressions out of the the path "x".
%
  slash = '[\\/]';
  word = '\w+';
  dot = '\.';
  
  y = regexprep(x, [slash word slash dot dot], '');
  
%endfunction LocRemUpDir

%endfunctions