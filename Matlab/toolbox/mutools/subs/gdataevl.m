% the following variables are all the same row dimension, and are
%   available in ANY mu-GUI-TOOL.  Here they are accessed from the
%   current figure
% EDITHANDLES - handles of editable text which are to be evaluated
% EDITRESULTS - strings of GUI-TOOL variables where the results of the evaluation go
% RESTOOLHAN - integers which are the handles of the tool where the result goes
%                   sguivar(EDITRESULTS,eval(EDITHANDLES),RESULTTOOLHAN)
% ERRORCB - strings of commands to run if error occurs in eval
% SUCCESSCB - stings of commands to run if eval is successful
%
% MINFOTAB - nx4 matrix of MINFO data for returned variables from the evals
%
% This is a script-file so all evals() are executed in Workspace

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

%   See callbacks of REFRESH buttons, in dkitgui, for instance

set(get(0,'children'),'pointer','watch');
drawnow;
[mtgui_h,mtgui_er,mtgui_rh,mtgui_scb,mtgui_ecb] = ...
    gguivar('EDITHANDLES','EDITRESULTS','RESTOOLHAN','SUCCESSCB','ERRORCB');
mtgui_tmp = zeros(size(mtgui_h,1),4);
for mtgui_i =1:size(mtgui_h,1)
%   callback here to (for instance) give message
    mtgui_fail = 0;
    eval(['mtgui_tmpp = ' get(mtgui_h(mtgui_i),'string') ';'],'mtgui_fail=1;');
    if mtgui_fail == 0
        [mtgui_a,mtgui_tmp(mtgui_i,2),mtgui_tmp(mtgui_i,3),mtgui_tmp(mtgui_i,4)] = minfo(mtgui_tmpp);
        mtgui_tmp(mtgui_i,1) = find(mtgui_a(1) == str2mat('c','e','s','v','p'));
        sguivar(deblank(mtgui_er(mtgui_i,:)),mtgui_tmpp,mtgui_rh(mtgui_i,1));
        if ~isempty(mtgui_scb)
            eval(deblank(mtgui_scb(mtgui_i,:)));
        end
    else
        if ~isempty(mtgui_ecb)
            eval(deblank(mtgui_ecb(mtgui_i,:)));
        end
        mtgui_tmp(mtgui_i,:) = [nan nan nan nan];
    end
end
sguivar('MINFOTAB',mtgui_tmp);
set(get(0,'children'),'pointer','arrow');
drawnow;
clear mtgui_h mtgui_i mtgui_fail mtgui_tmpp mtgui_a
clear mtgui_tmp mtgui_er mtgui_rh mtgui_scb mtgui_ecb