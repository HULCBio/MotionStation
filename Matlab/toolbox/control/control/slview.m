function varargout = slview(varargin);
%SLVIEW  Initializes and manages the Simulink LTI Viewer
%
%   SLVIEW is the callback for the Linear Analysis menu located under a
%   Simulink diagram Tools menu. Selecting the Linear Analysis menu
%   opens an linearization tools connected to the Simulink diagram.
%

%   SLVIEW(ACTION,Model_Handle) can be used at the command line to open
%   a Simulink LTI Viewer or execute a callback for the Simulink LTI 
%   Viewer connected to the Simulinkdiagram with the handle Model_Handle. 
%   ACTION specifies what function is executed.
%
%   The following ACTIONS are supported.
%
%   1) Initialize:  Open a Simulink Control Design linearization tool
%   2) States:      Select the node for specifying the State/Input values
%                   to linearize the model about
%   3) ClearBlocks: Remove all Input/OutputPoint blocks or 
%                   input/outputs points in the diagram
%
%   The LTI Viewer callbacks that are modified to now call SLVIEW actually
%   pass the Model Name as the second input argument. This is also valid.

%   Authors: Karen Gondoly, 12-2-96
%   Revised: Adam DiVergilio
%            Kamesh Subbarao
%            John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.53.4.4 $  $Date: 2004/04/10 23:13:58 $

ni=nargin;

%---Must have at least one input argument indicating the action
error(nargchk(1,3,ni));

%-- Must own the Simulink Control Designer to launch the linearization tool
if ~license('test','Simulink_Control_Design')
    error('control:SLControlNeeded','The product Simulink Control Design is required to launch the linear analysis tool'); 
end

action = lower(varargin{1});
if nargin>1,
   try
      diagram_name=get_param(varargin{2},'Name');
   catch
      error('Invalid Simulink diagram handle.');
   end
   
   diagram_handle=get_param(diagram_name,'Handle');
   fignum=[];
end % if nargin>1

%---Perform action
switch action
case 'initialize',
   %---Open the Linearization Tool
   varargout{1} = simcontdesigner('initialize_linearize',diagram_name);
  
case 'clearblocks',
   %---Callback to clear the Input/OutputPoint blocks from the Simulink diagram
   AllInBlocks = find_system(diagram_name,'masktype','InputPoint');
   AllOutBlocks = find_system(diagram_name,'masktype','OutputPoint');
   
   for NumIn=1:length(AllInBlocks)
      delete_block(AllInBlocks{NumIn});
   end
   for NumOut=1:length(AllOutBlocks)
      delete_block(AllOutBlocks{NumOut});
   end
   
   %---Remove all the linearization points
   setlinio(diagram_name,[]);
   
case 'closediagram',
    explorer = slctrlexplorer;
    if isa(explorer,'com.mathworks.toolbox.control.explorer.Explorer')
        explorer.doClose;
    end
   
case 'states'
    %---Open the Operating Point window
    [PROJECT,FRAME] = getvalidproject(diagram_name);
    
    %% Get the operating conditions node
    OperCondNode = PROJECT.OperatingConditions;

    %% If the dialog panel has not been created then create it
    if isempty(OperCondNode.Dialog)
        [Frame,Worspace,Manager] = slctrlexplorer;
        OperCondNode.getDialogInterface(Manager);
    end

    %% Set the operating condition creation tab as selected
    OperCondNode.Dialog.getTabbedPane.setSelectedIndex(1);

    %% Select the operating condition node
    Frame = slctrlexplorer;
    Frame.setSelected(OperCondNode.getTreeNodeInterface);
      
otherwise
   error('Invalid ACTION specified')
end


