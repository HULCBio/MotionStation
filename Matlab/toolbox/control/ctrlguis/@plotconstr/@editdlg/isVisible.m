function boo = isVisible(h)
%ISVISIBLE  Returns 1 if editor is visible.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:09:01 $

if isempty(h.Handles)
    % UI does not exist yet
    boo = 0;
else
    boo = strcmp(get(h.Handles.Frame, 'Visible'), 'on');
end
