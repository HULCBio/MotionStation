function loadfrom(this, projects)
% LOADFROM Loads project objects from the selected file.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/20 23:20:49 $

Dlg = this.Dialogs.Load;
if isempty(Dlg) || ~ishandle(Dlg)
  Dlg = LocalCreateDlg(this);
  this.Dialogs.Load = Dlg;
end

if nargin < 2
  projects = this.Root.getChildren;
end

% Populate list box
ud = get(Dlg, 'UserData');
set(ud.Edit(1), 'String', '', 'TooltipString', '')
set(ud.List,    'String', '', 'Value', [])
set(Dlg, 'Visible', 'on')

% --------------------------------------------------------------------------
function Dlg = LocalCreateDlg(this)
DlgH = 20;
DlgW = 50;
UIColor = get(0, 'DefaultUIControlBackgroundColor');
Dlg = figure('Name', 'Load Projects', ...
             'Visible', 'off', ...
             'Resize', 'off', ...
             'MenuBar', 'none', ...
             'Units', 'character',...
             'Position', [0 0 DlgW DlgH], ...
             'Color',  UIColor, ...
             'IntegerHandle', 'off', ...
             'HandleVisibility', 'off',...
             'WindowStyle', 'modal',...
             'NumberTitle', 'off');
centerfig(Dlg, 0);
set(Dlg, 'CloseRequestFcn', {@localHide Dlg})

% Button group
xgap = 1;
BW = 10;  BH = 1.5; Bgap = 1;
X0 = DlgW - xgap - 3*BW - 2*Bgap;
Y0 = 0.5;
uicontrol('Parent',   Dlg, ...
          'Units','   character', ...
          'Position', [X0 Y0 BW BH], ...
          'Callback', {@localOK Dlg this},...
          'Interruptible', 'off', ...
          'BusyAction', 'cancel', ...
          'String',   'OK');

X0 = X0+BW+Bgap;
uicontrol('Parent',   Dlg, ...
          'Units','   character', ...
          'Position', [X0 Y0 BW BH], ...
          'Callback', {@localHide Dlg},...
          'String',   'Cancel');

X0 = X0+BW+Bgap;
uicontrol('Parent',   Dlg, ...
          'Units',    'character', ...
          'Callback', @localHelp, ...
          'Position', [X0 Y0 BW BH], ...
          'String',   'Help');

Y0 = Y0 + BH + 0.7;
uicontrol('Parent', Dlg, ...
          'BackgroundColor', UIColor,...
          'Style', 'text', ...
          'String', 'Load from:', ...
          'HorizontalAlignment', 'left', ...
          'Units', 'character',...
          'Position', [xgap Y0 11 1.2]);

X0 = xgap+12;
EW = DlgW-X0-6-xgap;
ud.Edit(1) = uicontrol('Parent', Dlg, ...
                       'Style', 'edit', ...
                       'BackgroundColor', 'white', ...
                       'HorizontalAlignment', 'left', ...
                       'String', '', ...
                       'Callback', {@localSetList Dlg this},...
                       'Units', 'character', ...
                       'Position', [X0 Y0 EW 1.4]);

ud.Edit(2) = uicontrol('Parent', Dlg, ...
                       'Style', 'pushbutton', ...
                       'BackgroundColor', UIColor,...
                       'String', '...',...
                       'TooltipString', 'Select MAT file', ...
                       'Units', 'character',...
                       'Callback', {@localSetFile Dlg this},...
                       'Position', [X0+EW+1 Y0 5 1.4]);

y0 = DlgH-1.5;
uicontrol('Parent', Dlg, ...
          'BackgroundColor', UIColor,...
          'Style', 'text', ...
          'String', 'Select projects to load:', ...
          'HorizontalAlignment', 'left', ...
          'Units', 'character',...
          'Position', [xgap y0 40 1]);

Y0 = Y0 + BH + 0.7;
LH = y0-Y0-0.5;
ud.List = uicontrol('Parent', Dlg, ...
                    'Style',  'listbox', ...
                    'Units',  'character',...
                    'BackgroundColor',[1 1 1],...
                    'Position', [xgap Y0 DlgW-2*xgap LH],...
                    'Max', 2);

% Listener to parent deletion
ud.Listener = handle.listener(this, 'ObjectBeingDestroyed', {@localDelete Dlg});

set(Dlg, 'UserData', ud)

% --------------------------------------------------------------------------
function localHelp(varargin)
% RE: This dialog serves both CST and SRO
try
    helpview([docroot '/toolbox/slcontrol/slcontrol.map'],'load_project','CSHelpWindow');
catch
    try
        helpview([docroot '/toolbox/slestim/slestim.map'],'load_project','CSHelpWindow');
    catch
        helpview([docroot '/toolbox/mpc/mpc.map'],'load_project','CSHelpWindow');
    end
end

% --------------------------------------------------------------------------
function localDelete(hSrc, hData, hDlg)
% Deletes dialog when parent object goes away
delete(hDlg)

% --------------------------------------------------------------------------
function localHide(hSrc, hData, hDlg)
% Cancel or close 
set(hDlg, 'Visible', 'off')

% --------------------------------------------------------------------------
function localSetFile(hSrc, hData, Dlg, this)
% Select MAT file
ud = get(Dlg, 'UserData');
str = get(ud.Edit(1), 'String');

[filename, pathname] = uigetfile('*.mat', 'Select MAT file', str);
if ~isequal(filename,0) && ~isequal(pathname,0)
  % Append path if file is not in the current directory
  if ~strcmp( pathname(1:end-1),pwd )
    filename = [ pathname filename ];
  end
  set(ud.Edit(1), 'String', filename)

  localSetList([], [], Dlg, this)
end

% --------------------------------------------------------------------------
function localSetList(hSrc, hData, Dlg, this)
ud = get(Dlg, 'UserData');
filename = get(ud.Edit(1), 'String');
set( ud.Edit(1), 'TooltipString', filename )

nodes = [];
if exist(filename, 'file') ~= 0
  nodes = this.load(filename);
elseif ~isempty(filename)
  msg = sprintf( [ '%s\nFile not found.\n', ...
                   'Please verify the correct file name was given.'], ...
                 filename );
  warndlg( msg, 'Select MAT File' )
end

set(ud.List, 'String', get(nodes, {'Label'}), 'Value', 1:length(nodes))

% --------------------------------------------------------------------------
% REM: This callback is sychronized and will not execute simultaneously.
function localOK(hSrc, hData, Dlg, this)
% OK
ud = get(Dlg, 'UserData');
selection = get(ud.List,    'Value');
filename  = get(ud.Edit(1), 'String');

if exist(filename, 'file') ~= 0
  nodes    = this.load(filename);
  
  if ~isempty(selection)
    projects = nodes(selection);
    set( projects, 'SaveAs', '' );

    % Hide dialog and show warning
    set(Dlg,'Visible','off')
    
    % Post load initialization
    projects = LocalPreLoadTasks(this, projects);
    
    % Add nodes
    newProjNodes = [];
    for ct = 1:length(projects)
      newProjNodes = [newProjNodes; this.Root.addNode( projects(ct) )];
    end
    
    % Post load initialization
    LocalPostLoadTasks(this, newProjNodes)
    
  elseif ~isempty(nodes)
    msg = sprintf( 'No project has been selected.');
    warndlg( msg, 'Select Projects' )
  end
elseif ~isempty(filename)
  msg = sprintf( [ '%s\nFile not found.\n', ...
                   'Please verify the correct file name was given.'], ...
                 filename );
  warndlg( msg, 'Select MAT File' )
end

% --------------------------------------------------------------------------
function projects = LocalPreLoadTasks(this, projects)
% Prepare before loading
for ct1 = length(projects):-1:1
  try 
    projects(ct1).preLoad(this);
  catch
    [dummy, errmsg] = strtok( lasterr, sprintf('\n') );
    uiwait( errordlg( errmsg, 'Load Error', 'modal' ) )
    projects(ct1) = [];
  end
end

for ct1 = 1:length(projects)
  tasks = projects(ct1).getChildren;
  for ct2 = 1:length(tasks)
    if isa(tasks(ct2),'explorer.tasknode')
        try
          tasks(ct2).preLoad(this);
        catch
          [dummy, errmsg] = strtok( lasterr, sprintf('\n') );
          uiwait( errordlg( errmsg, 'Load Error', 'modal' ) )
          tasks(ct2).disconnect;
        end
    end
  end
end

% --------------------------------------------------------------------------
function LocalPostLoadTasks(this, projects)
% Process task nodes after loading projects and adding them to the tree.
for ct1 = 1:length(projects)
  projects(ct1).postLoad(this);
  tasks = projects(ct1).getChildren;
  for ct2 = 1:length(tasks)
      if isa(tasks(ct2),'explorer.tasknode') %jgo
         tasks(ct2).postLoad(this);
      end
  end
end
