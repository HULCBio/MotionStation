function makeCmdOut = setup_for_watcom(args)
%
% Function: SetupForWatcom =====================================================
% Abstract:
%       Configure the build process for Watcom
%  
%       This function wraps the raw make command, args.makeCmd (e.g. 'wcmake -f
%       model.mk MAT_FILE=1') in a batch (.bat) file that sets up some
%       environment variables needed during the build process.
%

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/15 00:25:06 $

  makeCmd        = args.makeCmd;
  modelName      = args.modelName;
  verbose        = args.verbose;
  compilerEnvVal = args.compilerEnvVal;

  watcom = parsestrforvar(makeCmd,'WATCOM_LOC');
  if isempty(watcom)
    if isempty(compilerEnvVal)
      compilerEnvVal=parse_mexopts_for_envval('_watc.tmf');
    end
    if ~isempty(compilerEnvVal)
      watcom = compilerEnvVal;
    else
      watcom = getenv('WATCOM');
    end
  end

  if ~isempty(watcom)
    if isempty(dir([watcom,'\binnt\wmake.exe']))
      checkEnvVal=['  %WATCOM%\binnt\wmake.exe'];
      issue_inv_comp_env_val_error('WATCOM',watcom, checkEnvVal, ...
                              '  set WATCOM=<WatcomPath>');
    end
    [status,result]=dos([watcom,'\binnt\wmake /?']);
    
    watver = '';
    addOpt = '';
    if ~isempty(findstr(result,'Version 10.6'))
      watver = ' WATCOM_VER=10.6';
      addOpt = ' /a';
      makeCmd = LocProcessMakeCmdFor106(makeCmd);
    elseif ~isempty(findstr(result,'Version 11.0'))
      watver = ' WATCOM_VER=11.0';
    else
      error(['unrecognized Watcom version <' result '>']);
    end

    cmdFile = ['.\',modelName, '.bat'];
    cmdFileFid = fopen(cmdFile,'wt');
    if ~verbose
      fprintf(cmdFileFid, '@echo off\n');
    end
    fprintf(cmdFileFid, 'set WATCOM=%s\n', watcom);
    fprintf(cmdFileFid, '%s\n', [makeCmd, watver, addOpt]);
    fclose(cmdFileFid);
    makeCmdOut = cmdFile;
  else
    if isempty(getenv('WATCOM'))
      error(['The environment variable, WATCOM does not exist. Please ' ...
             'set the variable to the path where your Watcom compiler is installed.']);
    end
    makeCmdOut = makeCmd;  % No change
  end
  
  % Delete the .err file left by a previous Watcom build
  
  errfile = [args.modelName,'.err']
  
  if ~isempty(dir(errfile))
    rtw_delete_file(errfile);
  end

%endfunction setup_for_watcom

function oMakeCmd = LocProcessMakeCmdFor106(iMakeCmd)
  
  % Rephrase assignments to quoted paths with spaces (wmake in v10.6 doesn't
  % handle them) as quoted assignments to paths with spaces, e.g x="a b" becomes
  % "x=a b". This is specifically in response to problems with DEVSTUDIO_LOC,
  % which, although it is generally unused if we are setting up for Watcom, is
  % always set by rtwteswtbuildimage.m for uniformity's sake.  But in general
  % this function may help avoid future problems with paths with spaces, for
  % instance if you attempt to set WATCOM_LOC to a path with spaces.

  bad_assign = '(\w+)="([^"]* [^"]*)"';

  oMakeCmd = regexprep(iMakeCmd, bad_assign, '"$1=$2"');

%endfunction LocProcessMakeCmdFor106
