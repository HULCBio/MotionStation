function varargout = slmodelpropj(varargin)
%SLMODELPROPJ  Open the Java GUI for editing Simulink Model Properties
%   SLMODELPROPJ manages the user interface for the Java Simulink  
%   Model Properties Dialog box.


%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/15 00:49:33 $

%---We only want one instance of the editor per model
% Find all the open SL_ModelPropertiesEditor
currentRoot = bdroot(gcs);
s.currentRoot = currentRoot;
Frame = LocalFindDialog(currentRoot);

%---Create a new editor if one is not found
if isempty(Frame)
	OldFig = varargin{1};
	
	% if the current system root is a locked library,
	% disable all fields except 'CANCEL' and 'HELP' buttons
	%
	enable = strcmp('off',get_param(currentRoot, 'Lock'));
	
	%---Frame
	Frame = com.mathworks.mwt.MWFrame(sprintf('Model Properties: %s',currentRoot));
	Frame.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
	set(Frame,'Parent',0,'HandleVisibility','callback',...
		'Name','SL_ModelPropertiesEditor',...
		'Resizable', 'off',...
		'WindowClosingCallback',{@localCancel,Frame});
	%---Open an empty Frame with some status text
	ss = get(0,'ScreenSize');
	Frame.setLocation(max(ss(3)/2-180, 0),max(ss(4)/2-140, 0));
	Frame.setSize(java.awt.Dimension(360,280));
	s.Status = com.mathworks.mwt.MWLabel(sprintf('Loading Model Properties...'),com.mathworks.mwt.MWLabel.CENTER);
	Frame.add(s.Status,com.mathworks.mwt.MWBorderLayout.CENTER);
	Frame.setVisible(1);
	Frame.toFront;
	
	%---ButtonPanel
	s.ButtonPanel = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,7,0));
	s.ButtonPanel.setInsets(java.awt.Insets(2,5,5,-2));
	%---OK
	s.OK = com.mathworks.mwt.MWButton(sprintf('OK')); s.ButtonPanel.add(s.OK);
	s.OK.setEnabled(enable);
	set(s.OK,'ActionPerformedCallback',{@localOK,Frame});
	%---Cancel
	s.Cancel = com.mathworks.mwt.MWButton(sprintf('Cancel')); s.ButtonPanel.add(s.Cancel);
	set(s.Cancel,'ActionPerformedCallback',{@localCancel,Frame});
	%---Help
	s.Help = com.mathworks.mwt.MWButton(sprintf('Help')); s.ButtonPanel.add(s.Help);
	set(s.Help,'ActionPerformedCallback',{@localHelp,Frame});
	%---Apply
	s.Apply = com.mathworks.mwt.MWButton(sprintf('Apply')); s.ButtonPanel.add(s.Apply);
	s.Apply.setEnabled(enable);
	set(s.Apply,'ActionPerformedCallback',{@localApply,Frame});
	
	%---TabPanel
	s.TabPanel = com.mathworks.mwt.MWTabPanel;
	s.TabPanel.setInsets(java.awt.Insets(5,5,5,5));
	s.TabPanel.setMargins(java.awt.Insets(12,8,8,8));

	%---Summary Tab
	s.Summary = localSummaryTab(Frame,enable);
	s.SummaryTab = localMakeTab(s.Summary);
	s.TabPanel.addPanel(sprintf('Summary'),s.SummaryTab);
	%---Callback Tab
	s.Callback = localCallbackTab(Frame,enable);
	s.CallbackTab = localMakeTab(s.Callback);
	s.TabPanel.addPanel(sprintf('Callbacks'),s.CallbackTab);
	%---History Tab
	s.History = localHistoryTab(Frame,enable);
	s.HistoryTab = localMakeTab(s.History);
	s.TabPanel.addPanel(sprintf('History'),s.HistoryTab);
	
	%---Start on the first tab panel
	s.TabPanel.selectPanel(0);

	%---Get the current property values from the model
	s.Properties = localInitProps(currentRoot);
	%---Set all the current widget values to the current Model Property Values
	Props = localSetPropertyValues(s,currentRoot); 

	%---Store structure of handles in Frame UserData
	s.Frame = Frame;
	set(Frame,'UserData',s);
	
	%---Remove the status text, add the real components, and pack
	Frame.remove(s.Status);
	Frame.add(s.TabPanel,com.mathworks.mwt.MWBorderLayout.CENTER);
	Frame.add(s.ButtonPanel,com.mathworks.mwt.MWBorderLayout.SOUTH);
	Frame.pack;
	Frame.setLocation(max(ss(3)/2-Frame.getSize.width/2, 0), ...
                          max(ss(4)/2-Frame.getSize.height/2, 0));

	% Get the frame as a Handle so DELETE can be used to destroy it.
	FrameHandle = LocalFindDialog(currentRoot);	 
	set(OldFig,'UserData',FrameHandle,'DeleteFcn','slmodelprop(''DeleteJavaFig'',gcbf)')

	varargout{1} = Frame;
	
else
	%---Update Model Properties window with correct property values
	s = get(Frame,'UserData');
	
	%---Set all the current values to the Model Property Values
	s.Properties = localInitProps(currentRoot);
	Props = localSetPropertyValues(s,currentRoot);
	set(Frame,'UserData',s)
	
	%---Raise Frame (no java methods here... findobj returns hg handles!)
	set(Frame,'Minimized','off','Visible','off','Visible','on');
	varargout{1} = Frame;
	
end

%------------------------------- Internal functions ---------------------------------

%%%%%%%%%%%%%%%%%%
% localInitProps %   % Get the property values from the Model
%%%%%%%%%%%%%%%%%%
function Props = localInitProps(H);

  Props = struct(...
      'PreLoadFcn', get_param(H,'PreLoadFcn'), ...
      'InitFcn', get_param(H,'InitFcn'), ...
      'StartFcn', get_param(H,'StartFcn'), ...
      'StopFcn', get_param(H,'StopFcn'), ...
      'PreSaveFcn', get_param(H,'PreSaveFcn'), ...
      'CloseFcn', get_param(H, 'CloseFcn'), ...
      'Creator', get_param(H,'Creator'), ...
      'Created', get_param(H,'Created'), ...
      'Description', get_param(H,'Description'), ...
      'ModelVersion', get_param(H,'ModelVersion'), ...
      'ModelVersionFormat', get_param(H,'ModelVersionFormat'), ...
      'LastModifiedBy', get_param(H,'LastModifiedBy'), ...
      'ModifiedByFormat', get_param(H,'ModifiedByFormat'), ...
      'LastModifiedDate', get_param(H,'LastModifiedDate'), ...
      'ModifiedDateFormat', get_param(H,'ModifiedDateFormat'), ...
      'ModifiedHistory', get_param(H,'ModifiedHistory'), ...
      'UpdateHistory', get_param(H,'UpdateHistory'));

%%%%%%%%%%%%%%%%%%%%%%%%%%
% localSetPropertyValues %      % Set the widgets' values
%%%%%%%%%%%%%%%%%%%%%%%%%%
function Props = localSetPropertyValues(s,H);

summaryControls = get(s.Summary,'UserData');
historyControls = get(s.History,'UserData');
callbackControls = get(s.Callback,'UserData');

Props = s.Properties;
summaryControls.CreatorName.setText(Props.Creator);
summaryControls.CreatedData.setText(Props.Created);
summaryControls.Description.setText(Props.Description);
summaryControls.Description.setSel(0, 0);

% Set the Callback controls
callbackControls.PreLoadFcnText.setText(Props.PreLoadFcn);
callbackControls.InitFcnText.setText(Props.InitFcn);
callbackControls.StartFcnText.setText(Props.StartFcn);
callbackControls.StopFcnText.setText(Props.StopFcn);
callbackControls.PreSaveFcnText.setText(Props.PreSaveFcn);
callbackControls.CloseFcnText.setText(Props.CloseFcn);

% Show values or Edit formats based on the value of the ViewMenu
ViewVal = historyControls.ViewMenu.getSelectedIndex;
if ~ViewVal, % Showing the current property values, get formats from UserData
	Version = Props.ModelVersion;
	ModifiedBy = Props.LastModifiedBy;
	ModifiedDate = Props.LastModifiedDate;
else
	Version = Props.ModelVersionFormat;
	ModifiedBy = Props.ModifiedByFormat;
	ModifiedDate = Props.ModifiedDateFormat;
end 

historyControls = get(s.History,'UserData');
historyControls.VersionNumber.setText(Version);
historyControls.LastModifiedBy.setText(ModifiedBy);
historyControls.LastModifiedDate.setText(ModifiedDate);

% Set the remaining History controls
historyControls.ModifiedHistory.setText(Props.ModifiedHistory);
historyControls.ModifiedHistory.setSel(0, 0);
value = UpdateHistoryOption(Props.UpdateHistory);
historyControls.PromptMenu.select(value-1);


%%%%%%%%%%%%%%%%
% localMakeTab %
%%%%%%%%%%%%%%%%
function Tab = localMakeTab(varargin)
% Combine panels into a single panel for use in a tab dialog
Tab = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0));
for n=1:nargin
	if n<nargin
		%---Not last element, leave 5-pixel spacing
		tmp = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,5));
	else
		%---Last element, leave 0-pixel spacing
		tmp = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0));
	end
	%---Pack towards top
	tmp.add(varargin{n},com.mathworks.mwt.MWBorderLayout.NORTH);
	%---Add java handle to structure
	s(n,1) = tmp;
	%---Add first panel to Tab
	if n==1
		Tab.add(tmp,com.mathworks.mwt.MWBorderLayout.CENTER);
		%---Nest other panels
	else
		tmp2 = s(n-1,1);
		tmp2.add(tmp,com.mathworks.mwt.MWBorderLayout.CENTER);
	end
end
%---Store java handles
set(Tab,'UserData',s);

%%%%%%%%%%%
% localOK %             % OK button callback
%%%%%%%%%%%
function localOK(eventSrc,eventData,Frame)

% Reset the diagram Property values
localSetParam(eventSrc,eventData,Frame)
% Close the Model Properties window
localCancel(eventSrc,eventData,Frame)


%%%%%%%%%%%%%%%
% localCancel %         % Cancel button callback
%%%%%%%%%%%%%%%
function localCancel(eventSrc,eventData,Frame)
set(Frame,'Visible','off');


%%%%%%%%%%%%%
% localHelp %         % Help button callback
%%%%%%%%%%%%%
function localHelp(eventSrc,eventData,Frame)
slprophelp('model');

%%%%%%%%%%%%%%
% localApply %           % Apply button callback
%%%%%%%%%%%%%%
function localApply(eventSrc,eventData,Frame)

% Reset the diagram Property values
localSetParam(eventSrc,eventData,Frame) 

%%%%%%%%%%%%%%%%%
% localSetParam %       % Reset the Simulink diagram Properties
%%%%%%%%%%%%%%%%%
function localSetParam(eventSrc,eventData,Frame)
s = get(Frame,'UserData');
historyControls = get(s.History,'Userdata');
summaryControls = get(s.Summary,'UserData');
callbackControls = get(s.Callback,'UserData');

% Read new values from the controls or userdata based on value of the View/Edit menu
ViewVal = historyControls.ViewMenu.getSelectedIndex;
if ~ViewVal, % Showing the current property values, get formats from UserData
	ModelVersionFormat = s.Properties.ModelVersionFormat;
	ModifiedByFormat = s.Properties.ModifiedByFormat;
	ModifiedDateFormat = s.Properties.ModifiedDateFormat;
else, % Editing the format strings, get Formats from the current text
	ModelVersionFormat = char(historyControls.VersionNumber.getText);
	ModifiedByFormat = char(historyControls.LastModifiedBy.getText);
	ModifiedDateFormat = char(historyControls.LastModifiedDate.getText);
end
	
% Set callbacks
set_param(s.currentRoot,'PreLoadFcn',char(callbackControls.PreLoadFcnText.getText));
set_param(s.currentRoot,'InitFcn',char(callbackControls.InitFcnText.getText));
set_param(s.currentRoot,'StartFcn',char(callbackControls.StartFcnText.getText));
set_param(s.currentRoot,'StopFcn',char(callbackControls.StopFcnText.getText));
set_param(s.currentRoot,'PreSaveFcn',char(callbackControls.PreSaveFcnText.getText));
set_param(s.currentRoot,'CloseFcn',char(callbackControls.CloseFcnText.getText));

% Set summary data
set_param(s.currentRoot,'Creator',char(summaryControls.CreatorName.getText));
set_param(s.currentRoot, 'Description',char(summaryControls.Description.getText));
set_param(s.currentRoot, 'ModifiedHistory',char(historyControls.ModifiedHistory.getText));

% Set History data
set_param(s.currentRoot, 'ModelVersionFormat',ModelVersionFormat);
set_param(s.currentRoot, 'ModifiedByFormat',ModifiedByFormat);
set_param(s.currentRoot, 'ModifiedDateFormat',ModifiedDateFormat);

% Setting the Model Version Format actually resets the ModelVersion Property.
% Store the new version number in the Model Properties dialog's Userdata and,
% if the current property values are being shown, update the string.
s.Properties.ModelVersion = get_param(s.currentRoot,'ModelVersion');
set(Frame,'UserData',s);
if ~ViewVal, 
	historyControls.VersionNumber.setText(s.Properties.ModelVersion);	
end

PromptVal = historyControls.PromptMenu.getSelectedIndex;
value = UpdateHistoryOption(PromptVal+1);
set_param(s.currentRoot, 'UpdateHistory',value);


%%%%%%%%%%%%%%%%%%%
% localChangeView %     % Callback to toggle between values and format
%%%%%%%%%%%%%%%%%%%
function localChangeView(eventSrc,eventData,Frame);

s = get(Frame,'UserData');
historyControls = get(s.History,'UserData');
ViewVal = historyControls.ViewMenu.getSelectedIndex;

if ~ViewVal, % Switch to current Values	
	% Store new format strings before removing the controls.
	s.Properties.ModelVersionFormat = char(historyControls.VersionNumber.getText);
	s.Properties.ModifiedByFormat = char(historyControls.LastModifiedBy.getText);
	s.Properties.ModifiedDateFormat = char(historyControls.LastModifiedDate.getText);
	
	historyControls.VersionPropertyPanel.remove(3);
	historyControls.VersionPropertyPanel.remove(2);
	historyControls.VersionPropertyPanel.remove(1);

	historyControls.VersionNumber = com.mathworks.mwt.MWLabel(sprintf(s.Properties.ModelVersion)); 
	historyControls.VersionPropertyPanel.add(historyControls.VersionNumber,1);
	historyControls.LastModifiedBy = com.mathworks.mwt.MWLabel(sprintf(s.Properties.LastModifiedBy)); 
	historyControls.VersionPropertyPanel.add(historyControls.LastModifiedBy,2);
	historyControls.LastModifiedDate = com.mathworks.mwt.MWLabel(sprintf(s.Properties.LastModifiedDate)); 
	historyControls.VersionPropertyPanel.add(historyControls.LastModifiedDate,3);
	
else, % Switch to save format
	historyControls.VersionPropertyPanel.remove(3);
	historyControls.VersionPropertyPanel.remove(2);
	historyControls.VersionPropertyPanel.remove(1);

	historyControls.VersionNumber = com.mathworks.mwt.MWTextField(s.Properties.ModelVersionFormat); 
	historyControls.VersionPropertyPanel.add(historyControls.VersionNumber,1);
	historyControls.LastModifiedBy = com.mathworks.mwt.MWTextField(s.Properties.ModifiedByFormat); 
	historyControls.VersionPropertyPanel.add(historyControls.LastModifiedBy,2);
	historyControls.LastModifiedDate = com.mathworks.mwt.MWTextField(s.Properties.ModifiedDateFormat); 
	historyControls.VersionPropertyPanel.add(historyControls.LastModifiedDate,3);
end

%---Update the graphic
Frame.validate
Frame.update(Frame.getGraphics)

set(s.History,'UserData',historyControls)
set(Frame,'Userdata',s)


%%%%%%%%%%%%%%%%%%%
% LocalFindDialog %
%%%%%%%%%%%%%%%%%%%
function Frame = LocalFindDialog(currentRoot);
% Find all the open SL_ModelPropertiesEditor
Frame = findobj(allchild(0),'flat','Type','com.mathworks.mwt.MWFrame',...
	'Name','SL_ModelPropertiesEditor');

% Find any associated with this model
if ~isempty(Frame),
	FrameTitle = get(Frame,{'Title'});
	FrameTitle = char(FrameTitle);
	FrameTitle = FrameTitle(:,19:end);
	isFrameOpen = strmatch(currentRoot,FrameTitle,'exact');
	Frame = Frame(isFrameOpen);
end


%%%%%%%%%%%%%%%%%%%
% localSummaryTab %         % Create the Summary Tab
%%%%%%%%%%%%%%%%%%%
function Main = localSummaryTab(Frame,enable)

%---Definitions
GL_31 = java.awt.GridLayout(3,1,0,10);

%---Top-level panel
Main = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));

%---Created/creator text panel
s.CreatedTextPanel = com.mathworks.mwt.MWPanel(GL_31);
Main.add(s.CreatedTextPanel,com.mathworks.mwt.MWBorderLayout.WEST);

s.CreatorLabel = com.mathworks.mwt.MWLabel(sprintf('Creator: ')); 
s.CreatorLabel.setEnabled(enable);
s.CreatedTextPanel.add(s.CreatorLabel);
s.CreatedLabel = com.mathworks.mwt.MWLabel(sprintf('Created: ')); 
s.CreatedLabel.setEnabled(enable);
s.CreatedTextPanel.add(s.CreatedLabel);
s.DescriptionLabel = com.mathworks.mwt.MWLabel(sprintf('Model description: ')); 
s.DescriptionLabel.setEnabled(enable);
s.CreatedTextPanel.add(s.DescriptionLabel);

%---Created/creator edit panel
s.CreatedEditPanel = com.mathworks.mwt.MWPanel(GL_31);
Main.add(s.CreatedEditPanel,com.mathworks.mwt.MWBorderLayout.CENTER);

s.CreatorName = com.mathworks.mwt.MWTextField; 
s.CreatorName.setEnabled(enable);
s.CreatedEditPanel.add(s.CreatorName);
s.CreatedData = com.mathworks.mwt.MWTextField; 
s.CreatedData.setEnabled(enable);
s.CreatedEditPanel.add(s.CreatedData);

%---Description text
s.Description = com.mathworks.mwt.MWTextArea;
s.Description.setRows(17)
s.Description.setVScrollStyle(2)
s.Description.setHScrollStyle(1)
s.Description.setEnabled(enable);
Main.add(s.Description,com.mathworks.mwt.MWBorderLayout.SOUTH);

set(Main,'UserData',s)


%%%%%%%%%%%%%%%%%%%
% localCallbackTab %            % Create the Callback Tab
%%%%%%%%%%%%%%%%%%%
function Main = localCallbackTab(Frame,enable)

%---Top-level panel
Main = com.mathworks.mwt.MWPanel(java.awt.GridLayout(6,1,0,10));

%---Add PreLoadFcn strings and edit fields.
s.PreLoadFcnPanel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));
s.PreLoadFcnLabel = ...
	com.mathworks.mwt.MWLabel(sprintf('Model pre-load function: ')); 
s.PreLoadFcnLabel.setEnabled(enable);
s.PreLoadFcnPanel.add(s.PreLoadFcnLabel,com.mathworks.mwt.MWBorderLayout.NORTH);

s.PreLoadFcnText = com.mathworks.ide.widgets.SyntaxTextArea;
s.PreLoadFcnText.setFileType(s.PreLoadFcnText.M_FILE_TYPE);
s.PreLoadFcnText.setAutoIndentEnabled(1);
s.PreLoadFcnText.setSmartIndentEnabled(1); 
s.PreLoadFcnText.set('SpacesPerIndent', 2);
s.PreLoadFcnText.set('SpacesPerTab', 8);
s.PreLoadFcnText.setRows(2);
s.PreLoadFcnText.setVScrollStyle(1);
s.PreLoadFcnText.setHScrollStyle(1);
s.PreLoadFcnText.setEnabled(enable);
s.PreLoadFcnPanel.add(s.PreLoadFcnText,com.mathworks.mwt.MWBorderLayout.CENTER);
Main.add(s.PreLoadFcnPanel);

%---Add InitFcn strings and edit fields.
s.InitFcnPanel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));
s.InitFcnLabel = ...
	com.mathworks.mwt.MWLabel(sprintf('Model initialization function: ')); 
s.InitFcnLabel.setEnabled(enable);
s.InitFcnPanel.add(s.InitFcnLabel,com.mathworks.mwt.MWBorderLayout.NORTH);
s.InitFcnText = com.mathworks.ide.widgets.SyntaxTextArea;
s.InitFcnText.setFileType(s.InitFcnText.M_FILE_TYPE);
s.InitFcnText.setAutoIndentEnabled(1);
s.InitFcnText.setSmartIndentEnabled(1); 
s.InitFcnText.set('SpacesPerIndent', 2);
s.InitFcnText.set('SpacesPerTab', 8);
s.InitFcnText.setRows(2);
s.InitFcnText.setVScrollStyle(1);
s.InitFcnText.setHScrollStyle(1);
s.InitFcnText.setEnabled(enable);
s.InitFcnPanel.add(s.InitFcnText,com.mathworks.mwt.MWBorderLayout.CENTER);
Main.add(s.InitFcnPanel);

%---Add StartFcn strings and edit fields.
%---StartFcn panel
s.StartFcnPanel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));
s.StartFcnLabel = ...
	com.mathworks.mwt.MWLabel(sprintf('Simulation start function: ')); 
s.StartFcnLabel.setEnabled(enable);
s.StartFcnPanel.add(s.StartFcnLabel,com.mathworks.mwt.MWBorderLayout.NORTH);
s.StartFcnText = com.mathworks.ide.widgets.SyntaxTextArea;
s.StartFcnText.setFileType(s.StartFcnText.M_FILE_TYPE);
s.StartFcnText.setAutoIndentEnabled(1);
s.StartFcnText.setSmartIndentEnabled(1); 
s.StartFcnText.set('SpacesPerIndent', 2);
s.StartFcnText.set('SpacesPerTab', 8);
s.StartFcnText.setRows(2);
s.StartFcnText.setVScrollStyle(1);
s.StartFcnText.setHScrollStyle(1);
s.StartFcnText.setEnabled(enable);
s.StartFcnPanel.add(s.StartFcnText,com.mathworks.mwt.MWBorderLayout.CENTER);
Main.add(s.StartFcnPanel);

%---Add StopFcn strings and edit fields.
s.StopFcnPanel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));
s.StopFcnLabel = ...
	com.mathworks.mwt.MWLabel(sprintf('Simulation stop function: ')); 
s.StopFcnLabel.setEnabled(enable);
s.StopFcnPanel.add(s.StopFcnLabel,com.mathworks.mwt.MWBorderLayout.NORTH);
s.StopFcnText = com.mathworks.ide.widgets.SyntaxTextArea;
s.StopFcnText.setFileType(s.StopFcnText.M_FILE_TYPE);
s.StopFcnText.setAutoIndentEnabled(1);
s.StopFcnText.setSmartIndentEnabled(1); 
s.StopFcnText.set('SpacesPerIndent', 2);
s.StopFcnText.set('SpacesPerTab', 8);
s.StopFcnText.setRows(2);
s.StopFcnText.setVScrollStyle(1);
s.StopFcnText.setHScrollStyle(1);
s.StopFcnText.setEnabled(enable);
s.StopFcnPanel.add(s.StopFcnText,com.mathworks.mwt.MWBorderLayout.CENTER);
Main.add(s.StopFcnPanel);

%---Add PreSaveFcn strings and edit fields.
s.PreSaveFcnPanel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));
s.PreSaveFcnLabel = ...
	com.mathworks.mwt.MWLabel(sprintf('Model pre-save function: ')); 
s.PreSaveFcnLabel.setEnabled(enable);
s.PreSaveFcnPanel.add(s.PreSaveFcnLabel,com.mathworks.mwt.MWBorderLayout.NORTH);
s.PreSaveFcnText = com.mathworks.ide.widgets.SyntaxTextArea;
s.PreSaveFcnText.setFileType(s.PreSaveFcnText.M_FILE_TYPE);
s.PreSaveFcnText.setAutoIndentEnabled(1);
s.PreSaveFcnText.setSmartIndentEnabled(1); 
s.PreSaveFcnText.set('SpacesPerIndent', 2);
s.PreSaveFcnText.set('SpacesPerTab', 8);
s.PreSaveFcnText.setRows(2);
s.PreSaveFcnText.setVScrollStyle(1);
s.PreSaveFcnText.setHScrollStyle(1);
s.PreSaveFcnText.setEnabled(enable);
s.PreSaveFcnPanel.add(s.PreSaveFcnText,com.mathworks.mwt.MWBorderLayout.CENTER);
Main.add(s.PreSaveFcnPanel);

%---Add CloseFcn strings and edit fields.
s.CloseFcnPanel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));
s.CloseFcnLabel = ...
	com.mathworks.mwt.MWLabel(sprintf('Model close function: ')); 
s.CloseFcnLabel.setEnabled(enable);
s.CloseFcnPanel.add(s.CloseFcnLabel,com.mathworks.mwt.MWBorderLayout.NORTH);
s.CloseFcnText = com.mathworks.ide.widgets.SyntaxTextArea;
s.CloseFcnText.setFileType(s.CloseFcnText.M_FILE_TYPE);
s.CloseFcnText.setAutoIndentEnabled(1);
s.CloseFcnText.setSmartIndentEnabled(1); 
s.CloseFcnText.set('SpacesPerIndent', 2);
s.CloseFcnText.set('SpacesPerTab', 8);
s.CloseFcnText.setRows(2);
s.CloseFcnText.setVScrollStyle(1);
s.CloseFcnText.setHScrollStyle(1);
s.CloseFcnText.setEnabled(enable);
s.CloseFcnPanel.add(s.CloseFcnText,com.mathworks.mwt.MWBorderLayout.CENTER);
Main.add(s.CloseFcnPanel);

set(Main,'UserData',s)


%%%%%%%%%%%%%%%%%%%
% localHistoryTab %            % Create the History Tab
%%%%%%%%%%%%%%%%%%%
function Main = localHistoryTab(Frame,enable)

%---Definitions
GL_41 = java.awt.GridLayout(4,1,0,5);

%---Top-level panel
Main = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));

%---Version information panel
s.VersionBox = com.mathworks.mwt.MWGroupbox(sprintf('Version information'));
s.VersionBox.setEnabled(enable)
s.VersionBox.setLayout(com.mathworks.mwt.MWBorderLayout(5,5));
Main.add(s.VersionBox,com.mathworks.mwt.MWBorderLayout.NORTH);

%---Version text labels
s.VersionTextPanel = com.mathworks.mwt.MWPanel(GL_41);
s.VersionBox.add(s.VersionTextPanel,com.mathworks.mwt.MWBorderLayout.WEST);
s.EmptyLabel = com.mathworks.mwt.MWLabel(sprintf(' ')); 
s.VersionTextPanel.add(s.EmptyLabel);
s.VersionLabel = com.mathworks.mwt.MWLabel(sprintf('Model version: ')); 
s.VersionLabel.setEnabled(enable);
s.VersionTextPanel.add(s.VersionLabel);
s.ModifiedbyLabel = com.mathworks.mwt.MWLabel(sprintf('Last saved by: ')); 
s.ModifiedbyLabel.setEnabled(enable);
s.VersionTextPanel.add(s.ModifiedbyLabel);
s.ModifiedonLabel = com.mathworks.mwt.MWLabel(sprintf('Last saved on: ')); 
s.ModifiedonLabel.setEnabled(enable);
s.VersionTextPanel.add(s.ModifiedonLabel);

%---Version property values
s.VersionPropertyPanel = com.mathworks.mwt.MWPanel(GL_41);
s.VersionBox.add(s.VersionPropertyPanel,com.mathworks.mwt.MWBorderLayout.CENTER);
% Add controls to change the view
s.ViewMenu = com.mathworks.mwt.MWChoice; 
s.ViewMenu.add(sprintf('View current values')); 
s.ViewMenu.add(sprintf('Edit format strings'));
s.ViewMenu.setEnabled(enable);
s.VersionPropertyPanel.add(s.ViewMenu);
set(s.ViewMenu,'ItemStateChangedCallback',{@localChangeView,Frame});

s.VersionNumber = com.mathworks.mwt.MWLabel; 
s.VersionNumber.setEnabled(enable);
s.VersionPropertyPanel.add(s.VersionNumber,1);
s.LastModifiedBy = com.mathworks.mwt.MWLabel; 
s.LastModifiedBy.setEnabled(enable);
s.VersionPropertyPanel.add(s.LastModifiedBy,2);
s.LastModifiedDate = com.mathworks.mwt.MWLabel; 
s.LastModifiedDate.setEnabled(enable);
s.VersionPropertyPanel.add(s.LastModifiedDate,3);

%---History panel
Historyflag=0; % Toggles between the two formats for the History controls.
if Historyflag
	% Original version without a frame around the Model History edit field
	s.HistoryPanel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));
	Main.add(s.HistoryPanel,com.mathworks.mwt.MWBorderLayout.SOUTH);
	
	s.HistoryLabel = com.mathworks.mwt.MWLabel(sprintf('Model history: ')); 
	s.HistoryLabel.setEnabled(enable);
	s.HistoryPanel.add(s.HistoryLabel,com.mathworks.mwt.MWBorderLayout.NORTH);
else
	% New version with the frame.
	s.HistoryPanel = com.mathworks.mwt.MWGroupbox(sprintf('Model history'));
	s.HistoryPanel.setEnabled(enable)
	s.HistoryPanel.setLayout(com.mathworks.mwt.MWBorderLayout(5,5));
	Main.add(s.HistoryPanel,com.mathworks.mwt.MWBorderLayout.SOUTH);
	
end

%---Model History text
s.ModifiedHistory = com.mathworks.mwt.MWTextArea; 
s.ModifiedHistory.setRows(10)
s.ModifiedHistory.setVScrollStyle(2)
s.ModifiedHistory.setHScrollStyle(1)
s.ModifiedHistory.setEnabled(enable);
s.HistoryPanel.add(s.ModifiedHistory,com.mathworks.mwt.MWBorderLayout.CENTER);

% Add controls to change the History prompt
s.PromptPanel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(5,5));
s.HistoryPanel.add(s.PromptPanel,com.mathworks.mwt.MWBorderLayout.SOUTH);
s.PromptLabel = com.mathworks.mwt.MWLabel(sprintf('Prompt to update model history:')); 
s.PromptLabel.setEnabled(enable);
s.PromptPanel.add(s.PromptLabel,com.mathworks.mwt.MWBorderLayout.WEST);
s.PromptMenu = com.mathworks.mwt.MWChoice; 
s.PromptMenu.setEnabled(enable);
s.PromptPanel.add(s.PromptMenu,com.mathworks.mwt.MWBorderLayout.CENTER);
s.PromptMenu.add(sprintf('Never')); 
s.PromptMenu.add(sprintf('When saving model'));

set(Main,'UserData',s)


% ===================== from slmodelprop.m ===============================
function y = UpdateHistoryOption(x)
% If x is a number, it returns the associated string 
%      in availableOptions list
% If x is a string, it returns its position in the 
%      availableOptions list

  availableOptions = {'UpdateHistoryNever', 'UpdateHistoryWhenSave'};
                  
  if isnumeric(x)
    y = availableOptions{x};
  else
    y = find(strcmp(availableOptions, x));
  end
