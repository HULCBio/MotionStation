function addProjectListeners(this,hMenu,hTool)
% Adds project-specific listeners

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.1 $ $Date: 2004/01/03 12:27:23 $
%   Copyright 1990-2003 The MathWorks, Inc. 
Proj = this.Project;

this.Listeners.Project = [...
   handle.listener(Proj,Proj.findprop('Tests'),...
   'PropertyPostSet',{@localUpdateTarget this});...
   handle.listener(Proj,'SourceCreated',...
   {@localAddSourceListener this hMenu hTool})];


%--------------- Local Functions --------------

function localUpdateTarget(eventsrc,eventdata,this)
% Retarget
targetEditor(this)


function localAddSourceListener(eventsrc,eventdata,this,hMenu,hTool)
% Add listeners to runtime project (OptimStatus)
RTProj = eventdata.Data;
this.RunTimeProject = RTProj;
hStop = [hMenu.Stop ; hTool.Stop];
hOther = [hMenu.Other ; hTool.Other];
this.Listeners.Source = ...
   handle.listener(RTProj,RTProj.findprop('OptimStatus'),...
   'PropertyPostSet',{@localEnable hStop hOther});


function localEnable(eventsrc,eventdata,hStop,hOther)
% Enables/disables menus/tools based on optimization status
switch eventdata.NewValue
   case 'run'
      set(hStop,'Enable','on'), set(hOther,'Enable','off')
   case 'idle'
      set(hStop,'Enable','off'), set(hOther,'Enable','on')
end
