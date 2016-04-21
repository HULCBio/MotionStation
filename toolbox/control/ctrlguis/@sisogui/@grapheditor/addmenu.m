function h = addmenu(Editor,Anchor,MenuType)
%ADDMENU  Creates generic editor context menus.
% 
%   H = ADDMENU(EDITOR,ANCHOR,MENUTYPE) creates a menu item, related
%   submenus, and associated listeners.  The menu is attached to the 
%   parent object with handle ANCHOR.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.38 $ $Date: 2002/04/10 05:02:06 $

switch MenuType
    
case 'add'
    % Add Pole/Zero menu
    LoopData = Editor.LoopData;
    h = uimenu(Anchor,'Label',sprintf('Add Pole/Zero'));
    uimenu(h,'Label',sprintf('Real Pole'),...
        'Callback',{@LocalAddPZ Editor 'Real' 'Pole'});
    uimenu(h,'Label',sprintf('Complex Pole'),...
        'Callback',{@LocalAddPZ Editor 'Complex' 'Pole'});
    uimenu(h,'Label',sprintf('Integrator'),...
        'Callback',{@LocalAddInt Editor});
    uimenu(h,'Label',sprintf('Real Zero'),...
        'Callback',{@LocalAddPZ Editor 'Real' 'Zero'}, ...
        'Separator','on');
    uimenu(h,'Label',sprintf('Complex Zero'),...
        'Callback',{@LocalAddPZ Editor 'Complex' 'Zero'});
    uimenu(h,'Label',sprintf('Differentiator'),...
        'Callback',{@LocalAddDiff Editor});
    uimenu(h,'Label',sprintf('Lead'),...
        'Callback',{@LocalAddPZ Editor 'Lead' ''}, ...
        'Separator','on');
    uimenu(h,'Label',sprintf('Lag'),...
        'Callback',{@LocalAddPZ Editor 'Lag' ''});
    uimenu(h,'Label',sprintf('Notch'),...
        'Callback',{@LocalAddPZ Editor 'Notch' ''});
    
    % Add listeners to edit mode changes
    lsnr = handle.listener(Editor,findprop(Editor,'EditMode'),...
        'PropertyPostSet',{@LocalModeChanged 'add' h});
    set(h,'UserData',lsnr)  % Anchor listeners for persistency
    
case 'constraint'
    % Constraints menu
    if usejava('MWT'), 
        h = uimenu(Anchor, 'Label', sprintf('Design Constraints'));
        % Constraint submenus
        hs1 = uimenu(h, 'Label', sprintf('New...'), ...
            'Callback', {@LocalDesignConstr Editor 'new'});
        hs2 = uimenu(h, 'Label', sprintf('Edit...'), ...
            'Callback', {@LocalDesignConstr Editor 'edit'});
    else
        h = [];
    end
    
case 'delete'
    % Delete Pole/Zero menu
    h = uimenu(Anchor,'Label',sprintf('Delete Pole/Zero'), ...
        'Callback',{@LocalDeletePZ Editor});
    
    % Add listeners to edit mode changes
    lsnr = handle.listener(Editor,findprop(Editor,'EditMode'),...
        'PropertyPostSet',{@LocalModeChanged 'delete' h});
    set(h,'UserData',lsnr)  % Anchor listeners for persistency
    
case 'edit'
    % Edit Compensator
    h = uimenu(Anchor,'Label',...
        sprintf('Edit Compensator...'),'Callback',{@LocalShowEditor Editor});
    
case 'grid'
    % Grid
    h = uimenu(Anchor,'Label',sprintf('Grid'),'Callback',{@LocalSetGrid Editor});
    L = handle.listener(Editor.Axes,findprop(Editor.Axes,'Grid'),...
        'PropertyPostSet',{@GridMenuState h});
    % Anchor listeners for persistency
    set(h,'UserData',L)
    
case 'property'
    % Properties
    h = uimenu(Anchor,'Label',sprintf('Properties...'),...
        'Callback',{@LocalOpenEditor Editor});
    
case 'zoom'
    % Zoom
    h = uimenu(Anchor,'Label',sprintf('Zoom'));
    uimenu(h,'label',sprintf('X-Y'),'Callback',{@LocalZoomIn Editor});
    uimenu(h,'Label',sprintf('In-X'),'Callback',{@LocalZoomIn Editor});
    uimenu(h,'label',sprintf('In-Y'),'Callback',{@LocalZoomIn Editor});
    hout = uimenu(h,'label',sprintf('Out'),'Enable','off',...
        'Callback',{@LocalZoomOut Editor});
    
    % Add listeners to edit mode changes
    L1 = handle.listener(Editor,findprop(Editor,'EditMode'),...
        'PropertyPostSet',{@LocalModeChanged 'zoom' h});
    p = [Editor.Axes.findprop('XlimMode');Editor.Axes.findprop('YlimMode')];
    L2 = handle.listener(Editor.Axes,p,'PropertyPostSet',{@LocalZoomOutEnable Editor hout});
    set(h,'UserData',[L1;L2])  % Anchor listeners for persistency
    
end


%----------------------------- Listener callbacks ----------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalModeChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalModeChanged(hProp,event,MenuMode,hMenu)
% Update state of right-click menu (check mark)
event.AffectedObject.checkmenu(MenuMode,hMenu);


%%%%%%%%%%%%%%%%%%%%%
%%% GridMenuState %%%
%%%%%%%%%%%%%%%%%%%%%
function GridMenuState(hProp,event,hMenu)
% Updates grid menu state
set(hMenu,'Checked',event.NewValue)


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalZoomOutEnable %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalZoomOutEnable(hProp,event,Editor,hZoomOut)
% Disable Zoom:Out menu when XlimMode=YlimMode=auto
if strcmp(Editor.Axes.XlimMode,'auto') & all(strcmp(Editor.Axes.YlimMode,'auto'))
    set(hZoomOut,'Enable','off')
else
    set(hZoomOut,'Enable','on')
end


%----------------------------- Callback actions ----------------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalAddInt %%%
%%%%%%%%%%%%%%%%%%%
function LocalAddInt(hSrc,event,Editor)
% Add integrator
LoopData = Editor.LoopData;
EventMgr = Editor.EventManager;

% Return to idle (aborts global modes)
Editor.EditMode = 'idle';

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Add Integrator',...
    'OperationStore','on','InverseOperationStore','on');

% Add integrator
if LoopData.Ts ~= 0,
    intvalue = 1;
else
    intvalue = 0;
end

Editor.EditedObject.addpz('Real',zeros(0,1),(intvalue));

% Register transaction 
EventMgr.record(T);

% Notify of loop data change
LoopData.dataevent('all');

% Update status and history
Status = sprintf('Added an integrator to the %s.',Editor.describe('comp'));
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);


%%%%%%%%%%%%%%%%%%%%
%%% LocalAddDiff %%%
%%%%%%%%%%%%%%%%%%%%
function LocalAddDiff(hSrc,event,Editor)
% Add differentiator
LoopData = Editor.LoopData;
EventMgr = Editor.EventManager;

% Return to idle (aborts global modes)
Editor.EditMode = 'idle';

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Add Differentiator',...
    'OperationStore','on','InverseOperationStore','on');

% Add differentiator
if LoopData.Ts ~= 0,
    difvalue = 1;
else
    difvalue = 0;
end

Editor.EditedObject.addpz('Real',(difvalue),zeros(0,1));

% Register transaction 
EventMgr.record(T);

% Notify of loop data change
LoopData.dataevent('all');

% Update status and history
Status = sprintf('Added a differentiator to the %s.',Editor.describe('comp'));
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);


%%%%%%%%%%%%%%%%%%
%%% LocalAddPZ %%%
%%%%%%%%%%%%%%%%%%
function LocalAddPZ(hSrc,event,Editor,Type,ID)
% Starts Add Pole/Zero operation (hSrc = submenu handle)

AddInfo = struct('Root',ID,'Group',Type); 

% Exiting Add mode? (unchecking menu)
ExitingMode = strcmp(Editor.EditMode,'addpz') & ...
    isequal(Editor.EditModeData,AddInfo);

% Return to idle (properly resets menu and pointer when switching mode, aborts global modes)
Editor.EditMode = 'idle';  

% Enter 'addpz' mode
if ~ExitingMode
    % RE: Updating EditMode triggers menu update and resets pointer
    Editor.EditModeData = AddInfo;
    Editor.EditMode = 'addpz';    
    % Evaluate WBM function once to set correct pointer
    Editor.mouseevent('wbm');
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalDeletePZ %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalDeletePZ(hSrc,event,Editor)
% Starts Delete Pole/Zero operation

% Exiting Delete mode? (unchecking menu)
ExitingMode = strcmp(Editor.EditMode,'deletepz');

% Return to idle (properly resets menu and pointer when switching mode, aborts global modes)
Editor.EditMode = 'idle';  

% Enter 'deletepz' mode
if ~ExitingMode
    % Enter 'delete' mode (triggers menu update and resets pointer)
    Editor.EditMode = 'deletepz';  
    % Evaluate WBM function once to set correct pointer
    Editor.mouseevent('wbm');
end    


%%%%%%%%%%%%%%%%%%%
%%% LocalZoomIn %%%
%%%%%%%%%%%%%%%%%%%
function LocalZoomIn(hSrc,event,Editor)
% Zoom menu callback (hSrc = submenu handle)

ZoomInfo = struct('Type',lower(get(hSrc,'Label')));

% Exiting Zoom mode? (unchecking menu)
ExitingMode = strcmp(Editor.EditMode,'zoom') & ...
    isequal(Editor.EditModeData,ZoomInfo);

% Return to idle (properly resets menu and pointer when switching mode, aborts global modes)
Editor.EditMode = 'idle';  

% Enter zoom mode
if ~ExitingMode
    % RE: Updating EditMode triggers menu update and resets pointer
    Editor.EditModeData = ZoomInfo;  
    Editor.EditMode = 'zoom';  
    % Evaluate WBM function once to set correct pointer
    Editor.mouseevent('wbm');
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDesignConstr %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDesignConstr(hSrc, event, Editor, ActionType)
% Opens dialogs to add/edit design constraints
switch ActionType
case 'new'
    % Add new constraint
    plotconstr.newdlg(Editor, Editor.Axes.Parent);
case 'edit'
    % Edit constraints in editor if there are constraints to edit.
    if isempty(Editor.findconstr)
        % No constraints to show in this Editor
        warndlg('There are no constraints to edit.','Edit Warning');
    else
        % Point constraint editor to this Editor
        Editor.ConstraintEditor.show(Editor);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowEditor %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowEditor(hSrc,event,Editor)
% Bring up PZ editor
Editor.TextEditor.show(Editor.EditedObject);


%%%%%%%%%%%%%%%%%%%%
%%% LocalZoomOut %%%
%%%%%%%%%%%%%%%%%%%%
function LocalZoomOut(hSrc,event,Editor)
% Zoom out callback (hSrc = submenu handle)
Editor.zoomout;


%%%%%%%%%%%%%%%%%%%%
%%% LocalSetGrid %%%
%%%%%%%%%%%%%%%%%%%%
function LocalSetGrid(hSrc,event,Editor)
% Grid menu callback (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
    Editor.Axes.Grid = 'off';
else
    Editor.Axes.Grid = 'on';
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenEditor %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalOpenEditor(hSrc,event,Editor)
% Properties menu callback (hSrc = menu handle)
PropEdit = PropEditor(Editor);
PropEdit.setTarget(Editor)