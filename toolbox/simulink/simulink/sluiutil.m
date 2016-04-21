function y = sluiutil(varargin)
%SLUIUTIL Simulink User Interface Utility Functions
%   These functions are called using the command:
%   Y = SLUIUTIL('FUNCTION_NAME', ARGUMENTS);
%
%   Functions implemented:
%      dimension
%      getCellArrayFromCharArray
%      getCharArrayFromCellArray
%      replaceChar10ByNewLine
%      getPropertyValue
%      SetProperties
%
%   Simple fields  
%      CreateText
%      CreateEdit
%      CreateCheckbox
%      CreateFrame
%      CreatePopup
%      CreateList
%
%   Combo's
%      TextWidget                (text + text)
%      SingleLineEditWidget      (text + edit)
%      MultipleLineEditWidget    (text + edit)
%      PopupWidget               (text + popup)
%      CheckboxWidget            (text + checkbox)
%      ListWidget                (text + list)

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

  y = feval(varargin{1}, varargin{2:nargin});

return

% ====================================================
function y = dimension(toplevel)
% Returns a structure with general dimension

  % get the dimensions of the screen in pixels and characters
  oldUnits = get(0, 'Units');
  
  set(0, 'Units', 'Pixels');
  screenSizePixels = get(0, 'ScreenSize');
  
  set(0, 'Units', 'Characters');
  screenSizeChars = get(0, 'ScreenSize');
  
  set(0, 'Units', oldUnits);
  
  hScale = screenSizeChars(3) / screenSizePixels(3);
  vScale = screenSizeChars(4) / screenSizePixels(4);
  
  y.leftAlignment = 10  * hScale; 
  y.vertSpacer    = 10  * vScale;
  
  y.hScale        = hScale;
  y.vScale        = vScale;
  
  %
  % textHeight is a general dimension for checkboxes, 
  % edits, texts, popupmenus.
  %
  sys = sluigeom('character');
  y.textHeight = 1 + max([sys.checkbox(4), sys.edit(4), ...
                          sys.text(4), sys.popupmenu(4)]);
  
  %
  % button dimensions.
  %
  y.buttonWidth   = 100 * hScale;  
  y.buttonHeight  = 1 + sys.pushbutton(4); % instead of 30  * vScale; 

return  % dimension
  
% ====================================================================
function cellArray = getCellArrayFromCharArray(charArray)
% Converts a char array to a cell array
  cellArray = cell(0);
  while ~isempty(charArray)
    [cellArray{end+1}, charArray] = strtok(charArray, sprintf('\n'));
  end
  
return  % getCellArrayFromCharArray

% ====================================================
function charArray = getCharArrayFromCellArray(cellArray)
% Converts a cell array to a char array

  if isempty(cellArray)
    charArray = '';
  else
    % add '\n' at the end of each cell line
    cellArray(:, 2) = {sprintf('\n')};
    cellArray{end, 2} = '';
    cellArray = cellArray';
    charArray = [cellArray{:}];
  end
  
return  % getCharArrayFromCellArray

% ====================================================
function stringWithNewLine = replaceChar10ByNewLine(stringWithChar10)
% replaces all char(10) with '\n' in the input string

  stringWithNewLine = strrep(stringWithChar10, sprintf('\n'), '\n');
  
return  % replaceChar10ByNewLine

% ====================================================
function value = getPropertyValue(propertyList, property)
% propertyList is either a 1xn or a mx2 cell array. It returns 
% the value of a specific property in the list. If the property
% is not found, or propertyList has not valid dimensions,
% it returns an empty string. 
% Note that in the case when the same property is declared
% several times, then the last value is returned.

  [m, n] = size(propertyList);
  
  value = '';
  
  if (m == 1 & rem(n, 2) == 0) | (n == 2)
    pos = find(strcmpi(propertyList, property));
    if ~isempty(pos)
      if (m == 1)
        % 
        % 1xm case
        %
        value = propertyList{pos(end) + 1};
      else
        %
        % mx2 case
        %
        value = propertyList{pos(end), 2};
      end
    end
  end
  
return  % getPropertyValue

% ====================================================
function y = SetProperties(field, propertyList)
% Set propertyList to a field. propertyList is either a 
% 1xn (n even number) or mx2 cell array. 

  if ~isempty(propertyList)
    [m, n] = size(propertyList);
    
    if (m == 1 & rem(n, 2) == 0) 
      % 
      % 1xn case, n is even
      %
      set(field, propertyList(1:2:end), propertyList(2:2:end));
    else
      if n == 2 
        %
        % mx2 case
        %
        set(field, propertyList(:, 1)', propertyList(:, 2)');
      end
    end
  end
  
return  % SetProperties

% ====================================================
function y = CreatePushbutton(parentWindow, visibility, ...
                              enable, position, properties)
% Creates a push button with minimum properties

  y = uicontrol('Parent',   parentWindow, ...
                'Style',    'Pushbutton', ...
                'String',   '', ...
                'Units',    'Characters', ...
                'Visible',  visibility, ...
                'Enable',   enable, ...
                'Position', position);
              
  if nargin > 4
    SetProperties(y, properties);
  end
  
return  % CreatePushbutton

% ====================================================
function y = CreateText(parentWindow, ...
                        visibility, enable, position, properties)
% Creates a text field with minimum properties

  backgroundcolor = get(parentWindow, 'color');

  y = uicontrol('Parent',              parentWindow, ...
                'Style',               'Text', ...
                'String',              '', ...
                'BackgroundColor',     backgroundcolor, ...
                'HorizontalAlignment', 'Left', ...
                'Units',               'Characters', ...
                'Visible',             visibility, ...
                'Enable',              enable, ...
                'Position',            position);
              
  if nargin > 4
    SetProperties(y, properties);
  end
  
return  % CreateText

% ====================================================
function y = CreateEdit(parentWindow, ...
                        visibility, enable, position, properties)
% Creates an edit field with minimum properties

  y = uicontrol('Parent',              parentWindow, ...
                'Style',               'Edit', ...   
                'Backgroundcolor',     'White',...
                'String',              '', ...
                'HorizontalAlignment', 'Left', ...
                'Units',               'Characters', ...
                'Visible',             visibility, ...
                'Enable',              enable, ...
                'Position',            position);
                   
  if nargin > 4
    SetProperties(y, properties);
  end
  
return  % CreateEdit

% ====================================================
function y = CreateCheckbox(parentWindow, ...
                            visibility, enable, position, properties)
% Creates a checkbox field with minimum properties

  backgroundcolor = get(parentWindow, 'color');

  y = uicontrol('Parent',              parentWindow, ...
                'Style',               'CheckBox', ...
                'String',              '', ...
                'Value',               1, ...
                'BackgroundColor',     backgroundcolor, ...
                'Units',               'Characters', ...
                'Visible',             visibility, ...
                'Enable',              enable, ...
                'Position',            position);
                   
  if nargin > 4
    SetProperties(y, properties);
  end
  
return  % CreateCheckbox

% ====================================================
function y = CreateFrame(parentWindow, visibility, position, properties)
% Creates a frame field with minimum properties

  backgroundcolor = get(parentWindow, 'color');

  y = uicontrol('Parent',              parentWindow, ...
                'Style',               'Frame', ...
                'String',              '', ...
                'BackgroundColor',     backgroundcolor, ...
                'Units',               'Characters', ...
                'Visible',             visibility, ...
                'Position',            position);
                  
  if nargin > 4
    SetProperties(y, properties);
  end
  
return  % CreateFrame

% ====================================================
function y = CreatePopup(parentWindow, ...
                         visibility, enable, position, properties)
% Creates a popup field with minimum properties

  y = uicontrol('Parent',              parentWindow, ...
                'Style',               'Popup', ...
                'String',              '', ...
                'Backgroundcolor',     'white', ...
                'Units',               'Characters', ...
                'Visible',             visibility, ...
                'Enable',              enable, ...
                'Position',            position);
                   
  if nargin > 4
    SetProperties(y, properties);
  end
  
return  % CreatePopup

% ====================================================
function y = CreateList(parentWindow, ...
                        visibility, enable, position, properties)
% Creates a list field with minimum properties

  y = uicontrol('Parent',          parentWindow, ...
                'Style',           'ListBox', ...   
                'Backgroundcolor', 'White',...
                'String',          '', ...  
                'Units',           'Characters', ...
                'Visible',         visibility, ...
                'Enable',          enable, ...
                'Position',        position);
                   
  if nargin > 4
    SetProperties(y, properties);
  end
  
return  % CreateList

% ====================================================
function y = TextWidget(varargin)
% Displays two text fields 
% text1Info: left, width, properties
% text2Info: left, width, properties
% Returns a structure with two fields: text1 and text2

  parentWindow = varargin{1};
  top          = varargin{2};
  text1Info    = varargin{3};
  text2Info    = varargin{4};
  visibility   = varargin{5};
  enable       = varargin{6};
  
  %
  % get general dimensions
  %
  z = dimension;
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  
  %
  % get the bottom
  %
  bottom = top - textHeight;
  
  %
  % create the left text
  %
  position = [text1Info.left, bottom, text1Info.width, textHeight];
  y.text1  = CreateText(parentWindow, ...
                        visibility, enable, position, text1Info.properties);
  
  %
  % create the right text
  %
  position = [text2Info.left, bottom, text2Info.width, textHeight];
  y.text2  = CreateText(parentWindow, ...
                        visibility, enable, position, text2Info.properties);

return  % TextWidget

% ====================================================
function y = SingleLineEditWidget(varargin)
% Displays a text and a single line edit field
% textInfo: left, width, properties
% editInfo: left, width, properties
% Returns a structure with two fields: text and edit
% that are handles to the text fields

  parentWindow = varargin{1};
  top          = varargin{2};
  sameTop      = varargin{3};
  textInfo     = varargin{4};
  editInfo     = varargin{5};
  visibility   = varargin{6};
  enable       = varargin{7};
  
  %
  % get general dimensions
  %
  z = dimension;
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  
  bottom = top - textHeight;
  
  %
  % try to allign the text with the center of the edit field
  %
  if sameTop
    tempBottom = bottom - (textHeight - 1) / 2;
  else
    tempBottom = bottom;
  end
    
  %
  % create description text
  %
  position = [textInfo.left, tempBottom, textInfo.width, textHeight];
  y.text   = CreateText(parentWindow, ...
                        visibility, enable, position, textInfo.properties);
  
  if ~sameTop
    bottom = bottom - textHeight;
  end
  
  %
  % create edit field
  %
  position = [editInfo.left, bottom, editInfo.width, textHeight];
  y.edit   = CreateEdit(parentWindow, ...
                        visibility, enable, position, editInfo.properties);
  
return  % SingleLineEditWidget

% ====================================================
function y = MultipleLineEditWidget(varargin)
% Displays a text and a multiple line edit field
% textInfo: left, width, properties
% editInfo: left, width, height, properties
% Returns a structure with two fields: text and edit
% that are handles to the text and edit fields

  parentWindow = varargin{1};
  top          = varargin{2};
  sameTop      = varargin{3};
  textInfo     = varargin{4};
  editInfo     = varargin{5};
  visibility   = varargin{6};
  enable       = varargin{7};
  
  %
  % get general dimensions
  %
  z = dimension;
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  
  bottom = top - textHeight;
  
  %
  % create description text
  %
  position = [textInfo.left, bottom, textInfo.width, textHeight];
  y.text   = CreateText(parentWindow, ...
                        visibility, enable, position, textInfo.properties);
                 
  if sameTop
    bottom = top;
  end
  
  bottom = bottom - editInfo.height;
  
  %
  % create edit field
  %
  position = [editInfo.left, bottom, editInfo.width, editInfo.height];
  y.edit   = CreateEdit(parentWindow, visibility, enable, ...
                        position, {'Min', 1, 'Max', 5000});
  SetProperties(y.edit, editInfo.properties);
  
  string = getPropertyValue(editInfo.properties, 'String');
  string = getCellArrayFromCharArray(string);
  set(y.edit, 'String', string);

return  % MultipleLineEditWidget

% ====================================================
function y = PopupWidget(varargin)
% Displays a text and a popup field
% textInfo:  left, width, properties
% popupInfo: left, width, properties
% Returns a structure with two fields: text and popup
% that are handles to the text and popup fields

  parentWindow = varargin{1};
  top          = varargin{2};
  textInfo     = varargin{3};
  popupInfo    = varargin{4};
  visibility   = varargin{5};
  enable       = varargin{6};
  
  %
  % get general dimensions
  %
  z = dimension;
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  
  bottom = top - textHeight;
  
  %
  % create description text
  %
  position = [textInfo.left, bottom - (textHeight - 1) / 2, textInfo.width, textHeight];
  y.text   = CreateText(parentWindow, ...
                        visibility, enable, position, textInfo.properties);
                    
  position = [popupInfo.left, bottom, popupInfo.width, textHeight];
  y.popup  = CreatePopup(parentWindow, ...
                         visibility, enable, position, popupInfo.properties);

return  % PopupWidget

% ====================================================
function y = CheckboxWidget(varargin)
% Displays a text and a checkbox field
% textInfo:  left, width, properties
% Returns a structure with one field: checkbox
% that is a handle to the checkbox

  parentWindow = varargin{1};
  top          = varargin{2};
  checkboxInfo = varargin{3};
  visibility   = varargin{4};
  enable       = varargin{5};
  
  %
  % get general dimensions
  %
  z = dimension;
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  
  bottom = top - textHeight;
  position   = [checkboxInfo.left, bottom, checkboxInfo.width, textHeight];
  y.checkbox = CreateCheckbox(parentWindow, visibility, ...
                              enable, position, checkboxInfo.properties);
                                       
return  % CheckboxWidget

% ====================================================
function y = ListWidget(varargin)
% Displays a text and below it a list field
% textInfo:  left, width, properties
% listInfo:  left, width, height, properties
% Returns a structure with two fields: text and list
% that is a handle to the text and list field

  parentWindow = varargin{1};
  top          = varargin{2};
  sameTop      = varargin{3};
  textInfo     = varargin{4};
  listInfo     = varargin{5};
  visibility   = varargin{6};
  enable       = varargin{7};
  
  %
  % get general dimensions
  %
  z = dimension;
  buttonWidth   = z.buttonWidth;
  buttonHeight  = z.buttonHeight;
  textHeight    = z.textHeight;
  leftAlignment = z.leftAlignment;
  
  bottom = top - textHeight;
  
  %
  % create description text
  %
  position = [textInfo.left, bottom, textInfo.width, textHeight];
  y.text   = CreateText(parentWindow, ...
                        visibility, enable, position, textInfo.properties);
                   
  if sameTop
    bottom = top;
  end
                     
  bottom   = bottom - listInfo.height;
  position = [listInfo.left, bottom, listInfo.width, listInfo.height];
  y.list   = CreateList(parentWindow, ...
                        visibility, enable, position, listInfo.properties);
                                  
return  % ListWidget

% ====================================================
function y = FrameWidget(varargin)
% Draws a frame
% frameInfo: properties
% Returns a structure with one field: frame
% that is a handle to the frame

  parentWindow = varargin{1};
  top          = varargin{2};
  frameInfo    = varargin{3};
  visibility   = varargin{4};
  
  bottom = top - frameInfo.height;
  
  %
  % create description text
  %
  position = [frameInfo.left, bottom, frameInfo.width, frameInfo.height];
  y.frame  = CreateFrame(parentWindow, ...
                         visibility, position, frameInfo.properties);
                   
return  % FrameWidget

% ===============================================