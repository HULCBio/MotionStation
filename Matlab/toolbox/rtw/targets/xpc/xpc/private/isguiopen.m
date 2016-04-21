function result = isguiopen
%ISGUIOPEN checks to see if a GUI (target or host scope manager) is open
%
%   ISGUIOPEN checks to see if a host or target scope manager GUI is open.
%   If it is, an error dialog box is displayed, and a result of 1 is
%   returned.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2004/04/08 21:04:33 $

result = 0;
fvisibiltystat=get(0,'showhiddenhandles');
set(0, 'ShowHiddenHandles', 'on');
fig=findobj(0, 'Type', 'Figure', 'Tag', 'xPCTargetHostScopeManager');
h_main = get(0, 'Children');
opened = strmatch('xPC Target: Target Manager', get(h_main, 'Name'));
set(0,'showhiddenhandles',fvisibiltystat);

if (~isempty(fig) & ~isempty(opened))
    xpcscope(-5,1);                       % close it, but not from callback
    xpctgscope(-8)
    result=0;
    return
elseif ~isempty(fig)
       xpcscope(-5,1);                       % close it, but not from callback
       result=0;
elseif ~isempty(opened)
        xpctgscope(-8);
        result=0;
end
