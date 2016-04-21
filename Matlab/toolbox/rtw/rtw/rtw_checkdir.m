function rtw_checkdir
%RTW_CHECKDIR check if Real-Time Workshop can build in to current directory
%
%  This routine will error out if the dos() command doesn't work or
%  if the current directory is an invalid location for a Real-Time Workshop
%  build.
%
%  1) On Windows PCs, 
%     This file checks to see that the MATLAB 'dos' command is functional.
%     MATLAB does not support banging out and running an executable, when in a 
%     UNC directory (e.g. directory starting with "\\"). 
%     This file also checks to see if you are in a UNC directory.
%  
%  2) To avoid corruption of MATLAB directories under the MATLAB path, this
%     function checks to see if you are working in a protected directory 
%     under MATLABROOT.
%
%  3) Validate that current directory is not a Real-Time Workshop project
%     (build) directory.
%
  
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.8.2.3 $  
  
  % Check to see if 'dos' command is functional
  if ispc 
    CheckIfDosCommandOkay;
  end
  
  % Check to see if current directory is not in one of the protected directories
  valid_rtwdir = CheckValidDir;
  if (valid_rtwdir == 0)
    cr = sprintf('\n');
    error(['Your current working directory is: ', cr, '  ' ,pwd, cr,...
	   'The Real-Time Workshop does not permit you to build ',...
	   'programs in the',cr,...
	   'MATLAB installation area. Please change to a working ',...
	   'directory that',cr,...
	   'is not in the MATLAB installation area.']);
  end

  % Check to see if current directory is a project directory
  ErrorIfInProjDir;
  ErrorIfInSlprjDir;
%endfunction rtw_checkdir


% Function: CheckValidDir ======================================================
% Abstract:
%     On all platforms, this excludes any directory under
%     matlabroot, unless you are in matlabroot\work (PC) or tempdir.
%
function valid_rtwdir = CheckValidDir
   
  %---------------------------------------------------------------------%
  % Start with the assumption that you are in a valid working directory.%
  %---------------------------------------------------------------------%
  valid_rtwdir = 1;
  isValid_matlabtree_dir = 1;
  current_dir = pwd;
  len_current_dir = size(current_dir, 2);
  mlroot_dir  = matlabroot; 
  len_mlroot_dir = size(mlroot_dir, 2);

  if (ispc)
    % Use lower(matlabroot) on PC's because DOS can't discriminate between
    % upper and lower case file names
    current_dir = lower(pwd);
    mlroot_dir  = lower(matlabroot); 
  end
  
  %---------------------------------------------------------------------------%
  % To avoid corruption of critical MATLAB directories, check to see that     %
  % the current working directory is not one of the protected dirctories in   %
  % the MATLAB tree.                                                          %
  %---------------------------------------------------------------------------%
  if len_current_dir > len_mlroot_dir
    if strcmp(current_dir(1:len_mlroot_dir), mlroot_dir)
      %% Reject protected matlab tree directories
      if len_current_dir > len_mlroot_dir+3
        current_dir_plus4 = current_dir(1:len_mlroot_dir+4);
        if (strcmp(current_dir_plus4, [fullfile(mlroot_dir,'bin')]) | ...
            strcmp(current_dir_plus4, [fullfile(mlroot_dir,'etc')]) | ...
            strcmp(current_dir_plus4, [fullfile(mlroot_dir,'rtw')]))
          isValid_matlabtree_dir = 0;
        end
      elseif len_current_dir > len_mlroot_dir+4 & ...
	    strcmp(current_dir(1:len_mlroot_dir+5), ...
		   [fullfile(mlroot_dir,'help')])
	isValid_matlabtree_dir = 0;
      elseif len_current_dir > len_mlroot_dir+6 & ...
	    strcmp(current_dir(1:len_mlroot_dir+7), ...
		   [fullfile(mlroot_dir,'extern')])
	isValid_matlabtree_dir = 0;
      elseif len_current_dir > len_mlroot_dir+7 & ...
	    strcmp(current_dir(1:len_mlroot_dir+8), ...
		   [fullfile(mlroot_dir,'toolbox')])
	isValid_matlabtree_dir = 0;
      elseif len_current_dir > len_mlroot_dir+8 & ...
	    strcmp(current_dir(1:len_mlroot_dir+9), ...
		   [fullfile(mlroot_dir,'simulink')])
	isValid_matlabtree_dir = 0;
      elseif len_current_dir > len_mlroot_dir+9 & ...
	    strcmp(current_dir(1:len_mlroot_dir+10), ...
		   [fullfile(mlroot_dir,'stateflow')])
	isValid_matlabtree_dir = 0;
      end
    end
  end
  
  %---------------------------------------------------------------------------%
  % If a problem exists with the current directory, describe via an error msg %
  %---------------------------------------------------------------------------%
  %
  if ~isValid_matlabtree_dir
    valid_rtwdir = 0;
  end
%endfunction CheckValidDir


% Function CheckIfDosCommandOkay ============================================
% Abstract: 
%   On Windows PC, Verify that we can use dos('syscmd'). 
%   
function CheckIfDosCommandOkay
  if ~isunix
    err = '';
    try
      dosOutput = evalc('dos(''cd'')');
      if isempty(dosOutput)
	cr = sprintf('\n');
	err = ['The Real-Time Workshop uses the MATLAB dos() command. This ',...
	       'command',cr,...
	       'is not functional, e.g., ',cr,...
	       '  >> dos(''cd'')',cr,...
	       'has no output. There are two potential causes:', cr,...
	       '1) Another application such as a virus checker is running ',...
	       'and interfering ',cr, ...
	       '   with MATLAB. Try disabling any virus checkers or ', ...
	       'similar applications.',cr, ...
	       '2) The current working directory, ',cr,...
	       '     ''', pwd, '''',cr,...
	       '   is too long for the MATLAB dos() command. ',...
	       'Try reducing the path and/or',cr,...
	       '   filename sizes, i.e., cd to another working directory ',...
	       'or shorten your',cr,...
	       '   model name. The directory limitation problem is a ', ...
	       'limitation of the',cr,...
	       '   system calls provided by Windows 95/98/Me and is not ',...
	       'a problem with',cr,...
	       '   Windows NT/2000.'];
      end
    catch
      cr = sprintf('\n');
      err = ['The Real-Time Workshop uses the MATLAB dos() command. This ',...
	     'command',cr,...
	     'is not functional, e.g., ',cr,...
	     '  >> dos(''cd'')',cr,...
	     'produces the following error:',cr,...
	     '  ',strrep(lasterr,cr,[cr,'  ']), cr,...
	     'UNC pathname errors can be fixed by working on a explicit ',...
	     'drive (i.e., map the',cr,...
	     'network drive or use a local drive).'];
    end
    if ~isempty(err)
      error(err);
    end
  end

%endfunction CheckIfDosCommandOkay


% Function: ErrorIfInProjDir ===================================================
% Abstract:
%   Issue an error if cwd is a Real-Time Workshop project directory, i.e.,
%   rtw_proj.tmw exists.
%
function ErrorIfInProjDir
  
  rtwProjFile  = 'rtw_proj.tmw';
  
  if ~isempty(dir(rtwProjFile))
    fid = fopen(rtwProjFile,'r');
    if fid == -1
      return; % definetly not in a project directory.
    end
    fline = fgetl(fid);
    fclose(fid);
    %
    % Prior to version 4.0, the
    %  rtw_proj.tmw file looked like: 
    %      'Current RTW Project: ...'
    % with we changed the starting characters to be
    %      'Real-Time Workshop project for: ...'
    % (because we now have project directories).
    %
    if strncmp(fline,'Current RTW Project',19)
      return; % not in project directory (pre 4.0 build)
    end
    cr = sprintf('\n');
    error(['Aborting code generation because current working directory,',cr, ...
	   '  ''', pwd,'''',cr,...
	   'is an existing Real-Time Workshop project directory. ',...
	   'Please change ',cr,...
	   'current working directory to a non-project ',...
	   'directory (e.g. cd ..).']);
  end
  
%endfunction ErrorIfInProjDir

% Function: ErrorIfInSlprjDir ===================================================
% Abstract:
%   Detect whether we are in project build directory, which follows pattern
% such as slprj/build/<model>/sl/sim/src/core
function ErrorIfInSlprjDir
cr = sprintf('\n');
errormsg = ['Aborting code generation because current working directory,',cr, ...
        '  ''', pwd,'''',cr,...
        'is an existing Real-Time Workshop project build directory. ',...
        'Please change ',cr,...
        'current working directory to a non-project ',...
        'directory.'];
currentdir = pwd;
slprjIdx = strfind(currentdir, 'slprj');
if ~isempty(slprjIdx)
    slProjFile = fullfile(currentdir(1:slprjIdx+length('slrpj')-1), 'sl_proj.tmw');
    if exist(slProjFile) == 2
      error(errormsg); % we are in project build directory.
    end
end
%endfunction ErrorIfInSlprjDir

% [EOF] rtw_checkdir.m
