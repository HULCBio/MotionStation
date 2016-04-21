% Script, called from WSGUI

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

[mtgui_names,mtgui_nl] = gguivar('ALLNAMES','ALLNAMESLEN');
if ~isempty(mtgui_names)
    mtgui_tmp = 32*ones(size(mtgui_names,1),25);
    mtgui_tmp(:,5) = mtgui_nl;
    mtgui_tmp(:,6:size(mtgui_names,2)+5) = setstr(mtgui_names);
    for mtgui_i=1:size(mtgui_names,1)
        mtgui_str = ['fminfo(',deblank(mtgui_names(mtgui_i,:)),');'];
        mtgui_str1 = '[mtgui_a,mtgui_tmpb,mtgui_tmpc,mtgui_tmpd]';
        %disp([mtgui_str1 ' = ' mtgui_str]);  % GJW -- weird.
        eval([mtgui_str1 ' = ' mtgui_str]);
        if strcmp(mtgui_a,'pckd')
            mtgui_tmp(mtgui_i,2) = sum(abs(mtgui_tmpb.*mtgui_tmpc));
            mtgui_tmp(mtgui_i,3) = 1;
            mtgui_tmp(mtgui_i,4) = length(mtgui_tmpd);
        else
            mtgui_tmp(mtgui_i,2) = mtgui_tmpb;
            mtgui_tmp(mtgui_i,3) = mtgui_tmpc;
            mtgui_tmp(mtgui_i,4) = mtgui_tmpd;
        end
        mtgui_tmp(mtgui_i,1) = find(mtgui_a(1) == ...
              str2mat('c','e','s','v','p','u'));
    end
    sguivar('ALLINFO',mtgui_tmp);
    clear mtgui_names mtgui_tmp mtgui_i mtgui_a mtgui_nl mtgui_str mtgui_str1
    clear mtgui_tmpb mtgui_tmpc mtgui_tmpd
else
    sguivar('ALLINFO',[]);
    clear mtgui_names mtgui_nl
    clear mtgui_names mtgui_tmp mtgui_i mtgui_a mtgui_nl mtgui_str mtgui_str1
end
