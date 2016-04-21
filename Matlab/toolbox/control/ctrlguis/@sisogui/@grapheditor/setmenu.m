function setmenu(Editor,OnOff)
% Enables/disables editor menus.

%   $Revision: 1.3 $  $Date: 2002/04/19 02:46:12 $
%   Copyright 1986-2002 The MathWorks, Inc.

% RE: Menus must be disabled when Editor.SingularLoop=1
PlotAxes = getaxes(Editor.Axes);
uic = get(PlotAxes(1),'uicontextmenu');
set(get(uic,'Children'),'Enable',OnOff)
set(get(Editor.MenuAnchors,'Children'),'Enable',OnOff)
