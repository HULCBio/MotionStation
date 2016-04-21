function varargout = tunable_param_dlg( varargin )
%TUNABLE_PARAM_DLG Real-Time Workshop Tunable Parameter Setting Dialog Box
%   TUNABLE_PARAM_DLG is called by SIMPRM only.
%   Note: This file is the back-up file for Model Parameter Configuration
%   dialog when use doesn't have Java MWT package properly installed. 
%
%   See also SIMPRM.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.28.2.4 $

% Abstract:
%    This dialog will supply a user interface to allow user to add, delete and
%    modify tunable parameters that are created in workspace as variables.
%    
%    There are three Simulink model properties:
%       set/get_param(model,  'TunableVars', ...
%         'var1, var2, var3, var4 ...');
%       set/get_param(model,  'TunableVarsStorageClass', ...
%         'Auto, ExportedGlobal, ImportedExtern, ImportedExternPointer');
%       set/get_param(model,  'TunableVarsTypeQualifier', ...
%         ' '''', ''string'', ''string'', ''string'' ');
%
%    Note: 
%    1. User can use any string except for ',' as the variable's name.
%    2. Storage class must be selected for each tunable variables, the
%       choices are: Auto, ExportedGlobal, ImportedExtern,
%       ImportedExternPointer and the default is Auto.
%    3. User can set up Type Qualifier for each Tunable Variables. Type
%       Qualifier can be any string. When 'Auto' is selected as Tunable
%       Variables' Storage class, the 'TunableVarsTypeQualifier' will be
%       empty string.
%

Action = varargin{1};
  
switch Action
  
  case 'Create'
    %
    % Second input argument is the model name.
    %
    hModel = varargin{2};
    
    %
    % Third input parameter is the objects handle of simulation parameter 
    % Real-Time Workshop Parameter page. From this, we can get the figure
    % handles of: 
    %     system target file name -- targetFileEdit
    %     template makefile name --- makeFileEdit
    %     make command string ------ makeCmdEdit
    %
    sysChildren = varargin{3};
    
    %
    % Create the dialog
    %
    dialogFig = CreatePage( hModel, sysChildren );

    Children = get(dialogFig, 'UserData');
    Children.simprmDlg = varargin{5};
    
    set(dialogFig, 'UserData', Children);

    %
    % Install callbacks.
    %
    InstallCallbacks( dialogFig );
    
    %
    % We have this figure handle as an output so that we might be able to
    % call this function by other functions.
    %
    varargout = { dialogFig };
  
  case 'reshow'

    hModel    = varargin{2};
    dialogFig = varargin{4};
    Children  = get(dialogFig, 'UserData');

    set(Children.okButton, 'Enable', 'on');
    Children.tunableVars = LoadTunableVars( hModel, Children );
    set(Children.varsListbox, ...
	'UserData',  Children.tunableVars ...
	);
    set(dialogFig, 'UserData', Children);

    if ~isempty(Children.tunableVars)
      set(Children.varsListbox, 'Enable', 'on');
      set(Children.deleteButton, 'Enable', 'on');
    end
	
    UpdateListboxString(Children.varsListbox);

    UpdateEditField(Children.tunableVars, dialogFig);

    set( dialogFig, 'Visible', 'on' );
    figure( dialogFig );
    varargout = {dialogFig};
    
  case 'changename'
    dialogFig = varargin{2};
    hModel    = varargin{3};
    set(dialogFig, 'name', DlgName(hModel));

    varargout = {dialogFig};
    
  case 'hgdeletefcn'
    dialogFig = varargin{2};
    Children = get(dialogFig, 'UserData');

    simprmDlg = Children.simprmDlg;
    
    if dialogFig ~= -1
      delete(dialogFig);
      dialogFig = -1;
    end

    if ~isempty(simprmDlg)
      if isa(simprmDlg, 'DAStudio.Dialog')
        simprmUserData = getUserData(simprmDlg, 'Tag_ConfigSet_Optimization_Configure');
        simprmUserData.hConfigDlg = -1;
        setUserData(simprmDlg, 'Tag_ConfigSet_Optimization_Configure', simprmUserData);
        simprmUserData = [];
      else
        simprmUserData = get(simprmDlg, 'UserData');
      end    
    end
    
    if ~isempty(simprmUserData) & ~isempty(simprmUserData.AdvancedPage.Children)
      simprmUserData.AdvancedPage.ParamAttrDlg = -1;
      set(simprmDlg, 'UserData', simprmUserData);
    end

  case 'CallBack'
    %
    % It handles 4 types of callback:
    %    Apply button, OK button, Cancel button and TLC file selection.
    %
    callBackAction = varargin{2};
    figHandle      = varargin{3};
    ApplyCallbacks( callBackAction, figHandle );

  otherwise
    %
    % Error out to indicate this function is for simprm.m only right now.
    %
    error(['TUNABLE_PARAM_DLG.M is called by SIMPRM.M only. ' ...
	  'To have it work with other functions, please look at simprm.m' ...
	  'for details.']);
    return;
end
%endfunction

% Function: CreatePage =========================================================
% Abstract:
%      Create the figure to show every system target file name and description.
%
function dialogFig = CreatePage(hModel, sysChildren);

%
% Create constants based on current computer
%
thisComputer = computer;

bgcolor     = get(0, 'FactoryUicontrolBackgroundColor');
hgdeletefcn = 'tunable_param_dlg(''hgdeletefcn'', gcbf)';

switch(thisComputer),
  case 'PCWIN',
    listboxFixedFontName = 'Courier new';
    lang = get(0, 'language');
    if strncmp(lang, 'ja', 2)
      listboxFixedFontName = 'FixedWidth';
    end
    listboxFixedFontSize = 9;
    popupBgColor = 'w';
    
  otherwise,  % X-window
    listboxFixedFontName = 'Courier';
    listboxFixedFontSize = 9;
    popupBgColor = bgcolor;
end

%
% Create an empty figure (we need it now for text extents).
%
dialogFig = figure( ...
    'Visible',                            'off', ...
    'DefaultUicontrolHorizontalAlign',    'left', ...
    'HandleVisibility',                   'off', ...
    'Color',                              bgcolor, ...
    'Menubar',                            'none', ...
    'NumberTitle',                        'off', ...
    'DeleteFcn',                          hgdeletefcn, ...
    'Name',                               DlgName(hModel), ...
    'WindowStyle',                        'normal', ...
    'IntegerHandle',                      'off' ...
    );

%
% Create a text object for text sizing.
%
textExtent = uicontrol( ...
    'Parent',     dialogFig, ...
    'Visible',    'off', ...
    'Style',      'text', ...
    'FontSize',   listboxFixedFontSize, ...
    'FontName',   listboxFixedFontName ...
    );

%===============================================================================
% Create default dialog page.
%===============================================================================

%
% The positions of figure and each objects has fixed position.
%
CtrlPos = CtrlPosition( textExtent );

%
% Create description groupbox.
%
set(textExtent, 'String', 'Description');
dscrptGroupbox = groupbox( ...
    dialogFig, ...
    CtrlPos.dscrptGroupbox, ...
    '  Description', ...
    textExtent ...
    );

dscrptGroupboxStr = [ ...
      'When inline parameters is on, the following workspace variables will' ...
      ' be tunable in your embedded target.' ...
      ];

Children.dscrptGroupbox = uicontrol( ...
    'Parent',   dialogFig, ...
    'Style',    'text', ...
    'String',   dscrptGroupboxStr, ...
    'Position', ...
    [CtrlPos.dscrptGroupbox(1)+8 ...
      CtrlPos.dscrptGroupbox(2)+2 ...
      CtrlPos.dscrptGroupbox(3)-10 ...
      CtrlPos.dscrptGroupbox(4)*3/4] ...
    );

%
% Create 'mainFrame'
%
Children.mainFrame = uicontrol( ...
    'Parent',      dialogFig, ...
    'Style',       'frame', ...
    'Enable',      'inactive', ...
    'Foreground',  [255 251 240]/255, ...
    'Position',    CtrlPos.mainFrame ...
    );

%
% Create 'Add' button
%
Children.addButton = uicontrol( ...
    'Parent',          dialogFig, ...
    'String',          'Add', ...
    'Horizontalalign', 'center', ...
    'Position',        CtrlPos.addButton ...
    );

%
% Create 'Delete' button
%
Children.deleteButton = uicontrol( ...
    'Parent',          dialogFig, ...
    'String',          'Delete', ...
    'Enable',          'off', ...
    'Horizontalalign', 'center', ...
    'Position',        CtrlPos.deleteButton ...
    );

%
% Create listbox title: Variable, Storage class and Type qualifier
%
Children.varsnameLabel = uicontrol( ...
    'Parent',          dialogFig, ...
    'Style',           'edit', ...
    'String',          'Variable name', ...
    'HorizontalAlign', 'center', ...
    'Enable',          'inactive', ...
    'Position',        CtrlPos.varsnameLabel ...
    );

Children.storageLabel = uicontrol( ...
    'Parent',          dialogFig, ...
    'Style',           'edit', ...
    'String',          'Storage class', ...
    'HorizontalAlign', 'center', ...
    'Enable',          'inactive', ...
    'Position',        CtrlPos.storageLabel ...
    );

Children.qualifierLabel = uicontrol( ...
    'Parent',          dialogFig, ...
    'Style',           'edit', ...
    'String',          'Storage type qualifier', ...
    'HorizontalAlign', 'center', ...
    'Enable',          'inactive', ...
    'Position',        CtrlPos.qualifierLabel ...
    );

%
% Create 'listbox'
%
Children.varsListbox = uicontrol( ...
    'Parent',       dialogFig, ...
    'Style',        'listbox', ...
    'Fontname',     listboxFixedFontName, ...
    'Fontsize',     listboxFixedFontSize, ...
    'Position',     CtrlPos.varsListbox ...
    );

%
% Create Variable Name editor
%
Children.varsnameText = uicontrol( ...
    'Parent',   dialogFig, ...
    'Style',    'text', ...
    'String',   'Variable:', ...
    'Position', CtrlPos.varsnameText ...
    );

Children.varsnameEdit = uicontrol( ...
    'Parent',          dialogFig, ...
    'Style',           'edit', ...
    'BackgroundColor', 'w', ...
    'Position',        CtrlPos.varsnameEdit ...
    );

%
% Create Storage class selector
%
Children.storageText = uicontrol( ...
    'Parent',    dialogFig, ...
    'Style',     'text', ...
    'String',    'Storage class:', ...
    'Position',  CtrlPos.storageText ...
    );

Children.storagePopup = uicontrol( ...
    'Parent',          dialogFig, ...
    'Style',           'popup', ...
    'BackgroundColor', popupBgColor, ...
    'String',          ...
    'Auto|ExportedGlobal|ImportedExtern|ImportedExternPointer', ...
    'Tooltip',        ...
    ['Storage class for code gerneration', sprintf('\n'), ...
      '(Auto places parameter in global structure)'], ...
    'Position',        CtrlPos.storagePopup ...
    );

%
% Create Type Qualifier editor
%
Children.qualifierText = uicontrol( ...
    'Parent',    dialogFig, ...
    'Style',     'text', ...
    'String',    'Storage type qualifier:', ...
    'Enable',    'off', ...
    'Position',  CtrlPos.qualifierText ...
    );

Children.qualifierEdit = uicontrol( ...
    'Parent',          dialogFig, ...
    'Style',           'edit', ...
    'Enable',          'off', ...
    'BackgroundColor', 'w', ...
    'Position',        CtrlPos.qualifierEdit ...
    );

%
% Create 'Current Limitations' button
%
Children.currentLimit = uicontrol( ...
    'Parent',          dialogFig, ...
    'String',          'Current limitations', ...
    'Horizontalalign', 'center', ...
    'Position',        CtrlPos.currentLimit ...
    );

%
% Create 'OK' button
%
Children.okButton = uicontrol( ...
    'Parent',          dialogFig, ...
    'String',          'OK', ...
    'Horizontalalign', 'center', ...
    'Position',        CtrlPos.okButton ...
    );

%
% Create 'cancel' button
%
Children.cancelButton = uicontrol( ...
    'Parent',          dialogFig, ...
    'String',          'Cancel', ...
    'Horizontalalign', 'center', ...
    'Position',        CtrlPos.cancelButton ...
    );

%
% Create 'Help' button
%
Children.helpButton = uicontrol( ...
    'Parent',          dialogFig, ...
    'String',          'Help', ...
    'Horizontalalign', 'center', ...
    'Enable',          'on', ...
    'Position',        CtrlPos.helpButton ...
    );

%
% Create 'Apply' button
%
Children.applyButton = uicontrol( ...
    'Parent',          dialogFig, ...
    'String',          'Apply', ...
    'Horizontalalign', 'center', ...
    'Enable',          'off', ...
    'Position',        CtrlPos.applyButton ...
    );

%
% Adjust the position of the figure if the sceen size is big enough
%
screenSize = get(0, 'ScreenSize');
if screenSize(4) >= 1024 

  if isa(sysChildren, 'DAStudio.Dialog')
    simprmPos = get(sysChildren, 'position');
  else 
    simprmPos = get( get(sysChildren.ParamAttrButton, 'Parent'), 'position');
  end
  
  if ~isempty(simprmPos)
    figPosition = get(dialogFig, 'position');
    set(dialogFig, 'Position', ...
                   [figPosition(1) simprmPos(2)-CtrlPos.figHeight ...
                    CtrlPos.figWidth CtrlPos.figHeight ] ...
                   );
  end

else
  figPosition = get(dialogFig, 'position');
  set(dialogFig, 'Position', ...
      [figPosition(1) figPosition(2)  ...
	CtrlPos.figWidth CtrlPos.figHeight ] ...
      );
  
end

%
% Free up some memory
%
CtrlPos     = [];
sysChildren = [];

%
% Load Tunable Parameters: TunableVars, TunableVarsStorageClass &
% TunableVarsTypeQualifier. 
%
Children.tunableVars = LoadTunableVars( hModel, Children );

if ~isempty(Children.tunableVars)
  
  set(Children.varsListbox, ...
      'UserData',  Children.tunableVars ...
      );
  
  UpdateListboxString( Children.varsListbox );
  set(Children.deleteButton, 'Enable', 'on' );

end

%
% Pass Simulation Parameter Real-Time Workshop page's figure handle into
% UserData 
%
Children.hModel    = hModel;
Children.dialogFig = dialogFig;

set(dialogFig, ...
    'UserData', Children ...
    );

%
% Updating associated items.
%
UpdateEditField( Children.tunableVars, dialogFig );

%
% Main portions of figure are created.
%
set(dialogFig, ...
    'Visible',    'on', ...
    'Resize',     'off' ...
    );

%endfunction


% Function: CtrlPosition =======================================================
% Abstract: 
%      Calculate the position of each objects on this page.
%
% This function will return a struct array CtrlPos which has the following
% fields: 
%  (1)mainFrame:      a frame which includes the major items.
%  (2)figWidth:       width of the dialog;
%     figHeight:      height of the dialog.
%  (3)dscrptGroupbox: a groupbox which has the description of this dialog.
%  (4)cancelButton:   ignore any change and close the figure.
%  (5)okButton:       'OK', apply the parameters and close the figure.
%  (6)varsnameText:   a string 'Variables:' in front of varsnameEdit.
%  (7)varsnameEdit:   a text edit field to type variable's name.
%  (8)storageText:    a string 'Storage class:' in front of 'storagePopup'.
%  (9)storagePopup:   a popup menu to select variable's Storage class type.
% (10)qualifierText:  a string of 'Type Qualifier:' in front of 'qualifierEdit'.
% (11)qualifierEdit:  a text edit field to type variable's type qualifier.
% (12)varsnameLabel:  a column label for tunable variable's name(text).
% (13)storageLabel:   a column label for storage class identification(text).
% (14)qualifierLabel: a column label for type qualifier of a variable(text).
% (15)addButton:      a button to add new tunable parameters.
% (16)deleteButton:   a button to remove an existing tunable parameter.
% (17)varsListbox:    the listbox to display tunable parameters and thier
%                     properties.
% (18)applyButton:    apply the parameters
% (19)currentLimit:   a linkage to the temp help HTML file that indicates
%                     the current limitation of this GUI.
% (20)helpButton:     a linkage to the help HTML file for this dialog.
%
function CtrlPos = CtrlPosition( textExtent )

%
% Set up some common geom for this figure.
%
sysOffsets = sluigeom;

%
% Calculate button width and item's height for popup, text and edit field.
%
calibrationStr = '_Cancel_';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

buttonWidth = ext(3);
charHeight  = ext(4);

%
% Calculate popup width, it also is used as the width of varsnameEdit and
% qualifierEdit.  
%
calibrationStr = 'ImportedExternPointer';
set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');
popupWidth = ext(3);

%
% Calculate listbox width, it consists of 'Tunable Variable', popupWidth
% (which is for the second column of the listbox) and 'Type Qualifier'.
%
calibrationStr = '     Tunable Variable    ';
set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');
varsnameLabelWidth = ext(3);

calibrationStr = 'Storage type qualifier:  ';
set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');
qualifierLabelWidth = ext(3);

textHeight   = charHeight;
editHeight   = charHeight + sysOffsets.edit(4);

popupHeight  = charHeight + sysOffsets.popupmenu(4);
popupWidth   = popupWidth + sysOffsets.popupmenu(3);

buttonHeight = (charHeight*1.3) + sysOffsets.pushbutton(4);
buttonWidth  = buttonWidth + sysOffsets.pushbutton(3);

listboxWidth = varsnameLabelWidth + popupWidth + qualifierLabelWidth;
listboxHeight = 150; 

buttonDelta   = 8;
figBuffer     = 8;

%
% We have the dimension of the mainFrame.
%
frameWidth = ...
    figBuffer + buttonWidth + ...   % the width of add/delete button
    figBuffer + listboxWidth + ...  % the width of listbox
    figBuffer;                      % right edge buffer

frameHeight = ...
    figBuffer + editHeight  + ...   % the line of 'Type Qualifier'
    figBuffer + popupHeight + ...   % the line of 'Variable'/'Storage class'
    figBuffer + buttonDelta + ...   % the empty line under listbox
    listboxHeight           + ...   % listbox height
    editHeight ;                    % the line of listbox title

%
% (1)Set up the position of mainFrame
%
CtrlPos.mainFrame = [ ...
      figBuffer ...
      buttonDelta + buttonHeight + figBuffer ...
      frameWidth ...
      frameHeight ...
      ];

%
% The description groupbox has a fixed size: its width equals to frameWidth,
% its height is two lines characters and some offsets. 
%
dscrptGroupboxWidth  = frameWidth;
dscrptGroupboxHeight = 2.2 * textHeight;

%
% (2)Now we have the full dimensions of the figure.
%
CtrlPos.figWidth  = frameWidth + 2 * figBuffer;
CtrlPos.figHeight = ...
    2*figBuffer + dscrptGroupboxHeight + ...
    figBuffer + frameHeight + ...
    buttonDelta + buttonHeight + ...
    figBuffer;

%
% (3)Set up the position of description's groupbox
%
CtrlPos.dscrptGroupbox = [ ...
      figBuffer ...
      CtrlPos.figHeight - 2*figBuffer - dscrptGroupboxHeight ...
      dscrptGroupboxWidth ...
      dscrptGroupboxHeight ...
      ];

%
% (18)Set up the position of applyButton
%
cxCur = CtrlPos.figWidth - figBuffer - buttonWidth;
cyCur = figBuffer;

CtrlPos.applyButton = [ ...
      cxCur cyCur ...
      buttonWidth ...
      buttonHeight ...
      ];

%
% (20)Set up the position for helpButton
%
cxCur = cxCur - buttonDelta - buttonWidth;

CtrlPos.helpButton = [ ...
      cxCur cyCur ...
      buttonWidth ...
      buttonHeight ...
      ];

%
% (4)Set up the position for cancelButton
%
cxCur = cxCur - buttonDelta - buttonWidth;

CtrlPos.cancelButton = [ ...
      cxCur cyCur ...
      buttonWidth ...
      buttonHeight ...
      ];

%
% (5)Set up the position of okButton.
%
cxCur = cxCur - buttonDelta - buttonWidth;

CtrlPos.okButton = [ ...
      cxCur cyCur ...
      buttonWidth ...
      buttonHeight ...
      ];

%
% (19)Set up the position of currentLimit
%
cxCur = figBuffer;

CtrlPos.currentLimit = [ ...
      cxCur cyCur ...
      buttonWidth * 2 ...
      buttonHeight ...
      ];

%
% (6,7)Set up the position of varsnameText & varsnameEdit pair.
%
cxCur = figBuffer + CtrlPos.mainFrame(1) + 10;
cyCur = ...
    CtrlPos.mainFrame(2) + figBuffer + ...
    editHeight + figBuffer;

calibrationStr = 'Variable:';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

varsnameTextWidth = ext(3);

CtrlPos.varsnameText = [ ...
      cxCur cyCur ...
      varsnameTextWidth textHeight ...
      ];

cxCur = figBuffer * 2 + buttonWidth + CtrlPos.mainFrame(1);

CtrlPos.varsnameEdit = [ ...
      cxCur cyCur ...
      varsnameLabelWidth editHeight ...
      ];

%
% (8,9)Set up the position of storageText & storagePopup pair.
%
cxCur = CtrlPos.figWidth - 2*figBuffer - popupWidth;
cyCur = cyCur;

CtrlPos.storagePopup = [ ...
      cxCur cyCur ...
      popupWidth popupHeight ...
      ];

CtrlPos.storageText = [ ...
      cxCur-qualifierLabelWidth+35 cyCur ...
      qualifierLabelWidth textHeight ...
      ];

%
% (10,11)Set up the position of qualifierText & qualifierEdit pair.
%
cyCur = cyCur - figBuffer - editHeight;

CtrlPos.qualifierEdit = [ ...
      cxCur cyCur ...
      popupWidth editHeight ...
      ];
      
CtrlPos.qualifierText = [ ...
      cxCur-qualifierLabelWidth+35  cyCur ...
      qualifierLabelWidth  textHeight ...
      ];

%
% (12,13,14)Set up the position of varsnameLabel, storageLabel and
% qualifierLabel. 
%
cxCur = 3 * figBuffer + buttonWidth;
cyCur = CtrlPos.figHeight - 4 * figBuffer - ...
    dscrptGroupboxHeight - textHeight;

CtrlPos.varsnameLabel  = [ ...
      cxCur cyCur ...
      varsnameLabelWidth textHeight ...
      ];
      
cxCur = cxCur + varsnameLabelWidth;

CtrlPos.storageLabel = [ ...
      cxCur cyCur ...
      popupWidth textHeight ...
      ];

cxCur = cxCur + popupWidth;

CtrlPos.qualifierLabel = [ ...
      cxCur cyCur ...
      qualifierLabelWidth textHeight ...
      ];

%
% (15,16)Set up the position of addButton & deleteButton.
%
cxCur = 2 * figBuffer;
cyCur = cyCur - buttonHeight;

CtrlPos.addButton = [ ...
      cxCur cyCur ...
      buttonWidth buttonHeight ...
      ];

CtrlPos.deleteButton = [ ...
      cxCur cyCur - buttonDelta - buttonHeight ...
      buttonWidth buttonHeight ...
      ];

%
% (17)Set up the position of varsListbox. The listbox has a fixed height.
%
cxCur = cxCur + buttonWidth + figBuffer;
cyCur = cyCur + buttonHeight - listboxHeight;

CtrlPos.varsListbox = [ ...
      cxCur cyCur ...
      listboxWidth listboxHeight ...
      ];

%
% Free up some memory.
%
sysOffsets = [];

%endfunction


% Function: LoadTunableVars ====================================================
% Abstract:
%      Load the model's tunable parameters and parsing them into one string and
%      return it.
%
function tunableVars = LoadTunableVars( hModel, Children )

tunableVarsName          = get_param(hModel, 'TunableVars');
tunableVarsStorageClass  = get_param(hModel, 'TunableVarsStorageClass');
tunableVarsTypeQualifier = get_param(hModel, 'TunableVarsTypeQualifier');

%
% Locate the separate symbol's position.
%
sep         = ',';
sepNameIndx = findstr(tunableVarsName, sep);
sepSCIndx   = findstr(tunableVarsStorageClass, sep);
sepTQIndx   = findstr(tunableVarsTypeQualifier, sep);

%
% Get the number of Tunable Variables
%
if ~isempty(tunableVarsName)
  numberVars = length(sepNameIndx) + 1;
else
  numberVars = 0;
end

if numberVars
  %
  % Error handling
  %
  if length(sepSCIndx)+1 ~= numberVars
    errordlg(...
	['Error on tunable parameters setting in model: ', ...
	  get_param(hModel,'name'), ... 
	  '. Number of tunable parameter names doesn''t match the number ' ...
	  'of storage class settings.'], ...
	'Tunable parameters Dialog Error', 'modal');
    set(Children.okButton, 'Enable', 'off');
    set(Children.applyButton, 'Enable', 'off');
    return;
  elseif  length(sepTQIndx)+1 ~= numberVars
    errordlg(...
	['Error on tunable parameters setting in model: ', ...
	  get_param(hModel,'name'), ...
	  '. Number of tunable parameter names doesn''t match the number ' ...
	  'of type qualifier settings.'], ...
	'Tunable parameters Dialog Error', 'modal');
    set(Children.okButton, 'Enable', 'off');
    set(Children.applyButton, 'Enable', 'off');
    return;
  elseif  length(sepTQIndx) ~= length(sepSCIndx)
    errordlg(...
	['Error on tunable parameters setting in model: ', ...
	  get_param(hModel,'name'), ...
	  '. Number of tunable parameter storage class settings doesn''t ' ...
	  'match the number of type qualifier settings.'], ... 
	'Tunable parameters Dialog Error', 'modal');
    set(Children.okButton, 'Enable', 'off');
    set(Children.applyButton, 'Enable', 'off');
    return;
  end

  %
  % Re-locate the separate symbol's position.
  %
  sepNameIndx = findstr(tunableVarsName, sep);
  sepSCIndx   = findstr(tunableVarsStorageClass, sep);
  sepTQIndx   = findstr(tunableVarsTypeQualifier, sep);
  
  sepNameIndx = [0 sepNameIndx length(tunableVarsName)+1];
  sepSCIndx   = [0 sepSCIndx length(tunableVarsStorageClass)+1];
  sepTQIndx   = [0 sepTQIndx length(tunableVarsTypeQualifier)+1];
  
  %
  % In the dialog, the width of each field is fixed so that we can get the
  % clear aliagnment.
  %
  varsNameLength = 25;
  scLength       = 26;

  tunableVars = [];
  for i = 1 : numberVars
    %
    % To have a nice look on the GUI, we need to sort these parameters.
    % First, make these three regions with specific lengths: 25 characters for
    % variable name list, 25 characters for storage class list and no limit for
    % type qualifier list.
    %
    nameTmp = tunableVarsName(sepNameIndx(i)+1 : sepNameIndx(i+1)-1);
    nameTmp = deblankall(nameTmp);
    if length(nameTmp) <= varsNameLength
      nameTmp( length(nameTmp)+1 : varsNameLength ) = ' ';
    else
      nameTmp = [nameTmp, ' '];
    end
    
    scTmp = tunableVarsStorageClass(sepSCIndx(i)+1 : sepSCIndx(i+1)-1);
    scTmp = deblankall(scTmp);
    
    switch lower(scTmp)
      case 'auto'
	scTmp = 'Auto';
      case 'exportedglobal'
	scTmp = 'ExportedGlobal';
      case 'importedextern'
	scTmp = 'ImportedExtern';
      case 'importedexternpointer'
	scTmp = 'ImportedExternPointer';
      otherwise
	warning(['Error using ===> set_param(''',get_param(hModel,'name') ...
	      ''',''TunableVarsStorageClass'')']);
	disp([scTmp, ' is not a standard option.']);
	disp(['Select from [ {Auto} | ExportedGlobal | ImportedExtern |' ...
	      ' ImportedExternPointer ]']);
    end

    if length(scTmp) <= scLength
      scTmp( length(scTmp)+1 : scLength ) = ' ';
    else
      scTmp = [scTmp( 1 : scLength ), ' '];
    end
      
    if strcmp(lower(deblankall(scTmp)), 'auto' )
      tqTmp = '';
    else
      tqTmp = tunableVarsTypeQualifier(sepTQIndx(i)+1 : sepTQIndx(i+1)-1);
      tqTmp = deblankall(tqTmp);
    end
    
    paramTmp = [nameTmp, '|', scTmp, '|', tqTmp];
    tunableVars = [tunableVars; {paramTmp}];
  
  end
  
else
  
  tunableVars = [];
  
end

%
%tunableVars = [tunableVars; ...
%       0        1         2         3         4         5
%      {12345678901234567890123456789012345678901234567890
%      'This_var        ImportedExternPointer     your_qualifier'; ...
%      'varsABC         Auto                                    '; ...
%      'varsXYZ         ExportedGlobal            qualifier2'; ...
%      }];

%
% After we get the whole set of string of these parameters, we need to sort
% all variable's name alphabetically.
%
tunableVars = sortrows(tunableVars);

%endfunction


% Function: InstallCallbacks ===================================================
% Abstract:
%      Set up the callback function for this dialog box.
%
%  okButton: apply the parameters and close the figure.
%  cancelButton: ignore any change and close the figure.
%  addButton: add a tunable parameter
%  deleteButton: delete a selected tunable parameter
%  Three edit fields: variable name, storage class popup and type qualifier
%  edit field.
%   
function dialogFig = InstallCallbacks( dialogFig )

Children  = get( dialogFig, 'UserData');  
dialogFig = Children.dialogFig;

% make the figure's keyboard press function to call 'OK' button
set(dialogFig, 'KeyPressFcn', ...
	       'tunable_param_dlg(''CallBack'', ''ReturnKeyOK'', gcbf)');

%
% Install callback for 'Apply', 'OK' and 'Cancel' button
%
set( Children.applyButton, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''Apply'', gcbf)' ...
    );

set( Children.okButton, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''OK'', gcbf)' ...
    );

set( Children.cancelButton, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''Cancel'', gcbf)' ...
    );

set( Children.currentLimit, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''LimitNote'', gcbf)' ...
    );

set( Children.helpButton, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''Help'', gcbf)' ...
    );

%
% Install callback for 'Add' and 'Delete' button
%
set( Children.addButton, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''Add'', gcbf)' ...
    );

set( Children.deleteButton, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''Delete'', gcbf)' ...
    );

%
% Install callback for 'listbox'
%
set( Children.varsListbox, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''Select'', gcbf)' ...
    );

%
% Install callback for 'Variable' name editor, 'Storage class' popup and
% 'Type Qualifier' editor.
%
set( Children.varsnameEdit, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''EditField'', gcbf)' ...
    );
set( Children.storagePopup, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''EditField'', gcbf)' ...
    );
set( Children.qualifierEdit, ...
    'Callback',   'tunable_param_dlg(''CallBack'', ''EditField'', gcbf)' ...
    );

%endfunction


% Function: ApplyCallbacks =====================================================
% Abstract:
%      Execute all of the callbacks for this dialog.
%
function  ApplyCallbacks( action, figHandle );

Children    = get(figHandle, 'UserData');
hModel      = Children.hModel;
dialogFig   = Children.dialogFig;
tunableVars = get(Children.varsListbox, 'UserData');
  
switch action
  
  case 'Apply'
    %
    % We will save the valid tunable parameters into the model
    %
    invalidVars = [];
    invalidVars = SaveTunableVars( hModel, Children, tunableVars );
    
    % gray out the apply button after click
    set(Children.applyButton, 'Enable', 'off');
    
  case 'OK'
    %
    % we must save the tunable parameters into the model.
    %
    invalidVars = [];
    invalidVars = SaveTunableVars( hModel, Children, tunableVars );
   
    %
    % Then, close the browser window if there is no error occurs.
    %
    if isempty( invalidVars )
      set(figHandle, 'Visible', 'off');
    else
      errordlg(['A variable name is empty! Please enter a valid variable ' ...
	    'name or delete it.'], 'Tunable parameters Dialog Error', 'modal');
      return;
    end
    
  case 'Cancel'
    %
    % Do nothing and close the figure.
    %
    set(figHandle, 'Visible', 'off');
    
  case 'Help'
    %
    % Load the help page for this dialog
    %
    set(dialogFig, 'Pointer', 'watch');
    helpview([docroot,'/toolbox/simulink/tuneprmhelp.html']);
    set(dialogFig, 'Pointer', 'arrow');
    
  case 'LimitNote'
    %
    % This is not a real help button yet. It will only tell user the current
    % limitations of this GUI.
    %
    set(dialogFig, 'Pointer', 'watch');
    helpview([docroot,'/toolbox/simulink/tuneprmlim.html']);
    set(dialogFig, 'Pointer', 'arrow');
    
  case 'Add'
    %
    % Add new tunable parameters.
    %
    dialogFig = AddTunableParams(tunableVars, dialogFig);
    
    %enable Apply button 
    set(Children.applyButton, 'Enable', 'on');
    
    %if it starts after the error has happened, also enable OK button
    set(Children.okButton, 'Enable', 'on');
    
  case 'Delete'
    %
    % Remove a tunable parameters
    %
    dialogFig = RemoveTunableParam(tunableVars, dialogFig);
  
    %enable Apply button 
    set(Children.applyButton, 'Enable', 'on');
  
  case 'Select'
    %
    % Update edit fields of 'Variable', 'Storage class' & 'Type Qualifier'. 
    %
    dialogFig = UpdateEditField(tunableVars, dialogFig);
    
  case 'EditField'
    %
    % Update the contents of listbox.
    %
    tunableVars = UpdateListboxData( dialogFig );

    %enable Apply button 
    set(Children.applyButton, 'Enable', 'on');

  case 'ReturnKeyOK'
    % if 'Enter' key is hit, then same as cliking 'OK' button
    if (abs(get(dialogFig, 'CurrentChar')) == 13)
      tunable_param_dlg('CallBack', 'OK', dialogFig);
    else
      % no-op
    end
  
  otherwise
    error('Error while executing tunable_param_dlg callbacks.');
    
end

%endfunction


% Function: SaveTunableVars ====================================================
% Abstract:
%      Parsing tunable parameters and save them into three system
%      parameters: TunableVars, TunableVarsStorageClass &
%                  TunableVarsTypeQualifier 
%
function invalidVars = SaveTunableVars( hModel, Children, tunableVars )

invalidVars = [];
%
% Get those three Tunable Parametrs properties:
%
if ~isempty( tunableVars )
  [tunableVars, invalidVars] = UpdateListboxData( Children.dialogFig );

  if ~isempty( invalidVars )
    return;
  end
  
  [tunableVarsName, tunableVarsStorageClass, tunableVarsTypeQualifier] = ...
      TunableParamStrParse(tunableVars);
  
  set_param( hModel, ...
      'TunableVars', tunableVarsName, ...
      'TunableVarsStorageClass', tunableVarsStorageClass, ...
      'TunableVarsTypeQualifier', tunableVarsTypeQualifier ...
    );
else
  %
  % No Tunable Parameters were set up, set parameters to be empty.
  %
  set_param( hModel, ...
      'TunableVars', '', ...
      'TunableVarsStorageClass', '', ...
      'TunableVarsTypeQualifier', '' ...
      );
end

%endfunction


% Function: AddTunableParams ===================================================
% Abstract:
%      Add new tunable parameters into model.
%
function dialogFig = AddTunableParams(tunableVars, dialogFig)

Children = get(dialogFig, 'UserData');
%
% Initialization of 'Add' function.
%
if strcmp(get(Children.varsListbox, 'Enable'), 'off')
  TurnOnOff(Children, tunableVars, 'on');
end

if isempty(tunableVars)
  tunableVars = [  {'||'};    tunableVars ];
elseif ~isempty(tunableVars) & ~strcmp(tunableVars(1), '||')
  tunableVars = [  {'||'};    tunableVars ];
else
  tunableVars = tunableVars;
end

set(Children.varsListbox, ...
    'UserData', tunableVars, ...
    'Value',    1 ...
    );

UpdateListboxString(Children.varsListbox);

UpdateEditField(tunableVars, dialogFig);

%endfunction


% Function: RemoveTunableParam ================================================
% Abstract:
%      Remove a selected tunable parameter.
%
function dialogFig = RemoveTunableParam(tunableVars, dialogFig)

Children = get(dialogFig, 'UserData');

selectedValue = get(Children.varsListbox, 'Value');
[rowNum, tmp] = size(tunableVars);

%
% Re-build the parameters string set.
%
switch selectedValue
  case 1
    tunableVars = tunableVars( 2 : rowNum );
  case rowNum
    tunableVars = tunableVars( 1 : rowNum-1 );
  otherwise
    tunableVars = [tunableVars( 1 : selectedValue-1 ); ...
	  tunableVars( selectedValue+1 : rowNum )]; 
end

set(Children.varsListbox, 'UserData', tunableVars);

if ~isempty(tunableVars)
  
  UpdateListboxString(Children.varsListbox);
  UpdateEditField(tunableVars, dialogFig);
  
else
  %
  % While all parameters are removed, everything should be as default.
  %
  set(Children.varsListbox, 'String', '');
  TurnOnOff(Children, tunableVars, 'off');
end

%endfunction


% Function: UpdateEditField ====================================================
% Abstract:
%      Refresh the edit fields while the selection in listbox is changed.
%      
function dialogFig = UpdateEditField(tunableVars, dialogFig)

Children  = get( dialogFig, 'UserData' );

if isempty(tunableVars)
  TurnOnOff(Children, tunableVars, 'off');
else
  [rowNum, tmp] = size(tunableVars);
  listboxValue  = get(Children.varsListbox, 'Value');
  if rowNum < listboxValue
    set(Children.varsListbox, ...
	'Value',      rowNum);
    listboxValue = rowNum;
  end
  
  varTmp = tunableVars{listboxValue};
  indx   = findstr(varTmp, '|');
  
  %
  % Set varsnameEdit, storagePopup and qualifierEdit to match the listbox
  % selection. 
  %
  set(Children.varsnameEdit, ...
      'String', deblank(varTmp(1:indx(1)-1)) ...
      );
  if ~isempty( get(Children.varsnameEdit, 'String') )
    set(Children.varsnameEdit, 'Enable', 'On');
    set(Children.varsnameText, 'Enable', 'On');
    set(Children.storagePopup, 'Enable', 'On');
    set(Children.storageText,  'Enable', 'On');
  end
  
  popupStr    = get(Children.storagePopup, 'string');
  [rowNum, m] = size(popupStr);
  popupValue  = 1;
  
  for i = 1 : rowNum
    if findstr( lower(popupStr(i,:)), lower(deblank(varTmp( ...
	  indx(1)+1:indx(2)-1 ))) ) 
      popupValue = i;
      break;
    end
  end
  set(Children.storagePopup, 'Value', popupValue);

  if popupValue == 1
    set(Children.qualifierText, 'Enable', 'off');
    set(Children.qualifierEdit, ...
	'Enable',    'off', ...
	'String',    '' ...
	);
  else
    set(Children.qualifierText, 'Enable', 'on');
    set(Children.qualifierEdit, ...
	'Enable',   'on', ...
	'String',   deblank(varTmp( indx(2)+1 : length(varTmp) ) ) ...
	);
  end
  
end

%endfunction


% Function: UpdateListboxString ================================================
% Abstract:
%      Refresh the listbox content while anything in edit field is changed.
%     
function varsListbox = UpdateListboxString( varsListbox )

tunableVars = get(varsListbox, 'UserData');
[rowNum, tmp] = size(tunableVars);

for i = 1 : rowNum

  vars = tunableVars{i};
  indx = findstr(vars, '|');
  
  varsName = vars( 1 : indx(1)-1 );
  if length(varsName) >= 25
    varsName = [varsName(1:24), ' '];
  end
  varsTmp = varsName;
  
  storageClass = vars(indx(1)+1:indx(2)-1);
  varsTmp = [varsTmp, storageClass];
  
  typeQualifier = deblank(vars(indx(2)+1:length(vars)));
  varsTmp = [varsTmp, typeQualifier];

  tunableVars{i} = varsTmp;
end

set(varsListbox, 'String', tunableVars);

%endfunction


% Function: UpdateListboxData ==================================================
% Abstract:
%      Refresh the listbox's userdata while anything in edit field is changed.
%     
function [tunableVars, invalidVars] = UpdateListboxData( dialogFig )

Children    = get( dialogFig, 'UserData' );

tunableVars   = get(Children.varsListbox, 'UserData');
[rowNum, tmp] = size(tunableVars);

listboxValue = get(Children.varsListbox, 'Value');
varTmp = tunableVars{listboxValue};

invalidVars = [];

%
% Get the current variable name, storage class type and type qualifier.
%
varsNameLength = 25;
scLength       = 26;

tunableVarsName = deblankall(get(Children.varsnameEdit, 'String') );

if isempty ( tunableVarsName )
  invalidVars = 1;
  warndlg(['Variable name is empty! Please enter a valid variable name ' ...
	'first.'], 'Tunable parameters Dialog Error', 'modal');
end

%
% To detect if the variable name has been used.
%
for i = 1 : rowNum
  if i ~= listboxValue
    indx = findstr(tunableVars{i}, '|');
    varsTmp = tunableVars{i};
    varsNameTmp = varsTmp(1:indx(1)-1);
    if strcmp(tunableVarsName, deblank(varsNameTmp))
      h=errordlg(['Variable '' ' tunableVarsName  ' '' already exists. ' ...
	    'You cannont use "Add" to modify an existing variable.'], ...
	  'Tunable parameters Dialog Error', 'modal');
      waitfor(h);
      set(Children.varsnameEdit, 'String', '');
      return;
    end
  end
end
if ~validate(tunableVarsName) & ~isempty(tunableVarsName)
  errordlg(['Invalid variable specified: ''' tunableVarsName  '''.'], ...
      'Tunable parameters Dialog Error', 'modal');
  set(Children.varsnameEdit, 'String', '');
  return;
end

if length(tunableVarsName) <= varsNameLength
  tunableVarsName( length(tunableVarsName)+1 : varsNameLength ) = ' ';
else
  tunableVarsName = [tunableVarsName, ' '];
end
varTmp = tunableVarsName;

storagePopup = get(Children.storagePopup, 'Value');
switch storagePopup
  case 1
    tunableVarsStorageClass = 'Auto                      ';
  case 2
    tunableVarsStorageClass = 'ExportedGlobal            ';
  case 3
    tunableVarsStorageClass = 'ImportedExtern            ';
  case 4
    tunableVarsStorageClass = 'ImportedExternPointer     ';
  otherwise
    error('Error while setting the Storage class.');
end
varTmp = [ varTmp, '|', tunableVarsStorageClass ];

if storagePopup == 1
  tunableVarsTypeQualifier = '';
  set(Children.qualifierEdit, ...
      'Enable', 'off', ...
      'String', tunableVarsTypeQualifier ...
      );
  set(Children.qualifierText, 'Enable', 'off');
else
  set(Children.qualifierEdit, 'Enable', 'on');
  set(Children.qualifierText, 'Enable', 'on'); 
 
  tunableVarsTypeQualifier = get(Children.qualifierEdit, 'String');

  if ~isempty(findstr(tunableVarsTypeQualifier, ',') ) & ...
	~isempty(tunableVarsTypeQualifier)
    errordlg( ...
	['Invalid type qualifier specified: ''' ...
	  tunableVarsTypeQualifier '''.'], ...
	'Tunable parameters Dialog Error', 'modal');
    set(Children.qualifierEdit, 'String', '');
    return;
  end
  
end
varTmp = [ varTmp, '|', tunableVarsTypeQualifier ];
  
%
% Construct new set of string as Listbox's content.
%
tunableVars{listboxValue} = varTmp;

%
% Sort all variables in the listbox while we keep the selection on the
% newest variable.
%
tunableVars = sortrows( tunableVars );

for i = 1 : rowNum
  if ~isempty( findstr(tunableVars{i}, varTmp) )
    set(Children.varsListbox, 'Value', i);
  end
end

if ~isempty(tunableVars)
  %
  % Update the userdata of listbox.
  %
  set(Children.varsListbox, 'UserData', tunableVars);
  
  %
  % Update the listbox's string to only display 25 chars varsName.
  %
  UpdateListboxString( Children.varsListbox ); 
end

%endfunction


% Function: TurnOnOff ==========================================================
% Abstract:
%      Turn the associated items ON/OFF.
%
function TurnOnOff(Children, tunableVars, sig)

set(Children.varsListbox,  'Enable',  sig );
set(Children.varsnameText, 'Enable',  sig );
set(Children.varsnameEdit, 'Enable',  sig );
set(Children.storageText,  'Enable',  sig );
set(Children.storagePopup, 'Value',   1,  'Enable', sig );
set(Children.deleteButton, 'Enable',  sig );
  
if strcmp(sig, 'off')
  set(Children.varsListbox,  'String', tunableVars );
  set(Children.varsnameEdit, 'String', [] );
    
  set(Children.qualifierEdit,'String', [], 'Enable', sig ); 
  set(Children.qualifierText,'Enable',sig );
end

%endfunction


% Function: TunableParamStrParse ===============================================
% Abstract:
%      Parse the whole set of string which includes all tunable parameters.
%
function [tunableVarsName, tunableVarsStorageClass, ...
      tunableVarsTypeQualifier] = TunableParamStrParse(tunableVars) 

[numberVars, tmp] = size(tunableVars);

%
% Get those three Tunable Parametrs properties:
%
tunableVarsName          = '';
tunableVarsStorageClass  = '';
tunableVarsTypeQualifier = '';

for i = 1 : numberVars
  varTmp = tunableVars{ i };
  
  indx = findstr(varTmp, '|');
  sep = ',';

  if isempty ( tunableVarsName ) | ( i==1 )
    sep = [];
  end
  
  if ~isempty ( deblank( varTmp( 1 : indx(1)-1 ) ) )
    tunableVarsName          = ...
	[ tunableVarsName, sep, ...
	  deblank( varTmp( 1 : indx(1)-1 ) ) ];
    tunableVarsStorageClass  = ...
	[ tunableVarsStorageClass, sep, ...
	  deblank( varTmp( indx(1)+1 : indx(2)-1 ) ) ];
    tunableVarsTypeQualifier = ...
	[ tunableVarsTypeQualifier, sep, ...
	  deblank( varTmp( indx(2)+1 : length(varTmp) ) ) ];
  end
  
end

%endfunction


% Function: groupbox ===========================================================
% Abstract:
%   GROUPBOX Create a frame with embedded text description.
%   GROUPBOX(fig, pos, string, htextObj), creates a frame and returns a vector 
%     of length 2:
%
%        [hFrame, hText].
%
%     fig      - desired parent of frame
%     pos      - position of frame: [left bottom width height]
%     string   - frame description
%     htextObj - handle of uicontrol text object for use in getting the text 
%                extent of the string.
%
function GroupBox = groupbox(fig, pos, string, htextObj),

GroupBox(2) = 0;  % alloc vector
style = 'frame';

GroupBox(1) = uicontrol( ...
    'Parent',             fig, ...
    'Style',              style, ...
    'Enable',             'inactive', ...
    'Foreground',         [255 251 240]/255, ...
    'Position',           pos ...
    );

ext = get(htextObj, 'Extent');

posText = [
  pos(1) + (ext(3)/length(string))
  pos(2) + pos(4) - (ext(4)/1.75)
  ext(3)
  ext(4)
  ];

GroupBox(2) = uicontrol( ...
    'Parent',             fig, ...
    'Style',              'text', ...
    'String',             string, ...
    'Position',           posText ...
    );
%endfunction


% Function: validate ===========================================================
% Abstract:
%      Detect the valid MATLAB variable.
% 
function valid = validate(var)
eval([var '=[];valid=1;'],'valid=0;')

%endfunction


% Function: DlgName ============================================================
% Abstract:
%      Get the name of a simulink model.
%
function name = DlgName(hModel)

name = ['Model Parameter Configuration: ' get_param(hModel,'name')];

%endfunction


%[eof] tunable_param_dlg.m
