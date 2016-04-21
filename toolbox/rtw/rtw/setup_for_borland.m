function makeCmdOut = setup_for_borland(args)
%
% Function: SetupForBorland ====================================================
% Abstract:
%       Configure the build process for Borland
%
%       This function wraps the raw make command, args.makeCmd (e.g. 'bmake -f
%       model.mk MAT_FILE=1') in a batch (.bat) file that sets up some
%       environment variables needed during the build process.

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/15 00:25:03 $

  makeCmd        = args.makeCmd;
  modelName      = args.modelName;
  verbose        = args.verbose;
  compilerEnvVal = args.compilerEnvVal;

  borland = parsestrforvar(makeCmd,'BORLAND_LOC');
  if isempty(borland)
    if isempty(compilerEnvVal)
      compilerEnvVal=parse_mexopts_for_envval('_bc.tmf');
    end
    if ~isempty(compilerEnvVal)
      borland = compilerEnvVal;
    else
      borland = getenv('BORLAND');
    end
  end

  if ~isempty(borland)
    
    if ~isempty(dir([borland,'\cbuilder6\bin\bcc32.exe']))
      % Borland 5.6 put everything under CBuilder6.
      [status,result]=dos([borland,'\cbuilder6\bin\bcc32.exe']);
    elseif ~isempty(dir([borland,'\bcc56\bin\bcc32.exe']))
      % Free Borland 5.6 put everything under bcc56
      [status,result]=dos([borland,'\bcc56\bin\bcc32.exe']);
    elseif ~isempty(dir([borland,'\cbuilder5\bin\bcc32.exe']))
      % Borland 5.5 put everything under CBuilder5.
      [status,result]=dos([borland,'\cbuilder5\bin\bcc32.exe']);
    elseif ~isempty(dir([borland,'\bcc55\bin\bcc32.exe']))
      % Free Borland 5.5 put everything under bcc55
      [status,result]=dos([borland,'\bcc55\bin\bcc32.exe']);
    elseif ~isempty(dir([borland,'\cbuilder4\bin\bcc32.exe']))
      % Borland 5.4 put everything under CBuilder4.
      [status,result]=dos([borland,'\cbuilder4\bin\bcc32.exe']);
    elseif ~isempty(dir([borland,'\cbuilder3\bin\bcc32.exe']))
      % Borland 5.3 put everything under CBuilder3.
      [status,result]=dos([borland,'\cbuilder3\bin\bcc32.exe']);
    elseif ~isempty(dir([borland,'\bin\bcc32.exe']))
      % Borland 5.0, 5.2 put everything under the root.
      [status,result]=dos([borland,'\bin\bcc32.exe']);
    else
      cr = sprintf('\n');
      checkEnvVal=['  %BORLAND%\cbuilder6\bin\bcc32.exe      ',...
                   '(for Borland 5.6)', cr, ...
                   '  %BORLAND%\bcc56\bin\bcc32.exe          ',...
                   '(for Borland 5.6 Free Compiler)',cr,       ...
                   '  %BORLAND%\cbuilder5\bin\bcc32.exe      ',...
                   '(for Borland 5.5)', cr, ...
                   '  %BORLAND%\bcc55\bin\bcc32.exe          ',...
                   '(for Borland 5.5 Free Compiler)',cr,       ...
                   '  %BORLAND%\cbuilder4\bin\bcc32.exe      ',...
                   '(for Borland 5.4)', cr, ...
                   '  %BORLAND%\cbuilder3\bin\bcc32.exe      ',...
                   '(for Borland 5.3)', cr, ...
                   '  %BORLAND%\bin\bcc32.exe                ', ...
                   '(for Borland 5.0, 5.2)'];
      issue_inv_comp_env_val_error('BORLAND',borland, checkEnvVal, ...
                              '  set BORLAND=<BorlandPath>');
    end


    cmdFile = ['.\',modelName, '.bat'];

    cmdFileFid = fopen(cmdFile,'wt');
    if ~verbose
      fprintf(cmdFileFid, '@echo off\n');
    end


    bcver = '';
    if ~isempty(result)
      if ~isempty(findstr(result,'Borland C++ 5.6'))
        if ~isempty(dir([borland,'\cbuilder6\bin\bcc32.exe']))
          bcver = ' BC_VER=5.6';
          makeCmd = strrep(makeCmd,'%BORLAND%','%BORLAND%\cbuilder6');
        else
          bcver = ' BC_VER=5.6free';
          makeCmd = strrep(makeCmd,'%BORLAND%','%BORLAND%\bcc56');
        end
      elseif ~isempty(findstr(result,'Borland C++ 5.5'))
        if ~isempty(dir([borland,'\cbuilder5\bin\bcc32.exe']))
          bcver = ' BC_VER=5.5';
          makeCmd = strrep(makeCmd,'%BORLAND%','%BORLAND%\cbuilder5');
        else
          bcver = ' BC_VER=5.5free';
          makeCmd = strrep(makeCmd,'%BORLAND%','%BORLAND%\bcc55');
        end
      elseif ~isempty(findstr(result,'Borland C++ 5.4'))
        bcver = ' BC_VER=5.4';
        makeCmd = strrep(makeCmd,'%BORLAND%','%BORLAND%\cbuilder4');
      elseif ~isempty(findstr(result,'Borland C++ 5.3'))
        bcver = ' BC_VER=5.3';
        makeCmd = strrep(makeCmd,'%BORLAND%','%BORLAND%\cbuilder3');
      elseif ~isempty(findstr(result,'Borland C++ 5.2'))
        bcver = ' BC_VER=5.2';
      elseif ~isempty(findstr(result,'Borland C++ 5.0'))
        bcver = ' BC_VER=5.0';
      else
        error('Unsupported version of Borland');
      end
    end

    fprintf(cmdFileFid, 'set BORLAND=\n');
    fprintf(cmdFileFid, 'set BORLAND=%s\n', borland);
    fprintf(cmdFileFid, 'set %s\n', bcver);
    fprintf(cmdFileFid, '%s\n', makeCmd);
    fclose(cmdFileFid);
    makeCmdOut = cmdFile;
  else
    error(['The environment variable, BORLAND does not exist. Please ' ...
           'set it to where your Borland compiler is installed, or use ',...
           'mex -setup']);

    makeCmdOut = makeCmd;  % No change
  end

%endfunction setup_for_borland
