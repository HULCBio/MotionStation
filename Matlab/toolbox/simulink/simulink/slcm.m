function slcm(varargin)
%SLCM Simulink Configuration Information Block.
%   SLCM manages the user interface for the Configuration Information Block.

%   SLCM Block Properties
%
%     SourceBlockDiagram    The name of the block diagram that the block
%                           resides in.  This is used as a flag to indicate
%                           when the configuration manager information needs
%                           to be updated.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.4 $

if nargin == 0
  action = 'Create';
else
  action = varargin{1};
end

switch action
case 'Create'
  % 
  % Create the dialog box
  %
  LocalCreate
      
case 'Ok'
  % 
  % Callback for OK button
  %
  LocalOk
  
case 'Cancel'
  % 
  % Callback for Cancel button
  %
  LocalCancel
  
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
  % Callback for Apply button
  %
  LocalRename
  
case 'TransferModelFields'   
  % 
  % Callback for model transfer button
  %
  LocalTransferModelFields; 
  
case 'TransferCMFields'   
  % 
  % Callback for configuration information transfer button
  %
  LocalTransferRcsFields; 
  
case 'LoadBlock'
  % 
  % Callback for block load function
  %
  LocalLoadBlock  
  
case 'CopyBlock'
  % 
  % Callback for block copy function
  %
  LocalCopyBlock
  
case 'UpdateAllCMBlocksInThisModel'
  % 
  % Callback for diagram update
  % Because any set_param to the Configuration Information block will 
  % trigger an "Initialization" command, gcbf variable is used to 
  % determine when to call LocalUpdateDiagram: LocalUpdateDiagram function
  % is called only when gcbf is not empty
  %
  if isempty(gcbf)  
    LocalUpdateDiagram(gcbh)
  end
  
case 'UpdateAllCMBlocksInThisModelInit'
  % 
  % Callback for diagram update
  % Because any set_param to the Configuration Information block will 
  % trigger an "Initialization" command, gcbf variable is used to 
  % determine when to call LocalUpdateDiagram: LocalUpdateDiagram function
  % is called only when gcbf is not empty
  %
  dirtyFlag = get_param(bdroot,'dirty');
  if isempty(gcbf)
    LocalUpdateDiagram(gcbh)
  end
  set_param(bdroot, 'dirty', dirtyFlag);
  
case 'ManuallyUpdateAllCMBlocksInThisModel'
  % 
  % This is the function that should be called when the configuration 
  % manager is changed from the File menu/Model properties. 
  % One more parameter (a block name or a handle) is expected
  % 
  blockID = varargin{2}{1};
  if ischar(blockID)
    blockID = get_param(blockID, 'Handle')
  end
  
  LocalUpdateDiagram(blockID);
  
case 'Resize'
  %
  % called when the GUI is resized
  %
  LocalResize
  
otherwise
  %
  % action represents an invalid option. Error this out
  %
  error([action ' - unknown option']);
  
end

% ====================================================
function LocalCreate
% Create the gui for the Configuration Information Block

  %
  % Don't show the dialog if there is no X connection on unix.
  %
  if isunix & ~strcmpi(get(0,'TerminalProtocol'),'X'),
    return;
  end
  
  % 
  % Show an error if the block belongs to a locked library. 
  %
  if strcmpi(get_param(bdroot(gcbh), 'Lock'), 'on')
    errordlg('This block must be placed into a model to operate.', ...
             'Error', 'Modal');
    return
  end

  %
  % check to see if the GUI is not already open
  %
  if ~isempty(get_param(gcbh, 'UserData'))
    %
    % restore the GUI
    %
    figure(get_param(gcbh, 'UserData'));
    return
  end
  
  % 
  % handle to the current block. 
  %
  allData.gcbh = gcbh;
  
  % 
  % The current root depends wheater the block is a linked subsystem or not
  %
  if CMParentIsLinkedSubsystem(allData.gcbh)
    parent          = get_param(gcbh, 'Parent');
    currentRootName = bdroot(get_param(parent, 'ReferenceBlock'));
    currentRoot     = get_param(currentRootName, 'Handle');
    enable          = 'off';  % no fields can be changed
  else
    currentRoot     = get_param(bdroot(gcs), 'Handle');
    enable          = 'on';   % allow changes in fields
  end
  
  allData.currentRoot = currentRoot;
  
  % 
  % get general dimensions for buttons, left alignments, height of text  
  %
  y = sluiutil('dimension');
  buttonWidth   = y.buttonWidth;
  buttonHeight  = y.buttonHeight;
  textHeight    = y.textHeight;
  leftAlignment = y.leftAlignment;
  vertSpacer    = y.vertSpacer;
  hScale        = y.hScale;
  vScale        = y.vScale;
  
  visibility = 'on';
  
  %
  % Define the toplevel dimensions and center the gui on the screen
  %
  toplevelWidth  = 520 * hScale;  
  toplevelHeight = 370 * vScale;  
  
  oldUnits   = get(0, 'Units');
  set(0, 'Units', 'Characters');
  screenSize = get(0, 'ScreenSize');
  set(0, 'Units', oldUnits);
  
  toplevelLeft   = (screenSize(3) - toplevelWidth) / 2 ;
  toplevelBottom = (screenSize(4) - toplevelHeight) / 2 ;
  
  toplevelPosition = [toplevelLeft, toplevelBottom, ...
                      toplevelWidth, toplevelHeight];
                  
  %
  % Construct the toplevel
  %
  windowName = ['Model Info: ' get_param(gcbh, 'Parent')];
  
  toplevel = figure('NumberTitle',      'off',...
                    'Name',             windowName, ... 
                    'IntegerHandle',    'off', ...
                    'Visible',          'off', ...
                    'HandleVisibility', 'on', ...
                    'DeleteFcn',        'slcm Cancel;', ...
                    'ResizeFcn',        'slcm Resize;', ...
                    'Units',            'Characters', ...
                    'MenuBar',          'none',...
                    'Position',         toplevelPosition,...
                    'Color',            get(0,'FactoryUicontrolBackgroundColor'));
                                   
  %   
  % Create bottom buttons
  %
  buttons       = {'Apply', 'Help', 'Cancel', 'OK'};
  buttonsEnable = {enable,  'on',   'on',     enable};
  
  buttonsCB = {'slcm Apply;', 'slcm Help;', 'slcm Cancel;', 'slcm  Ok;'};
  
  left = toplevelWidth;
  
  for i = 1 : length(buttons)
    left     = left - leftAlignment - buttonWidth;
    position = [left, vertSpacer, buttonWidth, buttonHeight];
    
    properties = {'String', buttons{i}, 'Callback', buttonsCB{i}};                  
    
    allData.bottomButtons(i) = sluiutil('CreatePushbutton', toplevel, ...
      'on', buttonsEnable{i}, position, properties);
  end
  
  % 
  % bottom distance is a reference for all the other widgets
  %
  bottom = 2 * vertSpacer + buttonHeight;
  
  %
  % create bottom frame that will contain BlockFrame checkbox
  % and HorizontalTextAlignment popup
  %
  frame.left       = leftAlignment;
  frame.width      = toplevelWidth - 2 * leftAlignment;
  frame.height     = 2 * vertSpacer + textHeight;
  frame.properties = '';
  
  frameTop = bottom + frame.height;
  allData.frame = sluiutil('FrameWidget', toplevel, frameTop, ...
                         frame, visibility);
                       
  % 
  % create a temporary text field to get the extent 
  %
  horzTextAlignString = 'Horizontal text alignment:';
  tempText = uicontrol('Parent', toplevel, ...
                       'Style',  'Text', ...
                       'String', horzTextAlignString, ...
                       'Visible', 'off', ...
                       'Position', [0, 0, toplevelWidth, toplevelHeight]);
                     
  textExtent = get(tempText, 'Extent');
  delete(tempText);
  textWidth  = textExtent(3) * hScale;
  
  % 
  % create the check box for block icon frame
  %
  bottom = bottom + vertSpacer + textHeight;
  
  text.left       = 2 * leftAlignment;
  text.width      = textWidth;  
  text.properties = {'String', horzTextAlignString};
  
  popup.left  = text.left + text.width + leftAlignment;
  popup.width = 100 * hScale;
  
  textHorzAlignString = {'Left', 'Center', 'Right'};
  textHorzAlignValue = get_param(allData.gcbh, 'HorizontalTextAlignment');
  value = find(strcmpi(textHorzAlignString, textHorzAlignValue));
  
  popup.properties = {'String', textHorzAlignString; ...
                      'Value', value; ...
                      'HorizontalAlignment', 'Left'};
  
  allData.textHorzAlignPopup = sluiutil('PopupWidget', toplevel, bottom, ...
                                      text, popup, visibility, enable);
  
  % 
  % create the check box for block icon frame
  %
  checkbox.width = 140 * hScale; 
  checkbox.left  = toplevelWidth - checkbox.width - 2 * leftAlignment;
    
  isFramed = get_param(allData.gcbh, 'Frame');
  value = strcmpi(isFramed, 'on');
  
  checkbox.properties = {'String', 'Show block frame', 'Value', value};
  
  allData.blockIconFrame = sluiutil('CheckboxWidget', toplevel, bottom, ...
                                    checkbox, visibility, enable);
  % 
  % create two list fields for model properies and configuration info
  %
  CM = get_param(currentRoot, 'ConfigurationManager');
  if isempty(CM) | strcmpi(CM, 'none')
    CMLabel = ''; % not used
  else
    CMLabel = 'Configuration manager properties:';
  end
  
  labelList = {'Model properties:', CMLabel};
  
  left = leftAlignment;
  top  = toplevelHeight - vertSpacer;
  
  % 
  % height of a listbox
  %
  listboxHeight = (toplevelHeight - frameTop ...
                   - 3 * vertSpacer - 2 * textHeight) / 2;
  
  text.left = left;
  text.width = 170 * hScale; % 250
  
  listbox.left   = left;
  listbox.width  = 170 * hScale; % 200
  listbox.height = listboxHeight;
  
  for i = 1 : 2
    text.properties    = {'String', labelList{i}};
    listbox.properties = '';
    
    allData.list(i) = sluiutil('ListWidget', toplevel, top, 0, ...
                             text, listbox, visibility, enable);
                                  
    top = top - textHeight;
    
    % 
    % Create the transfer button
    %
    buttonPosition = [left + listbox.width + leftAlignment, ...
                      top - buttonHeight, buttonWidth / 2 , buttonHeight];
    
    allData.transferButton(i) = uicontrol('Parent',   toplevel, ...
                                          'Style',    'PushButton', ...   
                                          'String',   '-->', ...
                                          'Units',    'Characters', ...
                                          'Visible',  visibility, ...
                                          'Enable',   enable, ...
                                          'Position', buttonPosition);
                                        
    top = top - listboxHeight - vertSpacer;
                                        
  end
  
  % Set the tooltip for the configuration manager-specific listbox
  set(allData.list(2).list, 'tooltip', ['Properties for ' CM]);
  
  % 
  % Create an editable field that contains all tags that are displayed
  % in the mask of the configuration information block
  %
  editPositionLeft = buttonPosition(1) + buttonPosition(3) + leftAlignment;

  % 
  % MODEL DESCRIPTION field
  %
  top = toplevelHeight - vertSpacer;
  
  text.left       = editPositionLeft;
  text.width      = toplevelWidth - editPositionLeft - leftAlignment;
  text.properties = {'String', 'Enter text and tokens to display on Model Info block:'};
  
  edit.left       = text.left;
  edit.width      = text.width;
  edit.height     = 2 * listboxHeight + vertSpacer + textHeight;
  
  charArray = get_param(allData.gcbh, 'DisplayStringWithTags');
  cellArray = sluiutil('getCellArrayFromCharArray', charArray);
  edit.properties = {'String', charArray};
  
  allData.edit = sluiutil('MultipleLineEditWidget', toplevel, top, 0, ...
                          text, edit, visibility, enable);
                       
  % 
  % Display the options for the model properties list box
  %
  modelFields = getModelFields;
  set(allData.list(1).list, 'String', modelFields(:, 1));
  
  % 
  % Display the options for the configuration properties list box
  %
  CMFields = cminfo('Tags', get_param(currentRoot, 'Name'));
  set(allData.list(2).list, 'String', CMFields);
  if isempty(CMFields)
    set(allData.transferButton(2), 'Enable', 'off');
  end
  
  % 
  % Make sure that BlockCM is the same with ConfigurationManager
  %
  CM = get_param(currentRoot, 'ConfigurationManager');
  set_param(allData.gcbh, 'BlockCM', CM);
  
  % 
  % Set transferButton callbacks for model and configuration propertieas
  %
  set(allData.transferButton(1), 'CallBack', 'slcm TransferModelFields;');
  set(allData.transferButton(2), 'CallBack', 'slcm TransferCMFields;');
  
  %
  % Create an invisible text field used to store the warning message
  % for the case no CM is selected. 
  %
  warningPosition = get(allData.list(2).list, 'Position');
  string = {'To include configuration manager';
	    'properties, use SET_PARAM to';
	    'specify a configuration manager for';
	    'this model.';
	    '';
	    'Use the General-Source Control';
	    'Preferences to select a source';
	    'control system for new models.'};
		  
  allData.NoCMWarning = sluiutil('CreateText', toplevel, ...
                                 'off', enable, warningPosition, ...
                                 {'String', string});

  %
  % Create an invisible text field for "WindowTooSmall". 
  %
  warningPosition = [0, 0, 25, textHeight];
  allData.windowTooSmall = sluiutil('CreateText', toplevel, ...
                                    'off', enable, warningPosition, ...
                                    {'HorizontalAlignment', 'Center'});

  % 
  % allData contains all handles that were created here. This handles 
  % are used in most of the following functions, so allData is saved 
  % in gcbf UserData variable
  %
  allData.toplevel = toplevel;
  
  %
  % set the flag that for visibility
  %
  allData.visibility = 'on';
  
  %
  % save allData in UserData field of the gcbf
  %
  set(toplevel, 'UserData', allData);
  % set(gcbf, 'UserData', allData);
  
  %
  % save toplevel for destroy when the block is deleted
  %
  set_param(gcbh, 'UserData', toplevel);
  
  % 
  % Set the visibility of the toplevelhandle
  %
  set(toplevel, 'HandleVisibility', 'Callback', 'Visible', 'on');
  
  if isempty(CMFields)
    updateInstalledCM(toplevel, allData.gcbh, 'none', 'none', 1)
  end
  
return  % LocalCreate 

% ====================================================
function newString = appendString(oldString, addedString)
% Appends "addedString" at the end of the "oldString" 
% "oldString" can be a cell array of strings or an array of strings
% The output "newString" is a cell array of strings.

  if iscell(oldString)
    newString = [oldString; {addedString}];
  else
    newString = cellStr(strvcat(oldString, addedString));
  end
  
return  % appendString

% ====================================================
function appendTagToList(appendTag)
% adds appendTag at the end of the string from the editable field

  allData = get(gcbf, 'UserData');
  
  editString = get(allData.edit.edit, 'String');
  set(allData.edit.edit, 'String', appendString(editString, appendTag));

return  % appendTagToList

% ====================================================
function LocalCancel
% Callback for the "Cancel" button

  %
  % This function can be called as a result of OK/Cancel button
  % press (and in this case gbcf is valid) or as a result of 
  % deleting the block (and in this case gcbh can be used).
  %
  if isempty(gcbf)
    %
    % use gcbh, the block is destroyed
    %
    toplevel    = get_param(gcbh, 'UserData');
  else
    allData = get(gcbf, 'UserData');
    if ~isempty(allData)
      set_param(allData.gcbh, 'UserData', '');
      toplevel = allData.toplevel;
    else
      toplevel = [];
    end
  end
  
  if ishandle(toplevel)
    delete(toplevel);
  end
  
return  % LocalCancel

% ====================================================
function value = getValueFromTagName(block, tagToSearch)
% tagToSearch is of the form %<TAG>. This function return TAG
% There is one excemption, %<LastModificationDate>. In this particular
% case a "dir" command is used to get the last date when the file 

  blockdiagram = bdroot(block);
  
  if strcmpi(tagToSearch, '%<LastModificationDate>')
    % 
    % for LastModificationDate, I use dir command
    %
    value = '';
    fileName = get_param(blockdiagram, 'FileName');
    if ~isempty(fileName)
      fileExist = dir(fileName);
      if ~isempty(fileExist)  % the file does not exist on the disk
        value = fileExist.date;
      end
    end
  else
    value = get_param(blockdiagram, tagToSearch(3:end-1));
  end
  
return  % getValueFromTagName

% ====================================================
function LocalApply
% Callback for the "Apply" button

  allData      = get(gcbf, 'UserData');
  blockDiagram = get_param(bdroot(allData.gcbh),'Name');
  
  % 
  % Process the string that will be displayed inside icon.
  % Get the entire array of strings from the editable field
  % and construct a big single string separated by '\n'
  %
  editString            = get(allData.edit.edit, 'String');
  displayStringWithTags = sluiutil('getCharArrayFromCellArray', editString);
  set_param(allData.gcbh, 'DisplayStringWithTags', displayStringWithTags);
  
  % 
  % Save the HorizontalTextAlignment option
  %
  horzAlign = get(allData.textHorzAlignPopup.popup, 'String');
  value     = get(allData.textHorzAlignPopup.popup, 'Value');
  
  %
  % Replace all tags with their values
  %
  LocalUpdateBlock(allData.gcbh, horzAlign{value});
  
  % 
  % Update SourceBlockDiagram
  %
  set_param(allData.gcbh, 'SourceBlockDiagram', blockDiagram);
  
  % 
  % Save the blockIconFrame checkbox
  %
  value  = get(allData.blockIconFrame.checkbox, 'Value');
  frameExist = onoff(value);
  set_param(allData.gcbh, 'MaskIconFrame', frameExist, 'Frame', frameExist);
  
return  % LocalApply

% ====================================================
function LocalOk
% Callback for OK button

  LocalApply
  LocalCancel

return  % LocalOk

% ====================================================
function LocalRename
% Callback for block rename. The new block name is in gcb.

  toplevel = get_param(gcbh, 'UserData');
  set(toplevel, 'Name', ['Model Info: ' get_param(gcbh, 'Parent')]);
  
return  % LocalRename

% ====================================================
function LocalTransferModelFields
% Callback for the model properties transfer button

  allData = get(gcbf, 'UserData');
  
  value = get(allData.list(1).list, 'Value');
  modelFields = getModelFields;
  
  appendTagToList(['%<' modelFields{value, 2} '>']);
  
  % 
  % increment value such that it points to the next element
  %
  listSize = size(modelFields, 1);  % size of modelFields
  value    = min(value + 1, listSize);
  set(allData.list(1).list, 'Value', value);

return  % LocalTransferModelFields

% ====================================================
function LocalTransferRcsFields
% Callback for the configuration properties transfer button

  allData = get(gcbf, 'UserData');
  
  CMFields = getBlockCMFields(allData.gcbh);
  CMValue  = get(allData.list(2).list, 'Value');
  appendTagToList(['%<' CMFields{CMValue} '>']);
  
  % 
  % increment value such that it points to the next element
  %
  CMValue  = min(CMValue + 1, length(CMFields));
  set(allData.list(2).list, 'Value', CMValue);

return  % LocalTransferRcsFields

% ====================================================
function LocalUpdateBlock(block, leftAlignment)
% Based on 'DisplayStringWithTags', the content of the configuration
% information mask is updated

  displayStringWithTags = get_param(block, ...
                                    'DisplayStringWithTags');
  
  blockdiagram = bdroot(block);
  
  % 
  % Replace all tags of the form %<..> with their real values
  % in modelFields cell array
  %
  modelFields  = getModelFields;
  nModelFields = size(modelFields, 1);
  
  % 
  % get the size of CMFields of the bdroot
  %
  CMFields  = cminfo('Tags', blockdiagram);
  nCMFields = length(CMFields);
      
  % 
  % determine the size of the shortest tag
  %
  minimOptionLength = length(modelFields{1, 2});
  for i = 2 : nModelFields
    minimOptionLength = min(minimOptionLength, length(modelFields{i, 2}));
  end
  
  for i = 1 : nCMFields
    minimOptionLength = min(minimOptionLength, length(CMFields{i}));
  end
  
  % 
  % determine if editString is valid, by checking its length with
  % the size of the shortes tag
  %
  if length(displayStringWithTags) >= minimOptionLength + 3
    % 
    % Process modelFields first
    %
    for i = 1 : nModelFields
      tagToSearch = ['%<' modelFields{i, 2} '>'];
      insertString = getValueFromTagName(block, tagToSearch);
      
      displayStringWithTags = strrep(displayStringWithTags, ...
                                     tagToSearch, insertString);
    end
    
    % 
    % Process CMFields now. 
    %
    CM = get_param(blockdiagram, 'ConfigurationManager');
    if isempty(CM)
      CM = 'none';
    end
    
    % 
    % Do further computations only if CM is not 'none'
    %
    if ~strcmpi(CM, 'none') 
      SaveTempField = get_param(block, 'SaveTempField');
      
      % 
      % If SaveTempField is empty, then call setSameValueToAllFields 
      % function to update it
      % 
      if isempty(SaveTempField)
        setSameValueToAllFields(block, CM, 'CheblockkInOutToUpdate');
        SaveTempField = get_param(block, 'SaveTempField');
      end
      
      %
      % All SaveTempField fields are separated by #|#
      %
      SaveTempField = ['#|#' SaveTempField];
      SaveTempFieldSep = findstr(SaveTempField, '#|#');
      
      CMFields = cminfo(CM);
      CMFields = CMFields.fields;
      
      for i = 1 : size(CMFields, 1)
        % 
        % Determine the tag to search and how many times it appears
        %
        tagToSearch = ['%<' CMFields{i} '>'];
        
        if ~isempty(findstr(displayStringWithTags, tagToSearch))
          % 
          % The tag was found. 
          % Note that if the first letter is x, then we need to run a command
          %
          startPos = SaveTempFieldSep(i) + length('#|#');
          endPos   = SaveTempFieldSep(i+1) - 1;
          insertString = SaveTempField(startPos:endPos);
          
          if ~isempty(insertString)
            if insertString(1) == 'x'
              % 
              % We have a command to run
              %
              insertString = '';
              fileName = get_param(blockdiagram, 'FileName');
              if ~isempty(fileName)
                command = [CMFields{i, 3} ' ' fileName];
                if strncmpi(computer, 'pc', 2)
                  [a, insertString] = dos(command);
                else
                  [a, insertString] = unix(command);
                end
              end
            end
          end
          
          addString = setTagValue(CMFields{i, 2}, ...
                                  insertString, block);
          displayStringWithTags = strrep(displayStringWithTags, ...
                                         tagToSearch, addString);
        end
      end
    end
  end
  
  if strcmpi(leftAlignment, 'defaultLeftAlignment')
    leftAlignment = get_param(block, 'HorizontalTextAlignment');
  end
  
  maskDisplayString = sluiutil('replaceChar10ByNewLine', displayStringWithTags);
  set_param(block, ...
            'MaskDisplayString', maskDisplayString, ...
            'HorizontalTextAlignment', leftAlignment, ...
            'LeftAlignmentValue', horizontalTextOffset(leftAlignment));
  
return  % LocalUpdateBlock
  
% ====================================================
function LoadOrCopyBlock
% Common function for loading / copying a block

  % 
  % Compare the current block diagram to that of the block diagram currently
  % associated with this block.  If different, then the block configuration
  % manager information needs to be updated so that it's in sync with the
  % block diagram.
  %
  sourceBlockDiagram = get_param(gcbh, 'SourceBlockDiagram');
  destBlockDiagram   = get_param(bdroot(gcbh), 'Name');
  
  % 
  % get CM for destination blockdiagram. 
  %
  CM = get_param(destBlockDiagram, 'ConfigurationManager');
  
  %
  % The CM fields need to be reset if the source block diagram is different
  % from the one this block is going into.
  %
  if ~strcmpi(destBlockDiagram, sourceBlockDiagram)
    if isempty(CM)
      CM = get_param(sourceBlockDiagram, 'ConfigurationManager');
      set_param(destBlockDiagram, 'ConfigurationManager', CM);
    end
    
    setSameValueToAllFields(gcbh, CM, 'CheckInOutToUpdate');
    
    % 
    % Set initialSaveTempField as saveTempField
    %
    saveTempField = get_param(gcbh, 'SaveTempField');
    
    set_param(gcbh, 'InitialBlockCM', CM, ...
                    'BlockCM', CM, ...
                    'InitialSaveTempField', saveTempField,...
                    'SourceBlockDiagram',destBlockDiagram);
  end
  
  % 
  % Specify that I do not want to set left alignment when the block icon
  % is updated
  %
  LocalUpdateBlock(gcbh, 'defaultLeftAlignment'); 
    
  installNewCMTag(gcbh, CM);

return  % LoadOrCopyBlock

% ====================================================
function LocalLoadBlock
% Callback for block load function

  blockdiagram = get_param(bdroot(gcbh),'Name');
  lockStatus = get_param(blockdiagram, 'Lock');
  dirtyFlag  = get_param(blockdiagram, 'Dirty');
  set_param(blockdiagram, 'Lock', 'off');

  if CMParentIsLinkedSubsystem(gcbh)
    parent = get_param(gcbh, 'Parent');
    sourceBlockDiagram = bdroot(get_param(parent, 'ReferenceBlock'));
    set_param(gcbh, 'SourceBlockDiagram', sourceBlockDiagram);
  else
    % 
    % Reset mask initialization commands
    %
    maskInitialization = get_param(gcbh, 'MaskInitialization');
    set_param(gcbh, 'MaskInitialization', '');

    % 
    % Clean CMTag#'s and set SaveTempField
    %
    ClearCMTagsAndCreateSaveTempField(gcbh)

    %
    % set the namechange and delete callbacks.
    % This should be done in Simulink, but for now I do it here
    %
    set_param(gcbh, 'NameChangeFcn', 'slcm Rename;', ...
        'DeleteFcn',     'slcm Cancel;');

    % 
    % Make sure that sourceBlockDiagram is the same with 
    % current block diagram. 
    %
    set_param(gcbh, 'SourceBlockDiagram', blockdiagram);

    LoadOrCopyBlock

    % 
    % update gcbh
    %
    saveTempField = get_param(gcbh, 'SaveTempField');
    CM            = get_param(blockdiagram, 'ConfigurationManager');

    set_param(gcbh, 'InitialSaveTempField', saveTempField, ...
        'InitialBlockCM', CM, ...
        'MaskIconFrame', get_param(gcbh, 'Frame'), ...
        'MaskInitialization', maskInitialization);
  end

  % 
  % Since the previous settings make the diagram dirty, reset the dirty flag
  %
  set_param(blockdiagram, 'Dirty', dirtyFlag, 'Lock', lockStatus);

return  % LocalLoadBlock

% ====================================================
function LocalCopyBlock
% Callback for block copy function

  % 
  % Do not do anything if the block belongs to a linked subsystem
  %
  if CMParentIsLinkedSubsystem(gcbh)
    return
  end
  
  blockdiagram = bdroot(gcbh);
  
  % 
  % Disable mask initialization commands because, otherwise, 
  % it takes a very long time to copy this block
  %
  maskInitialization = get_param(gcbh, 'MaskInitialization');
  set_param(gcbh, 'MaskInitialization', '');
  
  LoadOrCopyBlock
  
  %
  % Set back mask initialization command
  %
  set_param(gcbh, 'MaskInitialization', maskInitialization, ...
                  'UserData', '');
  
return  % LocalCopyBlock

% ====================================================
function offset = horizontalTextOffset(alignment)
% Returns the horizontal offset for text alignment
% Note the offset is in normalized coordinates

  switch alignment
  case {'Left'}
    offset = '0.02';
    
  case {'Center'}
    offset = '0.5';
    
  case {'Right'}
    offset = '0.98';
    
  end
  
return  % horizontalTextOffset
  
% ====================================================
function CMFields = getBlockCMFields(block)
% Returns the fields for the current Configuration Manager

  CM = get_param(block, 'BlockCM');

  if strcmpi(CM, 'none') | isempty(CM)
    CMFields = [];
  else
    CMFields = cminfo(CM);
    CMFields = CMFields.fields(:, 1);
  end
  
return  % getBlockCMFields

% ====================================================
function y = getTagValue(tag, block)
% Given a tag of the form: $Author: batserve $, it returns "blablabla"

  CM = get_param(block, 'BlockCM');
  CMAllInfo = cminfo(CM);
  
  if isempty(CMAllInfo.separators)
    colon = '';
    dollar = '';
  else
    colon = findstr(tag, CMAllInfo.separators.startValue);  % all ':'
    dollar= findstr(tag, CMAllInfo.separators.endValue);    % all '$'
  end
  
  if isempty(colon) | isempty(dollar)
    y = '';
  else
    y = tag(colon(1)+1:dollar(end)-1);
    
    % 
    % Remove leading and trailing spaces
    %
    y = deblank(y);
    y = fliplr(y);
    y = deblank(y);
    y = fliplr(y);
  end
  
return  % getTagValue

% ====================================================
function y = setTagValue(tag, newValue, block)
% Given a tag of the form: $Author: batserve $, 
% it returns $Author: batserve $
  
  CM = get_param(block, 'BlockCM');
  CMAllInfo = cminfo(CM);
  
  colon = findstr(tag, CMAllInfo.separators.startValue);  % all ':'
  
  if isempty(colon)
    y = '';
  else
    y = [tag(1:colon(1)) ' ' newValue ' ' CMAllInfo.separators.endValue];
  end
  
return  % setTagValue

% ====================================================
function y = createCellOfEmptyCMTags(block)
% Creates a cell array of size 1x2*TagMaxNumber, of the form:
% y = {'CMTag1', '', 'CMTag2, '',  ..... }

  TagMaxNumber  = str2num(get_param(block, 'TagMaxNumber'));

  y = cell(1, 2 * TagMaxNumber);
  for i = 1 : TagMaxNumber
    y{2 * i - 1} = ['CMTag' num2str(i)];
    y{2 * i}     = '';
  end

return  % createCellOfEmptyCMTags

% ====================================================
function setSameValueToAllFields(block, CM, SameValue)
% Reset all fields associated to this CM, and updates SaveTempField

  SaveTempField = '';
  TagMaxNumber  = str2num(get_param(block, 'TagMaxNumber'));
  
  % 
  % create an empty cell of 1 row and 2 * TagMaxNumber columns.
  % Each odd column will be of the form 'CMTagXX' (XX is a number
  % between 1 and TagMaxNumber. Each even cell is empty
  %
  tagNamesAndValues = createCellOfEmptyCMTags(block);
  
  if ~(strcmpi(CM, 'none') | isempty(CM))
    % 
    % there is a configuration manager set
    %
    CMFields = cminfo(CM);
    CMFields = CMFields.fields;
    
    for i = 1 : min(TagMaxNumber, size(CMFields, 1))
      if isempty(CMFields{i, 3})
        SaveTempField = [SaveTempField SameValue '#|#'];
        tagNamesAndValues{2 * i} = CMFields{i, 2};
      else
        % 
        % For a command, we do not do anything because 
        % LocalApply will take care of it
        %
        SaveTempField = [SaveTempField 'x' '#|#'];
        tagNamesAndValues{2 * i} = 'x';
      end
    end
  end
  
  % 
  % Finally, set CMTags and SaveTempField
  %
  set_param(block, tagNamesAndValues{:}, ...
                                'SaveTempField', SaveTempField);
  
return  % setSameValueToAllFields

% ====================================================
function LocalUpdateDiagram(block)
% Callback for "UpdateDiagram"

  if CMParentIsLinkedSubsystem(block)
    return
  end
  
  blockDiagram = get_param(bdroot(block), 'Name');
  if ~strcmp(blockDiagram, get_param(block, 'SourceBlockDiagram')),
    set_param(block, 'SourceBlockDiagram', blockDiagram);
  end
  
  % 
  % Update tags if CM is changed
  %
  oldCM = get_param(block, 'BlockCM');
  newCM = get_param(blockDiagram, 'ConfigurationManager');
  updateInstalledCM(gcbf, block, oldCM, newCM, 0);
  
  % 
  % Model fields and all other stuff to update
  %
  LocalUpdateBlock(block, 'defaultLeftAlignment');
  
return  % LocalUpdateDiagram

% ====================================================
function installNewCMTag(block, CM)
% Update CMTags with the tags of the configuration manager CM

  CMFields = cminfo(CM);
  CMFields = CMFields.fields;
  
  TagMaxNumber = str2num(get_param(block, 'TagMaxNumber'));

  %
  % empty all CMTags
  %
  tagNamesAndValues = createCellOfEmptyCMTags(block);
  
  %
  % Set CM tags
  %
  for i = 1 : min(TagMaxNumber, size(CMFields, 1));
    if isempty(CMFields{i, 3})
      tagNamesAndValues{2 * i} = CMFields{i, 2};
    else
      tagNamesAndValues{2 * i}= 'x';
    end
  end
  
  set_param(block, tagNamesAndValues{:});

return  % installNewCMTag

% ====================================================
function updateInstalledCM(fromWhere, block, ...
                           oldCM, newCM, updateList)
% if oldCM and newCM are different, update tags

  blockdiagram = bdroot(block);
  if CMParentIsLinkedSubsystem(block)
    return
  end
  
  if updateList == 1
    allData = get(fromWhere, 'UserData');
  end
  
  if ~strcmpi(oldCM, newCM)
    initialBlockCM = get_param(block, 'InitialBlockCM');
    if strcmpi(newCM, initialBlockCM)
      % 
      % oldCM is the same with the newCM, restore original fields
      %
      IntialSaveTempField = get_param(block, ...
                                      'InitialSaveTempField');
      InitialBlockCM = get_param(block, 'InitialBlockCM');
                                    
      set_param(block, 'SaveTempField', IntialSaveTempField, ...
                                    'BlockCM', InitialBlockCM);
    else  
      setSameValueToAllFields(block, newCM, ...
                              'CheckInOutToUpdate');
      set_param(block, 'BlockCM', newCM);
    end
    
    installNewCMTag(block, newCM);
    
    % 
    % if necessary, update the CM list field from the display page.
    %
    if updateList == 1
      CMFields = getBlockCMFields(allData.gcbh);
      set(allData.list(2).list, 'String', CMFields);
    end
  end
  
  if updateList == 1
    if strcmpi(newCM, 'none')
      set(allData.transferButton(2), 'Visible', 'off');
      set(allData.list(2).list,      'Visible', 'off');
      set(allData.list(2).text,      'Visible', 'off');
      
      set(allData.NoCMWarning,       'Visible', 'on');
    else
      set(allData.transferButton(2), 'Visible', 'on');
      set(allData.list(2).list,      'Visible', 'on');
      set(allData.list(2).text,      'Visible', 'on');
      
      set(allData.NoCMWarning,       'Visible', 'off');
    end
    
    set(fromWhere, 'UserData', allData);
  end
          
return  % updateInstalledCM

% ====================================================
function ClearCMTagsAndCreateSaveTempField(block)
% This function is called only when loading the block.
% After a check-in, CMTags are of the form: $Author: batserve $
% This function clears all tags (like $Author: batserve $) and creates
% SaveTempField based on tag values ("_____")

  % 
  % Get CM fields of the bdroot
  %
  CMFields = cminfo('Tags', bdroot(block));
  saveTempField = get_param(block, 'SaveTempField');
  
  TagMaxNumber  = str2num(get_param(block, 'TagMaxNumber'));
  
  % 
  % decision test related to what to do with saveTempField.
  % If CMTag1 value is empty, return without doing anything.
  % If CMTag1 is not empty, it means that a check-in or check-out
  % took place and I reconstruct saveTempField
  %
  if isempty(getTagValue(get_param(block, 'CMTag1'), ...
                         block))
    return
  else
    saveTempField = '';
  end
  
  %
  % empty all CMTags
  %
  tagNamesAndValues = createCellOfEmptyCMTags(block);
  
  for i = 1 : min(size(CMFields, 1), TagMaxNumber)
    CMTag = get_param(block, ['CMTag' num2str(i)]);
    
    if (CMTag(1) ~= 'x') % do something only if not a command
      % 
      % get current tag value
      %
      CMTagValue = getTagValue(CMTag, block);
      saveTempField = [saveTempField CMTagValue '#|#'];
      
      tagNamesAndValues{2 * i} = setTagValue(CMTag, '', block);
    else % we have a command
      saveTempField = [saveTempField 'x' '#|#'];
    end
  end
  
  set_param(block, 'SaveTempField', saveTempField, ...
                                tagNamesAndValues{:});
  
return  % ClearCMTagsAndCreateSaveTempField

% ====================================================
function y = CMParentIsLinkedSubsystem(block)
% Returns 1 if the block is part of a linked
% subsystem. In this case several action will not take place,
% such as reseting CMTag#, for instance

  y = 0;  % be default I assume that CMBlock is not
          % part of a linked subsystem
  
  % 
  % is the CMBlock part of a subsytem that is a link?
  %
  parent = get_param(gcbh, 'Parent');
  if strcmpi(get_param(parent, 'Type'), 'block')
    if strcmpi(get_param(parent, 'BlockType'), 'SubSystem')
      % 
      % has parent a valid reference?
      %
      if ~isempty(get_param(parent, 'ReferenceBlock'))
        %
        % block is part of a linked subsystem
        %
        y = 1;
      end
    end
  end
  
return  % CMParentIsLinkedSubsystem
 
 % ==============================================================
function LocalHelp
% Callback for Help button
H = gcbf;
Data = get(H, 'userdata');
slhelp(Data.gcbh);

return

% ==============================================================
function modelFields = getModelFields
% Model properties fields. The first column of the cell represents what is 
% displayed on the list field, while the second column is the tag 

  modelFields = {'Created',                'Created'; ...
                 'Creator',                'Creator'; ...
                 'ModifiedBy',             'ModifiedBy'; ...
                 'ModifiedDate',           'ModifiedDate'; ...
                 'ModifiedComment',        'ModifiedComment'; ...
                 'Model Version',          'ModelVersion'; ...
                 'Description',            'Description'; ...
                 'LastModifiedBy',         'LastModifiedBy'; ...
                 'Last Modification Date', 'LastModificationDate'};
             
return

% ====================================================
function setVisibility(visibility, msg)
% Set/reset the visibility of all HG elements

  allData    = get(gcbf, 'UserData');
  
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
    pos    = get(allData.windowTooSmall, 'Position');
    pos(1) = (toplevelWidth - pos(3)) / 2;
    pos(2) = (toplevelHeight - pos(4)) / 2;
    
    set(allData.windowTooSmall, 'Position', pos, 'String', msg);
  end
  
  %
  % do not do anything if nothing is changed
  %
  if onoff(allData.visibility) == onoff(visibility)
    return
  end
  
  allData.visibility = visibility;
  
  if onoff(notbool(visibility))
    %
    % create the vector of active objects at thie moment
    %
    allObjects = findobj(gcbf, 'Visible', 'on');
    allData.activeObjects = allObjects(find(allObjects ~= gcbf));
  end
  
  %
  % change the visibility of the "window too small warning"
  %
  set(allData.windowTooSmall, 'Visible', notbool(visibility));
  
  %
  % change the visibility of all active objects
  %
  set(allData.activeObjects, 'Visible', visibility);
  
  %
  % make sure that in the case when objects are visible, 
  % we empty the vector of active objects, since it is
  % no more used
  %
  if onoff(visibility)
    allData.activeObjects = [];
  end
  
  %
  % save the modifications in allData
  %
  set(gcbf, 'UserData', allData);
  
return  % setVisibility

% ====================================================
function LocalResize
% resizes the window

  allData = get(gcbf, 'UserData');
  
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
  % Get the toplevel dimensions 
  %
  toplevelPos    = get(gcbf, 'Position');
  toplevelWidth  = toplevelPos(3);
  toplevelHeight = toplevelPos(4);
  
  %
  % make sure that the window has minimum dimensions
  %
  textHorzAlignPopup = get(allData.textHorzAlignPopup.popup, 'Position');
  blockIconFrameCheckbox = get(allData.blockIconFrame.checkbox, 'Position');
  
  minimX = textHorzAlignPopup(1) + textHorzAlignPopup(3) + ...
           blockIconFrameCheckbox(3) + 3 * leftAlignment;
  
  minimY = 15.4;
  
  if toplevelWidth < minimX | toplevelHeight < minimY
    if toplevelWidth < minimX
      if toplevelHeight < minimY
        msg = 'Window too small';
      else
        msg = 'Window width too small';
      end
    else
      if toplevelHeight < minimY
        msg = 'Window height too small';
      end
    end
    
    setVisibility('off', msg);
    return
  else
    setVisibility('on', '');
  end
  
  %   
  % Resize bottom buttons
  %
  left = toplevelWidth;
  
  for i = 1 : length(allData.bottomButtons)
    left     = left - leftAlignment - buttonWidth;
    
    buttonPos = get(allData.bottomButtons(i), 'Position');
    buttonPos(1) = left;    
    set(allData.bottomButtons(i), 'Position', buttonPos);
  end
  
  % 
  % bottom distance is a reference for all the other widgets
  %
  bottom = 2 * vertSpacer + buttonHeight;
  
  %
  % resize bottom frame that will contain BlockFrame checkbox
  % and HorizontalTextAlignment popup
  %
  framePos    = get(allData.frame.frame, 'Position');
  framePos(3) = toplevelWidth - 2 * leftAlignment;
  set(allData.frame.frame, 'Position', framePos);
                       
  frameTop = bottom + framePos(4);  % used later on
  
  % 
  % resize the check box for block icon frame
  %
  bottom = bottom + vertSpacer + textHeight;
  
  checkboxPos    = get(allData.blockIconFrame.checkbox, 'Position');
  checkboxPos(1) = toplevelWidth - checkboxPos(3) - 2 * leftAlignment;
  set(allData.blockIconFrame.checkbox, 'Position', checkboxPos);
  
  % 
  % resize the two list fields 
  %
  left = leftAlignment;
  top  = toplevelHeight - vertSpacer;
  
  % 
  % height of a listbox
  %
  listboxHeight = (toplevelHeight - frameTop ...
                   - 3 * vertSpacer - 2 * textHeight) / 2;
                 
  for i = 1 : 2
    %
    % text description for each list box
    %
    textPos    = get(allData.list(i).text, 'Position');
    textPos(2) = top - textHeight;
    set(allData.list(i).text, 'Position', textPos);
    
    %
    % list
    %
    listPos    = get(allData.list(i).list, 'Position');
    listPos(2) = textPos(2) - listboxHeight;
    listPos(4) = listboxHeight;
    set(allData.list(i).list, 'Position', listPos);
                                  
    top = top - textHeight;
    
    % 
    % Resize the transfer button
    %
    buttonPos    = get(allData.transferButton(i), 'Position');
    buttonPos(2) = top - buttonHeight;
    set(allData.transferButton(i), 'Position', buttonPos);
                                        
    top = top - listboxHeight - vertSpacer;
  end
  
  % 
  % Resize the editable field that contains all tags that are displayed
  % in the mask of the configuration information block
  %
  editPositionLeft = buttonPos(1) + buttonPos(3) + leftAlignment;

  top = toplevelHeight - vertSpacer;
  
  textPos    = get(allData.edit.text, 'Position');
  textPos(1) = editPositionLeft;
  textPos(2) = top - textHeight;
  textPos(3) = toplevelWidth - editPositionLeft - leftAlignment;
  set(allData.edit.text, 'Position', textPos);
  
  editPos    = get(allData.edit.edit, 'Position');
  editPos(1) = textPos(1);
  editPos(3) = textPos(3);
  editPos(4) = 2 * listboxHeight + vertSpacer + textHeight;
  editPos(2) = textPos(2) - editPos(4);
  
  set(allData.edit.edit, 'Position', editPos);
                       
  %
  % Create an invisible text field used to store the warning message
  % for the case no CM is selected. 
  %
  warningPos = get(allData.list(2).list, 'Position');
  set(allData.NoCMWarning, 'Position', warningPos);
  
return  % LocalResize


