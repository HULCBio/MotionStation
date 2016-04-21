function [Proj,errmsg] = utFindProject(Model,Block)
% Finds or creates SRO project for Simulink model.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.3 $ $Date: 2004/03/10 21:56:13 $
%   Copyright 1990-2004 The MathWorks, Inc. 
errmsg = '';

% Project manager clean up (in case some project have been deleted)
PMTool = srogui.ProjectManager;
PMTool.Projects = PMTool.Projects(ishandle(PMTool.Projects));

% Find Simulink projects associated with model. Create default one if none
% R14 assumption: at most one project/spec per model
Proj = PMTool.Projects;
if ~isempty(Proj)
   Proj = find(Proj,'-isa','srogui.SimProjectForm','Model',Model);
end

% Create project if none found
if isempty(Proj)
   Proj = srogui.SimProjectForm;
   Proj.Name = Model;
   % Add to project list
   % RE: Before INIT as FIND_SYSTEM triggers loading of remaining blocks
   PMTool.Projects = [PMTool.Projects ; Proj];
   
   % Initialize project with one constraint per block in MODEL
   Proj.init(Model)

   % Try reloading project data
   SaveAs = get_param(Block,'SaveAs');
   if ~isempty(SaveAs)
      [LoadProj,errmsg] = utLoadProject(get_param(Block,'SaveIn'),SaveAs);
      if isempty(errmsg)
         % RE: Do not pop up any dialog (used while loading Simulink model)
         Dirty = Proj.Dirty;
         errmsg = Proj.load(LoadProj,'silent');
         Proj.Dirty = Dirty;
      end
   end
end
