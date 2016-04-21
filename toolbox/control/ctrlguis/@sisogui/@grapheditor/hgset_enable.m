function hgset_enable(Editor)
% Enables GUI menus and tools.

%   $Revision: 1.7 $  $Date: 2001/08/05 00:34:20 $
%   Copyright 1986-2001 The MathWorks, Inc.

% Turn editor on
Editor.EditMode = 'idle';

% Set all limit modes to auto 
% RE: Initialized to manual so that limits correctly update when 
%     changing units before importing data
set(Editor.Axes,'XlimMode','auto','YlimMode','auto');

% Enable right-click menu
uic = get(Editor.hgget_axeshandle(1),'uicontextmenu');
set(get(uic,'Children'),'Enable','on')
