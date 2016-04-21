%COMTMPO Script file for COMMGUI
%
%WARNING: This is an obsolete function and may be removed in the future.

%  Wes Wang, original design
%  Jun Wu, last update, Mar-07, 1997
%  Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.14 $

handle_com_tmp = get(gcf, 'UserData');
value_com_tmp = get(handle_com_tmp(34), 'string');
if ~isempty(deblank(value_com_tmp))
    eval(['set(', num2str(handle_com_tmp(34), 20), ',''UserData'',' value_com_tmp, ');']);
end;
clear handle_com_tmp
clear value_com_tmp
