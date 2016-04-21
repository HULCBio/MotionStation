% called from DKITGUI

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

        dk_failflg = 0;
        eval(['dk_tmp = ' gguivar('OMEGASTRING') ';'],['dk_failflg=1;']);
        if dk_failflg == 0 & exist('dk_tmp')
            sguivar('OMEGA',dk_tmp);
        else
            sguivar('OMEGA',[]);
        end
	clear dk_tmp dk_failflg
