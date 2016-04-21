function sfsrch(varargin),
%SFSRCH( VARARGIN )

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/15 01:00:18 $

watchon;
Action = varargin{1};

if isnumeric(Action) & sf('ishandle', Action'),
	arg2 = Action;
	Action = 'create';	
else, arg2 = varargin{2};
end;

switch(Action),

  case 'create',
     if(sf('MatlabVersion')>=600 & ...
        ~testing_stateflow_in_bat)
     %% WISH We invoke the integrated debugger in only in R12 and also when not in
     %% BAT since we havent fixed the tests that call sfsrch.
        if (usejava('mwt'))
	  findslobj('Create',sf('FullNameOf',arg2(1),'/'));
	  return;
	end
     end
    %================================================================
    % Create the dialog.
    %================================================================
    [DialogUserData,bModified,DialogFig] = i_Create(arg2);

    parentFig = gcbf;
    if ~isempty(parentFig), watchoff(parentFig); end;
    if bModified == 1, set(DialogFig, 'UserData', DialogUserData); end;


  case 'StringPage'
    %================================================================
    % Pass request to StringPage manager function.
    %================================================================
    DialogFig = varargin{3};
    DialogUserData = get(DialogFig, 'UserData');
    [DialogUserData, bModified] = i_ManageStringPage(...
      DialogFig, DialogUserData, varargin{2});

    if bModified == 1,
      set(DialogFig, 'UserData', DialogUserData);
    end

  case 'ReSort'
    %================================================================
    % Pass request to AdvancedPage manager function.
    %================================================================
    DialogFig = varargin{3};
    DialogUserData = get(DialogFig, 'UserData');
    [DialogUserData, bModified] = i_manage_sort_buttons(...
      DialogFig, DialogUserData, varargin{2});

    if bModified == 1,
      set(DialogFig, 'UserData', DialogUserData);
    end

  case 'ReSize'
    %================================================================
    % Pass request to AdvancedPage manager function.
    %================================================================
    DialogFig = varargin{2};
    DialogUserData = get(DialogFig, 'UserData');
    [DialogUserData, bModified] = i_manage_resize(...
      DialogFig, DialogUserData);

    if bModified == 1,
      set(DialogFig, 'UserData', DialogUserData);
    end


  case 'Results'
    %================================================================
    % Pass request to Results manager function.
    %================================================================
    DialogFig = varargin{2};
    DialogUserData = get(DialogFig, 'UserData');
    [DialogUserData, bModified] = i_manage_results(...
      DialogFig, DialogUserData);

    if bModified == 1,
      set(DialogFig, 'UserData', DialogUserData);
    end

  case 'SystemButtons'
    %================================================================
    % Pass request to SystemButtons manager function.
    %================================================================
    DialogFig = varargin{3};
    DialogUserData = get(DialogFig, 'UserData');
    [DialogUserData, bModified] = i_ManageSystemButtons(...
      DialogFig, DialogUserData, varargin{2});

    if bModified == 1,
      set(DialogFig, 'UserData', DialogUserData);
    end

% Dead code WBA,EMM 6/7/99
%  case 'RefEnable'
%    %================================================================
%    % Pass request to ResultsDisplay manager function.
%    %================================================================
%    DialogFig = varargin{2};
%    DialogUserData = get(DialogFig, 'UserData');
%    [DialogUserData, bModified] = i_ManageReference(...
%      DialogFig, DialogUserData);
%
%    if bModified == 1,
%      set(DialogFig, 'UserData', DialogUserData);
%    end

  case 'SummaryDisplay'
    %================================================================
    % Pass request to SummaryDisplay manager function.
    %================================================================
    DialogFig = varargin{2};
    DialogUserData = get(DialogFig, 'UserData');
    [DialogUserData, bModified] = i_ManageSummaryDisplay(...
      DialogFig, DialogUserData);

    if bModified == 1,
      set(DialogFig, 'UserData', DialogUserData);
    end

  case 'ContextMenu'
    %================================================================
    % Pass request to SummaryDisplay manager function.
    %================================================================
    DialogFig = varargin{2};
    DialogUserData = get(DialogFig, 'UserData');
    action = varargin{3};
    [DialogUserData, bModified] = manage_context_menu(...
      DialogFig, DialogUserData,action);

    if bModified == 1,
      set(DialogFig, 'UserData', DialogUserData);
    end


  otherwise,
    %================================================================
    % Bogus action.
    %================================================================
    error('Invalid action');

end

if ishandle(DialogFig);
	watchoff(DialogFig);
end


%******************************************************************************
% Function - Create the dialog box.                                         ***
%******************************************************************************
function [DialogUserData, bModified, DialogFig] = i_Create(ids),

CHART = sf('get', 'default','chart.isa');
MACHINE = sf('get', 'default','machine.isa');

ISA = unique(sf('get', ids, '.isa'));
if length(ISA) ~= 1, error('Mixed types passed to sfsrch()'); end;

switch ISA,
	case CHART,
		chartIds = ids;
		machine = unique(sf('get',chartIds,'.machine'));
	case MACHINE, 
		machine = ids;
		chartIds = sf('get', machine,'.charts');
	otherwise, error('Bad object type passed to sfsrch()');
end;

switch length(machine)
	case 0, error('why?');
	case 1,
	otherwise,
		warning('Ambiguous machine');
		machine = machine(1);
end

DialogFig = sf('get',machine,'.searchTool');

if DialogFig>0 & ishandle(DialogFig)
	DialogUserData = get(DialogFig,'UserData');
	if ~vset(DialogUserData.chartIds,'==',chartIds)
		% reset the search space to the new chartIds
		DialogUserData.chartIds = chartIds;
		bModified = 1;
	else
		bModified = 0;
	end
	figure(DialogFig);
	return;
end

bModified = 1;

%
% Create constants based on current computer.
%

thisComputer = computer;

fontsize = get(0, 'FactoryUicontrolFontSize');
fontname = get(0, 'FactoryUicontrolFontName');
screenSize = get(0, 'ScreenSize');
listboxFixedFontName = get(0,'FixedWidthFontName');

switch(thisComputer),
  case 'PCWIN',
    DialogUserData.popupBackGroundColor = 'w';
    dividingLineStyle     = 'pushbutton';
    dividingLineThickness = 4;
    listboxFixedFontSize  = 9;
    if(screenSize(3)<800),		     % Reduce font size when using 640x480
      listboxFixedFontSize  = 7;
    end

%  case 'MAC2',
%    DialogUserData.popupBackGroundColor = 'w';
%    dividingLineStyle     = 'frame';
%    dividingLineThickness = 3;
%    listboxFixedFontSize  = 10;

  otherwise,  % X
    DialogUserData.popupBackGroundColor = get(0, 'FactoryUicontrolBackgroundColor');
    dividingLineStyle     = 'pushbutton';
    dividingLineThickness = 4;
    listboxFixedFontSize  = 10;
end


%
% Create an empty figure (we need it now for text extents).
%


machineName = sf('get',machine,'.name');

figName = ['Stateflow Finder (',machineName,')'];
figColor = get(0,'defaultuicontrolbackgroundcolor');


DialogFig = figure( ...
  'Visible',                            'off' ...
 ,'Color',								figColor ...
 ,'DefaultUicontrolBackgroundColor',    figColor ...
 ,'DefaultUicontrolHorizontalAlign',    'left' ...
 ,'DefaultUicontrolFontname',           fontname ...
 ,'DefaultUicontrolFontsize',           fontsize ...
 ,'DefaultUicontrolUnits',              'points' ...
 ,'Units',                              'points' ...
 ,'HandleVisibility',                   'callback' ...
 ,'Colormap',                           [] ...
 ,'MenuBar',                            menubar ...
 ,'NumberTitle',                        'off' ...
 ,'Name',                               figName ...      
 ,'IntegerHandle',                      'off' ...
 ,'DoubleBuffer',                       'on'...
 ,'Tag',                                tag_l ...
);

sf('set',machine,'.searchTool',DialogFig);

%
% Create a text object for text sizing.
%

textExtent = uicontrol( ...
  'Parent',     DialogFig, ...
  'Visible',    'off', ...
  'Style',      'text', ...
  'Units',      'points'...
);


%
% Construct common geometry constants.
%

commonGeom = i_CreateCommonGeom(textExtent);
commonGeom.textExtent = textExtent;
commonGeom.listboxFixedFontName = listboxFixedFontName;
commonGeom.listboxFixedFontSize = listboxFixedFontSize;
commonGeom.dividingLineStyle = dividingLineStyle;
commonGeom.lineThickness     = dividingLineThickness;

if(screenSize(3)<800)											  % Reduce system button width 
  commonGeom.sysButtonWidth = commonGeom.sysButtonWidth -20;	  % When using 640x480
end


% Find the character width for listbox output

oldFontName = get(textExtent, 'FontName');  % Get original settings
oldFontSize = get(textExtent, 'FontSize');

testString = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

set(textExtent, 'FontName',commonGeom.listboxFixedFontName);
set(textExtent, 'FontSize', commonGeom.listboxFixedFontSize);
set(textExtent, 'String', testString(1:70));

ext = get(textExtent, 'Extent');
commonGeom.fixedCharWidth = ext(3)/70;
commonGeom.fixedCharHeight = ext(4);

% Return to original font

set(textExtent, 'FontName',oldFontName);
set(textExtent, 'FontSize', oldFontSize);


%
% -------------------------- Begin Label Information --------------------------
%
%
%  String Criteria Groupbox
%

DialogUserData.stringLabel.stringBox = 'String Criteria';
DialogUserData.stringLabel.stringEdit = 'Look for:';
DialogUserData.stringLabel.stringLoc = 'Look in:';
DialogUserData.stringLabel.LocationList = {'Any', 'Label','Name', 'Description', 'Document Link','Custom Code'};

%
%  Search Method Groupbox
%

DialogUserData.methodLabel.methodBox = 'Search Method';
DialogUserData.methodLabel.normalButton = 'Normal/Wildcard (regular expression)';
DialogUserData.methodLabel.exactButton = 'Exact Word match';

%
%  Search summary display
%

DialogUserData.summaryLabel.numMatches = 'Matches';
DialogUserData.summaryLabel.historyPopup = 'Search History:';


%
%  Object Type Groupbox
%

DialogUserData.objectLabel.objectBox = 'Object Type';
DialogUserData.objectLabel.objectTypeNames = {'States','Transitions','Junctions','Events','Data','Targets'};

%
% Map of valid types corresponding to string location
% (Certain object types will be eliminated due to the string Location selection)
%

%                               State Trans Junct  Event Data Targets
DialogUserData.stringLocMap = {[  1     1     1      1     1      1]; ...  % Any
                               [  1     1     0      0     0      0]; ...  % Label
                               [  1     0     0      1     1      1]; ...  % Name
                               [  1     1     1      1     1      1]; ...  % Description
                               [  1     1     1      1     1      1]; ...  % Document Link
                               [  0     0     0      0     0      1]};     % Custom Code
                             
DialogUserData.objectTypeCache = ones(1,6);

%
%  Referencing Groupbox
%

DialogUserData.referenceLabel.referenceBox = 'Referencing';
DialogUserData.referenceLabel.enableCheckbox = 'Label must contain reference to:';


%
%  Result page labels
%

DialogUserData.resultLabel = {'Type','Label','Chart','Parent','Source','Destination'};

%
%  System button labels
%

DialogUserData.sysButtonsLabel = {'Close','Help','Clear','Refine','Find'};


%
% -------------------------- End Label Information ----------------------------
%


%
%  Figure and sheet dimension calculations.  
%
%  All fixed dimension control groups will be sized first.  
%  Based on these sizes, the variable sized control groups 
%  can be sized.  Once all information is available the sheet
%  dimensions and figure dimensions will be determined.
%

%       
%       *****************************
%       *                           *
%       *     Layout Constants      *
%       *                           *
%       *****************************
%       

      minHorizDelta =   10;	 % horizontal separation between groups of uicontrols
		vertDelta = 	   10;	 % vertical separation between groups of uicontrols




[stringCriterExtent, stringCriterRelPos] = ...
  i_layoutStringCrit(commonGeom,DialogUserData.stringLabel);
[SearchMethodExtent, searchMethodRelPos] = ...
  i_layoutSearchMethod(commonGeom,DialogUserData.methodLabel);
[ObjectTypeBoxExtent, objectTypeRelPos] = ...
  i_layoutObjectTypeBox(commonGeom,DialogUserData.objectLabel);
[ResultsExtent, resultCtrlRelPos] = i_layoutResults(commonGeom);
           
%
% Find figure width, the larger of the required results width and
%	top pane width and available width for summary display
%

reqTopWidth = stringCriterExtent(1) + SearchMethodExtent(1) + ...
   commonGeom.sysButtonWidth + 2*minHorizDelta;

if( reqTopWidth > ResultsExtent(1) ),
   figWidth = reqTopWidth + 2*commonGeom.figSideEdgeBuffer;
else
   figWidth = ResultsExtent(1) + 2*commonGeom.figSideEdgeBuffer;
end


horizDelta = (figWidth -  SearchMethodExtent(1) -  stringCriterExtent(1) -...
   		2*commonGeom.figSideEdgeBuffer - commonGeom.sysButtonWidth)/2;
histWidth = figWidth - 2*commonGeom.figSideEdgeBuffer - horizDelta - commonGeom.sysButtonWidth;




%
%  Layout summary diplay controls
%
   
[SummaryDispExtent, summaryDispRelPos] = ...
  i_layoutSummaryDisp(commonGeom, DialogUserData.summaryLabel,histWidth);


%
% Find the system button group height
%

sysGroupHeight =  stringCriterExtent(2) + ObjectTypeBoxExtent(2) +  SummaryDispExtent(2) + ...
				  2*vertDelta; 


[SysButtonsExtent, sysButtonsRelPos] = ...
  i_layoutSysButtons(commonGeom,sysGroupHeight);

figHeight =  sysGroupHeight + commonGeom.figTopEdgeBuffer + commonGeom.figBottomEdgeBuffer;

        

%
% Find the offsets for each group of uicontrols, starting in the lower right
%

	cxCur =  commonGeom.figSideEdgeBuffer;
	cyCur = commonGeom.figBottomEdgeBuffer;

DialogUserData.SummaryDispOffset = [cxCur cyCur];

	cxCur = cxCur + SummaryDispExtent(1) + horizDelta;		% move to right

DialogUserData.SysButtonsOffset = [cxCur cyCur];

	cxCur =  commonGeom.figSideEdgeBuffer;   				% move to the left 
	cyCur = commonGeom.figBottomEdgeBuffer + ...			% move up
	SummaryDispExtent(2) + vertDelta;		 			

DialogUserData.ObjectTypeBoxOffset = [cxCur cyCur];

	cyCur = cyCur + ObjectTypeBoxExtent(2) + vertDelta;		% move up		 			

DialogUserData.stringCriterOffset = [cxCur cyCur];

	cxCur = cxCur + stringCriterExtent(1) + horizDelta;		% move to right 
	cyCur = figHeight -	commonGeom.figTopEdgeBuffer	- ...	% move up
	 SearchMethodExtent(2); 

DialogUserData.SearchMethodOffset = [cxCur cyCur];

DialogUserData.ResultsOffset = [commonGeom.figSideEdgeBuffer ...
                                commonGeom.figBottomEdgeBuffer];	 

% Adjust Width of Object Type Box for better appearance

objectTypeRelPos.groupBoxPos(3) =	 SummaryDispExtent(1);


               
% Resize the figure to the proper dimensions

curPos = get(DialogFig,'Position');
set(DialogFig,'Position',[curPos(1:2) figWidth figHeight]);

%
% Create initial user data.
%

DialogUserData.chartIds                 = chartIds;
DialogUserData.machine                  = machine;
DialogUserData.commonGeom               = commonGeom;
DialogUserData.objectTypeRelPos         = objectTypeRelPos;
DialogUserData.resultCtrlRelPos         = resultCtrlRelPos;
DialogUserData.sysButtonsRelPos         = sysButtonsRelPos;
DialogUserData.summaryDispRelPos        = summaryDispRelPos;
DialogUserData.stringCriterRelPos       = stringCriterRelPos;
DialogUserData.searchMethodRelPos       = searchMethodRelPos;
DialogUserData.resultCtrlRelPos         = resultCtrlRelPos;
DialogUserData.summaryDispRelPos        = summaryDispRelPos;
DialogUserData.stringCriterRelPos       = stringCriterRelPos;
DialogUserData.resultExtent             = ResultsExtent;
DialogUserData.stringCriteria.children  = [];
DialogUserData.searchMethod.children    = [];
DialogUserData.results.children         = [];
DialogUserData.sysButtons.children      = [];
DialogUserData.summaryDisplay.children  = [];
DialogUserData.objectType.children      = [];
DialogUserData.reference.children       = [];
DialogUserData.startingSearchSpace      = [];
DialogUserData.objectTypeCache      	= [];

DialogUserData.thisComputer = thisComputer;



%
% Create the groups of uicontrols:
%

DialogUserData = i_drawStringCrit(DialogFig, DialogUserData, ...
                                  DialogUserData.stringCriterOffset);

DialogUserData = i_drawSearchMethod(DialogFig, DialogUserData, ...
                                    DialogUserData.SearchMethodOffset);

DialogUserData = i_drawObjectTypeBox(DialogFig, DialogUserData, ...
                                     DialogUserData.ObjectTypeBoxOffset);

DialogUserData = i_drawSysButtons(DialogFig, DialogUserData, ...
                                  DialogUserData.SysButtonsOffset);

DialogUserData = i_drawSummaryDisp(DialogFig, DialogUserData, ...
                                   DialogUserData.SummaryDispOffset);

%
% Main portions of fig are created.
%

set(DialogFig, 'Visible', 'on');
set(DialogFig,'Resize','off');


i_InstallStringCallbacks(DialogFig, DialogUserData);
i_InstallSystemButtonCallbacks(DialogFig, DialogUserData);






%******************************************************************************
% Function - Create common geometry constants.                              ***
%******************************************************************************
function commonGeom = i_CreateCommonGeom(textExtent),

sysOffsets = sluigeom;

%
% Define generic font characterists.
%

calibrationStr = ...
  'abcdefghijklmnopqrstuvwxyz';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

charHeight = ext(4);

commonGeom.textHeight            = charHeight;
commonGeom.editHeight            = charHeight + sysOffsets.edit(4);
commonGeom.checkboxHeight        = charHeight + sysOffsets.checkbox(4);
commonGeom.radiobuttonHeight     = charHeight + sysOffsets.radiobutton(4);
commonGeom.popupHeight           = charHeight + sysOffsets.popupmenu(4);
commonGeom.sysButtonHeight       = 16 + sysOffsets.pushbutton(4);
commonGeom.sysButtonWidth        = 50 + sysOffsets.pushbutton(3);
commonGeom.sysButtonDelta        = 6;
commonGeom.sheetSideEdgeBuffer   = 6;
commonGeom.sheetTopEdgeBuffer    = 8;
commonGeom.sheetBottomEdgeBuffer = 6;
commonGeom.frameBottomEdgeBuffer = 4;
commonGeom.frameTopEdgeBuffer    = (commonGeom.textHeight/2) + 2;
commonGeom.frameSideEdgeBuffer   = 8;
commonGeom.frameDelta            = 10;
commonGeom.figBottomEdgeBuffer   = 3;
commonGeom.figTopEdgeBuffer      = 15;
commonGeom.figSideEdgeBuffer     = 3;
commonGeom.sysButton_SheetDelta  = 3;
commonGeom.groupboxVerticalDelta = 9;

commonGeom.bottomSheetOffset = ...
  commonGeom.figBottomEdgeBuffer    + ...
  commonGeom.sysButtonHeight        + ...
  commonGeom.sysButton_SheetDelta; 

commonGeom.sysOffsets = sysOffsets;




%********************************************************************************
% Function - Create layout for results page                                   ***
%********************************************************************************

function [extent, resultCtrlRelPos] = i_layoutResults(commonGeom)

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       commonGeom - Structure with standard dimensions for control objects   *
%                    and frame spacing.                                       *
%                                                                             *
%                                                                             *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       extent - A vector with [total width, total height] for all combined   * 
%                elements.                                                    *
%                                                                             *
%       resultCtrlRelPos - Relative positions for each element assuming       *  
%                          (0,0) for starting corner.                         *
%                                                                             *
%******************************************************************************


%       
%       *****************************
%       *                           *
%       *     Layout Constants      *
%       *                           *
%       *****************************
%       

        columnCharWidth =       [8 20 9 20 15 15];
        optionsColDelta =       25;
        titleButtonHeight =     1.2*commonGeom.textHeight;
        scrollBarWidth =        4;
        resultsTopBuffer =      6;


%
% Some frequently used variables:
%

sysOffsets   = commonGeom.sysOffsets;
textExtent   = commonGeom.textExtent;
fixedCharWidth = commonGeom.fixedCharWidth;
fixedCharHeight = commonGeom.fixedCharHeight;


%
% Determine dimensions of the listbox:
%


totColCharWidth = columnCharWidth + [1 1 1 1 1 0];
totalColumnWidth = fixedCharWidth * totColCharWidth;

listBoxWidth = sum(totalColumnWidth) + ...
               sysOffsets.listbox(3) + scrollBarWidth;
                                
listBoxHeight = 8*fixedCharHeight + sysOffsets.listbox(4);

resultCtrlRelPos.resultListbox = [0 0 listBoxWidth listBoxHeight];

%
% Layout the title buttons
%

cyCur = listBoxHeight;
cxCur = 0;

resultCtrlRelPos.titleButtons = [];

for k=1:length(totalColumnWidth)

  position = [cxCur cyCur totalColumnWidth(k) titleButtonHeight];
  resultCtrlRelPos.titleButtons =[resultCtrlRelPos.titleButtons;position];
  cxCur = cxCur + totalColumnWidth(k);
  
end

%
% Calculate position for separating line
%

cxCur = 0;
cyCur = cyCur + titleButtonHeight + resultsTopBuffer;

resultCtrlRelPos.line = [cxCur cyCur listBoxWidth ...
  commonGeom.lineThickness];


%
% Find the overall dimensions to return
%

width = listBoxWidth;
height = listBoxHeight + titleButtonHeight + resultsTopBuffer +...
  commonGeom.lineThickness;

extent = [width height];


%******************************************************************************
% Function - Create results page.                                           ***
%******************************************************************************
function DialogUserData = i_drawResults(DialogFig, DialogUserData, startXY);

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       startXY - The (x,y) pair for the lower left corner.                   *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************


offset = [startXY 0 0];

commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;


resultCtrlRelPos = DialogUserData.resultCtrlRelPos;
resultLabel = DialogUserData.resultLabel;

%
% Create output listbox.
%


temp = ' ';


Children.OutputList = uicontrol( ...
  'Parent',             DialogFig, ...
  'Style',              'listbox', ...
  'String',             temp, ...
  'Fontname',           commonGeom.listboxFixedFontName, ...
  'Fontsize',           commonGeom.listboxFixedFontSize, ...
  'Position',           resultCtrlRelPos.resultListbox+offset, ...
  'BackgroundColor',    'w', ...
  'Max',                20, ...
  'Callback',                   'sf(''Private'',''sfsrch'',''Results'',gcbf);'...
);




%
% Create the listbox context menu
%

Children.OutputContext = uicontextmenu('Parent',DialogFig);

Children.ctxExplore = uimenu(Children.OutputContext, ...
	'Label',		'Explore', ...
	'Callback',		'sf(''Private'',''sfsrch'',''ContextMenu'', gcbf,''Explore'')');

Children.ctxEdit = uimenu(Children.OutputContext, ...
	'Label',		'Edit', ...
	'Callback',		'sf(''Private'',''sfsrch'',''ContextMenu'', gcbf,''Edit'')');

uimenu(Children.OutputContext, ...
	'Label',		'Properties', ...
	'Callback',		'sf(''Private'',''sfsrch'',''ContextMenu'', gcbf,''Properties'')');

%
% Install the context menu
%
set(Children.OutputList, 'UIContextMenu',Children.OutputContext);


%
% Create the title buttons
%

Children.titleButtons = [];

for k=1:length(resultCtrlRelPos.titleButtons)
  handle = uicontrol( ...
    'Parent',             DialogFig, ...
    'String',             resultLabel{k}, ...
    'Horizontalalign',    'center', ...
    'Position',           resultCtrlRelPos.titleButtons(k,:)+offset ...
  );
  Children.titleButtons = [Children.titleButtons handle];
end

set(Children.titleButtons, ...
  {'Callback'},        {'sf(''Private'',''sfsrch'',''ReSort'', 1, gcbf)', ...
                        'sf(''Private'',''sfsrch'',''ReSort'', 2, gcbf)', ...
                        'sf(''Private'',''sfsrch'',''ReSort'', 3, gcbf)', ...
                        'sf(''Private'',''sfsrch'',''ReSort'', 4, gcbf)', ...
                        'sf(''Private'',''sfsrch'',''ReSort'', 5, gcbf)', ...
                        'sf(''Private'',''sfsrch'',''ReSort'', 6, gcbf)'}' );


%
% Create dividing line.
%

Children.Line = uicontrol(... 
  'Parent',             DialogFig, ...
  'Style',              commonGeom.dividingLineStyle, ...
  'Enable',             'off', ...
  'Position',           resultCtrlRelPos.line+offset ...
);

%
% Add the new handles to the output structure
%

DialogUserData.results.children = Children;




%********************************************************************************
% Function - Create layout for system buttons.                                ***
%********************************************************************************

function [extent, sysButtonsRelPos] = i_layoutSysButtons(commonGeom,totHeight)

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       commonGeom - Structure with standard dimensions for control objects   *
%                    and frame spacing.                                       *
%                                                                             *
%       totWidth - The width the system buttons should occupy. This will be   *
%                  returned in the width element of extent.                   *
%                                                                             *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       extent - A vector with total width, total height for all combined     * 
%                elements.                                                    *
%                                                                             *
%                NOTE: The returned size already incorporates edge spacing    *
%                      as this is a variable size control group.              *
%                                                                             *
%       sysButtonsRelPos - Relative positions for each element assuming       *  
%                          (0,0) for starting corner.                         *
%                                                                             *
%******************************************************************************

%       
%       *****************************
%       *                           *
%       *     Layout Constants      *
%       *                           *
%       *****************************
%       

        numSysButtons =         5;
        sideGroupBuffer =       4;
        %topGroupBuffer =        10;


textExtent = commonGeom.textExtent;


vertButtonDelta = (totHeight - numSysButtons * commonGeom.sysButtonHeight ) ...
  / (numSysButtons - 1);
  

%
%  Layout the bottom buttons
%


cxCur = 0;   
cyCur = 0;

sysButtonsRelPos.Buttons = [];

for k=1:numSysButtons
  position = [cxCur cyCur commonGeom.sysButtonWidth ...
              commonGeom.sysButtonHeight];
  sysButtonsRelPos.Buttons = [sysButtonsRelPos.Buttons;position];
  cyCur = cyCur + commonGeom.sysButtonHeight + vertButtonDelta;
end  


%
% Return the overall dimensions
%

width = commonGeom.sysButtonWidth;
         
extent = [width totHeight];



%********************************************************************************
% Function - Create layout for search display.                                ***
%********************************************************************************

function [extent, summaryDispRelPos] = i_layoutSummaryDisp(commonGeom, summaryLabel,totWidth)

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       commonGeom - Structure with standard dimensions for control objects   *
%                    and frame spacing.                                       *
%                                                                             *
%       summaryLabel - Structure with label strings.                                                                      *
%                                                                             *
%                                                                             *
%       totWidth - The width the system buttons should occupy. This will be   *
%                  returned in the width element of extent.                   *
%                                                                             *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       extent - A vector with total width, total height for all combined    * 
%                elements.                                                    *
%                                                                             *
%                NOTE: The returned size already incorporates edge spacing    *
%                      as this is a variable size control group.              *
%                                                                             *
%       summaryDispRelPos - Relative positions for each element assuming      *  
%                          (0,0) for starting corner.                         *
%                                                                             *
%******************************************************************************

%       
%       *****************************
%       *                           *
%       *     Layout Constants      *
%       *                           *
%       *****************************
%       

        labelDelta =			4;		% Vertical separation of control object and its label
        cntrlDelta =       15;		% Horizontal separation of uicontrols


textExtent = commonGeom.textExtent;

%
% Match Display
%

cxCur = 0; 
cyCur = 0;

summaryDispRelPos.MatchDisplay = [cxCur cyCur ...
  commonGeom.sysButtonWidth commonGeom.textHeight];

%
% Search History Popup
%

cxCur = cxCur + commonGeom.sysButtonWidth + cntrlDelta;

width = totWidth - cxCur;
        
summaryDispRelPos.HistoryPopup = [cxCur cyCur width commonGeom.popupHeight];

%
% Match Label
%

cxCur = 0; 
cyCur = cyCur + commonGeom.popupHeight + labelDelta;

set(textExtent,'String',summaryLabel.numMatches);
ext = get(textExtent,'extent');
width = ext(3);

summaryDispRelPos.MatchLabel = [cxCur cyCur ...
  width commonGeom.textHeight];

%
% Search History Label
%

cxCur = cxCur + commonGeom.sysButtonWidth + cntrlDelta;

set(textExtent,'String',summaryLabel.historyPopup);
ext = get(textExtent,'extent');
width = ext(3);

summaryDispRelPos.HistoryLabel = [cxCur cyCur ...
  width commonGeom.textHeight];

height = cyCur +  commonGeom.textHeight;      
                
extent = [totWidth height];


                

%******************************************************************************
% Function - Create system buttons.                                         ***
%******************************************************************************

function DialogUserData = i_drawSysButtons(DialogFig, DialogUserData, startXY);


%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       startXY - The (x,y) pair for the lower left corner.                   *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************


offset = [startXY 0 0];

sysButtonsRelPos = DialogUserData.sysButtonsRelPos;
sysButtonsLabel = DialogUserData.sysButtonsLabel;

commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;

%
% Create the system buttons
%

Children.Buttons = [];

for k=1:length(sysButtonsLabel)
  handle = uicontrol( ...
    'Parent',             DialogFig, ...
    'String',             sysButtonsLabel{k}, ...
    'Horizontalalign',    'center', ...
    'Position',           sysButtonsRelPos.Buttons(k,:)+offset ...
  );
  Children.Buttons = [Children.Buttons handle];
end

%
%  Set the initial Enable/Disable
%

set(Children.Buttons, ...
  {'Enable'},        {'on', ...     
                      'on', ...     
                      'off', ...     
                      'off', ...    
                      'on'}'); 


%
% Add the new handles to the output structure
%

DialogUserData.sysButtons.children = Children;



                

%******************************************************************************
% Function - Create search summary display.                                 ***
%******************************************************************************

function DialogUserData = i_drawSummaryDisp(DialogFig, DialogUserData, startXY);


%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       startXY - The (x,y) pair for the lower left corner.                   *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************


offset = [startXY 0 0];

summaryDispRelPos = DialogUserData.summaryDispRelPos;
summaryLabel = DialogUserData.summaryLabel;

commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;

figColor = get(DialogFig,'DefaultUicontrolBackgroundColor');


%
%  Use a frame and text for Matches display
%



Children.MatchDisplay = uicontrol( ...
  'Parent',             DialogFig, ...
  'Style',              'text', ...
  'BackGroundColor',    'k', ...
  'ForeGroundColor',    'w', ...
  'HorizontalAlignment', 'right', ...
  'String',             '0', ...
  'Position',           summaryDispRelPos.MatchDisplay+offset ...
);


%
%  Add the display label
%

Children.MatchLabel = uicontrol( ...
  'Parent',             DialogFig, ...
  'Style',              'text', ...
  'String',             summaryLabel.numMatches, ...
  'Position',           summaryDispRelPos.MatchLabel+offset ...
);


%
% Create Search History controls.
%

Children.HistoryLabel = uicontrol( ...
  'Parent',             DialogFig, ...
  'Style',              'text', ...
  'String',             summaryLabel.historyPopup, ...
  'Position',           summaryDispRelPos.HistoryLabel+offset...
);

Children.HistoryPopup = uicontrol( ...
  'Parent',             DialogFig, ...
  'BackgroundColor',    figColor, ...
  'Style',              'popupmenu', ...
  'String',             '  ', ...
  'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
  'Position',           summaryDispRelPos.HistoryPopup+offset, ...
  'Callback',           'sf(''Private'',''sfsrch'',''SummaryDisplay'', gcbf);', ...
  'Enable',             'off' ...
);

%
% Add the new handles to the output structure
%

DialogUserData.summaryDisplay.children = Children;




%******************************************************************************
% Function - Calculate positions for string criteria box & return the total ***
%  extent of all controls ([width height]).                                 ***
%                                                                           ***
% Positions are calculated relative to the lower left corner.               ***
%******************************************************************************

function [extent, stringCriterRelPos] = i_layoutStringCrit(commonGeom,stringLabel)

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       commonGeom - Structure with standard dimensions for control objects   *
%                    and frame spacing.                                       *
%                                                                             *
%       stringLabel -  Structure containing label strings used for sizing     *                                                  
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Output Description                                                    *
%                                                                             *
%       extent - A vector with [total width, total height] for all combined   * 
%                elements.                                                    *
%                                                                             *
%       stringCriterRelPos - Relative positions for each element assuming     *  
%                            (0,0) for starting corner.                       *
%                                                                             *
%******************************************************************************




%       
%       *****************************
%       *                           *
%       *     Layout Constants      *
%       *                           *
%       *****************************
%       

        editWidth =             6;
        optionsColDelta =       15;
        rowDelta =              5;
        editWidth =             150;


sysOffsets   = commonGeom.sysOffsets;
textExtent   = commonGeom.textExtent;

%
% Find the label width as max of both labels:
%

set(textExtent, 'String', stringLabel.stringEdit);
ext = get(textExtent, 'Extent');
width(1)  = ext(3);

set(textExtent, 'String', stringLabel.stringLoc);
ext = get(textExtent, 'Extent');
width(2)  = ext(3);

labelWidth = max(width);

%
% Positions for String Criteria groupbox
%


frameHeight = ...
  commonGeom.frameTopEdgeBuffer       + ...
  commonGeom.editHeight               + ...
  commonGeom.popupHeight              + ...
  rowDelta                            + ...
  commonGeom.frameBottomEdgeBuffer;

frameWidth = ...
  editWidth+ sysOffsets.edit(3)       + ...
  labelWidth                          + ...
  optionsColDelta                     + ...
  2*commonGeom.frameSideEdgeBuffer;
  
stringCriterRelPos.groupBoxPos = [0 0 frameWidth frameHeight];

%
% Search string label
%

cyCur = frameHeight - commonGeom.frameTopEdgeBuffer - ...
        commonGeom.textHeight;
cxCur = commonGeom.frameSideEdgeBuffer;

stringCriterRelPos.ForLabel = ...
  [cxCur cyCur width(1) commonGeom.textHeight];

%
% Search string edit field
%

cxCur = cxCur + labelWidth + optionsColDelta;

stringCriterRelPos.StringEditField = ...
  [cxCur cyCur editWidth+sysOffsets.edit(3) commonGeom.editHeight];

%
% Search string location label
%

cyCur = cyCur - commonGeom.editHeight - rowDelta;

stringCriterRelPos.LocLabel = ...
  [commonGeom.frameSideEdgeBuffer cyCur width(2) commonGeom.textHeight];


%
% Search string popup
%

popupColWidth = [];
for stringEntry = stringLabel.LocationList 
	set(textExtent, 'String', stringEntry{1,1});
	ext = get(textExtent, 'Extent');
	popupColWidth = [popupColWidth ext(3)];
end


popupWidth = max(popupColWidth) + sysOffsets.popupmenu(3);
  
stringCriterRelPos.LocPopup = ...
  [cxCur cyCur popupWidth commonGeom.popupHeight];
  
  
extent = [frameWidth frameHeight];  

%******************************************************************************
% Function - Calculate positions for string criteria box & return the total ***
%  extent of all controls ([width height]).                                 ***
%                                                                           ***
% Positions are calculated relative to the lower left corner.               ***
%******************************************************************************

function [extent, searchMethodRelPos] = i_layoutSearchMethod(commonGeom,methodLabel)

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       commonGeom - Structure with standard dimensions for control objects   *
%                    and frame spacing.                                       *
%                                                                             *
%       methodLabel -  Structure containing label strings used for sizing     *                                                                 *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Output Description                                                    *
%                                                                             *
%       extent - A vector with [total width, total height] for all combined   * 
%                elements.                                                    *
%                                                                             *
%       searchMethodRelPos - Relative positions for each element assuming     *  
%                            (0,0) for starting corner.                       *
%                                                                             *
%******************************************************************************




%       
%       *****************************
%       *                           *
%       *     Layout Constants      *
%       *                           *
%       *****************************
%       

        editWidth =             6;
        optionsColDelta =       15;
        rowDelta =              5;

sysOffsets   = commonGeom.sysOffsets;
textExtent   = commonGeom.textExtent;


%
% Find the label width as max of both labels:
%

set(textExtent, 'String', methodLabel.normalButton);
ext = get(textExtent, 'Extent');
width(1)  = ext(3);

set(textExtent, 'String', methodLabel.exactButton);
ext = get(textExtent, 'Extent');
width(2)  = ext(3);

labelWidth = max(width);

%
% Positions for String Criteria groupbox
%


frameHeight = ...
  commonGeom.frameTopEdgeBuffer       + ...
  (commonGeom.radiobuttonHeight * 2)  + ...
  rowDelta                            + ...
  commonGeom.frameBottomEdgeBuffer;

frameWidth = ...
  sysOffsets.radiobutton(3)           + ...
  labelWidth                          + ...
  2*commonGeom.frameSideEdgeBuffer;
  
searchMethodRelPos.groupBoxPos = [0 0 frameWidth frameHeight];

%
% Positions for normal radio button
%

cyCur = frameHeight - commonGeom.frameTopEdgeBuffer - ...
        commonGeom.textHeight;

cxCur = commonGeom.frameSideEdgeBuffer;


searchMethodRelPos.NormalRadio = [cxCur cyCur ...
  labelWidth+sysOffsets.radiobutton(3) commonGeom.radiobuttonHeight];


%
% Positions for exact radio button
%
 
cyCur = cyCur - rowDelta - commonGeom.textHeight;

searchMethodRelPos.ExactRadio = [cxCur cyCur ...
  labelWidth+sysOffsets.radiobutton(3) commonGeom.radiobuttonHeight];

extent = [frameWidth frameHeight];



%******************************************************************************
% Function - Create string criteria box.                                    ***
%******************************************************************************

function DialogUserData = i_drawStringCrit(DialogFig, DialogUserData, startXY);


%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       startXY - The (x,y) pair for the lower left corner.                   *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************


offset = [startXY 0 0];

stringCriterRelPos = DialogUserData.stringCriterRelPos;
stringLabel = DialogUserData.stringLabel;


commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;


%
% Create String Criteria group.
%

Children.StringCriteriaGroupBox = groupbox( ...
  DialogFig, ...
  stringCriterRelPos.groupBoxPos+offset, ...
  stringLabel.stringBox, ...
  textExtent ...
);



%
% String and Label
%

Children.ForLabel = uicontrol( ...
  'Parent',             DialogFig, ...
  'Style',              'text', ...
  'String',             stringLabel.stringEdit, ...
  'Position',           stringCriterRelPos.ForLabel+offset ...
);

Children.StringEditfield = uicontrol( ...
  'Parent',             DialogFig, ...
  'BackgroundColor',    'w', ...
  'Style',              'edit', ...
  'Position',           stringCriterRelPos.StringEditField+offset ...
);

%
% Location and label
%

Children.LocLabel = uicontrol( ...
  'Parent',             DialogFig, ...
  'Style',              'text', ...
  'String',             stringLabel.stringLoc, ...
  'Position',           stringCriterRelPos.LocLabel+offset ...
);

Children.LocPopup = uicontrol( ...
  'Parent',             DialogFig, ...
  'Style',              'popupmenu', ...
  'String',             stringLabel.LocationList, ...
  'BackgroundColor',    DialogUserData.popupBackGroundColor, ...
  'Position',           stringCriterRelPos.LocPopup+offset ...
);


%
% Add the new handles to the output structure
%

DialogUserData.stringCriteria.children = Children;



%******************************************************************************
% Function - Create string criteria box.                                    ***
%******************************************************************************

function DialogUserData = i_drawSearchMethod(DialogFig, DialogUserData, startXY),


%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       startXY - The (x,y) pair for the lower left corner.                   *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************


offset = [startXY 0 0];

searchMethodRelPos = DialogUserData.searchMethodRelPos;
methodLabel = DialogUserData.methodLabel;


commonGeom = DialogUserData.commonGeom;
textExtent = commonGeom.textExtent;


%
% Create search method group.
%

Children.MethodGroupBox = groupbox( ...
  DialogFig, ...
  searchMethodRelPos.groupBoxPos+offset, ...
  methodLabel.methodBox, ...
  textExtent ...
);



%
% Radio Buttons
%



Children.NormalRadio = uicontrol( ...
  'Parent',         DialogFig, ...
  'Style',          'radiobutton', ...
  'String',         methodLabel.normalButton, ...
  'Position',       searchMethodRelPos.NormalRadio+offset, ...
  'Value',          1 ...
);


Children.ExactRadio = uicontrol( ...
  'Parent',         DialogFig, ...
  'Style',          'radiobutton', ...
  'String',         methodLabel.exactButton, ...
  'Position',       searchMethodRelPos.ExactRadio+offset ...
);


%
% Add the new handles to the output structure
%

DialogUserData.searchMethod.children = Children;





%******************************************************************************
% Function - Create the object type group box layout                        ***
%******************************************************************************


function [extent, objectTypeRelPos] = i_layoutObjectTypeBox(commonGeom,objectLabel)


%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       commonGeom - Structure with standard dimensions for control objects   *
%                    and frame spacing.                                       *
%                                                                             *
%                                                                             *
%       objectTypeNames - A cell array with the labels for each checkbox      *
%                         (labeling is column by column!!)                    *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       extent - A vector with [total width, total height] for all combined   * 
%                elements.                                                    *
%                                                                             *
%       objectTypeRelPos - Relative positions for each element assuming       *  
%                          (0,0) for starting corner.                         *
%                                                                             *
%******************************************************************************


%       
%       *****************************
%       *                           *
%       *     Layout Constants      *
%       *                           *
%       *****************************
%       

        numCols  =              6;
        optionsColDelta =       15;
        rowDelta =              5;



% Frequently needed variables:

sysOffsets   = commonGeom.sysOffsets;
textExtent   = commonGeom.textExtent;
objectTypeNames = objectLabel.objectTypeNames;


%
% Find the length of each label
%

labelWidth = [];

for k=1:length(objectTypeNames)
  set(textExtent, 'String', objectTypeNames{k} );
  ext = get(textExtent, 'Extent');
  labelWidth  = [labelWidth ext(3)];
end

numCheckBox = k;

%
% Find the number of rows and the width of each column.
% (Note: the last column may have fewer rows)
%

numRows = ceil(numCheckBox/numCols);
columnWidth = [];

for k=1:numCols
  width =       max(labelWidth((k-1)*numRows+1:k*numRows))+...
                sysOffsets.checkbox(3)                    +...
                optionsColDelta;
  columnWidth = [columnWidth width];
end


%
% Overall dimensions
%


frameWidth =    sum(columnWidth) - optionsColDelta +...
                2*commonGeom.frameSideEdgeBuffer;
                
frameHeight =   numRows * commonGeom.checkboxHeight + ...
                (numRows-1) * rowDelta              + ...
                commonGeom.frameBottomEdgeBuffer    +...
                commonGeom.frameTopEdgeBuffer;
             

%
% Groupbox Position
%

objectTypeRelPos.groupBoxPos = [0 0 frameWidth frameHeight];


%
% Matrix with checkbox positions
%

objectTypeRelPos.checkBoxesPos = [];

cxCur = commonGeom.frameSideEdgeBuffer;
cyCur = frameHeight - commonGeom.checkboxHeight - ...
        commonGeom.frameTopEdgeBuffer;

for k=1:numCheckBox
  column = ceil(k/numRows);
  row = k - (column -1)*numRows;
  position = [  cxCur + sum(columnWidth(1:column-1)) ...
                cyCur - (row-1) * (commonGeom.checkboxHeight + rowDelta) ...
                columnWidth(column)-optionsColDelta ...
                commonGeom.checkboxHeight];
  
  objectTypeRelPos.checkBoxesPos = [objectTypeRelPos.checkBoxesPos; ...
                                    position];
end                  
  
extent = [frameWidth frameHeight];  

        
%******************************************************************************
% Function - Create the object type group box.                              ***
%******************************************************************************

      
function DialogUserData = i_drawObjectTypeBox(DialogFig, DialogUserData, startXY);

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       startXY - The (x,y) pair for the lower left corner.                   *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************

objectTypeRelPos = DialogUserData.objectTypeRelPos;
objectLabel = DialogUserData.objectLabel;
textExtent = DialogUserData.commonGeom.textExtent;

offset = [startXY 0 0];

%
%  Create the group Box
%

Children.objectGroupbox = groupbox( ...
  DialogFig, ...
  objectTypeRelPos.groupBoxPos+offset, ...
  objectLabel.objectBox, ...
  textExtent ...
);


%
%  Create the check boxes
%

Children.ObjectTypeCheckboxes = [];

for k=1:length(objectTypeRelPos.checkBoxesPos)
  handle = uicontrol( ...
  'Parent',             DialogFig, ...
  'Style',              'checkbox', ...
  'String',             objectLabel.objectTypeNames{k}, ...
  'Position',           objectTypeRelPos.checkBoxesPos(k,:)+offset, ...
  'Value',              1 ...
  );
  
  Children.ObjectTypeCheckboxes = [Children.ObjectTypeCheckboxes handle];

end

%
% Add the new handles to the output structure
%

DialogUserData.objectType.children = Children;




%******************************************************************************
% Function - Add the results output page to the figure.                     ***
%******************************************************************************
function DialogUserData = i_addResults(DialogFig, DialogUserData);

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************


%
% Resize the figure
%

DialogFigPosition = get(DialogFig,'Position');
NewDialogFigPosition = DialogFigPosition + [0  -DialogUserData.resultExtent(2)-...
  DialogUserData.commonGeom.figBottomEdgeBuffer   0   DialogUserData.resultExtent(2)+...
  DialogUserData.commonGeom.figBottomEdgeBuffer];

DialogUserData.totExtent = NewDialogFigPosition(3:4);
%  Save userData before resizing
set(DialogFig,'UserData',DialogUserData);

% Temporarily disable the resize management function
set(DialogFig,'ResizeFcn','');

set(DialogFig,'Position',NewDialogFigPosition);

%
% Move all active elements
%

allActiveElementsHandle = get(DialogFig,'child');
positionCell = get(allActiveElementsHandle,'Position');
positionMatrix = cat(1,positionCell{:});

positionMatrix(:,2) = positionMatrix(:,2) + DialogUserData.resultExtent(2)+...
  DialogUserData.commonGeom.figBottomEdgeBuffer;
newPositionCell = num2cell(positionMatrix,2);

set(allActiveElementsHandle,{'Position'},newPositionCell);

%
% Draw the results display
%

DialogUserData = i_drawResults(DialogFig, DialogUserData, DialogUserData.ResultsOffset);

set(DialogFig,'Resize','on'); 
set(DialogFig,'ResizeFcn','sf(''Private'',''sfsrch'',''ReSize'',gcbf)');


%******************************************************************************
% Function - Implement mutual exclusive radio button behavior.              ***
% Assumption: The radio buttons are initialize correctly (1 or 0 are on).   ***
%******************************************************************************
function  i_RadioBehavior(DialogFig, DialogUserData),

pressedRadio = gcbo;

if(pressedRadio == DialogUserData.searchMethod.children.NormalRadio)
  if get(DialogUserData.searchMethod.children.ExactRadio,'Value')
    set(DialogUserData.searchMethod.children.ExactRadio,'Value',0);
    set(DialogUserData.searchMethod.children.NormalRadio,'Value',1);
  end
else
  if get(DialogUserData.searchMethod.children.NormalRadio,'Value')
    set(DialogUserData.searchMethod.children.NormalRadio,'Value',0);
    set(DialogUserData.searchMethod.children.ExactRadio,'Value',1);
  end
end



%******************************************************************************
% Function - Manage callbacks for system buttons.                           ***
%******************************************************************************
function [DialogUserData, bModified] = i_ManageSystemButtons(DialogFig, DialogUserData, Action),

bModified = 0;

switch(Action),

  case 'Help',
    sfhelp;

  case 'Clear',
    DialogUserData = i_manage_clear_button(DialogFig, DialogUserData);
    bModified = 1;

  case 'Refine',
    DialogUserData = i_runRefine(DialogFig, DialogUserData);
    bModified = 1;

  case 'Search',
    DialogUserData = i_runSearch(DialogFig, DialogUserData);
    bModified = 1;

  case 'Close',
    delete(DialogFig);

  otherwise,
    error('Invalid action');

end


%******************************************************************************
% Function - Install callbacks for system buttons.                          ***
%******************************************************************************
function i_InstallSystemButtonCallbacks(DialogFig, DialogUserData),
set(DialogUserData.sysButtons.children.Buttons, ...
  {'Callback'},        {'sf(''Private'',''sfsrch'',''SystemButtons'', ''Close'', gcbf)',...
  								'sf(''Private'',''sfsrch'',''SystemButtons'', ''Help'', gcbf)', ...
                        'sf(''Private'',''sfsrch'',''SystemButtons'', ''Clear'', gcbf)', ...
                        'sf(''Private'',''sfsrch'',''SystemButtons'', ''Refine'', gcbf)', ...
                        'sf(''Private'',''sfsrch'',''SystemButtons'', ''Search'', gcbf)'}' );



%******************************************************************************
% Function - Install callbacks for system buttons.                          ***
%******************************************************************************
function i_InstallStringCallbacks(DialogFig, DialogUserData),

set(DialogUserData.searchMethod.children.NormalRadio, ...
  'Callback',  'sf(''Private'',''sfsrch'',''StringPage'', ''Radio'', gcbf)');

set(DialogUserData.searchMethod.children.ExactRadio, ...
  'Callback',  'sf(''Private'',''sfsrch'',''StringPage'', ''Radio'', gcbf)');

set(DialogUserData.stringCriteria.children.LocPopup, ...
  'Callback',  'sf(''Private'',''sfsrch'',''StringPage'', ''StringLoc'', gcbf)');





%******************************************************************************
% Function - Remove the results output page to the figure.                  ***
%******************************************************************************
function DialogUserData = i_removeResults(DialogFig, DialogUserData);

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************



set(DialogFig,'Resize','off');
%
% Resize the figure
%

DialogFigPosition = get(DialogFig,'Position');
NewDialogFigPosition = DialogFigPosition + [0  +DialogUserData.resultExtent(2)+...
  DialogUserData.commonGeom.figBottomEdgeBuffer 0  -DialogUserData.resultExtent(2)-...
  DialogUserData.commonGeom.figBottomEdgeBuffer];
DialogUserData.totExtent = NewDialogFigPosition(3:4);


%
% Remove the results display
%


resultCell   = struct2cell(DialogUserData.results.children);
ChildrenVector = [resultCell{:}];
delete(ChildrenVector);


DialogUserData.results.children = [];

%
% Move all active elements
%

allActiveElementsHandle = get(DialogFig,'child');
positionCell = get(allActiveElementsHandle,'Position');
positionMatrix = cat(1,positionCell{:});

positionMatrix(:,2) = positionMatrix(:,2) - DialogUserData.resultExtent(2)-...
  DialogUserData.commonGeom.figBottomEdgeBuffer;
newPositionCell = num2cell(positionMatrix,2);

set(allActiveElementsHandle,{'Position'},newPositionCell);

                                            
%  Save userData before resizing
set(DialogFig,'UserData',DialogUserData);

% Temporarily disable the resize management function
set(DialogFig,'ResizeFcn','');

set(DialogFig,'Position',NewDialogFigPosition)

% Re-enable the resize management function
set(DialogFig,'ResizeFcn','sf(''Private'',''sfsrch'',''ReSize'',gcbf)');


%******************************************************************************
% Function - Build the search structure.                                    ***
%******************************************************************************

function SearchCriteria = i_buildSearchStructure(DialogFig, DialogUserData);

typeCell = get(DialogUserData.objectType.children.ObjectTypeCheckboxes,'Value');
    
SearchCriteria.type = [typeCell{:}];
  

%
% Get search string and location from the string criteria groupbox
%

SearchCriteria.string = ...
  get(DialogUserData.stringCriteria.children.StringEditfield,'String');

SearchCriteria.stringLocation = ...
  get(DialogUserData.stringCriteria.children.LocPopup,'Value');


SearchCriteria.searchMethod = 1 + ...
  get(DialogUserData.searchMethod.children.ExactRadio,'Value');
  
% set caseInsensitive to false since there is no checkbox for it
SearchCriteria.caseInsensitive = 0;


%******************************************************************************
% Function - Generate a search description from the search structure.       ***
%******************************************************************************

function outputString = i_buildDescriptionString(SearchCriteria,DialogUserData)


%********************************************************
%
%       Input Descrition:
%
%       SearchCriteria should have the following fields:
%
%               
%          SearchCriteria.type     1x6 vector where each element
%                                       has 1 := selected, 0 := not Selected
%                                        
%          SearchCriteria.string   Search string
%
%          SearchCriteria.stringLocation   Location to match string
%                                               1 := Any, 2 := Label,
%                                               3 := Name, 3 := Description
%
%          SearchCriteria.searchMethod     1 := Normal (reg expr.)
%                                               2 := Exact word match
%
%********************************************************

%
%  Describe the object types
%

typeNames = DialogUserData.objectLabel.objectTypeNames;

numType = sum(SearchCriteria.type);

if(numType > 5)
  typeString = 'All objects';
elseif(numType > 2)
  typeString = 'Selected objects';
elseif(numType > 1)
  selectedIndex = find( SearchCriteria.type ==1);
  typeString = [typeNames{selectedIndex(1)} ', ' typeNames{selectedIndex(2)}];
elseif(numType < 1)
  outputString = 'NO OBJECT TYPES SELECTED';
  return;  
else
  selectedIndex = find( SearchCriteria.type ==1);
  typeString = typeNames{selectedIndex(1)};
end


%
%  Describe the search string and location
%

quote = '''';
stringLocations = DialogUserData.stringLabel.LocationList(2:end);

if( strcmp(SearchCriteria.string,''))
  stringSearchString = '';
else
  if ( SearchCriteria.stringLocation == 1)
    stringSearchString = [' with ' quote SearchCriteria.string quote];
  else
    stringSearchString = [' with ' ...
      stringLocations{SearchCriteria.stringLocation -1} ' ' quote SearchCriteria.string quote];
  end
end



outputString = [typeString stringSearchString  '.'];
  


%******************************************************************************
% Function - Run a search and update the display.                           ***
%******************************************************************************
function DialogUserData = i_runSearch(DialogFig, DialogUserData);

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************


%
% Determine the search structure
%

SearchCriteria = i_buildSearchStructure(DialogFig, DialogUserData);

%
% Genererate a search desription string
%

outputString = i_buildDescriptionString(SearchCriteria,DialogUserData);


%
% Find the search space if it doesn't already exist
%


chartSpace = DialogUserData.chartIds;
searchSpace = [];

if isempty(chartSpace), 
	if ~sf('get', DialogUserData.machine, '.deleted'),
		searchSpace = sf('ObjectsIn', DialogUserData.machine); 
	end;
end;

for chart = chartSpace(:)'
  space = sf('related',chart);
  searchSpace = [searchSpace space];
end

%searchSpace = sf('ObjectsIn',DialogUserData.searchRoot);



%
% Display the output string in the search history popup
%

set(DialogUserData.summaryDisplay.children.HistoryPopup,'Value',1,'String',outputString);

%
% Expand the window, if not already done
%

if(isempty(DialogUserData.results.children))
  DialogUserData = i_addResults(DialogFig, DialogUserData);
end


%
% Run the search and obtain Stateflow handles
%

resultHandles = fnd_runsearch(SearchCriteria,searchSpace);

%
% Display the number of matches in the summary field
%

if isempty(resultHandles)
  noMatchString = char({'';'';'               NO MATCHES FOUND'});
  set(DialogUserData.summaryDisplay.children.MatchDisplay,'String','0');
  set(DialogUserData.results.children.OutputList,'String' , ...
          noMatchString);

  %
  % Disable searching and refining
  %

  set(DialogUserData.sysButtons.children.Buttons, ...
  {'Enable'},        {'on';  ...     %  close
                      'on';  ...     %  Help
                      'on';  ...     %  Clear
                      'off';  ...    %  Refine
                      'on';  });  	 %  Find

  DialogUserData.searchResults = [];
  return;
end


numMatches = length(resultHandles);
matchText = sprintf('%d',numMatches);
set(DialogUserData.summaryDisplay.children.MatchDisplay,'String',matchText);

% Update the systems button

if (numMatches > 1)
  set(DialogUserData.sysButtons.children.Buttons, ...
  {'Enable'},        {'on';  ...     %  Close
                      'on';  ...     %  Help
                      'on';  ...     %  Clear
                      'on';  ...     %  Refine
                      'on';  });  	 %  Find
else
  set(DialogUserData.sysButtons.children.Buttons, ...
  {'Enable'},        {'on';  ...     %  Close
                      'on';  ...     %  Help
                      'on';  ...     %  Clear
                      'off';  ...    %  Refine
                      'on';  });  	 %  Find
end


%
% Find the object properties, and build the display cell array
%

[DialogUserData.displayCellArray, DialogUserData.sortedHandles] = fnd_objprop(resultHandles);

%
% Format and display the ouput results:
%

DialogUserData.resultsStringMatrix = frmcell(DialogUserData.displayCellArray, ...
  [8 20 9 20 15 15],[1 1 1 0 0 0]);

Izeros = find(~DialogUserData.resultsStringMatrix);
DialogUserData.resultsStringMatrix(Izeros) = ' ';
set(DialogUserData.results.children.OutputList,'Value',1,'String' , ...
          DialogUserData.resultsStringMatrix);


%
% Put sorting info into userData, clearing any existing data
%

DialogUserData.searchResults = [];
DialogUserData.searchResults{1} = resultHandles;
DialogUserData.searchDescription = [];
DialogUserData.searchDescription{1} = outputString;
DialogUserData.sortOrdering = [];
DialogUserData.sortOrdering{1} = 1:numMatches;
DialogUserData.sortOrdering{6} = [];
DialogUserData.currentButton = 1;

set_context_edit_status(DialogFig, DialogUserData);


%******************************************************************************
% Function - Run a search refinement and update the display.                ***
%******************************************************************************
function DialogUserData = i_runRefine(DialogFig, DialogUserData);

%******************************************************************************
%                                                                             *
%       Input Description                                                     *
%                                                                             *
%                                                                             *
%       DialogFig - Handle to the figure where the objects should be drawn.   *
%                                                                             *
%                                                                             *
%       DialogUserData - User data for the figure which contains label and    *
%                        relative position information for the controls to    *
%                        be created.                                          *
%                                                                             *
%       ------------------------------------------------------------------    *
%                                                                             *
%       Ouput Description                                                     *
%                                                                             *
%       DialogUserData - User data for the figure which contains handles      *
%                        for the newly created objects.                       *
%                                                                             *
%******************************************************************************


%
% Determine the search structure
%

SearchCriteria = i_buildSearchStructure(DialogFig, DialogUserData);

%
% Genererate a search desription string
%

outputString = i_buildDescriptionString(SearchCriteria,DialogUserData);


%
% Find the search space 
%

searchSpace = DialogUserData.searchResults{end};

%
% Append the new output string to the end of the search history popup
% and enable the uicontrol.
%

currentHistoryString = get(DialogUserData.summaryDisplay.children.HistoryPopup, ...
  'String');
currentHistoryValue = get(DialogUserData.summaryDisplay.children.HistoryPopup,'Value');

newString = strrows(currentHistoryString,['&  ' outputString]);
 
set(DialogUserData.summaryDisplay.children.HistoryPopup,'String',newString, ...
    'Value', currentHistoryValue+1,'Enable','on');

%
% Expand the window, if not already done
%

if(isempty(DialogUserData.results.children))
  DialogUserData = i_addResults(DialogFig, DialogUserData);
end


%
% Run the search and obtain SF handles
%

resultHandles = fnd_runsearch(SearchCriteria,searchSpace);

%
% Display the number of matches in the summary field
%

if isempty(resultHandles)
  noMatchString = char({'';'';'               NO MATCHES FOUND'});
  set(DialogUserData.summaryDisplay.children.MatchDisplay,'String','0');
  set(DialogUserData.results.children.OutputList,'Value',1,'String' , ...
          noMatchString);

  %
  % Disable searching and refining
  %

  set(DialogUserData.sysButtons.children.Buttons, ...
  {'Enable'},        {'on';  ...     %  Close
                      'on';  ...     %  Help
                      'on';  ...     %  Clear
                      'off';  ...    %  Refine
                      'on';  });  	 %  Find

  DialogUserData.searchResults{end+1} = [];
  return;
end


numMatches = length(resultHandles);
matchText = sprintf('%d',numMatches);
set(DialogUserData.summaryDisplay.children.MatchDisplay,'String',matchText);

% Update the systems button

if (numMatches > 1)
  set(DialogUserData.sysButtons.children.Buttons, ...
  {'Enable'},        {'on';  ...     %  Close
                      'on';  ...     %  Help
                      'on';  ...     %  Clear
                      'on';  ...     %  Refine
                      'on';  });  	 %  Find
else
  set(DialogUserData.sysButtons.children.Buttons, ...
  {'Enable'},        {'on';  ...     %  Close
                      'on';  ...     %  Help
                      'on';  ...     %  Clear
                      'off';  ...    %  Refine
                      'on';  });  	 %  Find
end


%
% Find the object properties, and build the display cell array
%

[DialogUserData.displayCellArray, DialogUserData.sortedHandles] = fnd_objprop(resultHandles); 

%
% Format and display the ouput results:
%

DialogUserData.resultsStringMatrix = frmcell(DialogUserData.displayCellArray, ...
  [8 20 9 20 15 15],[1 1 1 0 0 0]);

Izeros = find(~DialogUserData.resultsStringMatrix);
DialogUserData.resultsStringMatrix(Izeros) = ' ';
set(DialogUserData.results.children.OutputList,'Value',1,'String' , ...
          DialogUserData.resultsStringMatrix);


%
% Put sorting info into userData.
%

DialogUserData.searchResults{end+1} = resultHandles;
DialogUserData.searchDescription{end+1} = outputString;
DialogUserData.sortOrdering = [];
DialogUserData.sortOrdering{1} = 1:numMatches;
DialogUserData.sortOrdering{6} = [];
DialogUserData.currentButton = 1;

set_context_edit_status(DialogFig, DialogUserData);

%%%%%%%%%%%%%% START OF DEAD CODE %%%%%%%%%%%%%%%%%%%
% Dead Code WBA, EMM 6/7/99
%
%%******************************************************************************
%% Function - Manage reference enable button.                                ***
%%******************************************************************************
%function [DialogUserData, bModified] = i_ManageReference(DialogFig, DialogUserData),
%
%
%currentRefMode = get(DialogUserData.reference.children.referenceListbox,'Enable');         % Mode for reference listbox
%desiredRefMode = get(DialogUserData.reference.children.enableCheckbox,'Value');          % checkbox value
%
%bModified = 0;
%
%%
% Check if listbox mode should be changed 
%
%
%if(currentRefMode ~= desiredRefMode)
%  
%  if(desiredRefMode)
%    set(DialogUserData.reference.children.referenceListbox,'Enable','on')
%  else
%    set(DialogUserData.reference.children.referenceListbox,'Enable','off')
%  end
%  
%end
%
%
%
%%******************************************************************************
%% Function - Generate listbox strings and user data.                        ***
%%******************************************************************************
%function DialogUserData = i_syncReferenceGroup(DialogFig, DialogUserData),
%
%%  Find and format the  referenceable objects from Stateflow.
%
%[referenceLabel,userDataStructure] = i_findReferenceNames(DialogFig, DialogUserData);  
%
%set(DialogUserData.reference.children.referenceListbox,'String',referenceLabel);
%DialogUserData.referenceStruct = userDataStructure;
%
%
%%******************************************************************************
%% Function - Build the reference listbox strings and user data.             ***
%%******************************************************************************
%function [display, userdata] = i_findReferenceNames(DialogFig, DialogUserData),
%
%
%%
%% Find the search space if it doesn't already exist
%%
%
%chartSpace = DialogUserData.chartIds;
%searchSpace = [];
%
%for chart = chartSpace(:)'
%  space = sf('related',chart);
%  searchSpace = [searchSpace space];
%end
%
%
%
%
%%
%% Get all state handles
%%
%
%stateHandles = sf('get',searchSpace,'state.id');
%numStates = length(stateHandles);
%
%%
%% Get all event handles
%%
%
%eventHandles = sf('get',searchSpace,'event.id');
%numEvents = length(eventHandles);
%
%%
%% Get all data handles
%%
%
%dataHandles = sf('get',searchSpace,'data.id');
%numData = length(dataHandles);
%
%%
%% Build user data
%%
%
%userdata.refer = [stateHandles' dataHandles' eventHandles';...
%         ones(1,numStates) 2*ones(1,numData) 3*ones(1,numEvents)];
%
%%
%% Build the display string
%
%
%flshRight = {'(state)','(data)','(event)'};
%
%displayWidth = 30;
%separSpace = 3;
%
%[rw,cl] = size(char(flshRight));
%rightDisplayWidth = cl;
%
%maxNameChars = displayWidth - (rightDisplayWidth + separSpace);
%
%%
%% Entries for states
%
%
%%stateNames = sf('get',stateHandles,'.name');
%stateNames = '';
%for state=stateHandles(:)'
%        chart = sf('get',state,'.chart');
%        if isempty(stateNames)
%                stateNames = sf('FullNameOf',state,chart,'\');
%        else
%                stateNames = strrows(stateNames,sf('FullNameOf',state,chart,'\'));
%        end
%end
%[rows,strWidth] = size(stateNames);
%
%if(strWidth>maxNameChars)
%  newStateNames = stateNames(:,1:maxNameChars);
%  strWidth=maxNameChars;
%else
%  newStateNames = stateNames;
%end
%
%numAddSpaces = displayWidth - length(flshRight{1}) - strWidth;
%spaces = '                                                 ';
%
%middleString = char(ones(rows,1)*spaces(1:numAddSpaces));
%
%endString = char(ones(rows,1)*flshRight{1});
%
%display = [newStateNames middleString endString];
%
%%
%% Entries for data
%%
%
%dataNames = sf('get',dataHandles,'.name');
%[rows,strWidth] = size(dataNames);
%if(strWidth>maxNameChars)
%  newDataNames = dataNames(:,1:maxNameChars);
%  strWidth=maxNameChars;
%else
%  newDataNames = dataNames;
%end
%numAddSpaces = displayWidth - length(flshRight{2}) - strWidth;
%spaces = '                                                 ';
%middleString = char(ones(rows,1)*spaces(1:numAddSpaces));
%endString = char(ones(rows,1)*flshRight{2});
%i = find(display==0);
%display(i)=setstr(ones(size(i,1),1)*32);
%display = [display;newDataNames middleString endString];
%
%%
%% Entries for events
%%
%
%eventNames = sf('get',eventHandles,'.name');
%[rows,strWidth] = size(eventNames);
%if(strWidth>maxNameChars)
%  newEventNames = eventNames(:,1:maxNameChars);
%  strWidth=maxNameChars;
%else
%  newEventNames = eventNames;
%end
%numAddSpaces = displayWidth - length(flshRight{3}) - strWidth;
%middleString = char(ones(rows,1)*spaces(1:numAddSpaces));
%endString = char(ones(rows,1)*flshRight{3});
%
%display = [display;newEventNames middleString endString];
%
%%%%%%%%%%%%%% END OF DEAD CODE %%%%%%%%%%%%%%%%%%%



%
% Format the names to fit and add description
%

%******************************************************************************
% Function - Manage the resizing callback.                                  ***
%******************************************************************************
function [DialogUserData, bModified] = i_manage_resize(DialogFig, DialogUserData),

%
%  Get the new position
%

adjustedPosition = get(DialogFig,'Position');

%
%  Find the change in height and Width
%

deltaHeight = adjustedPosition(4) - DialogUserData.totExtent(2);
deltaWidth = adjustedPosition(3) - DialogUserData.totExtent(1);

%
% If neither height or width changed, return
%

if (isequal(round([deltaHeight deltaWidth]),[0 0]))
  bModified = 0;
  return;
end


%
%  Make sure that resize will still allow the listbox to fit on the screen
%

listboxHeight = DialogUserData.resultCtrlRelPos.resultListbox(4);
if (deltaHeight < -listboxHeight)
  newPosition = [adjustedPosition(1:2) DialogUserData.totExtent(1:2)];
  noResize = 1;
else
  noResize = 0;
  DialogUserData.totExtent(2) = adjustedPosition(4);     %  Put new size information in DialogUserData
  newPosition = [adjustedPosition(1:2) DialogUserData.totExtent(1) adjustedPosition(4)];
end



%
%  Set the figure position so only height has changed
%

set(DialogFig,'UserData',DialogUserData);       %  Save userData before resizing
set(DialogFig,'ResizeFcn',' ');
set(DialogFig,'Position',newPosition);
set(DialogFig,'ResizeFcn','sf(''Private'',''sfsrch'',''ReSize'',gcbf)');


%
%  Check for a change in height
%

% WJA - 12/30/97 added an extra or expr at the end to filter out sperious
% resize callbacks.
if (round(deltaHeight)==0) | noResize | isempty(DialogUserData.results.children),
  bModified = 0;
  return;
end

bModified = 1;

%
% Move all active elements
%

allActiveElementsHandle = get(DialogFig,'child');
moveableObjs = filter_menu_handles(allActiveElementsHandle);
positionCell = get(moveableObjs,'Position');
positionMatrix = cat(1,positionCell{:});

positionMatrix(:,2) = positionMatrix(:,2) + deltaHeight;
newPositionCell = num2cell(positionMatrix,2);

set(moveableObjs,{'Position'},newPositionCell);

%
%  Resize the results listbox
%

adjPos = get(DialogUserData.results.children.OutputList, 'Position');
set(DialogUserData.results.children.OutputList ,'Position', ...
  adjPos +[0 -deltaHeight 0 deltaHeight]);


%
%  Recalculate the results positions
%

rsltPos = DialogUserData.resultCtrlRelPos;
rsltPos.line = rsltPos.line + [0 deltaHeight 0 0];
rsltPos.titleButtons = rsltPos.titleButtons + ones(6,1)*[0 deltaHeight 0 0];
rsltPos.resultListbox = rsltPos.resultListbox  + [0 0 0 deltaHeight];
DialogUserData.resultCtrlRelPos = rsltPos;
DialogUserData.resultExtent(2) = DialogUserData.resultExtent(2) +  deltaHeight;




%******************************************************************************
% Function - Manage the callback for History popup.                         ***
%******************************************************************************
function [DialogUserData, bModified] = i_ManageSummaryDisplay(...
      DialogFig, DialogUserData),

histString = get(DialogUserData.summaryDisplay.children.HistoryPopup, 'String');
szeHist = size(histString);

srchIndex = get(DialogUserData.summaryDisplay.children.HistoryPopup,'Value');

% Check if the selection is the currently active search

if srchIndex == szeHist(1),
  bModified = 0; 
  return;
end

bModified = 1;

% Clear the trailing refinements

DialogUserData.searchResults = DialogUserData.searchResults(1:srchIndex);
DialogUserData.searchDescription = DialogUserData.searchDescription(1:srchIndex);

%
% Remove trailing lines from history popup
%

currHistoryString = get(DialogUserData.summaryDisplay.children.HistoryPopup,'String');
newString = currHistoryString(1:srchIndex,:);
set(DialogUserData.summaryDisplay.children.HistoryPopup,'String',newString);


%
% Get the cached results
%

resultHandles = DialogUserData.searchResults{srchIndex};

numMatches = length(resultHandles);
matchText = sprintf('%d',numMatches);
set(DialogUserData.summaryDisplay.children.MatchDisplay,'String',matchText);

% Update the systems button

  set(DialogUserData.sysButtons.children.Buttons, ...
  {'Enable'},        {'on';  ...     %  Close
                      'on';  ...     %  Help
                      'on';  ...     %  Clear
                      'on';  ...     %  Refine
                      'on';  });  	 %  Find

%
% Disable the history popup, if needed.
%

if srchIndex==1,
  set(DialogUserData.summaryDisplay.children.HistoryPopup ,'Enable','off');
end



%
% Find the object properties, and build the display cell array
%

[DialogUserData.displayCellArray, DialogUserData.sortedHandles] = fnd_objprop(resultHandles);

%
% Format and display the ouput results:
%

DialogUserData.resultsStringMatrix = frmcell(DialogUserData.displayCellArray, ...
  [8 20 9 20 15 15],[1 1 1 0 0 0]);

Izeros = find(~DialogUserData.resultsStringMatrix);
DialogUserData.resultsStringMatrix(Izeros) = ' ';
set(DialogUserData.results.children.OutputList,'Value',1,'String' , ...
          DialogUserData.resultsStringMatrix);

% Update context menu status.
set_context_edit_status(DialogFig, DialogUserData);


%
% Put sorting info into userData.
%

DialogUserData.sortOrdering = [];
DialogUserData.sortOrdering{1} = 1:numMatches;
DialogUserData.sortOrdering{6} = [];
DialogUserData.currentButton = 1;


%******************************************************************************
% Function - Manage callbacks for SolverPage.                               ***
%******************************************************************************
function [DialogUserData, bModified] = i_ManageStringPage(...
  DialogFig, DialogUserData, Action),

bModified = 0;
switch(Action),

  case 'Radio',
     i_RadioBehavior(DialogFig, DialogUserData);
    
  case 'StringLoc',
     [DialogUserData, bModified] = i_sync_object_type(DialogFig, DialogUserData);   
    
  otherwise,
    error('Invalid action');

end


%******************************************************************************
% Function - Manage callbacks for SolverPage.                               ***
%******************************************************************************
function DialogUserData = i_manage_clear_button(DialogFig, DialogUserData),   

%
% Resize figure if needed
%

if ~isempty(DialogUserData.results.children)
  DialogUserData = i_removeResults(DialogFig, DialogUserData);
end

%
% Set number of matches to 0 and clear history string
%

set(DialogUserData.summaryDisplay.children.MatchDisplay,'String','0');
set(DialogUserData.summaryDisplay.children.HistoryPopup,'String',' ','Value',1);

%
% Remove contents of "look for" string
%

set(DialogUserData.stringCriteria.children.StringEditfield,'String','');

%
% Set the string location to Any
%

set(DialogUserData.stringCriteria.children.LocPopup,'Value',1);

%
% Update the object types if needed
%

if ~isempty(DialogUserData.objectType.children)
        set(DialogUserData.objectType.children.ObjectTypeCheckboxes, ...
          'Value',1,'Enable','on')
end

%
% Clear the search information from DialogUserData
%

DialogUserData.searchResults = [];
DialogUserData.searchDescription = [];
DialogUserData.sortOrdering = [];
DialogUserData.currentButton = 1;


%
% Make all object types active
%

if ~isempty(DialogUserData.objectType.children)  % If advanced page used
  set(DialogUserData.objectType.children.ObjectTypeCheckboxes,{'Value'},{1});
end
    

%
% Update the system buttons to original state
%

  set(DialogUserData.sysButtons.children.Buttons, ...
  {'Enable'},        {'on';  ...     %  Close
                      'on';  ...     %  Help
                      'off';  ...    %  Clear
                      'off';  ...    %  Refine
                      'on';  });  	 %  Find
                
%
% Disable the history popup
%

set(DialogUserData.summaryDisplay.children.HistoryPopup ,'Enable','off')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_valid_handles(sfHandles),
%
% Selects valid handles in the input vector, sfHandles.  Valid implies 
% that you are a Stateflow state, junction, or transition handle AND you're 
% not on the clipboard.
%
	GET = sf('method','get');
	stateISA = sf(GET, 'default', 'state.isa');
	junctionISA = sf(GET, 'default', 'junction.isa');
	transitionISA = sf(GET, 'default', 'transition.isa');  
   
	validHandles = sf('find', sfHandles, '.isa', [stateISA;junctionISA;transitionISA]);
   
	if ~isempty(validHandles),
		validHandles = filter_deleted_ids(validHandles);
		charts = [];
		for obj=validHandles,
		  charts = [charts sf(GET, obj, '.chart')];
		end

		charts = unique(charts);
		for i=1:length(charts),
			chart = charts(i);
			ids = sf('find', validHandles, '.chart', chart);
			chartFig = sf('get',chart,'chart.hg.figure');
			if chartFig>0 & ishandle(chartFig)
				sf('Select', chart, validHandles);
			end
		end;
	end;
   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  manage_context_menu
%
%  Callback management for listbox context menu

function  [UserData, bModified] = manage_context_menu(fig, UserData, action),

  bModified = 0;

  if isempty(UserData.searchResults)
    return;
  end

  %
  % Find the Stateflow handles for the currently selected listbox entries
  %

  if(UserData.searchResults{end})  % Any valid results    ??

    selectedValues =  get(UserData.results.children.OutputList,'Value');
	if(UserData.currentButton>0)
    	displaySorting = (UserData.sortOrdering{UserData.currentButton});
	else
    	displaySorting = (UserData.sortOrdering{-UserData.currentButton}(end:-1:1));
	end
    sfHandles =   UserData.sortedHandles(displaySorting(selectedValues));
  else
    return;
  end


  %
  % Switch based on the action
  %


  switch(action),
  	case 'Explore',
  		hndl  = sfHandles(1);	% Apply to just the first selected object
  		sfexplr;
  		sf('Explr','VIEW',hndl);
  		
  	case 'Edit',
  		hndl  = sfHandles(1);	% Apply to just the first selected object
		open_chart_window(hndl);
  		
	case 'Properties',
		dlg_open(sfHandles);

	otherwise,
	error('Bad action type');
  end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  open_chart_window
%
%  Function to find the relavent explorer object.  This is the parent of data
%  events, transitions, and junctions or the same object that was passed in 
%  for machines, charts and machines.

function  open_chart_window(sfId),

	GET = sf('method','get');
	chartISA = sf(GET, 'default', 'chart.isa');
	machineISA = sf(GET, 'default', 'machine.isa');  

	objIsa =  sf(GET, sfId, '.isa');
	
	if( objIsa==chartISA)
		chartId = sfId;
	elseif( objIsa==machineISA)
		return;
	else
		chartId = sf('get',sfId,'.chart');
	end

	sf('Open',sfId);
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  set_context_edit_status
%
%  Function to check if the entry in the results listbox has edit enabled in
%  the context menu.

function  set_context_edit_status(fig, UserData),

  if isempty(UserData.searchResults)
    return;
  end

	GET = sf('method','get');
	dataISA = sf(GET, 'default', 'data.isa');
	eventISA = sf(GET, 'default', 'event.isa');  
	targetISA = sf(GET, 'default', 'target.isa');  
	machineISA = sf(GET, 'default', 'machine.isa');  
	stateISA = sf(GET, 'default', 'state.isa');  
	transitionISA = sf(GET, 'default', 'transition.isa');  
	junctionISA = sf(GET, 'default', 'junction.isa');  

  %
  % Find the Stateflow handles for the currently selected listbox entries
  %

  if(UserData.searchResults{end})  % Any valid results    ??

    selectedValues =  get(UserData.results.children.OutputList,'Value');
	if(UserData.currentButton>0)
    	displaySorting = (UserData.sortOrdering{UserData.currentButton});
	else
    	displaySorting = (UserData.sortOrdering{-UserData.currentButton}(end:-1:1));
	end
    sfHandles =   UserData.sortedHandles(displaySorting(selectedValues));
  else
    return;
  end

	objIsa = sf(GET,sfHandles(1),'.isa');
	
	typeField = UserData.displayCellArray{1}(displaySorting(selectedValues(1)),:);
	labelField = UserData.displayCellArray{2}(displaySorting(selectedValues(1)),:);
	
	switch(objIsa),
		case dataISA, 
			ctxtName = labelField;
			set(UserData.results.children.ctxEdit,'Enable','off');
		case eventISA, 
			ctxtName = labelField;
			set(UserData.results.children.ctxEdit,'Enable','off');
		case targetISA, 
			ctxtName = labelField;
			set(UserData.results.children.ctxEdit,'Enable','off');
		case machineISA, 
			ctxtName = labelField;
			set(UserData.results.children.ctxEdit,'Enable','off');
		case stateISA, 
			ctxtName = labelField;
			if length(ctxtName)>15,  ctxtName = [ctxtName(1:15) '...']; end
			set(UserData.results.children.ctxEdit,'Enable','on');
		case junctionISA, 
			ctxtName = typeField;
			set(UserData.results.children.ctxEdit,'Enable','on');
		case transitionISA, 
			ctxtName = labelField;
			if length(ctxtName)>15,  ctxtName = [ctxtName(1:15) '...']; end
			set(UserData.results.children.ctxEdit,'Enable','on');
	end
	
	set(UserData.results.children.ctxEdit,'Label',['Edit ' ctxtName]);
	set(UserData.results.children.ctxExplore,'Label',['Explore ' ctxtName]);







%******************************************************************************
% Function - Manage callback for output listbox.                            ***
%
%       Related Input Fields
%
%       .sortOrdering:                  Cell array with sorted indexes for each button
%       .currentButton:                 The button whose sort index is currently active
%
%******************************************************************************
function  [DialogUserData, bModified] = i_manage_results(...
  DialogFig, DialogUserData);

  bModified = 0;

  if isempty(DialogUserData.searchResults)
    return;
  end

  %
  % Find the Stateflow handles for the currently selected listbox entries
  %

  if(DialogUserData.searchResults{end})  % Any valid results    ??

    selectedValues =  get(DialogUserData.results.children.OutputList,'Value');
	if(DialogUserData.currentButton>0)
    	displaySorting = (DialogUserData.sortOrdering{DialogUserData.currentButton});
	else
    	displaySorting = (DialogUserData.sortOrdering{-DialogUserData.currentButton}(end:-1:1));
	end
    sfHandles =   DialogUserData.sortedHandles(displaySorting(selectedValues));
  else
    return;
  end

  %
  % Toggle behavior based on mouse action:
  %

  mouseActionType = get(DialogFig,'SelectionType');

  switch(mouseActionType),  
    case 'normal',		
    	select_valid_handles(sfHandles);
    	set_context_edit_status(DialogFig, DialogUserData);
    case 'extended',	
    	select_valid_handles(sfHandles);
    	set_context_edit_status(DialogFig, DialogUserData);
    case 'alternate',	
    	select_valid_handles(sfHandles);
    	set_context_edit_status(DialogFig, DialogUserData);
    case 'open',		dlg_open(sfHandles);
    otherwise,			error('Invalid mouse action type');
  end




%******************************************************************************
% Function - Manage callbacks for sorting buttons.                          ***
%
%       Related Input Fields
%
%       .sortOrdering:                  Cell array with sorted indexes for each button
%       .currentButton:                 The button whose sort index is currently active
%       .displayCellArray:      The cell array of output.
%       .resultsStringMatrix    The output display matrix with its initial ordering
%
%******************************************************************************
function  [DialogUserData, bModified] = i_manage_sort_buttons(...
  DialogFig, DialogUserData, buttonNumber);

  if(abs(DialogUserData.currentButton) == buttonNumber)  % Button is already active

  		% Toggle the ordering
		rsltMat = get(DialogUserData.results.children.OutputList,'String');
		set(DialogUserData.results.children.OutputList,'String',rsltMat(end:-1:1,:));
    	
    	DialogUserData.currentButton = -DialogUserData.currentButton;
    	bModified = 1;
        return;
  end

  if isempty(DialogUserData.sortOrdering{buttonNumber}) % Has search already been performed?
    
        sortMat = lower(DialogUserData.displayCellArray{buttonNumber});
        dimsSort = size(sortMat);
        wdth = min([20 dimsSort(2)]);
        [notused,ordering] = sortrows(sortMat(:,1:wdth));

        DialogUserData.sortOrdering{buttonNumber} = ordering;

        %
        % Update results display
        %

        set(DialogUserData.results.children.OutputList,'String' , ...
          DialogUserData.resultsStringMatrix(ordering,:));

        DialogUserData.currentButton = buttonNumber;
  else

        ordering = DialogUserData.sortOrdering{buttonNumber};

        %
        % Update results display
        %

        set(DialogUserData.results.children.OutputList,'String' , ...
          DialogUserData.resultsStringMatrix(ordering,:));

        DialogUserData.currentButton = buttonNumber;
  
  end
	
  set_context_edit_status(DialogFig, DialogUserData);

  bModified = 1;
  
%******************************************************************************
% Function - Sync valid object types.                                       ***
%                                                                           ***
% This function should be part of the string location callback              ***
% and whenever the advanced page is first displayed.                        ***
%                                                                           ***
%******************************************************************************
function [DialogUserData, bModified] = i_sync_object_type(DialogFig, DialogUserData),   

bModified = 0;
stringLocValue = get(DialogUserData.stringCriteria.children.LocPopup,'Value');
validTypes = DialogUserData.stringLocMap{stringLocValue};

for k=1:length(validTypes)   % Step through object types
  if(validTypes(k))  % Is current object valid
    if( strcmp(get(DialogUserData.objectType.children.ObjectTypeCheckboxes(k), ... 
      'Enable'),'off'))
        % Restore cached value and enable
        set(DialogUserData.objectType.children.ObjectTypeCheckboxes(k), ...
          'Value',DialogUserData.objectTypeCache(k),'Enable','on')
    end
    
  else
    if( strcmp(get(DialogUserData.objectType.children.ObjectTypeCheckboxes(k), ...
        'Enable'),'on'))
      bModified = 1;
      % Cache the current value
      DialogUserData.objectTypeCache(k) = get( ...
        DialogUserData.objectType.children.ObjectTypeCheckboxes(k),'Value');
      % Set new value to 0 and disable
        set(DialogUserData.objectType.children.ObjectTypeCheckboxes(k), ...
          'Value',0,'Enable','off')
    end
  end
end


function watchon
	if ~isempty(get(0,'Children'))
	    fig = gcbf;
        if isequal(get(fig,'tag'), tag_l)
		   set(fig,'Pointer','watch');
        end;
	end
   
function watchoff( fig )
	if ~isnan(fig) & isequal(get(fig, 'tag'), tag_l)
		set(fig,'Pointer','arrow');
	end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  filter_menu_handles
%
%  Function to remove handles relating to context menu items from a list 
%  of handles so the resulting objects all have a position property.

function outHandles = filter_menu_handles(inHandles),

	menHands = findobj(inHandles,'Type','uimenu');
	ctxHands = findobj(inHandles,'Type','uicontextmenu');
	
	removeObjs = [menHands(:);ctxHands(:)];
	removeIds = zeros(size(inHandles));
	
	for obj = removeObjs'
		removeIds = removeIds | inHandles==obj;
	end
	
	outHandles = inHandles(~removeIds);

 %-------------------------------------------------------------------------
 function tag = tag_l
 %
 % return finder tool tag
 %
        tag = 'FINDER';


