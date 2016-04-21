function [tmf,envVal,otherOpts] = get_tmf_for_target(target)
%GET_TMF_FOR_TARGET Returns the default template makefile on for given target
%
%       On Unix systems, the default template makefile is <target>_unix.tmf.
%       On PC systems, the default template makefile is determined by
%       examining mexopts.bat (see help mex). It will be <target>_watc.tmf
%	if WATCOM exists in mexopts.bat, <target>_bc.tmf if BORLAND exists
%	in mexopts.bat, otherwise <target>_vc.tmf.

%       Copyright 1994-2004 The MathWorks, Inc.
%       $Revision: 1.17.2.2 $


  envVal = ''; % Will be non-empty if we learned of the environment variable
               % from the mexopts preference file on the PC

  if isunix
    suffix = '_unix.tmf';
    otherOpts = [];
  else

    [envVal, suffix, otherOpts] = parse_mexopts_for_envval('');

    if isempty(suffix)
      if ~isempty(getenv('DEVSTUDIO')) | ~isempty(getenv('MSDevDir'))
        suffix = '_vc.tmf';
      elseif ~isempty(getenv('WATCOM'))
        suffix = '_watc.tmf';
      elseif ~isempty(getenv('BORLAND'))
        suffix = '_bc.tmf';
      elseif (exist([matlabroot '\sys\lcc']))
	suffix = '_lcc.tmf';
      else
	suffix = '_lcc.tmf'; 
	envVal = 'no default compiler';
      end
    end

  end

  tmf = [target, suffix];

%endfunction get_tmf_for_target


%[eof] get_tmf_for_target.m
