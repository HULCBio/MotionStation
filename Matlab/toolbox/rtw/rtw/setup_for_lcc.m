function makeCmdOut = setup_for_lcc(args)
%
% Function: SetupForLcc ========================================================
% Abstract:
%       Configure the build process for Lcc
%
%       This function wraps the raw make command, args.makeCmd (e.g. 'gmake -f
%       model.mk MAT_FILE=1') in a batch (.bat) file that sets up some
%       environment variables needed during the build process.
%

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/15 00:25:05 $
  
  makeCmd        = args.makeCmd;
  modelName      = args.modelName;
  verbose        = args.verbose;
  
  % args.compilerEnvVal not used

  lcc_root = parsestrforvar(makeCmd,'LCC_LOC');
  if isempty(lcc_root)
    lcc_root = [matlabroot '\sys\lcc'];
  end

  if ~isempty(lcc_root)
    if isempty(dir([lcc_root,'\bin\lcc.exe']))
      error(['Unable to locate LCC in ' lcc_root '\bin .',sprintf('\n'), ...
             'Please make sure that you have LCC installed using MATLAB' ...
             ' installer.']);
    end
    cmdFile = ['.\',modelName, '.bat'];
    cmdFileFid = fopen(cmdFile,'wt');
    if ~verbose
      fprintf(cmdFileFid, '@echo off\n');
    end
    fprintf(cmdFileFid, 'set MATLAB=%s\n', matlabroot);
    fprintf(cmdFileFid, '%s\n', makeCmd );
    fclose(cmdFileFid);
    makeCmdOut = cmdFile;
  else
    if isempty(lcc_root)
      error(['Unable to locate LCC ' lcc_root , sprintf('\n'), ...
             'Please make sure that you have LCC installed using MATLAB' ...
             ' installer.']);
    end
    makeCmdOut = makeCmd;  % No change
  end

%endfunction setup_for_lcc
