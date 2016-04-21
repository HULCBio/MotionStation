function this = SignalConstraintDialog(blk,Constr,Proj)
% Constructor for block dialog object.

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:44:19 $
%   Copyright 1986-2004 The MathWorks, Inc.
this = srogui.SignalConstraintDialog;
this.Block = getfullname(blk);
this.Constraint = Constr;
this.Project = Proj;

% Create dialog figure
f = handle(localCreateDialog(this,str2num(get_param(blk,'DialogPosition'))));
this.Figure = f;

% Build editor (required in FIGMENUS)
Editor = srogui.SignalConstraintEditor(Constr,f);
this.Editor = Editor;
Editor.Axes.Title = getSignalName(this);
Editor.XFocus = getSimInterval(Proj);

% Reapply manual Y limits saved with block
Ylim = get_param(blk,'Ylim');
if ~isempty(Ylim)
   Ylim = str2num(Ylim);
   set(getaxes(Editor),'Ylim',Ylim)
end

% Add menus and toolbars
hMenu = figmenus(this);
hTool = toolbar(this);

% Target editor and update contents
targetEditor(this)

% Add fixed listeners
this.Listeners.Fixed = [...
   handle.listener(this,'ObjectBeingDestroyed',{@localDelete this});...
   handle.listener(srogui.ProjectManager,'LoadProject',{@LocalRetarget this})];

% Configure for current project
% RE: Adds project-specific listeners
addProjectListeners(this,hMenu,hTool)

%--------------- Local Functions --------------
   
function hFig = localCreateDialog(this,Pos)
% Creates dialog figure
UIColor = get(0,'DefaultUIControlBackgroundColor');
hFig = figure(...
   'Name',sprintf('Block Parameters: %s',get_param(this.Block,'Name')),...
   'Visible','off',...
   'Menubar','none',...
   'Toolbar','none',...
   'Units','normalized', ...
   'IntegerHandle','off', ...
   'HandleVisibility','off',...
   'Position',Pos, ...
   'NumberTitle','off',...
   'Color', UIColor);
set(hFig,'CloseRequestFcn',{@localHide hFig})


function localHide(eventsrc,eventdata,hFig)
% Hides dialog when clicking on x
set(hFig,'Visible','off')


function localDelete(eventsrc,eventdata,this)
% Clean up when dialog goes away
if ishandle(this.Figure)
   delete(this.Figure)
end


function LocalRetarget(eventsrc,eventdata,this)
% Retargets editor to new Project
this.load(eventdata.Data)
