function hgset_enable(sisodb)
% Enables GUI menus and tools.

%   $Revision: 1.5 $  $Date: 2001/08/05 00:34:22 $
%   Copyright 1986-2001 The MathWorks, Inc.

HG = sisodb.HG;

% Enable toolbar icons (except help, monitored on its own)
set(HG.Toolbar(1:end-1),'Enable','on')

% Enable figure menus and controls
set(get(HG.Menus.File.Top,'Children'),'Enable','on')
set(get(HG.Menus.Edit.Top,'Children'),'Enable','on')
set(get(HG.Menus.View.Top,'Children'),'Enable','on')
set(get(HG.Menus.Tools.Top,'Children'),'Enable','on')
set(get(HG.Menus.Compensator.Top,'Children'),'Enable','on')

% Disable undo/redo (have their own state management)
set([HG.Menus.Edit.Undo;HG.Menus.Edit.Redo],'Enable','off')

% Enable controls
set(HG.CompensatorFrame.GainEdit,'Enable','on')

