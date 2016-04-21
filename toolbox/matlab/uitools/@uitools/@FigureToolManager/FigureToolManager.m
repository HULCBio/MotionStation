function [hThis] = FigureToolManager(hfig)

% Copyright 2002 The MathWorks, Inc.

hThis = uitools.FigureToolManager;
hThis.Figure = hfig;

% Create CommandManager  
hCmdManager = uiundo.CommandManager;
hThis.CommandManager = hCmdManager;

% Create Listeners
l = handle.listener(hCmdManager,'CommandStackChanged',{@locCommandStackChanged,hThis});

% Add Listeners
hThis.CommandManagerListeners = l;

%-----------------------------------------%
function locCommandStackChanged(obj,evd,hThis)

fig = hThis.Figure;
cmd_manager = obj;

locUpdateUndoUI(hThis,fig,cmd_manager);
locUpdateRedoUI(hThis,fig,cmd_manager);

%-----------------------------------------%
function locUpdateUndoUI(hThis, fig,cmd_manager)

undocmd = cmd_manager.peekundo;

hMenu = hThis.UndoUIMenu;

% If invalid handle, load by searching tag
if isempty(hMenu) | ~ishandle(hMenu)
  hMenu = findall(fig,'tag','figMenuEditUndo'); 
  hThis.UndoUIMenu = hMenu;
end

% If still no handle, bail out
if isempty(hMenu) | ~ishandle(hMenu)
  hThis.UndoUIMenu = [];
  return;
end

if ishandle(undocmd)
  label = sprintf('&Undo %s',undocmd.Name);
  set(hMenu,'Label',label,'Enable','on');
  hfunc = @undo;
  set(hMenu,'callback',{@locExecute,hfunc,cmd_manager});  
else
  set(hMenu,'Label','&Undo','Enable','off','callback','');
end

%-----------------------------------------%
function locUpdateRedoUI(hThis,fig,cmd_manager)

redocmd = cmd_manager.peekredo;

hMenu = hThis.RedoUIMenu;

% If invalid handle, load by searching tag
if isempty(hMenu) | ~ishandle(hMenu)
  hMenu = findall(fig,'tag','figMenuEditRedo'); 
  hThis.RedoUIMenu = hMenu;
end

% If still no handle, bail out
if isempty(hMenu) | ~ishandle(hMenu)
  hThis.RedoUIMenu = [];
  return;
end

if ~isempty(redocmd)
  name = redocmd.Name;
  set(hMenu,'Label',sprintf('&Redo %s',name),'Enable','on');
  hfunc = @redo;
  set(hMenu,'callback',{@locExecute,hfunc,cmd_manager});  
else
  set(hMenu,'Label','&Redo','Enable','off','callback','');
end


%-----------------------------------------%
function locExecute(junk1,junk2,func,arg)

feval(func,arg);












