function varargout = simprm(varargin)
%SIMPRM Simulink Simulation Parameter Dialog Box
%   SIMPRM manages the user interface for the Simulink Simulation Parameter
%   Dialog Box.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.257.4.13 $

Action = varargin{1};
switch(Action)

 case 'create',
  %================================================================
  % Create the dialog.
  %================================================================
  [DialogFig, DialogUserData] = i_Create(varargin{2});

  set_param(DialogUserData.model, 'SimParamHandle', DialogFig);
  set(DialogFig, 'UserData', DialogUserData);
  varargout = {DialogFig};

 case 'SolverPage'
  %================================================================
  % Pass request to SolverPage manager function.
  %================================================================
  DialogFig = varargin{3};
  DialogUserData = get(DialogFig, 'UserData');
  [DialogUserData, bModified] = i_ManageSolverPage(...
      DialogFig, DialogUserData, varargin{2});

  if bModified == 1,
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'WorkspaceIOPage'
  %================================================================
  % Pass request to WorkspaceIOPage manager function.
  %================================================================
  DialogFig = varargin{3};
  DialogUserData = get(DialogFig, 'UserData');
  [DialogUserData, bModified] = i_ManageWorkspaceIOPage(...
      DialogFig, DialogUserData, varargin{2});

  if bModified == 1,
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'DiagnosticsPage'
  %================================================================
  % Pass request to DiagnosticsPage manager function.
  %================================================================
  DialogFig = varargin{3};
  DialogUserData = get(DialogFig, 'UserData');
  [DialogUserData, bModified] = i_ManageDiagnosticsPage(...
      DialogFig, DialogUserData, varargin{2});

  if bModified == 1,
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'AdvancedPage'
  %================================================================
  % Pass request to AdvancedPage manager function.
  %================================================================
  DialogFig = varargin{3};
  DialogUserData = get(DialogFig, 'UserData');
  [DialogUserData, bModified] = i_ManageAdvancedPage(...
      DialogFig, DialogUserData, varargin{2});

  if bModified == 1,
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'RTWPage'
  %================================================================
  % Pass request to RTWPage manager function.
  %================================================================
  DialogFig = varargin{3};

  if ischar(DialogFig)
    %
    % Special case of Stateflow - they pass in the model name
    %
    model          = DialogFig;
    DialogFig      = -1;
    DialogUserData = [];

  elseif ~ishandle(DialogFig)
    %
    % Old way of progamatically hitting the build, ie.,
    % button, the new way is to call rtwbuild    
    %  >>  simprm('RTWPage','Build',-2)
    %
    model          = bdroot;
    DialogFig      = -1;
    DialogUserData = [];

    warningState = [warning; warning('query','backtrace')];
    warning on backtrace;
    warning('Calling simprm to build model is obsolete, use rtwbuild instead.');
    warning(warningState);

  else
    
    DialogUserData = get(DialogFig, 'UserData');
    model = DialogUserData.model;
    
  end

  [DialogUserData, bModified] = i_RTWTargetConfigCallback(...
      DialogFig, DialogUserData, varargin{2}, model);

  if bModified == 1,
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'RTWCategorySwitchAction'
  DialogFig = varargin{2};
  DialogUserData = get(DialogFig, 'UserData');

  %
  % Switch between three different categories on RTW page
  %
  [DialogUserData, bModified] = ...
      i_RTWPageCategorySwitch(DialogFig, DialogUserData);

  if bModified == 1,
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'RTWPageSwitchCategory'
  DialogFig        = varargin{2};
  newCategoryIndex = varargin{3};

  DialogUserData = get(DialogFig, 'UserData');
  categoryPopup = DialogUserData.RTWPage.Children.CategoryPopup;

  if size(get(categoryPopup, 'String'), 1) < newCategoryIndex
    error('No valid category for selection!');
  else
    set(categoryPopup, 'Value', newCategoryIndex);
    simprm('RTWCategorySwitchAction', DialogFig);
  end

 case 'UpdateParamValue'
  % Note:
  % This update should only be done after set_param has finished, so it should
  % not enable Apply button on SIMPRM dialog. This function requires some
  % explicit input arguments. Please don't use it if you are not sure how.
  try
    UpdateParamValue(varargin{2:end});
  catch
    error('Invalid synchronization on Simulation Parameters dialog.');
  end

 case 'SystemButtons'
  %================================================================
  % Pass request to System buttons(apply...) manager function.
  %================================================================
  DialogFig = varargin{3};
  DialogUserData = get(DialogFig, 'UserData');
  i_ManageSystemButtons(DialogFig, DialogUserData, varargin{2});

 case 'tabcallbk',
  %================================================================
  % Request to change pages.
  %================================================================
  DialogFig = varargin{6};
  DialogUserData = get(DialogFig, 'UserData');

  [DialogUserData, bModified] = ...
      i_ChangePage(varargin{2:5}, DialogFig, DialogUserData);

  if bModified == 1,
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'EnableApply'
  %================================================================
  % Public access to i_EnableApply.
  %================================================================
  DialogFig = varargin{2};
  DialogUserData = get(DialogFig, 'UserData');
  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

  if (bModified == 1)
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'show',
  %================================================================
  % Make an existing dialog visible.
  %================================================================
  DialogFig = varargin{2};
  DialogUserData = get(DialogFig, 'UserData');

  [DialogUserData, bModified] = ...
      i_ReShowDialog(DialogFig, DialogUserData,0);

  if (bModified == 1)
    set(DialogFig, 'UserData', DialogUserData);
  end

 case {'SimStart','SimStop'},
  %================================================================
  % Update the dialog for start of sim: simprm('SimStart',hFig)
  %================================================================
  DialogFig = varargin{2};

  if ~ishandle(DialogFig) || ~onoff(get(DialogFig,'Visible')),
    return
  end

  DialogUserData = get(DialogFig, 'UserData');

  [DialogUserData, bModified] = ...
      i_SimStartStop(DialogFig, DialogUserData, Action);

  if (bModified == 1)
    set(DialogFig, 'UserData', DialogUserData);
  end


 case 'ChangeName',
  %==================================================================
  % Message from Simulink that the bd has changed names.
  %==================================================================
  DialogFig = varargin{2};
  DialogUserData = get(DialogFig, 'UserData');

  set(DialogFig, 'Name', i_DlgName(gcs));

  if ~isempty(DialogUserData.RTWPage.Children)
    if DialogUserData.RTWPage.systlcDlg ~= -1
      systlc_browse_dlg('ChangeName', ...
			DialogUserData.RTWPage.systlcDlg, gcs);
    end
  end
  if ~isempty(DialogUserData.AdvancedPage.Children)
    if usejava('MWT')
      if ishandle(DialogUserData.AdvancedPage.ParamAttrDlg)
	slwsprmattrib('ChangeName', ...
		      gcs, ...
		      DialogUserData.AdvancedPage.ParamAttrDlg);
      end
    else
      if DialogUserData.AdvancedPage.ParamAttrDlg ~= -1
	tunable_param_dlg('changename', ...
			  DialogUserData.AdvancedPage.ParamAttrDlg, gcs);
      end
    end
  end

 case 'FigDeleteFcn',
  %
  % When the figure is deleted, make sure to delete all opened figures that
  % are associated with simprm.
  %
  DialogFig = varargin{2};
  DialogUserData = get(DialogFig, 'UserData');

  if ~isempty(DialogUserData.RTWPage.Children)
    if DialogUserData.RTWPage.systlcDlg ~= -1
      delete(DialogUserData.RTWPage.systlcDlg);
    end
  end
  if ~isempty(DialogUserData.AdvancedPage.Children)
    if usejava('MWT')
      if ishandle(DialogUserData.AdvancedPage.ParamAttrDlg)
	hd = findobj(allchild(0), 'Title', ...
		     get(DialogUserData.AdvancedPage.ParamAttrDlg,'Title'));
	DialogUserData.AdvancedPage.ParamAttrDlg.dispose;
	if ishandle(hd)
	  delete(hd);
	end
	setappdata(0, get_param(DialogUserData.model,'Name'), '');
	rmappdata(0, get_param(DialogUserData.model,'Name') );
      end
    else
      if DialogUserData.AdvancedPage.ParamAttrDlg ~= -1
	delete(DialogUserData.AdvancedPage.ParamAttrDlg);
      end
    end
  end

  % also set the SimParamHandle to be -1
  set_param(DialogUserData.model, 'SimParamHandle', -1);

 otherwise,
  %================================================================
  % Bogus action.
  %================================================================
  error('Invalid action');

end

% end function simprm


%%%%%%%%%%%%%%%%%%%%%%%%%%%% Common functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% function [DialogFig, DialogUserData] = i_Create(hModel)                     %
% function DialogUserData = i_CreateSysButtons(DialogFig, DialogUserData)     %
% function DialogUserData = i_CreatePage(page, DialogFig, DialogUserData)     %
% function i_ManageSystemButtons(DialogFig, DialogUserData, Action)           %
% function [DialogUserData, bModified] = i_ChangePage( ... )                  %
% function i_InstallSystemButtonCallbacks(DialogFig, DialogUserData)          %
% function i_InstallCallbacks(page, DialogFig, DialogUserData)                %
% function [DialogUserData, bModified] = i_ApplyParams(DialogFig,             %
%                                                     DialogUserData)         %
% function i_EnableApply(DialogUserData)                                      %
% function commonGeom = i_CreateCommonGeom(textExtent)                        %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%******************************************************************************
% Function - Create the dialog box.                                         ***
%******************************************************************************
function [DialogFig, DialogUserData] = i_Create(hModel)

%
% Create constants based on current computer.
%

thisComputer = computer;

fontsize = get(0, 'FactoryUicontrolFontSize');
fontname = get(0, 'FactoryUicontrolFontName');

switch(thisComputer)
  case 'PCWIN',
    DialogUserData.popupBackGroundColor = 'w';
    dividingLineStyle     = 'pushbutton';
    dividingLineThickness = 4;
    listboxFixedFontName  = 'Courier new';
    listboxFixedFontSize  = 9;
    lang = get(0, 'language');
    if strncmp(lang, 'ja', 2)
      listboxFixedFontName = 'FixedWidth';
	  listboxFixedFontSize  = 12;
    end


  case 'MAC2',
    DialogUserData.popupBackGroundColor = 'w';
    dividingLineStyle     = 'frame';
    dividingLineThickness = 3;
    listboxFixedFontName  = 'Courier';
    listboxFixedFontSize  = 10;

  otherwise,  % X
    DialogUserData.popupBackGroundColor = get(0, ...
	'FactoryUicontrolBackgroundColor');
    dividingLineStyle     = 'pushbutton';
    dividingLineThickness = 4;
    listboxFixedFontName  = 'FixedWidth';
    listboxFixedFontSize  = 9;
end


%
% Create an empty figure (we need it now for text extents).
%

DialogFig = figure( ...
    'Visible',                            'off', ...
    'DefaultUicontrolHorizontalAlign',    'left', ...
    'DefaultUicontrolFontname',           fontname, ...
    'DefaultUicontrolFontsize',           fontsize, ...
    'DefaultUicontrolUnits',              'pixels', ...
    'HandleVisibility',                   'off', ...
    'Colormap',                           [], ...
    'Name',                               i_DlgName(hModel), ...
    'IntegerHandle',                      'off', ...
    'DeleteFcn',                          ...
    'simprm(''FigDeleteFcn'', gcbf)',     ...
    'CloseRequestFcn',                    ...
    'simprm(''SystemButtons'', ''Cancel'', gcbf)' ...
    );

%
% Create a text object for text sizing.
%

textExtent = uicontrol( ...
    'Parent',     DialogFig, ...
    'Visible',    'off', ...
    'Style',      'text', ...
    'FontSize',   fontsize, ...
    'FontName',   fontname ...
    );

%
% Construct common geometry constants.
%

commonGeom                      = i_CreateCommonGeom(textExtent);
commonGeom.textExtent           = textExtent;
commonGeom.listboxFixedFontName = listboxFixedFontName;
commonGeom.listboxFixedFontSize = listboxFixedFontSize;
commonGeom.dividingLineStyle    = dividingLineStyle;
commonGeom.lineThickness        = dividingLineThickness;

%
% Calculate positions and extents for ctrls on solver page.
% This page is the largest and is used for sizing the figure.
%

solverGeom = i_CreateSolverGeom(commonGeom);
[sheetDims, solverCtrlPos] = i_solverCtrlPositions( ...
    commonGeom, solverGeom ...
    );

%
% Set callback and offsets for tabdlg.
%

callback  = 'simprm';
offsets   = [
  commonGeom.figSideEdgeBuffer
  commonGeom.figTopEdgeBuffer
  commonGeom.figSideEdgeBuffer
  commonGeom.bottomSheetOffset
  ];


%
% ...determine default page..
%
% NOTE: Internally the page name is stored as an enumstr which
%   does not allow white space in a string.  As such, the
%   internal versions of the tab names are deblanked.
%

[defaultPageNum, defaultPageName] = ...
    i_inName2extName(loc_getSimParamPage(hModel));


%
% Calculate tab dimensions and handle other tasks associated with
% optional RTW page.
%
if strcmp(get_param(0,'RTWLicensed'),'on')
  tabStrings = {'Solver', 'Workspace I/O', 'Diagnostics', 'Advanced', ...
		'Real-Time Workshop'};
else
  tabStrings = {'Solver', 'Workspace I/O', 'Diagnostics', 'Advanced'};

  if (defaultPageNum > 4)
    % Real-Time Workshop not licensed - can't show this page

    defaultPageNum  = 1;
    defaultPageName = 'Solver';
  end
end

if (defaultPageNum > 5)
  %
  % M-file corrupt - can't show this page
  %
  defaultPageNum  = 1;
  defaultPageName = 'Solver';
end

% ... tab dimensions

nTabs = length(tabStrings);
widths(nTabs) = 0;

for i=1:nTabs,
  set(textExtent, 'String', tabStrings{i});
  ext = get(textExtent, 'Extent');
  widths(i) = ext(3) + 6;
end

height  = ext(4) + 4;
tabDims = {widths, height};


%
% ... create it.
%

[DialogFig, sheetPos] = tabdlg('create', ...
    tabStrings, ...
    tabDims, ...
    callback, ...
    sheetDims, ...
    offsets, ...
    defaultPageNum, ...
    {}, ...
    DialogFig ...
    );

commonGeom.sheetPos = sheetPos;


%
% Create initial user data.
%
DialogUserData.model                         = hModel;
DialogUserData.commonGeom                    = commonGeom;
DialogUserData.solverCtrlPos                 = solverCtrlPos;
DialogUserData.tabStrings                    = tabStrings;
DialogUserData.workspaceIOCtrlPos            = [];
DialogUserData.diagnosticsCtrlPos            = [];
DialogUserData.advancedCtrlPos               = [];
DialogUserData.RTWCtrlPos                    = [];
DialogUserData.SolverPage.Children           = [];
DialogUserData.WorkspaceIOPage.Children      = [];
DialogUserData.DiagnosticsPage.Children      = [];
DialogUserData.AdvancedPage.Children         = [];
DialogUserData.RTWPage.Children              = [];

DialogUserData.solverLists = {
  {'VariableStepDiscrete', ...          % Variable step
	'ode45', 'ode23', 'ode113', 'ode15s', 'ode23s', 'ode23t', 'ode23tb'}
  {'FixedStepDiscrete', ...             % Fixed step
	'ode5', 'ode4', 'ode3', 'ode2', 'ode1'}
  };

DialogUserData.ExternalSolverLists = { ...
  ... % Variable step
  { ...
    'discrete (no continuous states)', ...
    'ode45 (Dormand-Prince)', ...
    'ode23 (Bogacki-Shampine)', ...
    'ode113 (Adams)', ...
    'ode15s (stiff/NDF)', ...
    'ode23s (stiff/Mod. Rosenbrock)' ...
    'ode23t (mod. stiff/Trapezoidal)' ...
    'ode23tb (stiff/TR-BDF2)' ...
    } ...
  ... % Fixed step
  { ...
    'discrete (no continuous states)', ...
    'ode5 (Dormand-Prince)', ...
    'ode4 (Runge-Kutta)', ...
    'ode3 (Bogacki-Shampine)', ...
    'ode2 (Heun)', ...
    'ode1 (Euler)' ...
    } ...
  };

DialogUserData.SolverPage.solverTypes  = {'Variable-step', 'Fixed-step'};
DialogUserData.SolverPage.oldSolverNum = [-1 -1];

DialogUserData.SolverPage.OutputTimesEditLabels = {
  'Refine factor:  '
  'Output times:  '
  'Output times:  '
  };

%
% These are just "no white-space" versions of the external names
% for storing as an internal enumstr (white space not allowed!).
%
DialogUserData.InternalPageNames = ...
    {'Solver', 'WorkspaceI/O', 'Diagnostics', 'Optimization', 'RTW'};

DialogUserData.CurrentPageNum = defaultPageNum;

DialogUserData.thisComputer = thisComputer;


%
% Create default page.
%

DialogUserData = i_CreatePage(defaultPageName, DialogFig, DialogUserData);


%
% Create "system" buttons.
%

DialogUserData = i_CreateSysButtons(DialogFig, DialogUserData);


%
% Main portions of fig are created.
%

set(DialogFig, 'Visible', 'on');

%
% Install callbacks.
%

i_InstallCallbacks(defaultPageName, DialogFig, DialogUserData);
i_InstallCallbacks('System', DialogFig, DialogUserData);

% end i_Create()

%******************************************************************************
% Function - Create "system" buttons.                                       ***
%******************************************************************************
function DialogUserData = i_CreateSysButtons(DialogFig, DialogUserData)

figPos      = get(DialogFig, 'Position');
commonGeom  = DialogUserData.commonGeom;
sheetPos    = commonGeom.sheetPos;
width       = commonGeom.sysButtonWidth;
height      = commonGeom.sysButtonHeight;
buttonDelta = commonGeom.sysButtonDelta;

totalButtonWidth = (width * 4) + (buttonDelta * 3);
sheetEdge = sheetPos(1) + sheetPos(3);

cxCur = sheetEdge - totalButtonWidth;
cyCur = commonGeom.figBottomEdgeBuffer;


%==============================================================================
% Place ok button.
%==============================================================================
Children.OK = uicontrol( ...
    'Parent',             DialogFig, ...
    'String',             'OK', ...
    'Horizontalalign',    'center', ...
    'Position',           [cxCur cyCur width height] ...
    );

%==============================================================================
% Place cancel button.
%==============================================================================
cxCur = cxCur + width + buttonDelta;
Children.Cancel = uicontrol( ...
    'Parent',             DialogFig, ...
    'String',             'Cancel', ...
    'Horizontalalign',    'center', ...
    'Position',           [cxCur cyCur width height] ...
    );

%==============================================================================
% Place help button.
%==============================================================================
cxCur = cxCur + width + buttonDelta;
Children.Help = uicontrol( ...
    'Parent',             DialogFig, ...
    'String',             'Help', ...
    'Horizontalalign',    'center', ...
    'Enable',             'on', ...
    'Position',           [cxCur cyCur width height] ...
    );

%==============================================================================
% Place apply button.
%==============================================================================
cxCur = cxCur + width + buttonDelta;
Children.Apply = uicontrol( ...
    'Parent',             DialogFig, ...
    'String',             'Apply', ...
    'Horizontalalign',    'center', ...
    'Enable',             'off', ...
    'Position',           [cxCur cyCur width height] ...
    );

%==============================================================================
% Update user data.
%==============================================================================
DialogUserData.SystemButtons = Children;

% end i_CreateSysButtons()


%******************************************************************************
% Function - Create specified tab page.                                     ***
%******************************************************************************
function DialogUserData = i_CreatePage(page, DialogFig, DialogUserData)

if strcmp(get(DialogFig, 'Visible'), 'on')
  set(DialogFig, 'DefaultUicontrolVisible', 'off');
end

switch(page)

  case 'Solver',
    DialogUserData = i_CreateSolverPage(DialogFig, DialogUserData);
    [DialogUserData, notused] = i_SyncSolverPage(DialogFig, DialogUserData,1);

  case 'Workspace I/O',
    DialogUserData = i_CreateWorkspaceIOPage(DialogFig, DialogUserData);
    i_SyncWorkspaceIOPage(DialogUserData,1);

  case 'Diagnostics',
    DialogUserData = i_CreateDiagnosticsPage(DialogFig, DialogUserData);
    DialogUserData = i_SyncDiagnosticsPage(DialogFig,DialogUserData,1);

  case 'Optimization',
    DialogUserData = i_CreateAdvancedPage(DialogFig, DialogUserData);
    DialogUserData = i_SyncAdvancedPage(DialogFig,DialogUserData,1);

  case 'RTW'
    DialogUserData = i_CreateRTWPage(DialogFig, DialogUserData);
    DialogUserData = i_SyncRTWPage(DialogUserData,1);

  otherwise,
    error('Invalid page');

end

set(DialogFig, 'DefaultUicontrolVisible', 'on');

%
% Free up some memory.
%

% xxx I think that at the end of each page creation, I can free up
%     the page specific geom (except for solver!).
%

if ~isempty(DialogUserData.SolverPage.Children)      && ...
      ~isempty(DialogUserData.WorkspaceIOPage.Children) && ...
      ~isempty(DialogUserData.DiagnosticsPage.Children) && ...
      ~isempty(DialogUserData.AdvancedPage.Children) && ...
      ~isempty(DialogUserData.RTWPage.Children)

  %delete(DialogUserData.commonGeom.textExtent);
  %DialogUserData.commonGeom = [];
end

% end i_CreatePage()


%******************************************************************************
% Function - Manage callbacks for system buttons.                           ***
%******************************************************************************
function i_ManageSystemButtons(DialogFig, DialogUserData, Action)

switch(Action)

 case 'Apply',

  [DialogUserData, bModified] = i_ApplyParams(DialogFig, DialogUserData);
  set(DialogUserData.SystemButtons.Apply, 'Enable', 'off');
  % evaluate codegen options' close callback function, if any
  if ~isempty(DialogUserData.RTWPage.Children)
    DialogUserData = CallOptionsCloseCallback(DialogUserData);
    bModified = 1;
  end

  if bModified,
    set(DialogFig, 'UserData', DialogUserData);
  end

 case 'Cancel',

  set(DialogFig, 'Visible', 'off');
  set(DialogUserData.SystemButtons.Apply, 'Enable', 'off');

  if ~isempty(DialogUserData.RTWPage.Children)
    if DialogUserData.RTWPage.systlcDlg ~= -1
      delete(DialogUserData.RTWPage.systlcDlg);
      DialogUserData.RTWPage.systlcDlg = -1;
    end
  end
  if ~isempty(DialogUserData.AdvancedPage.Children)
    if usejava('MWT')
      if ishandle(DialogUserData.AdvancedPage.ParamAttrDlg)
	hd = findobj(allchild(0), 'Title', ...
		     get(DialogUserData.AdvancedPage.ParamAttrDlg,'Title'));
	DialogUserData.AdvancedPage.ParamAttrDlg.setVisible(0);
	DialogUserData.AdvancedPage.ParamAttrDlg.dispose;
      end
    else
      if DialogUserData.AdvancedPage.ParamAttrDlg ~= -1
	delete(DialogUserData.AdvancedPage.ParamAttrDlg);
	DialogUserData.AdvancedPage.ParamAttrDlg = -1;
      end
    end
  end
  set( DialogFig, 'UserData', DialogUserData);

 case 'OK',

  set(DialogFig, 'Visible', 'off');
  [DialogUserData, bModified] = i_ApplyParams(DialogFig, DialogUserData);
  set(DialogUserData.SystemButtons.Apply, 'Enable', 'off');

  loc_setSimParamPage(DialogUserData.model,...
                      DialogUserData.InternalPageNames{DialogUserData.CurrentPageNum});

  if ~isempty(DialogUserData.RTWPage.Children)
    if DialogUserData.RTWPage.systlcDlg ~= -1
      delete(DialogUserData.RTWPage.systlcDlg);
      DialogUserData.RTWPage.systlcDlg = -1;
    end
  end
  if ~isempty(DialogUserData.AdvancedPage.Children)
    if usejava('MWT')
      if ishandle(DialogUserData.AdvancedPage.ParamAttrDlg)
	hd = findobj(allchild(0), 'Title', ...
		     get(DialogUserData.AdvancedPage.ParamAttrDlg,'Title'));
	DialogUserData.AdvancedPage.ParamAttrDlg.dispose;
      end
    else
      if DialogUserData.AdvancedPage.ParamAttrDlg ~= -1
	delete(DialogUserData.AdvancedPage.ParamAttrDlg);
	DialogUserData.AdvancedPage.ParamAttrDlg = -1;
      end
    end
  end

  % evaluate codegen options' close callback function, if any
  if ~isempty(DialogUserData.RTWPage.Children)
    DialogUserData = CallOptionsCloseCallback(DialogUserData);
  end
  set( DialogFig, 'UserData', DialogUserData);

 case 'Help',
    if (DialogUserData.CurrentPageNum > 4)
      helpview([docroot,'/mapfiles/rtw_ug.map'], 'rtw_ui_overview');
    else
      helpview([docroot '/mapfiles/simulink.map'], 'simparamdialog');
    end

 case 'ReturnKeyOK'
  % if 'Enter' key is hit, then same as clicking 'OK' button
  if ~isempty(get(DialogFig, 'CurrentChar')) % unix keyboard has an empty key
    if (abs(get(DialogFig, 'CurrentChar')) == 13)
      simprm('SystemButtons', 'OK', DialogFig);
    else
      % no-op
    end
  end

 otherwise,

  error('Invalid action');

end %switch

% end i_ManageSystemButtons()


%******************************************************************************
% Function - Process change page event.                                     ***
%                                                                           ***
% This is not well organized.  It should be designed as callbacks for each  ***
%  page (e.g., SolverPageOffFcn gets called when the page is going away).   ***
%******************************************************************************
function [DialogUserData, bModified] = i_ChangePage( ...
    pressedTabString, ...
    pressedTabNum, ...
    oldTabString, ...
    oldTabNum, ...
    DialogFig, ...
    DialogUserData ...
    )

bModified = 0;

%==============================================================================
% Determine which controls to make visible based on page number.
%==============================================================================
switch(pressedTabNum)

 case 1,
  if isempty(DialogUserData.SolverPage.Children)
    page = 'Solver';

    DialogUserData = i_CreatePage(page, DialogFig, DialogUserData);
    i_InstallCallbacks(page, DialogFig, DialogUserData);
    bModified = 1;

  end

  pressedChildren = DialogUserData.SolverPage.Children;

  % Handles of everything, but the options ctrls.  These must be handled
  %  separately as they depend on more than just the current page.
  ChildrenVector = [
      pressedChildren.SimulationTimeGroupBox'
      pressedChildren.StartTimeLabel
      pressedChildren.StartTimeEdit
      pressedChildren.StopTimeLabel
      pressedChildren.StopTimeEdit
      pressedChildren.IntegratorGroupBox'
      pressedChildren.TypeLabel
      pressedChildren.TypePopup
      pressedChildren.SolverPopup
      pressedChildren.Line
      pressedChildren.OutputGroupBox'
      pressedChildren.OutputOptionPopup
      pressedChildren.RefineLabel
      pressedChildren.RefineEdit
		   ];

 case 2,
  if isempty(DialogUserData.WorkspaceIOPage.Children)
    page = 'Workspace I/O';

    DialogUserData = i_CreatePage(page, DialogFig, DialogUserData);
    i_InstallCallbacks(page, DialogFig, DialogUserData);
    bModified = 1;
  end

  ChildrenCell   = struct2cell(DialogUserData.WorkspaceIOPage.Children);
  ChildrenVector = [ChildrenCell{:}];

 case 3,
  if isempty(DialogUserData.DiagnosticsPage.Children)
    page = 'Diagnostics';

    DialogUserData = i_CreatePage(page, DialogFig, DialogUserData);
    i_InstallCallbacks(page, DialogFig, DialogUserData);
    bModified = 1;
  end

  ChildrenCell   = struct2cell(DialogUserData.DiagnosticsPage.Children);
  ChildrenVector = [ChildrenCell{:}];

 case 4,
  if isempty(DialogUserData.AdvancedPage.Children)
    page = 'Optimization';

    DialogUserData = i_CreatePage(page, DialogFig, DialogUserData);
    i_InstallCallbacks(page, DialogFig, DialogUserData);
    bModified = 1;
  end

  ChildrenCell   = struct2cell(DialogUserData.AdvancedPage.Children);
  ChildrenVector = [ChildrenCell{:}];

 case 5,
  if isempty(DialogUserData.RTWPage.Children)
    page = 'RTW';

    DialogUserData = i_CreatePage(page, DialogFig, DialogUserData);
    i_InstallCallbacks(page, DialogFig, DialogUserData);
    bModified = 1;
  end

  %
  % Need to use the category popup information to determine which
  % category to save.
  %
  ChildrenVector = [
      DialogUserData.RTWPage.Children.CategoryLabel
      DialogUserData.RTWPage.Children.CategoryPopup
      DialogUserData.RTWPage.Children.BuildButton
      DialogUserData.RTWPage.Children.DividingLine
		   ];

  val = get(DialogUserData.RTWPage.Children.CategoryPopup, 'Value');
  if val == 1
    ChildrenVector = [ChildrenVector
		      DialogUserData.RTWPage.Children.TargetHdl];
  elseif val == 2
    ChildrenVector = [ChildrenVector
		      DialogUserData.RTWPage.Children.TLCDebugHdl];
  else
    % on code generation options category
    if val > 2 && (val-2) <= DialogUserData.RTWPage.Children.NumOfCategoryItems
      eval(['hdl = DialogUserData.RTWPage.Children.CodeGenHdl' ...
	    num2str(val-2) ';']);
      ChildrenVector = [ChildrenVector
			hdl];
    else
      error('M-file assert!');
    end
  end
end


%==============================================================================
% Determine which controls to make invisible base on page number.
%==============================================================================
switch(oldTabNum)

 case 1,
  oldChildrenCell   = struct2cell(DialogUserData.SolverPage.Children);
  oldChildrenVector = [oldChildrenCell{:}];

 case 2,
  oldChildrenCell   = struct2cell(DialogUserData.WorkspaceIOPage.Children);
  oldChildrenVector = [oldChildrenCell{:}];

 case 3,
  oldChildrenCell   = struct2cell(DialogUserData.DiagnosticsPage.Children);
  oldChildrenVector = [oldChildrenCell{:}];

 case 4,
  oldChildrenCell   = struct2cell(DialogUserData.AdvancedPage.Children);
  oldChildrenVector = [oldChildrenCell{:}];

 case 5,
  %
  % Need to use the category popup information to determine
  % which category to save.
  %
  oldChildrenVector = [
      DialogUserData.RTWPage.Children.CategoryLabel
      DialogUserData.RTWPage.Children.CategoryPopup
      DialogUserData.RTWPage.Children.BuildButton
      DialogUserData.RTWPage.Children.DividingLine
		      ];

  val = get(DialogUserData.RTWPage.Children.CategoryPopup, 'Value');
  if val == 1
    oldChildrenVector = [oldChildrenVector
		    DialogUserData.RTWPage.Children.TargetHdl];
  elseif val == 2
    oldChildrenVector = [oldChildrenVector
		    DialogUserData.RTWPage.Children.TLCDebugHdl];
  else
    % on code generation options category
    if val > 2 && (val-2) <= DialogUserData.RTWPage.Children.NumOfCategoryItems
      eval(['hdl = DialogUserData.RTWPage.Children.CodeGenHdl' ...
	    num2str(val-2) ';']);
      oldChildrenVector = [oldChildrenVector
		    hdl];
    else
      error('M-file assert!');
    end
  end

end

%==============================================================================
% Toggle page visibility (default behavior).
%==============================================================================
set(oldChildrenVector, 'Visible', 'off');
set(ChildrenVector, 'Visible', 'on');

DialogUserData.CurrentPageNum = pressedTabNum;
loc_setSimParamPage(DialogUserData.model, ...
                    DialogUserData.InternalPageNames{DialogUserData.CurrentPageNum});
bModified = 1;

%==============================================================================
% Finish tasks that are specific to each page.
%==============================================================================
switch(pressedTabNum)

  case 1,
    solverPopup = pressedChildren.SolverPopup;
    solverNum   = get(solverPopup, 'Value');

    typeNum = get(pressedChildren.TypePopup, 'Value');
    solver  = DialogUserData.solverLists{typeNum}{solverNum};

    i_ShowRelevantOptions(DialogFig, DialogUserData, solver);

 case { 2, 3, 4, 5}
     % no special handling required

  case 6,
    i_UpdateChangesPendingIndicator(DialogFig, DialogUserData);
end

%
% Make sure that the page is in the right configuration for the
% simulation status
%
[DialogUserData, bModified] = ...
    i_SimStartStop(DialogFig, DialogUserData, 'PageChange');

set(DialogFig, 'UserData', DialogUserData);

% end i_ChangePage()


%******************************************************************************
% Function - Install callbacks for system buttons.                          ***
%******************************************************************************
function i_InstallSystemButtonCallbacks(DialogFig, DialogUserData)

% make the figure's keyboard press function to call 'OK' button
set(DialogFig, 'KeyPressFcn', ...
	       'simprm(''SystemButtons'', ''ReturnKeyOK'', gcbf)');

set(DialogUserData.SystemButtons.OK, ...
    'Callback',   'simprm(''SystemButtons'', ''OK'', gcbf)' ...
    );

set(DialogUserData.SystemButtons.Cancel, ...
    'Callback',   'simprm(''SystemButtons'', ''Cancel'', gcbf)' ...
    );

set(DialogUserData.SystemButtons.Apply, ...
    'Callback',   'simprm(''SystemButtons'', ''Apply'', gcbf)' ...
    );

set(DialogUserData.SystemButtons.Help, ...
    'Callback',   'simprm(''SystemButtons'', ''Help'', gcbf)' ...
    );

% end i_InstallSystemButtonCallbacks()


%******************************************************************************
% Function - Install callbacks for specified page.                          ***
%******************************************************************************
function i_InstallCallbacks(page, DialogFig, DialogUserData)

switch(page)

  case 'Solver',
    i_InstallSolverCallbacks(DialogFig, DialogUserData);

  case 'Workspace I/O',
    i_InstallWorkspaceIOCallbacks(DialogFig, DialogUserData);

  case 'Diagnostics',
    i_InstallDiagnosticsCallbacks(DialogFig, DialogUserData);

  case 'Optimization',
    i_InstallAdvancedCallbacks(DialogFig, DialogUserData);

  case 'RTW',
    i_InstallRTWCallbacks(DialogFig, DialogUserData);

  case 'System',
    i_InstallSystemButtonCallbacks(DialogFig, DialogUserData);

  otherwise,
    error('Invalid page');

end

% end i_InstallCallbacks()


%******************************************************************************
% Function - apply params to model.
%******************************************************************************
function [DialogUserData, bModified] = i_ApplyParams(DialogFig, DialogUserData)

bModified = 0;
model = DialogUserData.model;
propValPairs = {};

%==============================================================================
% Solver page property value pairs.
%==============================================================================
if ~isempty(DialogUserData.SolverPage.Children)
  propValPairs = [propValPairs i_SolverPropValPairs(DialogUserData)];
end

%==============================================================================
% Workspace I/O page property value pairs.
%==============================================================================
if ~isempty(DialogUserData.WorkspaceIOPage.Children)
  propValPairs = [propValPairs i_WorkspaceIOPropValPairs(DialogUserData)];
end


%==============================================================================
% Diagnostics page property value pairs.
%==============================================================================
if ~isempty(DialogUserData.DiagnosticsPage.Children)
  propValPairs = [propValPairs i_DiagnosticsPropValPairs(DialogUserData)];
end

%==============================================================================
% Advanced page property value pairs.
%==============================================================================
if ~isempty(DialogUserData.AdvancedPage.Children)
  propValPairs = [propValPairs i_AdvancedPropValPairs(DialogUserData)];
end

%==============================================================================
% Real-Time Workshop page property value pairs.
%==============================================================================
if ~isempty(DialogUserData.RTWPage.Children)
  propValPairs = [propValPairs i_RTWPropValPairs(DialogUserData)];
end

%==============================================================================
% Set all propval pairs.
%==============================================================================
loc_setParams(model, propValPairs);
 
DialogUserData = get(DialogFig, 'UserData');

% end i_ApplyParams()


%******************************************************************************
% FUNCTION: Enable the Apply button.                                        ***
%******************************************************************************
function [DialogUserData,bModified] = i_EnableApply(DialogUserData)

bModified = 0;
hApply    = DialogUserData.SystemButtons.Apply;

set(hApply, 'Enable', 'on');

% end i_EnableApply()


%******************************************************************************
% Function - Create common geometry constants.                              ***
%******************************************************************************
function commonGeom = i_CreateCommonGeom(textExtent)

sysOffsets = sluigeom;

%
% Define generic font characterists.
%
calibrationStr = '_Revert_';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

sysButtonWidth = ext(3);
charHeight     = ext(4);

commonGeom.textHeight            = charHeight;
commonGeom.editHeight            = charHeight + sysOffsets.edit(4);
commonGeom.checkboxHeight        = charHeight + sysOffsets.checkbox(4);
commonGeom.radiobuttonHeight     = charHeight + sysOffsets.radiobutton(4);
commonGeom.popupHeight           = charHeight + sysOffsets.popupmenu(4);
commonGeom.sysButtonHeight       = (charHeight*1.3) + sysOffsets.pushbutton(4);
commonGeom.sysButtonWidth        = sysButtonWidth + sysOffsets.pushbutton(3);
commonGeom.sysButtonDelta        = 8;
commonGeom.sheetSideEdgeBuffer   = 8;
commonGeom.sheetTopEdgeBuffer    = (commonGeom.textHeight/1.3);
commonGeom.sheetBottomEdgeBuffer = 8;
commonGeom.frameBottomEdgeBuffer = 6;
commonGeom.frameTopEdgeBuffer    = (commonGeom.textHeight/2) + 2;
commonGeom.frameSideEdgeBuffer   = 8;
commonGeom.frameDelta            = (commonGeom.textHeight/1.3);
commonGeom.figBottomEdgeBuffer   = 5;
commonGeom.figTopEdgeBuffer      = 5;
commonGeom.figSideEdgeBuffer     = 5;
commonGeom.sysButton_SheetDelta  = 5;

commonGeom.bottomSheetOffset = ...
    commonGeom.figBottomEdgeBuffer    + ...
    commonGeom.sysButtonHeight        + ...
    commonGeom.sysButton_SheetDelta;

commonGeom.sysOffsets = sysOffsets;

% end i_CreateCommonGeom()

%%%%%%%%%%%%%%%%%%%%%%%%%%% end Common functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Solver page %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% function DialogUserData = i_CreateSolverPage(DialogFig, DialogUserData)     %
% function [extent,solverCtrlPos]=i_solverCtrlPositions(commonGeom,solverGeom)%
% function solverGeom = i_CreateSolverGeom(commonGeom)                        %
% function [DialogUserData, bModified] = i_ManageSolverPage(...)              %
% function i_InstallSolverCallbacks(DialogFig, DialogUserData)                %
% function [DialogUserData, bModified] = i_SyncSolverPage( ... )              %
% function propValPairs = i_SolverPropValPairs(DialogUserData)                %
% function ctrlMap = i_SolverPageIntgCtrlMap(DialogUserData, integrator)      %
% function [DialogUserData, bModified] = i_ProcessTypeCallback( ... )         %
% function [DialogUserData, bModified] = i_ProcessOutputPopupCallback( ... )  %
% function [DialogUserData, bModified] = i_ProcessOutputEditCallback( ... )   %
% function [DialogUserData, bModified] = i_ProcessSolverCallback( ... )       %
% function [type,typeNum,solverList,solverNum] = i_IntAlg2ExtNameAndType(...) %
% function i_ShowRelevantOptions(DialogFig, DialogUserData, integrator)       %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%******************************************************************************
% Function - Create solver page.                                            ***
%******************************************************************************
function DialogUserData = i_CreateSolverPage(DialogFig, DialogUserData)

commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;

if isempty(DialogUserData.solverCtrlPos)
  solverGeom = i_CreateSolverGeom(commonGeom);

  [sheetDims, DialogUserData.solverCtrlPos] = i_solverCtrlPositions( ...
      commonGeom, solverGeom ...
      );
end

solverCtrlPos = DialogUserData.solverCtrlPos;

%
% Create simulation time group.
%
Children.SimulationTimeGroupBox = groupbox( ...
    DialogFig, ...
    solverCtrlPos.SimulationTimeGroupBox, ...
    ' Simulation time', ...
    textExtent ...
    );

%
% Create start time controls.
%
Children.StartTimeLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Start time:', ...
    'Position',           solverCtrlPos.StartTimeLabel ...
    );

Children.StartTimeEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'StartTimeEdit', ...
    'Position',           solverCtrlPos.StartTimeEdit ...
    );

%
% Create stop time controls.
%
Children.StopTimeLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Stop time:', ...
    'Position',           solverCtrlPos.StopTimeLabel ...
    );

Children.StopTimeEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'StopTimeEdit', ...
    'Position',           solverCtrlPos.StopTimeEdit ...
    );

%
% Create integrator options group.
%
Children.IntegratorGroupBox = groupbox( ...
    DialogFig, ...
    solverCtrlPos.IntegratorGroupBox, ...
    ' Solver options', ...
    textExtent ...
    );

%
% Create type controls.
%
Children.TypeLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Type:', ...
    'Position',           solverCtrlPos.TypeLabel ...
    );

Children.TypePopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'popupmenu', ...
    'String',             DialogUserData.SolverPage.solverTypes, ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'Tag',                'SolverTypePopup', ...
    'Position',           solverCtrlPos.TypePopup ...
    );

%
% Create integrator controls.
%
Children.SolverPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'popupmenu', ...
    'String',             'ode15s', ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'Tag',                'SolverPopup', ...
    'Position',           solverCtrlPos.SolverPopup ...
    );

%
% Create dividing line.
%
Children.Line = uicontrol(...
    'Parent',             DialogFig, ...
    'Style',              commonGeom.dividingLineStyle, ...
    'Enable',             'inactive', ...
    'Position',           solverCtrlPos.Line ...
    );

%
% Define mapping of active ctrls to solvers.
%  1 for on, 0 for off
%
nonStiffMap.RelTol            = 1;
nonStiffMap.AbsTol            = 1;
nonStiffMap.MaxOrder          = 0;
nonStiffMap.MaxStep           = 1;
nonStiffMap.MinStep           = 1;
nonStiffMap.FixedStep         = 0;
nonStiffMap.solverMode        = 0;
nonStiffMap.InitialStep       = 1;

ode15sMap.RelTol              = 1;
ode15sMap.AbsTol              = 1;
ode15sMap.MaxOrder            = 1;
ode15sMap.MaxStep             = 1;
ode15sMap.MinStep             = 1;
ode15sMap.FixedStep           = 0;
ode15sMap.solverMode          = 0;
ode15sMap.InitialStep         = 1;

ode23sMap.RelTol              = 1;
ode23sMap.AbsTol              = 1;
ode23sMap.MaxOrder            = 0;
ode23sMap.MaxStep             = 1;
ode23sMap.MinStep             = 1;
ode23sMap.FixedStep           = 0;
ode23sMap.solverMode          = 0;
ode23sMap.InitialStep         = 1;

ode23tMap.RelTol              = 1;
ode23tMap.AbsTol              = 1;
ode23tMap.MaxOrder            = 0;
ode23tMap.MaxStep             = 1;
ode23tMap.MinStep             = 1;
ode23tMap.FixedStep           = 0;
ode23tMap.solverMode          = 0;
ode23tMap.InitialStep         = 1;

ode23tbMap.RelTol             = 1;
ode23tbMap.AbsTol             = 1;
ode23tbMap.MaxOrder           = 0;
ode23tbMap.MaxStep            = 1;
ode23tbMap.MinStep            = 1;
ode23tbMap.FixedStep          = 0;
ode23tbMap.solverMode         = 0;
ode23tbMap.InitialStep        = 1;

varStepDiscMap.RelTol         = 0;
varStepDiscMap.AbsTol         = 0;
varStepDiscMap.MaxOrder       = 0;
varStepDiscMap.MaxStep        = 1;
varStepDiscMap.MinStep        = 0;
varStepDiscMap.FixedStep      = 0;
varStepDiscMap.solverMode     = 0;
varStepDiscMap.InitialStep    = 0;

fixStepDiscMap.RelTol         = 0;
fixStepDiscMap.AbsTol         = 0;
fixStepDiscMap.MaxOrder       = 0;
fixStepDiscMap.MaxStep        = 0;
fixStepDiscMap.MinStep        = 0;
fixStepDiscMap.FixedStep      = 1;
fixStepDiscMap.solverMode     = 1;
fixStepDiscMap.InitialStep    = 0;

DialogUserData.nonStiffMap    = nonStiffMap;
DialogUserData.ode15sMap      = ode15sMap;
DialogUserData.ode23sMap      = ode23sMap;
DialogUserData.ode23tMap      = ode23tMap;
DialogUserData.ode23tbMap     = ode23tbMap;
DialogUserData.varStepDiscMap = varStepDiscMap;
DialogUserData.fixStepDiscMap = fixStepDiscMap;

%
% Fixed step size controls.
%
Children.FixedStepLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Fixed step size:', ...
    'Position',           solverCtrlPos.FixedStepLabel ...
    );

Children.FixedStepEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'FixedStepEdit', ...
    'Position',           solverCtrlPos.FixedStepEdit ...
    );

%
% Solver mode controls.
%
Children.SolverModeLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Mode:', ...
    'Position',           solverCtrlPos.solverModeLabel ...
    );

Children.SolverModePopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'Style',              'popupmenu', ...
    'String',             {'Auto','SingleTasking','MultiTasking'}, ...
    'Tag',                'SolverModePopup', ...
    'Position',           solverCtrlPos.solverModePopup ...
    );

%
% Max step size controls.
%
Children.MaxStepLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Max step size:', ...
    'Position',           solverCtrlPos.MaxStepLabel ...
    );

Children.MaxStepEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'MaxStepEdit', ...
    'Position',           solverCtrlPos.MaxStepEdit ...
    );

%
% Init step size controls.
%
Children.InitialStepLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Initial step size:', ...
    'Position',           solverCtrlPos.InitialStepLabel ...
    );

Children.InitialStepEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'InitialStepEdit', ...
    'Position',           solverCtrlPos.InitialStepEdit ...
    );

%
% Min step size controls.
%
Children.MinStepLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Min step size:', ...
    'Position',           solverCtrlPos.MinStepLabel ...
    );

Children.MinStepEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'MinStepEdit', ...
    'Position',           solverCtrlPos.MinStepEdit ...
    );

%
% Reltol controls.
%
Children.RelTolLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Relative tolerance:', ...
    'Position',           solverCtrlPos.RelTolLabel ...
    );

Children.RelTolEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'RelTolEdit', ...
    'Position',           solverCtrlPos.RelTolEdit ...
    );

%
% Abstol controls.
%
Children.AbsTolLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Absolute tolerance:', ...
    'Position',           solverCtrlPos.AbsTolLabel ...
    );

Children.AbsTolEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'AbsTolEdit', ...
    'Position',           solverCtrlPos.AbsTolEdit ...
    );

%
% Max order controls.
%
Children.MaxOrderLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Maximum order:', ...
    'Position',           solverCtrlPos.MaxOrderLabel ...
    );

Children.MaxOrderPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'Style',              'popupmenu', ...
    'String',             '1|2|3|4|5', ...
    'Tag',                'MaxOrderPopup', ...
    'Position',           solverCtrlPos.MaxOrderPopup ...
    );

%
% Create output options group.
%
Children.OutputGroupBox = groupbox( ...
    DialogFig, ...
    solverCtrlPos.OutputGroupBox, ...
    ' Output options', ...
    textExtent ...
    );


%
% Create output options popup.
%
string = { ...
  'Refine output', ...
  'Produce additional output' ...
  'Produce specified output only' ...
  };

cr = sprintf('\n');
outputOptionTooltip = [...
    'Time step output options for variable-step solvers:',cr,...
    cr,...
    '"Refine output" uses the Solver interpolant to produce additional ',cr,...
    'output points for each integration time step. During refinement,',cr,...
    'the solver also checks for zero crossings.',cr,...
    cr,...
    '"Produce additional output" and "Produce specified output only" ',cr,...
    'are used to specify explicit integration hit times.'];

Children.OutputOptionPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'popupmenu', ...
    'String',             string, ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'Tag',                'OutputOptionPopup', ...
    'Position',           solverCtrlPos.OutputOptionPopup, ...
    'Tooltip',            outputOptionTooltip ...
    );


%
% Create output refine/times text and edit.
%
Children.RefineLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'HorizontalAlign',    'right', ...
    'Position',           solverCtrlPos.RefineLabel ...
    );

Children.RefineEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'RefineEdit', ...
    'Position',           solverCtrlPos.RefineEdit ...
    );

DialogUserData.solverCtrlPos = [];
DialogUserData.SolverPage.Children = Children;

% end i_CreateSolverPage()


%******************************************************************************
% Function - Calculate positions for all solver ctrls & return the total    ***
%  extent of all controls ([width height]).  The extent is actually the     ***
%  the sheet dimensions required for this page.                             ***
%                                                                           ***
% Positions are calculate from the bottom left of the fig to avoid          ***
% dependencies on figure size.                                              ***
%******************************************************************************
function [extent,solverCtrlPos] = i_solverCtrlPositions(commonGeom, solverGeom)

frameLeft = commonGeom.figSideEdgeBuffer + commonGeom.sheetSideEdgeBuffer;

optionsCol1 = frameLeft + commonGeom.frameSideEdgeBuffer;

optionsCol2 = ...
    optionsCol1                       + ...
    solverGeom.optionsCol1LabelWidth  + ...
    solverGeom.editWidth              + ...
    solverGeom.optionsColDelta;

frameWidth = ...                              % based on options section
    commonGeom.frameSideEdgeBuffer    + ...
    solverGeom.optionsCol1LabelWidth  + ...
    solverGeom.editWidth              + ...
    solverGeom.optionsColDelta        + ...
    solverGeom.optionsCol2LabelWidth  + ...
    solverGeom.editWidth              + ...
    commonGeom.frameSideEdgeBuffer;

%
% Output options groupbox.
%
frameHeight = ...
    commonGeom.frameTopEdgeBuffer     + ...
    solverGeom.outOptCtrlHeight       + ...
    commonGeom.frameBottomEdgeBuffer;

frameBottom = ...
    commonGeom.bottomSheetOffset      + ...
    commonGeom.sheetBottomEdgeBuffer;

frameRight = frameLeft + frameWidth;

cxCur = frameLeft;
cyCur = frameBottom;

frameBottom_OutputGroup = frameBottom;

solverCtrlPos.OutputGroupBox = [cxCur cyCur frameWidth frameHeight];

%
% OutputOptionPopup
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = cyCur + commonGeom.frameBottomEdgeBuffer;

solverCtrlPos.OutputOptionPopup = [cxCur cyCur ...
		    solverGeom.outputOptionPopupWidth  commonGeom.popupHeight];

%
% Refine label and edit.
%
cxCur = optionsCol2;
cyCur = cyCur + commonGeom.popupHeight - commonGeom.editHeight;
solverCtrlPos.RefineLabel = [cxCur cyCur ...
		    solverGeom.optionsCol2LabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.optionsCol2LabelWidth;
solverCtrlPos.RefineEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Integrator options groupbox.
%
frameBottom = frameBottom + frameHeight + commonGeom.frameDelta;

cyCur = frameBottom;
cxCur = frameLeft;

frameHeight = ...
    commonGeom.frameTopEdgeBuffer     + ...
    commonGeom.popupHeight            + ...
    solverGeom.optionsRowDelta        + ...
    commonGeom.lineThickness          + ...
    solverGeom.optionsRowDelta        + ...
    (commonGeom.editHeight * 2)       + ...
    commonGeom.popupHeight            + ...
    (solverGeom.optionsRowDelta * 2)  + ...
    commonGeom.frameBottomEdgeBuffer;

solverCtrlPos.IntegratorGroupBox = [cxCur cyCur frameWidth frameHeight];

%
% Max order
%
% Note: For appearance, the text label on the popup is not center
%   as with the edit boxes, but placed so that the vertical
%   distance between the init step label and the max order label
%   is equal to the distance between the init step label and the
%   max step size label.
%
cxCur = optionsCol2;

cyCurNominal = frameBottom + commonGeom.frameBottomEdgeBuffer;
cyDelta = commonGeom.popupHeight - commonGeom.editHeight;

cyCur = cyCurNominal + cyDelta;
solverCtrlPos.MaxOrderLabel = [cxCur cyCur ...
		    solverGeom.optionsCol2LabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.optionsCol2LabelWidth;
cyCur = cyCurNominal;

solverCtrlPos.MaxOrderPopup = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.popupHeight];

%
% Initial step size.
%
cxCur = optionsCol1;
cyCur = cyCur;

solverCtrlPos.InitialStepLabel = [cxCur cyCur ...
		    solverGeom.optionsCol1LabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.optionsCol1LabelWidth;
solverCtrlPos.InitialStepEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Min step size.
%
cxCur = optionsCol1;
cyCur = cyCur + commonGeom.popupHeight + solverGeom.optionsRowDelta;

solverCtrlPos.MinStepLabel = [cxCur cyCur ...
		    solverGeom.optionsCol1LabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.optionsCol1LabelWidth;

solverCtrlPos.MinStepEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Absolute tolerance
%
cxCur = optionsCol2;
solverCtrlPos.AbsTolLabel = [cxCur cyCur ...
		    solverGeom.optionsCol2LabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.optionsCol2LabelWidth;

solverCtrlPos.AbsTolEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Max step size.
%
cxCur = optionsCol1;
cyCur = cyCur + commonGeom.editHeight + solverGeom.optionsRowDelta;

solverCtrlPos.MaxStepLabel = [cxCur cyCur ...
		    solverGeom.optionsCol1LabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.optionsCol1LabelWidth;

solverCtrlPos.MaxStepEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Relative tolerance
%
cxCur = optionsCol2;

solverCtrlPos.RelTolLabel = [cxCur cyCur ...
		    solverGeom.optionsCol2LabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.optionsCol2LabelWidth;

solverCtrlPos.RelTolEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Fixed step size.
%
cxCur = optionsCol1;

solverCtrlPos.FixedStepLabel = [cxCur cyCur ...
		    solverGeom.fixedStepLabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.fixedStepLabelWidth;

solverCtrlPos.FixedStepEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Solver mode
%
cxCur = optionsCol2;

solverCtrlPos.solverModeLabel = [cxCur cyCur ...
		    solverGeom.solverModeLabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.solverModeLabelWidth;

solverCtrlPos.solverModePopup = [cxCur cyCur ...
		    solverGeom.solverModePopupWidth commonGeom.popupHeight];

%
% Dividing line.
%
lineWidth = frameWidth - (2 * commonGeom.frameSideEdgeBuffer);

cxCur = optionsCol1;
cyCur = cyCur + commonGeom.editHeight + solverGeom.optionsRowDelta;

solverCtrlPos.Line = [cxCur cyCur lineWidth commonGeom.lineThickness];

%
% Integrator type popup & label.
%
cyCur = cyCur + commonGeom.lineThickness + solverGeom.optionsRowDelta;

solverCtrlPos.TypeLabel = [cxCur cyCur ...
		    solverGeom.typeLabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.typeLabelWidth;

solverCtrlPos.TypePopup = [cxCur cyCur ...
		    solverGeom.typePopupWidth commonGeom.popupHeight];

%
% Integrator popup ctrls.
%
rightTypePopup = cxCur + solverGeom.typePopupWidth;
delta = 25;

cxCur = rightTypePopup + delta;
leftIntegratorPopup = cxCur;

popupWidth = frameRight - commonGeom.frameSideEdgeBuffer - cxCur;
solverCtrlPos.SolverPopup = [cxCur cyCur popupWidth commonGeom.popupHeight];

%
% Simulation time groupbox.
%

frameBottom = frameBottom + frameHeight + commonGeom.frameDelta;

cyCur = frameBottom;
cxCur = frameLeft;

frameHeight = ...
    commonGeom.frameTopEdgeBuffer     + ...
    commonGeom.editHeight             + ...
    commonGeom.frameBottomEdgeBuffer;

frameTop_SimulationTime = frameBottom + frameHeight;

solverCtrlPos.SimulationTimeGroupBox = [cxCur cyCur frameWidth frameHeight];


%
% Start time ctrls.
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = frameBottom + commonGeom.frameBottomEdgeBuffer;

solverCtrlPos.StartTimeLabel = [cxCur cyCur ...
		    solverGeom.startLabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.startLabelWidth;

solverCtrlPos.StartTimeEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Stop time ctrls.
%
cxCur = leftIntegratorPopup;

solverCtrlPos.StopTimeLabel = [cxCur cyCur ...
		    solverGeom.startLabelWidth commonGeom.textHeight];

cxCur = cxCur + solverGeom.startLabelWidth;

solverCtrlPos.StopTimeEdit = [cxCur cyCur ...
		    solverGeom.editWidth commonGeom.editHeight];

%
% Calculate extents (sheet dimensions).
%
width  = frameWidth + (2 * commonGeom.sheetSideEdgeBuffer);

height = ...
    (frameTop_SimulationTime - frameBottom_OutputGroup) + ...
    commonGeom.sheetTopEdgeBuffer                       + ...
    commonGeom.sheetBottomEdgeBuffer;

extent = [width height];

% end i_solverCtrlPositions()


%******************************************************************************
% Function - Create geometry constants for solver page.                     ***
%******************************************************************************
function solverGeom = i_CreateSolverGeom(commonGeom)

sysOffsets   = commonGeom.sysOffsets;
textExtent   = commonGeom.textExtent;

set(textExtent, 'String', 'Start time:');
ext = get(textExtent, 'Extent');
solverGeom.startLabelWidth = ext(3);

set(textExtent, 'String', '0123456789');
ext = get(textExtent, 'Extent');
solverGeom.editWidth = ext(3) + sysOffsets.edit(3);

set(textExtent, 'String', 'Type:');
ext = get(textExtent, 'Extent');
solverGeom.typeLabelWidth = ext(3);

set(textExtent, 'String', 'Variable-step  ');
ext = get(textExtent, 'Extent');
solverGeom.typePopupWidth = ext(3) + sysOffsets.popupmenu(3);

set(textExtent, 'String', 'Initial step size:  ');
ext = get(textExtent, 'Extent');
solverGeom.optionsCol1LabelWidth = ext(3);

set(textExtent, 'String', 'Absolute tolerance:');
ext = get(textExtent, 'Extent');
solverGeom.optionsCol2LabelWidth  = ext(3);

set(textExtent, 'String', 'Fixed step size:');
ext = get(textExtent, 'Extent');
solverGeom.fixedStepLabelWidth  = ext(3);

set(textExtent, 'String', 'Mode: ');
ext = get(textExtent, 'Extent');
solverGeom.solverModeLabelWidth  = ext(3);

set(textExtent, 'String', 'SingleTasking  ');
ext = get(textExtent, 'Extent');
solverGeom.solverModePopupWidth = ext(3) + sysOffsets.popupmenu(3);


solverGeom.optionsColDelta = 29;
solverGeom.optionsRowDelta = 5;

set(textExtent, 'String', 'Produce specified output only ');
ext = get(textExtent, 'Extent');
solverGeom.outputOptionPopupWidth = ext(3) + sysOffsets.popupmenu(3);

solverGeom.outOptCtrlHeight = ...
    max(commonGeom.popupHeight, commonGeom.editHeight);

% end i_CreateSolverGeom()

%******************************************************************************
% Function - Manage callbacks for SolverPage.                               ***
%******************************************************************************
function [DialogUserData, bModified] = i_ManageSolverPage(...
    DialogFig, DialogUserData, Action)

bModified = 0;

switch(Action)

  case 'SolverPopup',
    [DialogUserData, bModified] = i_ProcessSolverCallback( ...
	DialogFig, DialogUserData);

    [DialogUserData,bModified] = i_EnableApply(DialogUserData);

  case 'TypePopup',
    [DialogUserData, bModified] = i_ProcessTypeCallback( ...
	DialogFig, DialogUserData);

    [DialogUserData,bModified] = i_EnableApply(DialogUserData);

  case 'OutputPopup',
    [DialogUserData, bModified] = i_ProcessOutputPopupCallback( ...
	DialogFig, DialogUserData);

    [DialogUserData,bModified] = i_EnableApply(DialogUserData);

  case 'OutputEdit',
    [DialogUserData, bModified] = i_ProcessOutputEditCallback( ...
	DialogFig, DialogUserData);

    [DialogUserData,bModified] = i_EnableApply(DialogUserData);

  otherwise,
    error('Invalid action');

end

% end i_ManageSolverPage()


%******************************************************************************
% Function - Install callbacks for Solver page.                             ***
%******************************************************************************
function i_InstallSolverCallbacks(DialogFig, DialogUserData)

Children = DialogUserData.SolverPage.Children;

%==============================================================================
% Start and Stop time.
%==============================================================================
set([Children.StartTimeEdit Children.StopTimeEdit], ...
    'Callback',       'simprm(''EnableApply'', gcbf)' ...
    );

%==============================================================================
% Integrator group.
%==============================================================================
set(Children.SolverPopup, ...
    'Callback',  'simprm(''SolverPage'', ''SolverPopup'', gcbf)' ...
    );

set(Children.TypePopup, ...
    'Callback',  'simprm(''SolverPage'', ''TypePopup'', gcbf)' ...
    );


%
% Set enable Apply callback for all appropriate options.
%
handles = [
    Children.RelTolEdit
    Children.FixedStepEdit
    Children.SolverModePopup
    Children.AbsTolEdit
    Children.MaxStepEdit
    Children.MinStepEdit
    Children.InitialStepEdit
    Children.MaxOrderPopup
	  ];

set(handles, 'Callback', 'simprm(''EnableApply'', gcbf)');


%==============================================================================
% Output group.
%==============================================================================
set(Children.OutputOptionPopup, ...
    'Callback',   'simprm(''SolverPage'', ''OutputPopup'', gcbf)' ...
    );

set(Children.RefineEdit, ...
    'Callback',   'simprm(''SolverPage'', ''OutputEdit'', gcbf)' ...
    );

% end i_InstallSolverCallbacks()


%******************************************************************************
% Function - Sync solver page & create revert buffers.                      ***
%                                                                           ***
% NOTE: Since each option ctrl is sunc on creation, we don't need to        ***
%   sync them "again" during creation of the page.                          ***
%******************************************************************************
function [DialogUserData, bModified] = i_SyncSolverPage( ...
    DialogFig, DialogUserData,syncWithModel)

bModified = 0;

Children = DialogUserData.SolverPage.Children;
model = DialogUserData.model;

%==============================================================================
% The code that makes sure that all enable/disable states are correct
% assumes that all controls start of in the enabled state.
%==============================================================================
childVect = struct2cell(Children);
childVect = [childVect{:}];

exclude = [
  Children.SimulationTimeGroupBox'
  Children.IntegratorGroupBox'
  Children.Line
  Children.OutputGroupBox'];

childVect = setdiff(childVect,exclude);

set(childVect, 'Enable','on');

%==============================================================================
% Sync start time.
%==============================================================================
if syncWithModel,
  string = get_param(model, 'StartTime');

  set(Children.StartTimeEdit, ...
    'String',         string);
end

%==============================================================================
% Sync stop time.
%==============================================================================
if syncWithModel,
  string = get_param(model, 'StopTime');

  set(Children.StopTimeEdit, ...
    'String',         string);
end

%==============================================================================
% Sync integrator type & integrator.
%==============================================================================
if syncWithModel,
  solver = get_param(model, 'Solver');

  [type, typeNum, solverList, solverNum] = ...
    i_IntAlg2ExtNameAndType(solver, DialogUserData);

  DialogUserData.SolverPage.oldSolverNum(typeNum) = solverNum;

  set(Children.TypePopup, ...
    'Value',          typeNum);

  set(Children.SolverPopup, ...
    'String',         solverList, ...
    'Value',          solverNum);
else
  typeNum = get(Children.TypePopup, 'Value');
end

%==============================================================================
% Sync options group.
%==============================================================================

if syncWithModel,

  %
  % Make sure that the proper ctrls are vis.
  %
  i_ShowRelevantOptions(DialogFig, DialogUserData, solver);
  Children = DialogUserData.SolverPage.Children;

  %
  % Sync Reltol controls.
  %
  string = get_param(model, 'RelTol');

  set(Children.RelTolEdit, ...
    'String',         string);

  %
  % Sync Fixed step controls.
  %
  string = get_param(model, 'FixedStep');

  set(Children.FixedStepEdit, ...
    'String',         string);

  %
  % Sync solver mode controls.
  %
  str = get_param(model, 'SolverMode');
  val = popupStr2ValMatch(Children.SolverModePopup, str);

  set(Children.SolverModePopup, ...
    'Value',          val);

  %
  % Sync Abstol controls.
  %
  string = get_param(model, 'AbsTol');

  set(Children.AbsTolEdit, ...
    'String',         string);

  %
  % Sync max step size controls.
  %
  string = get_param(model, 'MaxStep');

  set(Children.MaxStepEdit, ...
    'String',         string);

  %
  % Sync init step size controls.
  %
  string = get_param(model, 'InitialStep');

  set(Children.InitialStepEdit, ...
    'String',         string);

  %
  % Sync min step size controls.
  %
  string = get_param(model, 'MinStep');

  set(Children.MinStepEdit, ...
    'String',         string);

  %
  % Sync max order.
  %
  val = get_param(model, 'MaxOrder');

  set(Children.MaxOrderPopup, ...
    'Value',          val);
end

%==============================================================================
% Sync output options.
%==============================================================================

if syncWithModel,
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Determine option and appropriate label string.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  switch get_param(model, 'OutputOption')
    case 'RefineOutputTimes',
      outputOptionNum = 1;
    case 'AdditionalOutputTimes',
      outputOptionNum = 2;
    case 'SpecifiedOutputTimes',
      outputOptionNum = 3;
    otherwise,
      error('Invalid output option');
  end
else
  outputOptionNum = get(Children.OutputOptionPopup, 'Value');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set enable property for output options based on whether or not
%  this is a fixed step solver.
%
% Magic number: 2 = fixed step solver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if typeNum == 2,
  enableState = 'off';
else
  enableState = 'on';
end

%%%%%%%%%%%%%%%%%
% Set ui values.
%%%%%%%%%%%%%%%%%

if syncWithModel,
  set(Children.OutputOptionPopup, ...
    'Value',          outputOptionNum);

  string = DialogUserData.SolverPage.OutputTimesEditLabels{outputOptionNum};

  set(Children.RefineLabel, ...
    'String',         string);
end

set([Children.OutputOptionPopup Children.RefineLabel], ...
  'Enable',         enableState);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve info from model & construct user data for edit ctrl.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if syncWithModel,
  User.CurrentOptionStrings{1} = get_param(model, 'Refine');
  User.CurrentOptionStrings{2} = get_param(model, 'OutputTimes');
  User.CurrentOptionStrings{3} = User.CurrentOptionStrings{2};

  string = User.CurrentOptionStrings{outputOptionNum};

  set(Children.RefineEdit, ...
    'String',         string, ...
    'UserData',       User);
end

set(Children.RefineEdit, ...
    'Enable',         enableState);

%==============================================================================
% Disable controls for ReadOnlyIfCompiledParams if we're not stopped.
%==============================================================================
if ~strcmp(get_param(model,'SimulationStatus'),'stopped'),

  if outputOptionNum ~= 1,
    refineEdit  = Children.RefineEdit;
    refineLabel = Children.RefineLabel;
  else
    refineEdit  = [];
    refineLabel = [];
  end

  handles = [
      Children.StartTimeLabel
      Children.StartTimeEdit
      Children.TypeLabel
      Children.TypePopup
      Children.SolverPopup
      Children.InitialStepLabel
      Children.InitialStepEdit
      Children.FixedStepLabel
      Children.FixedStepEdit
      Children.SolverModeLabel
      Children.SolverModePopup
      Children.OutputOptionPopup
      refineLabel
      refineEdit];

  set(handles,'Enable','off');
end

% end i_SyncSolverPage()


%******************************************************************************
% Function - Build prop/val pairs for solver page.                          ***
%******************************************************************************
function propValPairs = i_SolverPropValPairs(DialogUserData)

Children = DialogUserData.SolverPage.Children;

algTypeNum = get(Children.TypePopup, 'Value');
algNum     = get(Children.SolverPopup, 'Value');
solver  = DialogUserData.solverLists{algTypeNum}{algNum};
ctrlMap    = i_SolverPageIntgCtrlMap(DialogUserData, solver);

propValPairs = {};

%============================================================================
% Start time.
%============================================================================
string = get(Children.StartTimeEdit, 'String');
prop = 'StartTime';
propValPairs([end+1 end+2]) = {prop, string};

%============================================================================
% Stop time.
%============================================================================
string = get(Children.StopTimeEdit, 'String');
prop = 'StopTime';
propValPairs([end+1 end+2]) = {prop, string};

%============================================================================
% Solver
%============================================================================
string = solver;
prop   = 'Solver';

propValPairs([end+1 end+2]) = {prop, string};

%============================================================================
% Relative tolerance
%============================================================================
if ctrlMap.RelTol == 1,
  string = get(Children.RelTolEdit, 'String');
  prop = 'RelTol';
  propValPairs([end+1 end+2]) = {prop, string};
end

%============================================================================
% Absolute tolerance
%============================================================================
if ctrlMap.AbsTol == 1,
  string = get(Children.AbsTolEdit, 'String');
  prop = 'AbsTol';
  propValPairs([end+1 end+2]) = {prop, string};
end

%============================================================================
% Max order
%============================================================================
if ctrlMap.MaxOrder == 1,
  value = get(Children.MaxOrderPopup, 'Value');
  prop = 'MaxOrder';
  propValPairs([end+1 end+2]) = {prop, value};
end

%============================================================================
% Max step size
%============================================================================
if ctrlMap.MaxStep == 1,
  string = get(Children.MaxStepEdit, 'String');
  prop = 'MaxStep';
  propValPairs([end+1 end+2]) = {prop, string};
end

%============================================================================
% Min step size
%============================================================================
if ctrlMap.MinStep == 1,
  string = get(Children.MinStepEdit, 'String');
  prop = 'MinStep';
  propValPairs([end+1 end+2]) = {prop, string};
end

%============================================================================
% Fixed step size
%============================================================================
if ctrlMap.FixedStep == 1,
  string = get(Children.FixedStepEdit, 'String');
  prop = 'FixedStep';
  propValPairs([end+1 end+2]) = {prop, string};
end


%============================================================================
% Solver Mode
%============================================================================
if ctrlMap.solverMode == 1,
  string = get(Children.SolverModePopup, 'String');
  val    = get(Children.SolverModePopup, 'Value');
  prop   = 'SolverMode';
  propValPairs([end+1 end+2]) = {prop, string{val}};
end

%============================================================================
% Init step size
%============================================================================
if ctrlMap.InitialStep == 1,
  string = get(Children.InitialStepEdit, 'String');
  prop = 'InitialStep';
  propValPairs([end+1 end+2]) = {prop, string};
end

%============================================================================
% Output option, and refine factor/output times.
%============================================================================
outputOptionNum = get(Children.OutputOptionPopup, 'Value');
switch(outputOptionNum)
  case 1,
    string     = 'RefineOutputTimes';
    outputProp = 'Refine';
  case 2,
    string     = 'AdditionalOutputTimes';
    outputProp = 'OutputTimes';
  case 3,
    string = 'SpecifiedOutputTimes';
    outputProp = 'OutputTimes';
  otherwise,
    error('M Assert: invalid option number');
end

propValPairs([end+1 end+2]) = {'OutputOption', string};

string = get(Children.RefineEdit, 'String');
propValPairs([end+1 end+2]) = {outputProp, string};

% end i_SolverPropValPairs()


%******************************************************************************
% Function - Retrieve appropritate ctrl map given an internal intg name.    ***
%******************************************************************************
function ctrlMap = i_SolverPageIntgCtrlMap(DialogUserData, integrator)

switch(integrator)

  case {'ode45', 'ode23', 'ode113'},
    ctrlMap = DialogUserData.nonStiffMap;

  case 'ode15s',
    ctrlMap = DialogUserData.ode15sMap;

  case 'ode23s',
    ctrlMap = DialogUserData.ode23sMap;

  case 'ode23t',
    ctrlMap = DialogUserData.ode23tMap;

  case 'ode23tb',
    ctrlMap = DialogUserData.ode23tbMap;

  case {'FixedStepDiscrete', 'ode5', 'ode4', 'ode3', 'ode2', 'ode1'},
    ctrlMap = DialogUserData.fixStepDiscMap;

  case 'VariableStepDiscrete',
    ctrlMap = DialogUserData.varStepDiscMap;

  otherwise,
    error('M assert: invalid action');
end

% end i_SolverPageIntgCtrlMap()


%******************************************************************************
% Function - Process callback for type popup.                               ***
%******************************************************************************
function [DialogUserData, bModified] = i_ProcessTypeCallback( ...
    DialogFig, DialogUserData)

Children  = DialogUserData.SolverPage.Children;
bModified = 0;

%==============================================================================
% Retrieve current solver for this type.
%==============================================================================
solverPopup = Children.SolverPopup;
typeNum = get(Children.TypePopup, 'Value');

if DialogUserData.SolverPage.oldSolverNum(typeNum) ~= -1,
  solverNum = DialogUserData.SolverPage.oldSolverNum(typeNum);
else
  solverNum = 1;
end

solver = DialogUserData.solverLists{typeNum}{solverNum};

%==============================================================================
% Set the appropriate options.
%==============================================================================
i_ShowRelevantOptions(DialogFig, DialogUserData, solver);

%==============================================================================
% Update solver popup strings.
%==============================================================================
set(solverPopup, ...
    'Value',      solverNum, ...
    'String',     DialogUserData.ExternalSolverLists{typeNum} ...
    );

%==============================================================================
% Controlled enabledness of output option controls.
%==============================================================================
handles = [
  Children.OutputOptionPopup
  Children.RefineLabel
  Children.RefineEdit
  ];

if typeNum == 2,
  set(handles, 'Enable', 'off');
else
  set(handles, 'Enable', 'on');
end

% end i_ProcessTypeCallback()


%******************************************************************************
% Function - Process callback for output option popup.                      ***
%******************************************************************************
function [DialogUserData, bModified] = i_ProcessOutputPopupCallback( ...
    DialogFig, DialogUserData)

Children  = DialogUserData.SolverPage.Children;
bModified = 0;

outputOptionNum = get(Children.OutputOptionPopup, 'Value');

string = DialogUserData.SolverPage.OutputTimesEditLabels{outputOptionNum};
set(Children.RefineLabel, 'String', string);

EditUserData = get(Children.RefineEdit, 'UserData');
set(Children.RefineEdit, ...
    'String',  EditUserData.CurrentOptionStrings{outputOptionNum} ...
    );

% end i_ProcessOutputPopupCallback()


%******************************************************************************
% Function - Process callback for output option popup.                      ***
%******************************************************************************
function [DialogUserData, bModified] = i_ProcessOutputEditCallback( ...
    DialogFig, DialogUserData)

Children  = DialogUserData.SolverPage.Children;
bModified = 0;

outputOptionNum = get(Children.OutputOptionPopup, 'Value');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update the string for this option so that we can remember it
%  if we switch to another option and come back.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
refineEdit = Children.RefineEdit;
string     = get(refineEdit, 'String');

EditUserData = get(refineEdit, 'UserData');
EditUserData.CurrentOptionStrings{outputOptionNum} = string;

set(refineEdit, 'UserData', EditUserData);

% end i_ProcessOutputEditCallback()


%******************************************************************************
% Function - Process callback for solver popup.                             ***
%******************************************************************************
function [DialogUserData, bModified] = i_ProcessSolverCallback( ...
    DialogFig, DialogUserData)

Children = DialogUserData.SolverPage.Children;

%==============================================================================
% Determine the solver name & adjust options.
%==============================================================================
solverPopup = Children.SolverPopup;
solverNum   = get(solverPopup, 'Value');

typeNum = get(Children.TypePopup, 'Value');

solver = DialogUserData.solverLists{typeNum}{solverNum};

i_ShowRelevantOptions(DialogFig, DialogUserData, solver);

%==============================================================================
% Update value of solver so we can restore it during type
%  switching.
%==============================================================================
DialogUserData.SolverPage.oldSolverNum(typeNum) = solverNum;
bModified = 1;

% end i_ProcessSolverCallback()


%******************************************************************************
% Function - convert solver to solver type.
% INPUT:
%    internal solver name
%
% OUTPUT:
%   type       - type string
%   typeNum    - type number
%   solverList - list of external solver names for this type
%   solverNum  - number of this solver
%******************************************************************************
function [type,typeNum,solverList,solverNum] = i_IntAlg2ExtNameAndType( ...
    solver, DialogUserData)

solverLists          = DialogUserData.solverLists;
ExternalSolverLists  = DialogUserData.ExternalSolverLists;

switch(solver)
 case solverLists{1},
  type = 'Variable-step';
  typeNum  = 1;
 case solverLists{2},
  type = 'Fixed-step';
  typeNum  = 2;
 otherwise,
  error('M Assert: Invalid solver');
end

solverList = ExternalSolverLists{typeNum};
solverNum  = find(strcmp(solver, solverLists{typeNum}));

% end i_IntAlg2ExtNameAndType()

%******************************************************************************
% Function - Show/Hide integrator options based on current                  ***
%  integrator (internal name).                                              ***
%******************************************************************************
function i_ShowRelevantOptions(DialogFig, DialogUserData, integrator)

if DialogUserData.CurrentPageNum == 1,

  Children = DialogUserData.SolverPage.Children;
  ctrlMap  = i_SolverPageIntgCtrlMap(DialogUserData, integrator);

  hh= [Children.RelTolLabel Children.RelTolEdit];
  set(hh, 'Visible', onoff(ctrlMap.RelTol));

  hh = [Children.FixedStepLabel Children.FixedStepEdit];
  set(hh, 'Visible', onoff(ctrlMap.FixedStep));

  hh = [Children.SolverModeLabel Children.SolverModePopup];
  set(hh, 'Visible', onoff(ctrlMap.solverMode));

  hh = [Children.AbsTolLabel Children.AbsTolEdit];
  set(hh, 'Visible', onoff(ctrlMap.AbsTol));

  hh = [Children.MaxStepLabel Children.MaxStepEdit];
  set(hh, 'Visible', onoff(ctrlMap.MaxStep));

  hh = [Children.MinStepLabel Children.MinStepEdit];
  set(hh, 'Visible', onoff(ctrlMap.MinStep));

  hh = [Children.InitialStepLabel Children.InitialStepEdit];
  set(hh, 'Visible', onoff(ctrlMap.InitialStep));

  hh = [Children.MaxOrderLabel Children.MaxOrderPopup];
  set(hh, 'Visible', onoff(ctrlMap.MaxOrder));

end

% end i_ShowRelevantOptions()


%%%%%%%%%%%%%%%%%%%%%%%%%%%% end Solver page %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%% Workspace I/O page %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% function DialogUserData = i_CreateWorkspaceIOPage(DialogFig, DialogUserData)%
% function [extent, workspaceIOCtrlPos] = i_workspaceIOCtrlPositions( ... )   %
% function workspaceIOGeom = i_CreateWorkspaceIOGeom(commonGeom)              %
% function [DialogUserData, bModified] = i_ManageWorkspaceIOPage(...)         %
% function i_InstallWorkspaceIOCallbacks(DialogFig, DialogUserData)           %
% function i_SyncWorkspaceIOPage(DialogUserData)                              %
% function propValPairs = i_WorkspaceIOPropValPairs(DialogUserData)           %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%******************************************************************************
% Function - Create workspace i/o page.                                     ***
%******************************************************************************
function DialogUserData = i_CreateWorkspaceIOPage(DialogFig, DialogUserData)

commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;

if isempty(DialogUserData.workspaceIOCtrlPos)
  workspaceIOGeom = i_CreateWorkspaceIOGeom(commonGeom);

  [notUsed, DialogUserData.workspaceIOCtrlPos] = i_workspaceIOCtrlPositions(...
      commonGeom, workspaceIOGeom ...
      );
end

workspaceIOCtrlPos = DialogUserData.workspaceIOCtrlPos;

%
% Create 'load from workspace group'.
%
Children.LoadGroupBox = groupbox( ...
    DialogFig, ...
    workspaceIOCtrlPos.LoadGroupBox, ...
    ' Load from workspace', ...
    textExtent ...
    );

%
% Create input label and edit ctrls.
%
Children.InputCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Input:', ...
    'Tag',                'InputCheckbox', ...
    'Position',           workspaceIOCtrlPos.InputCheckbox ...
    );

Children.InputEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'InputEdit', ...
    'Position',           workspaceIOCtrlPos.InputEdit ...
    );

%
% Create load initial checkbox and edit ctrl.
%
Children.InitialStateCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Initial state:', ...
    'Tag',                'InitialStateCheckbox', ...
    'Position',           workspaceIOCtrlPos.InitialStateCheckbox ...
    );

Children.InitialStateEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'InitialStateEdit', ...
    'Position',           workspaceIOCtrlPos.InitialStateEdit ...
    );

if slfeature('SignalLogging'),
  %
  % Create 'Data logging' group.
  %
  Children.SigLogGroupBox = groupbox( ...
    DialogFig, ...
    workspaceIOCtrlPos.SigLogGroupBox, ...
    ' Logging object', ...
    textExtent ...
    );

  %
  % Create signal logging label and edit ctrls.
  %
  Children.SigLogLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Variable name:', ...
    'Tag',                'SigLogLabel', ...
    'Position',           workspaceIOCtrlPos.SigLogLabel);

  Children.SigLogEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'SigLogEdit', ...
    'Position',           workspaceIOCtrlPos.SigLogEdit ...
    );
end

%
% Create 'save to workspace group'.
%
Children.SaveGroupBox = groupbox( ...
    DialogFig, ...
    workspaceIOCtrlPos.SaveGroupBox, ...
    ' Save to workspace', ...
    textExtent ...
    );


%
% Create time label and edit ctrls.
%
Children.TimeCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Time:', ...
    'Tag',                'SaveTimeCheckbox', ...
    'Position',           workspaceIOCtrlPos.TimeCheckbox ...
    );

Children.TimeEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'TimeEdit', ...
    'Position',           workspaceIOCtrlPos.TimeEdit ...
    );

%
% Create states label and edit ctrls.
%
Children.StatesCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'States:', ...
    'Tag',                'SaveStatesCheckbox', ...
    'Position',           workspaceIOCtrlPos.StatesCheckbox ...
    );

Children.StatesEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'StatesEdit', ...
    'Position',           workspaceIOCtrlPos.StatesEdit ...
    );

%
% Create output label and edit ctrls.
%
Children.OutputCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Output:', ...
    'Tag',                'OutputCheckbox', ...
    'Position',           workspaceIOCtrlPos.OutputCheckbox ...
    );

Children.OutputEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'OutputEdit', ...
    'Position',           workspaceIOCtrlPos.OutputEdit ...
    );

%
% Create 'save final' checkbox and edit ctrl.
%
Children.FinalStateCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Final state:', ...
    'Tag',                'FinalStateCheckbox', ...
    'Position',           workspaceIOCtrlPos.FinalStateCheckbox ...
    );

Children.FinalStateEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'FinalStateEdit', ...
    'Position',           workspaceIOCtrlPos.FinalStateEdit ...
    );

%
% Create 'save options group'.
%
Children.SaveOptionsGroupBox = groupbox( ...
    DialogFig, ...
    workspaceIOCtrlPos.SaveOptionsGroupBox, ...
    ' Save options', ...
    textExtent ...
    );

%
% Create 'Limit data points to last' checkbox and edit ctrl.
%
Children.LimitDataCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Limit data points to last:', ...
    'Tag',                'LimitDataPointsCheckbox', ...
    'Position',           workspaceIOCtrlPos.LimitDataCheckbox ...
    );

Children.LimitDataEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'LimitDataEdit', ...
    'Position',           workspaceIOCtrlPos.LimitDataEdit ...
    );

%
% Create 'decimation factor' label and edit ctrl.
%
Children.DecimationLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Decimation:', ...
    'Position',           workspaceIOCtrlPos.DecimationLabel ...
    );

Children.DecimationEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'DecimationEdit', ...
    'Position',           workspaceIOCtrlPos.DecimationEdit ...
    );

%
% Create 'Format' string and popup menu
%
Children.SaveFormatLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Format:', ...
    'Position',           workspaceIOCtrlPos.SaveFormatLabel ...
    );

Children.SaveFormatPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Backgroundcolor',    DialogUserData.popupBackGroundColor, ...
    'Style',              'popup', ...
    'Tag',                'SaveFormatPopup', ...
    'String',             {'Structure with time'; 'Structure'; 'Array'}, ...
    'Position',           workspaceIOCtrlPos.SaveFormatPopup ...
    );

%
% Update user data.
%
DialogUserData.workspaceIOCtrlPos = [];
DialogUserData.WorkspaceIOPage.Children = Children;

% end i_CreateWorkspaceIOPage()


%******************************************************************************
% Function - Calculate positions for all workspace I/O ctrls & return total ***
%  extent of all controls ([width height]).                                 ***
%                                                                           ***
% It is assumemed that the sheet position is now known (based on solver     ***
%   page), so we work from the top down.                                    ***
%******************************************************************************
function [extent, workspaceIOCtrlPos] = i_workspaceIOCtrlPositions( ...
    commonGeom, workspaceIOGeom )

sheetPos  = commonGeom.sheetPos;
sheetTop  = sheetPos(2) + sheetPos(4);
sheetLeft = sheetPos(1);

%
% Load groupbox.
%
loadFrameLeft   = sheetLeft + commonGeom.sheetSideEdgeBuffer;
loadFrameTop    = sheetTop  - commonGeom.sheetTopEdgeBuffer;
loadFrameBottom = loadFrameTop - workspaceIOGeom.LoadFrameHeight;

frameDelta = 10;
actualLoadFrameWidth = ...
    (sheetPos(3) - (commonGeom.sheetSideEdgeBuffer*2) - frameDelta) / 2;

workspaceIOCtrlPos.LoadGroupBox = ...
    [loadFrameLeft loadFrameBottom ...
      actualLoadFrameWidth workspaceIOGeom.LoadFrameHeight];

%
% Input check/edit pair.
%
cxCur = loadFrameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = ...
    loadFrameTop                          - ...
    commonGeom.frameTopEdgeBuffer         - ...
    workspaceIOGeom.Check_EditPairHeight;

cxOrig = cxCur;

workspaceIOCtrlPos.InputCheckbox = [cxCur cyCur ...
      workspaceIOGeom.loadCheckboxWidth commonGeom.checkboxHeight];

cxCur = cxCur + workspaceIOGeom.loadCheckboxWidth;

editWidth = ...
    actualLoadFrameWidth              - ...
    workspaceIOGeom.loadCheckboxWidth - ...
    (2*commonGeom.frameSideEdgeBuffer);

workspaceIOCtrlPos.InputEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];

loadEditRight = cxCur + editWidth;

%
% Load init check/edit pair.
%
cxCur = cxOrig;
cyCur = ...
    cyCur - workspaceIOGeom.rowDelta - workspaceIOGeom.Check_EditPairHeight;

cxOrig = cxCur;

workspaceIOCtrlPos.InitialStateCheckbox = [cxCur cyCur ...
      workspaceIOGeom.loadCheckboxWidth commonGeom.checkboxHeight];

cxCur = cxCur + workspaceIOGeom.loadCheckboxWidth;

editWidth = loadEditRight - cxCur;

workspaceIOCtrlPos.InitialStateEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];

if slfeature('SignalLogging'),
  %
  % siglog groupbox.
  %
  frameBottom = loadFrameBottom - commonGeom.frameDelta - ...
    workspaceIOGeom.SigLogFrameHeight;
  workspaceIOCtrlPos.SigLogGroupBox = ...
    [loadFrameLeft frameBottom ...
     actualLoadFrameWidth workspaceIOGeom.SigLogFrameHeight];

  %
  % Signal logging label/edit pair.
  %
  cxCur = cxOrig;
  cyCur = ...
    frameBottom + workspaceIOGeom.rowDelta;

  cxOrig = cxCur;

  workspaceIOCtrlPos.SigLogLabel = [cxCur cyCur ...
      workspaceIOGeom.loadCheckboxWidth commonGeom.checkboxHeight];

  cxCur = cxCur + workspaceIOGeom.loadCheckboxWidth;

  editWidth = loadEditRight - cxCur;

  workspaceIOCtrlPos.SigLogEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];
else
  frameBottom = loadFrameBottom;
end

%
% Save groupbox.
%
saveFrameLeft = sheetPos(1) + sheetPos(3) - ...
    commonGeom.sheetSideEdgeBuffer      - ...
    actualLoadFrameWidth;

workspaceIOCtrlPos.SaveGroupBox = [saveFrameLeft frameBottom ...
      actualLoadFrameWidth workspaceIOGeom.LoadSaveFrameHeight];


%
% Time check/edit pair.
%
editWidth = ...
    actualLoadFrameWidth              - ...
    workspaceIOGeom.saveCheckboxWidth - ...
    (2*commonGeom.frameSideEdgeBuffer);

cxCur = saveFrameLeft + commonGeom.frameSideEdgeBuffer;

cyCur = ...
    loadFrameTop                          - ...
    commonGeom.frameTopEdgeBuffer         - ...
    workspaceIOGeom.Check_EditPairHeight;

cxOrig = cxCur;

workspaceIOCtrlPos.TimeCheckbox = [cxCur cyCur ...
      workspaceIOGeom.saveCheckboxWidth commonGeom.checkboxHeight];

cxCur = cxCur + workspaceIOGeom.saveCheckboxWidth;

workspaceIOCtrlPos.TimeEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];

saveEditRight = cxCur + editWidth;


%
% States check/edit pair.
%
cxCur = cxOrig;

cyCur = ...
    cyCur - workspaceIOGeom.rowDelta - workspaceIOGeom.Check_EditPairHeight;

workspaceIOCtrlPos.StatesCheckbox = [cxCur cyCur ...
      workspaceIOGeom.saveCheckboxWidth commonGeom.checkboxHeight];

cxCur = cxCur + workspaceIOGeom.saveCheckboxWidth;

workspaceIOCtrlPos.StatesEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];


%
% Output check/edit pair.
%
cxCur = cxOrig;
cyCur = ...
    cyCur - workspaceIOGeom.rowDelta - workspaceIOGeom.Check_EditPairHeight;
workspaceIOCtrlPos.OutputCheckbox = [cxCur cyCur ...
      workspaceIOGeom.saveCheckboxWidth commonGeom.checkboxHeight];
cxCur = cxCur + workspaceIOGeom.saveCheckboxWidth;

workspaceIOCtrlPos.OutputEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];


%
% Save final check/edit pair.
%
cxCur = cxOrig;
cyCur = ...
    cyCur - workspaceIOGeom.rowDelta - workspaceIOGeom.Check_EditPairHeight;
workspaceIOCtrlPos.FinalStateCheckbox = [cxCur cyCur ...
      workspaceIOGeom.saveCheckboxWidth commonGeom.checkboxHeight];

cxCur = cxCur + workspaceIOGeom.saveCheckboxWidth;

workspaceIOCtrlPos.FinalStateEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];


%
% Save options group.
%
frameHeight = ...
    commonGeom.frameTopEdgeBuffer              + ...
    commonGeom.popupHeight                     + ...
    workspaceIOGeom.Check_EditPairHeight       + ...
    commonGeom.editHeight                      + ...
    (workspaceIOGeom.rowDelta * 3)             + ...
    commonGeom.frameBottomEdgeBuffer;

frameBottom = frameBottom - commonGeom.frameDelta - frameHeight;
frameLeft   = loadFrameLeft;
frameWidth  = sheetPos(3) - (2 * commonGeom.sheetSideEdgeBuffer) + 1;

workspaceIOCtrlPos.SaveOptionsGroupBox = ...
    [frameLeft frameBottom frameWidth frameHeight];

%
% Limit rows check/edit pair.
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cxOrig = cxCur;
cyCur = frameBottom + frameHeight - ...
    commonGeom.frameTopEdgeBuffer - ...
    commonGeom.checkboxHeight;

workspaceIOCtrlPos.LimitDataCheckbox = [cxCur cyCur ...
      workspaceIOGeom.LimitDataCheckboxWidth commonGeom.checkboxHeight];

cxCur = cxCur + workspaceIOGeom.LimitDataCheckboxWidth;
editWidth = ...
    frameWidth                         - ...
    (2*commonGeom.frameSideEdgeBuffer) - ...
    workspaceIOGeom.LimitDataCheckboxWidth;

workspaceIOCtrlPos.LimitDataEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];

%
% Decimation label and edit.
%
cxCur = cxOrig;
cyCur = cyCur - workspaceIOGeom.rowDelta - ...
    workspaceIOGeom.Check_EditPairHeight;
workspaceIOCtrlPos.DecimationLabel = [cxCur cyCur ...
      workspaceIOGeom.LimitDataCheckboxWidth commonGeom.textHeight];
cxCur = cxCur + workspaceIOGeom.LimitDataCheckboxWidth;
workspaceIOCtrlPos.DecimationEdit = [cxCur cyCur ...
      editWidth commonGeom.editHeight];

%
% State Format label and popup menu.
%
cxCur = cxOrig;
cyCur = cyCur - workspaceIOGeom.rowDelta - ...
	commonGeom.popupHeight;
cxOrig = cxCur;
workspaceIOCtrlPos.SaveFormatLabel = [cxCur cyCur ...
      workspaceIOGeom.LimitDataCheckboxWidth commonGeom.textHeight];

cxCur = cxCur + workspaceIOGeom.LimitDataCheckboxWidth;

workspaceIOCtrlPos.SaveFormatPopup = [cxCur cyCur ...
      editWidth commonGeom.popupHeight];

%
% Extents.
%
% NOTE: The extent should never be used as the sheet dimensions
%  are defined by the solver page.  I'm setting it to NaN so that
%  if I ever try to use it, it will cause an obvious mistake.
%
extent = NaN;

% end i_workspaceIOCtrlPositions()


%******************************************************************************
% Function - Create geometry constants for workspaceIO page.                ***
%                                                                           ***
% NOTE: Some dimensions are min required dimensions.  If the sheets end     ***
%       up being bigger the controls will use larger widths.                ***
%******************************************************************************
function workspaceIOGeom = i_CreateWorkspaceIOGeom(commonGeom)

sysOffsets   = commonGeom.sysOffsets;
textExtent   = commonGeom.textExtent;

workspaceIOGeom.Check_EditPairHeight = ...
    max(commonGeom.checkboxHeight, commonGeom.editHeight);

workspaceIOGeom.rowDelta = 5;

set(textExtent, 'String', 'Initial state:');
ext = get(textExtent, 'Extent');
workspaceIOGeom.loadCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Final state:');
ext = get(textExtent, 'Extent');
workspaceIOGeom.saveCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

workspaceIOGeom.loadEditWidth = 95  + sysOffsets.edit(3);

workspaceIOGeom.LoadSaveFrameHeight = ...
    commonGeom.frameTopEdgeBuffer              + ...
    (workspaceIOGeom.Check_EditPairHeight * 4) + ...
    (workspaceIOGeom.rowDelta * 3)             + ...
    commonGeom.frameBottomEdgeBuffer;

workspaceIOGeom.loadFrameWidth = ...
    (commonGeom.frameSideEdgeBuffer * 2) + ...
    workspaceIOGeom.loadCheckboxWidth    + ...
    workspaceIOGeom.loadEditWidth;

if slfeature('SignalLogging'),
  workspaceIOGeom.LoadFrameHeight = ...
    commonGeom.frameTopEdgeBuffer              + ...
    (workspaceIOGeom.Check_EditPairHeight * 2) + ...
    (workspaceIOGeom.rowDelta)             + ...
    commonGeom.frameBottomEdgeBuffer;

  workspaceIOGeom.SigLogFrameHeight = ...
    commonGeom.frameTopEdgeBuffer          + ...
    (workspaceIOGeom.Check_EditPairHeight) + ...
    commonGeom.frameBottomEdgeBuffer;
else
  workspaceIOGeom.LoadFrameHeight = workspaceIOGeom.LoadSaveFrameHeight;
end

workspaceIOGeom.saveEditWidth = ...
    workspaceIOGeom.loadFrameWidth       - ...
    (2 * commonGeom.frameSideEdgeBuffer) - ...
    workspaceIOGeom.saveCheckboxWidth;

set(textExtent, 'String', 'Limit data points to last:');
ext = get(textExtent, 'Extent');
workspaceIOGeom.LimitDataCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

workspaceIOGeom.advancedEditWidth = 75  + sysOffsets.edit(3);

% end i_CreateWorkspaceIOGeom()


%******************************************************************************
% Function - Manage callbacks for WorkspaceIOPage.                          ***
%******************************************************************************
function [DialogUserData, bModified] = i_ManageWorkspaceIOPage(...
    DialogFig, DialogUserData, Action)

bModified = 0;

switch(Action)

  case 'DefCheckEdit',
    %==================================================================
    % Default behavior for checkbox/edit pairs.
    %==================================================================
    checkbox = gcbo;
    checkBoxUserData = get(checkbox, 'UserData');
    i_CheckEditPair_DefCheckCallbk(checkbox, checkBoxUserData.edit);
    [DialogUserData,bModified] = i_EnableApply(DialogUserData);

  otherwise,
    %==================================================================
    % Unhandled case.
    %==================================================================
    error('M assert: invalid action');
end

% end i_ManageWorkspaceIOPage()


%******************************************************************************
% Function - Install callbacks for workspace i/o page.                      ***
%******************************************************************************
function i_InstallWorkspaceIOCallbacks(DialogFig, DialogUserData)

Children = DialogUserData.WorkspaceIOPage.Children;

%==============================================================================
% All default checkbox/edit pairs.
%==============================================================================
checkboxHandles = [
    Children.InputCheckbox
    Children.TimeCheckbox
    Children.StatesCheckbox
    Children.OutputCheckbox
    Children.InitialStateCheckbox
    Children.FinalStateCheckbox
    Children.LimitDataCheckbox
		  ];

set(checkboxHandles, ...
    'Callback',       'simprm(''WorkspaceIOPage'', ''DefCheckEdit'', gcbf)' ...
    );

editHandles = [
    Children.InputEdit
    Children.TimeEdit
    Children.StatesEdit
    Children.OutputEdit
    Children.InitialStateEdit
    Children.FinalStateEdit
    Children.LimitDataEdit];

if slfeature('SignalLogging'),
  editHandles = [editHandles;Children.SigLogEdit];
end

set(editHandles, ...
    'Callback',       'simprm(''EnableApply'', gcbf)' ...
    );

%==============================================================================
% State Format
%==============================================================================
set(Children.SaveFormatPopup, ...
    'Callback',       'simprm(''EnableApply'', gcbf)' ...
    );

%==============================================================================
% Decimation.
%==============================================================================
set(Children.DecimationEdit, ...
    'Callback',       'simprm(''EnableApply'', gcbf)' ...
    );

% end i_InstallWorkspaceIOCallbacks()


%******************************************************************************
% Function - Sync Workspace I/O page.                                       ***
%******************************************************************************
function i_SyncWorkspaceIOPage(DialogUserData,syncWithModel)

Children = DialogUserData.WorkspaceIOPage.Children;
model    = DialogUserData.model;

childVect = struct2cell(Children);
childVect = [childVect{:}];

exclude = [
  Children.LoadGroupBox'
  Children.SaveGroupBox'
  Children.SaveOptionsGroupBox'];

childVect = setdiff(childVect,exclude);

%==============================================================================
% The code that makes sure that all enable/disable states are correct
% assumes that all controls start of in the enabled state.
%==============================================================================
set(childVect, 'Enable','on');

%==============================================================================
% Sync input checkbox & edit ctrl.
%==============================================================================
i_InitCheckEditPair(Children.InputCheckbox, Children.InputEdit, ...
    get_param(model, 'LoadExternalInput'), ...
    get_param(model, 'ExternalInput'), ...
    syncWithModel);

i_InitCheckEditPair( ...
    Children.InitialStateCheckbox, Children.InitialStateEdit, ...
    get_param(model, 'LoadInitialState'), ...
    get_param(model, 'InitialState'), ...
    syncWithModel);

if slfeature('SignalLogging'),
  str = get_param(model,'SignalLoggingName');
  set(Children.SigLogEdit, 'String', str);
end

%==============================================================================
% Sync time, states and output checkbox & edit ctrls.
%==============================================================================
i_InitCheckEditPair(Children.TimeCheckbox, Children.TimeEdit, ...
    get_param(model, 'SaveTime'), ...
    get_param(model, 'TimeSaveName'), ...
    syncWithModel);

i_InitCheckEditPair(Children.StatesCheckbox, Children.StatesEdit, ...
    get_param(model, 'SaveState'), ...
    get_param(model, 'StateSaveName'), ...
    syncWithModel);

i_InitCheckEditPair(Children.OutputCheckbox, Children.OutputEdit, ...
    get_param(model, 'SaveOutput'), ...
    get_param(model, 'OutputSaveName'), ...
    syncWithModel);

i_InitCheckEditPair(Children.FinalStateCheckbox, Children.FinalStateEdit, ...
    get_param(model, 'SaveFinalState'), ...
    get_param(model, 'FinalStateName'), ...
    syncWithModel);

%==============================================================================
% Sync 'State Format' popup.
%==============================================================================
if syncWithModel,
  str = get_param(model, 'SaveFormat');
  val = popupStr2ValMatch(Children.SaveFormatPopup, str);
  set(Children.SaveFormatPopup, ...
    'Value', val);
end

%==============================================================================
% 'Limit data points to last' checkbox and edit ctrl.
%==============================================================================
i_InitCheckEditPair(Children.LimitDataCheckbox, ...
    Children.LimitDataEdit, ...
    get_param(model, 'LimitDataPoints'), ...
    get_param(model, 'MaxDataPoints'), ...
    syncWithModel);


%==============================================================================
% Decimation factor.
%==============================================================================
if syncWithModel,
  string = get_param(model, 'Decimation');

  set(Children.DecimationEdit, ...
    'String',         string);
end

%==============================================================================
% Disable controls for ReadOnlyIfCompiledParams if we're not stopped.
%==============================================================================
if ~strcmp(get_param(model,'SimulationStatus'),'stopped'),
  set(childVect,'Enable','off');
end

% end i_SyncWorkspaceIOPage()


%******************************************************************************
% Function - Build prop/val pairs for workspace i/o page.                   ***
%******************************************************************************
function propValPairs = i_WorkspaceIOPropValPairs(DialogUserData)

Children = DialogUserData.WorkspaceIOPage.Children;
propValPairs = {};


%============================================================================
% Input checkbox and string.
%============================================================================
propValPairs(end+1:end+4) = {
  'LoadExternalInput',  onoff(get(Children.InputCheckbox, 'Value')), ...
      'ExternalInput',      get(Children.InputEdit, 'String') ...
      };

%============================================================================
% Load initial states checkbox and string.
%============================================================================
propValPairs(end+1:end+4) = {
  'LoadInitialState', onoff(get(Children.InitialStateCheckbox, 'Value')), ...
      'InitialState',     get(Children.InitialStateEdit, 'String') ...
      };

%============================================================================
% Signal logging string.
%============================================================================
if slfeature('SignalLogging'),
  str = get(Children.SigLogEdit,'String');
  propValPairs([end+1 end+2]) = {'SignalLoggingName',str};
end

%============================================================================
% Time checkbox and string.
%============================================================================
propValPairs(end+1:end+4) = {
      'SaveTime',       onoff(get(Children.TimeCheckbox, 'Value')), ...
      'TimeSaveName',   get(Children.TimeEdit, 'String') ...
};


%============================================================================
% States checkbox and string.
%============================================================================
propValPairs(end+1:end+4) = {
  'SaveState',       onoff(get(Children.StatesCheckbox, 'Value')), ...
      'StateSaveName',   get(Children.StatesEdit, 'String') ...
      };


%============================================================================
% Output checkbox and string.
%============================================================================
propValPairs(end+1:end+4) = {
  'SaveOutput',      onoff(get(Children.OutputCheckbox, 'Value')), ...
      'OutputSaveName',  get(Children.OutputEdit, 'String') ...
      };


%============================================================================
% Save final states checkbox and string.
%============================================================================
propValPairs(end+1:end+4) = {
  'SaveFinalState',    onoff(get(Children.FinalStateCheckbox, 'Value')), ...
      'FinalStateName',    get(Children.FinalStateEdit, 'String') ...
      };

%============================================================================
% State Format Popup
%============================================================================
strings = get(Children.SaveFormatPopup, 'String');
val     = get(Children.SaveFormatPopup, 'Value');
if val == 1
  setprmStr = 'StructureWithTime';
else
  setprmStr = strings{val};
end
propValPairs(end+1:end+2) = { 'SaveFormat',  setprmStr };

%============================================================================
% Limit rows checkbox and string.
%============================================================================
propValPairs(end+1:end+4) = {
  'LimitDataPoints',    onoff(get(Children.LimitDataCheckbox, 'Value')), ...
      'MaxDataPoints',         get(Children.LimitDataEdit, 'String') ...
      };


%============================================================================
% Decimiation factor.
%============================================================================
propValPairs(end+1:end+2) = {
  'Decimation',     get(Children.DecimationEdit, 'String') ...
      };

% end i_WorkspaceIOPropValPairs()

%%%%%%%%%%%%%%%%%%%%%%%%% end Workspace I/O page %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Diagnostics page %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% function DialogUserData = i_CreateDiagnosticsPage(DialogFig, DialogUserData)%
% function [extent,diagnosticsCtrlPos] = i_DiagnosticsCtrlPositions( ... )    %
% function diagnosticsGeom = i_CreateDiagnosticsGeom(commonGeom)              %
% function [DialogUserData, bModified] = i_ManageDiagnosticsPage(...)         %
% function i_InstallDiagnosticsCallbacks(DialogFig, DialogUserData)           %
% function i_DiagnosticListCallback(DialogFig, DialogUserData)                %
% function i_DiagnosticRadioCallback(DialogFig, DialogUserData)               %
% function DialogUserData = i_SyncDiagnosticsPage(DialogUserData)             %
% function propValPairs = i_DiagnosticsPropValPairs(DialogUserData)           %
% function idx = i_EventActStr2ActIdx(string)                             %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%******************************************************************************
% Function - Create diagnostics page.                                       ***
%******************************************************************************
function DialogUserData = i_CreateDiagnosticsPage(DialogFig, DialogUserData)

cr = sprintf('\n');
commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;

if isempty(DialogUserData.diagnosticsCtrlPos)
  diagnosticsGeom = i_CreateDiagnosticsGeom(commonGeom);

  [notUsed, DialogUserData.diagnosticsCtrlPos] = i_DiagnosticsCtrlPositions( ...
      commonGeom, diagnosticsGeom ...
      );
end

diagnosticsCtrlPos = DialogUserData.diagnosticsCtrlPos;

%
% Create 'options' group.
%
Children.OptionsGroupBox = groupbox( ...
    DialogFig, ...
    diagnosticsCtrlPos.OptionsGroupBox, ...
    ' Simulation options', ...
    textExtent ...
    );

%
% Create 'Consistency checking' control.
%
ConsistencyTooltipStr = ...
    ['Verifies that blocks with continuous sample times', cr, ...
     'work correctly with the solvers by executing them', cr, ...
     'repeatedly and checking for consistent answers'];
Children.ConsistencyLabel = uicontrol( ...
    'Parent',         DialogFig, ...
    'Style',          'text', ...
    'String',         'Consistency checking:', ...
    'Position',       diagnosticsCtrlPos.ConsistencyLabel, ...
    'Tooltip',        ConsistencyTooltipStr ...
    );

Children.ConsistencyPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'popupmenu', ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'String',             getfield(getfield(get_param(0, 'ObjectParameters'), ...
                                            'ConsistencyChecking'), 'Enum'), ...
    'Position',           diagnosticsCtrlPos.ConsistencyPopup, ...
    'Tag',                'ConsistencyCheckingPopup', ...
    'Tooltip',            ConsistencyTooltipStr ...
    );

%
% Create 'Bounds checking' control.
%
BoundsCheckTooltipStr = ...
    ['Ensures that Simulink-allocated memory used in blocks and', cr, ...
     'S-Functions do not write beyond their assigned array bounds', cr, ...
     'when writing to their outputs, states or work vectors'];
Children.BoundsCheckLabel = uicontrol( ...
    'Parent',         DialogFig, ...
    'Style',          'text', ...
    'String',         'Bounds checking:', ...
    'Position',       diagnosticsCtrlPos.BoundsCheckLabel, ...
    'Tooltip',        BoundsCheckTooltipStr ...
    );

Children.BoundsCheckPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'popupmenu', ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'String',             getfield(getfield(get_param( 0, 'ObjectParameters'), ...
                                            'ArrayBoundsChecking'), 'Enum'), ...
    'Position',           diagnosticsCtrlPos.BoundsCheckPopup, ...
    'Tag',                'BoundsCheckingPopup', ...
    'Tooltip',            BoundsCheckTooltipStr ...
    );

%
% Create event label and listbox.
%
Children.EventsLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Configuration options:', ...
    'Position',           diagnosticsCtrlPos.EventLabel ...
    );

Children.EventsList = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'listbox', ...
    'String',             'temp', ...
    'Fontname',           commonGeom.listboxFixedFontName, ...
    'Fontsize',           commonGeom.listboxFixedFontSize, ...
    'Position',           diagnosticsCtrlPos.EventsList, ...
    'Tag',                'DiagnosticsListbox', ...
    'BackgroundColor',    'w', ...
    'Max',                2 ...
    );

%
% Create actions group.
%
Children.ActionGroupBox = groupbox( ...
    DialogFig, ...
    diagnosticsCtrlPos.ActionGroupBox, ...
    ' Action', ...
    textExtent ...
    );

%
% Create radio buttons for actions.
%

%
% ... create strings for radio buttons.  They are padded with spaces
% for convenience.  These strings are used later to fill in
% the string for the listbox (fixed width font).
% See i_DiagnosticRadioCallback.
%
strings = [
    'None   '
    'Warning'
    'Error  '
	  ];

Children.NoneRadio = uicontrol( ...
    'Parent',         DialogFig, ...
    'Style',          'radiobutton', ...
    'String',         strings(1,:), ...
    'Position',       diagnosticsCtrlPos.NoneRadio ...
    );

Children.WarningRadio = uicontrol( ...
    'Parent',         DialogFig, ...
    'Style',          'radiobutton', ...
    'String',         strings(2,:), ...
    'Position',       diagnosticsCtrlPos.WarningRadio ...
    );

Children.ErrorRadio = uicontrol( ...
    'Parent',         DialogFig, ...
    'Style',          'radiobutton', ...
    'String',         strings(3,:), ...
    'Position',       diagnosticsCtrlPos.ErrorRadio ...
    );

%
% Update user data.
%
DialogUserData.diagnosticsCtrlPos = [];
DialogUserData.DiagnosticsPage.Children = Children;

DialogUserData.DiagnosticsPage.ActionRadioGroup = [
    Children.NoneRadio
    Children.WarningRadio
    Children.ErrorRadio
		   ];

% end i_CreateDiagnosticsPage()


%******************************************************************************
% Function - Calculate positions for all diagnostics ctrls & return total   ***
%  extent of all controls ([width height]).                                 ***
%                                                                           ***
% It is assumemed that the sheet position is now known (based on solver     ***
%   page), so we work from the top down.                                    ***
%******************************************************************************
function [extent, diagnosticsCtrlPos] = i_DiagnosticsCtrlPositions( ...
    commonGeom, diagnosticsGeom )

sheetPos  = commonGeom.sheetPos;
sheetTop  = sheetPos(2) + sheetPos(4);
sheetLeft = sheetPos(1);

%
% Options groupbox.
%
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
frameHeight = ...
    commonGeom.frameTopEdgeBuffer   + ...
    commonGeom.popupHeight          + ...
    commonGeom.frameBottomEdgeBuffer;

cyCur = sheetTop - frameHeight - commonGeom.sheetTopEdgeBuffer;
frameBottom = cyCur;

frameWidth  = sheetPos(3) - 2 * commonGeom.sheetSideEdgeBuffer;
frameLeft   = cxCur;
frameRight  = frameLeft + frameWidth;

diagnosticsCtrlPos.OptionsGroupBox = ...
    [frameLeft frameBottom frameWidth frameHeight];

%
% Consistency label & popup.
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = frameBottom + frameHeight      - ...
	commonGeom.frameTopEdgeBuffer  - ...
	commonGeom.popupHeight;

diagnosticsCtrlPos.ConsistencyLabel = [cxCur cyCur ...
		    diagnosticsGeom.consistencyLabelWidth ...
		    commonGeom.textHeight];

cxCur = cxCur + diagnosticsGeom.consistencyLabelWidth;
diagnosticsCtrlPos.ConsistencyPopup = [cxCur cyCur ...
		    diagnosticsGeom.consistencyPopupWidth ...
		    commonGeom.popupHeight];

%
% Bounds Check label & popup.
%
cxCur = frameRight - commonGeom.frameSideEdgeBuffer - ...
	diagnosticsGeom.boundsCheckPopupWidth - ...
	diagnosticsGeom.boundsCheckLabelWidth;

diagnosticsCtrlPos.BoundsCheckLabel = [cxCur cyCur ...
		    diagnosticsGeom.boundsCheckLabelWidth ...
		    commonGeom.textHeight];

cxCur = cxCur + diagnosticsGeom.boundsCheckLabelWidth;
diagnosticsCtrlPos.BoundsCheckPopup = [cxCur cyCur ...
		    diagnosticsGeom.boundsCheckPopupWidth ...
		    commonGeom.popupHeight];

%
% event label
%
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
cyCur = frameBottom - commonGeom.editHeight - commonGeom.sheetTopEdgeBuffer;
diagnosticsCtrlPos.EventLabel = [cxCur cyCur ...
      diagnosticsGeom.eventLabelWidth, commonGeom.editHeight];

%
% event list box.
%
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
cyCur = frameBottom - commonGeom.editHeight - ...
	commonGeom.sheetBottomEdgeBuffer - diagnosticsGeom.eventListHeight;

listBoxBottom = cyCur;
listBoxTop    = cyCur + diagnosticsGeom.eventListHeight;
listBoxLeft   = cxCur;
listBoxWidth  = ...
    sheetPos(3) - 3 * commonGeom.sheetSideEdgeBuffer - ...
    (commonGeom.frameSideEdgeBuffer * 2) - ...
    diagnosticsGeom.radiobuttonWidth;
diagnosticsCtrlPos.EventsList = [cxCur cyCur ...
      listBoxWidth diagnosticsGeom.eventListHeight];

%
% Action groupbox.
%
frameHeight = ...
    commonGeom.frameTopEdgeBuffer       + ...
    (commonGeom.radiobuttonHeight * 3)  + ...
    (diagnosticsGeom.rowDelta * 2)      + ...
    commonGeom.frameBottomEdgeBuffer;
frameWidth = ...
    (commonGeom.frameSideEdgeBuffer * 2) + diagnosticsGeom.radiobuttonWidth;

frameBottom = listBoxTop - frameHeight;

frameLeft = ...
    sheetPos(1) + sheetPos(3)      - ...
    commonGeom.sheetSideEdgeBuffer - ...
    frameWidth;

framePos = [frameLeft frameBottom frameWidth frameHeight];

diagnosticsCtrlPos.ActionGroupBox = ...
    [frameLeft frameBottom frameWidth frameHeight];

%
% Action radio buttons.
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = ...
    frameBottom + frameHeight     - ...
    commonGeom.frameTopEdgeBuffer - ...
    commonGeom.radiobuttonHeight;

diagnosticsCtrlPos.NoneRadio = [cxCur cyCur ...
		    diagnosticsGeom.radiobuttonWidth ...
		    commonGeom.radiobuttonHeight];

cyCur = cyCur - diagnosticsGeom.rowDelta - commonGeom.radiobuttonHeight;
diagnosticsCtrlPos.WarningRadio = [cxCur cyCur ...
		    diagnosticsGeom.radiobuttonWidth ...
		    commonGeom.radiobuttonHeight];

cyCur = cyCur - diagnosticsGeom.rowDelta - commonGeom.radiobuttonHeight;
diagnosticsCtrlPos.ErrorRadio = [cxCur cyCur ...
		    diagnosticsGeom.radiobuttonWidth ...
		    commonGeom.radiobuttonHeight];


%
% Extents.
%
% NOTE: The extent should never be used as the sheet dimensions
%  are defined by the solver page.  I'm setting it to NaN so that
%  if I ever try to use it, it will cause an obvious mistake.
%
extent = NaN;

% end i_DiagnosticsCtrlPositions()


%******************************************************************************
% Function - Create geometry constants for diagnostics page.                ***
%******************************************************************************
function diagnosticsGeom = i_CreateDiagnosticsGeom(commonGeom)

sysOffsets = commonGeom.sysOffsets;
textExtent = commonGeom.textExtent;

diagnosticsGeom.rowDelta             = 5;
diagnosticsGeom.groupBoxListBoxDelta = 6;
diagnosticsGeom.eventLabelWidth      = 68  + sysOffsets.text(3);
diagnosticsGeom.eventListHeight      = ...
    125 + commonGeom.editHeight + ...
    diagnosticsGeom.rowDelta  + ...
    sysOffsets.listbox(4);

set(textExtent, 'String', 'Configuration options: ');
ext = get(textExtent, 'Extent');
diagnosticsGeom.eventLabelWidth = ext(3);

set(textExtent, ...
    'String',   'Unconnected block output   Warning', ...
    'FontName', commonGeom.listboxFixedFontName, ...
    'FontSize', commonGeom.listboxFixedFontSize ...
    );
ext = get(textExtent, 'Extent');
set(textExtent, ...
    'FontName',   get(0, 'FactoryUicontrolFontname'), ...
    'FontSize',   get(0, 'FactoryUicontrolFontsize') ...
    );
diagnosticsGeom.eventListWidth = ext(3) + sysOffsets.listbox(3);

set(textExtent, 'String', 'Warning');
ext = get(textExtent, 'Extent');
warningWidth = ext(3);
diagnosticsGeom.radiobuttonWidth = ext(3) + sysOffsets.radiobutton(3);

set(textExtent, 'String', 'Consistency checking ');
ext = get(textExtent, 'Extent');
advancedGeom.consistencyCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Consistency checking: ');
ext = get(textExtent, 'Extent');
diagnosticsGeom.consistencyLabelWidth = ext(3);
diagnosticsGeom.consistencyPopupWidth = warningWidth + sysOffsets.popupmenu(3);

set(textExtent, 'String', 'Bounds checking: ');
ext = get(textExtent, 'Extent');
diagnosticsGeom.boundsCheckLabelWidth = ext(3);
diagnosticsGeom.boundsCheckPopupWidth = warningWidth + sysOffsets.popupmenu(3);

% end i_CreateDiagnosticsGeom()


%******************************************************************************
% Function - Manage callbacks for DiagnosticsPage.                          ***
%******************************************************************************
function [DialogUserData, bModified] = i_ManageDiagnosticsPage(...
    DialogFig, DialogUserData, Action)

bModified = 0;

switch(Action)

 case 'ActionRadio',
  %==================================================================
  % Action radio buttons.
  %==================================================================
  i_DiagnosticRadioCallback(DialogFig, DialogUserData);
  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

 case 'eventsList',
  %==================================================================
  % Action radio buttons.
  %==================================================================
  i_DiagnosticListCallback(DialogFig, DialogUserData);
  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

 otherwise,
  %==================================================================
  % Unhandled case.
  %==================================================================
  error('M assert: invalid action');
end

% end i_ManageDiagnosticsPage()


%******************************************************************************
% Function - Install callbacks for diagnostics page.                        ***
%******************************************************************************
function i_InstallDiagnosticsCallbacks(DialogFig, DialogUserData)

Children = DialogUserData.DiagnosticsPage.Children;
ActionRadioGroup = DialogUserData.DiagnosticsPage.ActionRadioGroup;


%==============================================================================
% action radio buttons.
%==============================================================================
set(ActionRadioGroup, ...
    'Callback', 'simprm(''DiagnosticsPage'', ''ActionRadio'', gcbf)' ...
    );

%==============================================================================
% Event listbox.
%==============================================================================
set(Children.EventsList, ...
    'Callback', 'simprm(''DiagnosticsPage'', ''eventsList'', gcbf)' ...
    );

%==============================================================================
% Consistency and bounds checking popup.
%==============================================================================
stdHdl = [
    Children.ConsistencyPopup
    Children.BoundsCheckPopup
    ];
set(stdHdl, 'Callback', 'simprm(''EnableApply'', gcbf)' );

% end i_InstallDiagnosticsCallbacks()


%******************************************************************************
% Function - Handle callback for listbox on diagnostic page.                ***
%******************************************************************************
function i_DiagnosticListCallback(DialogFig, DialogUserData)

Children = DialogUserData.DiagnosticsPage.Children;

eventList        = Children.EventsList;
eventTooltips    = DialogUserData.DiagnosticsPage.eventTooltips;
ActionRadioGroup = DialogUserData.DiagnosticsPage.ActionRadioGroup;

actionIndex = DialogUserData.DiagnosticsPage.actionIndex;

selectedItems    = get(eventList, 'Value');
numSelectedItems = length(selectedItems);

noneItems        = DialogUserData.DiagnosticsPage.noneItems;
noneAndWarnItems = DialogUserData.DiagnosticsPage.noneAndWarnItems;
warnAndErrItems  = DialogUserData.DiagnosticsPage.warnAndErrItems;

%==============================================================================
% Handle differently if multi - selection.
%==============================================================================
if numSelectedItems == 0,
  %=======================================================================
  % No items are selected, turn off all radio buttons.
  %=======================================================================
  set(ActionRadioGroup, 'Enable', 'off', 'Value', 0);
elseif numSelectedItems > 1,
  if all(ismember(selectedItems, noneItems))
    set(ActionRadioGroup, 'Enable', 'off', 'Value', 0);
    set(eventList, 'Tooltip', '');
  else
    %=======================================================================
    % Multi selection case.
    %=======================================================================
    string = get(eventList, 'String');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Retrieve actions for all selections.
    % I'm using the magic number of 7, here.  It is the length of
    % 'warning'.  This is done because these are padded strings.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    actions = char(zeros(numSelectedItems,7));
    for i=1:numSelectedItems,
      columns = actionIndex:actionIndex + 6;
      row     = selectedItems(i);

      actions(i,:) = string(row, columns);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If all the actions are the same, turn on
    %  the appropriate radio button.  If not,
    %  turn off all radio buttons.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bSameActions = all(all((diff(abs(actions))) == 0));

    if bSameActions,
      action    = actions(1,:);
      actionNum = i_EventActStr2ActIdx(action);

      i_RadioBehaviorWithPress(ActionRadioGroup, ActionRadioGroup(actionNum));
    else
      set(ActionRadioGroup, 'Value', 0);
    end

    % make sure that the action buttons are enabled
    set(ActionRadioGroup, 'Enable', 'on');

    eventListTooltipStr = 'Specify action taken on error conditions';
    set(eventList, 'Tooltip', eventListTooltipStr);
  end
else
  %=======================================================================
  % Single selection.
  %=======================================================================

  string  = get(eventList, 'String');
  row     = selectedItems;
  columns = actionIndex:actionIndex + 6;

  action = string(row, columns);
  % note intentional use of | not || below
  if isempty(action) | findstr(action(1:end), '---')
    set(ActionRadioGroup, 'Enable', 'off', 'Value', 0);
  else
    actionNum = i_EventActStr2ActIdx(action);
    i_RadioBehaviorWithPress(ActionRadioGroup, ActionRadioGroup(actionNum));

    % disallow the none option if needed
    if (any(selectedItems==warnAndErrItems))
      set(ActionRadioGroup(1), 'Enable', 'off');
    else
      set(ActionRadioGroup(1), 'Enable', 'on');
    end

    % make sure second option (warning) is enabled for all
    set(ActionRadioGroup(2), 'Enable', 'on');

    % disallow the error option if needed
    if (any(selectedItems==noneAndWarnItems))
      set(ActionRadioGroup(3), 'Enable', 'off');
    else
      set(ActionRadioGroup(3), 'Enable', 'on');
    end
  end

  set(eventList, 'Tooltip', eventTooltips{row});

end

% end i_DiagnosticListCallback()


%******************************************************************************
% Function - Handle callback for action radio button on diagnostic page.    ***
%******************************************************************************
function i_DiagnosticRadioCallback(DialogFig, DialogUserData)

Children = DialogUserData.DiagnosticsPage.Children;

eventList    = Children.EventsList;
ActionRadioGroup = DialogUserData.DiagnosticsPage.ActionRadioGroup;
pressedRadio     = gcbo;

actionIndex = DialogUserData.DiagnosticsPage.actionIndex;

%==============================================================================
% Implement radio behavior.
%==============================================================================
bNewValue = i_RadioBehavior(ActionRadioGroup, pressedRadio);


%==============================================================================
% Build new listbox string.
%==============================================================================
if bNewValue == 1,
  string           = get(eventList, 'String');
  selectedItems    = get(eventList, 'Value');
  numSelectedItems = length(selectedItems);

  action = get(pressedRadio, 'String');
  actionLength = length(action);

  noneItems        = DialogUserData.DiagnosticsPage.noneItems;
  noneAndWarnItems = DialogUserData.DiagnosticsPage.noneAndWarnItems;
  warnAndErrItems  = DialogUserData.DiagnosticsPage.warnAndErrItems;

  for i=1:numSelectedItems,
    columns = actionIndex:(actionIndex + actionLength - 1);
    row     = selectedItems(i);

    if any(row==noneItems) || ...
               (numSelectedItems > 1   && ...
                ((any(row==noneAndWarnItems) && strcmp(action, 'Error  ')) || ...
                 (any(row==warnAndErrItems) && strcmp(action, 'None   '))))
      % Do nothing, someone tried to set an item via a multi-selection
      % which isn't allowed.
      % Note: I'm not worrying about the single selection
      %       case as the listbox is responsible for disabling
      %       the none radio ctrl.
    else
      string(row,columns) = action;
    end

  end % for

  set(eventList, 'String', string);
end % bNewValue == 1

% end i_DiagnosticRadioCallback()


%******************************************************************************
% Function - Sync Diagnostics page.                                         ***
%******************************************************************************
function DialogUserData = i_SyncDiagnosticsPage( ...
    DialogFig,DialogUserData,syncWithModel)

Children         = DialogUserData.DiagnosticsPage.Children;
model            = DialogUserData.model;
ActionRadioGroup = DialogUserData.DiagnosticsPage.ActionRadioGroup;


%==============================================================================
% The code that makes sure that all enable/disable states are correct
% assumes that all controls start of in the enabled state.
%==============================================================================
childVect = struct2cell(Children);
childVect = [childVect{:}];

exclude = [
  Children.OptionsGroupBox'
  Children.ActionGroupBox'
  Children.EventsLabel];

childVect = setdiff(childVect,exclude);

set(childVect, 'Enable','on');


% Configure the diagnostic messages to show. The display string in the
% diagnostic page hass to be less than 26 characters to fit into the
% listbox.

if (syncWithModel),
  diagnosticMsgs = {
  %   { Display string, ...
  %     set_param item, Allowed settings, ...
  %     Tooltips }
  %
  %     123456789*123456789*123456789*123456
      {'----Solver Performance-------------', '', 'None', ''}, ...
      {'Algebraic loop', ...
       'AlgebraicLoopMsg', 'All', ...
       'Detect algebraic loops in the model'}, ...
      {'Block priority violation',  ...
       'BlockPriorityViolationMsg', 'Warning&Error', ...
       'Detect illegal block priority specifications'}, ...
      {'Min step size violation', ...
       'MinStepSizeMsg', 'Warning&Error', ...
       ['Detect a conflict between minimum machine step size and ' ...
        'integration tolerances']}, ...
      ...
      {'------Sample Time------------------', '', 'None', ''}, ...
      {'-1 sample time in source',  ...
       'InheritedTsInSrcMsg', 'All', ...
       'Detect inherited sample time in source blocks'}, ...
      {'Discrete used as continuous', ...
       'DiscreteInheritContinuousMsg', 'All', ...
       'Detect discrete block using continuous sample rate'}, ...
      {'MultiTask rate transition', ...
       'MultiTaskRateTransMsg', 'Warning&Error', ...
       'Detect invalid multiple task rate transition'}, ...
      {'SingleTask rate transition', ...
       'SingleTaskRateTransMsg', 'All', ...
       'Detect invalid single task rate transition'}, ...
      ...
      {'-----Data Checking-----------------', '', 'None', ''}, ...
      {'Check for singular matrix', ...
       'CheckForMatrixSingularity','All', ...
       'Detect singular matrix during matrix inversion in Product block'}, ...
      {'Data overflow', ...
       'IntegerOverflowMsg', 'All', ...
       'Detect runtime signal overflow condition'}, ...
      {'int32 to float conversion', ...
       'Int32ToFloatConvMsg', 'None&Warning', ...
       'Detect possible data precision loss when converting from int32 to float'}, ...
      {'Parameter downcast', ...
       'ParameterDowncastMsg', 'All', ...
       ['Detect data type downcast during conversion of block dialog ' ...
        'parameters to runtime parameters']}, ...
      {'Parameter overflow', ...
       'ParameterOverflowMsg', 'All', ...
       ['Detect overflow condition during conversion of block dialog ' ...
        'parameters to runtime parameters']}, ...
      {'Parameter precision loss', ...
       'ParameterPrecisionLossMsg', 'All', ...
       ['Detect precision loss during conversion of block dialog ' ...
        'parameters to runtime parameters']}, ...
      {'Underspecified data types', ...
       'UnderSpecifiedDataTypeMsg', 'All', ...
       'Detect usage of heuristics to assign signal data types'}, ...
      ...
      {'----Type Conversions---------------', '', 'None', ''}, ...
      {'Unneeded type conversions', ...
       'UnnecessaryDatatypeConvMsg', 'None&Warning',...
       'Detect unnecessary data type conversion blocks'}, ...
      {'Vector/Matrix conversion',  ...
       'VectorMatrixConversionMsg', 'All', ...
       'Detect vector to matrix or matrix to vector conversion'}, ...
      ...
      {'---Block Connectivity--------------', '', 'None', ''}, ...
      {'Invalid FcnCall connection', ...
       'InvalidFcnCallConnMsg', 'All', ...
       ['Detect illegal use of function-call subsystems.',sprintf('\n'),...
        'Setting this option to none or warning may cause',sprintf('\n'),...
        'Simulink to insert extra delay operations']}, ...
      {'Signal label mismatch', ...
       'SignalLabelMismatchMsg', 'All', ...
       'Detect when different signal labels map to the same source location'}, ...
      {'Unconnected block input', ...
       'UnconnectedInputMsg', 'All', ...
       'Detect unconnected block input ports'}, ...
      {'Unconnected block output',  ...
       'UnconnectedOutputMsg', 'All', ...
       'Detect unconnected block output ports'}, ...
      {'Unconnected line', ...
       'UnconnectedLineMsg', 'All', ...
       'Detect unconnected lines'}, ...
      ...
      {'--Backward Compatibility-----------', '', 'None', ''}, ...
      {'S-function upgrades needed', ...
       'SfunCompatibilityCheckMsg', 'All', ...
       'Detect S-functions that can be upgraded to use new features'}, ...
      ...
                   };

  events           = {};
  eventProps       = {};
  eventTooltips    = {};
  warnAndErrItems  = [];
  noneAndWarnItems = [];
  noneItems        = [];

  for i=1:length(diagnosticMsgs)
    item = diagnosticMsgs{i};
    events{end+1} = item{1};
    eventProps{end+1} = item{2};
    switch item{3}
     case 'None&Warning'
      noneAndWarnItems(end+1) = i;
     case 'Warning&Error'
      warnAndErrItems(end+1) = i;
     case 'All'
      % no action
     case 'None'
      noneItems(end+1) = i;
     otherwise
      error('Internal coding error - bad diagnosticMsgs setting');
    end
    eventTooltips{end+1} = item{4};
  end

  if strcmp(computer, 'PCWIN')
    eventStringWidth  = 28;
  else
    eventStringWidth  = 34;
  end
  actionIndex          = eventStringWidth + 1;
  actionStringWidth    = 7;
  totalStringWidth     = eventStringWidth + actionStringWidth;

  numevents   = length(eventProps);

  %============================================================================
  % Build list of all event settings.  This is the listbox string.  It looks
  % like:  'property name'    'property setting'
  %============================================================================
  spaceChar = 32;
  string = zeros(numevents, totalStringWidth) + spaceChar;

  for i=1:numevents,
    thisProp = events{i};
    string(i,1:length(thisProp)) = thisProp;

    if ~isempty(eventProps{i})
      thisVal = get_param(model, eventProps{i});
      thisVal(1) = upper(thisVal(1));
      string(i,actionIndex:actionIndex+length(thisVal)-1) = thisVal;
    else
      % it's a category item, fill it up with '---'
      string(i,actionIndex:actionIndex+6) = '-------';
    end
  end

  string = char(string);

  set(Children.EventsList, ...
    'String',         string, ...
    'Value',          []);
end

%==============================================================================
% Sync action radio buttons.
%==============================================================================
if syncWithModel,
  set(ActionRadioGroup, ...
    'Value',          0);
else
  i_DiagnosticListCallback(DialogFig, DialogUserData);
end

%==============================================================================
% Sync 'Consistency checking' popup.
%==============================================================================
if syncWithModel,
  str = get_param(model, 'ConsistencyChecking');
  val = popupStr2ValMatch(Children.ConsistencyPopup, str);

  set(Children.ConsistencyPopup, ...
    'Value',          val);
end

%==============================================================================
% Sync 'Bounds checking' popup.
%==============================================================================
if syncWithModel,
  str     = get_param(model, 'ArrayBoundsChecking');
  val = popupStr2ValMatch(Children.BoundsCheckPopup, str);

  set(Children.BoundsCheckPopup, ...
    'Value',          val);
end

%==============================================================================
% Update user data.
%==============================================================================
if syncWithModel,
  DialogUserData.DiagnosticsPage.eventProps       = eventProps;
  DialogUserData.DiagnosticsPage.eventTooltips    = eventTooltips;
  DialogUserData.DiagnosticsPage.actionIndex      = actionIndex;
  DialogUserData.DiagnosticsPage.warnAndErrItems  = warnAndErrItems;
  DialogUserData.DiagnosticsPage.noneAndWarnItems = noneAndWarnItems;
  DialogUserData.DiagnosticsPage.noneItems        = noneItems;
end


%==============================================================================
% Disable controls for ReadOnlyIfCompiledParams if we're not stopped.
%==============================================================================
if ~strcmp(get_param(model,'SimulationStatus'),'stopped'),

  handles = [
      Children.ConsistencyLabel
      Children.ConsistencyPopup
      Children.BoundsCheckLabel
      Children.BoundsCheckPopup];

  set(handles,'Enable','off');
end

% end  i_SyncDiagnosticsPage()


%******************************************************************************
% Function - Build prop/val pairs for Diagnostics page.                     ***
%******************************************************************************
function propValPairs = i_DiagnosticsPropValPairs(DialogUserData)

Children = DialogUserData.DiagnosticsPage.Children;

eventProps  = DialogUserData.DiagnosticsPage.eventProps;
actionIndex = DialogUserData.DiagnosticsPage.actionIndex;
noneItems   = DialogUserData.DiagnosticsPage.noneItems;

numProps = length(eventProps);
propValPairs = cell(1, numProps);

eventList   = Children.EventsList;
eventString = get(eventList, 'String');

idx = 1;
for i=1:numProps,
  if any(i==noneItems)
    % skip this line, grouping name
  else
    propIdx = 1 + ((idx-1)*2);
    valIdx  = propIdx + 1;

    propValPairs{propIdx} = eventProps{i};
    propValPairs{valIdx}  = eventString(i,actionIndex:end);
    idx = idx+1;
  end
end

%
% Consistency checking
%
strings = get(Children.ConsistencyPopup, 'String');
val     = get(Children.ConsistencyPopup, 'Value');
prop    = 'ConsistencyChecking';
propValPairs([end+1 end+2]) = {prop, strings{val}};

%
% Array bounds checking
%
strings = get(Children.BoundsCheckPopup, 'String');
val     = get(Children.BoundsCheckPopup, 'Value');
prop    = 'ArrayBoundsChecking';
propValPairs([end+1 end+2]) = {prop, strings{val}};

% end i_DiagnosticsPropValPairs()


%******************************************************************************
% Function - Convert action string to action number for diagnostics page.   ***
%   none = 1, warning = 2, error = 3                                        ***
%******************************************************************************
function idx = i_EventActStr2ActIdx(string)

switch(lower(string))
 case 'none   ',
  idx = 1;
 case 'warning',
  idx = 2;
 case 'error  ',
  idx = 3;
 otherwise,
  error('M assert: invalid action');
end

% end i_EventActStr2ActIdx()


%%%%%%%%%%%%%%%%%%%%%%%%%%% end Diagnostics page %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Advanced page %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% function DialogUserData = i_CreateAdvancedPage(DialogFig, DialogUD)         %
% function [extent,AdvancedCtrlPos] = i_AdvancedCtrlPositions( ... )  %
% function AdvancedGeom = i_CreateAdvancedGeom(commonGeom)            %
% function [DialogUserData, bModified] = i_ManageAdvancedPage(...)        %
% function i_InstallAdvancedCallbacks(DialogFig, DialogUserData)          %
% function i_AdvancedListCallback(DialogFig, DialogUserData)              %
% function i_AdvancedRadioCallback(DialogFig, DialogUserData)             %
% function DialogUserData = i_SyncAdvancedPage(DialogUserData)            %
% function propValPairs = i_AdvancedPropValPairs(DialogUserData)          %
% function idx = i_OnOffActStr2ActIdx(string)                                 %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%******************************************************************************
% Function - Create Advanced page.                                      ***
%******************************************************************************
function DialogUserData = i_CreateAdvancedPage(DialogFig, DialogUserData)

commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;

if isempty(DialogUserData.advancedCtrlPos)
  advancedGeom = i_CreateAdvancedGeom(commonGeom);

  [notUsed,DialogUserData.advancedCtrlPos] = i_AdvancedCtrlPositions( ...
      commonGeom, advancedGeom ...
      );
end

advancedCtrlPos = DialogUserData.advancedCtrlPos;

%
% 'Parameter options' group box
%
Children.OptionsGroupBox = groupbox( ...
    DialogFig, ...
    advancedCtrlPos.OptionsGroupBox, ...
    ' Model parameter configuration', ...
    textExtent ...
    );

%
% 'Inline paramters' check box
%
InlineTooltipStr = ...
    ['Treat block parameters (except for global/tunable parameters)' ...
     sprintf('\n') ...
     'as invariant for the duration of the simulation resulting in faster ' ...
     sprintf('\n') ...
     'model execution and smaller code size'];
Children.InlineCheckbox = uicontrol( ...
    'Parent',           DialogFig, ...
    'Style',            'checkbox', ...
    'String',           'Inline parameters', ...
    'Tag',              'RTWInlineParametersCheckbox', ...
    'Position',         advancedCtrlPos.InlineCheckbox, ...
    'Tooltip',          InlineTooltipStr ...
    );

%
% 'Configure...' button
%
ParamAttrTooltipStr = 'Define and configure global (tunable) parameters';
Children.ParamAttrButton = uicontrol( ...
    'Parent',           DialogFig, ...
    'Style',            'pushbutton', ...
    'String',           'Configure...', ...
    'Position',         advancedCtrlPos.ParamAttrButton, ...
    'Tooltip',          ParamAttrTooltipStr ...
    );

%
% Create 'Assertion Control' control.
%
AssertTooltipStr = ...
    ['Set the global control of the Model Verification blocks and' ...
     sprintf('\n') ...
     'the Assertion block'];
AssertPopupStr = ...
    { 'Use local settings'; 'Enable all'; 'Disable all'};
Children.AssertLabel = uicontrol( ...
    'Parent',         DialogFig, ...
    'Style',          'text', ...
    'String',         'Model Verification block control:', ...
    'Position',       advancedCtrlPos.AssertLabel, ...
    'Tooltip',        AssertTooltipStr ...
    );

Children.AssertPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'popupmenu', ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'String',             AssertPopupStr, ...
    'Position',           advancedCtrlPos.AssertPopup, ...
    'Tag',                'AssertionControlPopup', ...
    'Tooltip',            AssertTooltipStr ...
    );

%
% Create event label and listbox.
%
Children.EventLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             ' Optimizations:', ...
    'Position',           advancedCtrlPos.EventLabel ...
    );

Children.EventsList = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'listbox', ...
    'String',             'temp', ...
    'Tag',                'AdvancedListbox', ...
    'Fontname',           commonGeom.listboxFixedFontName, ...
    'Fontsize',           commonGeom.listboxFixedFontSize, ...
    'Position',           advancedCtrlPos.EventsList, ...
    'BackgroundColor',    'w', ...
    'Max',                2 ...
    );

%
% Create actions group.
%
Children.ActionGroupBox = groupbox( ...
    DialogFig, ...
    advancedCtrlPos.ActionGroupBox, ...
    ' Action', ...
    textExtent ...
    );

%
% Create radio buttons for actions.
%

%
% ... create strings for radio buttons.  They are padded with spaces
% for convenience.  These strings are used later to fill in
% the string for the listbox (fixed width font).
% See i_AdvancedRadioCallback.
%
strings = [
    'On '
    'Off'
	  ];

Children.OnRadio = uicontrol( ...
    'Parent',         DialogFig, ...
    'Style',          'radiobutton', ...
    'String',         strings(1,:), ...
    'Position',       advancedCtrlPos.OnRadio ...
    );

Children.OffRadio = uicontrol( ...
    'Parent',         DialogFig, ...
    'Style',          'radiobutton', ...
    'String',         strings(2,:), ...
    'Position',       advancedCtrlPos.OffRadio ...
    );

% Add Model Parameter Configuration dialog's figure handle initial.
DialogUserData.AdvancedPage.ParamAttrDlg  = -1;

% dividing line
Children.sepLine = uicontrol(...
    'Parent',             DialogFig, ...
    'Style',              commonGeom.dividingLineStyle, ...
    'Enable',             'inactive', ...
    'Position',           advancedCtrlPos.SepLine ...
    );
%
% 'Production hardware characteristics' label
%
Children.ProdHWCharsPrompt = uicontrol( ...
    'Parent',           DialogFig, ...
    'Style',            'text', ...
    'String',           'Production hardware characteristics:', ...
    'Tag',              'ProdHWCharsPrompt', ...
    'Position',         advancedCtrlPos.ProdHWCharsPrompt ...
    );

prodHWTooltipStr = ...
    sprintf(['Specify the intended production hardware target. Selecting\n' ...
             'Microprocessor enables you to specify C language word lengths.\n'...
             'In turn, appropriate word lengths are selected for intermediate\n' ...
             'computations. When selecting Unconstrained integer sizes, word\n' ...
             'lengths are not specified. Use this for targets where any word\n' ...
             'length is intrinsically supported, such as in an ASIC/FPGA.']);
ProdHWCharsPopupStr = {'Microprocessor';'Unconstrained integer sizes'};
Children.ProdHWCharsPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'popupmenu', ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'String',             ProdHWCharsPopupStr, ...
    'Position',           advancedCtrlPos.ProdHWCharsPopup, ...
    'Tooltip',            prodHWTooltipStr, ...
    'Tag',                'ProdHWCharsPopup' ...
    );

% 'Word length' listbox
Children.WordLengthList = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'listbox', ...
    'Max',                2, ...
    'BackgroundColor',    'w', ...
    'Fontname',           commonGeom.listboxFixedFontName, ...
    'Fontsize',           commonGeom.listboxFixedFontSize, ...
    'Position',           advancedCtrlPos.WordLengthList, ...
    'Tag',                'WordLengthList' ...
    );

Children.WordLengthPrompt = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             ' Value: ', ...
    'Position',           advancedCtrlPos.WordLengthPrompt, ...
    'Tag',                'WordLengthPrompt' ...
    );

Children.WordLengthEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'edit', ...
    'String',             '', ...
    'Enable',             'off', ...
    'Position',           advancedCtrlPos.WordLengthEdit, ...
    'Tag',                'WordLengthEdit' ...
    );

%
% Update user data.
%
DialogUserData.advancedCtrlPos = [];
DialogUserData.AdvancedPage.Children = Children;

DialogUserData.AdvancedPage.ActionRadioGroup = [
    Children.OnRadio
    Children.OffRadio
		   ];

% end i_CreateAdvancedPage()


%******************************************************************************
% Function - Calculate positions for all Advanced ctrls & return total  ***
%  extent of all controls ([width height]).                                 ***
%                                                                           ***
% It is assumed that the sheet position is now known (based on solver       ***
%   page), so we work from the top down.                                    ***
%******************************************************************************
function [extent,advancedCtrlPos] = i_AdvancedCtrlPositions( ...
    commonGeom, advancedGeom )

sheetPos  = commonGeom.sheetPos;
sheetTop  = sheetPos(2) + sheetPos(4);
sheetLeft = sheetPos(1);

%
% Calculate the size of the groupbox that includes:
%  1. inline parameter checkbox;
%  2. workspace parameter attributes button;
%
% 'Parameter options' group box
%
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
frameHeight = commonGeom.frameTopEdgeBuffer + ...
    commonGeom.editHeight                   + ...
    commonGeom.frameBottomEdgeBuffer;

cyCur = sheetTop - frameHeight - commonGeom.sheetTopEdgeBuffer;
frameBottom = cyCur;

frameWidth  = sheetPos(3) - 2*commonGeom.sheetSideEdgeBuffer;
frameLeft   = cxCur;
frameRight  = frameLeft + frameWidth;

advancedCtrlPos.OptionsGroupBox = ...
    [frameLeft frameBottom frameWidth frameHeight];

%
% 'Inline paramters' check box
%
cxCur = cxCur + commonGeom.frameSideEdgeBuffer;
cyCur = cyCur + commonGeom.frameBottomEdgeBuffer;

advancedCtrlPos.InlineCheckbox = [cxCur cyCur ...
		    advancedGeom.inlineCheckboxWidth ...
		    commonGeom.editHeight];

%
% 'Configure...' button
%
cxCur = cxCur + ...
	advancedGeom.inlineCheckboxWidth + ...
	commonGeom.sheetSideEdgeBuffer;

advancedCtrlPos.ParamAttrButton = [cxCur cyCur ...
		    advancedGeom.paramAttrButtonWidth ...
		    commonGeom.editHeight];


%
% 'General options:' label
%
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
cyCur = frameBottom - commonGeom.editHeight - commonGeom.sheetTopEdgeBuffer/2;
advancedCtrlPos.EventLabel = [cxCur cyCur ...
      advancedGeom.eventLabelWidth, commonGeom.editHeight];

%
% General options list box.
%
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
cyCur = frameBottom - commonGeom.editHeight - ...
	commonGeom.sheetBottomEdgeBuffer/2 - advancedGeom.eventListHeight;

listBoxBottom = cyCur;
listBoxTop    = cyCur + advancedGeom.eventListHeight;
listBoxLeft   = cxCur;
listBoxWidth  = ...
    sheetPos(3) - 3 * commonGeom.sheetSideEdgeBuffer - ...
    (commonGeom.frameSideEdgeBuffer * 2) - ...
    advancedGeom.radiobuttonWidth;

advancedCtrlPos.EventsList = [cxCur cyCur ...
      listBoxWidth advancedGeom.eventListHeight];

%
% Action groupbox.
%
frameHeight = ...
    commonGeom.frameTopEdgeBuffer       + ...
    (commonGeom.radiobuttonHeight * 2)  + ...
    advancedGeom.rowDelta           + ...
    commonGeom.frameBottomEdgeBuffer;

frameWidth = ...
    (commonGeom.frameSideEdgeBuffer * 2) + advancedGeom.radiobuttonWidth;

frameBottom = listBoxTop - frameHeight;

frameLeft = ...
    sheetPos(1) + sheetPos(3)      - ...
    commonGeom.sheetSideEdgeBuffer - ...
    frameWidth;

framePos = [frameLeft frameBottom frameWidth frameHeight];

advancedCtrlPos.ActionGroupBox = ...
    [frameLeft frameBottom frameWidth frameHeight];


%
% Action radio buttons.
%

cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;

cyCur = ...
    frameBottom + frameHeight     - ...
    commonGeom.frameTopEdgeBuffer - ...
    commonGeom.radiobuttonHeight;

advancedCtrlPos.OnRadio = [cxCur cyCur ...
		    advancedGeom.radiobuttonWidth ...
		    commonGeom.radiobuttonHeight];

cyCur = cyCur - advancedGeom.rowDelta - commonGeom.radiobuttonHeight;
advancedCtrlPos.OffRadio = [cxCur cyCur ...
		    advancedGeom.radiobuttonWidth ...
		    commonGeom.radiobuttonHeight];

%
% Assertion Control label & popup.
%
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
cyCur = listBoxBottom - commonGeom.editHeight - ...
	commonGeom.sheetBottomEdgeBuffer;

advancedCtrlPos.AssertLabel = [cxCur cyCur ...
		    advancedGeom.assertLabelWidth ...
		    commonGeom.textHeight];

cxCur = cxCur + advancedGeom.assertLabelWidth;
advancedCtrlPos.AssertPopup = [cxCur cyCur ...
		    advancedGeom.assertPopupWidth ...
		    commonGeom.popupHeight];

%
% Dividing line.
%
lineWidth = sheetPos(3) - (2 * commonGeom.sheetSideEdgeBuffer);

cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
cyCur = cyCur - commonGeom.sheetBottomEdgeBuffer;
advancedCtrlPos.SepLine = [cxCur cyCur lineWidth commonGeom.lineThickness];

% 'Production hardware characteristics' label and popup
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
cyCur = cyCur - commonGeom.popupHeight - ...
	commonGeom.sheetBottomEdgeBuffer;
advancedCtrlPos.ProdHWCharsPrompt = [cxCur cyCur ...
                    advancedGeom.prodHWCharsWidth ...
                    commonGeom.textHeight];

% popup menu
cxCur = cxCur + advancedGeom.prodHWCharsWidth + commonGeom.sheetSideEdgeBuffer;
advancedCtrlPos.ProdHWCharsPopup = [cxCur cyCur ...
                    (sheetPos(3) - 3*commonGeom.sheetSideEdgeBuffer - ...
                     advancedGeom.prodHWCharsWidth) ...
                    commonGeom.popupHeight];

%
% Word length info listbox
%
cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
cyCur = sheetPos(2) + commonGeom.sheetBottomEdgeBuffer;
frameHeight = advancedCtrlPos.ProdHWCharsPopup(2) - ...
    2*commonGeom.frameBottomEdgeBuffer - sheetPos(2);
frameWidth  = sheetPos(3) - 3*commonGeom.sheetSideEdgeBuffer - ...
    advancedCtrlPos.ActionGroupBox(3);
advancedCtrlPos.WordLengthList = [cxCur cyCur ...
                    frameWidth frameHeight];

% 'Value: ' prompt
cxCur = advancedCtrlPos.ActionGroupBox(1);
%cxCur = cxCur + frameWidth + commonGeom.sheetSideEdgeBuffer;
cyCur = cyCur + frameHeight - commonGeom.textHeight;
advancedCtrlPos.WordLengthPrompt = [cxCur cyCur ...
                    advancedGeom.valuePromptWidth commonGeom.textHeight];

% word length edit
cyCur = cyCur - commonGeom.editHeight;
advancedCtrlPos.WordLengthEdit = [cxCur cyCur ...
                    advancedGeom.ValueEditWidth commonGeom.editHeight];

%
% Extents.
%
% NOTE: The extent should never be used as the sheet dimensions
%  are defined by the solver page.  I'm setting it to NaN so that
%  if I ever try to use it, it will cause an obvious mistake.
%
extent = NaN;

% end i_AdvancedCtrlPositions()


%******************************************************************************
% Function - Create geometry constants for Advanced page.               ***
%******************************************************************************
function advancedGeom = i_CreateAdvancedGeom(commonGeom)

sysOffsets = commonGeom.sysOffsets;
textExtent = commonGeom.textExtent;

advancedGeom.rowDelta             = 5;
advancedGeom.groupBoxListBoxDelta = 6;
advancedGeom.eventLabelWidth      = 68  + sysOffsets.text(3);
advancedGeom.eventListHeight      = 60 + sysOffsets.listbox(4);

set(textExtent, 'String', 'Use local settings ');
ext = get(textExtent, 'Extent');
maximalWidth = ext(3);
advancedGeom.radiobuttonWidth = ext(3) + sysOffsets.radiobutton(3);

set(textExtent, 'String', 'Inline parameters ');
ext = get(textExtent, 'Extent');
advancedGeom.inlineCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Configure...');
ext = get(textExtent, 'Extent');
advancedGeom.paramAttrButtonWidth = ext(3) + sysOffsets.pushbutton(3);

set(textExtent, 'String', 'Model Verification block control: ');
ext = get(textExtent, 'Extent');
advancedGeom.assertLabelWidth = ext(3);
advancedGeom.assertPopupWidth = maximalWidth + sysOffsets.popupmenu(3);

set(textExtent, 'String', 'Optimizations: ');
ext = get(textExtent, 'Extent');
advancedGeom.eventLabelWidth = ext(3);

set(textExtent, ...
    'String',   'Unconnected block output   Warning', ...
    'FontName', commonGeom.listboxFixedFontName, ...
    'FontSize', commonGeom.listboxFixedFontSize ...
    );
ext = get(textExtent, 'Extent');
set(textExtent, ...
    'FontName',   get(0, 'FactoryUicontrolFontname'), ...
    'FontSize',   get(0, 'FactoryUicontrolFontsize') ...
    );
advancedGeom.eventListWidth = ext(3) + sysOffsets.listbox(3);

set(textExtent, 'String', 'Off');
ext = get(textExtent, 'Extent');
warningWidth = ext(3);
advancedGeom.radiobuttonWidth = ext(3) + sysOffsets.radiobutton(3);

set(textExtent, 'String', 'Production hardware characteristics:');
ext = get(textExtent, 'Extent');
advancedGeom.prodHWCharsWidth = ext(3);

set(textExtent, 'String', 'Value:');
ext = get(textExtent, 'Extent');
advancedGeom.valuePromptWidth = ext(3)+ sysOffsets.listbox(3);

set(textExtent, 'String', '12345');
ext = get(textExtent, 'Extent');
advancedGeom.ValueEditWidth = ext(3)+ sysOffsets.edit(3);

% end i_CreateAdvancedGeom()


%******************************************************************************
% Function - Manage callbacks for Advanced page.                        ***
%******************************************************************************
function [DialogUserData, bModified] = i_ManageAdvancedPage(...
    DialogFig, DialogUserData, Action)

bModified = 0;
Children  = DialogUserData.AdvancedPage.Children;
model     = DialogUserData.model;

switch(Action)

 case 'ActionRadio',
  %==================================================================
  % Action radio buttons.
  %==================================================================
  i_AdvancedRadioCallback(DialogFig, DialogUserData);
  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

 case 'eventsList',
  %==================================================================
  % Action radio buttons.
  %==================================================================
  i_AdvancedListCallback(DialogFig, DialogUserData);
  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

 case 'Inline'
  %
  % This callback function will allow user to turn on the model parameter
  % configuration dialog button. Apply button will be enabled as
  % soon as you click Inline parameter checkbox.
  %
  inlineCheckbox  = Children.InlineCheckbox;
  paramAttrButton = Children.ParamAttrButton;

  %
  % Invoke Apply button when click inlineCheckbox
  %
  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

  %
  % Enable the "Configure..." button when
  % inlineCheckbox is on;
  % On RTW page under Common code generation options category,
  % the Inline invariant signal checkbox will be switched on/off
  % as well.
  %
  objTag = 'Inline invariant signals_CheckboxTag';
  obj = findobj(DialogFig,'Tag', objTag);
  obj = [obj
         paramAttrButton];

  %
  % On RTW E-coder options category page 2 or 3, the
  % Inlined parameter placement switch box will be swiched on/off
  % as well.
  %
  obj0Tag = 'Parameter structure_PopupFieldTag';
  obj0 = findobj(DialogFig,'Tag',obj0Tag);

  if ~isempty(obj0) && all(ishandle(obj))
    obj = [obj
           obj0];
  end

  if get(inlineCheckbox, 'Value') == 1
    set(obj, 'Enable', 'on');
  else
    set(obj, 'Enable', 'off');

    %
    % Probably need to disable all related children, but need to discuss
    % with others more.
    %
    if usejava('MWT')
      if ishandle(DialogUserData.AdvancedPage.ParamAttrDlg)
	set(DialogUserData.AdvancedPage.ParamAttrDlg, 'Visible', 'off');
      end
    else
      if DialogUserData.AdvancedPage.ParamAttrDlg ~= -1
	set(DialogUserData.AdvancedPage.ParamAttrDlg, 'Visible', 'off');
      end
    end

  end

  set(DialogFig, 'UserData', DialogUserData);

 case 'ParamAttributes'
  %
  % Invoke Model Parameter Configuration dialog box
  % function tunable_param_dlg.
  %

  %
  % Invoke Apply button when click 'Configure...' button
  %
  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

  % store the current warning state
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  errmsg = [];
  if ~isempty(DialogUserData)
    set(Children.ParamAttrButton,'enable','off');
  end

  dlgID = DialogUserData.AdvancedPage.ParamAttrDlg;

  defaultPointer = get(DialogFig, 'Pointer');
  set(DialogFig, 'Pointer', 'watch');

  if usejava('MWT')
    if ~ishandle(dlgID)
      eval(['dlgID = slwsprmattrib(''Create'',model,' ...
	    'DialogUserData.AdvancedPage.Children);'], ...
	   'errmsg = lasterr;');
    else
      eval(['dlgID = slwsprmattrib(''reshow'',model,' ...
	    'DialogUserData.AdvancedPage.Children,dlgID);'], ...
	   'errmsg = lasterr;');
    end
  else
    if dlgID == -1
      eval(['dlgID = tunable_param_dlg(''Create'',model,' ...
	    'DialogUserData.AdvancedPage.Children, dlgID, DialogFig);'], ...
	   'errmsg = lasterr;');
    else
      eval(['dlgID = tunable_param_dlg(''reshow'',model,' ...
	    'DialogUserData.AdvancedPage.Children,dlgID);'], ...
	   'errmsg = lasterr;');
    end

  end

  set(DialogFig, 'Pointer', defaultPointer);

  if ~isempty(DialogUserData)
    set(Children.ParamAttrButton,'enable','on');
  end

  DialogUserData.AdvancedPage.ParamAttrDlg = dlgID;
  set(DialogFig, 'UserData', DialogUserData);

  % restore the warning state
  warning(warningState);

  if ~isempty(errmsg)
    errmsg = ...
	['Error loading ''Model parameter configuration'' setting dialog:' ...
	 errmsg];
    errordlg(errmsg, 'Error');
  end

 case 'ProdHWChars'
  Children = DialogUserData.AdvancedPage.Children;
  val = get(Children.ProdHWCharsPopup, 'String');
  idxVal = get(Children.ProdHWCharsPopup, 'Value');
  val = val{idxVal, :};

  % need to update the listbox to reflect the change
  bitsInfoStr = '';

  % eventually, this information should be parsed from the UDD object dynamically.
  switch val
   case 'Microprocessor'
    bitsInfoStr = {'Number of bits for C ''char''';  ...
                   'Number of bits for C ''short'''; ...
                   'Number of bits for C ''int'''; ...
                   'Number of bits for C ''long'''};
   case 'Unconstrained integer sizes'
    % in this case, there is no word length need to be specified
   otherwise
    % other device type
  end

  if isempty(bitsInfoStr)
    set(Children.WordLengthList, 'Enable', 'off', ...
                      'BackgroundColor', get(DialogFig, 'Color'));
    set(Children.WordLengthEdit, 'Enable', 'off', ...
                      'BackgroundColor', get(DialogFig, 'Color'), ...
                      'String', '');
    set(Children.WordLengthPrompt, 'Enable', 'off');
    string = '';
  else
    set(Children.WordLengthList, 'Enable', 'on', ...
                      'BackgroundColor', 'w');
    if isempty(get(Children.WordLengthList, 'Value'))
      set(Children.WordLengthEdit,   'Enable', 'off', ...
                        'BackgroundColor', get(DialogFig, 'Color'));
    else
      set(Children.WordLengthEdit, 'Enable', 'on', ...
                        'BackgroundColor', 'w');
    end
    set(Children.WordLengthPrompt, 'Enable', 'on');

    numProps = length(bitsInfoStr);
    correspondingValue = get_param(model, 'ProdHWWordLengths');

    string = WordLengthsDataStringParsing(bitsInfoStr, correspondingValue);
  end

  set(Children.WordLengthList, ...
      'String',         string, ...
      'Value',          []);

  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

 case 'WordLengthList'
  Children = DialogUserData.AdvancedPage.Children;
  wordLengthList = Children.WordLengthList;
  wordLengthEdit = Children.WordLengthEdit;

  valueIndex = 32; % hard-coded for now
  selectedItems    = get(wordLengthList, 'Value');
  numSelectedItems = length(selectedItems);

  if numSelectedItems == 0,
    %=======================================================================
    % No items are selected, turn off all radio buttons.
    %=======================================================================
    set(wordLengthEdit, 'Enable', 'off', 'String', '');
  elseif numSelectedItems > 1,
    %=======================================================================
    % Multi selection case.
    %=======================================================================
    string = get(wordLengthList, 'String');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Retrieve value for all selections.
    % I'm using the magic number of 4, here.  It is the length of
    % '1234'.  This is done because these are padded strings.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    actions = char(zeros(numSelectedItems,3));
    for i=1:numSelectedItems,
      columns = valueIndex:valueIndex + 2;
      row     = selectedItems(i);

      actions(i,:) = string(row, columns);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If all the values are the same, display
    %  the value. If not, display empty.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bSameActions = all(all((diff(abs(actions))) == 0));

    set(wordLengthEdit, 'Enable', 'on', 'Background', 'white');
    if bSameActions,
      action    = actions(1,:);
      set(wordLengthEdit, 'String', deblankall(action));
    else
      set(wordLengthEdit, 'String', '');
    end

  else
    %=======================================================================
    % Single selection.
    %=======================================================================
    string  = get(wordLengthList, 'String');
    row     = selectedItems;
    columns = valueIndex:valueIndex + 2;

    action = string(row, columns);
    set(wordLengthEdit, 'Enable', 'on', ...
        'Background', 'white', ...
        'String', deblankall(action));
  end

  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

 case 'WordLengthEdit'
  Children = DialogUserData.AdvancedPage.Children;
  wordLengthList = Children.WordLengthList;
  wordLengthEdit = Children.WordLengthEdit;

  spaceChar  = 32;
  valueIndex = 32; % hard-coded for now
  selectedItems    = get(wordLengthList, 'Value');
  numSelectedItems = length(selectedItems);

  string = get(wordLengthList, 'String');
  value = deblankall(get(wordLengthEdit, 'String'));

  % error checking for the input value
  inputNum = str2num(value);
  if isempty(inputNum) || ...
        (~isnumeric(inputNum) || length(value) > 4 || ...
         inputNum < 0 || floor(inputNum) ~= inputNum || ...
         isnan(inputNum))
    errordlg(...
        sprintf(['Number of bits should be entered as a positive ' ...
                 'numerical integer with less than 4 digits.']));
    set(wordLengthEdit, 'String','');
    return;
  end

  if length(value) > 4
    value = value(1:4);
  elseif length(value) < 4
    value = [value char(repmat(spaceChar, 1, 4-length(value)))];
  end

  for i=1:numSelectedItems
    columns = valueIndex : (valueIndex+length(value)-1);
    row = selectedItems(i);

    string(row, columns) = value;
  end
  set(wordLengthList, 'String', string);
  set(wordLengthEdit, 'String', deblank(value));

  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

 otherwise,
  %==================================================================
  % Unhandled case.
  %==================================================================
  error('M assert: invalid action');
end

% end i_ManageAdvancedPage()


%******************************************************************************
% Function - Install callbacks for Advanced page.                        ***
%******************************************************************************
function i_InstallAdvancedCallbacks(DialogFig, DialogUserData)

Children = DialogUserData.AdvancedPage.Children;
ActionRadioGroup = DialogUserData.AdvancedPage.ActionRadioGroup;

%==============================================================================
% Inline parameter checkbox.
%==============================================================================
set(Children.InlineCheckbox, ...
    'Callback', 'simprm(''AdvancedPage'', ''Inline'', gcbf)' ...
    );

%==============================================================================
% Inline parameters configure button.
%==============================================================================
set(Children.ParamAttrButton, ...
    'Callback', 'simprm(''AdvancedPage'', ''ParamAttributes'', gcbf)' ...
    );

%==============================================================================
% action radio buttons.
%==============================================================================
set(ActionRadioGroup, ...
    'Callback', 'simprm(''AdvancedPage'', ''ActionRadio'', gcbf)' ...
    );

%==============================================================================
% options listbox;
%==============================================================================
set(Children.EventsList, ...
    'Callback', 'simprm(''AdvancedPage'', ''eventsList'', gcbf)' ...
    );

%==============================================================================
% Assertion Mode popup.
%==============================================================================
set(Children.AssertPopup, 'Callback', 'simprm(''EnableApply'', gcbf)' );

%==============================================================================
% ProdHWChars popup.
%==============================================================================
set(Children.ProdHWCharsPopup, 'Callback', ...
                  'simprm(''AdvancedPage'', ''ProdHWChars'', gcbf)' );

%==============================================================================
% Value change for word length info
%==============================================================================
set(Children.WordLengthList, 'Callback', ...
                  'simprm(''AdvancedPage'', ''WordLengthList'', gcbf)' );

set(Children.WordLengthEdit, 'Callback', ...
                  'simprm(''AdvancedPage'', ''WordLengthEdit'', gcbf)' );

% end i_InstallAdvancedCallbacks()


%******************************************************************************
% Function - Handle callback for listbox on Advanced page.              ***
%******************************************************************************
function i_AdvancedListCallback(DialogFig, DialogUserData)

Children = DialogUserData.AdvancedPage.Children;

eventList        = Children.EventsList;
eventTooltips    = DialogUserData.AdvancedPage.eventTooltips;
ActionRadioGroup = DialogUserData.AdvancedPage.ActionRadioGroup;

actionIndex = DialogUserData.AdvancedPage.actionIndex;

selectedItems    = get(eventList, 'Value');
numSelectedItems = length(selectedItems);

%onItems  = DialogUserData.AdvancedPage.onItems;
%offItems = DialogUserData.AdvancedPage.offItems;

%==============================================================================
% Handle differently if multi - selection.
%==============================================================================
if numSelectedItems == 0,
  %=======================================================================
  % No items are selected, turn off all radio buttons.
  %=======================================================================
  set(ActionRadioGroup, 'Enable', 'off', 'Value', 0);
elseif numSelectedItems > 1,
  %=======================================================================
  % Multi selection case.
  %=======================================================================
  string = get(eventList, 'String');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Retrieve actions for all selections.
  % I'm using the magic number of 3, here.  It is the length of
  % 'off'.  This is done because these are padded strings.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  actions = char(zeros(numSelectedItems,3));
  for i=1:numSelectedItems,
    columns = actionIndex:actionIndex + 2;
    row     = selectedItems(i);

    actions(i,:) = string(row, columns);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % If all the actions are the same, turn on
  %  the appropriate radio button.  If not,
  %  turn off all radio buttons.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  bSameActions = all(all((diff(abs(actions))) == 0));

  if bSameActions,
    action    = actions(1,:);
    actionNum = i_OnOffActStr2ActIdx(action);

    i_RadioBehaviorWithPress(ActionRadioGroup, ActionRadioGroup(actionNum));
  else
    set(ActionRadioGroup, 'Value', 0);
  end

  % make sure that the action buttons are enabled
  set(ActionRadioGroup, 'Enable', 'on');

else
  %=======================================================================
  % Single selection.
  %=======================================================================
  string  = get(eventList, 'String');
  row     = selectedItems;
  columns = actionIndex:actionIndex + 2;

  action = string(row, columns);
  actionNum = i_OnOffActStr2ActIdx(action);
  i_RadioBehaviorWithPress(ActionRadioGroup, ActionRadioGroup(actionNum));

  % all items listed in the box are subjected to change to 'on' or 'off'
  set(ActionRadioGroup, 'Enable', 'on');

  set(eventList, 'Tooltip', eventTooltips{row});
end

% end i_AdvancedListCallback()


%******************************************************************************
% Function - Handle callback for action radio button on Advanced page.    ***
%******************************************************************************
function i_AdvancedRadioCallback(DialogFig, DialogUserData)

Children = DialogUserData.AdvancedPage.Children;

eventList        = Children.EventsList;
ActionRadioGroup = DialogUserData.AdvancedPage.ActionRadioGroup;
pressedRadio     = gcbo;

actionIndex = DialogUserData.AdvancedPage.actionIndex;

%==============================================================================
% Implement radio behavior.
%==============================================================================
bNewValue = i_RadioBehavior(ActionRadioGroup, pressedRadio);

%==============================================================================
% Build new listbox string.
%==============================================================================
if bNewValue == 1,
  string           = get(eventList, 'String');
  selectedItems    = get(eventList, 'Value');
  numSelectedItems = length(selectedItems);

  action = get(pressedRadio, 'String');
  actionLength = length(action);

  for i=1:numSelectedItems,
    % Special handling to turn 'Local block outputs' on/off in RTW
    % page's code generation options according to 'Signal storage
    % reuse' (a.k.a) Optimize block I/O storage.  Also, controls
    % buffer reuse and expression folding settings.
    if ~isempty(findstr(string(selectedItems(i)), 'Signal storage reuse'))
      % buffer reuse
      objTag = 'Buffer reuse_CheckboxTag';
      brObj = findobj(DialogFig,'Tag',objTag);

      if ~isempty(brObj)
	set(brObj, 'Enable', action);
      end

      % local block outputs
      objTag = 'Local block outputs_CheckboxTag';
      lboObj = findobj(DialogFig,'Tag',objTag);

      if ~isempty(lboObj)
	set(lboObj, 'Enable', action);
      end

      if ~isempty(lboObj)
	% expression folding
	objTag = 'Expression folding_CheckboxTag';
	obj = findobj(DialogFig,'Tag',objTag);

	if ~isempty(obj)
	  set(obj, 'Enable', action);
	end

	% fold unrolled vectors
	objTag = 'Fold unrolled vectors_CheckboxTag';
	obj = findobj(DialogFig,'Tag',objTag);

	if ~isempty(obj)
	  set(obj, 'Enable', action);
	end

	% enforce integer downcast
	objTag = 'Enforce integer downcast_CheckboxTag';
	obj = findobj(DialogFig,'Tag',objTag);

	if ~isempty(obj)
	  set(obj, 'Enable', action);
	end
      end
    end

    % change 'on/off' string inside listbox
    columns = actionIndex:(actionIndex + actionLength - 1);
    row     = selectedItems(i);

    string(row,columns) = action;

  end % for

  set(eventList, 'String', string);
end % bNewValue == 1

% according to current implementation, the onItems/offItems
% cache may not be needed. Leave this code here for potential usage
% in the future.
% onItems  = DialogUserData.AdvancedPage.onItems;
% offItems = DialogUserData.AdvancedPage.offItems;

% end i_AdvancedRadioCallback()


%******************************************************************************
% Function - Sync Advanced page.                                        ***
%******************************************************************************
function DialogUserData = i_SyncAdvancedPage( ...
    DialogFig,DialogUserData,syncWithModel)

Children         = DialogUserData.AdvancedPage.Children;
model            = DialogUserData.model;
ActionRadioGroup = DialogUserData.AdvancedPage.ActionRadioGroup;

childVect = struct2cell(Children);
childVect = [childVect{:}];

exclude = [
    Children.OptionsGroupBox'
    Children.sepLine
    Children.EventLabel
    Children.ActionGroupBox'];

childVect = setdiff(childVect,exclude);

%==============================================================================
% The code that makes sure that all enable/disable states are correct
% assumes that all controls start of in the enabled state.
%==============================================================================
set(childVect, 'Enable','on');

%==============================================================================
% Sync inline parameters checkbox.
%==============================================================================
if syncWithModel,
  bValue = onoff(get_param(model, 'RTWInlineParameters'));
  set(Children.InlineCheckbox, ...
    'Value',      bValue);
end

if get( Children.InlineCheckbox, 'Value') == 1
  set(Children.ParamAttrButton, ...
      'Enable',    'on');
else
  set(Children.ParamAttrButton, ...
      'Enable',    'off');
end

if syncWithModel,

  % Configure the Advanced messages to show. The display string in the
  % Advanced page hass to be less than 26 characters to fit into the
  % listbox.
  cr = sprintf('\n');
  condExecOpt = 'Conditional input branch';
  optimizationMsgs = {...
      {'Block reduction',        'BlockReductionOpt',         'on', ...
       ['Replaces groups of blocks with a synthesized', cr, ...
        'block resulting in faster execution']}, ...
      {'Boolean logic signals',  'BooleanDataType',           'off', ...
       ['Use boolean data-type instead of double for logical signals in ', ...
        'Logical Operator,', cr, ...
        'Combinational Logic, Relational Operator and Hit Crossing blocks']}, ...
      {condExecOpt, 'ConditionallyExecuteInputs', ...
       'on', ...
       ['If a block conditionally needs its input signal, e.g., Switch ', ...
        'block, only', cr, 'execute blocks that are providing the input ', ...
        'signal when this input is needed.']}, ...
      {'Parameter pooling','ParameterPooling',                'on', ...
       ['Group identical parameters in to one memory ',...
        'storage location when inline parameters is on']}, ...
      {'Signal storage reuse',   'OptimizeBlockIOStorage',    'on', ...
       ['When possible, reuse memory storage locations for block signals', ...
        cr, '(i.e., map multiple signals to the same storage location)']}, ...
      {'Zero crossing detection','ZeroCross',                 'on',   ...
       ['Locates time points of interest for blocks with intrinsic', ...
        cr, 'zero crossings running under a variable step solver']}...
                     };
%      {'R13 solver module', 'R13SolverModule', 'off', ...
%       ['Use the new solver module. When ''off'', Simulink uses the ', ...
%        'pre-R13 solver ', cr, 'module. This option is provided for ', ...
%        'backwards compatibility and will be ', cr, ...
%        'removed in a future release.']},

  events        = {};
  eventProps    = {};
  eventTooltips = {};
  onItems       = [];
  offItems      = [];

  for i=1:length(optimizationMsgs)
    item = optimizationMsgs{i};
    events{end+1} = item{1};
    eventProps{end+1} = item{2};
    %switch item{3}
    %  case 'on'
    %    onItems(end+1) = i;
    %  case 'off'
    %    offItems(end+1) = i;
    %  otherwise
    %    error('Internal coding error - bad optimizationMsgs setting');
    %end
    eventTooltips{end+1}=item{4};
  end

  if strcmp(computer, 'PCWIN')
    eventStringWidth  = 34;
  else
    eventStringWidth  = 40;
  end
  actionIndex       = eventStringWidth + 1;
  actionStringWidth = 3;
  totalStringWidth  = eventStringWidth + actionStringWidth;

  numevents   = length(eventProps);

  %============================================================================
  % Build list of all event settings.  This is the listbox string.  It looks
  % like:  'property name'    'property setting'
  %============================================================================
  spaceChar = 32;
  string = repmat(spaceChar, numevents, totalStringWidth);

  for i=1:numevents,
    thisProp = events{i};
    string(i,1:length(thisProp)) = thisProp;

    thisVal = get_param(model, eventProps{i});
    thisVal(1) = upper(thisVal(1));
    string(i,actionIndex:actionIndex+length(thisVal)-1) = thisVal;
  end

  string = char(string);

  set(Children.EventsList, ...
    'String',         string, ...
    'Value',          []);
end

%==============================================================================
% Sync action radio buttons.
%==============================================================================
if syncWithModel,
  set(ActionRadioGroup, ...
    'Value',          0);
else
  i_AdvancedListCallback(DialogFig, DialogUserData);
end

%==============================================================================
% Update Assertion control
%==============================================================================
if syncWithModel
  val = get_param(model, 'AssertionControl');
  idxVal = popupStr2ValMatch(Children.AssertPopup, val);
  set(Children.AssertPopup, 'Value', idxVal);
end

%==============================================================================
% Update Word length infomation
%==============================================================================
if syncWithModel
  val = get_param(model, 'ProdHWDeviceType');
  if ~strcmp(val, 'ASIC/FPGA')
    val = 'Microprocessor';
    idxVal = 1;
  else
    idxVal = 2;
  end
  set(Children.ProdHWCharsPopup, 'Value', idxVal);

  % need to update the listbox to reflect the change
  bitsInfoStr = '';

  % check the UDD object (need to change to the latest one)
  switch val
   case 'Microprocessor'
    bitsInfoStr = {'Number of bits for C ''char''';  ...
                   'Number of bits for C ''short'''; ...
                   'Number of bits for C ''int'''; ...
                   'Number of bits for C ''long'''};
   case 'ASIC/FPGA'
    % in this case, there is no word length need to be specified
   otherwise
    % other device type
  end

  if isempty(bitsInfoStr)
    set(Children.WordLengthList,   'Enable', 'off', ...
                      'BackgroundColor', get(DialogFig, 'Color'));
    set(Children.WordLengthEdit,   'Enable', 'off', ...
                      'BackgroundColor', get(DialogFig, 'Color'));
    set(Children.WordLengthPrompt, 'Enable', 'off');
    string = '';
  else
    set(Children.WordLengthList,   'Enable', 'on', ...
                      'BackgroundColor', 'w');
    if isempty(get(Children.WordLengthList, 'String')) || ...
            isempty(get(Children.WordLengthList, 'Value'))
      set(Children.WordLengthEdit,   'Enable', 'off', ...
                        'BackgroundColor', get(DialogFig, 'Color'));
    else
      set(Children.WordLengthEdit, 'Enable', 'on', ...
                        'BackgroundColor', 'w');
    end

    set(Children.WordLengthPrompt, 'Enable', 'on');

    numProps = length(bitsInfoStr);
    correspondingValue = get_param(model, 'ProdHWWordLengths');

    string = WordLengthsDataStringParsing(bitsInfoStr, correspondingValue);

    string = char(string);
  end
  set(Children.WordLengthList, ...
      'String',         string, ...
      'Value',          []);
end

%==============================================================================
% Update user data.
%==============================================================================
if syncWithModel,
  DialogUserData.AdvancedPage.eventProps    = eventProps;
  DialogUserData.AdvancedPage.actionIndex   = actionIndex;
  DialogUserData.AdvancedPage.onItems       = onItems;
  DialogUserData.AdvancedPage.offItems      = offItems;
  DialogUserData.AdvancedPage.eventTooltips = eventTooltips;
end

%==============================================================================
% Disable controls for ReadOnlyIfCompiledParams if we're not stopped.
%==============================================================================
if ~strcmp(get_param(model,'SimulationStatus'),'stopped'),
  set(childVect,'Enable','off');
end

% end i_SyncAdvancedPage()


%******************************************************************************
% Function - Parsing the string for Word Lengths data setting               ***
%******************************************************************************
function string = WordLengthsDataStringParsing(bitsInfoStr, correspondingValue)

numProps = length(bitsInfoStr);

spaceChar        = 32;
bitStringWidth   = 30;
valueIndex       = bitStringWidth + 2;
valueStringWidth = 4;
totalStringWidth = bitStringWidth + valueStringWidth + 1;
string           = repmat(spaceChar, numProps, totalStringWidth);

defaultVal = [8 16 32 32];

newStr = '';
if isempty(correspondingValue)
  newStr = '8,16,32,32';
else
  commaIdx = strfind(correspondingValue, ',');
  if length(commaIdx) > 3
    correspondingValue(commaIdx(3)+1:end) = '';
  end
  correspondingValue(end+1:end+3-length(commaIdx)) = ...
      ','*ones(1, 3-length(commaIdx));
  commaIdx = [0 strfind(correspondingValue, ',') ...
              length(correspondingValue)+1];
  for i=1:length(defaultVal)
    if isempty(correspondingValue(commaIdx(i)+1:commaIdx(i+1)-1))
      newStr = [newStr, ',' sprintf('%d', defaultVal(i))];
    else
      newStr = [newStr, ',' correspondingValue(commaIdx(i)+1:commaIdx(i+1)-1)];
    end
  end
end
correspondingValue = newStr;

for i = 1:numProps
  item = bitsInfoStr{i};
  string(i, 1:length(item)) = item;

  [val, correspondingValue] = strtok(correspondingValue, ',');
  string(i, valueIndex:valueIndex+length(val)-1) = val;
end
string = char(string);

% end WordLengthsDataStringParsing


%******************************************************************************
% Function - Build prop/val pairs for Advanced page.                        ***
%******************************************************************************
function propValPairs = i_AdvancedPropValPairs(DialogUserData)

Children = DialogUserData.AdvancedPage.Children;

%==============================================================================
% General options and actions group
%==============================================================================
eventProps = DialogUserData.AdvancedPage.eventProps;
actionIndex = DialogUserData.AdvancedPage.actionIndex;

numProps = length(eventProps);
propValPairs = cell(1, numProps);

eventList   = Children.EventsList;
eventString = get(eventList, 'String');

for i=1:numProps,
  propIdx = 1 + ((i-1)*2);
  valIdx  = propIdx + 1;

  propValPairs{propIdx} = eventProps{i};
  propValPairs{valIdx}  = eventString(i,actionIndex:end);
end

%==============================================================================
% Inline parameters.
%==============================================================================
string = onoff(get(Children.InlineCheckbox, 'Value'));
prop = 'RTWInlineParameters';
propValPairs([end+1 end+2]) = {prop, string};

%
% Assertion Control
%
strings = { 'UseLocalSettings'; 'EnableAll'; 'DisableAll'};
val     = get(Children.AssertPopup, 'Value');
prop    = 'AssertionControl';
propValPairs([end+1 end+2]) = {prop, strings{val}};

%==============================================================================
% Word length information
%==============================================================================
strings = {'Microprocessor'; 'ASIC/FPGA'};
val = get(Children.ProdHWCharsPopup, 'Value');
prop = 'ProdHWDeviceType';
propValPairs([end+1 end+2]) = {prop, strings{val}};

if val == 1
  eventList   = Children.WordLengthList;
  eventString = get(eventList, 'String');

  if ~isempty(eventString)
    numEvent = size(eventString);
    numEvent = numEvent(1);

    strings = deblankall(eventString(1, end-4:end));
    for i=2:numEvent
    strings = [strings, ',' deblankall(eventString(i, end-4:end))];
    end
  else
    strings = '';
  end
  prop = 'ProdHWWordLengths';
  propValPairs([end+1 end+2]) = {prop, strings};
end
% end i_AdvancedPropValPairs()


%******************************************************************************
% Function - Convert action string to action number for Advanced page.   ***
%   none = 1, warning = 2, error = 3                                        ***
%******************************************************************************
function idx = i_OnOffActStr2ActIdx(string)

switch(lower(string))
 case 'on ',
  idx = 1;
 case 'off',
  idx = 2;
 otherwise,
  error('M assert: invalid action');
end

% end i_OnOffActStr2ActIdx()

%%%%%%%%%%%%%%%%%%%%%%%%%%% end Advanced page %%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%% Real-Time Workshop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% function DialogUserData = i_CreateRTWPage(DialogFig, DialogUserData)        %
% function [extent, RTWCtrlPos] = i_RTWCtrlPositions(commonGeom, RTWGeom)     %
% function [RTWGeom, DialogUserData] = i_CreateRTWGeom(commonGeom,DialogUD)   %
% function i_InstallRTWCallbacks(DialogFig, DialogUserData)                   %
% function [DialogUserData, bModified] = i_RTWPageCategorySwitch(...);        %
% function [DialogUserData, bModified] = i_RTWTargetConfigCallback(...)       %
% function DialogUserData = i_SyncRTWPage(DialogUserData)                     %
% function propValPairs = i_RTWPropValPairs(DialogUserData)                   %
% function DialogUserData = i_SyncCategoryMenu(DialogUserData);               %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%******************************************************************************
% Function - Create Real-Time Workshop page.                                ***
%******************************************************************************
function DialogUserData = i_CreateRTWPage(DialogFig, DialogUserData)

commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;

if isempty(DialogUserData.RTWCtrlPos)
  [RTWGeom DialogUserData] = i_CreateRTWGeom(commonGeom, DialogUserData);

  [sheetDims, DialogUserData.RTWCtrlPos] = i_RTWCtrlPositions( ...
      commonGeom, RTWGeom ...
      );
end

RTWCtrlPos = DialogUserData.RTWCtrlPos;

%
% Create 'Category' lable and popup menu
%
Children.CategoryTypes = { ...
    'Target configuration'; ...
    'TLC debugging'         ...
		   };
Children.CategoryLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Category:', ...
    'Position',           RTWCtrlPos.CategoryLabel ...
    );

Children.CategoryPopup = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'popupmenu', ...
    'String',             Children.CategoryTypes, ...
    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
    'Position',           RTWCtrlPos.CategoryPopup ...
    );

%
% Build button.
%
Children.BuildButton = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'pushbutton', ...
    'String',             'Build', ...
    'HorizontalAlignment','center', ...
    'Tooltip',            'Apply changes and build', ...
    'Position',           RTWCtrlPos.BuildButton ...
    );

%
% Create dividing line.
%
Children.DividingLine = uicontrol(...
    'Parent',             DialogFig, ...
    'Style',              commonGeom.dividingLineStyle, ...
    'Enable',             'inactive', ...
    'Position',           RTWCtrlPos.Line ...
    );

%===============================================================================
% List of items belong to 'Target' category
%===============================================================================
%
% Create Configuration group.
%
Children.ConfigurationGroupBox = groupbox( ...
    DialogFig, ...
    RTWCtrlPos.ConfigurationGroupBox, ...
    ' Configuration', ...
    textExtent ...
    );


%
% Create target file label, edit and browser button.
%
Children.TargetFileLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'System target file:', ...
    'Position',           RTWCtrlPos.TargetFileLabel ...
    );


Children.TargetFileEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'TargetFileEdit', ...
    'Position',           RTWCtrlPos.TargetFileEdit ...
    );


Children.TargetFileButton = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'pushbutton', ...
    'String',             'Browse...', ...
    'HorizontalAlignment','center', ...
    'Position',           RTWCtrlPos.TargetFileButton ...
    );


%
% Template makefile label and edit.
%
Children.MakeFileLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Template makefile:', ...
    'Position',           RTWCtrlPos.MakeFileLabel ...
    );


Children.MakeFileEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'MakeFileEdit', ...
    'Position',           RTWCtrlPos.MakeFileEdit ...
    );


%
% Make command label and edit
%
Children.MakeCmdLabel = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'text', ...
    'String',             'Make command:', ...
    'Position',           RTWCtrlPos.MakeCmdLabel ...
    );


Children.MakeCmdEdit = uicontrol( ...
    'Parent',             DialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Tag',                'MakeCmdEdit', ...
    'Position',           RTWCtrlPos.MakeCmdEdit ...
    );


%
% Generate code only checkbox.
%
Children.CodeOnlyCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Generate code only', ...
    'Tag',                'gencodeonly', ...
    'Position',           RTWCtrlPos.CodeOnlyCheckbox);

%
% State Flow button.
%
Children.StateflowButton = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'pushbutton', ...
    'String',             'Stateflow options...', ...
    'HorizontalAlignment','center', ...
    'Position',           RTWCtrlPos.StateflowButton, ...
    'Enable',             'off' ...
    );

% The default stateflow options button's 'Enable' is 'off'. When a licensed
% Stateflow is detected, it will be turned on.

if  exist(['sf.',mexext])
  StateflowTooltipStr = 'Launch Stateflow Options Settings dialog';
  set(Children.StateflowButton, ...
      'Enable',        'on', ...
      'Tooltip',       StateflowTooltipStr);
end

Children.TargetHdl = [
    Children.ConfigurationGroupBox'
    Children.TargetFileLabel
    Children.TargetFileEdit
    Children.TargetFileButton
    Children.MakeFileLabel
    Children.MakeFileEdit
    Children.MakeCmdLabel
    Children.MakeCmdEdit
    Children.CodeOnlyCheckbox
    Children.StateflowButton
		  ];

%===============================================================================
% List of items belong to 'TLC Debugging' category
%===============================================================================
%
% Create TLC debugging options group.
%
Children.TLCOptionsGroupBox = groupbox( ...
    DialogFig, ...
    RTWCtrlPos.TLCOptionsGroupBox, ...
    ' Options', ...
    textExtent ...
    );

%
% Retain .rtw file checkbox.
%
ReainRTWTooltipStr = 'Leaves the model.rtw file in your build directory';
Children.RetainRTWFileCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Retain .rtw file', ...
    'Tag',                'RetainRTWFileCheckbox', ...
    'Position',           RTWCtrlPos.RetainRTWFileCheckbox, ...
    'Tooltip',            ReainRTWTooltipStr ...
    );

%
% TLC Profiler checkbox
%
TLCProfilerTooltipStr = ...
    ['Creates HTML output showing execution time of', sprintf('\n'), ...
     'the TLC files used to generate code'];
Children.TLCProfilerCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'String',             'Profile TLC ', ...
    'Tag',                'ProfileTLCCheckbox', ...
    'Position',           RTWCtrlPos.TLCProfilerCheckbox, ...
    'Tooltip',            TLCProfilerTooltipStr...
    );

%
% TLC debug checkbox
%
TLCDebugTooltipStr = ...
    ['Start the TLC debugger during code generation.', sprintf('\n'), ...
     'Alternatively, you can specify %breakpoint in your TLC file(s).', ...
     sprintf('\n'),...
     'When TLC encounters a %breakpoint statement it will automatically',...
     sprintf('\n'),...
     'invoke the TLC debugger regardless of the checkbox setting.'];
Children.TLCDebugCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'Tag',                'TLCDebugCheckbox', ...
    'String',             'Start TLC debugger when generating code ', ...
    'Position',           RTWCtrlPos.TLCDebugCheckbox, ...
    'Tooltip',            TLCDebugTooltipStr ...
    );

%
% TLC coverage checkbox
%
TLCCoverageTooltipStr = ...
    ['Generates .log files containing the number of times', sprintf('\n'), ...
     'each line of TLC code is hit during code generation'];
Children.TLCCoverageCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'Tag',                'TLCCoverageCheckbox', ...
    'String',             'Start TLC coverage when generating code ', ...
    'Position',           RTWCtrlPos.TLCCoverageCheckbox, ...
    'Tooltip',            TLCCoverageTooltipStr ...
    );


%
% TLC assertion checkbox
%
TLCAssertionTooltipStr = ...
    ['Produce a TLC stack trace when the argument to the ', sprintf('\n'), ...
     '%assert directives evaluates to false'];

Children.TLCAssertionCheckbox = uicontrol( ...
    'Parent',             DialogFig, ...
    'Style',              'checkbox', ...
    'Tag',                'TLCAssertionCheckbox', ...
    'String',             'Enable TLC assertions', ...
    'Position',           RTWCtrlPos.TLCAssertionCheckbox, ...
    'Tooltip',            TLCAssertionTooltipStr ...
    );

Children.TLCDebugHdl = [
    Children.TLCOptionsGroupBox'
    Children.RetainRTWFileCheckbox
    Children.TLCProfilerCheckbox
    Children.TLCDebugCheckbox
    Children.TLCCoverageCheckbox
    Children.TLCAssertionCheckbox
		   ];
% turn off the items at this time
set(Children.TLCDebugHdl, 'Visible', 'off');

%===============================================================================
% List of items belong to 'Code generation options' category
%===============================================================================
%
% Create Code generation options group.
%
Children.CodeGenerationGroupBox = groupbox( ...
    DialogFig, ...
    RTWCtrlPos.CodeGenerationGroupBox, ...
    ' Options', ...
    textExtent ...
    );
% turn this groupbox off by default. It will be turned back on when we
% found the correct system target file or when switch to general options page.
set(Children.CodeGenerationGroupBox', 'Visible', 'off');

%
% Initialization of code generation options and systlc browser dialogs.
%
DialogUserData.RTWPage.systlcDlg = -1;

%
% cache RTW Code generation process stage information
%
DialogUserData.RTWPage.build = 0;

%
% Update user data.
%
DialogUserData.RTWGeom          = [];
DialogUserData.RTWCtrlPos       = [];

DialogUserData.RTWPage.Children = Children;
set(DialogFig, 'UserData', DialogUserData);

% end i_CreateRTWPage()


%******************************************************************************
% Function - Calculate positions for all Real-Time Workshop dialog ctrls.   ***
%            Extent is not used.                                            ***
%                                                                           ***
% It is assumemed that the sheet position is now known (based on solver     ***
%   page), so we work from the top down.                                    ***
%******************************************************************************
function [extent, RTWCtrlPos] = i_RTWCtrlPositions(commonGeom, RTWGeom)

sheetPos  = commonGeom.sheetPos;
sheetTop  = sheetPos(2) + sheetPos(4);
sheetLeft = sheetPos(1);

%
% 'Category' lable
%
cxCur = commonGeom.figSideEdgeBuffer + commonGeom.sheetSideEdgeBuffer;
cyCur = sheetTop  - commonGeom.sheetTopEdgeBuffer - ...
	commonGeom.popupHeight;
RTWCtrlPos.CategoryLabel = [cxCur cyCur ...
		    RTWGeom.categoryLabelWidth ...
		    commonGeom.textHeight];

frameLeft  = cxCur;

%
% 'Category' popup
%
cxCur = cxCur + RTWGeom.categoryLabelWidth - RTWGeom.rowDelta;
categoryPopupWidth = sheetPos(3) - cxCur - RTWGeom.buildButtonWidth ...
    - commonGeom.sheetSideEdgeBuffer;
RTWCtrlPos.CategoryPopup = [cxCur cyCur ...
		    categoryPopupWidth ...
		    commonGeom.popupHeight];

%
% Build button
%
cxCur = cxCur + categoryPopupWidth + RTWGeom.rowDelta;
RTWCtrlPos.BuildButton = [cxCur cyCur ...
     RTWGeom.buildButtonWidth commonGeom.popupHeight];

%
% Dividing line.
%
lineWidth = sheetPos(3) - (2 * commonGeom.sheetSideEdgeBuffer);

cxCur = frameLeft;
cyCur = cyCur - RTWGeom.rowDelta - commonGeom.lineThickness;
RTWCtrlPos.Line = [cxCur cyCur lineWidth commonGeom.lineThickness];

%===============================================================================
% Target configuration
%===============================================================================
%
% Configuration groupbox.
%
frameWidth  = lineWidth;
frameHeight = ...
    commonGeom.frameTopEdgeBuffer + ...
    commonGeom.editHeight * 4     + ...
    RTWGeom.rowDelta * 3          + ...
    commonGeom.frameBottomEdgeBuffer;

frameBottom = cyCur - commonGeom.sheetTopEdgeBuffer - frameHeight;
frameRight  = frameLeft + frameWidth;

RTWCtrlPos.ConfigurationGroupBox = [cxCur frameBottom frameWidth frameHeight];

%
% System target file label and edit.
%

cxCur = cxCur + commonGeom.frameSideEdgeBuffer;
cyCur = ...
    (frameBottom + frameHeight)   - ...
    commonGeom.frameTopEdgeBuffer - ...
    commonGeom.editHeight;
% label
RTWCtrlPos.TargetFileLabel = ...
    [cxCur cyCur RTWGeom.targetFileLabelWidth commonGeom.editHeight];

cxCur = cxCur + RTWGeom.targetFileLabelWidth;

width = frameRight - commonGeom.frameSideEdgeBuffer - cxCur - ...
    RTWGeom.targetFileBrowseWidth - commonGeom.frameSideEdgeBuffer;
% edit field
RTWCtrlPos.TargetFileEdit = [cxCur cyCur width commonGeom.editHeight];

cxCur = frameRight - commonGeom.frameSideEdgeBuffer - ...
    RTWGeom.targetFileBrowseWidth;
% browse button
RTWCtrlPos.TargetFileButton = ...
    [cxCur cyCur RTWGeom.targetFileBrowseWidth commonGeom.editHeight];

%
% Template makefile label and edit.
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = cyCur - RTWGeom.rowDelta - commonGeom.editHeight;
RTWCtrlPos.MakeFileLabel = ...
    [cxCur cyCur RTWGeom.makeFileLabelWidth commonGeom.editHeight];

cxCur = cxCur + RTWGeom.makeFileLabelWidth;
width = frameRight - commonGeom.frameSideEdgeBuffer - cxCur;
RTWCtrlPos.MakeFileEdit = [cxCur cyCur width commonGeom.editHeight];


%
% Make command label and edit.
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = cyCur - RTWGeom.rowDelta - commonGeom.textHeight;
RTWCtrlPos.MakeCmdLabel = ...
    [cxCur cyCur RTWGeom.makeCmdLabelWidth commonGeom.textHeight];

cxCur = frameRight - width - commonGeom.frameSideEdgeBuffer;
cyCur = cyCur - RTWGeom.rowDelta;
RTWCtrlPos.MakeCmdEdit = ...
    [cxCur cyCur width commonGeom.editHeight];

%
% Generate code only checkbox
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = cyCur - RTWGeom.rowDelta - commonGeom.editHeight;

RTWCtrlPos.CodeOnlyCheckbox = ...
    [cxCur cyCur RTWGeom.codeOnlyCheckboxWidth commonGeom.checkboxHeight];

%
% Stateflow options button
%
cxCur = frameRight - commonGeom.frameSideEdgeBuffer - ...
	RTWGeom.sfButtonWidth;
%cxCur = sheetPos(1) + 3*sheetPos(3)/4 - RTWGeom.sfButtonWidth/2;
RTWCtrlPos.StateflowButton = [cxCur cyCur ...
     RTWGeom.sfButtonWidth commonGeom.editHeight];

%
% Build button
%
%cxCur = sheetPos(1) + sheetPos(3)/2 - RTWGeom.buildButtonWidth/2;
%cyCur = commonGeom.bottomSheetOffset + commonGeom.sheetBottomEdgeBuffer;
%RTWCtrlPos.BuildButton = [cxCur cyCur ...
%     RTWGeom.buildButtonWidth commonGeom.sysButtonHeight];


%===============================================================================
% TLC Debugging
%===============================================================================
%
% TLC debugging groupbox
%
cxCur = RTWCtrlPos.Line(1);
cyCur = RTWCtrlPos.Line(2);

frameWidth  = lineWidth;
frameHeight = ...
    commonGeom.frameTopEdgeBuffer + ...
    commonGeom.checkboxHeight * 5 + ...
    RTWGeom.rowDelta * 4          + ...
    commonGeom.frameBottomEdgeBuffer;

frameBottom = cyCur - commonGeom.sheetTopEdgeBuffer - frameHeight;

RTWCtrlPos.TLCOptionsGroupBox = ...
    [cxCur frameBottom frameWidth frameHeight];

%
% use the entire row width for these checkboxes
%
checkboxWidth = frameWidth - 2 * commonGeom.frameSideEdgeBuffer;
%
% Retain .rtw file
%
cxCur = cxCur + commonGeom.frameSideEdgeBuffer;
cyCur = ...
    (frameBottom + frameHeight)   - ...
    commonGeom.frameTopEdgeBuffer - ...
    commonGeom.checkboxHeight;
RTWCtrlPos.RetainRTWFileCheckbox = ...
    [cxCur cyCur checkboxWidth commonGeom.checkboxHeight];

%
% TLC Profiler checkbox
%
cyCur = cyCur - RTWGeom.rowDelta - commonGeom.checkboxHeight;
RTWCtrlPos.TLCProfilerCheckbox = ...
    [cxCur cyCur checkboxWidth commonGeom.checkboxHeight];

%
% TLC debug
%
cyCur = cyCur - RTWGeom.rowDelta - commonGeom.checkboxHeight;
RTWCtrlPos.TLCDebugCheckbox = ...
    [cxCur cyCur checkboxWidth commonGeom.checkboxHeight];

%
% TLC coverage
%
cyCur = cyCur - RTWGeom.rowDelta - commonGeom.checkboxHeight;
RTWCtrlPos.TLCCoverageCheckbox = ...
    [cxCur cyCur checkboxWidth commonGeom.checkboxHeight];

%
% TLC assertion
%
cyCur = cyCur - RTWGeom.rowDelta - commonGeom.checkboxHeight;
RTWCtrlPos.TLCAssertionCheckbox = ...
    [cxCur cyCur checkboxWidth commonGeom.checkboxHeight];


%===============================================================================
% Code generation
%===============================================================================
cxCur = RTWCtrlPos.Line(1);
cyCur = RTWCtrlPos.Line(2);

%
% Code generation options groupbox
%
frameWidth  = lineWidth;
frameHeight = ...
    cyCur - sheetPos(2)               - ...
    commonGeom.frameTopEdgeBuffer * 2;

frameBottom = cyCur - commonGeom.sheetTopEdgeBuffer - frameHeight;

RTWCtrlPos.CodeGenerationGroupBox = ...
    [cxCur frameBottom frameWidth frameHeight];

extent = nan;  % not used

% end i_RTWCtrlPositions()


%******************************************************************************
% Function - Create geometry constants for Real-Time Workshop page.         ***
%******************************************************************************
function [RTWGeom, DialogUserData] = i_CreateRTWGeom(commonGeom, DialogUserData)

sysOffsets = commonGeom.sysOffsets;
textExtent = commonGeom.textExtent;

RTWGeom.rowDelta = 5;

set(textExtent, 'String', 'Category: ');
ext = get(textExtent, 'Extent');
RTWGeom.categoryLabelWidth = ext(3);

set(textExtent, 'String', 'System target file: ');
ext = get(textExtent, 'Extent');
RTWGeom.targetFileLabelWidth = ext(3);

set(textExtent, 'String', 'Browse...');
ext = get(textExtent, 'Extent');
RTWGeom.targetFileBrowseWidth = ext(3) + sysOffsets.pushbutton(3);

set(textExtent, 'String', 'Template make file: ');
ext = get(textExtent, 'Extent');
RTWGeom.makeFileLabelWidth = ext(3);

%we adjust the targetFileLabelWidth to make three edit field items aliagned
RTWGeom.targetFileLabelWidth = RTWGeom.makeFileLabelWidth;

set(textExtent, 'String', 'Make command: ');
ext = get(textExtent, 'Extent');
RTWGeom.makeCmdLabelWidth = ext(3);

set(textExtent, 'String', 'Generate code only ');
ext = get(textExtent, 'Extent');
RTWGeom.codeOnlyCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Retain .rtw file ');
ext = get(textExtent, 'Extent');
RTWGeom.retainRTWFileCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Profile TLC ');
ext = get(textExtent, 'Extent');
RTWGeom.tlcProfilerCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'TLC debug ');
ext = get(textExtent, 'Extent');
RTWGeom.tlcDebugCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'TLC coverage ');
ext = get(textExtent, 'Extent');
RTWGeom.tlcCoverageCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Stateflow options ...');
ext = get(textExtent, 'Extent');
RTWGeom.sfButtonWidth = ext(3) + sysOffsets.pushbutton(3);

set(textExtent, 'String', 'Generate code');
ext = get(textExtent, 'Extent');
RTWGeom.buildButtonWidth = ext(3) + sysOffsets.pushbutton(3);

% end i_CreateRTWGeom()


%******************************************************************************
% Function - Install callbacks for Real-Time Workshop page.                 ***
%******************************************************************************
function i_InstallRTWCallbacks(DialogFig, DialogUserData)

Children = DialogUserData.RTWPage.Children;

%
% Functions on RTW page will only be available to licensed RTW customer.
%
%============================================================================
% Standard behavior is simply to enable the Apply button.
%============================================================================
stdHandles = [
    Children.TargetFileEdit
    Children.MakeFileEdit
    Children.MakeCmdEdit
    Children.RetainRTWFileCheckbox
    Children.TLCProfilerCheckbox
    Children.TLCDebugCheckbox
    Children.TLCCoverageCheckbox
    Children.TLCAssertionCheckbox
	     ];

set(stdHandles, ...
    'Callback',       'simprm(''EnableApply'', gcbf)' ...
    );

%=============================================================================
% Category switch popup menu change
%=============================================================================
set(Children.CategoryPopup, ...
    'Callback', 'simprm(''RTWCategorySwitchAction'', gcbf)' ...
    );

%=============================================================================
% System target file edit field.
%=============================================================================
set(Children.TargetFileEdit, ...
    'Callback', 'simprm(''RTWPage'', ''TargetFileManualEdit'', gcbf)' ...
    );

%=============================================================================
% System target file browser button.
%=============================================================================
set(Children.TargetFileButton, ...
    'Callback', 'simprm(''RTWPage'', ''TargetBrowse'', gcbf)' ...
    );

%
% When systlc browser dialog is open, the following items will be
% disabled and any attempt to click on them will be lead to that dialog.
%
buttonDownFcnItems = [
    Children.TargetFileEdit
    Children.TargetFileLabel
    Children.MakeFileEdit
    Children.MakeFileLabel
    Children.MakeCmdEdit
    Children.MakeCmdLabel
    Children.TargetFileButton
    Children.BuildButton
		   ];
set(buttonDownFcnItems, ...
    'ButtonDownFcn',  'simprm(''RTWPage'', ''ButtonDownFcns'', gcbf)' ...
    );

%=============================================================================
% Generate code only checkbox
%=============================================================================
set(Children.CodeOnlyCheckbox, ...
    'Callback',       'simprm(''RTWPage'', ''GenerateOnly'', gcbf)' ...
    );

%=============================================================================
% Stateflow button if exists.
%=============================================================================
if  exist(['sf.',mexext])
  set(Children.StateflowButton, ...
      'Callback',       'simprm(''RTWPage'', ''Stateflow'', gcbf)' ...
      );
end

%=============================================================================
% Build button.
%=============================================================================
set(Children.BuildButton, ...
    'Callback',       'simprm(''RTWPage'', ''Build'', gcbf)' ...
    );

% end i_InstallRTWCallbacks()


%******************************************************************************
% Function - Switch categories on Real-Time Workshop Page
%     This function will handle only the page updating on RTW page as you
%     select different category.
%******************************************************************************
function [DialogUserData, bModified] = i_RTWPageCategorySwitch( ...
    DialogFig, DialogUserData)

DialogUserData = get(DialogFig, 'UserData');
Children = DialogUserData.RTWPage.Children;

val = get(Children.CategoryPopup, 'Value');

if val == 1
  set(Children.TargetHdl, 'Visible',  'on');
  set(Children.TLCDebugHdl, 'Visible', 'off');
elseif val == 2
  set(Children.TargetHdl, 'Visible',  'off');
  set(Children.TLCDebugHdl, 'Visible', 'on');
elseif val > 2 && (val-2) <= Children.NumOfCategoryItems
  set(Children.TargetHdl, 'Visible',  'off');
  set(Children.TLCDebugHdl, 'Visible', 'off');
else
  error('M assert!');
end

%
% turn off all code generation category pages except for the one
% that was selected
%
if Children.NumOfCategoryItems > 2
  for i = 1:Children.NumOfCategoryItems-2
    if i ~= val-2
      eval(['set(Children.CodeGenHdl' num2str(i) ...
	    ', ''Visible'', ''off'');']);
    end
  end

  if val > 2
    eval(['set(Children.CodeGenHdl' num2str(val-2) ...
	  ', ''Visible'', ''on'');']);
  end
end

set(DialogFig, 'UserData', DialogUserData);
bModified = 1;

% end i_RTWPageCategorySwitch()


%******************************************************************************
% Function - Manage Target category callbacks for Real-Time Workshop Page.
%******************************************************************************
function [DialogUserData, bModified] = i_RTWTargetConfigCallback(...
    DialogFig, DialogUserData, Action, model)

bModified = 0;

switch(Action)

 case 'Build',
  %==================================================================
  % Execute the build command.
  %==================================================================
  errmsg = '';
  modelName = get_param(model, 'Name');
  slsfnagctlr('Clear', modelName, 'RTW Builder');

  % Ensure that bdroot is set to modelName
  % (This is needed in case parts of build process use bdroot).
  if ~strcmp(bdroot, modelName)
    set_param(0, 'CurrentSystem', modelName);
  end

  if ishandle(DialogFig)
    simprm('SystemButtons','Apply',DialogFig);
  end

  % don't disp backtraces when we get rtwgen errors
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;

  if ishandle(DialogFig)
    DialogUserData.RTWPage.build = 1;
    set(DialogFig, 'UserData', DialogUserData);
  end

  %
  % This function will also be called by some Real-Time Workshop test suite
  % functions. They are calling from command window, so there is no
  % UserData for this dialog.
  %
  if ~isempty(DialogUserData) && ...
	isfield(DialogUserData.RTWPage.Children,'BuildButton')
    set(DialogUserData.RTWPage.Children.BuildButton,'enable','off')
  end

  try
    slbuild(model, 'StandaloneRTWTarget','OkayToPushNags', true);
  catch
    errmsg = lasterr;    
  end

  if ishandle(DialogFig)
    DialogUserData.RTWPage.build = 0;
    set(DialogFig, 'UserData', DialogUserData);

    if ~isempty(DialogUserData.RTWPage.Children),
      DialogUserData = i_SyncRTWPage(DialogUserData,0);
    end
  end

  warning(warningState);
  
 case 'TargetFileManualEdit'

  [DialogUserData,bModified] = i_EnableApply(DialogUserData);
  DialogUserData = i_SyncCategoryMenu(DialogUserData);

  % if the system target file get updated, so do the template
  % makefile and make command field
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  errmsg = [];
  try
    systlcFile = systlc_browse(matlabroot,path);
  catch
    errmsg = lasterr('');
  end
  warning(warningState);
  if ~isempty(errmsg)
    errmsg = ['Error during search for system target files: ' ...
	       errmsg];
    errordlg(errmsg, 'Error','modal');
    return;
  end

  if ~isempty(systlcFile)
    existingTLC = get(DialogUserData.RTWPage.Children.TargetFileEdit, ...
		      'String');
    i = length(systlcFile);
    while i > 0
      if strcmp(existingTLC, systlcFile(i).shortName)
	set(DialogUserData.RTWPage.Children.MakeFileEdit, 'String', ...
			  systlcFile(i).tmf);
	set(DialogUserData.RTWPage.Children.MakeCmdEdit, 'String', ...
			  systlcFile(i).makeCmd);
	break;
      end
      i = i - 1;
    end
  end

 case 'TargetFileEdit'

  [DialogUserData,bModified] = i_EnableApply(DialogUserData);
  DialogUserData = i_SyncCategoryMenu(DialogUserData);

 case 'TargetBrowse'
  %
  % Start browsing the system target file.
  % Update targetfile edit area when new tlc file is found.
  % Enable the Apply button when TLC file is changed.
  %
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on; errmsg = [];

  dlgId = DialogUserData.RTWPage.systlcDlg;
  try
    dlgId = systlc_browse_dlg('Create', model, ...
			      DialogUserData.RTWPage.Children, ...
			      dlgId);
  catch
    errmsg = lasterr;
  end

  if ~isempty(errmsg)
    errmsg = ['Error loading system target file browser: ' errmsg];
    errordlg(errmsg, 'Error');
  end

  if ~isempty(DialogUserData) && isempty(errmsg)
    %
    % Because the systlc dialog is non-modal now, we need to disable some
    % of the items on the RTWPage after we open the "System Target File"
    % browser. You have to close the browser to change any of them. They
    % will be turned back on when we close the browser.
    %
    buttonDownFcnItems = [
	DialogUserData.RTWPage.Children.TargetFileEdit
	DialogUserData.RTWPage.Children.TargetFileLabel
	DialogUserData.RTWPage.Children.MakeFileEdit
	DialogUserData.RTWPage.Children.MakeFileLabel
	DialogUserData.RTWPage.Children.MakeCmdEdit
	DialogUserData.RTWPage.Children.MakeCmdLabel
	DialogUserData.RTWPage.Children.TargetFileButton
	DialogUserData.RTWPage.Children.BuildButton
		   ];

    set(buttonDownFcnItems, 'enable', 'off');
  end

  DialogUserData.RTWPage.systlcDlg = dlgId;
  set(DialogFig, 'UserData', DialogUserData);

  warning(warningState);

 case 'ButtonDownFcns'
  if (DialogUserData.RTWPage.systlcDlg ~= -1) && ...
	strcmp( get(DialogUserData.RTWPage.systlcDlg, 'Visible'), 'on')
    figure(DialogUserData.RTWPage.systlcDlg);
  end

 case 'Stateflow'
  %
  % Invoke Stateflow options dialog.
  % If the model does not have any stateflow block, bring out the message
  % box to tell that.
  %
  if ishandle(DialogFig)
    [DialogUserData, bModified] = i_ApplyParams(DialogFig, DialogUserData);
  end

  modelName = get_param( model, 'name');
  sfBlocks = stateflow_options(modelName);

  if ~isempty(sfBlocks)
    %
    % Invoke Apply button when click user's button
    %
    [DialogUserData,bModified] = i_EnableApply(DialogUserData);
  end

 case 'GenerateOnly'
  % when this checkbox is 'on', 'Build' will become to 'Generate code'
  if get(DialogUserData.RTWPage.Children.CodeOnlyCheckbox, 'value') == 1
    actionstr = 'generate code';
  else
    actionstr = 'build';
  end

  set(DialogUserData.RTWPage.Children.BuildButton, ...
      'string',  initialUpper(actionstr), ...
      'Tooltip', ['Apply changes and ' actionstr]);

  set(DialogFig, 'UserData', DialogUserData);
  [DialogUserData,bModified] = i_EnableApply(DialogUserData);

 otherwise
  %==================================================================
  % Unhandled case.
  %==================================================================
  error(['M assert: invalid action <' action '>']);

end

% end i_RTWTargetConfigCallback()


%******************************************************************************
% Function - Sync Real-Time Workshop page.                                  ***
%******************************************************************************
function DialogUserData = i_SyncRTWPage(DialogUserData,syncWithModel)

Children = DialogUserData.RTWPage.Children;
model    = DialogUserData.model;

%==============================================================================
% The code that makes sure that all enable/disable states are correct
% assumes that all controls start off in the enabled state.
%==============================================================================
handlesNormal   = Children.BuildButton;

%
% In external mode, these need to be disabled as browsing targets can
% cause the external mode mex file change.  This file cannot change
% on the fly as the new mex-file is not gauranteed to have the same
% user data structure (which simulink is holding onto and passing to
% the mex-file during extmode).
%
handlesExternal = [
  Children.TargetFileButton
  Children.TargetFileLabel
  Children.TargetFileEdit
  Children.MakeFileLabel
  Children.MakeFileEdit
  Children.MakeCmdLabel
  Children.MakeCmdEdit];

% enable these items if it's not duing the make_rtw
if DialogUserData.RTWPage.build ~= 1
  set([handlesNormal; handlesExternal], 'Enable','on');
end

%==============================================================================
% Sync system target file.
%==============================================================================
if syncWithModel,
  string = get_param(model, 'RTWSystemTargetFile');
  set(Children.TargetFileEdit, ...
    'String',         string);
end

%==============================================================================
% Sync template makefile.
%==============================================================================
if syncWithModel,
  string = get_param(model, 'RTWTemplateMakefile');
  set(Children.MakeFileEdit, ...
    'String',         string);
end

%==============================================================================
% Sync make command.
%==============================================================================
if syncWithModel,
  string = get_param(model, 'RTWMakeCommand');
  set(Children.MakeCmdEdit, ...
    'String',         string);
end

%==============================================================================
% Sync generate code only checkbox.
%==============================================================================
if syncWithModel,
  bValue = onoff(get_param(model, 'RTWGenerateCodeOnly'));
  set(Children.CodeOnlyCheckbox, ...
      'Value',      bValue);
  if bValue == 0
    set(Children.BuildButton, 'String', 'Build');
  else
    set(Children.BuildButton, 'String', 'Generate code');
  end
end

%==============================================================================
% Sync retain .rtw file checkbox.
%==============================================================================
if syncWithModel,
  bValue = onoff(get_param(model, 'RTWRetainRTWFile'));
  set(Children.RetainRTWFileCheckbox, ...
    'Value',      bValue);
end

%==============================================================================
% Sync TLC profiler status
%==============================================================================
if syncWithModel,
  bValue = onoff(get_param(model, 'TLCProfiler'));
  set(Children.TLCProfilerCheckbox, ...
    'Value',      bValue);
end

%==============================================================================
% Sync TLC debug status
%==============================================================================
if syncWithModel,
  bValue = onoff(get_param(model, 'TLCDebug'));
  set(Children.TLCDebugCheckbox, ...
    'Value',      bValue);
end

%==============================================================================
% Sync TLC coverage status
%==============================================================================
if syncWithModel,
  bValue = onoff(get_param(model, 'TLCCoverage'));
  set(Children.TLCCoverageCheckbox, ...
      'Value',      bValue);

  DialogFig = get(Children.TLCCoverageCheckbox, 'Parent');
  DialogUserData.RTWPage.Children = Children;
  set(DialogFig, 'UserData', DialogUserData);
end

%==============================================================================
% Sync TLC assertion status
%==============================================================================
if syncWithModel,
  bValue = onoff(get_param(model, 'TLCAssertion'));
  set(Children.TLCAssertionCheckbox, ...
      'Value',      bValue);

  DialogFig = get(Children.TLCAssertionCheckbox, 'Parent');
  DialogUserData.RTWPage.Children = Children;
  set(DialogFig, 'UserData', DialogUserData);
end

%==============================================================================
% Sync code generation options, including category menu and options categories.
%==============================================================================
if syncWithModel,
  DialogUserData = i_SyncCategoryMenu(DialogUserData);
end

%==============================================================================
% Disable controls for ReadOnlyIfCompiledParams if we're not stopped.
%==============================================================================
if ~strcmp(get_param(model,'SimulationStatus'),'stopped'),

  set(handlesNormal,'Enable','off');

  %
  % Note that the 'if' below must check Simulation Mode and not
  % Simulation Status as we are still in the SimStatus==initializing
  % stage when we call into simprm to set the enabledness of controls.
  %
  if strcmp(get_param(model,'SimulationMode'),'external'),
    set(handlesExternal, 'Enable', 'off');
  end
end

% end i_SyncRTWPage()


%******************************************************************************
% Function - Build prop/val pairs for Real-Time Workshop page.              ***
%******************************************************************************
function propValPairs = i_RTWPropValPairs(DialogUserData)

Children     = DialogUserData.RTWPage.Children;
propValPairs = {};

%==============================================================================
% Target file.
%==============================================================================
string = get(Children.TargetFileEdit, 'String');
prop = 'RTWSystemTargetFile';
propValPairs([end+1 end+2]) = {prop, string};

%==============================================================================
% Template makefile
%==============================================================================
string = get(Children.MakeFileEdit, 'String');
prop = 'RTWTemplateMakefile';
propValPairs([end+1 end+2]) = {prop, string};


%==============================================================================
% Make command.
%==============================================================================
string = get(Children.MakeCmdEdit, 'String');
prop = 'RTWMakeCommand';
propValPairs([end+1 end+2]) = {prop, string};

%==============================================================================
% Generate code only.
%==============================================================================
string = onoff(get(Children.CodeOnlyCheckbox, 'Value'));
prop = 'RTWGenerateCodeOnly';
propValPairs([end+1 end+2]) = {prop, string};

%==============================================================================
% Retain rtw file checkbox.
%==============================================================================
string = onoff(get(Children.RetainRTWFileCheckbox, 'Value'));
prop = 'RTWRetainRTWFile';
propValPairs([end+1 end+2]) = {prop, string};

%==============================================================================
% TLC Profiler
%==============================================================================
string = onoff(get(Children.TLCProfilerCheckbox, 'Value'));
prop = 'TLCProfiler';
propValPairs([end+1 end+2]) = {prop, string};

%==============================================================================
% TLC Debug
%==============================================================================
string = onoff(get(Children.TLCDebugCheckbox, 'Value'));
prop = 'TLCDebug';
propValPairs([end+1 end+2]) = {prop, string};

%==============================================================================
% TLC coverage
%==============================================================================
string = onoff(get(Children.TLCCoverageCheckbox, 'Value'));
prop = 'TLCCoverage';
propValPairs([end+1 end+2]) = {prop, string};

%==============================================================================
% TLC assertion
%==============================================================================
string = onoff(get(Children.TLCAssertionCheckbox, 'Value'));
prop = 'TLCAssertion';
propValPairs([end+1 end+2]) = {prop, string};

%==============================================================================
% Code generation options
%==============================================================================
rtwOptions = [];
if Children.NumOfCategoryItems > 2
  for i = 1 : Children.NumOfCategoryItems-2
    eval(['rtwOptions = [rtwOptions Children.CodeGenHdl' ...
	  num2str(i) 'Opts];']);
  end

  DialogFig = get(Children.TLCCoverageCheckbox, 'Parent');
  % update the value of all rtwOptions items
  for i=1:length(rtwOptions)
    switch (lower(rtwOptions(i).type))
     case 'checkbox'
      objTag = [rtwOptions(i).prompt '_CheckboxTag'];
      obj = findobj(DialogFig, 'Tag', objTag);
      val = get(obj, 'Value');

      rtwOptions(i).default = onoff(val);
      rtwOptions(i).enable  = get(obj, 'Enable');

     case 'edit'
      objTag = [rtwOptions(i).prompt '_EditFieldTag'];
      obj = findobj(DialogFig, 'Tag', objTag);
      str = get(obj, 'String');

      rtwOptions(i).default = str;
      rtwOptions(i).enable  = get(obj, 'Enable');

     case 'popup'
      objTag = [rtwOptions(i).prompt '_PopupFieldTag'];
      obj = findobj(DialogFig, 'Tag', objTag);
      val = get(obj, 'Value');

      str = get(obj, 'String');
      defaultStr = deblankall(str(get(obj, 'Value'), :));

      rtwOptions(i).popupstrings = str(1, :);
      for j=2:size(str, 1)
	rtwOptions(i).popupstrings = [rtwOptions(i).popupstrings, '|', ...
		    deblankall(str(j, :))];
      end

      rtwOptions(i).default = defaultStr;
      rtwOptions(i).enable  = get(obj, 'Enable');

      if isfield(rtwOptions(i), 'value') && ~isempty(rtwOptions(i).value)
        rtwOptions(i).value = val;
      end

     otherwise
      %no-op
    end
  end
  % get the propVal for RTWOptions
  string = simprmrtwfcn('struct2optarr', rtwOptions);
  prop = 'RTWOptions';
  propValPairs([end+1 end+2]) = {prop, string};
end

% end i_RTWPropValPairs()


%*******************************************************************************
% Function - Synchronize Code generation options.
%
% Update the Category popupmenu. We allow user to dynamically
% modify the 'Category' items via the system target file. Because
% of the space limitation of the simprm dialog, we can only have 7
% rows of items shown up at one category page. Any code generation
% options pre-setup in system target file must follow this limit
% rule. For items more than 7, have a new page specified with field
% type 'Category' in the tlc file. The 'Common code generation
% options' category is specified in file
% toolbox\rtw\rtw\private\rtwcommonoptions.m.
%*******************************************************************************
%
%*******************************************************************************
% Sync Category popup menu
%*******************************************************************************
function DialogUserData = i_SyncCategoryMenu(DialogUserData)

Children = DialogUserData.RTWPage.Children;
model    = DialogUserData.model;

% set up nagctrl
warnmsg = '';

%
% sync code generation options
%
DialogFig = get(Children.TLCCoverageCheckbox, 'Parent');

if ishandle(DialogFig)
  defaultPointer = get(DialogFig, 'Pointer');
  set(DialogFig, 'Pointer', 'watch');
end

%
% Basic geom for option items
%
commonGeom  = DialogUserData.commonGeom;
textExtent  = commonGeom.textExtent;

% Make some extra space rowDelta between each line
rowDelta   = 5;
sysOffsets = commonGeom.sysOffsets;

%
% Starting position within the code generation options UI groupbox,
%
startPos = get(Children.RetainRTWFileCheckbox, 'Position');
cxCur    = startPos(1);
cyCur    = startPos(2) - 3       + ...
    commonGeom.checkboxHeight    + ...
    commonGeom.frameTopEdgeBuffer;

linePos = get(Children.DividingLine,'Position');
itemWidth = linePos(3) - 2 * commonGeom.frameSideEdgeBuffer;

%
% Sync Common code generation options and get user defined options
% from system target file.
%
try
  options = simprmrtwfcn('getrtwoptions', model, ...
			 get(Children.TargetFileEdit, 'String'));
catch
  options = [];
end

if ~isempty(options)
  updated = 1;
  %
  % Update 'Category' popup menu's items list.
  %
  numOptCategory = 0;
  syncOpt        = 0;
  if length(Children.CategoryTypes) > 2
    for i=3:length(Children.CategoryTypes)
      eval(['hdls = Children.CodeGenHdl' num2str(i-2) ';']);
      if ishandle(hdls(3:length(hdls)))
	delete(hdls(3:length(hdls)));
      end
    end

    Children.CategoryTypes = Children.CategoryTypes(1:2);
  end

  for i = 1:length(options)
    if syncOpt > 0
      syncOpt = syncOpt - 1;
      eval(['Children.CodeGenHdl' num2str(numOptCategory) ...
	    'Opts = [Children.CodeGenHdl' num2str(numOptCategory) ...
	    'Opts options(i)];']);
    end

    if strcmp(options(i).type, 'Category')
      numOptCategory = numOptCategory + 1;
      Children.CategoryTypes = [ Children.CategoryTypes; ...
		    {options(i).prompt} ];

      %
      % We create the handle's bundle structure now so that we could add
      % the proper callback function on the 'Category' popup menu.
      %
      eval(['Children.CodeGenHdl' num2str(numOptCategory) ...
	    '= [Children.CodeGenerationGroupBox''];']);

      % turn off the items at this time
      eval(['set(Children.CodeGenHdl' num2str(numOptCategory) ...
	    ', ''Visible'', ''off'');']);

      syncOpt = options(i).default;
      eval(['Children.CodeGenHdl' num2str(numOptCategory) 'Opts =' ...
		    ' [];']);

      maxNumItemPerPage = 7;

      % reset the starting position for new category
      cxCur = startPos(1);
      cyCur = startPos(2) - 3       + ...
	  commonGeom.checkboxHeight    + ...
	  commonGeom.frameTopEdgeBuffer;
    else
      maxNumItemPerPage = maxNumItemPerPage -1;
      if maxNumItemPerPage < 0 && ~strcmp(options(i).type, 'NonUI')
	slsfnagctlr('Clear', ...
		    get_param(model, 'name'), ...
		    'RTW Options category');

	warnmsg = (...
	    ['The number of visible code generation options you customized ' ...
	     sprintf('\n'), ...
	     'is more than it can be shown on one page (7 rows).' ...
	     sprintf('\n'), ...
	     'Please use separate pages for grouping more options.' ...
	     sprintf('\n'), ...
	     'Run ">>close all force" in command window to close the' ...
	      ' dialog.']);

	nag                = slsfnagctlr('NagTemplate');
	nag.type           = 'Warning';
	nag.msg.details    = warnmsg;
	nag.msg.type       = 'SYSTLC';
	nag.msg.summary    = warnmsg;
	nag.component      = 'RTW';
	nag.sourceName     = get_param(model, 'RTWSystemTargetFile');
	nag.sourceFullName = evalc( ...
	    ['which ' get_param(model, 'RTWSystemTargetFile')]);

	slsfnagctlr('Naglog', 'push', nag);
	slsfnagctlr('ViewNaglog');
      end

      Option = options(i);
      %
      % To get the length of strings of each code generation option.
      % For edit & popup labels, we need to add ':' at the end of them.
      %
      % need to add ':' for Edit and popup labels.
      if strcmp(lower(Option.type), 'edit') || ...
	    strcmp(lower(Option.type), 'popup')
	Option.prompt = [Option.prompt ':'];
      end

      set(textExtent, 'String', Option.prompt);
      ext = get(textExtent, 'Extent');
      width = ext(3);

      if itemWidth <= (width + rowDelta)
	width = itemWidth - rowDelta - 1;

	slsfnagctlr('Clear', ...
		    get_param(model, 'name'), ...
		    'RTW Options category');

	warnmsg = (...
	    ['Please consider to use fewer words in the code generation ' ...
	     sprintf('\n'), 'option''s item prompt string: ' ...
	     Option.prompt, sprintf('\n')]);

	nag                = slsfnagctlr('NagTemplate');
	nag.type           = 'Warning';
	nag.msg.details    = warnmsg;
	nag.msg.type       = 'SYSTLC';
	nag.msg.summary    = warnmsg;
	nag.component      = 'RTW';
	nag.sourceName     = get_param(model, 'RTWSystemTargetFile');
	nag.sourceFullName = evalc(...
	    ['which ' get_param(model, 'RTWSystemTargetFile')]);

	slsfnagctlr('Naglog', 'push', nag);
	slsfnagctlr('ViewNaglog');

      end

      % if user miss some important fields in their system target
      % file, we will give them a default value and proper warning
      if isfield(Option, 'prompt') && isempty(Option.prompt)
	Option.prompt = '';
	slsfnagctlr('Clear', ...
		    get_param(model, 'name'), ...
		    'RTW Options category');

	warnmsg = (...
	    ['Must have prompt string for each option' sprintf('\n')]);

	nag                = slsfnagctlr('NagTemplate');
	nag.type           = 'Warning';
	nag.msg.details    = warnmsg;
	nag.msg.type       = 'SYSTLC';
	nag.msg.summary    = warnmsg;
	nag.component      = 'RTW';
	nag.sourceName     = get_param(model, 'RTWSystemTargetFile');
	nag.sourceFullName = evalc(...
	    ['which '  get_param(model, 'RTWSystemTargetFile')]);

	slsfnagctlr('Naglog', 'push', nag);
	slsfnagctlr('ViewNaglog');
      end
      if isfield(Option, 'enable') && isempty(Option.enable)
	Option.enable = 'on';
      end
      if isfield(Option, 'tooltip') && isempty(Option.tooltip)
	Option.tooltip = '';
      end

      switch ( Option.type )
       case 'Checkbox',
	%
	% locate the position; use the entire row for a checkbox
	%
	width    = itemWidth;
	cyOffset = commonGeom.checkboxHeight + rowDelta;
	cyCur    = cyCur - cyOffset;
	itemPos  = [cxCur cyCur width commonGeom.checkboxHeight];

	%
	% For the option which needs a check box. The structure will have
	% following fields:
	%    prompt:      the string prompt will show up on the dialog;
	%    type:        user interface style (checkbox);
	%    default:     default value (on/off);
	%    tlcvariable: the variable name which is used in Real-Time Workshop
	%    tooltip:     tooltip string for dialog
	%    callback:    callback function (optional)
	%
	opt = uicontrol( ...
	    'Parent',             DialogFig, ...
	    'Style',              Option.type, ...
	    'String',             Option.prompt, ...
	    'Visible',            'off', ...
	    'Value',              onoff(Option.default), ...
	    'Enable',             Option.enable, ...
	    'TooltipString',      Option.tooltip, ...
	    'Position',           itemPos, ...
	    'Tag',                [Option.prompt, '_CheckboxTag'] ...
	    );

       case 'Edit',
	%
	% locate the position; use the entire row for a checkbox
	%
	cyOffset = commonGeom.editHeight + rowDelta;
	cyCur    = cyCur - cyOffset;

	itemPos = [cxCur cyCur width commonGeom.textHeight];

	%
	% For the option which needs a edit text field. The structure will
	% have following fields:
	%    prompt:      the label string for the edit field
	%    type:        user interface style (edit)
	%    default:     default value in the edit field;
	%    tlcvariable: the variable name which is used in RTW
	%    callback:    calback function name (optional)
	%
	opt = uicontrol( ...
	    'Parent',             DialogFig, ...
	    'Style',              'text', ...
	    'String',             Option.prompt, ...
	    'Visible',            'off', ...
	    'Enable',             Option.enable, ...
	    'TooltipString',      Option.tooltip, ...
	    'Position',           itemPos, ...
	    'Tag',                [Option.prompt(1:end-1), '_EditLabelTag'] ...
	    );

	eval(['Children.CodeGenHdl' num2str(numOptCategory) ...
	      '=[Children.CodeGenHdl' num2str(numOptCategory) '; opt];']);

	% use the rest of the row for edit field
	cxOffset = width + rowDelta;
	extWidth = itemWidth - cxOffset;

	itemPos = [cxCur + cxOffset cyCur extWidth commonGeom.editHeight];

	opt = uicontrol( ...
	    'Parent',             DialogFig, ...
	    'BackgroundColor',    'w', ...
	    'Style',              'edit', ...
	    'Visible',            'off', ...
	    'Enable',             Option.enable, ...
	    'String',             Option.default, ...
	    'TooltipString',      Option.tooltip, ...
	    'Position',           itemPos, ...
	    'Tag',                [Option.prompt(1:end-1), '_EditFieldTag'] ...
	    );

       case 'Popup',
	%
	% locate the position; use the entire row for a checkbox
	%
	cyOffset = commonGeom.popupHeight + rowDelta;
	cyCur    = cyCur - cyOffset;

	% set up the position for popup's label
	itemPos = [cxCur cyCur width commonGeom.textHeight];

	if isfield(Option, 'popupstrings') && isempty(Option.popupstrings)
	  Option.popupstrings = '';

	  slsfnagctlr('Clear', ...
		    get_param(model, 'name'), ...
		    'RTW Options category');

	  warnmsg = ['Popup menu item for "' Option.prompt ...
		     '" must have list of strings' sprintf('\n')];

	  nag                = slsfnagctlr('NagTemplate');
	  nag.type           = 'Warning';
	  nag.msg.details    = warnmsg;
	  nag.msg.type       = 'SYSTLC';
	  nag.msg.summary    = warnmsg;
	  nag.component      = 'RTW';
	  nag.sourceName     = get_param(model, 'RTWSystemTargetFile');
	  nag.sourceFullName = evalc( ...
	      ['which ' get_param(model, 'RTWSystemTargetFile')]);

	  slsfnagctlr('Naglog', 'push', nag);
	  slsfnagctlr('ViewNaglog');

	end
	%
	% For the option which needs a popup menu. The structure will have
	% following fields:
	%    prompt:       the string prompt will show up on the dialog;
	%    type:         user interface style;
	%    default:      default value;
	%    popupstrings: string lists for popup menu
	%    tlcvariable:  the variable name which is used in Real-Time Workshop
	%    callback:     callback functions (optional)
	%
	opt = uicontrol( ...
	    'Parent',             DialogFig, ...
	    'Style',              'text', ...
	    'String',             Option.prompt, ...
	    'Enable',             Option.enable, ...
	    'Visible',            'off', ...
	    'TooltipString',      Option.tooltip, ...
	    'Position',           itemPos, ...
	    'Tag',                [Option.prompt(1:end-1), '_PopupLabelTag'] ...
	    );

	eval(['Children.CodeGenHdl' num2str(numOptCategory) ...
	      '=[Children.CodeGenHdl' num2str(numOptCategory) '; opt];']);

	% use the rest of the row for popup menu
	cxOffset = width + rowDelta;
	extWidth = itemWidth - cxOffset;

	% set up the position for popup menu
	itemPos = [cxCur+cxOffset cyCur extWidth commonGeom.popupHeight];

	defaultValue = GetDefaultPopup(Option.popupstrings, Option.default);
	opt = uicontrol( ...
	    'Parent',             DialogFig, ...
	    'Style',              'popupmenu', ...
	    'String',             Option.popupstrings, ...
	    'HorizontalAlign',    'left', ...
	    'Visible',            'off', ...
	    'Enable',             Option.enable, ...
	    'TooltipString',      Option.tooltip, ...
	    'Position',           itemPos, ...
	    'Value',              defaultValue, ...
	    'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
	    'Tag',                [Option.prompt(1:end-1), '_PopupFieldTag'] ...
	    );

       case 'Pushbutton'
	if strcmp(Option.default, 'on')
	  % locate the button, move the curser down
	  cyOffset = commonGeom.editHeight + rowDelta;
	  cyCur    = cyCur - cyOffset;

	  % use the actual size of the button
	  buttonWidth = width + sysOffsets.pushbutton(3);

	  itemPos = [cxCur cyCur buttonWidth commonGeom.editHeight];
	  %
	  % For the option which needs a push button. The structure will have
	  % following fields:
	  %    prompt:      the string prompt will show up on the button;
	  %    type:        user interface style (pushbutton);
	  %    enable:      on/off;
	  %    tooltip:     help tooltip strings
	  %    callback:    callback function.
	  %
	  opt = uicontrol( ...
	      'Parent',             DialogFig, ...
	      'Style',              'pushbutton', ...
	      'Visible',            'off', ...
	      'String',             [' ' Option.prompt ' '], ...
	      'Enable',             Option.enable, ...
	      'TooltipString',      Option.tooltip, ...
	      'Position',           itemPos, ...
	      'Tag',                [Option.prompt, '_ButtonTag'] ...
	      );
	end

       case 'NonUI'
	% Special case for dSpace, other user should not use it as it may have
        % some unexpected behaviors.

	% Because this item doesn't take any space, it is not included in that
        % "7" items limitation.
	maxNumItemPerPage = maxNumItemPerPage + 1;

	% There is no handle that needs to be registered.
	opt = [];

       otherwise,
	%
	% Wrong code generation option type
	%
	error('Invalid code generation option type: %s.', Option.type );
      end

      % trigger the Apply button when item changed
      cb = 'simprm(''EnableApply'', gcbf);';
      if (isfield(Option, 'callback') && ~isempty(Option.callback)),
	cb = [cb Option.callback];
      end
      set(opt, 'Callback', cb);

      eval(['Children.CodeGenHdl' num2str(numOptCategory) ...
	    '=[Children.CodeGenHdl' num2str(numOptCategory) '; opt];']);

    end

  end

else
  % report no change on code generation options item
  updated = 0;
end

%
% Refresh 'Category' menu string
%
set(Children.CategoryPopup, 'String', Children.CategoryTypes);
Children.NumOfCategoryItems = length(Children.CategoryTypes);

if DialogUserData.CurrentPageNum == 5
  showCategory = 'on';
else
  showCategory = 'off';
end
popupVal = get(Children.CategoryPopup, 'Value');
if popupVal > Children.NumOfCategoryItems
  set(Children.CategoryPopup, 'Value', 1);
  set(Children.TargetHdl, 'Visible', showCategory);
else
  if popupVal > 2
    eval(['set(Children.CodeGenHdl' num2str(popupVal-2) ...
	  ', ''Visible'', showCategory);']);
    set(Children.CodeGenerationGroupBox, 'Visible', showCategory);
  else
    set(Children.CategoryPopup, 'Value', popupVal);
    if popupVal == 2
      set(Children.TLCDebugHdl, 'Visible', showCategory);
    else
      set(Children.TargetHdl, 'Visible', showCategory);
    end
  end

end;

if updated
  %
  % Make a second pass and evaluate any opencallback functions
  %
  i = 1;
  while i <= length(options)
    Option = options(i);

    if ~strcmp(Option.type, 'Category') && ...
	  (isfield(Option, 'opencallback') && ...
	   ~isempty(Option.opencallback))
      %
      % At this time, we are using gcbf as a variable because we have callback
      % set as a string in system target files.
      %
      gcbf = DialogFig;
      try
          eval(Option.opencallback);
      catch
	slsfnagctlr('Clear', ...
		    get_param(model, 'name'), ...
		    'RTW Options category');

	warnmsg = (['The RTW option "' Option.prompt '" has some invalid settings', ...
		    sprintf('\n'), ...
		    'in its opencallback field. Please see Real-Time Workshop User''s Guide' ...
		    sprintf('\n'), ...
		    'as reference to set it up correctly']);

	nag                = slsfnagctlr('NagTemplate');
	nag.type           = 'Warning';
	nag.msg.details    = warnmsg;
	nag.msg.type       = 'SYSTLC';
	nag.msg.summary    = warnmsg;
	nag.component      = 'RTW';
	nag.sourceName     = get_param(model, 'RTWSystemTargetFile');
	nag.sourceFullName = evalc( ...
	    ['which ' get_param(model, 'RTWSystemTargetFile')]);

	slsfnagctlr('Naglog', 'push', nag);
	slsfnagctlr('ViewNaglog');
      end
      clear gcbf;
    end
    i = i+1;
  end
  %
  % The variable ExtModeTable is created by the opencallback function for
  % targets supporting external mode.  Set ExtModeMextFile to be no_ext_comm
  % for all targets not supporting extmode.
  %
  if ~exist('ExtModeTable');
    extmodecallback('noextcomm', model);
  end;
end

DialogUserData.RTWPage.Children = Children;
set(DialogFig, 'UserData', DialogUserData);

if ishandle(DialogFig)
  set(DialogFig, 'Pointer', defaultPointer);
end

% end i_SyncCategoryMenu();


% Function: GetDefaultPopup ===================================================
% Abstract:
%      Find the default popup menu item.
%
function defaultValue = GetDefaultPopup(PopupStrings, default)

defaultValue = 1;

if strcmp(default(1), '"' ) && strcmp( default( length(default) ), '"' )
  default = default( 2 : length(default)-1 );
end

% Locate the '|'s positions
SepPos = findstr( PopupStrings, '|');
if ~isempty( SepPos )

  SepPos = [0 SepPos length(PopupStrings)+1];

  % Locate the default string's position.
  for i = 1 : length(SepPos)-1
    if strcmp( default, PopupStrings( SepPos(i)+1 : SepPos(i+1)-1 ) )
      defaultValue = i;
      return;
    end
  end

end

%end function

% Function: CallOptionsCloseCallback ==========================================
% Abstract:
%      Call closecallback for code generation options, if any
%
function DialogUserData = CallOptionsCloseCallback(DialogUserData)


DialogFig = ...
    get(DialogUserData.RTWPage.Children.TLCCoverageCheckbox, 'Parent');
model = DialogUserData.model;

if DialogUserData.RTWPage.Children.NumOfCategoryItems > 2
  for j=1:DialogUserData.RTWPage.Children.NumOfCategoryItems-2
    eval(['options = DialogUserData.RTWPage.Children.CodeGenHdl' ...
	  num2str(j) 'Opts;']);
    i = 1;
    while i <= length(options)
      Option = options(i);

      if ~strcmp(Option.type, 'Category') && ...
	    (isfield(Option, 'closecallback') && ...
	     ~isempty(Option.closecallback))

	gcbf = DialogFig;
	eval(Option.closecallback);
	clear gcbf;
      end
      i = i+1;
    end
  end
end

%endfunction


% Function: i_PromptForUnappliedParams =========================================
% Abstract:
%  Alert the user if there are unapplied simulation parameters and either
%  apply them or discard them.
%
function act = i_PromptForUnappliedParams(DialogFig,DialogUserData,processID)

hModel    = DialogUserData.model;
modelName = get_param(hModel,'name');
hApply    = DialogUserData.SystemButtons.Apply;
act       = 1;

if onoff(get(hApply,'Enable')),
  processStr = 'simulation';
  if strcmp(processID, 'build')		% for build or generate code
    processStr = 'build process';
    if ~isempty(DialogUserData.RTWPage.Children)
      if ~strcmp(get(DialogUserData.RTWPage.Children.BuildButton,'String'), ...
		 'Build')
	processStr = 'code generation';
      end
    else
      if strcmp(get_param(hModel, 'RTWGenerateCodeOnly'), 'on')
	processStr = 'code generation';
      end
    end
  end
  qst = ['There are unapplied changes in the Simulation Parameter Dialog ' ...
         'box.  Do you want to apply, cancel the changes or abort' ...
	 ' the ' processStr '?'];

  choice = questdlg(qst,modelName,'Apply','Cancel','Abort','Apply');

  switch(choice),

   case 'Apply',
    simprm('SystemButtons','Apply',DialogFig);
   case 'Cancel',
    [DialogUserData,bModified] = i_ReShowDialog(DialogFig, ...
						DialogUserData,1);
   case 'Abort'
    % don't do anything on the dialog and stop the Simulation or
    % Build process.
    if strcmp(processID, 'simulation')
      set_param(hModel, 'SimulationCommand','stop');
      act = 0;
    elseif strcmp(processID, 'build') % Build process
      act = 0;
    end

  otherwise,
    error('M-assert');
  end
end


% Function: i_SimStartStop =====================================================
% Abstract:
%  Handle update of dialog for sim start and sim stop.
%
function [DialogUserData, bModified] = ...
    i_SimStartStop(DialogFig, DialogUserData, Action)

%
% Assume: If we get here, the dialog exists and is visible
%

bModified = 0;
hModel    = DialogUserData.model;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't allow start of sim if dialog vals don't match model vals. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Action,'SimStart'),
  readyToRun = i_PromptForUnappliedParams(DialogFig,...
					  DialogUserData, ...
					  'simulation');
end

%%%%%%%%%%%%%%%%%%%%%%
% Solver page        %
%%%%%%%%%%%%%%%%%%%%%%
if DialogUserData.CurrentPageNum == 1 && ...
   ~isempty(DialogUserData.SolverPage.Children),
  %disp(['updating solver page for: ' Action ' ---simstatus: ' get_param(hModel,'SimulationStatus')]);
  i_SyncSolverPage(DialogFig,DialogUserData,0);
end

%%%%%%%%%%%%%%%%%%%%%%
% Workspace I/O page %
%%%%%%%%%%%%%%%%%%%%%%
if DialogUserData.CurrentPageNum == 2 && ...
   ~isempty(DialogUserData.WorkspaceIOPage.Children),
  %disp(['updating workspace i/o page for: ' Action ' ---simstatus: ' get_param(hModel,'SimulationStatus')]);
  i_SyncWorkspaceIOPage(DialogUserData,0);
end

%%%%%%%%%%%%%%%%%%%%%%
% Diagnostic page    %
%%%%%%%%%%%%%%%%%%%%%%
if DialogUserData.CurrentPageNum == 3 && ...
   ~isempty(DialogUserData.DiagnosticsPage.Children),
  %disp(['updating diagnostics page for: ' Action ' ---simstatus: ' get_param(hModel,'SimulationStatus')]);
  i_SyncDiagnosticsPage(DialogFig,DialogUserData,0);
end

%%%%%%%%%%%%%%%%%%%%%%
% Advanced page      %
%%%%%%%%%%%%%%%%%%%%%%
if DialogUserData.CurrentPageNum == 4 && ...
   ~isempty(DialogUserData.AdvancedPage.Children),
  %disp(['updating advanced page for: ' Action ' ---simstatus: ' get_param(hModel,'SimulationStatus')]);
  i_SyncAdvancedPage(DialogFig,DialogUserData,0);
end

%%%%%%%%%%%%%%%%%%%%%%
% RTW page           %
%%%%%%%%%%%%%%%%%%%%%%
if DialogUserData.CurrentPageNum == 5 && ...
   ~isempty(DialogUserData.RTWPage.Children),
  %disp(['updating RTW page for: ' Action ' ---simstatus: ' get_param(hModel,'SimulationStatus')]);
  i_SyncRTWPage(DialogUserData,0);
end




%%%%%%%%%%%%%%%%%%%%%%%%%% end Real-Time Workshop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%% Utility functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% function i_CheckEditPair_DefCheckCallbk(checkbox, edit)                     %
% function name = i_DlgName(hModel)                                           %
% function i_InitCheckEditPair(checkbox, edit, onoffState, string)            %
% function [defaultPageNum, defaultPageName] = i_inName2extName(internalName) %
% function [DialogUserData,bModified] = i_ReShowDialog(DialogFig, DialogUD)   %
% function bNewValue = i_RadioBehavior(allButtons, pressedButton)             %
% function i_RadioBehaviorWithPress(allButtons, buttonToPress)                %
% function sfBlocks = stateflow_options(modelName)                            %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%******************************************************************************
% Function - Handle default callback behavior for checkbox in a             ***
%   checkbox/edit pair.                                                     ***
%******************************************************************************
function i_CheckEditPair_DefCheckCallbk(checkbox, edit)

bState = get(checkbox, 'Value');
set(edit, 'Enable', onoff(bState));

% i_CheckEditPair_DefCheckCallbk()


%******************************************************************************
% Function - Construct name for dialog box.
%******************************************************************************
function name = i_DlgName(hModel)

name = ['Simulation Parameters: ' get_param(hModel,'name')];

% end i_DlgName()


%******************************************************************************
% Function - Initialize checkbox/edit pair.                                 ***
%******************************************************************************
function i_InitCheckEditPair(checkbox, edit, onoffState, string,syncWithModel)

if syncWithModel,

  bState = onoff(onoffState);

  User.edit   = edit;
  set(checkbox, ...
    'Value',          bState, ...
    'UserData',       User ...
  );

  set(edit, ...
    'Enable',         onoffState, ...
    'String',         string);
else
  bState = get(checkbox,'Value');
end

set(edit, ...
  'Enable',         onoff(bState));

% end i_InitCheckEditPair()


%******************************************************************************
% Function - Convert internal name w/no spaces to the external name.
%******************************************************************************
function [defaultPageNum, defaultPageName] = i_inName2extName(internalName)

%
% the "internalName" is specified in simulink source file.
%
switch(internalName)
 case 'Solver',
  defaultPageNum  = 1;
  defaultPageName = 'Solver';
 case 'WorkspaceI/O',
  defaultPageNum  = 2;
  defaultPageName = 'Workspace I/O';
 case 'Diagnostics',
  defaultPageNum  = 3;
  defaultPageName = 'Diagnostics';
 case 'Optimization',
  defaultPageNum  = 4;
  defaultPageName = 'Optimization';
 case 'RTW',
  defaultPageNum  = 5;
  defaultPageName = 'RTW';
 case 'RTWExternal',
  % This is for backward compatibility only. We eliminated External tag
  % from this dialog.
  defaultPageNum  = 1;
  defaultPageName = 'Solver';
 otherwise,
  error('M assert: Invalid action');
end

% end i_inName2extName()


%******************************************************************************
% Function - Show an already existing dialog box and if it is invisible,    ***
%   re-sync the existing pages.                                             ***
%******************************************************************************
function [DialogUserData,bModified] = ...
  i_ReShowDialog(DialogFig, DialogUserData,forceReSync)

bModified = 0;
bVisible = onoff(get(DialogFig, 'Visible'));
hModel   = DialogUserData.model;


if (~bVisible || forceReSync) && ~isempty(DialogUserData.SolverPage.Children)
  [DialogUserData, bModified] = i_SyncSolverPage(DialogFig, DialogUserData,1);
end

if (~bVisible || forceReSync) && ...
    ~isempty(DialogUserData.WorkspaceIOPage.Children)
  i_SyncWorkspaceIOPage(DialogUserData,1);
end

if (~bVisible || forceReSync) && ~isempty(DialogUserData.DiagnosticsPage.Children)
  DialogUserData_NotUsed = i_SyncDiagnosticsPage(DialogFig,DialogUserData,1);
end

if (~bVisible || forceReSync) && ~isempty(DialogUserData.AdvancedPage.Children)
  DialogUserData_NotUsed = i_SyncAdvancedPage(DialogFig,DialogUserData,1);
end

if (~bVisible || forceReSync) && ~isempty(DialogUserData.RTWPage.Children)
  DialogUserData_NotUsed = i_SyncRTWPage(DialogUserData,1);
end

%
% Handle a page change if someone has set the 'SimParamPage' property.
% Only change page if the dialog was created in such a way that a
% tab exists for the requested page.
%
[pageNum, pageName] = i_inName2extName(loc_getSimParamPage(hModel));
if pageNum <= length(DialogUserData.tabStrings)
  tabdlg('tabpress', DialogFig, pageName, pageNum);
end

if ~bVisible || forceReSync,
  set(DialogUserData.SystemButtons.Apply, 'Enable', 'off');
end

figure(DialogFig);

% end i_ReShowDialog


%******************************************************************************
% Function - Implement mutual exclusive radio button behavior.              ***
% Assumption: The radio buttons are initialize correctly (1 or 0 are on).   ***
%                                                                           ***
% Returns 1 if a different radio button was turned on, 0 if there was no    ***
%   change.                                                                 ***
%******************************************************************************
function bNewValue = i_RadioBehavior(allButtons, pressedButton)

bNewValue = 1;

value = get(pressedButton, 'Value');

if value == 0,
  % a button cannot turn itself off
  set(pressedButton, 'Value', 1);
  bNewValue = 0;
  return;
else
  % remove pressed button from list
  allButtons(allButtons == pressedButton) = [];

  % turn off all other buttons.
  set(allButtons, 'Value', 0);
end

% end i_RadioBehavior()


%******************************************************************************
% Function - Implement mutual exclusive radio button behavior.  Prior to    ***
%   implementing this behavior, the value of 'buttonToPress' is set to 1 so ***
%   that it will be on and the others will be off.                          ***
%******************************************************************************
function i_RadioBehaviorWithPress(allButtons, buttonToPress)

set(buttonToPress, 'Value', 1);
i_RadioBehavior(allButtons, buttonToPress);

% end i_RadioBehaviorWithPress()


%******************************************************************************
% Function - Load stateflow block's options editor.
%******************************************************************************
function sfBlocks = stateflow_options(modelName)

sfBlocks = find_system(modelName,...
    'FollowLinks','On','LookUnderMasks','all','MaskType','Stateflow');

if(isempty(sfBlocks))
  msgbox(sprintf('No Stateflow blocks in this model'), 'Stateflow message', 'modal');
  return;
end

sf('Private','goto_target',modelName,'rtw')

% end stateflow_options()


%******************************************************************************
% Function - Interface function for updating parameter value on dialog.
%******************************************************************************
function UpdateParamValue(varargin)

mdl = varargin{1};
paramName  = varargin{2};
paramValue = varargin{3};

DialogFig = get_param(mdl, 'SimParamHandle');
DialogUserData = get(DialogFig, 'UserData');

simParamMap = simprmtagmap;
simParamId = find(strcmp(lower(simParamMap(:,1)), lower(paramName)));

if isempty(simParamId)
  % do nothing, can be used for debugging
else
  tagName = simParamMap{simParamId, 2};
  switch tagName
   case 'Solver'
    if ~isempty(DialogUserData.SolverPage.Children)
      i_SyncSolverPage(DialogFig, DialogUserData, 1);
    end
   case 'WorkspaceIO'
    if ~isempty(DialogUserData.WorkspaceIOPage.Children)
      i_SyncWorkspaceIOPage(DialogUserData, 1);
    end
   case 'Diagnostics'
    if ~isempty(DialogUserData.DiagnosticsPage.Children)
      i_SyncDiagnosticsPage(DialogFig, DialogUserData, 1);
    end
   case 'Advanced'
    if ~isempty(DialogUserData.AdvancedPage.Children)
      DialogUserData = i_SyncAdvancedPage(DialogFig, DialogUserData, 1);
    end
   case 'RTW'
    if ~isempty(DialogUserData.RTWPage.Children)
      DialogUserData = i_SyncRTWPage(DialogUserData, 1);
    end
   otherwise
    obj = findobj(DialogFig, 'Tag', tagName);

    if ~isempty(obj)
      switch get(obj, 'style')
       case 'edit'
        set(obj, 'String', paramValue);
       case 'checkbox'
        set(obj, 'value', onoff(paramValue));
       case 'popupmenu'
        idxVal = popupStr2ValMatch(obj, paramValue);
        set(obj, 'value', idxVal);
       case 'listbox'
       otherwise
        % do nothing, internal error
      end
    end
  end
end
set(DialogFig, 'UserData', DialogUserData);

% end UpdateParamValue

%******************************************************************************
% Function - Return matching index value for a given string on a popup menu.
%            Partial match will also return valid index.
%******************************************************************************
function idxVal = popupStr2ValMatch(obj, paramValue)

tagName = get(obj, 'Tag');
switch tagName
 case 'SolverTypePopup+SolverPopup'
  % special case handled in previous function
 case 'MaxOrderPopup'
  idxVal = paramValue;
 case 'OutputOptionPopup'
  switch paramValue
   case 'RefineOutputTimes',
    idxVal = 1;
   case 'AdditionalOutputTimes',
    idxVal = 2;
   case 'SpecifiedOutputTimes',
    idxVal = 3;
   otherwise,
    idxVal = 1;
  end
 case 'SaveFormatPopup'
  switch paramValue
   case 'StructureWithTime',
    idxVal = 1;
   case {'Structure', 'structure'},
    idxVal = 2;
   case {'Array'},
    idxVal = 3;
   otherwise
    idxVal = 1;
  end
 case {'ConsistencyCheckingPopup', 'BoundsCheckingPopup', 'SolverModePopup'}
  strings = get(obj, 'String');
  idxVal = 1;
  for i=1:length(strings)
    if strcmp(lower(paramValue), lower(strings{i}))
      idxVal = i;
      break;
    end
  end
 case 'AssertionControlPopup'
  if strcmp(lower(paramValue(1:3)), 'use')
    idxVal = 1;
  elseif strcmp(lower(paramValue(1:3)), 'ena')
    idxVal = 2;
  else
    idxVal = 3;
  end
 case 'ProdHWCharsPopup'
  if strcmp(paramValue, 'Microprocessor')
    idxVal = 1;
  else
    idxVal = 2;
  end
 otherwise
  idxVal = 1;
end

function page = loc_getSimParamPage(hModel)
  cs = getActiveConfigSet(hModel);
  switch cs.CurrentDlgPage
   case 'Solver'
    page = 'Solver';
   case 'Data Import//Export'
    page = 'WorkspaceI/O';
   case 'Diagnostics'
    page = 'Diagnostics';
   case 'Optimization'
    page = 'Optimization';
   case 'Real-Time Workshop'
    page = 'RTW';
   case 'Real-Time Workshop/Interface'
    page = 'RTWExternal';
   otherwise
    page = 'Solver';
  end
  
function loc_setSimParamPage(hModel, page)
  cs = getActiveConfigSet(hModel);
  switch page
   case 'Solver'
    csPage = 'Solver';
   case 'WorkspaceI/O'
    csPage = 'Data Import//Export';
   case 'Diagnostics'
    csPage = 'Diagnostics';
   case 'Optimization'
    csPage = 'Optimization';
   case 'RTW'
    csPage = 'Real-Time Workshop';
   case 'RTWExternal'
    csPage = 'Real-Time Workshop/Interface';
   otherwise
    csPage = 'Solver';
  end
  cs.CurrentDlgPage = csPage;

function loc_setParams(hModel, pvPairs)
  rtwoptions = '';
  for i = 1:2:length(pvPairs)
    prop = pvPairs{i};
    val  = pvPairs{i+1};
    if ~strcmp(prop, 'RTWOptions')
      set_param(hModel, prop, val);
    else
      rtwoptions = val;
    end
  end
  
  if ~isempty(rtwoptions)
    cs = getActiveConfigSet(hModel);
    cs.switchTarget(get_param(hModel, 'RTWSystemTargetFile'), []);
    cs.setRTWOptions(rtwoptions);
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%% end Utility functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
