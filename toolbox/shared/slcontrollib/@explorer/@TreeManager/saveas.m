function saveas(this, projects, varargin)
% SAVEAS Saves the project objects to the selected file.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.r
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:08:23 $

Dlg = this.Dialogs.Save;
if isempty(Dlg) || ~ishandle(Dlg)
  Dlg = LocalCreateDlg(this);
  this.Dialogs.Save = Dlg;
end

if nargin < 2
  projects = this.Root.getChildren;
end

% Populate list box
ud = get(Dlg, 'UserData');
nodes = this.Root.getChildren;
[dummy, ia, ib] = intersect(nodes, projects);
set(ud.List, 'String', get(nodes, {'Label'}))
set(Dlg, 'Visible', 'on')
drawnow;
set(ud.List, 'Value', ia)
if nargin > 2
  uiwait(Dlg)
end

% --------------------------------------------------------------------------
function Dlg = LocalCreateDlg(this)
DlgH = 20;
DlgW = 50;
UIColor = get(0, 'DefaultUIControlBackgroundColor');
Dlg = figure('Name', 'Save Projects', ...
             'Visible', 'off', ...
             'Resize', 'off', ...
             'MenuBar', 'none', ...
             'Units', 'character',...
             'Position', [0 0 DlgW DlgH], ...
             'Color',  UIColor, ...
             'IntegerHandle', 'off', ...
             'HandleVisibility', 'off', ...
             'WindowStyle', 'modal', ...
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
          'String', 'Save as:', ...
          'HorizontalAlignment', 'left', ...
          'Units', 'character',...
          'Position', [xgap Y0 10 1.2]);

X0 = xgap+10;
EW = DlgW-X0-6-xgap;
ud.Edit(1) = uicontrol('Parent', Dlg, ...
                       'Style', 'edit', ...
                       'BackgroundColor', 'white', ...
                       'HorizontalAlignment', 'left', ...
                       'String', '', ...
                       'Units', 'character', ...
                       'Position', [X0 Y0 EW 1.4]);

ud.Edit(2) = uicontrol('Parent', Dlg, ...
                       'Style', 'pushbutton', ...
                       'BackgroundColor', UIColor,...
                       'String', '...',...
                       'TooltipString', 'Select MAT file', ...
                       'Units', 'character',...
                       'Callback', {@localSetFile Dlg},...
                       'Position', [X0+EW+1 Y0 5 1.4]);

y0 = DlgH-1.5;
uicontrol('Parent', Dlg, ...
          'BackgroundColor', UIColor,...
          'Style', 'text', ...
          'String', 'Select projects to save:', ...
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
                    'Max', 2, ...
                    'Value', []);

% Listener to parent deletion
ud.Listener = handle.listener(this, 'ObjectBeingDestroyed', {@localDelete Dlg});

set(Dlg, 'UserData', ud)

% --------------------------------------------------------------------------
function localHelp(es,ed)
% RE: This dialog serves both CST and SRO
try
    helpview([docroot '/toolbox/slcontrol/slcontrol.map'],'save_project','CSHelpWindow');
catch
    try
        helpview([docroot '/toolbox/slestim/slestim.map'],'save_project','CSHelpWindow');
    catch
        helpview([docroot '/toolbox/mpc/mpc.map'],'save_project','CSHelpWindow');
    end
end

% --------------------------------------------------------------------------
function localDelete(hSrc, hData, hDlg)
% Deletes dialog when parent object goes away
uiresume(hDlg)
delete(hDlg)

% --------------------------------------------------------------------------
function localHide(hSrc, hData, hDlg)
% Cancel or close 
set(hDlg, 'Visible', 'off')
uiresume(hDlg)

% --------------------------------------------------------------------------
function localSetFile(hSrc, hData, Dlg)
% Select MAT file
ud = get(Dlg, 'UserData');
str = get(ud.Edit(1), 'String');

[filename, pathname] = uiputfile('*.mat', 'Select MAT file', str);
if ~isequal(filename,0) && ~isequal(pathname,0)
  % Append path if file is not in the current directory
  if ~strcmp( pathname(1:end-1), pwd )
    filename = [ pathname filename ];
  end
  set(ud.Edit(1), 'String', filename, 'TooltipString', filename)
end

% --------------------------------------------------------------------------
function localOK(hSrc, hData, Dlg, this)
% Save projects
ud = get(Dlg, 'UserData');
selection = get(ud.List,    'Value');
filename  = get(ud.Edit(1), 'String');
nodes     = this.Root.getChildren;

if ~isempty(filename) && ~isempty(selection)
  projects = nodes(selection);
  set( projects, 'SaveAs', filename );
  
  % Actual saving done here
  try
    this.save( projects )
  catch
    [dummy, errmsg] = strtok( lasterr, sprintf('\n') );
    uiwait( errordlg( errmsg, 'Save Error', 'modal' ) )
    return
  end
else
  uiwait(warndlg('No file name or project selected', 'Save Warning', 'modal'))
  return
end

% Hide dialog
set(Dlg, 'Visible', 'off')
uiresume(Dlg)
