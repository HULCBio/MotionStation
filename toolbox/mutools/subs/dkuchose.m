% FUNCTION: recognizes existing variables in workspace,
%  and M-files which return a variable.  M-files may
%  pass arguments of variables in workspace.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

  dk_tool = gcf;
  dk_tmp = gguivar('UCHOICE_STR',dk_tool);
  if strcmp(dk_tmp,'All') | strcmp(dk_tmp,'all')
	sguivar('UCHOICE',1:gguivar('NCNTRL',dk_tool),dk_tool);
 	if gguivar('CITER',dk_tool)>=2
		dk_able(2,2,dk_tool)
	end
 else
  	dk_fail = 0;
  	eval(['dk_tmpp = ' dk_tmp ';'],'dk_fail=1;');
  	if dk_fail == 1
      		sguivar('UCHOICE',1:gguivar('NCNTRL',dk_tool),dk_tool);
		dk_ud = get(gguivar('UCHOOSE',dk_tool),'userdata');
		set(dk_ud(2),'string','All');
		clear dk_ud
  	else
      		sguivar('UCHOICE',dk_tmpp,dk_tool);
		if gguivar('CITER',dk_tool)>=2
			dk_able(2,2,dk_tool)
		end
  	end
  	clear dk_tmpp dk_tmp dk_fail dk_tool
  end