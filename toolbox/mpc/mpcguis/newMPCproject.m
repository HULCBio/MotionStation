function h = newMPCproject(ProjectName)

% h = newMPCproject(ProjectName)
%
% Utility function to create a new MPC project node, add it to
% the MPC gui workspace, and return the node's handle.
%
% ProjectName  is an optional project name (string).  If not assigned,
%              a default name is created.

%	Author:  Larry Ricker
%	Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.4 $  $Date: 2004/04/10 23:37:58 $

% Workspace and tree manager handles.  Should have been created previously.
%global MPC_WSh MPC_MANh
[hJava,MPC_WSh,MPC_MANh] = slctrlexplorer('initialize');

%% Get MPC projects
WorkspaceProjects = [];
SimulinkProjects = [];
Projects = MPC_WSh.find('-class','mpcnodes.MPCGUI');
for k=1:length(Projects)
    if ~isempty(Projects(k).up) && MPC_WSh==Projects(k).up
        WorkspaceProjects = [WorkspaceProjects; Projects(k)];
    elseif isa(Projects(k).up,'explorer.projectnode')
        SimulinkProjects = [SimulinkProjects; Projects(k)];
    end
end
        
if nargin < 1 || isempty(deblank(ProjectName))
    % Create a uniqe project name
    ProjectName = 'MPCdesign';
    % If project with default name exists and hasn't been used yet, return
    % its handle.
    if ~isempty(WorkspaceProjects)
        h = WorkspaceProjects.find('Label', ProjectName);
        if ~isempty(h) && ~h.ModelImported
            return
        end
    end
    if length(WorkspaceProjects) > 0
        i=0;
        while  ~isempty(WorkspaceProjects.find('Label', ProjectName))
            i = i + 1;
            ProjectName = sprintf('MPCdesign%i', i);
        end
    end
else
    % If specified project name is in use, ask if it should be replaced
    if ~isempty(WorkspaceProjects)
        h = WorkspaceProjects.find('Label', ProjectName);
        if ~isempty(h)
            if h.ModelImported
                Msg = sprintf(['Project "%s" exists.\n\n', ...
                    'Do you want to replace it?'], ...
                    ProjectName);
                Button = questdlg(Msg, 'Confirm Project Deletion', ...
                    'Yes', 'No', 'No');
                if strcmpi(Button, 'No')
                    h = [];
                    return
                else
                    MPC_WSh.removeNode(h);
                end
            else
                % Project name refers to an existing empty project.
                % Return this project's handle
                return
            end
        end
    end
end

% Create the GUI project node
h = mpcnodes.MPCGUI(ProjectName, {});
% Add this project to the workspace and select it
h.Frame = MPC_MANh.Explorer;
h.getDialogInterface(MPC_MANh);
MPC_WSh.addNode(h); 

% (jgo) The following line has been commented out becuase the combination
% of node selection and collapsing creates a race condition in the
% explorer. So far a solution to this has not been found.
%MPC_MANh.Explorer.setSelected(h.getTreeNodeInterface);
MPC_MANh.Explorer.collapseNode(h.TreeNode);
