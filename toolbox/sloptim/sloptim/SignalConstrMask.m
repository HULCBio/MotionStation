function SignalConstraintMask(action,blk)
% Manages Signal Constraint mask.

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:46:50 $
%   Copyright 1986-2004 The MathWorks, Inc.

% UDDREVISIT: make it a static method of @SignalConstraintDialog

% Bypass for library block
Model = bdroot(blk);
if strcmp(Model,'srolib')
   if strcmp(action,'open')
      errordlg('Cannot launch constraint editor off the library block',...
         'Open Constraint Editor','modal')
   end
   return
end

% Block data   
PMTool = srogui.ProjectManager;
BlockData = get_param(blk,'UserData');
if ~isfield(BlockData,'Dialog')
   BlockData = struct('Dialog',[],'Project',[]);
end
Dialog = BlockData.Dialog;
if isempty(Dialog) || ~ishandle(Dialog) || ~ishandle(Dialog.Figure)
   Dialog = [];
end


switch action
   case 'load'
      % Create project when opening model
      [Proj,msg] = utFindProject(Model,blk);
      
      % Update block data
      BlockData.Project = Proj;
      set_param(blk,'UserData',BlockData)
      
      % Issue warnings
      if ~isempty(msg)
         warning('Could not restore all Simulink Response Optimization settings.\n%s',msg)
      end
      
   case 'open'
      % Opening editor
      if isempty(Dialog)
         % Create dialog
         % Find constraint associated with Dialog's block
         Proj = BlockData.Project;
         LogID = get_param(blk,'LogID');
         C = findspec(Proj.Tests(1),LogID);
         
         % This should never happen
         if isempty(C)
            % Corrupted project: blast it and start afresh
            errordlg('Corrupted project. Close Simulink model and try again.',...
               'Signal Constraint Error')
            return
         end

         % Create dialog object if it does not exist
         Dialog = srogui.SignalConstraintDialog(blk,C,Proj);

         % Update block data
         BlockData.Dialog = Dialog;
         set_param(blk,'UserData',BlockData)
      end

      % Make dialog visible
      Dialog.Figure.Visible = 'on';

      % Update editor contents
      update(Dialog.Editor)

   case 'close'
      % Closing block
      if ~isempty(Dialog)
         % Hide dialog
         Dialog.Figure.Visible = 'off';
      end
      
   case 'delete'
      % Remove constraint from associated project
      Proj = BlockData.Project;
      if ishandle(Proj)
         for ct=1:length(Proj.Tests)
            Proj.Tests(ct).rmblock(blk);
         end
      end
      % Delete dialog
      if ~isempty(Dialog)
         % Remove constraint from project
         delete(Dialog)
      end

   case {'copy','undelete'}
      % Get project for targeted model
      Proj = localGetProject(PMTool,Model);
      % Enforce unique log ID, clear association with dialog, and 
      % update SaveAs/SaveIn settings. Returns spec object with
      % original block settings
      C = utSROCopyFcn(blk,action);
      % Add to project
      if isempty(C)
         % Use default settings for constraints
         XFocus = getSimInterval(Proj);
         for ct=1:length(Proj.Tests)
            Proj.Tests(ct).addblock(blk,XFocus);
         end
      else
         C = copy(C);
         for ct=1:length(Proj.Tests)
            Proj.Tests(ct).addblock(blk,C);
         end
      end
      % Update block data
      BlockData.Dialog = [];
      BlockData.Project = Proj;
      set_param(blk,'UserData',BlockData)

   case 'modelclose'
      % Delete associated project
      % RE: When using BDCLOSE ALL, dialog may be destroyed 
      %     before getting here
      Proj = BlockData.Project;
      if ishandle(Proj)
         PMTool.Projects(PMTool.Projects==Proj,:) = [];
         % Prompt user for saving
         if Proj.Dirty && ~isempty(Dialog)
            localSavePrompt(Dialog)
            % Execution resumes after save dialog is closed
            Proj.Dirty = false;
         end
         % Delete project
         delete(Proj)
      end
      % Clean up (after deleting project, otherwise localSavePrompt fails)
      if ~isempty(Dialog)
          % Delete dialog
         delete(Dialog)
      end
      
   case 'save'
      % Callback when saving model
      if ~isempty(Dialog)
         % Has the model name changed?
         if ~strcmp(Dialog.Project.Model,Model)
            Dialog.Block = blk;
            Dialog.Editor.Axes.Title = getSignalName(Dialog);
            Dialog.Project.renameModel(Model)
         end
         % Save dialog position
         set_param(Dialog.Block,'DialogPosition',mat2str(get(Dialog.Figure,'Position')))
         % Save manual Y limit settings
         if strcmp(Dialog.Editor.Axes.YlimMode,'manual')
            set_param(Dialog.Block,'Ylim',mat2str(get(getaxes(Dialog.Editor),'Ylim')))
         else
            set_param(Dialog.Block,'Ylim','')
         end
      end

   case 'namechange'
      % Renaming block: update internal name and resync project
      if ~isempty(Dialog)
         % Update dialog reference to block
         Dialog.Block = blk;
         Dialog.Editor.Axes.Title = getSignalName(Dialog);
      end

end


%--------------- Local Functions --------------

function Proj = localGetProject(PMTool,Model)
% Finds or creates project for targeted model in COPY operation
Proj = PMTool.Projects;
if ~isempty(Proj)
   Proj = find(Proj,'-isa','srogui.SimProjectForm','Model',Model);
end
if isempty(Proj)
   % Copying block into model w/o SRO blocks
   Proj = srogui.SimProjectForm;
   Proj.Name = Model;
   % Add to project list
   PMTool.Projects = [PMTool.Projects ; Proj];
   % Initialize project (skip spec initialization)
   Proj.init(Model,'skipspec')
end


function localSavePrompt(Dialog)
% Prompts user for saving project
blk = Dialog.Block;
if strcmp('Yes',questdlg('Do you want to save your optimization project before closing?',...
      'Save Optimization Project','Yes','No','Yes'))
   saveas(Dialog,'suspend')
end
