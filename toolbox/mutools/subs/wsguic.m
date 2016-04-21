%   Custom Callback for WSGUI

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

[mtgui_names,mtgui_nl,mtgui_as] = ...
    gguivar('ALLNAMES','ALLNAMESLEN','APPLYSTAT');
mtgui_strtmp = get(get(gguivar('CUSTOM'),'userdata'),'string');
if ~isempty(deblank(mtgui_strtmp))
    mtgui_str = mtgui_strtmp(1,:);
    for mtgui_i=2:size(mtgui_strtmp,1)
        mtgui_str = [mtgui_str ' | ' deblank(mtgui_strtmp(mtgui_i,:))];
    end
    mtgui_dp = pullaprt('find',mtgui_str);
    mtgui_loc = [];
    if ~isempty(mtgui_names)
        for mtgui_i=1:size(mtgui_names,1)
            mtgui_name = mtgui_names(mtgui_i,1:mtgui_nl(mtgui_i));
            mtgui_words = str2mat('mtgui_name',mtgui_name);
            mtgui_com = pullaprt('fillin',mtgui_str,mtgui_dp,mtgui_words);
            mtgui_fail = 0;
            mtgui_keep = 0;
            eval(['mtgui_keep=' mtgui_com ';'],'mtgui_fail=1;');
            if mtgui_fail == 0
                if mtgui_keep == 1
                    mtgui_loc = [mtgui_loc;mtgui_i];
                end
            end
        end
    end
else
    mtgui_loc = 1:size(mtgui_names,1);
end
if isempty(mtgui_loc)
    sguivar('CUSITEMS',[]);
else
    mtgui_allinfo = gguivar('ALLINFO');
    sguivar('CUSITEMS',mtgui_allinfo(mtgui_loc,:));
end
sguivar('APPLYSTAT',[mtgui_as(1);0]);
clear mtgui_str mtgui_dp mtgui_words mtgui_keep mtgui_fail mtgui_name mtgui_strtmp
clear mtgui_names mtgui_i mtgui_nl mtgui_allinfo mtgui_loc mtgui_com mtgui_as

set(gguivar('SR_BUT'),'enable','off')

















