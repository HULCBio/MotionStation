function varargout = logcfg(varargin)
%LOGCFG Simulink external mode data logging configuration dialog.
%   LOGCFG creates and manages the external mode data logging configuration
%   dialog.  The first argument is always an "action" string.
%
%   See also LOGCTRLPANEL, LOGPANEL.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.5 $

try
    action = lower(varargin{1});
    
    switch(action),

    case 'create',
        %
	% Create the dialog.
	%
	bd = varargin{2};
	
	[dlgFig, dlgUserData] = i_CreateDlg(bd);
	
	set(dlgFig, ...
	    'UserData', dlgUserData, ...
	    'Visible',  'on');
	
	if nargout == 1,
	  varargout{1} = dlgFig;
        end

    case 'reshow',
        dlgFig      = varargin{2};
	dlgUserData = get(dlgFig, 'UserData');
	bd          = dlgUserData.bd;

	set(dlgFig, 'Name', i_DialogName(bd));

        if strcmp(get(dlgFig, 'Visible'), 'on'),
            %
            % It exists and its opened.  Pop it to the foreground.
            %
            figure(dlgFig);
        else
            %
            % It exists, but its closed.  Re-sync it with the diagram
            % and open it.
            %
            dlgUserData.revertInfo = i_SyncDlg(bd, dlgUserData, 1);
            i_AdjustDlgState(bd, dlgUserData);

            set(dlgFig, ...
                'Visible',      'on', ...
                'UserData',     dlgUserData);
        end

    case 'selectionlist',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_SelectionListCB(dlgFig, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'selectall',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_SelectAllCheckboxCB(dlgFig, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'clearall',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_ClearAllButtonCB(dlgFig, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'onoffradio',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        hPressed    = gcbo;
        i_OnOffRadioCB(dlgFig, dlgUserData, hPressed);
	i_EnableApply(dlgFig, dlgUserData);

    case 'trigsigbutton',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_TrigSigButtonCB(dlgFig, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'gotoblockbutton',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_GotoBlockButtonCB(dlgFig, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'sourcepopup',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_TrigSourcePopupCB(dlgFig, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);
	
    case 'trigapply'
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
	i_EnableApply(dlgFig, dlgUserData);

    case 'trigarmed',
        %
        % Message from simulink.
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;

        i_AdjustDlgState(bd, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'connected',
        %
        % Message from simulink.
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;

        i_AdjustDlgState(bd, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'unconnected',
        %
        % Message from simulink.
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;

        i_AdjustDlgState(bd, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'trigunarmed',
        %
        % Message from simulink.
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;

        i_AdjustDlgState(bd, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'revert',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_RevertCB(dlgFig, dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);

    case 'apply',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        dum = i_ApplyCB(dlgFig, dlgUserData, 0);

    case 'hgclosereqfcn',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_CloseReqCB(dlgFig, dlgUserData);

    case 'hgdeletefcn'
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;

        %
        % Notify the parent that we have disappeared.  Note if this is
        % being called due to the block diagram being deleted, then the
        % bd is already invalid at this point.
        %
        if ishandle(bd),
            parent = get_param(bd, 'ExtModeLogCtrlPanelDlg');

            if ishandle(parent),
                logctrlpanel('subfigdeleted', parent, 'config');
            else
                warning(['Parent control panel not found.  Orphan ' ... 
                         'configuration dialog.']);
            end
        end

    case 'portedit',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        
        i_CtrlValuesFromSigSelectStr(dlgUserData);
	i_EnableApply(dlgFig, dlgUserData);
      
    case 'help'
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');

	%
	% Load the help page for this dialog
	%
	set(dlgFig, 'Pointer', 'watch');
	helpview([docroot,'/mapfiles/rtw_ug.map'], 'rtw_sigs_and_trigs');
	set(dlgFig, 'Pointer', 'arrow');
    

    case 'changename'
      bd     = varargin{2};
      dlgFig = varargin{3};
      
      set(dlgFig, 'Name', i_DialogName(bd));
      
    otherwise,
        i_Assert('Unrecognized action in main entry point.');

    end %action switch

catch
    if nargout == 1,
        if ishandle(dlgFig),
            delete(dlgFig);
        end
        varargout = {-1};
    end
    errordlg(lasterr,'Error in external mode configuration dialog','modal');
end


% Function =====================================================================
% Mimicks a c assertion by throwing an error if asserts are active.

function i_Assert(str)

error(['M Assert: ' str]);


% Function =====================================================================
% Create the external mode logging control panel.

function [dlgFig, dlgUserData] = i_CreateDlg(bd)

%
% Create constants based on current computer & cache in user data.
%
dlgUserData.fontsize = get(0, 'FactoryUicontrolFontSize');
dlgUserData.fontname = get(0, 'FactoryUicontrolFontName');
dlgUserData.computer = computer;
dlgUserData.bd       = bd;

%
% Create an empty figure & invisible text object for text sizing.
%
figColor      = get(0, 'FactoryUiControlBackGroundColor');
hgclosereqfcn = 'logcfg(''hgclosereqfcn'', gcbf)';
hgdeletefcn   = 'logcfg(''hgdeletefcn'', gcbf)';

dlgFig = figure( ...
    'Visible',                              'off', ...
    'DefaultUicontrolHorizontalAlign',      'left', ...
    'DefaultUicontrolFontname',             dlgUserData.fontname, ...
    'DefaultUicontrolFontsize',             dlgUserData.fontsize, ...
    'DefaultUicontrolUnits',                'character', ...
    'Units',                                'character', ...
    'HandleVisibility',                     'off', ...
    'Colormap',                             [], ...
    'Color',                                figColor, ...
    'Name',                                 i_DialogName(bd), ...
    'IntegerHandle',                        'off', ...
    'Renderer',                             'painters', ...
    'DoubleBuffer',                         'on', ...
    'CloseRequestFcn',                      hgclosereqfcn, ...
    'DeleteFcn',                            hgdeletefcn, ...
    'MenuBar',                              'none', ...
    'NumberTitle',                          'off', ...
    'Resize',                               'off');

dlgUserData.textExtent = uicontrol( ...
    'Parent',     dlgFig, ...
    'Visible',    'off', ...
    'Style',      'text', ...
    'Units',      'character');

%
% Create geometry constants.
%
sysOffsets = sluigeom('character');
geom       = i_CreateGeom(sysOffsets, dlgUserData);


%
% Calculate figure position.
%
wFig = ...
    geom.sideEdgeBuffer                                  + ...
    max([geom.wSignalSelectionGroup geom.wTriggerGroup]) + ...
    geom.sideEdgeBuffer;

hFig = ...
    geom.figTopEdgeBuffer       + ...
    geom.hSignalSelectionGroup  + ...
    geom.frameDelta             + ...
    geom.hTriggerGroup          + ...
    geom.frameDelta             + ...
    geom.hSysButton             + ...
    geom.figBottomEdgeBuffer;

figPos = get(dlgFig,'Position');
figPos([3 4]) = [wFig hFig];
figPos = figpos(figPos, 'character');
set(dlgFig, 'Position', figPos);

%
% Calculate the position of each control.
%
ctrlPos = i_CtrlPos(geom,figPos);

%
% Create the controls.
%
dlgUserData.children = i_CreateCtrls(dlgFig, ctrlPos, dlgUserData, geom);

%
% Save the pieces of geometry that need to persist into the user data.
%
dlgUserData.sigList = geom.sigList;

%
% Synchronize settings with model.
%
dlgUserData.revertInfo = i_SyncDlg(bd, dlgUserData, 1);
i_AdjustDlgState(bd, dlgUserData);

%
% Install callbacks
%
i_InstallCallbacks(bd, dlgUserData);

%
% Cache remaining info in dlgUserData.
%


% Function =====================================================================
% Get the name for the dialog box.

function figName = i_DialogName(bd)

figName = [get_param(bd, 'Name') ': ', xlate('External Signal & Triggering')];


% Function =====================================================================
% Create the geomerty constants for construction of the dialog.  Note that
% these are the minimun size requirements.  Some controls may be stretched
% to improve appearance (e.g., line the right edges up).

function geom = i_CreateGeom(sysOffsets, dlgUserData)

textExtent = dlgUserData.textExtent;

%
% NOTE: These values should be consistent with those in
%       logpanel.m.
%
geom.hText                 = 1   + sysOffsets.text(4);
geom.hEdit                 = 1   + sysOffsets.edit(4);
geom.hButton               = 1   + sysOffsets.pushbutton(4);
geom.hCheckbox             = 1.1 + sysOffsets.checkbox(4);
geom.hRadioButton          = 1   + sysOffsets.radiobutton(4);
geom.hPopupMenu            = 1   + sysOffsets.popupmenu(4);
geom.wSysButton            = 7.5 + sysOffsets.pushbutton(3);
geom.hSysButton            = 1.1 + sysOffsets.pushbutton(4);
geom.sysButtonDelta        = 1.2;
geom.figTopEdgeBuffer      = 1;
geom.figBottomEdgeBuffer   = 0.5;
geom.frameTopEdgeBuffer    = (geom.hText/1.8);
geom.frameBottomEdgeBuffer = 1.0;
geom.sideEdgeBuffer        = 1.5;
geom.frameDelta            = (geom.hText/1.3);
geom.rowSpace              = 0.5;

%
% Set computer specific values.
%
geom.computer.dividingLineStyle     = 'pushbutton';
geom.computer.fixedFontName         = 'FixedWidth';
geom.computer.fixedFontSize         = 9;
switch(dlgUserData.computer),
case 'PCWIN',
    geom.computer.popupBackGroundColor  = 'w';
    geom.computer.dividingLineThickness = 0.65;
    geom.hListbox = 1;
otherwise,  % X
    geom.computer.popupBackGroundColor  = ...
        get(0, 'FactoryUicontrolBackgroundColor');
    geom.computer.dividingLineThickness = 0.9;
    geom.hListbox = 2;
end

%
% Signal selection groupbox.
%


%
% ...Take care of the selection list box.  It uses a fixed width font!
%
fixedFontName = geom.computer.fixedFontName;
fixedFontSize = geom.computer.fixedFontSize;
set(textExtent, 'FontName', fixedFontName, 'FontSize', fixedFontSize);

blockNameCalString  = 'gain block blah blah blah';
pathCalString       = 'vdp/blah/blahdy/blah/moo/moo/meow/bark/dkdbb/ddd';
listSepStr          = '  ';
headerStr           = 'X  ';

geom.sigList.nameStartIdx = length(headerStr) + 1;
geom.sigList.maxNameWidth = length(blockNameCalString);

geom.sigList.pathStartIdx = ...
    geom.sigList.nameStartIdx + ...
    geom.sigList.maxNameWidth + ...
    length(listSepStr);

tmp = [headerStr blockNameCalString listSepStr pathCalString];
set(textExtent, 'String', tmp);
ext = get(textExtent, 'Extent');

geom.sigList.lengthCalStr = length(tmp);

geom.wSelectionList = ext(3) + sysOffsets.listbox(3);
geom.hSelectionList = (ext(4) * 13) + sysOffsets.listbox(4);

%
% ...Now we're back into using the factory font so character units
%    work just fine.
%
set(textExtent, ...
    'FontName', dlgUserData.fontname, ...
    'FontSize', dlgUserData.fontsize);

geom.wOnOffRadio = length('off_') + sysOffsets.radiobutton(3);

geom.wTriggerSourceButton = ...
    length('Trigger Signal_') + sysOffsets.pushbutton(3);

geom.wGotoBlockButton   = geom.wTriggerSourceButton;
geom.wSelectAllCheckbox = geom.wTriggerSourceButton;
geom.wClearAllButton    = geom.wTriggerSourceButton;

geom.listBoxDelta = 1;

geom.listCtrlWidth = max(geom.wGotoBlockButton, geom.wOnOffRadio);

geom.wSignalSelectionGroup = ...
    geom.sideEdgeBuffer   +...
    geom.wSelectionList   + ...
    geom.listBoxDelta     + ...
    geom.listCtrlWidth    + ...
    geom.sideEdgeBuffer;

geom.hSignalSelectionGroup = ...
    geom.frameTopEdgeBuffer + ...
    geom.hText              + ...
    geom.hSelectionList     + ...
    geom.frameBottomEdgeBuffer;

%
% Trigger groupbox.
%

geom.wCol1Label    = length('Duration:')  + sysOffsets.text(3);
geom.wSourcePopup  = length('manual___')  + sysOffsets.popupmenu(3);
geom.wDurationEdit = length('1000000000_') + sysOffsets.edit(3);
geom.colDelta      = 2;
geom.wCol2Label    = length('Delay:_')   + sysOffsets.text(3);
geom.wModePopup    = geom.wSourcePopup;
geom.wDelayEdit    = geom.wDurationEdit;

geom.wArmWhenConnectCheckbox = ...
    length('Arm when connect to target__') + sysOffsets.checkbox(3);

geom.wSignalLabel  = length('Trigger Signal:') + sysOffsets.text(3);
geom.wStaticSignal = length(pathCalString) + sysOffsets.listbox(3);
geom.hStaticSignal = geom.hListbox + sysOffsets.listbox(4);

geom.wDirectionLabel = length('Direction:') + sysOffsets.text(3);
geom.wDirectionPopup = length('falling__')  + sysOffsets.popupmenu(3);

geom.wLevelLabel = length('Level:') + sysOffsets.text(3);
geom.wLevelEdit  = geom.wDurationEdit;

geom.wHoldOffLabel = length('Hold-off:') + sysOffsets.text(3);
geom.wHoldOffEdit  = geom.wDurationEdit;

geom.directionDelta = 2;

sect1WidthA = ...
    geom.wCol1Label    + ...
    geom.wSourcePopup  + ...
    geom.colDelta      + ...
    geom.wCol2Label    + ...
    geom.wModePopup;   

sect1WidthB = ...
    geom.wCol1Label     + ...
    geom.wDurationEdit  + ...
    geom.colDelta       + ...
    geom.wCol2Label     + ...
    geom.wDelayEdit;

sect1Width = max([sect1WidthA sect1WidthB]);

sect2WidthA = ...
    geom.wDirectionLabel  + ...
    geom.wDirectionPopup  + ...
    geom.directionDelta   + ...
    geom.wLevelLabel      + ...
    geom.wLevelEdit       + ...
    geom.directionDelta   + ...
    geom.wHoldOffLabel    + ...
    geom.wHoldOffEdit;

sect2Width = max([geom.wStaticSignal sect2WidthA geom.wArmWhenConnectCheckbox]);

geom.wTriggerGroup = ...
    geom.sideEdgeBuffer                  + ...
    sect1Width                           + ...
    geom.sideEdgeBuffer                  + ...
    geom.computer.dividingLineThickness  + ...
    geom.sideEdgeBuffer                  + ...
    sect2Width                           + ...
    geom.sideEdgeBuffer;

sect1Height = ...
    geom.hPopupMenu + ...
    geom.rowSpace   + ...
    geom.hEdit      + ...
    geom.rowSpace   + ...
    geom.hCheckbox;

sect2Height = ...
    geom.hText         + ...
    geom.hStaticSignal + ...
    geom.rowSpace      + ...
    geom.hPopupMenu;

height = max([sect1Height sect2Height]);

geom.hTriggerGroup = ...
    geom.frameTopEdgeBuffer + ...
    height                  + ...
    geom.frameBottomEdgeBuffer;

geom.hDividingLine      = geom.hTriggerGroup * 0.9;
geom.hDividingLineDelta = (geom.hTriggerGroup - geom.hDividingLine) / 2;

geom.wPortLabel    = length('Port:')   + sysOffsets.text(3);
geom.wPortEdit     = length('1000000') + sysOffsets.edit(3);
geom.portDelta     = 2;
geom.wElementLabel = length('Element:') + sysOffsets.text(3);
geom.wElementEdit  = geom.wPortEdit;

%
% Make sure that both groups are the same width
%
maxGroupWidth = max([geom.wSignalSelectionGroup geom.wTriggerGroup]);
geom.wSignalSelectionGroup = maxGroupWidth;
geom.wTriggerGroup         = maxGroupWidth;


% Function =====================================================================
% Calculate the position for every control.

function ctrlPos = i_CtrlPos(geom, figPos)

%
% Signal Selection group box.
%

%
% ...frame
%

frameLeft = geom.sideEdgeBuffer;

frameTop    = figPos(4) - geom.figTopEdgeBuffer;
frameBottom = frameTop - geom.hSignalSelectionGroup;

ctrlPos.signalSelectionGroup = ...
    [frameLeft frameBottom ...
     geom.wSignalSelectionGroup geom.hSignalSelectionGroup];

%
% ...signal list box titles
%
cxCur = frameLeft + geom.sideEdgeBuffer;
cyCur = frameTop - geom.frameTopEdgeBuffer - geom.hText;

ctrlPos.listTitle = [cxCur cyCur geom.wSelectionList geom.hText];

%
% ...signal list box
%
cxCur = frameLeft + geom.sideEdgeBuffer;
cyCur = cyCur - geom.hSelectionList;
listBottom = cyCur;

ctrlPos.selectionList = [cxCur cyCur geom.wSelectionList geom.hSelectionList];

%
% Select/clear all
%
cxCur = cxCur + geom.wSelectionList + geom.listBoxDelta;
cyCur = cyCur + geom.hSelectionList - geom.hCheckbox;

ctrlPos.selectAllCheckbox = [cxCur cyCur geom.listCtrlWidth geom.hCheckbox];

cyCur = cyCur - geom.rowSpace - geom.hCheckbox;
ctrlPos.clearAllButton = [cxCur cyCur geom.listCtrlWidth geom.hButton];

cyCur = cyCur - geom.hRadioButton - geom.rowSpace;
ctrlPos.onRadio = [cxCur cyCur geom.listCtrlWidth geom.hRadioButton];

cyCur = cyCur - geom.hRadioButton - geom.rowSpace;
ctrlPos.offRadio = [cxCur cyCur geom.listCtrlWidth geom.hRadioButton];

%
% ...on/off, trigger source and goto block buttons (from bottom up)
%
cyCur = listBottom;
ctrlPos.gotoBlockButton = [cxCur cyCur geom.listCtrlWidth geom.hButton];

cyCur = cyCur + geom.hButton + geom.rowSpace;
ctrlPos.triggerSourceButton = [cxCur cyCur geom.listCtrlWidth geom.hButton];

%
% Trigger group box.
%

%
% ...frame
%
frameTop    = frameBottom - geom.frameDelta;
frameBottom = frameTop - geom.hTriggerGroup;
frameRight  = frameLeft + geom.wTriggerGroup;

ctrlPos.triggerGroup = ...
    [frameLeft frameBottom ...
     geom.wTriggerGroup geom.hTriggerGroup];

width1 = max([geom.wSourcePopup  geom.wDurationEdit]);
width2 = max([geom.wModePopup geom.wDelayEdit]);

%
% ...Sources label and popup
%
cxCur = frameLeft + geom.sideEdgeBuffer;
cyCur = frameTop - geom.frameTopEdgeBuffer - geom.hPopupMenu;

ctrlPos.sourceLabel = [cxCur cyCur geom.wCol1Label geom.hText];
cxCur = cxCur + geom.wCol1Label;
ctrlPos.sourcePopup = [cxCur cyCur width1 geom.hPopupMenu];

%
% ...Mode label and popup
%
cxCur = cxCur + width1 + geom.colDelta;

ctrlPos.modeLabel = [cxCur cyCur geom.wCol2Label geom.hText];
cxCur = cxCur + geom.wCol2Label;
ctrlPos.modePopup = [cxCur cyCur width2 geom.hPopupMenu];

%
% ...Duration label and edit.
%
cxCur = frameLeft + geom.sideEdgeBuffer;
cyCur = cyCur - geom.rowSpace - geom.hPopupMenu;

ctrlPos.durationLabel = [cxCur cyCur geom.wCol1Label geom.hText];
cxCur = cxCur + geom.wCol1Label;
ctrlPos.durationEdit = [cxCur cyCur width1 geom.hEdit];

%
% ...Delay label and edit
%
cxCur = cxCur + width1 + geom.colDelta;

ctrlPos.delayLabel = [cxCur cyCur geom.wCol2Label geom.hText];
cxCur = cxCur + geom.wCol2Label;
ctrlPos.delayEdit = [cxCur cyCur width2 geom.hEdit];

delayEditRight = cxCur + width2;

%
% ...Arm when connect checkbox.
%
cxCur = frameLeft + geom.sideEdgeBuffer;
cyCur = cyCur - geom.rowSpace - geom.hPopupMenu;
ctrlPos.armWhenConnectCheckbox = ...
    [cxCur cyCur geom.wArmWhenConnectCheckbox geom.hCheckbox];

%
% ... Dividing line.
%
cyCur = frameBottom + geom.hDividingLineDelta;
cxCur = delayEditRight + geom.sideEdgeBuffer;

ctrlPos.dividingLine = ...
    [cxCur cyCur geom.computer.dividingLineThickness geom.hDividingLine];

%
% ... Signal label & static trigger signal listbox display.
%
cxCur  = cxCur + geom.computer.dividingLineThickness + geom.sideEdgeBuffer;
cyCur  = frameTop - geom.frameTopEdgeBuffer - geom.hText;
cxCol1 = cxCur;

ctrlPos.signalLabel = [cxCur cyCur geom.wSignalLabel geom.hText];

cyCur = cyCur - geom.hStaticSignal;
width = (frameRight - geom.sideEdgeBuffer) - cxCur;
ctrlPos.staticSignal = [cxCur cyCur width geom.hStaticSignal];

%
% ... Direction, level and hold-off.
%
totSpace = ...
    geom.wDirectionLabel + ...
    geom.wDirectionPopup + ...
    geom.directionDelta  + ... 
    geom.wLevelLabel     + ...
    geom.wLevelEdit      + ...
    geom.directionDelta  + ...
    geom.wHoldOffLabel   + ...
    geom.wHoldOffEdit;

wDiff = width - totSpace;
if (wDiff > 0),
    geom.directionDelta = geom.directionDelta + (wDiff/2);
end

cxCur = cxCol1;
cyCur = cyCur - geom.rowSpace - geom.hPopupMenu;
ctrlPos.directionLabel = [cxCur cyCur geom.wDirectionLabel geom.hText];

cxCur = cxCur + geom.wDirectionLabel;
ctrlPos.directionPopup = [cxCur cyCur geom.wDirectionPopup geom.hPopupMenu];

cxCur = cxCur + geom.wDirectionPopup + geom.directionDelta;
ctrlPos.levelLabel = [cxCur cyCur geom.wLevelLabel geom.hText];

cxCur = cxCur + geom.wLevelLabel;
ctrlPos.levelEdit = [cxCur cyCur geom.wLevelEdit geom.hEdit];

cxCur = cxCur + geom.wLevelEdit + geom.directionDelta;
ctrlPos.holdOffLabel = [cxCur cyCur geom.wHoldOffLabel geom.hText];

cxCur = cxCur + geom.wHoldOffLabel;
ctrlPos.holdOffEdit = [cxCur cyCur geom.wHoldOffEdit geom.hEdit];

%
% Port and element (left to right)
%
cxCur = (frameRight - geom.sideEdgeBuffer) - geom.wElementEdit;
cyCur = frameTop - geom.frameTopEdgeBuffer - geom.hText;
ctrlPos.elementEdit = [cxCur cyCur geom.wElementEdit geom.hEdit];

cxCur = cxCur - geom.wElementLabel;
ctrlPos.elementLabel = [cxCur cyCur geom.wElementLabel geom.hText];

cxCur = cxCur - geom.portDelta - geom.wPortEdit;
ctrlPos.portEdit = [cxCur cyCur geom.wPortEdit geom.hEdit];

cxCur = cxCur - geom.wPortLabel;
ctrlPos.portLabel = [cxCur cyCur geom.wPortLabel geom.hText];

%
% System buttons.
%
cyCur = frameBottom - geom.frameDelta - geom.hSysButton;

cxCur = (figPos(3) - geom.sideEdgeBuffer) - ...
        ((4*geom.wSysButton) + (3*geom.sysButtonDelta));

ctrlPos.revert = [cxCur cyCur geom.wSysButton geom.hSysButton];

cxCur = cxCur + geom.wSysButton + geom.sysButtonDelta;
ctrlPos.help = [cxCur cyCur geom.wSysButton geom.hSysButton];

cxCur = cxCur + geom.wSysButton + geom.sysButtonDelta;
ctrlPos.apply = [cxCur cyCur geom.wSysButton geom.hSysButton];

cxCur = cxCur + geom.wSysButton + geom.sysButtonDelta;
ctrlPos.close = [cxCur cyCur geom.wSysButton geom.hSysButton];


% Function =====================================================================
% Create the uicontrols in the specified locations.

function children = i_CreateCtrls(dlgFig, ctrlPos, dlgUserData, geom)

textExtent = dlgUserData.textExtent;

%
% Selection groupbox.
%
children.signalSelectionGroup = groupbox(...
    dlgFig, ...
    ctrlPos.signalSelectionGroup, ...
    ' Signal selection', ...
    textExtent);

string = char(ones(1,geom.sigList.lengthCalStr) * 32);

insertStr = xlate('Block');
strStart  = geom.sigList.nameStartIdx + 1;
strEnd    = strStart + (length(insertStr) - 1);
string(strStart:strEnd) = insertStr;

insertStr = xlate('Path');
strStart  = geom.sigList.pathStartIdx;
strEnd    = strStart + (length(insertStr) - 1);
string(strStart:strEnd) = insertStr;

children.listTitle = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             string, ...
    'Position',           ctrlPos.listTitle, ...
    'Fontname',           geom.computer.fixedFontName, ...
    'Fontsize',           geom.computer.fixedFontSize);

children.selectionList = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'listbox', ...
    'String',             ' ', ...
    'Fontname',           geom.computer.fixedFontName, ...
    'Fontsize',           geom.computer.fixedFontSize, ...
    'Position',           ctrlPos.selectionList, ...
    'BackgroundColor',    'w', ...
    'Max',                2, ...
    'Value',              []);

children.selectAllCheckbox = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Select all', ...
    'Style',              'checkbox', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.selectAllCheckbox);

children.clearAllButton = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Clear All', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.clearAllButton);

children.onRadio = uicontrol( ...
    'Parent',         dlgFig, ...
    'Style',          'radiobutton', ...
    'String',         'on', ...
    'Position',       ctrlPos.onRadio);

children.offRadio = uicontrol( ...
    'Parent',         dlgFig, ...
    'Style',          'radiobutton', ...
    'String',         'off', ...
    'Position',       ctrlPos.offRadio);

children.triggerSourceButton = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Trigger Signal', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.triggerSourceButton);

children.gotoBlockButton = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Go To Block', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.gotoBlockButton);

%
% Trigger group box.
%
children.triggerGroup = groupbox(...
    dlgFig, ...
    ctrlPos.triggerGroup, ...
    ' Trigger', ...
    textExtent);

children.sourceLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Source:', ...
    'Position',           ctrlPos.sourceLabel);

string = {'manual'; 'signal'};
children.sourcePopup = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'popupmenu', ...
    'String',             string, ...
    'BackgroundColor',    geom.computer.popupBackGroundColor, ...
    'Position',           ctrlPos.sourcePopup);

children.modeLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Mode:', ...
    'Position',           ctrlPos.modeLabel);
    
string = {'one-shot'; 'normal'};
children.modePopup = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'popupmenu', ...
    'String',             string, ...
    'BackgroundColor',    geom.computer.popupBackGroundColor, ...
    'Position',           ctrlPos.modePopup);

children.durationLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Duration:', ...
    'Position',           ctrlPos.durationLabel);

children.durationEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.durationEdit, ...
    'BackGroundColor',    'w');

children.delayLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Delay:', ...
    'Position',           ctrlPos.delayLabel);

children.delayEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.delayEdit, ...
    'BackGroundColor',    'w');

children.armWhenConnectCheckbox = uicontrol(...
    'Parent',       dlgFig, ...
    'Style',        'checkbox', ...
    'String',       'Arm when connect to target', ...
    'Position',     ctrlPos.armWhenConnectCheckbox);

children.dividingLine = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              geom.computer.dividingLineStyle, ...
    'Enable',             'inactive', ...
    'Position',           ctrlPos.dividingLine);

children.signalLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Trigger signal:', ...
    'Position',           ctrlPos.signalLabel);

children.staticSignal = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'listbox', ...
    'String',             ' ', ...
    'Position',           ctrlPos.staticSignal, ...
    'Max',                2, ...
    'Value',              [], ...
    'Enable',             'inactive');

children.portLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Port:', ...
    'Position',           ctrlPos.portLabel);

children.portEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.portEdit, ...
    'BackGroundColor',    'w');

children.elementLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Element:', ...
    'Position',           ctrlPos.elementLabel);

children.elementEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.elementEdit, ...
    'BackGroundColor',    'w');

children.directionLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Direction:', ...
    'Position',           ctrlPos.directionLabel);

string = {'rising';'falling';'either'};
children.directionPopup = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'popupmenu', ...
    'String',             string, ...
    'BackgroundColor',    geom.computer.popupBackGroundColor, ...
    'Position',           ctrlPos.directionPopup);

children.levelLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Level:', ...
    'Position',           ctrlPos.levelLabel);

children.levelEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.levelEdit, ...
    'BackGroundColor',    'w');

children.holdOffLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Hold-off:', ...
    'Position',           ctrlPos.holdOffLabel);

children.holdOffEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.holdOffEdit, ...
    'BackGroundColor',    'w');

%
% System buttons.
%
children.revert = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Revert', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.revert);

children.help = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Help', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.help);

children.apply = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Apply', ...
    'Horizontalalign',    'center', ...
    'Enable',             'off', ...
    'Position',           ctrlPos.apply);

children.close = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Close', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.close);


% Function =====================================================================
% Get the handles of the blocks that should appear in the signal selection
% listbox.

function blocks = i_FindUploadBlocks(bd)

%
% Find all blocks that support data uploading.
%
blocks = find_system(bd,'LookUnderMasks','all','FollowLinks','on', ...
    'AllBlocks', 'on', 'ExtModeLoggingSupported', 'on');

%
% Find all user-defined upload blocks (user-defined subystems).  They
% should appear in the list, but none of their children should (they are
% atomic).
%
userUploadBlocks = find_system(blocks, 'SearchDepth', 0, ...
    'BlockType',        'SubSystem', ...
    'SimViewingDevice', 'on');

%
% Remove their descendents from the list.
%
while ~isempty(userUploadBlocks),
    hB = userUploadBlocks(1);

    %
    % Find all descendents of this user defined block that support 
    % uploading and remove them from the block list.
    %
    hBAllUploadDescendants = ...
        find_system(hB,'LookUnderMasks','all','FollowLinks','on', ...
            'AllBlocks', 'on', 'ExtModeLoggingSupported', 'on');
    hBAllUploadDescendants(1) = []; %remove hB from child list

    blocks = setdiff(blocks, hBAllUploadDescendants)';
    
    %
    % This block, as well as any descendants that are user defined
    % have been processed.  Remove them from the userUploadBlock 
    % list.
    done = [hB
            find_system(hBAllUploadDescendants, 'SearchDepth', 0, ...
                'BlockType',        'SubSystem', ...
                'SimViewingDevice', 'on')];
    userUploadBlocks = setdiff(userUploadBlocks, done)';
end


% Function =====================================================================
% From the updated user data of the selection listbox, update the
% header string.  We need the 'on' vector and trigIdx to be up to date before
% calling this function.

function str = i_UpdateSelectionHdrStrings(str, ud, allOn)

on      = ud.on;
trigIdx = ud.trigIdx;

if length(on) ~= length(str),
    i_Assert('length mismatch in selection string and its user data flags');
end

for i=1:length(str),
    if i == trigIdx,
        str{i}(2) = 'T';
    else
        str{i}(2) = ' ';       
    end
    
    if on(i) || allOn,
        str{i}(1) = 'X';
    else
        str{i}(1) = ' ';
    end
end


% Function =====================================================================
% From a list of block handles, create string for the signal selection list box.
% Also, create the userdata for the listbox control.  It consists of 1
% block handle per line and the index of the trigger signal (-1 if not exist).

function [str, ud] = i_BlockList(blocks, dlgUserData, hTrigSig)

sigList      = dlgUserData.sigList;
nameStartIdx = sigList.nameStartIdx;
maxNameWidth = sigList.maxNameWidth;
pathStartIdx = sigList.pathStartIdx;

newLine = 10;
space   = 32;

if isempty(blocks),
    ud.blocks       = [];
    ud.on           = [];
    ud.trigIdx      = -1;
    ud.oldSelection = -1;
    str = {};
    return;
end

ud.blocks             = blocks;     %alloc
ud.on(length(blocks)) = logical(0); %alloc
ud.trigIdx            = -1;         %assume
ud.oldSelection       = -1;

str     = {};
tmpName = char(ones(1, maxNameWidth) * space);
tmpHdr  = char(ones(1,nameStartIdx-1) * 32);
for i=1:length(blocks),
    block = blocks(i);
    
    %
    % get name, strip new lines & truncate to maxNameWidth
    %
    name                  = GetBlockDisplayName(block);
    name(name == newLine) = space;
    nameLen               = length(name);
    
    if nameLen > maxNameWidth,
        tmpName(1:maxNameWidth) = name(1:maxNameWidth);
    elseif nameLen ~= maxNameWidth,
        tmpName(1:nameLen)     = name;
        tmpName(nameLen+1:end) = space;
    end

    %
    % get path and strip new lines
    %
    tmpPath                     = GetBlockDisplayPath(block);
    tmpPath(tmpPath == newLine) = space;

    %
    % Is this the trigger block?
    %
    if onoff(get_param(block, 'ExtModeLoggingTrig')),
        if (ud.trigIdx ~= -1),
            warning(['There should only be one trigger signal in the ' ...
                     'model.  See the ''ExtModeLoggingTrig'' property']);
        end 
        ud.trigIdx = i;
    end

    %
    % Set on/off values in user data (we update the string later).
    %
    if strcmp(get_param(block, 'ExtModeUploadOption'), 'log'),
        ud.on(i) = 1;
    else
        ud.on(i) = 0;
    end
    
    str{i,1}     = [tmpHdr tmpName '  ' tmpPath];
    ud.blocks(i) = block;
end

%
% Sort alphabetically.
%
[str, sortIdx] = sortrows(str);
ud.blocks      = ud.blocks(sortIdx);
ud.on          = ud.on(sortIdx);

%
% Now update the hdr entries based on the values stored in ud.on vector.
%
children    = dlgUserData.children;
allSelected = get(children.selectAllCheckbox,'value');

str = i_UpdateSelectionHdrStrings(str, ud,allSelected);


% Function =====================================================================
% Given a selection string (cell array), and index and the dlgUserData, return
% the full path string for that row of the list box.

function str = i_GetPathStr(selectionString, trigIdx, dlgUserData)

sigList      = dlgUserData.sigList;
pathStartIdx = sigList.pathStartIdx;

str = selectionString{trigIdx}(pathStartIdx:end);


% Function =====================================================================
% Return the appropriate values for the on and off radio buttons based on
% the selection in the signals listbox.  If the selection is homogenous,
% then the appropriate on/off value is selected, otherwise neither on or off
% is selected.

function [onVal, offVal] = i_OnOffVals(selectionList)

ud     = get(selectionList, 'UserData');
values = get(selectionList, 'Value');
onVal  = 0; %assume
offVal = 0; %assume

if ~isempty(values),
    lengthVal = length(values);
    sumVals   = sum(ud.on(values));
    if sumVals == 0,
        offVal = 1;
    elseif sumVals == lengthVal,
        onVal = 1;
    end
end


% Function =====================================================================
% Based on the current string in the signal selection list box, update the
% values (Not enabledness) of any controls that depend on the list box
% string (e.g., static text version of the trigger signal).

function i_CtrlValuesFromSigSelectStr(dlgUserData)

children      = dlgUserData.children;
selectionList = children.selectionList;
staticSignal  = children.staticSignal;
bd            = dlgUserData.bd;

%
% Update static trigger signal display in the trigger groupbox.
%
ud              = get(selectionList, 'UserData');
selectionString = get(selectionList, 'String');

if ud.trigIdx == -1
    str = '';
else,
    portIdx        = [];
    block          = ud.blocks(ud.trigIdx);
    sigLabels      = get_param(block, 'InputSignalNames');
    %portStr        = lower(get_param(bd, 'ExtModeTrigPort'));
    portStr        = get(children.portEdit, 'String');

    portStr = fliplr(deblank(fliplr(deblank(portStr))));
    if ~isempty(findstr('last', portStr)),
        portIdx = length(sigLabels);
    else,
        error = 0;
        portIdx = eval(portStr, 'error = 1');
        if ~error,
            if ~isnumeric(portIdx) || ~isequal(size(portIdx), [1 1]) || ...
               (portIdx <= 0) || (portIdx > length(sigLabels)),
                portIdx = [];        
            end
        else
            portIdx = [];
        end
    end

    if ~isempty(portIdx) && ~isempty(sigLabels{portIdx}) && ...
       ~all(isspace(sigLabels{portIdx})),
        str = sigLabels{portIdx};
    else 
        % use the block path
        str = i_GetPathStr(selectionString, ud.trigIdx, dlgUserData);
    end
end
set(staticSignal, 'String', str);


% Function =====================================================================
% Based on the current selection in the signal selection list box, update the
% values (Not enabledness) of any controls that depend on the list box
% selection.(e.g., on/off buttons).

function i_CtrlValuesFromSigSelection(dlgUserData)

children      = dlgUserData.children;
selectionList = children.selectionList;
onRadio       = children.onRadio;
offRadio      = children.offRadio;

%
% Take care of on/off buttons.  If the selection is homogenous, then the
% appropriate on/off value is selected, otherwise neither on or off
% is selected.
%
[onVal, offVal] = i_OnOffVals(selectionList);
set([onRadio; offRadio], {'Value'}, {onVal;offVal});


% Function =====================================================================
% Flip the trigger source value to its opposite representation:
%   string in, value out
%   value  in, string out

function out = i_TrigSourceFlip(in)

if ischar(in),
    %
    % Convert from Simulink string (returned by get_param) to index of
    % uicontrol.
    %
    switch(in),
        case 'manual',
            out = 1;
        case 'signal',
            out = 2;
        otherwise,
            i_Assert('Unexpected trigger source string.');
    end
else,
    %
    % Convert from uicontrol index to Simulink string (appropriate for use
    % with set_param).
    %
    switch(in),
        case 1,
            out = 'manual';
        case 2,
            out = 'signal';
        otherwise,
            i_Assert('Unexpected trigger source index');
    end
end    


% Function =====================================================================
% Flip the mode value to its opposite representation:
%   string in, value out
%   value  in, string out

function out = i_TrigModeFlip(in),

if ischar(in),
    %
    % Convert from Simulink string (returned by get_param) to index of
    % uicontrol.
    %
    switch(in),
        case 'oneshot',
            out = 1;
        case 'normal',
            out = 2;
        otherwise,
            i_Assert('Unexpected trigger mode string.');
    end
else,
    %
    % Convert from uicontrol index to Simulink string (appropriate for use
    % with set_param).
    %
    switch(in),
        case 1,
            out = 'oneshot';
        case 2,
            out = 'normal';
        otherwise,
            i_Assert('Unexpected trigger mode index');
    end
end    


% Function =====================================================================
% Flip the mode value to its opposite representation:
%   string in, value out
%   value  in, string out

function out = i_TrigDirectionFlip(in),

if ischar(in),
    %
    % Convert from Simulink string (returned by get_param) to index of
    % uicontrol.
    %
    switch(in),
        case 'rising',
            out = 1;
        case 'falling',
            out = 2;
        case 'either',
            out = 3;
        otherwise,
            i_Assert('Unexpected trigger mode string.');
    end
else,
    %
    % Convert from uicontrol index to Simulink string (appropriate for use
    % with set_param).
    %
    switch(in),
        case 1,
            out = 'rising';
        case 2,
            out = 'falling';
        case 3,
            out = 'either';
        otherwise,
            i_Assert('Unexpected trigger mode index');
    end
end    


% Function =====================================================================
% Get all property values from block diagram and update the contents of the ui
% controls.  If the 3rd arg is 1, then update the revert buffers and the
% revertInfo is returned, otherwise, revertInfo is returned as {}.

function revertInfo = i_SyncDlg(bd, dlgUserData, updateRevertBuf),

children = dlgUserData.children;

revertInfo = {};

%
% Sync the select all checkbox
%
h = children.selectAllCheckbox;
logAll = onoff(get_param(bd,'ExtModeLogAll'));
setInfo = {h, 'Value',logAll};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync the listbox string & its dependencies.
%
blocks    = i_FindUploadBlocks(bd);
[str, ud] = i_BlockList(blocks, dlgUserData);

h       = children.selectionList;
setInfo = {h, 'String', str, 'UserData', ud};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end
 
%
% Sync trigger port edit.
%
str = get_param(bd, 'ExtModeTrigPort');
h   = children.portEdit;
setInfo = {h, 'String', str};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync trigger port element.
%
str = get_param(bd, 'ExtModeTrigElement');
h   = children.elementEdit;
setInfo = {h, 'String', str};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

i_CtrlValuesFromSigSelection(dlgUserData);
i_CtrlValuesFromSigSelectStr(dlgUserData);

%
% Sync trigger source popup.
%
value   = i_TrigSourceFlip(get_param(bd, 'ExtModeTrigType'));
h       = children.sourcePopup;
setInfo = {h, 'Value', value};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync mode popup.
%
value   = i_TrigModeFlip(get_param(bd, 'ExtModeTrigMode'));
h       = children.modePopup;
setInfo = {h, 'Value', value};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync duration edit.
%
duration = get_param(bd, 'ExtModeTrigDuration');
str      = sprintf('%d', duration);
h        = children.durationEdit;
setInfo  = {h, 'String', str};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end


%
% Sync delay edit.
%
delay   = get_param(bd, 'ExtModeTrigDelay');
str     = sprintf('%d', delay);
h       = children.delayEdit;
setInfo = {h, 'String', str};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync the "arm when connect to target" checkbox.
%
val     = onoff(get_param(bd, 'ExtModeArmWhenConnect'));
h       = children.armWhenConnectCheckbox;
setInfo = {h, 'Value', val};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync direction popup.
%
value   = i_TrigDirectionFlip(get_param(bd, 'ExtModeTrigDirection'));
h       = children.directionPopup;
setInfo = {h, 'Value', value};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync level edit.
%
level = get_param(bd, 'ExtModeTrigLevel');
str   = sprintf('%0.16g', level);
h     = children.levelEdit;
setInfo = {h, 'String', str};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync hold-off edit.
%
holdOff = get_param(bd, 'ExtModeTrigHoldOff');
str     = sprintf('%d', holdOff);
h       = children.holdOffEdit;
setInfo = {h, 'String', str};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end


% Function =====================================================================
% Set the enabledness of the trigger source button, the goto block button and
% the clear all button, based on the state of the signal selection listbox.

function i_AdjustSigListCtrlsState(dlgUserData)

children      = dlgUserData.children;
selectionList = children.selectionList;

handles = [
    children.triggerSourceButton;
    children.gotoBlockButton];

value = get(selectionList, 'Value');
if isempty(value),
    set(handles, 'Enable', 'off');
else,
    state = 'off'; %assume
    if length(value) == 1,
        state = 'on';
    end
    set(handles, 'Enable', state);
end


% Function =====================================================================
% Set the enabledness of the trigger signal controls based on the state of 
% the trigger source popup.

function i_AdjustTrigSigCtrlsState(dlgUserData)

children    = dlgUserData.children;
sourcePopup = children.sourcePopup;

handles = [
    children.signalLabel
    children.portLabel
    children.portEdit
    children.elementLabel
    children.elementEdit
    children.directionLabel
    children.directionPopup
    children.levelLabel
    children.levelEdit
    children.holdOffLabel
    children.holdOffEdit];

if get(sourcePopup, 'Value') == 1,  %manual
    set([handles; children.staticSignal], 'Enable', 'off');
else,
    set(handles, 'Enable', 'on');
    set(children.staticSignal, 'Enable', 'inactive');
end


% Function =====================================================================
% Adjust the enable state for the entire dialog.

function i_AdjustDlgState(bd, dlgUserData),

children = dlgUserData.children;

%
% List of handles that get toggled from on to off
%
onOffHandles = [
    children.selectAllCheckbox
    children.clearAllButton
    children.onRadio
    children.offRadio
    children.triggerSourceButton
    children.gotoBlockButton
    children.sourceLabel
    children.sourcePopup
    children.modeLabel
    children.modePopup
    children.durationLabel
    children.durationEdit
    children.delayLabel
    children.delayEdit
    children.armWhenConnectCheckbox
    children.signalLabel
    children.staticSignal
    children.portLabel
    children.portEdit
    children.elementLabel
    children.elementEdit
    children.directionLabel
    children.directionPopup
    children.levelLabel
    children.levelEdit
    children.holdOffLabel
    children.holdOffEdit
    children.revert
    children.apply
    children.listTitle
    children.selectionList];

if ~strcmp(get_param(bd, 'ExtModeUploadStatus'), 'inactive'),
    set(onOffHandles, 'Enable', 'off');

    %
    % It's hard to read the selected item on the list box when the
    % enable state if off.  So, we cache the selected items (value)
    % and temporarily clear the selection.
    %
    h  = children.selectionList;
    ud = get(h, 'UserData');
    ud.oldSelection = get(h, 'Value');
    set(h, 'UserData', ud, 'Value', []);

else,
    set(onOffHandles, 'Enable', 'on');

    % special cases
    hInactive = [children.staticSignal];
    set(hInactive, 'Enable', 'inactive');

    %
    % Adjust based on dependencies
    %
    i_AdjustSigListCtrlsState(dlgUserData);
    i_AdjustTrigSigCtrlsState(dlgUserData);

    if get(children.selectAllCheckbox, 'Value'),
        set(children.clearAllButton, 'Enable', 'off');
        set([children.onRadio children.offRadio],'Enable','off');
    end
    
    %
    % Restore the selection on the list box.
    %
    h  = children.selectionList;
    ud = get(h, 'UserData');
    if ~isempty(ud.oldSelection) && (ud.oldSelection(1) ~= -1),
        oldSelection    = ud.oldSelection;
        ud.oldSelection = -1;
        set(h, 'UserData', ud, 'Value', oldSelection);
    end
end


% Function =====================================================================
% Install callbacks for the uicontrols.

function i_InstallCallbacks(bd, dlgUserData),

children = dlgUserData.children;

%
% Signal selection list.
%
selectionList = children.selectionList;
cb = 'logcfg(''selectionlist'', gcbf)';
set(selectionList, 'Callback', cb);

%
% Select all button.
%
cb = 'logcfg(''selectall'', gcbf)';
set(children.selectAllCheckbox, 'Callback', cb);

%
% Clear all button.
%
cb = 'logcfg(''clearall'', gcbf)';
set(children.clearAllButton, 'Callback', cb);

%
% On/Off radio buttons.
%
radioGroup = [children.onRadio children.offRadio];
cb = 'logcfg(''onoffradio'', gcbf)';
set(radioGroup, 'Callback', cb);

%
% Trigger signal button.
%
cb = 'logcfg(''trigsigbutton'', gcbf)';
set(children.triggerSourceButton, 'Callback', cb);

%
% Go to block button.
%
cb = 'logcfg(''gotoblockbutton'', gcbf)';
set(children.gotoBlockButton, 'Callback', cb);

%
% Source popup.
%
cb = 'logcfg(''sourcepopup'', gcbf)';
set(children.sourcePopup, 'Callback', cb);

%
% Port edit.
%
cb = 'logcfg(''portedit'', gcbf)';
set(children.portEdit, 'Callback', cb);

%
% Rest of the hg items on the dialog that need to trigger the apply button
%
trigapplyItems = [
    children.durationEdit
    children.modePopup
    children.delayEdit
    children.armWhenConnectCheckbox
    children.directionPopup
    children.levelEdit
    children.holdOffEdit
    children.elementEdit];
cb = 'logcfg(''trigapply'', gcbf)';
set(trigapplyItems, 'Callback', cb);

%
% Revert button.
%
cb = 'logcfg(''revert'', gcbf)';
set(children.revert, 'Callback', cb);

%
% Apply button
%
cb = 'logcfg(''apply'', gcbf)';
set(children.apply, 'Callback', cb);

%
% Close button
%
cb = 'logcfg(''hgclosereqfcn'', gcbf)';
set(children.close, 'Callback', cb);

%
% Help button
%
cb = 'logcfg(''help'', gcbf)';
set(children.help, 'Callback', cb);


% Function =====================================================================
% Handle callback from signal selection list.

function i_SelectionListCB(dlgFig, dlgUserData),

children          = dlgUserData.children;
selectAllCheckbox = children.selectAllCheckbox;
selectAll         = get(selectAllCheckbox,'value');

selectionType = get(dlgFig, 'SelectionType');
if ~strcmp(selectionType, 'open'),
    i_CtrlValuesFromSigSelection(dlgUserData);
    i_AdjustSigListCtrlsState(dlgUserData);
elseif ~selectAll,
    children        = dlgUserData.children;
    selectionList   = children.selectionList;
    ud              = get(selectionList, 'UserData');
    value           = get(selectionList, 'Value');
    radioGroup      = [children.onRadio children.offRadio];

    if isempty(value)
        return;
    end

    if length(value) ~= 1,
        i_Assert('Only one selection expected for double click');
    end

    if ud.on(value) == 1,
        buttonToPress = children.offRadio;
    else,
        buttonToPress = children.onRadio;
    end
    
    i_RadioBehaviorWithPress(dlgFig, dlgUserData, buttonToPress);
end

    
% Function =====================================================================
% Implement mutual exclusive radio button behavior.
% Assumption: The radio buttons are initialize correctly (one or none are on).
% Returns 1 if a different radio button was turned on, 0 if there was no
% change.

function bNewValue = i_RadioBehavior(allButtons, pressedButton),

bNewValue = 1;

value = get(pressedButton, 'Value');

if value == 0,
  % a button cannot turn itself off
  set(pressedButton, 'Value', 1);
  bNewValue = 0;
  return;
else,
  % remove pressed button from list
  allButtons(allButtons == pressedButton) = [];

  % turn off all other buttons.
  set(allButtons, 'Value', 0);
end


% Function =====================================================================
% Implement mutual exclusive radio button behavior.  Prior to implementing this
% behavior, the value of 'buttonToPress' is set to 1 so that it will be on and
% the others will be off (i.e., emulate pressing the button).

function i_RadioBehaviorWithPress(dlgFig, dlgUserData, buttonToPress),

set(buttonToPress, 'Value', 1);
i_OnOffRadioCB(dlgFig, dlgUserData, buttonToPress);


% Function =====================================================================
% Handle callback from on/off radio buttons. 

function i_OnOffRadioCB(dlgFig, dlgUserData, hPressed),

children   = dlgUserData.children;
radioGroup = [children.onRadio children.offRadio];

%
% Implement mutually exclusive radio group.
%
bNewValue = i_RadioBehavior(radioGroup, hPressed);

if bNewValue,
    selectionList   = children.selectionList;
    selectionString = get(selectionList, 'String');
    ud              = get(selectionList, 'UserData');
    value           = get(selectionList, 'Value');

    newState = (hPressed == children.onRadio);

    if ~isempty(value),
        ud.on(value) = newState;
        
        set(selectionList, 'UserData', ud);

        % update any dependencies
        i_CtrlValuesFromSigSelectStr(dlgUserData);
    end

    allSelected = get(children.selectAllCheckbox,'value');
    selectionString = i_UpdateSelectionHdrStrings( ...
        selectionString, ud,allSelected);
    set(selectionList, 'String', selectionString);
end


% Function =====================================================================
% Handle callback from the trigger signal button.

function i_TrigSigButtonCB(dlgFig, dlgUserData),

children        = dlgUserData.children;
selectionList   = children.selectionList;
selectionString = get(selectionList, 'String');
ud              = get(selectionList, 'UserData');
value           = get(selectionList, 'Value');

if ~isempty(value),
    %
    % The button should only be enabled for a single selection.  Just
    % in case, however, I'll take the first item in the selection.
    %
    value = value(1);

    %
    % If the selected item is the trigger signal, then we want to toggle
    % the trigger status.
    %
    if value ~= ud.trigIdx,
        ud.trigIdx = value;
    else,
        ud.trigIdx = -1;
    end

    %
    % Update any dependencies
    %
    allSelected = get(children.selectAllCheckbox,'value');
    selectionString = i_UpdateSelectionHdrStrings(...
        selectionString, ud,allSelected);

    set(selectionList, 'UserData', ud, 'String', selectionString);
    
    i_CtrlValuesFromSigSelectStr(dlgUserData);
    i_CtrlValuesFromSigSelection(dlgUserData);
end


% Function =====================================================================
% Handle callback for the goto block button.

function i_GotoBlockButtonCB(dlgFig, dlgUserData),

children        = dlgUserData.children;
selectionList   = children.selectionList;
selectionString = get(selectionList, 'String');
ud              = get(selectionList, 'UserData');
value           = get(selectionList, 'Value');

if ~isempty(value),
    %
    % The button should only be enabled for a single selection.  Just
    % in case, however, I'll take the first item in the selection.
    %
    value = value(1);

    block  = ud.blocks(value);
    parent = get_param(block, 'parent');
    open_system(parent);
    LocalDeselectAllObjects(parent);
    set_param(block, 'Selected', 'on');
end


% Function =====================================================================
% Handle callback from the select all checkbox.

function i_SelectAllCheckboxCB(dlgFig, dlgUserData),

children      = dlgUserData.children;
checkbox      = children.selectAllCheckbox;
selectionList = children.selectionList;

handles = [
    children.clearAllButton
    children.onRadio
    children.offRadio];

allSelected = get(checkbox,'value');
if (allSelected),
    set([handles],'enable','off');
else,
    set([handles],'enable','on');
end

selectionString = get(selectionList, 'String');
ud              = get(selectionList, 'UserData');

selectionString = i_UpdateSelectionHdrStrings(selectionString, ud,allSelected);
set(selectionList, 'UserData', ud, 'String', selectionString);


% Function =====================================================================
% Handle callback from the clear all button.

function i_ClearAllButtonCB(dlgFig, dlgUserData),

children        = dlgUserData.children;
selectionList   = children.selectionList;

selectionString = get(selectionList, 'String');

origValue = get(selectionList, 'Value');
nRows     = length(selectionString);

tmpValue = 1:nRows;
set(selectionList, 'Value', tmpValue);

i_RadioBehaviorWithPress(dlgFig, dlgUserData, children.offRadio);
set(selectionList, 'Value', origValue);


% Function =====================================================================
% Handle callback from the trigger source popup menu.

function i_TrigSourcePopupCB(dlgFig, dlgUserData),

i_AdjustTrigSigCtrlsState(dlgUserData);


% Function =====================================================================
% Apply settings to each block.  This includes the 'ExtModeUploadOption' and 
% the 'ExtModeLoggingTrig' properties.  If the 3rd arg is 1, the changes are
% not applied.  The name of the unapplied property is returned if one is
% detected, otherwise '' is returned.

function unapplied = i_ApplyBlockSettings(dlgFig,dlgUserData,lookForUnapplied),

children        = dlgUserData.children;
selectionList   = children.selectionList;
ud              = get(selectionList, 'UserData');

upSettingIdx = ud.on + 1; %adjust for 1 based indexing
upSetting    = {'none', 'log'};

unapplied = '';

%
% Set'ExtModeUploadOption' and, if a trigger has been designated, set it.
% In the process we clear any clear any existing trigger entries.  This 
% will get the user out of a situation, probably due to direct use
% of set_param, where there is more than block in the block diagram that
% has the 'ExtModeLoggingTrig' property set to 'on'.
%
for i=1:length(ud.on),
    newUploadVal      = upSetting{upSettingIdx(i)};
    newLoggingTrigVal = onoff(ud.trigIdx == i);
    block             = ud.blocks(i);

    if ~lookForUnapplied,
        set_param(block, ...
            'ExtModeUploadOption',  newUploadVal, ...
            'ExtModeLoggingTrig',   newLoggingTrigVal);
    else,
        oldUploadVal = get_param(block, 'ExtModeUploadOption');
        if ~strcmp(oldUploadVal, newUploadVal),
            unapplied = 'ExtModeUploadOption';
            return;
        end

        oldLoggingTrigVal = get_param(block, 'ExtModeLoggingTrig');
        if ~strcmp(oldLoggingTrigVal, newLoggingTrigVal),
            unapplied = 'ExtModeLoggingTrig';
            return;
        end
    end
end

% Function =====================================================================
% Enable the "Apply" button if anything on the dialog changed when it was
% disabled. 
%
function i_EnableApply(dlgFig, dlgUserData)

children  = dlgUserData.children;
bd        = dlgUserData.bd;

if strcmp( 'off', get(children.apply, 'Enable') )
  set(children.apply, 'Enable', 'on');
end


% Function =====================================================================
% Handle callback from the apply button.  If the 3rd arg is 1, the changes are
% not applied.  The name of the unapplied property is returned if one is
% detected, otherwise '' is returned.

function unapplied = i_ApplyCB(dlgFig, dlgUserData, lookForUnapplied),

children  = dlgUserData.children;
bd        = dlgUserData.bd;
unapplied = '';

if ~lookForUnapplied && ~strcmp(get_param(bd, 'ExtModeUploadStatus'), 'inactive'),
    error(['External logging configuration cannot be changed while data ' ...
           'logging is in progress.']);
end

unapplied = i_ApplyBlockSettings(dlgFig, dlgUserData, lookForUnapplied);
if ~isempty(unapplied),
    return;
end

%
% Block diagram settings.
%

propValPairs = {};

%
% trigger source
%
h      = children.selectAllCheckbox;
prop   = 'ExtModeLogAll';
string = onoff(get(h,'value'));

propValPairs([end+1 end+2]) = {prop, string};


%
% trigger source
%
h      = children.sourcePopup;
prop   = 'ExtModeTrigType';
string = i_TrigSourceFlip(get(h, 'Value'));

propValPairs([end+1 end+2]) = {prop, string};

%
% trigger mode
%
h      = children.modePopup;
prop   = 'ExtModeTrigMode';
string = i_TrigModeFlip(get(h, 'Value'));

propValPairs([end+1 end+2]) = {prop, string};

%
% duration
%
h           =    children.durationEdit;
durationVal = eval(get(h, 'String'));
if durationVal <= 0,
    error('Duration must be greater than zero.');
end
prop = 'ExtModeTrigDuration';
propValPairs(end+1:end+2) = {prop, durationVal};

%
% delay
%
h    = children.delayEdit;
val  = eval(get(h, 'String'));
if (val<0) && (-val > durationVal),
    error('Pre-triggering delay must be less than the duration');
end
prop = 'ExtModeTrigDelay';
propValPairs(end+1:end+2) = {prop, val};

%
% arm when connect
%
h    = children.armWhenConnectCheckbox;
str  = onoff(get(h, 'Value'));
prop = 'ExtModeArmWhenConnect';
propValPairs(end+1:end+2) = {prop, str};

%
% direction
%
h      = children.directionPopup;
prop   = 'ExtModeTrigDirection';
string = i_TrigDirectionFlip(get(h, 'Value'));
propValPairs([end+1 end+2]) = {prop, string};


%
% level
%
h    = children.levelEdit;
val  = eval(get(h, 'String'));
prop = 'ExtModeTrigLevel';
propValPairs(end+1:end+2) = {prop, val};


%
% hold-off
%
h    = children.holdOffEdit;
val  = eval(get(h, 'String'));
prop = 'ExtModeTrigHoldOff';
propValPairs(end+1:end+2) = {prop, val};


%
% trigger port
%
h    = children.portEdit;
str  = get(h, 'String');
prop = 'ExtModeTrigPort';
propValPairs(end+1:end+2) = {prop, str};


%
% Sync trigger port element.
%
h    = children.elementEdit;
str  = get(h, 'String');
prop = 'ExtModeTrigElement';
propValPairs(end+1:end+2) = {prop, str};

%
% Disable the apply button
%
set(children.apply, 'Enable', 'off');

%
% Apply to bd or look for unapplied settings.
%
if ~lookForUnapplied,
    set_param(bd, propValPairs{:});
else,
    unapplied = i_CheckPVPairsForChanges(bd, propValPairs);
end


% Function =====================================================================
% Given a set of property value pairs and a bd, check to see if any of the
% values in the pvpair vector are different from those stored in the block
% diagram.  If they are then there are unapplied changes - return the name
% of the property.  If all values are different, then there are no unapplied
% changes.  Return an empty string.

function unapplied = i_CheckPVPairsForChanges(bd, propValPairs),

unapplied = '';
for i=1:2:length(propValPairs),
    prop   = propValPairs{i};
    newVal = propValPairs{i+1};

    oldVal = get_param(bd, prop);

    if ~isequal(oldVal, newVal),
        unapplied = prop;
        return;
    end
end


% Function =====================================================================
% Handle callback from the revert button.

function i_RevertCB(dlgFig, dlgUserData),

bd = dlgUserData.bd;

if ~strcmp(get_param(bd, 'ExtModeUploadStatus'), 'inactive'),
    error(['External logging configuration cannot be changed while data ' ...
           'logging is in progress.']);
end

revertInfo = dlgUserData.revertInfo;
bd         = dlgUserData.bd;

%
% Revert the values.
%
for i=1:length(revertInfo),
    set(revertInfo{i}{:});
end

%
% Re-adjust the dialog state (enabling of controls) based on the new values.
%
i_AdjustDlgState(bd, dlgUserData);

%
% Re-apply the values.
%
dum = i_ApplyCB(dlgFig, dlgUserData, 0);


% Function =====================================================================
% Handle callback from the close button.

function i_CloseReqCB(dlgFig, dlgUserData),

bd           = dlgUserData.bd;
applyChanges = 1;

if ~strcmp(get_param(bd, 'ExtModeUploadStatus'),'inactive'),
    %
    % We can't apply any unapplied changes if this dialog is being closed
    % while uploading is in progress.  So, we inform the user that that
    % any unapplied changes will be lost and give the option of leaving the
    % dialog opened.
    %
    unappliedChanges = i_ApplyCB(dlgFig, dlgUserData, 1);
    if ~isempty(unappliedChanges),
        beep;
        quest = ['External data logging configuration properties cannot be ' ...
                 'modified while data uploading is in progress.  Closing ' ...
                 'the dialog will result in the loss of any unapplied ' ...
                 'changes.  Do you want to close the dialog now?'];
        answer = questdlg(quest,'External data logging','Yes','Cancel','Yes');
        if ~strcmp(answer, 'Yes'),
            return;
        else,
            applyChanges = 0;
        end
    else
        %
        % No changes to apply.  Close silently.
        %
        applyChanges = 0;
    end
end

if applyChanges,
    dum = i_ApplyCB(dlgFig, dlgUserData, 0);
end
set(dlgFig, 'Visible', 'off');

%
% Function: LocalDeselectAllObjects ============================================
% Abstract:
%    Deselects all objects in a given system.
%
function LocalDeselectAllObjects(bd)

selectedObjs = find_system(bd, ...
			   'SearchDepth', 1, ...
			   'FindAll',     'on', ...
			   'AllBlocks',   'on', ...
                           'Selected',    'on');
for i = 1:length(selectedObjs),
  set_param(selectedObjs(i),'Selected','off')
end

% LocalDeselectAllObjects

%
% Function: isBlockModelBased ==================================================
% Abstract:
%    Returns true if the block being passed in is model based, false otherwise.
%
function modelBased = isBlockModelBased(block)

Type = get_param(block, 'blockType');

if (strcmp(Type,'SignalViewerScope')),
    modelBased = true;
else
    modelBased = false;
end

% end function isBlockModelBased

%
% Function: GetModelBasedBlockDisplayName ======================================
% Abstract:
%    Returns the name of a model based block with the special model based
%    prefix stripped out.  This version of the name is suitable for
%    displaying to the user.
%
function name = GetModelBasedBlockDisplayName(block)

ModelBased = isBlockModelBased(block);
if (ModelBased == 0)
    i_Assert(['Input to GetModelBasedBlockDisplayName() must be ' ...
              'a model based block.']);
end

Type = get_param(block, 'blockType');

if (strcmp(Type,'SignalViewerScope')),
    name = get_param(block, 'name');
    name = watchsigsdlg('GetSigViewerDisplayName',name);
end

% end function GetModelBasedBlockDisplayName

%
% Function: GetBlockDisplayName ======================================
% Abstract:
%    Returns the name of a block suitable for displaying to the user.
%
function name = GetBlockDisplayName(block)

ModelBased = isBlockModelBased(block);
if (ModelBased == 0),
    name = get_param(block, 'name');
else,
    name = GetModelBasedBlockDisplayName(block);
end

% end function GetBlockDisplayName

%
% Function: GetModelBasedBlockDisplayPath ======================================
% Abstract:
%    Returns the path of a model based block with the special model based
%    prefix stripped out.  This version of the path is suitable for
%    displaying to the user.
%
function path = GetModelBasedBlockDisplayPath(block)

ModelBased = isBlockModelBased(block);
if (ModelBased == 0)
    i_Assert(['Input to GetModelBasedBlockDisplayPath() must be ' ...
              'a model based block.']);
end

Type = get_param(block, 'blockType');

if (strcmp(Type,'SignalViewerScope')),
    path = getfullname(block);
    path = watchsigsdlg('GetSigViewerDisplayPath',path);
end

% end function GetModelBasedBlockDisplayPath

%
% Function: GetBlockDisplayPath ======================================
% Abstract:
%    Returns the path of a block suitable for displaying to the user.
%
function path = GetBlockDisplayPath(block)

ModelBased = isBlockModelBased(block);
if (ModelBased == 0),
    path = getfullname(block);
else,
    path = GetModelBasedBlockDisplayPath(block);
end

% end function GetBlockDisplayPath
