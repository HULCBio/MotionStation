% callback for exporting to workspace in WSGUI

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

if ~isempty(deblank(get(gguivar('LEFTHAND'),'string')))
    mtgui_com = [get(gguivar('LEFTHAND'),'string') ' = ' get(gguivar('RIGHTHAND'),'string') ';'];
else
    mtgui_com = [get(gguivar('RIGHTHAND'),'string')];
end
mtgui_fail=0;
eval(mtgui_com,'mtgui_fail=1;');
if mtgui_fail==1
    set(gguivar('EXPMESS'),'String',...
        ['Error in expression     >> ' mtgui_com])
%        ['Variable ' get(gguivar('RIGHTHAND'),'string') ' Not Found'])
else
    set(gguivar('EXPMESS'),'String',['>> ' mtgui_com '     executed ' nicetod(1)])
end
clear mtgui_com mtgui_fail