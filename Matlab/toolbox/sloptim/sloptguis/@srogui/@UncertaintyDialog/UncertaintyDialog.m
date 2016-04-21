function this = UncertaintyDialog(Project,Test,CleanUpObj)
% Constructs parameter dialog for a given project.
%
%   The dialog is destroyed when CLEANUPOBJ is being destroyed.

%   Author(s): Pascal Gahinet
%   $Revision $ $Date: 2004/04/11 00:45:17 $
%   Copyright 1986-2004 The MathWorks, Inc.
this = srogui.UncertaintyDialog;
this.Project = Project;
this.Test = Test;

% Initialize spec objects
this.Uncertainty = [...
   srogui.RandSetForm ; ...
   srogui.GridSetForm];
   
% Listeners
this.Listeners = handle.listener(CleanUpObj,...
   'ObjectBeingDestroyed',{@LocalDestroy this});

% Build dialog
build(this)

%----------- Local Functions -------------------------------

function LocalDestroy(hSrc, hData, this)
% Hide dialog
if ishandle(this.Figure)
   delete(this.Figure)
end
delete(this)
