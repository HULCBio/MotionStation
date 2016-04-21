function boo = isVisible(h)
%ISVISIBLE  Returns 1 if editor is visible.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:12:52 $

if ~isa(h.Dialog,'sisogui.tooldlg')
    % UI does not exist yet
    boo = 0;
else
    boo = h.Dialog.isVisible;
end
