function varargout = logpanel(varargin),
%LOGPANEL Simulink external mode data logging control panel.
%   LOGPANEL creates and manages the external mode data logging control panel.
%   The first argument is always an "action" string.  The second argument is
%   always the handle to the block diagram (root level).
%
%   See also LOGCFG, LOGCTRLPANEL.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.16.2.4 $

try,
    action = lower(varargin{1});

    switch(action),

      case 'create',
        %
        % Create the dialog if it does not exist, otherwise refresh it
        % and bring it to the foreground.
        %
        bd     = varargin{2};
        dlgFig = varargin{3};

        if dlgFig ~= -1,
            i_Assert('If the dialog exists, use the ''reshow''');
        end

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
        else,
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

      case 'enablearchiving',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');

        i_AdjustArchivingCtrls(dlgUserData);

      case 'revert',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_RevertCB(dlgFig, dlgUserData);

      case 'hgclosereqfcn',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_CloseReqCB(dlgFig, dlgUserData);

      case 'hgdeletefcn',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        if dlgFig ~= -1
          delete(dlgFig);
          dlgFig = -1;
        end

        bd = dlgUserData.bd;
        %
        % Notify the parent that we have disappeared.  Note if this is
        % being called due to the block diagram being deleted, then the
        % bd is already invalid at this point.
        %
        if ishandle(bd),
          parent = get_param(bd, 'ExtModeLogCtrlPanelDlg');

          if ishandle(parent),
            logctrlpanel('subfigdeleted', parent, 'logpanel');
          else,
            warning(['Parent control panel not found.  Orphan ' ...
                  'data archiving dialog.']);
          end
        end

      case 'editdirnote',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_DirNoteCB(dlgFig, dlgUserData);

      case 'editfilenote',
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        i_FileNoteCB(dlgFig, dlgUserData);

      case 'help'
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');

        %
        % Load the help page for this dialog
        %
        set(dlgFig, 'Pointer', 'watch');
	helpview([docroot,'/mapfiles/rtw_ug.map'], 'rtw_data_archiving');
        set(dlgFig, 'Pointer', 'arrow');

      case 'changename'
        bd     = varargin{2};
        dlgFig = varargin{3};

        set(dlgFig, 'Name', i_DialogName(bd));

      otherwise,
        i_Assert('Unrecognized action in main entry point.');

    end %action switch

catch,
    errordlg(lasterr, 'Error in external mode data archiving dialog', 'modal');
end


% Function =====================================================================
% Mimicks a c assertion by throwing an error if asserts are active.

function i_Assert(str),

error(['M Assert: ' str]);


% Function =====================================================================
% Create the external mode logging control panel.

function [dlgFig, dlgUserData] = i_CreateDlg(bd),

%
% Create constants based on current computer & cache in user data.
%
dlgUserData.fontsize = get(0, 'FactoryUicontrolFontSize');
dlgUserData.fontname = get(0, 'FactoryUicontrolFontName');

%
% Create an empty figure & invisible text object for text sizing.
%
figColor      = get(0, 'FactoryUiControlBackGroundColor');
hgclosereqfcn = 'logpanel(''hgclosereqfcn'', gcbf)';
hgdeletefcn   = 'logpanel(''hgdeletefcn'', gcbf)';

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
figWidth1 = geom.wDataArchiveGroup;
figWidth2 = ...
    (geom.wSysButton * 3)       + ...
    (geom.sysButtonDelta * 2)   + ...
    geom.wConfigButton          + ...
    geom.wStatusText;

wFig = ...
    geom.sideEdgeBuffer         +...
    max([figWidth1 figWidth2])  + ...
    geom.sideEdgeBuffer;

hFig = ...
    geom.figTopEdgeBuffer  + ...
    geom.hDataArchiveGroup + ...
    geom.rowSpace   + ...
    geom.hSysButton + ...
    geom.hText;

figPos = get(dlgFig,'Position');
figPos([3 4]) = [wFig hFig];
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
dlgUserData.bd          = bd;


% Function =====================================================================
% Get the name for the dialog box.

function figName = i_DialogName(bd),

figName = [get_param(bd, 'Name') ': ', xlate('External Data Archiving')];


% Function =====================================================================
% Create the geomerty constants for construction of the dialog.  Note that
% these are the minimun size requirements.  Some controls may be stretched
% to improve appearance (e.g., line the right edges up).

function geom = i_CreateGeom(sysOffsets, dlgUserData),

%
% NOTE: These values should be consisten with those in
%       logcfg.m.
%
geom.hText                 = 1   + sysOffsets.text(4);
geom.hEdit                 = 1   + sysOffsets.edit(4);
geom.hButton               = 1   + sysOffsets.pushbutton(4);
geom.hCheckbox             = 1   + sysOffsets.checkbox(4);
geom.wSysButton            = 7.5 + sysOffsets.pushbutton(3);
geom.hSysButton            = 1.1 + sysOffsets.pushbutton(4);
geom.sysButtonDelta        = 1.2;
geom.wConfigButton         = length('__Configure...__');
geom.wArmStopButton        = geom.wConfigButton;
geom.figTopEdgeBuffer      = 1;
geom.figBottomEdgeBuffer   = 0.5;
geom.frameTopEdgeBuffer    = (geom.hText/1.8);
geom.frameBottomEdgeBuffer = 1.0;
geom.sideEdgeBuffer        = 1.5;
geom.frameDelta            = (geom.hText/1.3);
geom.rowSpace              = 0.5;

geom.wEnableCheckbox   = length('enable archiving_') + sysOffsets.checkbox(3);
geom.wDirFileLabel     = length('directory:');
geom.wDirFileEdit      = length('c:\model\remotesim\data\blah\blah');
geom.wEditNotesButtons = length('_Edit Directory Notes ..._');
geom.wColDelta         = 4.3;

geom.wCol2Checkbox = ...
    length('Write intermediate results to workspace___') + sysOffsets.checkbox(3);

geom.wStatusText = length('This seems like enough') + sysOffsets.text(3);

geom.wMaxCol1 = geom.wDirFileLabel + geom.wDirFileEdit;

geom.wDataArchiveGroup = ...
    geom.sideEdgeBuffer + ...
    geom.wMaxCol1       + ...
    geom.wColDelta      + ...
    geom.wCol2Checkbox  + ...
    geom.sideEdgeBuffer;

geom.hDataArchiveGroup = ...
    geom.frameTopEdgeBuffer + ...
    geom.hCheckbox          + ...
    geom.rowSpace           + ...
    geom.hEdit              + ...
    geom.rowSpace           + ...
    geom.hEdit              + ...
    geom.rowSpace           + ...
    geom.hButton            + ...
    geom.rowSpace           + ...
    geom.hButton            + ...
    geom.frameBottomEdgeBuffer;


% Function =====================================================================
% Calculate the position for every control.

function ctrlPos = i_CtrlPos(geom, figPos),


%
% Data Archiving group box.
%

%
% ...frame
%

frameLeft = geom.sideEdgeBuffer;

frameTop    = figPos(4) - geom.figTopEdgeBuffer;
frameBottom = frameTop - geom.hDataArchiveGroup;

ctrlPos.dataArchiveGroupbox = ...
    [frameLeft frameBottom geom.wDataArchiveGroup geom.hDataArchiveGroup];

%
% ...enable archive checkbox
%
cxCur = frameLeft + geom.sideEdgeBuffer;
cyCur = frameTop - geom.frameTopEdgeBuffer - geom.hCheckbox;

ctrlPos.enableArchiveCheckbox = ...
    [cxCur cyCur geom.wEnableCheckbox geom.hCheckbox];

%
% ...directory text label
%
cyCur  = cyCur - geom.rowSpace - geom.hEdit;
cyRow1 = cyCur;

ctrlPos.dirTextLabel = [cxCur cyCur geom.wDirFileLabel geom.hText];

%
% ...directory edit box
%
cxCur = cxCur + geom.wDirFileLabel;
ctrlPos.dirEdit = [cxCur cyCur geom.wDirFileEdit geom.hEdit];

%
% ...file text label
%
cxCur = frameLeft + geom.sideEdgeBuffer;
cyCur = cyCur - geom.rowSpace - geom.hEdit;

ctrlPos.fileTextLabel = [cxCur cyCur geom.wDirFileLabel geom.hText];

%
% ...file edit box
%
cxCur = cxCur + geom.wDirFileLabel;
ctrlPos.fileEdit = [cxCur cyCur geom.wDirFileEdit geom.hEdit];
fileEditRight = cxCur + geom.wDirFileEdit;

%
% ... Edit directory note button (center).
%
totalFileWidth = fileEditRight - (frameLeft + geom.sideEdgeBuffer);
centerOffset   = (totalFileWidth - geom.wEditNotesButtons)/2;

cxCur = frameLeft + geom.sideEdgeBuffer + centerOffset;
cyCur = cyCur - geom.rowSpace - geom.hButton;
ctrlPos.dirNoteButton = [cxCur cyCur geom.wEditNotesButtons geom.hButton];

%
% ...Edit file note button
%
cyCur = cyCur - geom.rowSpace - geom.hButton;
ctrlPos.fileNoteButton = [cxCur cyCur geom.wEditNotesButtons geom.hButton];

%
% ...Increment dir when armed
%
cxCol2 = frameLeft + geom.sideEdgeBuffer + geom.wMaxCol1 + geom.wColDelta;
cxCur  = cxCol2;
cyCur  = cyRow1;

ctrlPos.incDirWhenArmCheckbox = ...
    [cxCur cyCur geom.wCol2Checkbox geom.hCheckbox];

%
% ...Increment file after one-shot
%
cyCur = cyCur - geom.rowSpace - geom.hCheckbox;
ctrlPos.incFileOnOneshotCheckbox = ...
    [cxCur cyCur geom.wCol2Checkbox geom.hCheckbox];

%
% ...Append file suffix to variable name
%
cyCur = cyCur - geom.rowSpace - geom.hCheckbox;
ctrlPos.appendSuffixToVarCheckbox = ...
    [cxCur cyCur geom.wCol2Checkbox geom.hCheckbox];

%
% ...Write intermediate files to WS
%
cyCur = cyCur - geom.rowSpace - geom.hCheckbox;
ctrlPos.writeIntermediateFileCheckbox = ...
    [cxCur cyCur geom.wCol2Checkbox geom.hCheckbox];

%
% "system" buttons (work left to right).
%

cxCur = (figPos(3) - geom.sideEdgeBuffer) - ...
        ((3 * geom.wSysButton) + (3 * geom.sysButtonDelta));
cyCur = frameBottom - geom.rowSpace - geom.hSysButton;

%
% ...revert button
%
ctrlPos.revertButton = ...
    [cxCur cyCur geom.wSysButton geom.hSysButton];

%
% ...Help button
%
cxCur = cxCur + geom.sysButtonDelta + geom.wSysButton;
ctrlPos.helpButton = ...
    [cxCur cyCur geom.wSysButton geom.hSysButton];

%
% ...Close button
%
cxCur = cxCur + geom.sysButtonDelta + geom.wSysButton;
ctrlPos.closeButton = ...
    [cxCur cyCur geom.wSysButton geom.hSysButton];

%
% ...Status text.
%
cxCur = 0.02;
cyCur = 0.02;
wStat = figPos(3)-2;

ctrlPos.statusText = ...
    [cxCur cyCur wStat 1];


% Function =====================================================================
% Create the uicontrols in the specified locations.

function children = i_CreateCtrls(dlgFig, ctrlPos, dlgUserData, geom),

textExtent = dlgUserData.textExtent;

children.dataArchiveGroupbox = groupbox(...
    dlgFig, ...
    ctrlPos.dataArchiveGroupbox, ...
    ' Data archiving', ...
    textExtent);

children.enableArchiveCheckbox = uicontrol(...
    'Parent',       dlgFig, ...
    'Style',        'checkbox', ...
    'String',       'Enable archiving', ...
    'Position',     ctrlPos.enableArchiveCheckbox);

children.dirTextLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'Directory:', ...
    'Position',           ctrlPos.dirTextLabel);

children.dirEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.dirEdit, ...
    'BackGroundColor',    'w');

children.fileTextLabel = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             'File:', ...
    'Position',           ctrlPos.fileTextLabel);

children.fileEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.fileEdit, ...
    'BackGroundColor',    'w');

children.dirNoteButton = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Edit Directory Note...', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.dirNoteButton);

children.fileNoteButton = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Edit File Note...', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.fileNoteButton);

children.incDirWhenArmCheckbox = uicontrol( ...
    'Parent',       dlgFig, ...
    'Style',        'checkbox', ...
    'String',       'Increment directory when trigger armed', ...
    'Position',     ctrlPos.incDirWhenArmCheckbox);

children.incFileOnOneshotCheckbox = uicontrol( ...
    'Parent',       dlgFig, ...
    'Style',        'checkbox', ...
    'String',       'Increment file after one-shot', ...
    'Position',     ctrlPos.incFileOnOneshotCheckbox);

children.appendSuffixToVarCheckbox = uicontrol( ...
    'Parent',       dlgFig, ...
    'Style',        'checkbox', ...
    'String',       'Append file suffix to variable names', ...
    'Position',     ctrlPos.appendSuffixToVarCheckbox);

children.writeIntermediateFileCheckbox = uicontrol( ...
    'Parent',       dlgFig, ...
    'Style',        'checkbox', ...
    'String',       'Write intermediate results to workspace', ...
    'Position',     ctrlPos.writeIntermediateFileCheckbox);

children.statusText = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'text', ...
    'String',             '', ...
    'Position',           ctrlPos.statusText);

children.revertButton = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Revert', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.revertButton);

children.helpButton = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Help', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.helpButton);

children.closeButton = uicontrol( ...
    'Parent',             dlgFig, ...
    'String',             'Close', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.closeButton);


% Function =====================================================================
% Get all property values from block diagram and update the contents of the ui
% controls.  If the 3rd arg is 1, then update the revert buffers and the
% revertInfo is returned, otherwise, revertInfo is returned as {}.

function revertInfo = i_SyncDlg(bd, dlgUserData, updateRevertBuf),

children = dlgUserData.children;

revertInfo = {};

%
% Sync the enable archive checkbox.
%
h   = children.enableArchiveCheckbox;
str = get_param(bd, 'ExtModeArchiveMode');
val = ~strcmp(str, 'off');
setInfo = {h, 'Value', val};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync the directory edit box.
%
h       = children.dirEdit;
str     = get_param(bd, 'ExtModeArchiveDirName');
setInfo = {h, 'String', str};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end


%
% Sync the file edit box.
%
h       = children.fileEdit;
str     = get_param(bd, 'ExtModeArchiveFileName');
setInfo = {h, 'String', str};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync the increment directory when arm checkbox.
%
h       = children.incDirWhenArmCheckbox;
val     = onoff(get_param(bd, 'ExtModeIncDirWhenArm'));
setInfo = {h, 'Value', val};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync the increment file on one shot checkbox.
%
h = children.incFileOnOneshotCheckbox;
val     = onoff(get_param(bd, 'ExtModeAutoIncOneShot'));
setInfo = {h, 'Value', val};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync the append suffix to variable checkbox.
%
h       = children.appendSuffixToVarCheckbox;
val     = onoff(get_param(bd, 'ExtModeAddSuffixToVar'));
setInfo = {h, 'Value', val};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end

%
% Sync the write intermediate files to workspace checkbox.
%
h       = children.writeIntermediateFileCheckbox;
val     = onoff(get_param(bd, 'ExtModeWriteAllDataToWs'));
setInfo = {h, 'Value', val};
set(setInfo{:});

if updateRevertBuf,
    revertInfo{end+1,1} = setInfo;
end


% Function =====================================================================
% Adjust the enabled state of the arhciving controls based on the value of
% the enable archiving checkbox.

function i_AdjustArchivingCtrls(dlgUserData),

children         = dlgUserData.children;
archivingEnabled = onoff(get(children.enableArchiveCheckbox, 'Value'));

handles = [
    children.dirTextLabel
    children.dirEdit
    children.fileTextLabel
    children.fileEdit
    children.incDirWhenArmCheckbox
    children.incFileOnOneshotCheckbox
    children.appendSuffixToVarCheckbox];

set(handles, 'Enable',archivingEnabled);
gray = get(0,'defaultuicontrolbackgroundcolor');
if (strcmp(archivingEnabled,'off')),
    set(children.dirEdit,'BackGroundColor',gray);
    set(children.fileEdit,'BackGroundColor',gray);
else,
    set(children.dirEdit,'BackGroundColor','w');
    set(children.fileEdit,'BackGroundColor','w');
end
  


% Function =====================================================================
% Adjust the enable state for the entire dialog.

function i_AdjustDlgState(bd, dlgUserData),

children     = dlgUserData.children;
childrenCell = struct2cell(children);
childrenVect = [childrenCell{:}];

if ~strcmp(get_param(bd, 'ExtModeUploadStatus'), 'inactive'),
    offHandles = [
        children.enableArchiveCheckbox
        children.dirTextLabel
        children.dirEdit
        children.fileTextLabel
        children.fileEdit
        children.incDirWhenArmCheckbox
        children.incFileOnOneshotCheckbox
        children.appendSuffixToVarCheckbox
        children.revertButton
        children.writeIntermediateFileCheckbox];
    set(offHandles, 'Enable', 'off');
else,
    onHandles = [
        children.enableArchiveCheckbox
        children.revertButton
        children.writeIntermediateFileCheckbox];

    set(onHandles, 'Enable', 'on');

    %special cases
    i_AdjustArchivingCtrls(dlgUserData);

%    set(children.armStopButton, 'Enable', get_param(bd, 'ExtModeConnected'));

end

%i_AdjustArmButtonLabelState(bd, dlgUserData);


% Function =====================================================================
% Install callbacks for the uicontrols.

function i_InstallCallbacks(bd, dlgUserData),

children = dlgUserData.children;

%
% Enable archiving checkbox.
%
cb = 'logpanel(''enablearchiving'', gcbf)';
set(children.enableArchiveCheckbox, 'Callback', cb);

%
% Edit directory note.
%
cb = 'logpanel(''editdirnote'', gcbf)';
set(children.dirNoteButton, 'Callback', cb);

%
% Edit file note.
%
cb = 'logpanel(''editfilenote'', gcbf)';
set(children.fileNoteButton, 'Callback', cb);

%
% Revert buttton.
%
cb = 'logpanel(''revert'', gcbf)';
set(children.revertButton, 'Callback', cb);

%
% Close button.
%
cb = 'logpanel(''hgclosereqfcn'', gcbf)';
set(children.closeButton, 'Callback', cb);

%
% Help button.
%
cb = 'logpanel(''help'', gcbf)';
set(children.helpButton, 'Callback', cb);


% Function =====================================================================
% Apply dialog settings.

function i_Apply(dlgFig, dlgUserData),

children = dlgUserData.children;
bd       = dlgUserData.bd;

propValPairs = {};

%
% Enable archiving
%
h      = children.enableArchiveCheckbox;
prop   = 'ExtModeArchiveMode';
if get(h, 'Value'),
    string = 'auto';
else,
    string = 'off';
end

propValPairs([end+1 end+2]) = {prop, string};

%
% Directory name.
%
h      = children.dirEdit;
prop   = 'ExtModeArchiveDirName';
string = get(h, 'String');

propValPairs([end+1 end+2]) = {prop, string};

%
% File name.
%
h      = children.fileEdit;
prop   = 'ExtModeArchiveFileName';
string = get(h, 'String');

propValPairs([end+1 end+2]) = {prop, string};

%
% Increment dir when arm trigger.
%
h      = children.incDirWhenArmCheckbox;
prop   = 'ExtModeIncDirWhenArm';
string = onoff(get(h, 'Value'));

propValPairs([end+1 end+2]) = {prop, string};

%
% increment file on one shot checkbox.
%
h      = children.incFileOnOneshotCheckbox;
prop   = 'ExtModeAutoIncOneShot';
string = onoff(get(h, 'Value'));

propValPairs([end+1 end+2]) = {prop, string};

%
% append suffix to variable checkbox.
%
h      = children.appendSuffixToVarCheckbox;
prop   = 'ExtModeAddSuffixToVar';
string = onoff(get(h, 'Value'));

propValPairs([end+1 end+2]) = {prop, string};

%
% write intermediate files to workspace checkbox.
%
h      = children.writeIntermediateFileCheckbox;
prop   = 'ExtModeWriteAllDataToWs';
string = onoff(get(h, 'Value'));

propValPairs([end+1 end+2]) = {prop, string};

%
% Apply to bd.
%
set_param(bd, propValPairs{:});


% Function =====================================================================
% Handle callback from the close button.

function i_CloseReqCB(dlgFig, dlgUserData),

bd               = dlgUserData.bd;
uploadInProgress = ~strcmp(get_param(bd, 'ExtModeUploadStatus'),'inactive');

if ~uploadInProgress,
    %
    % Only need to apply if uploading is not in progress since no changes
    % should have been allowed (uicontrols are disabled while uploading).
    % We must not try to apply these values while uploading is occuring
    % because set_param throw errors.
    %
    i_Apply(dlgFig, dlgUserData);
end

set(dlgFig, 'Visible', 'off');


% Function =====================================================================
% Handle callback from the revert button.

function i_RevertCB(dlgFig, dlgUserData),

revertInfo = dlgUserData.revertInfo;
bd         = dlgUserData.bd;

%
% Revert the values.
%
for i=1:length(revertInfo),
    set(revertInfo{i}{:});
end


% Function =====================================================================
% From the last file that was written do, return its directory name.

function dirName = i_DirNameFromFileName(fName),

if isempty(fName),
    dirName = '';
    return;
end

lastSlash = max(find(fName == '/'));
if isempty(lastSlash),
    lastSlash = max(find(lastFileWritten == '\'));
end

if ~isempty(lastSlash),
    dirName = fName(1:lastSlash);
else,
    dirName = filesep; %root
end


% Function =====================================================================
% Handle callback from the "edit dir note" button.  This isn't the best
% approach, but since uigetfile errors out if a file does not exist, there
% isn't a great way to edit an existing file or create a new one.  So, for now
% we are essentially making this button a link to MATLAB's default editor.
% If we know the last directory that was written to, then we open the editor
% in that directory.  If a note.txt exists in that dir, then it is loaded
% otherwise, we first create an empty note.txt in that dir and load that.
% If we don't know that directory was last written to, then we just open
% the editor.
%

function i_DirNoteCB(dlgFig, dlgUserData),

bd = dlgUserData.bd;

%
% Open the editor with the note file from the last directory that was written
% into.  If the user wants to edit a different file or create a new one
% he can do it from within the environment of the editor.
%
lastFileWritten = get_param(bd, 'ExtModeLastArchiveFile');
fileToEdit = '';
if ~isempty(lastFileWritten),
    dirName    = i_DirNameFromFileName(lastFileWritten);
    fileToEdit = [dirName 'note.txt'];
end

if ~isempty(fileToEdit),
    %
    % Ensure that the file exists, so we can open the editor with the
    % target file name.
    %
    if ~exist(fileToEdit),
        fid = fopen(fileToEdit, 'w');
        if fid == -1,
            error(['Could not create directory note file: ' fileToEdit]);
        end
        fclose(fid);
    end

    try,
        edit(fileToEdit);
    catch,
        warning(['Could not open file: ''' fileToEdit '''in MATLAB''s default editor.']);
        try,
            edit;
        catch,
            error(['Could not open MATLAB''s default editor.']);
        end
    end
else,
    try,
        edit;
    catch,
        error(['Could not open MATLAB''s default editor.']);
    end
end


% Function =====================================================================
% Handle callback from the "edit file note" button.  If we know what the
% last directory written to is, then give a choice of all MAT-files in that
% directory.  If not, then just open-up the open dialog in the current
% directory and show all MAT files.

function i_FileNoteCB(dlgFig, dlgUserData),

bd = dlgUserData.bd;

lastFileWritten = get_param(bd, 'ExtModeLastArchiveFile');

if ~isempty(lastFileWritten),
    if 0,
        %
        % strip the file name to getlast dir written
        %
        lastSlash = max(find(lastFileWritten == '/'));
        if isempty(lastSlash),
            lastSlash = max(find(lastFileWritten == '\'));
        end

        if ~isempty(lastSlash),
            dirName = lastFileWritten(1:lastSlash);
        else,
            dirName = filesep; %root
        end
        defFile = [dirName '*.mat'];
    else,
        defFile = lastFileWritten;
    end

    if isunix,
        defFile(defFile == '\') = '/';
    else,
        defFile(defFile == '/') = '\';
    end
else,
    defFile = '*.mat';
end

[fname, pname] = uigetfile(defFile, xlate('Edit File Note'));
if fname == 0,
    % user cancelled operation
    return;
end

fileToEdit = [pname fname];

note = '';
try,
    load(fileToEdit, 'note'); % not an error if note does not exist!
catch,
    error(['Error loading note from MAT-file: ''' fileToEdit ': ' lasterr]);
    return;
end

if ~iscell(note),
    note = {note};
end
note = inputdlg(['Enter note for: ' fileToEdit], 'External mode',15,note);
if ~isempty(note),
    save(fileToEdit, '-append', 'note');
end
