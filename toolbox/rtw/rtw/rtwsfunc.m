function displist = rtwsfunc(rtw_sf_name,block)
%RTWSFUNC: Used by the RTW S-Function code format to create a
%          block with the proper sfunctionmodules parameter set and
%          the text for display in the icon
% 
%  rtw_sf_name = String containing the name of the RTW generated
%                S-Function
%  block       = the handle to the RTW s-function block(gcb)
%
  
% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.12.2.3 $
  
  sfmodules = ''; modules = ''; sflibs = ''; usermodules = '';
  if exist(rtw_sf_name) == 3
    mkpath = which(rtw_sf_name);
    modelname = rtw_sf_name(1:end-3);
    sfcn_sizes = feval(rtw_sf_name, [], [], [], 0);
    if sfcn_sizes(31) == 1 % rtwsfunc
      mkfile = strrep(mkpath,[rtw_sf_name,'.',mexext], ...
		      [modelname,'_sfcn_rtw',filesep,modelname,'.mk']);
    else
      mkfile = strrep(mkpath,[rtw_sf_name,'.',mexext], ...
		      [modelname,'_ert_rtw',filesep,modelname,'.mk']);
    end
    fid = fopen(mkfile,'r');
    if fid == -1
      error(['Unable to find ', ...
	     'makefile: ', sprintf('\n'), '  ',mkfile, sprintf('\n'), ...
	    'for the Real-Time Workshop generated MEX ', ...
	     'S-function ''', rtw_sf_name, '''.', sprintf('\n'), ...
	     'This is required in order to show the underlying ', ...
	     'modules or to build a Real-Time Workshop target from ', ...
	     'this model. If simulation capability is only needed, ', ...
	     'unselect the ''Show Module List'' checkbox, otherwise ', ...
	     'try rebuilding the Real-Time Workshop S-function ', ...
	     'target for model ''',modelname, '''']);
    else
      got_sfmodules =0; got_sflibs =0; got_usermodules =0;
      while (1)
	line = fgetl(fid); if ~ischar(line), break; end
	sfmodulesIdx = findstr(line,  'S_FUNCTIONS     =');
	sflibsIdx = findstr(line,     'S_FUNCTIONS_LIB =');
	usermodulesIdx = findstr(line,'USERMODULES     =');
	if length(sfmodulesIdx) == 1
	  sfmodules = line(sfmodulesIdx+17:end);
	  got_sfmodules =1;
	end
	if length(sflibsIdx) == 1
	  sflibs = line(sflibsIdx+17:end);
	  got_sflibs = 1;
	end
	if length(usermodulesIdx) == 1
	  usermodules = line(usermodulesIdx+17:end);
	  got_usermodules =1;
	end
	if got_sfmodules & got_sflibs & got_usermodules
	  break;
	end
      end
      fclose(fid);
    end
  end
  % Create the list for the sfunctionmodules parameter.
  sflist   = strrep(sfmodules,'.c','');
  sflist   = strrep(sflist,'.obj','');
  userlist = strrep(usermodules,'.c','');
  userlist = strrep(userlist,'.obj','');
  list     = [sflist, ' ', userlist, ' ', sflibs];
  
  %
  % Set up the module list for code generation.  Note that this is
  % a "read only if compiled" parameter, so it can only be set
  % at initialization time (which includes code generation).
  %
  if strcmp(get_param(bdroot(block),'SimulationStatus'),'initializing'),
    set_param(block,'sfunctionmodules', list);
  end
  
  % Create the list for the display inside the block.
  sflist = strrep(sfmodules,'.c','.c\n');
  sflist = strrep(sflist,'.obj','.c\n');
  moduleslist = strrep(modules,'.c','.c\n');
  moduleslist = strrep(moduleslist,'.obj','.c\n');
  userlist = strrep(usermodules,'.c','.c\n');
  userlist = strrep(userlist,'.obj','.c\n');
  sflibs = strrep(sflibs,'.lib','.lib\n');
  sflibs = strrep(sflibs,'.a','.a\n');
  displist = [sflist, moduleslist, userlist, sflibs];
  if isempty(deblank(displist))
    displist = 'none';
  end

