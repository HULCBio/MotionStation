function [project,FRAME] = getvalidproject(diagram_name,addoptaskflag,varargin)
%  GETVALIDPROJECT Gets or creates a valid project for a new task to be added.

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:32:20 $

%% Check for valid platform for Java Swing
if (~usejava('Swing'))
    error('The Control and Estimation Tools Manager is not supported in the current platform.');
end

%% Get the frame and workspace handles
[FRAME,WSHANDLE] = slctrlexplorer;

if ~isa(FRAME,'com.mathworks.toolbox.control.explorer.Explorer')
    %% Get the frame and workspace handles
    wb = waitbar(0,'Creating Tools Manager','Name','Control and Estimation Tools Manager');
    [FRAME,WSHANDLE] = slctrlexplorer('initialize');
    waitbar(1,wb)
    close(wb)
end

%% Get the after a draw now has occured since there may be a node selection 
%% still in the event queue
drawnow
selected = FRAME.getSelected;
if isempty(selected)
    %% Make the workspace to be the selected node.
    selected = WSHANDLE;
else
    selected = handle(getObject(selected));
end

if (nargin == 3)
    %% Create a new project if there are two input arguements
    project = explorer.Project(WSHANDLE, diagram_name);
    project.Label = project.createDefaultName(varargin{1}, WSHANDLE);
    
    %% Add it to the workspace
    WSHANDLE.addNode(project);
    %% Create the operating conditions if Simulink Control Designer if needed;
    LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)
elseif isa(selected,'explorer.Workspace')
    %% This is the case where the workspace node is selected
    project = LocalCreateProjectfromWorkspace(diagram_name,selected,addoptaskflag);
else
    %% This is the case where any other node is selected
    SelectedRoot = selected.getRoot;
    %% Loop up until we reach the top of a project
    while ~isempty(SelectedRoot)
        if (isa(SelectedRoot,'explorer.Project'))
            project = SelectedRoot;
            break
        end
        SelectedRoot = SelectedRoot.up;
    end

    if ~strcmp(project.Model,diagram_name)
        %% Create a new project if the diagram name does not match
        project = LocalCreateProjectfromWorkspace(diagram_name,project.up,addoptaskflag);
    else
        %% Create the operating conditions if Simulink Control Designer if needed;
        LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function LocalCreateProjectfromWorkspace create a project given a
%% workspace handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function project = LocalCreateProjectfromWorkspace(diagram_name,workspace,addoptaskflag)

projects = workspace.getChildren;
validind = find(strcmp(get(projects,'Model'),diagram_name));
if isempty(validind);
    %% Create a new project
    project = explorer.Project(workspace, diagram_name);
    project.Label = project.createDefaultName(sprintf('Project - %s', diagram_name), workspace);
    %% Add it to the workspace
    workspace.addNode(project);
    %% Create the operating conditions if Simulink Control Designer if needed;
    LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)
elseif (length(validind) == 1)
    project = projects(validind);
    %% Create the operating conditions if Simulink Control Designer if needed;
    LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)
else
    errordlg('Select a unique project to add the task.',...
        'Control and Estimation Tools Manager','modal');
    project = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function LocalCreateOpSpec create the operating condition task node
%% object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)

if addoptaskflag && license('test','Simulink_Control_Design')
    addoptask(diagram_name,project);
end