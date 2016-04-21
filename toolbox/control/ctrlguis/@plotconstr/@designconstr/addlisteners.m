function addlisteners(Constr,Listeners)
%ADDLISTENERS  Installs listeners for gain constraints.

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $ $Date: 2002/04/10 05:12:25 $

if nargin == 1
   % Clear existing listeners (e.g., after clone operation)
   delete(Constr.Listeners);
   % Listeners to HG axes events and properties
   PlotAxes = Constr.Parent;
   L1 = [handle.listener(PlotAxes, 'ObjectBeingDestroyed', @LocalCleanUp) ; ...
         handle.listener(PlotAxes,PlotAxes.findprop('Visible'),...
         'PropertyPostSet',@LocalToggleVisible)];
   % Listeners to constraint properties
   L2 = [handle.listener(Constr, Constr.findprop('Selected'), ...
         'PropertyPostSet', @LocalSelect) ; ...
         handle.listener(Constr, Constr.findprop('Zlevel'), ...
         'PropertyPostSet', @LocalSetZlevel) ; ...
         handle.listener(Constr, Constr.findprop('TextEditor'), ...
         'PropertyPreGet', @LocalDefaultEditor) ; ...
         handle.listener(Constr, Constr.findprop('Activated'),...
         'PropertyPreSet', @LocalOnOff)  ;...
         handle.listener(Constr, Constr.findprop('Activated'),...
         'PropertyPostSet', @LocalTargetEditor)  ;...
         handle.listener(Constr, 'ObjectBeingDestroyed',@LocalPreDelete)];
   Constr.Listeners = [L1;L2];
   set(Constr.Listeners,'CallbackTarget',Constr)
else
   % Add to list of listeners
   Constr.Listeners = [Constr.Listeners; Listeners];    
end


%-------------------------Property listeners-------------------------


%%%%%%%%%%%%%%%%%%%%
%% LocalPreDelete %%
%%%%%%%%%%%%%%%%%%%%
function LocalPreDelete(Constr,eventSrc,eventData)
% Pre-delete actions
% Always deselect before deleting (ensures undo will add it back to list of selected objects)
Constr.Selected = 'off';
% Desactivate (to facilitate undo delete)
Constr.Activated = 0;


%%%%%%%%%%%%%%%%%
%% LocalOnOff %%%
%%%%%%%%%%%%%%%%%
function LocalOnOff(Constr,eventData)
% Toggles Activated state (preset callback)
%disp(sprintf('preset for Activated = %d',eventData.NewValue))
if eventData.NewValue,  
   % Going to active mode: render constraint and notify observers (needed for redo)
   render(Constr);
else
   % Desactivating: delete HG handles
   h = ghandles(Constr);
   delete(h(ishandle(h)))    
end


%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalTargetEditor %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalTargetEditor(Constr,eventData)
% PostSet for Activated=0/1
if Constr.TextEditor.isVisible
   if eventData.NewValue
      % If constraint editor is up, retarget it to activated constraint
      Constr.TextEditor.target(Constr);
   else
      % Detarget constraint editor
      Constr.TextEditor.detarget(Constr);
   end
end


%%%%%%%%%%%%%%%%%%
%% LocalSelect %%%
%%%%%%%%%%%%%%%%%%
function LocalSelect(Constr,eventData)
% Sets Selected property of line objects and plots end markers
EventMgr = Constr.EventManager;
HostFig = Constr.Parent.Parent;

if strcmp(Constr.Selected, 'on')
   % Object becomes selected
   % Add to axes list of selected objects
   if strcmp(get(HostFig,'SelectionType'), 'extend')
      % Multi-select
      EventMgr.addselect(Constr,Constr.Parent);
   else
      % Single-select
      EventMgr.newselect(Constr,Constr.Parent);
   end
   % Turn markers on
   set(Constr.HG.Markers,'Visible','on');
   % Raise constraint
   Constr.Zlevel = Constr.Zlevel+0.001;
else
   EventMgr.rmselect(Constr);
   set(Constr.HG.Markers,'Visible','off'); 
   % Lower constraint back to initial level
   Constr.Zlevel = Constr.Zlevel-0.001;
end    


%%%%%%%%%%%%%%%%%%
%% LocalCleanUp %%
%%%%%%%%%%%%%%%%%%
function LocalCleanUp(Constr,eventData)
% Clean up when @axes deleted (needed because persistent editor may contain reference
% that will prevent deletion)
delete(Constr(ishandle(Constr)));


%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalToggleVisible %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleVisible(Constr,eventData)
% Toggle visibility
set(ghandles(Constr),'Visible',eventData.NewValue)


%%%%%%%%%%%%%%%%%%%%%
%% LocalSetZlevel %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetZlevel(Constr,eventData)
% Sets Selected property of line objects and plots end markers
hgobj = ghandles(Constr);
for h=hgobj(:)'
   if strcmp(get(h,'Type'),'patch')
      % Do not use Zdata when patch specified in terms of Vertices
      vdata  = get(h,'Vertices');
      vdata(:,3) = eventData.NewValue;
      set(h,'Vertices',vdata)
   else
      zdata = get(h,'Zdata');
      zdata(:) = eventData.NewValue;
      set(h,'Zdata',zdata);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDefaultEditor %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDefaultEditor(Constr,eventData)
% PreGet listener on TextEditor property
if ~isa(Constr.TextEditor,'plotconstr.constreditor') 
   % Set to default editor
   Constr.TextEditor = plotconstr.editdlg;
end
