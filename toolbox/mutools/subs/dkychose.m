% FUNCTION: recognizes existing variables in workspace,
%  and M-files which return a variable.  M-files may
%  pass arguments of variables in workspace.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $


  dk_tmp = gguivar('YCHOICE_STR');
  if strcmp(dk_tmp,'All') | strcmp(dk_tmp,'all')
	sguivar('YCHOICE',1:gguivar('NMEAS'));
 	if gguivar('CITER')>=2
		dk_able(2,2)
	end
  else
  	dk_fail = 0;
  	eval(['dk_tmpp = ' dk_tmp ';'],'dk_fail=1;');
  	if dk_fail == 1
      		sguivar('YCHOICE',1:gguivar('NMEAS'));
		dk_yd = get(gguivar('YCHOOSE'),'userdata');
		set(dk_yd(2),'string','All');
		clear dk_yd
  	else
      		sguivar('YCHOICE',dk_tmpp);
		if gguivar('CITER')>=2
			dk_able(2,2)
		end
  	end
  	clear dk_tmpp dk_tmp dk_fail
  end