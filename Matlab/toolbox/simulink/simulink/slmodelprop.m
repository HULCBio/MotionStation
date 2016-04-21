function varargout = slmodelprop(varargin)
%SLMODELPROP Simulink Model Properties Dialog box.
%   SLMODELPROP manages the user interface for the Simulink Model 
%   Properties Dialog box.

% SLMODLEPROP(action) executes the subfunction in the code associated 
% with the string flag action. Additional input arguments are used 
% based on the action specified.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.16 $

if nargin == 0
   action = 'Create';
else
   action = varargin{1};
end

switch action
case 'Create'
  % 
  % Create the gui
  %
  
  % If Java is supported, open the Java Model Properties window
  % Otherwise, open the old window
  if usejava('MWT') 
	  % For now, use the current Model Properties window as a trigger for
	  % closing the new Java window.
	  % The input argument to LocalCreate sets the visibility of the old GUI
	  OldFig = LocalCreate('off');
	  Frame = slmodelpropj(OldFig);
  else
	  LocalCreate('on');
  end
case 'Ok'
  % 
  % Callback for OK button 
  %
  LocalOk
  
case 'CloseBD'
  %
  % Called when the model is closed
  %
  LocalCancel(varargin{2});
  
case 'Cancel'
  % 
  % Callback for Cancel button 
  %
  LocalCancel
   
case 'DeleteJavaFig'
	%
	% DeleteFcn for the HG Model Properties window if a Java dialog was used.
	%
	LocalDeleteJavaFig(varargin{2})
	% varargin{2} is the handle of the HG Model Properties window.
	
case 'Help'
  % 
  % Callback for Help button 
  %
  LocalHelp
   
case 'Apply'
  % 
  % Callback for Apply button 
  %
  LocalApply
  
case 'Rename'
  % 
  % Called when the model is renamed
  %
  LocalRename(varargin{2:3})
  
case 'EditHistory'
  % 
  % Callback for edit history button (from History tab)
  %
  LocalEditHistory;
  
case 'EditHistoryCallback'
  %
  % Callback for OK and Apply buttons of the window that allows changes 
  % in the history
  %
  LocalEditHistoryCallback(varargin{2});

case 'EditHistoryResize'  
  %
  % Resize GUI
  %
  LocalEditHistoryResize; 

case 'tabcallbk'  
  %
  % Tab dialog callback
  %
  LocalTabCallBk(varargin); 
  
otherwise
  %
  % action represents an invalid option. Error this out
  %
  error([action ' unknown option ']);
  
end

% ====================================================
function toplevel = LocalCreate(visibility)
% Create the GUI 

  %
  % If handle is valid, it means that the model properties
  % GUI is already open
  %
  handle = findall(0, 'Tag', ['Model Properties: ' bdroot(gcs)]);
  if ishandle(handle)
	set(handle,'Visible',visibility)
    %figure(handle);
	toplevel = handle;
    return
  end
  
  % 
  % handle to the current block
  %
  currentRoot         = get_param(bdroot(gcs), 'Handle');
  allData.currentRoot = currentRoot;
  
  % 
  % if the current system root is a locked library,
  % disable all fields except 'CANCEL' and 'HELP' buttons
  %
  enable = notbool(get_param(currentRoot, 'Lock'));
  
  %
  % Define the toplevel dimensions
  %
  screenSize = get(0, 'ScreenSize');
  
  toplevelWidth  = 580;
  toplevelHeight = 350;
  
  toplevelLeft   = (screenSize(3) - toplevelWidth) / 2 ;
  toplevelBottom = (screenSize(4) - toplevelHeight) / 2 ;
  
  toplevelPosition = [max(toplevelLeft, 0), ...
                      max(toplevelBottom, toplevelHeight), ...
                      toplevelWidth, toplevelHeight ];
                                          
  % 
  % Construct the toplevel. Note that because of the tab dialog,
  % I have to work in pixels. After the tab dialog is created,
  % character units are used.
  %
  windowName = ['Model Properties: ', get_param(currentRoot, 'Name')];
  
  toplevel = figure('Numbertitle',      'off',...
                    'Name',             windowName,...
                    'Tag',              windowName,...
                    'menubar',          'none',...
                    'IntegerHandle',    'off', ...
                    'Visible',          'off', ...
                    'HandleVisibility', 'on', ...
                    'Units',            'Pixels', ...
                    'Resize',           'off', ...
                    'DeleteFcn',        'slmodelprop Cancel;', ...
                    'Color',            [0.7529    0.7529    0.7529], ...
                    'Position',         toplevelPosition);

  %                 Add Resize functionality at later time              
  %                'ResizeFcn',        'slmodelprop Resize;', ...
                
  % 
  % Construct the tab dialog
  %
  
  % Return early, if using the Java figure
  if strcmp(visibility,'off')
	  set(toplevel,'HandleVisibility','callback');
	  return
  end
  
  tabString = {'Model Properties', 'Options', 'History'};
  tabStringDimensions = tabdlg('tabdims', tabString);
  
  tabWidth  = toplevelWidth  - 20;
  tabHeight = toplevelHeight - 20;
  
  tabOffsets = [10, 10, 10, 50];
  
  [tabHandle, tabSheetPos] = tabdlg('create', ...
                                    tabString, tabStringDimensions, ...
                                    'slmodelprop', ...
                                    [tabWidth, tabHeight], ...
                                    tabOffsets, 1, {}, ...
                                    toplevel);
                                  
  %
  % get general dimensions
  %
  z = sluiutil('dimension');
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  vertSpacer    = z.vertSpacer;
  hScale        = z.hScale;
  vScale        = z.vScale;
  
  %                                  
  % convert all dimensions in characters
  %
  set(toplevel, 'Units', 'Characters');
  toplevelWidth  = toplevelWidth  * hScale;
  toplevelHeight = toplevelHeight * vScale;
  
  activWindow = [20 * hScale, 60 * vScale, ...
                 toplevelWidth - 40 * hScale, toplevelHeight - 40 * vScale];                                  
  allData.tabdlg.activWindow = activWindow;
  allData.tabdlg.tabHandle   = tabHandle;

  % 
  % create Model Properties tab
  %
  allData.tabdlg.modelPage = createModelPropertiesPage(currentRoot, ...
    toplevel, enable, 'off', activWindow, activWindow(1), activWindow(2));
  allData.tabdlg.modelPage.title = tabString{1};
  allData.pressedTab = tabString{1};  % for help
                    
  % 
  % create Options tab
  %
  allData.tabdlg.optionsPage = createModelOptionsPage(currentRoot, ...
    toplevel, enable, 'off', activWindow, activWindow(1), activWindow(2));
  allData.tabdlg.optionsPage.title = tabString{2};
                    
  % 
  % create History tab
  %
  allData.tabdlg.historyPage = createModelHistoryPage(currentRoot, ...
    toplevel, enable, 'off', activWindow, activWindow(1), activWindow(2));
  allData.tabdlg.historyPage.title = tabString{3};
                    
  % 
  % Create bottom buttons
  %
  buttons       = {'Apply', 'Help', 'Cancel', 'OK'};
  enableButtons = {enable,  'on',   'on',     enable};
  
  buttonsCB = {'slmodelprop Apply;', ...
              'slmodelprop Help;', ...
              'slmodelprop Cancel;', ...
              'slmodelprop Ok;'};
  
  left = toplevelWidth;
  
  for i = 1 : length(buttons)
     left     = left - leftAlignment - buttonWidth;
     position = [ left, vertSpacer, buttonWidth, buttonHeight ];
     
     properties = {'String', buttons{i}, 'Callback', buttonsCB{i}};                  
     
     bottomButtons(i) = sluiutil('CreatePushbutton', toplevel, ...
                                 'on', enableButtons{i}, position, properties);
  end
                            
  % 
  % save everything in UserData
  %
  allData.toplevel = toplevel;
  allData.editHistoryWindow = [];
  
  set(toplevel, 'UserData', allData);
  
  % 
  % make Model Properties Page (tab) visible
  %
  setModelPageProperties(toplevel, 'Visible', 'on');
  
  % 
  % set the visibility of the toplevelhandle
  %
  set(toplevel, 'HandleVisibility', 'Callback', 'Visible', visibility) ;
  
return  % LocalCreate 

% ====================================================
function LocalCancel(BDName)
% Callback for the Cancel button

  if nargin == 0
    % 
    % LocalCancel was called as a result of Cancel or OK button press
    %
    allData = get(gcbf, 'UserData');
    modelName = get_param(allData.currentRoot, 'Name');
  else 
    %
    % LocalCancel was called from C code, because the model
    % is being closed
    %
    modelName = BDName;
  end
  
  %
  % Is the edit history open? if yes, we need to close it
  %
  handle = findall(0, 'Tag', ['Modification History: ', modelName]);
  if ~isempty(handle)
    delete(handle);
  end

  %
  % Is the edit history open? if yes, we need to close it
  %
  handle = findall(0, 'Tag', ['Model Properties: ', modelName]);
  if ~isempty(handle)
    delete(handle);
  end
  
return  % LocalCancel

% ====================================================
function LocalOk
% Callback for the OK button

  LocalApply
  LocalCancel

return  % LocalOk

% ====================================================
function LocalRename(oldBDName, newBDName)
% Called when the model is renamed

  % common part of the window name
  commonName = 'Model Properties: ';

  oldWindowName = [commonName, oldBDName];
  newWindowName = [commonName, newBDName];
  
  % 
  % check to see if the window is open
  %
  windowHandle = findall(0, 'Tag', oldWindowName);
  
  if ~isempty(windowHandle)
    set(windowHandle, 'Name', newWindowName, 'Tag', newWindowName);
	
	% Check if a Java window is also open
	JavaFig = get(windowHandle,'UserData');
	if ishandle(JavaFig),
		set(JavaFig,'Title',newWindowName);
	end
	
  else
    %
    % The model properties window was not open, so there is no need 
    % to check if Modification History window is open.
    % That is why we exit
    %
    return
  end
  
  %
  % make the same analysis for Modification History window
  %
  commonName = 'Modification History: ';
  oldWindowName = [commonName, oldBDName];
  newWindowName = [commonName, newBDName];
  
  windowHandle = findall(0, 'Tag', oldWindowName);
  
  if ~isempty(windowHandle)
    set(windowHandle, 'Name', newWindowName, 'Tag', newWindowName);
  end
  
return  % LocalRename

% ====================================================
function LocalTabCallBk(varargin)
% Callback for the Tab Dialog

  pressedTab  = varargin{1}{2};
  previousTab = varargin{1}{4};
  toplevel    = varargin{1}{6};
  
  % 
  % return if there is no tab change
  %
  if strcmp(pressedTab, previousTab)
     return
  end 
  
  allData = get(toplevel, 'UserData');
  
  % 
  % hide previous tab
  %
  switch previousTab
  case {allData.tabdlg.modelPage.title}
    setModelPageProperties(toplevel, 'Visible', 'off');
     
  case {allData.tabdlg.optionsPage.title}
    setOptionsPageProperties(toplevel, 'Visible', 'off');
     
  case {allData.tabdlg.historyPage.title}
    setHistoryPageProperties(toplevel, 'Visible', 'off');
     
  end
  
  % 
  % show new tab
  %
  switch pressedTab
  case {allData.tabdlg.modelPage.title}
    setModelPageProperties(toplevel, 'Visible', 'on');
     
  case {allData.tabdlg.optionsPage.title}
    setOptionsPageProperties(toplevel, 'Visible', 'on');
     
  case {allData.tabdlg.historyPage.title}
    setHistoryPageProperties(toplevel, 'Visible', 'on');
     
  end
  
  allData.pressedTab = pressedTab;
  set(toplevel, 'UserData', allData);
  
  refresh
  
return  % LocalTabCallBk

% ====================================================
function LocalHelp
% Callback for the Help button
  slprophelp('model');
  return
  
% ====================================================
function y = createModelPropertiesPage(varargin)
% Creates the Model Properties page

  currentRoot  = varargin{1};
  toplevel     = varargin{2};
  
  enable       = varargin{3};
  visibility   = varargin{4};
  
  position     = varargin{5};
  
  leftOffset   = varargin{6};
  bottomOffset = varargin{7};
  
  % 
  % get general dimensions
  %
  z = sluiutil('dimension');
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  vertSpacer    = z.vertSpacer;
  hScale        = z.hScale;
  vScale        = z.vScale;
  
  % 
  % get activ window dimensions (tab dimensions)
  %
  toplevelWidth    = position(3);
  toplevelHeight   = position(4);
  
  %
  % get the minimum extent of the text that are displayed
  % to the keft side of each editable/popup.
  %
  allTextStrings = {'Model version:'; ...
                    'Creator:'; ...
                    'Created:'};
  
  tempText = uicontrol('Parent', toplevel, ...
                       'Style',  'Text', ...
                       'String', allTextStrings, ...
                       'Visible', 'off', ...
                       'Position', [0, 0, toplevelWidth, toplevelHeight]);
                     
  textExtent = get(tempText, 'Extent');
  delete(tempText);
  textWidth  = textExtent(3) * hScale;
                     
  fieldLeft  = textWidth + 2 * leftAlignment;
  fieldWidth = toplevelWidth - fieldLeft - leftAlignment;
  
  backgroundcolor = get(toplevel, 'Color');
  
  top = bottomOffset + toplevelHeight - vertSpacer;
  sameTop = 1;
  
  % 
  % Model Version 
  %
  text1.left       = leftOffset + leftAlignment;
  text1.width      = textWidth;
  text1.properties = {'String', allTextStrings{1}};
  
  text2.left       = leftOffset + fieldLeft;
  text2.width      = fieldWidth;
  text2.properties = {'String', get_param(currentRoot, 'ModelVersion')};
 
  y.modelVersion = sluiutil('TextWidget', toplevel, top, ...
                          text1, text2, visibility, enable);
  
  % 
  % CREATOR field
  %
  top = top - vertSpacer - textHeight;
  
  text.left       = leftOffset + leftAlignment;
  text.width      = textWidth;
  text.properties = {'String', allTextStrings{2}};
  
  edit.left       = leftOffset + fieldLeft;
  edit.width      = fieldWidth;
  edit.properties = {'String', get_param(currentRoot, 'Creator')};
 
  y.creator = sluiutil('SingleLineEditWidget', toplevel, top, sameTop, ...
                     text, edit, visibility, enable);
  
  % 
  % CREATED field
  %
  top = top - vertSpacer - textHeight;
  
  text.properties = {'String', allTextStrings{3}};
  edit.properties = {'String', get_param(currentRoot, 'Created')};
  
  y.created = sluiutil('SingleLineEditWidget', toplevel, top, sameTop, ...
                     text, edit, visibility, enable);
  
  % 
  % MODEL DESCRIPTION field
  %
  top = top - vertSpacer - textHeight;
  
  text.left       = leftOffset + leftAlignment;
  text.width      = fieldLeft + 50 * hScale;
  text.properties = {'String', 'Model description:'};
  
  edit.left       = leftOffset + leftAlignment;
  edit.width      = toplevelWidth - 2 * leftAlignment;
  edit.height     = top - bottomOffset + 1.5 * vertSpacer - 2 * textHeight;
  edit.properties = {'String', get_param(currentRoot, 'Description')};
  
  y.description = sluiutil('MultipleLineEditWidget', toplevel, top, 0, ...
                         text, edit, visibility, enable);
                                          
return  % createModelPropertiesPage

% ====================================================
function y = createModelOptionsPage(varargin)
% Creates the Options page

  currentRoot  = varargin{1};
  toplevel     = varargin{2};
  
  enable       = varargin{3};
  visibility   = varargin{4};
  
  position     = varargin{5};
  
  leftOffset   = varargin{6};
  bottomOffset = varargin{7};
  
  % 
  % get general dimensions
  %
  z = sluiutil('dimension');
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  vertSpacer    = z.vertSpacer;
  hScale        = z.hScale;
  vScale        = z.vScale;
  
  % 
  % get activ window dimensions (tab dimensions)
  %
  toplevelWidth    = position(3);
  toplevelHeight   = position(4);
  
  %
  % get the minimum extent of the text that are displayed
  % to the keft side of each editable/popup.
  %
  allTextStrings = {'Configuration manager:'; ...
                    '(For Model Info block)'; ...
                    'Model version format:'; ...
                    '"Modified by" format:'; ...
                    '"Modified date" format:'};
  
  tempText = uicontrol('Parent', toplevel, ...
                       'Style',  'Text', ...
                       'String', allTextStrings, ...
                       'Visible', 'off', ...
                       'Position', [0, 0, toplevelWidth, toplevelHeight]);
                     
  textExtent = get(tempText, 'Extent');
  delete(tempText);
  textWidth  = textExtent(3) * hScale;
                     
  fieldLeft  = textWidth + 2 * leftAlignment;
  fieldWidth = toplevelWidth - fieldLeft - leftAlignment;
  
  topFrame = bottomOffset + toplevelHeight;
  top      = topFrame;
  sameTop  = 1;
  
  % 
  % Create configuration manager selection popup + help + frame
  %
  
  % 
  % frame
  %
  frameHeight = 1.1 * vertSpacer + 2.2 * textHeight;
  framePos    = [leftOffset, top - frameHeight, toplevelWidth, frameHeight]; 
  y.CMFrame   = sluiutil('CreateFrame', toplevel, visibility, framePos);
  
  %
  % popup
  %
  text.left       = leftOffset + leftAlignment;
  text.width      = textWidth;
  text.properties = {'String', allTextStrings{1}};
  
  popup.left       = leftOffset + fieldLeft;
  popup.width      = fieldWidth;
  
  allCM     = cminfo('All');
  currentCM = get_param(currentRoot, 'ConfigurationManager');
  
  if exist('cmopts') == 2  % check to see if cmopts exists as an m file
    defaultCM = cmopts;
  else
    defaultCM = 'none';
  end
  
  if isempty(currentCM)
    currentCM = 'none';
  end
  
  %
  % get the configuration manager position in list of all CM's
  %
  value = find(strcmpi(allCM, currentCM));
  if isempty(value)
    %
    % the currentCM is not in the list. 
    % Show a warning and default to none
    %
    string = {['''' currentCM '''' ' is an undefined configuration manager.']; ...
        ['Edit ''cminfo'' to provide information about ''' currentCM '''.']; ...
        'Default to ''none''.'};
    warndlg(string, 'Warning', 'Modal');
    value = 1;
  end
  
  %
  % mark the default configuration manager
  %
  pos = find(strcmpi(allCM, defaultCM));
  if ~isempty(pos)
    for i = 1 : length(pos)
      allCM{pos(i)} = ['Default (' allCM{pos(i)} ')'];
    end
  end
  
  tooltipString = 'Default configuration manager can be set in cmopts.m';
  popup.properties = {'String', allCM; ...
                      'Value', value; ...
                      'HorizontalAlignment', 'Left'; ...
                      'TooltipString', tooltipString};
  
  top = top - vertSpacer;
  y.CM = sluiutil('PopupWidget', toplevel, top, ...
                  text, popup, visibility, enable);
              
  % 
  % display '(For Model Info block)' below 'Configuration Manager' 
  %
  top = top - 1.1 * textHeight - textHeight;
  textPos = [text.left, top, textWidth, textHeight];
  
  y.HelpBelowCMText = sluiutil('CreateText', toplevel, visibility, enable, ...
                               textPos, {'String', allTextStrings{2}});
  
  % 
  % Frame for FORMAT fiedls
  %
  topFrame = topFrame - frameHeight - vertSpacer;
  top      = topFrame;
  
  % 
  % frame
  %
  frameHeight   = 3 * textHeight + 4 * vertSpacer;
  framePos      = [leftOffset, top - frameHeight, toplevelWidth, frameHeight];
  y.FormatFrame = sluiutil('CreateFrame', toplevel, visibility, framePos);
  
  % 
  % MODEL VERSION FORMAT field
  %
  top = top - vertSpacer;
  
  text.left   = leftOffset + leftAlignment;
  text.width  = textWidth;
  text.properties = {'String', allTextStrings{3}};
  
  edit.left       = leftOffset + fieldLeft;
  edit.width      = fieldWidth;
  
  tooltipString   = 'Use %<AutoIncrement: # > tag to increment # when save.';
  edit.properties = {'String', get_param(currentRoot, 'ModelVersionFormat'); ...
                     'TooltipString', tooltipString};
  
  y.modelVersionFormat = sluiutil('SingleLineEditWidget', toplevel, top, 1, ...
                                  text, edit, visibility, enable);

  % 
  % MODIFIED BY FORMAT field
  %
  top = top - textHeight - vertSpacer;
  
  text.left       = leftOffset + leftAlignment;
  text.width      = textWidth;
  text.properties = {'String', allTextStrings{4}};
  
  edit.left       = leftOffset + fieldLeft;
  edit.width      = fieldWidth;
  
  tooltipString   = 'Use %<Auto> tag to display current login name.';
  edit.properties = {'String', get_param(currentRoot, 'ModifiedByFormat'); ...
                     'TooltipString', tooltipString};
  
  y.modifiedByFormat = sluiutil('SingleLineEditWidget', toplevel, top, ...
                              sameTop, text, edit, visibility, enable);

  % 
  % MODIFIED DATE FORMAT field
  %
  top = top - textHeight - vertSpacer;
  
  text.left       = leftOffset + leftAlignment;
  text.width      = textWidth;
  text.properties = {'String', allTextStrings{5}};
  
  edit.left       = leftOffset + fieldLeft;
  edit.width      = fieldWidth;
  
  tooltipString   = 'Use %<Auto> tag to display current date and time.';
  edit.properties = {'String', get_param(currentRoot, 'ModifiedDateFormat'); ...
                     'TooltipString', tooltipString};
  
  y.modifiedDateFormat = sluiutil('SingleLineEditWidget', ....
                                toplevel, top, sameTop, ...
                                text, edit, visibility, enable);
  
return  % createModelOptionsPage

% ====================================================
function y = createModelHistoryPage(varargin)
% Creates the History page

  currentRoot  = varargin{1};
  toplevel     = varargin{2};
  
  enable       = varargin{3};
  visibility   = varargin{4};
  
  position     = varargin{5};
  
  leftOffset   = varargin{6};
  bottomOffset = varargin{7};
  
  % 
  % get general dimensions
  %
  z = sluiutil('dimension');
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  vertSpacer    = z.vertSpacer;
  hScale        = z.hScale;
  vScale        = z.vScale;
  
  % 
  % get activ window dimensions (tab dimensions)
  %
  toplevelWidth    = position(3);
  toplevelHeight   = position(4);
  
  %
  % get the minimum extent of the text that are displayed
  % to the keft side of each editable/popup.
  %
  allTextStrings = {'Last modified by:'; ...
                    'Last modified date:'; ...
                    'Modified history update:'; ...
                    'Modified history:'};
  
  tempText = uicontrol('Parent', toplevel, ...
                       'Style',  'Text', ...
                       'String', allTextStrings, ...
                       'Visible', 'off', ...
                       'Position', [0, 0, toplevelWidth, toplevelHeight]);
                     
  textExtent = get(tempText, 'Extent');
  delete(tempText);
  
  textWidth  = max(textExtent(3) * hScale, buttonWidth);
  fieldLeft  = textWidth + 2 * leftAlignment;
  fieldWidth = toplevelWidth - fieldLeft - leftAlignment;
  
  top = bottomOffset + toplevelHeight - vertSpacer;
               
  % 
  % Last Modified By
  %  
  text1.left       = leftOffset + leftAlignment;
  text1.width      = textWidth;
  text1.properties = {'String', allTextStrings{1}};
  
  text2.left       = leftOffset + fieldLeft;
  text2.width      = fieldWidth;
  text2.properties = {'String', get_param(currentRoot, 'LastModifiedBy')};
  
  y.lastModifiedBy = sluiutil('TextWidget', toplevel, top, ...
                            text1, text2, visibility, enable);
  
  % 
  % Last Modified Date
  %
  top = top - textHeight;
  
  text1.properties = {'String', allTextStrings{2}};
  text2.properties = {'String', get_param(currentRoot, 'LastModifiedDate')};
 
  y.lastModifiedDate = sluiutil('TextWidget', toplevel, top, ...
                              text1, text2, visibility, enable);
                   
  % 
  % Popup for ModifiedHistoryUpdate
  %
  top = top - textHeight;
  
  text.left       = leftOffset + leftAlignment;
  text.width      = textWidth;
  text.properties = {'String', allTextStrings{3}};
  
  popup.left       = leftOffset + fieldLeft;
  popup.width      = fieldWidth;
  
  value = UpdateHistoryOption(get_param(currentRoot, 'UpdateHistory'));
  popup.properties = {'String', ...
                      {'Don''t Prompt'; 'Prompt For Comments When Save'}; ...
                      'Value', value; ...
                      'HorizontalAlignment', 'Left'};
  
  y.update = sluiutil('PopupWidget', toplevel, top, ...
                    text, popup, visibility, enable);
                  
  % 
  % MODIFICATION HISTORY field
  %
  top = top - vertSpacer / 2 - textHeight;
  
  text.left   = leftOffset + leftAlignment;
  text.width  = textWidth;
  text.properties = {'String', allTextStrings{4}};
  
  list.left   = leftOffset + fieldLeft;
  list.width  = fieldWidth;
  list.height = top - vertSpacer - bottomOffset;
  
  string = get_param(currentRoot, 'ModifiedHistory');
  string  = sluiutil('getCellArrayFromCharArray', string);
  
  list.properties = {'String',          string, ...
                     'Value',           1, ...
                     'Backgroundcolor', get(toplevel, 'color')};
  
  y.historyList = sluiutil('ListWidget', toplevel, top, 1, ...
                         text, list, visibility, enable);
                       
  % 
  % EDIT HISTORY button
  %
  left = leftOffset + fieldLeft - buttonWidth - leftAlignment;
  position = [left, bottomOffset + vertSpacer, buttonWidth, buttonHeight];
  
  properties = {'String', 'Edit', 'Callback', 'slmodelprop EditHistory;'};                  
  
  y.editHistory = sluiutil('CreatePushbutton', toplevel, ...
                         visibility, enable, position, properties);
  
return  % createModelHistoryPage

% ====================================================
function setModelPageProperties(toplevel, property, value)
% Sets a common property to all fields in Model Properties Page

  allData = get(toplevel, 'UserData');
  
  set(allData.tabdlg.modelPage.modelVersion.text1, property, value);
  set(allData.tabdlg.modelPage.modelVersion.text2, property, value);
  
  set(allData.tabdlg.modelPage.created.text, property, value);
  set(allData.tabdlg.modelPage.created.edit, property, value);
  
  set(allData.tabdlg.modelPage.creator.text, property, value);
  set(allData.tabdlg.modelPage.creator.edit, property, value);
  
  set(allData.tabdlg.modelPage.description.text, property, value);
  set(allData.tabdlg.modelPage.description.edit, property, value);
  
return  % setModelPageProperties

% ====================================================
function setOptionsPageProperties(toplevel, property, value)
% Sets a common property to all fields in Options Page

  allData = get(toplevel, 'UserData');
  
  set(allData.tabdlg.optionsPage.CMFrame,    property, value);
  
  set(allData.tabdlg.optionsPage.CM.text,    property, value);
  set(allData.tabdlg.optionsPage.CM.popup,   property, value);
  set(allData.tabdlg.optionsPage.HelpBelowCMText,  property, value)
  
  set(allData.tabdlg.optionsPage.FormatFrame,    property, value);
  
  set(allData.tabdlg.optionsPage.modelVersionFormat.text, property, value);
  set(allData.tabdlg.optionsPage.modelVersionFormat.edit, property, value);
  
  set(allData.tabdlg.optionsPage.modifiedByFormat.text, property, value);
  set(allData.tabdlg.optionsPage.modifiedByFormat.edit, property, value);
  
  set(allData.tabdlg.optionsPage.modifiedDateFormat.text, property, value);
  set(allData.tabdlg.optionsPage.modifiedDateFormat.edit, property, value);
  
return  % setOptionsPageProperties

% ====================================================
function setHistoryPageProperties(toplevel, property, value)
% Sets a common property to all fields in History Page

  allData = get(toplevel, 'UserData');
  
  set(allData.tabdlg.historyPage.lastModifiedBy.text1, property, value);
  set(allData.tabdlg.historyPage.lastModifiedBy.text2, property, value);
  
  set(allData.tabdlg.historyPage.lastModifiedDate.text1, property, value);
  set(allData.tabdlg.historyPage.lastModifiedDate.text2, property, value);
  
  set(allData.tabdlg.historyPage.update.text,  property, value);
  set(allData.tabdlg.historyPage.update.popup, property, value);
  
  set(allData.tabdlg.historyPage.historyList.text, property, value);
  set(allData.tabdlg.historyPage.historyList.list, property, value);
 
  set(allData.tabdlg.historyPage.editHistory, property, value);
  
return  % setHistoryPageProperties

% ====================================================
function LocalApply
% Callback for Apply button

  allData = get(gcbf, 'UserData');
  
  currentRoot = allData.currentRoot;
  
  %
  % model page
  % ----------
  
  %
  % Created
  %
  string = get(allData.tabdlg.modelPage.created.edit, 'String');
  set_param(currentRoot, 'Created', string);
  
  %
  % Creator
  %
  string = get(allData.tabdlg.modelPage.creator.edit, 'String');
  set_param(currentRoot, 'Creator', string);
  
  % 
  % Description
  %
  cellArray = get(allData.tabdlg.modelPage.description.edit, 'String');
  charArray = sluiutil('getCharArrayFromCellArray', cellArray);
  set_param(currentRoot, 'Description', charArray);
  
  %
  % options page
  % ------------
  
  % 
  % ModelVersionFormat
  % 
  string = get(allData.tabdlg.optionsPage.modelVersionFormat.edit, 'String');
  set_param(currentRoot, 'ModelVersionFormat', string);
  
  % 
  % ModifiedByFormat fields
  %
  string = get(allData.tabdlg.optionsPage.modifiedByFormat.edit, 'String');
  set_param(currentRoot, 'modifiedByFormat', string);
  
  % 
  % ModifiedDateFormat fields
  %
  string = get(allData.tabdlg.optionsPage.modifiedDateFormat.edit, 'String');
  set_param(currentRoot, 'modifiedDateFormat', string);
  
  %
  % hidtory page
  % ------------
  
  % 
  % UpdateHistory field
  %
  value = get(allData.tabdlg.historyPage.update.popup, 'Value');
  set_param(currentRoot, 'UpdateHistory', UpdateHistoryOption(value));
  
  % 
  % Determine if there are any changes in the CM. If such a 
  % change is found, update all CM blocks in the model
  %
  oldCM = get_param(currentRoot, 'ConfigurationManager');
  
  CMValue = get(allData.tabdlg.optionsPage.CM.popup, 'Value');
  CM = cminfo('All');
  newCM = CM{CMValue};
    
  if ~strcmpi(oldCM, newCM)    % 
    set_param(currentRoot, 'ConfigurationManager', newCM);
  end
    
  % 
  % get all CMBlocks from the model
  %
  allCMBlock = find_system(bdroot(gcs), ...
    'BlockType', 'SubSystem', ...
    'MaskType', 'CMBlock');
  
  if ~isempty(allCMBlock)
    set(allData.toplevel, 'Pointer', 'Watch');
    
    allCMBlockHandles = get_param(allCMBlock, 'Handle');
    for i = 1 : length(allCMBlockHandles)
      slcm('ManuallyUpdateAllCMBlocksInThisModel', allCMBlockHandles(i));
    end
    
    set(allData.toplevel, 'Pointer', 'Arrow');
  end
  
return  % LocalApply

% ====================================================
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
  
return  % UpdateHistoryOption

% ====================================================
function LocalEditHistory
% Callback for edit history button

  allData     = get(gcbf, 'UserData');
  currentRoot = allData.currentRoot;
  
  if ishandle(allData.editHistoryWindow)
    figure(allData.editHistoryWindow);
    return
  end
  
  %
  % get general dimensions
  %
  z = sluiutil('dimension');
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  vertSpacer    = z.vertSpacer;
  hScale        = z.hScale;
  vScale        = z.vScale;
  
  % 
  % set gui dimensions and center it on the screen
  %  
  oldUnits   = get(0, 'Units');
  set(0, 'Units', 'Characters');
  screenSize = get(0, 'ScreenSize');
  set(0, 'Units', oldUnits);
  
  toplevelWidth  = 500 * hScale;
  toplevelHeight = 200 * vScale;
  
  toplevelLeft   = (screenSize(3) - toplevelWidth) / 2 ;
  toplevelBottom = (screenSize(4) - toplevelHeight) / 2 ;
  
  toplevelPosition = [toplevelLeft, toplevelBottom, ...
                      toplevelWidth, toplevelHeight];
                  
  % 
  % Construct the toplevel
  %
  windowName = ['Modification History: ', get_param(currentRoot, 'Name')];
  
  toplevelEdit = figure('Numbertitle',      'off',...
                        'Name',             windowName,...
                        'Tag',              windowName,...
                        'menubar',          'none',...
                        'IntegerHandle',    'off', ...
                        'Visible',          'off', ...
                        'HandleVisibility', 'on', ...
                        'Units',            'Characters', ...
                        'Resize',           'off', ...
                        'DeleteFcn',        'delete(gcbf);', ...
                        'ResizeFcn',        'slmodelprop EditHistoryResize;', ...
                        'Position',         toplevelPosition);
  
  % 
  % Create bottom buttons
  %
  buttons       = {'Apply', 'Help', 'Cancel', 'OK'};
  buttonsCB = {'slmodelprop EditHistoryCallback Apply;', ...
               'slmodelprop Help;', ...
               'delete(gcbf);', ...
               'slmodelprop EditHistoryCallback OK;'};
           
  left = toplevelWidth;
  
  for i = 1 : length(buttons)
     left = left - leftAlignment - buttonWidth;
     position = [ left, vertSpacer, buttonWidth, buttonHeight ];
     
     properties = {'String', buttons{i}, 'Callback', buttonsCB{i}};                  
     
     bottomButtons(i) = sluiutil('CreatePushbutton', toplevelEdit, ...
                                 'on', 'on', position, properties);
  end
                            
  % 
  % Create editable field for modification history
  %
  top = toplevelHeight - vertSpacer;

  text.left       = leftAlignment;
  text.width      = toplevelWidth - 2 * leftAlignment;
  text.properties = {'String', 'Modified history:'};
  
  edit.left   = leftAlignment;
  edit.width  = text.width;
  edit.height = top - buttonHeight - 2 * vertSpacer - textHeight;
  edit.properties = {'String', get_param(currentRoot, 'ModifiedHistory')};
  
  editHistory = sluiutil('MultipleLineEditWidget', toplevelEdit, top, 0, ...
                         text, edit, 'on', 'on');

  %
  % Create an invisible text field for "WindowTooSmall". 
  %
  warningPosition = [0, 0, 25, textHeight];
  windowTooSmall = sluiutil('CreateText', toplevelEdit, ...
                            'off', 'on', warningPosition, ...
                            {'HorizontalAlignment', 'Center'});
                                  
  % 
  % create allDataEditMod and save it
  %
  allDataEditMod.toplevelEdit   = toplevelEdit;
  allDataEditMod.editHistory    = editHistory;
  allDataEditMod.currentRoot    = currentRoot;
  allDataEditMod.bottomButtons  = bottomButtons;
  allDataEditMod.windowTooSmall = windowTooSmall;
  
  allDataEditMod.modifiedHistoryList = ...
                          allData.tabdlg.historyPage.historyList.list;
                        
  allDataEditMod.visibility = 'on';
  
  set(toplevelEdit, 'UserData', allDataEditMod);
  set(toplevelEdit, 'HandleVisibility', 'Callback', 'Visible', 'on' ) ;
  
  %
  % If the Model Property dialog is closed, then I also
  % need to close (Cancel) edit history window. For this
  % I need the "toplevelEdit"
  %
  allData.editHistoryWindow = toplevelEdit;
  set(gcbf, 'UserData', allData);
  
return  % LocalEditHistory

% ====================================================
function LocalEditHistoryCallback(button)
% Callback for OK, Apply button in the window that allows
% changes in the history

  allDataEditMod = get(gcbf, 'UserData');
  
  cellArray = get(allDataEditMod.editHistory.edit, 'String');
  charArray = sluiutil('getCharArrayFromCellArray', cellArray);
  set_param(allDataEditMod.currentRoot, 'modifiedHistory', charArray);
  
  %
  % update the list
  %
  set(allDataEditMod.modifiedHistoryList, 'String', cellArray, 'Value', 1);
  
  if strcmpi(button, 'ok')
    delete(gcbf);
  end
  
return  % editModifiedHistoryCallback

% ====================================================
function setVisibility(visibility, msg)
% Set/reset the visibility of all HG elements

  allDataEditMod = get(gcbf, 'UserData');
  
  %
  % get GUI width and height
  %
  GUISize = get(gcbf, 'Position');
  toplevelWidth  = GUISize(3);
  toplevelHeight = GUISize(4);
  
  if onoff(visibility) == 0
    % 
    % make the windowTooSmall text attached to the entire GUI
    %
    pos    = get(allDataEditMod.windowTooSmall, 'Position');
    pos(1) = (toplevelWidth - pos(3)) / 2;
    pos(2) = (toplevelHeight - pos(4)) / 2;
    
    set(allDataEditMod.windowTooSmall, 'Position', pos, 'String', msg);
  end
  
  %
  % do not do anything if nothing is changed
  %
  if onoff(allDataEditMod.visibility) == onoff(visibility)
    return
  end
  
  allDataEditMod.visibility = visibility;
  
  if onoff(notbool(visibility))
    %
    % create the vector of active objects at thie moment
    %
    allObjects = findobj(gcbf, 'Visible', 'on');
    allDataEditMod.activeObjects = allObjects(find(allObjects ~= gcbf));
  end
  
  %
  % change the visibility of the "window too small warning"
  %
  set(allDataEditMod.windowTooSmall, 'Visible', notbool(visibility));
  
  %
  % change the visibility of all active objects
  %
  set(allDataEditMod.activeObjects, 'Visible', visibility);
  
  %
  % make sure that in the case when objects are visible, 
  % we empty the vector of active objects, since it is
  % no more used
  %
  if onoff(visibility)
    allDataEditMod.activeObjects = [];
  end
  
  %
  % save the modifications in allData
  %
  set(gcbf, 'UserData', allDataEditMod);
  
return  % setVisibility

% ====================================================
function LocalEditHistoryResize
% resizes the window

  %
  % Get the toplevel dimensions 
  %
  toplevelEditPos    = get(gcbf, 'Position');
  toplevelEditWidth  = toplevelEditPos(3);
  toplevelEditHeight = toplevelEditPos(4);
  
  %
  % make sure that the window has minimum dimensions
  %
  minimX = 75;
  minimY = 10;
  
  if toplevelEditWidth < minimX | toplevelEditHeight < minimY
    if toplevelEditWidth < minimX
      if toplevelEditHeight < minimY
        msg = 'Window too small';
      else
        msg = 'Window width too small';
      end
    else
      if toplevelEditHeight < minimY
        msg = 'Window height too small';
      end
    end
    
    setVisibility('off', msg);
    return
  else
    setVisibility('on', '');
  end
  
  
  allDataEditMod = get(gcbf, 'UserData');

  % 
  % get general dimensions for buttons, left alignments, height of text  
  %
  y = sluiutil('dimension');
  buttonWidth   = y.buttonWidth;
  buttonHeight  = y.buttonHeight;
  textHeight    = y.textHeight;
  leftAlignment = y.leftAlignment;
  vertSpacer    = y.vertSpacer;
  
  %   
  % Resize bottom buttons
  %
  left = toplevelEditWidth;
  
  for i = 1 : length(allDataEditMod.bottomButtons)
    left     = left - leftAlignment - buttonWidth;
    
    buttonPos = get(allDataEditMod.bottomButtons(i), 'Position');
    buttonPos(1) = left;    
    set(allDataEditMod.bottomButtons(i), 'Position', buttonPos);
  end
  
  % 
  % bottom distance is a reference for all the other widgets
  %
  bottom = 2 * vertSpacer + buttonHeight;
  top    = toplevelEditHeight - vertSpacer;
  
  %
  % resize the text and editable field
  %
  textPos    = get(allDataEditMod.editHistory.text, 'Position');
  textPos(2) = top - textHeight;
  textPos(3) = toplevelEditWidth - 2 * leftAlignment;
  set(allDataEditMod.editHistory.text, 'Position', textPos);
  
  editPos    = get(allDataEditMod.editHistory.edit, 'Position');
  editPos(3) = textPos(3);
  editPos(4) = textPos(2) - bottom;
  set(allDataEditMod.editHistory.edit, 'Position', editPos);
  
return  % LocalEditHistoryResize

% ====================================================
function LocalDeleteJavaFig(HGfig)
% Deletes the Java Figure when model is closed.
JavaFig = get(HGfig,'UserData');
if ishandle(JavaFig) 
	% Necessary check if someone calls delete(allchild(0)) from command line
	delete(JavaFig)
end


% ====================================================
