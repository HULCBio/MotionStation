function this = ParameterDialog(Project,CleanUpObj)
% Constructs parameter dialog for a given project.
%
%   The dialog is destroyed when CLEANUPOBJ is being destroyed.

%   Author(s): Pascal Gahinet
%   $Revision $ $Date: 2004/04/11 00:44:06 $
%   Copyright 1986-2004 The MathWorks, Inc.
this = srogui.ParameterDialog;
this.Project = Project;
this.Listeners = [...
   handle.listener(CleanUpObj,'ObjectBeingDestroyed',{@LocalDestroy this});...
   handle.listener(this,this.findprop('ParamSpecs'),...
   'PropertyPostSet',{@LocalRefreshList this})];

% Build dialog
build(this)

%----------- Local Functions -------------------------------

function LocalDestroy(hSrc, hData, this)
% Hide dialog
if ishandle(this.Figure)
   delete(this.Figure)
end
delete(this)


function LocalRefreshList(hSrc, hData, this)
% Update list contents
updateList(this)
