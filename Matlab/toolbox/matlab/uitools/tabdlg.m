function varargout = tabdlg(varargin)
%TABDLG Create and manage tabbed dialog box.
%   [hfig, sheetPos] = tabdlg(...
%       'create',strings,tabDims,callback,sheetDims,offsets,default_page)
%
%   'create' - a flag for requesting dialog creation
%
%   strings -  cell array of the tab labels.
%
%   tabDims - a cell array of length 2.
%     tabDims{1} - a vector of same length as 'strings' specifying the
%                  width in pixels, of each tab.
%
%     tabDims{2} - a scalar specifying string heights (in pixels).
%
%   See the ADDITIONAL FUNCTIONALITY section of this help for more info.
%        
%   callback - name of callback function that will be called each time that
%              a new tab is selected.  The callback function will be called
%              with the following arguments:
%              1) 'tabcallbk'     - a text flag
%              2) pressedTab      - the string of selected tab
%              3) pressedTabNum   - the number of the selected tab
%              4) previousTab     - the string of the previously selected tab
%              5) previousTabNum  - the number of the previously selected tab
%              6) hfig            - handle of the figure
%
%              The callback function must manage all aspects of the tabbed
%              dialog box other than the management of the actual tabs
%              (i.e., swapping visibility of controls).
%
%   sheetDims - [width, height] of the tab sheet in pixels.  
%
%   offsets - Four element vector of offsets between the edges
%            of the sheets and the figure border (in pixels):  
%            [ offset from left side of figure
%              offset from top of figure
%              offset from right of figure
%              offset from bottom of figure ]
%
%   default_page - page number that is shown upon creation.
%
%   OPTIONAL ARGUMENTS:
%   font - a two element cell array (arg 8)
%     {'fontname', fontsize}
%          
%     The FactoryUicontrolFontName and FactoryUiControlFontSize are
%     used by default.
%
%   hfig - handle to a figure window (arg 9)
%     If this option is used, the 'font' argument must also be
%     specified.  If the default font is desired, use {}.
%     Sometimes it is necessary to create a figure in order
%     to get text extents for geometry calculations.
%     In this case, create the figure, do geometry calculations
%     and then call tabdlg.  The existing figure will be used
%     for the tabbed dialog box.  Do not place any controls on the
%     figure until after the call tabdlg.
%
%     NOTE: It is assumed that hfig is a non-integer handle and
%     that the figure is invisible!
%
%   RETURNS:
%     hfig     - handle to the newly created tabbed dialog.
%     sheetPos - 4 element position vector of for sheet
%
%     NOTE: the dialog is invisible so that further processing
%           may be done.
%
%   ADDITIONAL FUNCTIONALITY
%
%   tabDims = tabdlg('tabdims', strings, font)
%     Given the font and the strings, returns a tabDims cell array of
%     the form described above.  This is a fairly expensive operation
%     and as such is not done "on the fly" when creating the tabbed
%     dialog.  Doing it before hand and passing the widths in to the
%     creation call results in better performance.
%           
%     strings - see description above
%     font    - see description above
%
%     example: tabDims = tabdlg('tabdims', {'cat', 'bird'});
%
%     NOTE: font is an OPTIONAL argument.
%     NOTE: the height is the height of the string, NOT the height of
%           the tab 

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/04/15 03:26:15 $

Action = lower(varargin{1});

switch(Action),

  case 'create',
    [fig, sheetPos] = i_CreateTabbedDialog(varargin{2:end});
    varargout = {fig, sheetPos};

  case 'tabdims',
    varargout =  {i_DetermineTabDims(varargin{2:end})};

  case 'tabpress',
    hfig = varargin{2};
    DialogUserData = i_GetDialogData(hfig);
    previousTabNum = DialogUserData.activeTabNum;
    [DialogUserData, bModified] = ...
      i_ProcessTabPress(hfig, DialogUserData, varargin{3:end});

    if bModified == 1,
      activeTabNum = varargin{end};

      i_SetDialogData(hfig, DialogUserData);
                   
      feval(DialogUserData.callback, ...
        'tabcallbk', ...
        DialogUserData.strings{activeTabNum}, ...
        activeTabNum, ...
        DialogUserData.strings{previousTabNum}, ...
        previousTabNum, ...
        hfig ...
      );

    end

  otherwise,
     error('Invalid action.');
end


%******************************************************************************
% Function - Get the user data for the tabbed dialog.                       ***
%******************************************************************************
function data = i_GetDialogData(dialog),

oldHiddenHandleStatus = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'on');

dataContainer = findobj(dialog,...
  'Type',       'uicontrol', ...
  'Style',      'text', ...
  'Tag',        'TMWDlgDat@#' ...
);

data = get(dataContainer, 'UserData');

set(0, 'ShowHiddenHandles', oldHiddenHandleStatus);


%******************************************************************************
% Function - Set the user data for the tabbed dialog.                       ***
%******************************************************************************
function i_SetDialogData(dialog, data),

oldHiddenHandleStatus = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'on');

dataContainer = findobj(dialog,...
  'Type',       'uicontrol', ...
  'Style',      'text', ...
  'Tag',        'TMWDlgDat@#' ...
);

if isempty(dataContainer),
  dataContainer = uicontrol(...
    'Parent',           dialog, ...
    'Style',            'text', ...
    'Visible',          'off', ...
    'Tag',              'TMWDlgDat@#' ...
  );
end

set(dataContainer, 'UserData', data);

set(0, 'ShowHiddenHandles', oldHiddenHandleStatus);


%******************************************************************************
% Function - Create the tabbed dialog box.                                  ***
%******************************************************************************
function [hfig, sheetPosActual] = i_CreateTabbedDialog( ...
  strings, tabDims, callback, sheetDims, offsets, default_page, font, hfig...
),

%==============================================================================
% Argument checks.
%==============================================================================
if nargin >= 7 & ~isempty(font),
  fontsize = font{2};
  fontname = font{1};
else
  fontsize = get(0, 'FactoryUicontrolFontSize');
  fontname = get(0, 'FactoryUicontrolFontName');
end

if nargin ~= 8,
  hfig = -1;
end
  

%==============================================================================
% Create figure (dialog)
%==============================================================================
origDefaultUicontrolEnable = get(0, 'DefaultUicontrolEnable');

if hfig == -1,
  hfig = figure( ...
    'Visible',                            'off', ...
    'Color',                              get(0,'FactoryUicontrolBack'), ...
    'Units',                              'pixels', ...
    'Resize',                             'off', ...
    'MenuBar',                            menubar, ...
    'IntegerHandle',                      'off', ...
    'NumberTitle',                        'off', ...
    'DefaultUicontrolUnits',              'pixels', ...
    'DefaultUicontrolEnable',             'inactive' ... 
  );
else,
  set(hfig, ...
    'Color',                              get(0,'FactoryUicontrolBack'), ...
    'Units',                              'pixels', ...
    'Resize',                             'off', ...
    'MenuBar',                            menubar, ...
    'NumberTitle',                        'off', ...
    'DefaultUicontrolUnits',              'pixels', ...
    'DefaultUicontrolEnable',             'inactive' ... 
  );
end

%==============================================================================
% Calculate geometry constants.
%==============================================================================
stringHeight  = tabDims{2};
tabHeight     = tabDims{2} + 5;
tabWidths     = [0; tabDims{1}(:)];
numTabs       = length(tabWidths) - 1;


switch(computer),

  case 'PCWIN',
    
    leftBevelOffset         = 0;
    rightBevelOffset        = 2;   
    topBevelOffset          = 1;
    selectorHeight          = 2;
    selectorLeftFudgeFactor = 0;
    deltaTabs               = 3;
    selectionHoffset        = 1;
    sheetEnableState        = 'off';

  case 'MAC2',
   
    leftBevelOffset         = 2;
    rightBevelOffset        = 2;
    topBevelOffset          = 2;
    selectorHeight          = 3;
    selectorLeftFudgeFactor = -1;
    deltaTabs               = 1;
    selectionHoffset        = deltaTabs;
    sheetEnableState        = 'inactive';
 
  otherwise,

    leftBevelOffset         = 3;
    rightBevelOffset        = 3;
    topBevelOffset          = 2;
    selectorHeight          = 2;
    selectorLeftFudgeFactor = 0;
    deltaTabs               = 0;
    selectionHoffset        = deltaTabs;
    sheetEnableState        = 'off';

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In order to give the selected tab a 3-D look, it is made slightly 
%  taller & wider than its unselected size.  selectionVoffset is the
%  number of pixels by which the selected tabs height is increased.
%  Likewise for selectionHoffset.
% NOTE: The 1st tab only lines up w/ the left side of the sheet when
%       it is the selected tab!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selectionVoffset = 2;

%==============================================================================
% Set figure width & height.
%==============================================================================
figPos = get(hfig, 'Position');

figHeight = ...
  offsets(4)        + ...
  sheetDims(2)      + ...        
  tabHeight         + ...  
  selectionVoffset  + ...        
  offsets(2);

figWidth = offsets(1) + sheetDims(1) + offsets(3);

figPos(3:4) = [figWidth, figHeight];
set(hfig, 'Position', figPos);


%==============================================================================
% Calculate sheet position.
%==============================================================================
sheetPos = [
  offsets(1) + 1
  offsets(4) + 1
  sheetDims(1)
  sheetDims(2)
];

%==============================================================================
% Create the tabs & store selector positions.
%==============================================================================
posTab(4) = tabHeight;
posTab(2) = sheetPos(2) + sheetPos(4) - 1;

tabs(numTabs) = 0;
selectorPos   = zeros(numTabs, 4);

for i = 1:numTabs,

  butDownFcn = ['tabdlg(''tabpress'', gcbf, ''' strings{i} ''', ' sprintf('%d',i) ')'];

  leftEdge =...
    sheetPos(1)            + ...
    selectionHoffset       + ...
    sum(tabWidths(1:i))    + ...
    ( (i-1) * deltaTabs );

  posTab(1) = leftEdge;
  posTab(3) = tabWidths(i+1);

  tabs(i) = uicontrol( ...
    'Parent',           hfig, ...
    'String',           strings{i}, ...
    'Position',         posTab, ...
    'HorizontalAlign',  'center', ...
    'ButtonDownFcn',    butDownFcn ...
  );

  selectorPos(i, :) = [ ...
    leftEdge - selectionHoffset + leftBevelOffset + selectorLeftFudgeFactor ...
    posTab(2) ...
    posTab(3) + selectionHoffset - rightBevelOffset ...
    selectorHeight ...
  ];

end


%==============================================================================
% Create the sheet.
%==============================================================================
sheetPosActual = sheetPos;
sheetPosActual(4) = sheetPosActual(4) + topBevelOffset;
sheet = uicontrol( ...
  'Parent',             hfig, ...
  'Position',           sheetPosActual, ...
  'Enable',             sheetEnableState ...
);

%==============================================================================
% Create the selector.
%==============================================================================
selector = uicontrol( ...
  'Parent',             hfig, ...
  'Style',              'text' ...
);

%==============================================================================
% Save pertinent info in tabbed dialog data container.
%==============================================================================
DialogUserData.tabs             = tabs;
DialogUserData.selector         = selector;
DialogUserData.selectorPos      = selectorPos;
DialogUserData.selectionHoffset = selectionHoffset;
DialogUserData.selectionVoffset = selectionVoffset;
DialogUserData.leftBevelOffset  = leftBevelOffset;
DialogUserData.rightBevelOffset = rightBevelOffset;
DialogUserData.deltaTabs        = deltaTabs;
DialogUserData.activeTabNum     = -1;
DialogUserData.callback         = callback;
DialogUserData.strings          = strings;

%==============================================================================
% Select the default tab.
%==============================================================================
DialogUserData = i_PressTab(hfig, DialogUserData, default_page);

%==============================================================================
% Store the user data.
%==============================================================================
i_SetDialogData(hfig, DialogUserData);

%==============================================================================
% Restore defaults.
%==============================================================================
set(hfig, 'DefaultUicontrolEnable', origDefaultUicontrolEnable);

%******************************************************************************
% Function - Press the specified tab.                                       ***
%******************************************************************************
function DialogUserData = i_PressTab(hfig, DialogUserData, pressedTabNum),

posPressedTab = get(DialogUserData.tabs(pressedTabNum), 'Position');

posPressedTab(1) = posPressedTab(1) - DialogUserData.selectionHoffset;
posPressedTab(3) = posPressedTab(3) + DialogUserData.selectionHoffset;
posPressedTab(4) = posPressedTab(4) + DialogUserData.selectionVoffset;

set(DialogUserData.tabs(pressedTabNum), 'Position', posPressedTab);

set(DialogUserData.selector, ...
  'Position',           DialogUserData.selectorPos(pressedTabNum,:) ...
);

DialogUserData.activeTabNum = pressedTabNum;


%******************************************************************************
% Function - Unpress the specified tab.                                     ***
%                                                                           ***
% Reduces the size of the specified tab.                                    ***
%                                                                           ***
% NOTE: This function does not move the selector or update the              ***
%   activeTabNum field.  It is assumed that a call to i_PressTab will       ***
%   soon occur and take care of these tasks.                                ***
%******************************************************************************
function i_UnPressTab(hTab, nTab, DialogUserData),

posTab = get(DialogUserData.tabs(nTab), 'Position');

posTab(1) = posTab(1) + DialogUserData.selectionHoffset;
posTab(3) = posTab(3) - DialogUserData.selectionHoffset;
posTab(4) = posTab(4) - DialogUserData.selectionVoffset;

set(DialogUserData.tabs(nTab), 'Position', posTab);


%******************************************************************************
% Function - Process tab press action.                                      ***
%******************************************************************************
function [DialogUserData, bModified] = ...
  i_ProcessTabPress(hfig, DialogUserData, string, pressedTabNum),

%==============================================================================
% Initialize.
%==============================================================================
bModified = 0;

tabs         = DialogUserData.tabs;
activeTabNum = DialogUserData.activeTabNum;

if pressedTabNum == activeTabNum,
  return;
end

i_UnPressTab(tabs(activeTabNum), activeTabNum, DialogUserData);
DialogUserData = i_PressTab(hfig, DialogUserData, pressedTabNum);
bModified = 1;


%******************************************************************************
% Function - Determine the widths of the tabs based on the strings.         ***
%******************************************************************************
function tabdims = i_DetermineTabDims(strings, font),

%==============================================================================
% Argument checks.
%==============================================================================
if nargin == 1,
  fontsize = get(0, 'DefaultUicontrolFontSize');
  fontname = get(0, 'DefaultUicontrolFontName');
else
  fontsize = font{2};
  fontname = font{1};
end

%==============================================================================
% Create figure and sample text control.
%==============================================================================
hfig  = figure('Visible', 'off');
hText = uicontrol('Style', 'text', 'FontWeight', 'bold');

%==============================================================================
% Get widths.
%==============================================================================
tabdims{1} = zeros(length(strings), 1);
for i=1:length(strings),
  set(hText, 'String', strings{i});
  ext = get(hText, 'Extent');
  tabdims{1}(i) = ext(3) + 4;
end  

tabdims{2} = ext(4) + 2;

%==============================================================================
% Delete objects.
%==============================================================================
delete(hfig);






