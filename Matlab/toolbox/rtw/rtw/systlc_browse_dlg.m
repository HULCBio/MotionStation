function varargout = systlc_browse_dlg( varargin )
%SYSTLC_BROWSE_DLG Real-Time Workshop System Target File Browser Dialog Box
%   SYSTLC_BROWSE_DLG is called by SIMPRM only.
%
%   See also SYSTLC_BROWSE, SIMPRM.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.33.4.1 $

% Abstract:
%   This functions will locate all system target files that can be seen
%   by Real-Time Workshop and display all of them in a dialog box. If
%   nothing is found, display a message.
%     
%   The dialog consists of five parts:
%
%   description: system target file description
%           tmf: template make file associated with system target file
%       makeCmd: make command
%     shortName: TLC file name
%      fullName: TLC file name including directory path
%
%   When you press the "Browse" button on Simulation parameters dialog
%   Real-Time Workshop page, a dialog window will show up and it lists all
%   system target file with their short name, description. Once you select
%   one, you can see its full path on the bottom of the window.  
%
%   The dialog window is non-modal style. We didn't implement the "Apply" and
%   "Help" button as we are planning to re-design the whole RTW page. Because
%   we don't want to allow user manully change some related items like typing
%   "ert.tlc" in "system target file" editable area, we have to disable some
%   items on RTW page of simprm.
%   Note: this is a temporary solution to get rid of the modal dialog.
%
%   After you select a valid TLC file and close this window, the following
%   item on Real-Time Workshop page will be refreshed:
%     System Target File name, Template makefile name and Make command.
%
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
    % Real-Time Workshop page. From this, we can get the figure handles of:
    %     system target file name -- TargetFileEdit
    %     template makefile name --- MakeFileEdit
    %     make command string ------ MakeCmdEdit
    %
    if nargin > 2
      sysChildren = varargin{3};
      dialogFig   = varargin{4};
    else
      sysChildren = [];
      dialogFig   = -1;
    end
  
    if dialogFig == -1
      %
      % Create the dialog
      %
      dialogFig = CreatePage( hModel, sysChildren );
    
      %
      % Install callbacks.
      %
      InstallCallbacks( dialogFig );
      
    else
      set(dialogFig, 'Visible', 'on');
      systlc_browse_dlg('CallBack', 'Reshow', dialogFig);
    end;
  
    %
    % We have this figure handle as an output so that we might be able to
    % call this function by other functions.
    %
    varargout = { dialogFig };
  
  case 'CallBack'
    %
    % It handles 3 types of callback:
    %     OK button, Cancel button and TLC file selection.
    %
    callBackAction = varargin{2};
    figHandle      = varargin{3};
    
    defaultPointer = get(figHandle, 'Pointer');
    set(figHandle, 'Pointer', 'watch');

    ApplyCallbacks( callBackAction, figHandle );
    
    set(figHandle, 'Pointer', defaultPointer);
    
  case 'ChangeName'
    dialogFig = varargin{2};
    hModel    = varargin{3};
    
    set(dialogFig, 'Name', DlgName(hModel));
    
  otherwise
    %
    % Error out to indicate this function is for simprm.m only right now.
    %
    error(['SYSTLC_BROWSE_DLG.M is called by SIMPRM.M only. To have it' ...
	   ' work with other functions, please look at simprm.m for ' ...
	   'details.']); ...
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
bgcolor  = get(0, 'FactoryUicontrolBackgroundColor');

switch(thisComputer),
  case 'PCWIN',
    listboxFixedFontName = 'Courier new';
    lang = get(0, 'language');
    if strncmp(lang, 'ja', 2)
      listboxFixedFontName = 'FixedWidth';
    end
    listboxFixedFontSize = 9;

  otherwise,  % X-window
    listboxFixedFontName = 'FixedWidth';
    listboxFixedFontSize = 9;
end

hgdeletefcn = 'systlc_browse_dlg(''CallBack'', ''Delete'', gcbf)';
    
%
% Create an empty figure (we need it now for text extents).
%
dialogFig = figure( ...
    'Visible',                            'off', ...
    'DefaultUicontrolHorizontalAlign',    'left', ...
    'DefaultUicontrolFontname',           listboxFixedFontName, ...
    'DefaultUicontrolFontsize',           listboxFixedFontSize, ...
    'HandleVisibility',                   'off', ...
    'Color',                              bgcolor, ...
    'DeleteFcn',                          hgdeletefcn, ...
    'Menubar',                            'none', ...
    'NumberTitle',                        'off', ...
    'Name',                               DlgName(hModel), ...
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
% The positions of figure and each objects are fixed.
%
CtrlPos = CtrlPosition( textExtent );

%
% Create the listbox for TLC's short name and description
%
Children.fileList = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'listbox', ...
    'Position',         CtrlPos.fileList ...
    );

Children.shortNameLabel = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'edit', ...
    'String',           'System target file', ...
    'HorizontalAlign',  'center', ...
    'Enable',           'inactive', ...
    'Position',         CtrlPos.shortNameLabel ...
    );
Children.descripLabel = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'edit', ...
    'String',           'Description', ...
    'HorizontalAlign',  'center', ...
    'Enable',           'inactive', ...
    'Position',         CtrlPos.descripLabel ...
    );

%
% Create directory name and text field
%
Children.dirLabel = uicontrol( ...
    'Parent',       dialogFig, ...
    'Style',        'text', ...
    'String',       ' Selection:', ...
    'Position',     CtrlPos.dirLabel ...
    );
Children.dirField = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'edit', ...
    'Enable',           'inactive', ...
    'Position',         CtrlPos.dirField ...
    );

%
% Create Cancel button
% 
Children.cancelButton = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'pushbutton', ...
    'String',           'Cancel', ...
    'HorizontalAlign',  'center', ...
    'FontName',         get(0,'DefaultUicontrolfontname'), ...
    'Position',         CtrlPos.cancelButton ...
    );

%
% Create OK button
%
Children.okButton = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'pushbutton', ...
    'String',           'OK', ...
    'HorizontalAlign',  'center', ...
    'FontName',         get(0,'DefaultUicontrolfontname'), ...
    'Position',         CtrlPos.okButton ...
    );

%
% Adjust the position of the figure if the sceen size is big enough
%
screenSize = get(0, 'ScreenSize');
if ~isempty(sysChildren)
  if screenSize(4) >= 1024 
    
    simprmPos = get( get(sysChildren.BuildButton, 'Parent'), 'position');
    
    figPosition = get(dialogFig, 'position');
    set(dialogFig, 'Position', ...
                   [figPosition(1) simprmPos(2)-CtrlPos.figHeight ...
                    CtrlPos.figWidth CtrlPos.figHeight ] ...
                   );
    
  else
    figPosition = get(dialogFig, 'position');
    set(dialogFig, 'Position', ...
                   [figPosition(1) figPosition(2)  ...
                    CtrlPos.figWidth CtrlPos.figHeight ] ...
                   );
    
  end
end

%
% Pass Simulation Parameter Real-Time Workshop page's figure handle into
% UserData 
%
Children.sysChildren = sysChildren;
Children.hModel      = hModel;
Children.dialogFig   = dialogFig;

%
% Free some memory
%
CtrlPos     = [];
sysChildren = [];

set(dialogFig, ...
    'UserData', Children ...
    );

%
% Load system target file
%
dialogFig = SysTLCBrowse( dialogFig );

userData = get(dialogFig,'UserData');
if isempty( userData.systlcFile )
  %
  % If no system target file was found, disable the OK button.
  %
  set( userData.okButton, ...
      'Enable',     'off' ...
      );
end

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
%   It has the following items:
%   systlcLabel:  'System Target File'
%   fileList:     display every TLC file with their shortName and description
%   dirLabel:     'Selection:'
%   dirField:     display the fullName(including path) of a selected TLC
%   okButton:     'OK', apply the parameters and close the figure
%   cancelButton: ignore any change and close the figure
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
% Calculate listbox width, it consists of 'System Target File' and
% 'Description'. 'Description' column should be able to display 60 characters.
%
calibrationStr = ' System Target File ';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

shortNameWidth = ext(3);
descripWidth   = 3 * shortNameWidth + 4 * sysOffsets.listbox(3);;

%
% Get the common item's dimensions.
%
textHeight   = charHeight;
editHeight   = charHeight + sysOffsets.edit(4);

buttonHeight = (charHeight*1.3) + sysOffsets.pushbutton(4);
buttonWidth  = buttonWidth + sysOffsets.pushbutton(3);

listboxWidth = shortNameWidth + descripWidth;
listboxHeight = 16 * textHeight + sysOffsets.listbox(4); 

objOffset = 8;
figBuffer = 8;

%
% Set the position of the selected file full name including ite path.
%
calibrationStr = ' Selection:';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

CtrlPos.dirLabel = [ 0  2*figBuffer+buttonHeight  ext(3)  textHeight];

%
% Set the position of the listbox for displaying short name and file
% descriptions.
%
CtrlPos.fileList = [ ...
      figBuffer ...
      CtrlPos.dirLabel(2) + textHeight + objOffset ...
      listboxWidth ...
      listboxHeight ...
      ];

%
% Set the position of 'name' lablel
%
CtrlPos.shortNameLabel = [ ...
      figBuffer ...
      CtrlPos.fileList(2) + CtrlPos.fileList(4) ...
      shortNameWidth ...
      textHeight ...
      ];
%
% Set the position of 'description' lablel
%
CtrlPos.descripLabel = [ ...
      figBuffer + shortNameWidth ...
      CtrlPos.fileList(2) + CtrlPos.fileList(4) ...
      descripWidth ...
      textHeight ...
      ];

%
% Set the figure width
%
CtrlPos.figWidth = 2*figBuffer + listboxWidth;

CtrlPos.dirField = [...
      CtrlPos.dirLabel(3)  ...
      CtrlPos.dirLabel(2)  ...
      CtrlPos.figWidth - CtrlPos.dirLabel(3) - 5 ...
      textHeight];

%
% Set up the position of 'OK' button
% 
CtrlPos.okButton = [ ...
      CtrlPos.figWidth - 2*(buttonWidth+figBuffer) ...
      figBuffer ...
      buttonWidth  ...
      buttonHeight ...
      ];

%
% Set up the position of 'Cancel' button
% 
CtrlPos.cancelButton = [ ...
      CtrlPos.figWidth - buttonWidth - figBuffer ...
      figBuffer ...
      buttonWidth  ...
      buttonHeight ...
      ];

%
% Set the figure height
%
CtrlPos.figHeight = CtrlPos.shortNameLabel(2) ...
    + textHeight + figBuffer;

%endfunction


% Function: InstallCallbacks ===================================================
% Abstract:
%      Set up the callback function for this dialog box.
%
%  okButton: apply the parameters and close the figure.
%    When it's pressed, it will apply the following to the system:
%        set_param(model, 'RTWSystemTargetFile', SELECTED.shortname);
%        set_param(model, 'RTWTemplateMakeFile', SELECTED.tmf);
%        set_param(model, 'RTWMakeCommand', SELECTED.makeCmd);
%    After all these finished, the "Apply" button in simulation parameters 
%    dialog will be enabled. At the end, the Browser window will be closed.
%
%  cancelButton: ignore any change and close the figure.
%   
%  When you selected any TLC file by double click it on the dialog, its full
%  path will be showed on the botton of the window.
%
function dialogFig = InstallCallbacks( dialogFig )

Children  = get( dialogFig, 'UserData');  
dialogFig = Children.dialogFig;

% make the figure's keyboard press function to call 'OK' button
set(dialogFig, 'KeyPressFcn', ...
	       'systlc_browse_dlg(''CallBack'', ''ReturnKeyOK'', gcbf)');

%
% Install callback for 'OK' and 'Cancel' buttton
%
set( Children.okButton, ...
    'Callback',   'systlc_browse_dlg(''CallBack'', ''OK'', gcbf)' ...
    );

set( Children.cancelButton, ...
    'Callback',   'systlc_browse_dlg(''CallBack'', ''Cancel'', gcbf)' ...
    );

set( Children.fileList, ...
    'Callback',   'systlc_browse_dlg(''CallBack'', ''Selection'', gcbf)' ...
    );

%endfunction


% Function: SysTLCBrowse =======================================================
% Abstract:
%      Get the system target file which are available in the system. 
%      It works by calling a C code Mex file SystlcBrowse.c and set the
%      short name and description of TLC files as Children.fileList's string.
%
function dialogFig = SysTLCBrowse( dialogFig )

Children  = get( dialogFig, 'UserData');  
dialogFig = Children.dialogFig;
sysChildren = Children.sysChildren;

if ~isempty(sysChildren)
  TargetFileEdit = sysChildren.TargetFileEdit;
  MakeFileEdit   = sysChildren.MakeFileEdit;
  MakeCmdEdit    = sysChildren.MakeCmdEdit;
end

% 
% Browse whole system to find every system target file.
%
% It will return a structure array with the following structure:
%     field.description
%     field.tmf
%     field.makeCmd
%     field.shortName
%     field.fullName
%
warningState = [warning;  warning('query','backtrace')];
warning off backtrace;
warning on;
errmsg = [];
eval( ...
    ['systlcFile = systlc_browse(matlabroot,path);'], ...
    'errmsg = lasterr;');
warning(warningState);

if (~isempty(errmsg))
  errmsg = ['Error while looking your system for system target file:' errmsg];
  errordlg(errmsg, 'Error','modal');
  return;
end

Children.systlcFile = systlcFile;

if ~isempty(systlcFile)
  %
  % Parsing the string of systlcFile
  %
  tlcListStr = [];
  
  if ~isempty(sysChildren)
    existingTLC = fliplr(deblank(fliplr(deblank(get(TargetFileEdit, 'String')))));
    existingTMF = fliplr(deblank(fliplr(deblank(get(MakeFileEdit, 'String')))));
    existingMCD = fliplr(deblank(fliplr(deblank(get(MakeCmdEdit, 'String')))));
  end
  
  defaultSelectedValue = 1;
  
  for i = 1:length(systlcFile)
    %
    % Select existing TLC file as highlighted
    %
    
    if ~isempty(sysChildren)
      if strcmp(existingTLC, systlcFile(i).shortName) & ...
            strcmp(existingTMF, systlcFile(i).tmf) & ...
            findstr(existingMCD, systlcFile(i).makeCmd)
        defaultSelectedValue = i;
      end
    end
    
    fileListStr = [systlcFile(i).shortName];
    
    %
    % Use the fixed size of string to display both of short name and
    % description in one line of this listbox.
    %
    if length( fileListStr ) <= 21
      fileListStr( length(fileListStr)+1 : 21 ) = ' ';
    elseif length( fileListStr ) > 21 
      fileListStr = [fileListStr(1:20) ' '];
    end;
    
    fileListStr = [ fileListStr systlcFile(i).description ];
    
    tlcListStr = [ tlcListStr; { fileListStr } ];
    
  end

  set(Children.fileList, ...
      'String',         tlcListStr, ...
      'Value',          defaultSelectedValue ...
      );
  
  set(Children.dirField, 'String',           ...
      systlcFile( defaultSelectedValue ).fullName ...
      );
  
  %
  % Free up some memory
  %
  systlcFile  = [];
  tlcListStr  = [];
  fileListStr = [];
  
end

%
% Store data into the figure
%
set(dialogFig, ...
    'UserData',   Children ...
    );

%endfunction


% Function: ApplyCallbacks =====================================================
% Abstract:
%      Execute all of the callbacks for this dialog.
%
function  ApplyCallbacks( action, figHandle );

Children    = get(figHandle, 'UserData');
sysChildren = Children.sysChildren;
hModel      = Children.hModel;
systlcFile  = Children.systlcFile;

if ~isempty(sysChildren)
  TargetFileEdit = sysChildren.TargetFileEdit;
  MakeFileEdit   = sysChildren.MakeFileEdit;
  MakeCmdEdit    = sysChildren.MakeCmdEdit;
  
  simParamFig         = get(sysChildren.TargetFileButton, 'parent');
  simParamUserData    = get(simParamFig, 'UserData');
  rtwPageChildren     = simParamUserData.RTWPage.Children;
  simParamApplyButton = simParamUserData.SystemButtons.Apply;
  
  rtwDisabledItems = [
      rtwPageChildren.TargetFileEdit
      rtwPageChildren.TargetFileLabel
      rtwPageChildren.MakeFileEdit
      rtwPageChildren.MakeFileLabel
      rtwPageChildren.MakeCmdEdit
      rtwPageChildren.MakeCmdLabel
      rtwPageChildren.TargetFileButton
      rtwPageChildren.BuildButton
                     ];
end

if strcmp(action, 'Delete')
  %
  % Delete the figure handle
  %
  if ~isempty(sysChildren)
    set(rtwDisabledItems, 'enable', 'on');
  
    simParamUserData.RTWPage.systlcDlg = -1;
    set(simParamFig, 'UserData', simParamUserData);
  end
  
  delete(figHandle);
  
  return;
end

warningState = [warning; warning('query','backtrace')];
warning off backtrace;
warning on; errmsg = [];
%
% Take care of Options dialog if it's open.
% First, remember the old target file
%
oldTargetFile = get_param(hModel,'RTWSystemTargetFile');

switch action
  
 case 'OK'
  
  %
  % close the browser window.
  %
  set(figHandle, 'Visible', 'off');
  
  if ~isempty(sysChildren)
    preTLCFileSet = [ ...
        get( TargetFileEdit, 'String') ...
        get( MakeFileEdit,   'String') ...
        get( MakeCmdEdit,    'String') ...
                    ];
  else
    preTLCFileSet = [ ...
        '' ...
        '' ...
        '' ...
        ];
  end
  
  listboxIndex = get(Children.fileList, 'Value'); 
  
  currentTLCFileSet = [ ...
      systlcFile( listboxIndex ).shortName ... 
      systlcFile( listboxIndex ).tmf ...
      systlcFile( listboxIndex ).makeCmd ...
		      ];
  
  if ~strcmp ( preTLCFileSet, currentTLCFileSet ) 
    %
    % Set the selected TLC file on Simulation Parameter GUI and in the
    % system.
    %
    if ~isempty(sysChildren)
      set(TargetFileEdit, ...
          'String',     systlcFile( listboxIndex ).shortName );
      set(MakeFileEdit, ...
          'String',     systlcFile( listboxIndex ).tmf );
      set(MakeCmdEdit, ...
	  'String',     systlcFile( listboxIndex ).makeCmd );
    end
    
    %
    % Update Category list to update the code generation options properly.
    %
    if ~isempty(sysChildren)
      simprm('RTWPage', 'TargetFileEdit', get(TargetFileEdit, 'Parent'));

      %
      % Enable the 'Apply' Button.
      %
      if ~isempty (sysChildren.TargetFileButton)
        set( simParamApplyButton, 'Enable', 'on' );
      else
        error('Invalid Simulation parameters Dialog.');
      end
    end
      
  end
    
  %
  % Re-enable the simprm's disabled items
  %
  if ~isempty(sysChildren)
    set(rtwDisabledItems, 'enable', 'on');
  end
  
 case 'Cancel'
  %
  % Re-enable the simprm's disabled items
  %
  if ~isempty(sysChildren)
    set(rtwDisabledItems, 'enable', 'on');
    set(simParamFig, 'UserData', simParamUserData);
    set(figHandle, 'Visible', 'off');
  end
  
 case 'Selection'

  if strcmp(lower(get(figHandle, 'SelectionType')), 'normal')
    %
    % Select system target file
    %
    Children = get( figHandle, 'UserData');
  
    %
    % Get the handles of listbox and directory field.
    %
    fileList = Children.fileList;
    dirField = Children.dirField;
    
    %
    % Get the system target file.
    %
    systlcFile = Children.systlcFile;
    
    listboxIndex = get(fileList, 'Value');
    dirString = systlcFile( listboxIndex ).fullName;
    
    set(dirField, 'String',  dirString );
  elseif strcmp(lower(get(figHandle, 'SelectionType')), 'open')
    systlc_browse_dlg('CallBack', 'OK', figHandle);
  end
  
 case 'ReturnKeyOK'
  % if 'Enter' key is hit, then same as cliking 'OK' button
  if (abs(get(figHandle, 'CurrentChar')) == 13)
    systlc_browse_dlg('CallBack', 'OK', figHandle);
  else
    % no-op
  end 
  
 case 'Reshow'
  figHandle = SysTLCBrowse( figHandle );
 
 otherwise
  error('Error while executing systlc_browse_dlg callbacks.');
  
end

warning(warningState);

% end function


% Function: DlgName ============================================================
% Abstract:
%      Get the name of a simulink model.
%
function name = DlgName(hModel)

name = ['System Target File Browser: ' get_param(hModel,'name')];

% end function


%[eof] systlc_browse_dlg.m



