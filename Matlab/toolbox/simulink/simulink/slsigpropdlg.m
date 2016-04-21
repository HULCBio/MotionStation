function figHdl = slsigpropdlg(varargin)
% SLSIGPROPDLG Signal properties dialog with Signal Logging fields.
%   SLSIGPROPDLG(varargin) displays the dialog for editing signal properties.
  
%   Jun Wu
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $
  
if nargin < 1,
  error('Not enough input arguments');
end

action = varargin{1};
ArgErrorStr = ['Invalid arguments for ''', mfilename, ''' ', ...
	       'to perform ''', action,''' action'];

switch action,
  
 case 'Open',
  %-------------------------------------------------------------
  % Opens the dialog and sets its components to values of 
  % corresponding port parameters. If the dialog is already 
  % opened, just bring it to the front.
  %-------------------------------------------------------------
  if nargin ~= 2 
    error(ArgErrorStr); 
  end,
  portHdl = varargin{2};
  figHdl  = get_param(portHdl,'SigPropDialogHandle');
  
  if ishandle(figHdl)
    ud = get(figHdl, 'UserData'); 
    ud.javaItems.figHdl.setVisible(1);
  else
    % create dialog if there isn't one; or show the existing one
    figHdl  = CreateDlg(figHdl, portHdl);
  end
  
  simStatus = get_param(bdroot(get_param(portHdl,'Parent')), 'SimulationStatus');
  if strcmp(simStatus,'stopped') | strcmp(simStatus,'terminating')
    % sychronize the control items with parameter data
    UpdateFigureItems(figHdl, varargin{2});
  end

 case 'Apply',
  %-------------------------------------------------------------
  % Applies changes to port parameters.
  %-------------------------------------------------------------
  if nargin ~= 2 error(ArgErrorStr); end,
  figHdl = varargin{2};
  ApplyAllChanges(figHdl);
  
 case 'Help'
  %-------------------------------------------------------------
  % Open help window on Signal Properties dialog
  %-------------------------------------------------------------
  slprophelp('signal');
  
 case 'DocLink',
  %-------------------------------------------------------------
  % Document Link field callback.
  %-------------------------------------------------------------
  if nargin ~= 2 error(ArgErrorStr); end,
  figHdl = varargin{2};
  DocumentLinkCallback(figHdl);

 case 'Refresh'
  if nargin ~= 2 error(ArgErrorStr); end;
  figHdl = varargin{2};
  ud = get(figHdl, 'UserData');
  
  % sychronize the control items with parameter data
  UpdateFigureItems(figHdl, ud.portHdl);
 
 case 'LogNamePopupChanged'
  if nargin ~= 2 error(ArgErrorStr); end;
  figHdl = varargin{2};
  LogNamePopupChangedCallback(figHdl);
  
 case {'ToggleLoggingPanel', 'SimStart', 'SimStop'},
  %-------------------------------------------------------------
  % Update the state of Logging tab
  %-------------------------------------------------------------
  if nargin ~= 2 error(ArgErrorStr); end;
  portHdl = varargin{2};
  figHdl  = get_param(portHdl,'SigPropDialogHandle');
  ToggleLoggingTab(figHdl, portHdl);
  
 otherwise,
  %-------------------------------------------------------------
  % Default case - Invalid action command.
  %-------------------------------------------------------------
  error(['Invalid action command for ''', mfilename, ': ' action '.']);
  
end

% end slsigpropdlg


% Function: CreateDlg ----------------------------------------------------------
% Abstract:
%   This function will create the signal properties dialog if it is not 
%   existing, or bring the existing one to the front.
%
function figHdl = CreateDlg(figHdl, portHdl);
  
import com.mathworks.toolbox.simulink.signalproperty.*;
figHdl = SLSigProp(onoff(get_param(0,'RTWLicensed')));

javaItems.figHdl  = handle(figHdl, 'callbackproperties');
javaItems.sigName = handle(figHdl.sigName, 'callbackproperties');
javaItems.description = handle(figHdl.description, 'callbackproperties');
javaItems.docLink = handle(figHdl.docLink, 'callbackproperties');
javaItems.propagatedSigPopup = handle(figHdl.propagatedSigPopup, ...
                                      'callbackproperties');
javaItems.logDataCheckbox = handle(figHdl.logDataCheckbox, ...
                                   'callbackproperties');
javaItems.testPointCheckbox = handle(figHdl.testPointCheckbox, ...
                                     'callbackproperties');
javaItems.logNamePopup = handle(figHdl.logNamePopup, 'callbackproperties');
javaItems.logNameEdit = handle(figHdl.logNameEdit, 'callbackproperties');
javaItems.limitDataCheckbox = handle(figHdl.limitDataCheckbox, ...
                                     'callbackproperties');
javaItems.limitDataEdit = handle(figHdl.limitDataEdit, 'callbackproperties');
javaItems.decimationCheckbox = handle(figHdl.decimationCheckbox, ...
                                      'callbackproperties');
javaItems.decimationEdit = handle(figHdl.decimationEdit, ...
                                  'callbackproperties');
javaItems.frameCheckbox = handle(figHdl.frameCheckbox, ...
                                 'callbackproperties');
javaItems.rtwSCPopup = handle(figHdl.rtwSCPopup, 'callbackproperties');
javaItems.rtwSTQEdit = handle(figHdl.rtwSTQEdit, 'callbackproperties');
javaItems.okButton = handle(figHdl.okButton, 'callbackproperties');
javaItems.clButton = handle(figHdl.clButton, 'callbackproperties');
javaItems.hpButton = handle(figHdl.hpButton, 'callbackproperties');
javaItems.apButton = handle(figHdl.apButton, 'callbackproperties');

ud.javaItems = javaItems;

% adjust the location of the dialog
dlgDims = [javaItems.figHdl.getWidth javaItems.figHdl.getHeight];
portPos = get_param(portHdl, 'Position');
sysPos  = get_param(get_param(get_param(portHdl, 'Parent'), 'Parent'), ...
		    'Location');
portPos = [portPos(1:2)+sysPos(1:2) portPos(1:2)+sysPos(1:2)+sysPos(3:4)];

% make sure that the dialog will stay inside teh window
screenSize = get(0, 'ScreenSize');

if portPos(1) < 0
  portPos(1) = 0;
end
if portPos(2) < 0
  portPos(2) = 0;
end
if portPos(1)+dlgDims(1) > screenSize(3)
  portPos(1) = screenSize(3)-dlgDims(1);
end
if portPos(2)+dlgDims(2) > screenSize(4)
  portPos(2) = screenSize(4)-dlgDims(2);
end
javaItems.figHdl.setLocation(portPos(1), portPos(2));

ud.portHdl = portHdl;
set(figHdl, 'UserData', ud);

% end CreateDlg


% Function: UpdateFigureItems --------------------------------------------------
% Abstract:
%   This function will update all items on the dialog according to the current
%   port handle information
%
function UpdateFigureItems(figHdl, portHdl)

ud = get(figHdl, 'UserData');
javaItems = ud.javaItems;

% Update the title for the dialog based on the signal name
sigName = get_param(portHdl,'Name');
javaItems.figHdl.setTitle(['Signal Properties: ' sigName]);

% documentation panel
javaItems.sigName.setText(sigName);
if onoff(get_param(portHdl,'EnableSigPropUI'))
  javaItems.figHdl.setPropagatedSigPanelItemsEnabled(1);
  javaItems.propagatedSigPopup.setSelectedItem(...
	  get_param(portHdl, 'ShowPropagatedSignals'));
else
  javaItems.figHdl.setPropagatedSigPanelItemsEnabled(0);
end
javaItems.description.setText(get_param(portHdl,'Description'));
javaItems.docLink.setText(get_param(portHdl,'DocumentLink'));

% Signal logging panel
javaItems.logDataCheckbox.setSelected(...
    onoff(get_param(portHdl, 'DataLogging')));
if strcmp(get_param(portHdl, 'DataLoggingNameMode'), 'Custom')
  idx = 1;
elseif strcmp(get_param(portHdl, 'DataLoggingNameMode'), 'SignalName')
  idx = 0;
else
  idx = 0;
  warndlg(['Signal logging feature: parameter ''DataLoggingNameMode'' '...
           'is returning unknown value'], 'Signal Properties Dialog Message');
end
javaItems.logNamePopup.setSelectedIndex(idx);
if idx == 0
  javaItems.logNameEdit.setText(sigName);
  javaItems.logNameEdit.setEnabled(0);
else
  javaItems.logNameEdit.setText(get_param(portHdl, 'DataLoggingName'));
  javaItems.logNameEdit.setEnabled(1);
end

javaItems.limitDataCheckbox.setSelected(...
    onoff(get_param(portHdl,'DataLoggingLimitDataPoints')));
javaItems.limitDataEdit.setText(get_param(portHdl,'DataLoggingMaxPoints'));
javaItems.decimationCheckbox.setSelected(...
    onoff(get_param(portHdl,'DataLoggingDecimateData')));
javaItems.decimationEdit.setText(get_param(portHdl,'DataLoggingDecimation'));
javaItems.frameCheckbox.setSelected(...
    onoff(get_param(portHdl,'DataLoggingIndividualFrames')));

tp = onoff(get_param(portHdl,'TestPoint'));
javaItems.testPointCheckbox.setSelected(tp);

% RTW panel
javaItems.rtwSCPopup.setSelectedItem(get_param(portHdl,'RTWStorageClass'));
if javaItems.rtwSCPopup.getSelectedIndex ~= 0
  javaItems.figHdl.setSTQGroupEnabled(1);
  javaItems.rtwSTQEdit.setText(get_param(portHdl,'RTWStorageTypeQualifier'));
else
  javaItems.figHdl.setSTQGroupEnabled(0);
  javaItems.rtwSTQEdit.setText('');
end

% by default, apply button should be disabled
javaItems.apButton.setEnabled(0);

% save the figure handle into the port data
% xxx
set_param(portHdl, 'SigPropDialogHandle', figHdl);

% after finished everything, show the dialog
set(javaItems.figHdl, 'Visible', 1);

% xxx TODO looks like some library thing need to be handled here
%Locked_flag = strcmp(get_param(bdroot(BlockDiagram),'Lock'),'on');
%Linked_flag = strcmp(get_param(ParentBlock,'LinkStatus'),'implicit');

%if ( Locked_flag | Linked_flag),
%  LocalDisableGUIComponentsForLockedLibraryOrLinkedBlocks(fig);
%end,

% end UpdateFigureItems


% Function: applyAllChanges ----------------------------------------------------
% Abstract:
%   This function will perform set_param on all changed items.
%
function ApplyAllChanges(figHdl)

ud = get(figHdl, 'UserData');
portHdl = ud.portHdl;

propValPairs = {};


%
% Common setttings
%
prop = 'Name';
val  = char(figHdl.sigName.getText);
propValPairs([end+1 end+2]) = {prop, val};

if onoff(get_param(portHdl, 'EnableSigPropUI'))
  prop = 'ShowPropagatedSignals';
  val  = char(figHdl.propagatedSigPopup.getSelectedItem);
  propValPairs([end+1 end+2]) = {prop, val};
end

prop = 'Description';
val  = char(figHdl.description.getText);
propValPairs([end+1 end+2]) = {prop, val};

prop = 'DocumentLink';
val  = char(figHdl.docLink.getText);
propValPairs([end+1 end+2]) = {prop, val};

%
% Logging & accessibility tab
%
prop = 'DataLogging';
val  = onoff(figHdl.logDataCheckbox.isSelected);
propValPairs([end+1 end+2]) = {prop, val};

prop = 'DataLoggingNameMode';
idx = figHdl.logNamePopup.getSelectedIndex;
if idx == 0
  val = 'SignalName';
else
  val = 'Custom';
end
propValPairs([end+1 end+2]) = {prop, val};

prop = 'DataLoggingName';
val  = char(figHdl.logNameEdit.getText);
propValPairs([end+1 end+2]) = {prop, val};

prop = 'DataLoggingLimitDataPoints';
val  = onoff(figHdl.limitDataCheckbox.isSelected);
propValPairs([end+1 end+2]) = {prop, val};

prop = 'DataLoggingMaxPoints';
val  = char(figHdl.limitDataEdit.getText);
propValPairs([end+1 end+2]) = {prop, val};

prop = 'DataLoggingDecimateData';
val  = onoff(figHdl.decimationCheckbox.isSelected);
propValPairs([end+1 end+2]) = {prop, val};

prop = 'DataLoggingDecimation';
val  = char(figHdl.decimationEdit.getText);
propValPairs([end+1 end+2]) = {prop, val};

prop = 'DataLoggingIndividualFrames';
val  = onoff(figHdl.frameCheckbox.isSelected);
propValPairs([end+1 end+2]) = {prop, val};

prop = 'TestPoint';
val  = onoff(figHdl.testPointCheckbox.isSelected);
propValPairs([end+1 end+2]) = {prop, val};

%
% Real-Time Workshop tab
%
if onoff(get_param(0,'RTWLicensed')),
  prop = 'RTWStorageClass';
  val  = char(figHdl.rtwSCPopup.getSelectedItem);
  propValPairs([end+1 end+2]) = {prop, val};
  
  prop = 'RTWStorageTypeQualifier';
  if figHdl.rtwSCPopup.getSelectedIndex == 0
    val = '';
  else
    val = char(figHdl.rtwSTQEdit.getText);
  end
  propValPairs([end+1 end+2]) = {prop, val};
end

try,
  set_param(portHdl, propValPairs{:});
catch,
  %
  % Java eats the error message, so explicitly open NAG Controller.
  %
  slErrInfo = sllasterror;
  nagTmpl   = slsfnagctlr('NagTemplate');
  
  nagTmpl.component = 'Simulink';
  nagTmpl.type        = slErrInfo.Type;
  nagTmpl.msg.type    = slErrInfo.MessageID;
  nagTmpl.msg.summary = slErrInfo.Message;
  nagTmpl.msg.details = slErrInfo.Message;
  nagTmpl.objHandles  = slErrInfo.Handle;
  
  slsfnagctlr('Push',nagTmpl);
  slsfnagctlr('View');
end

% end ApplyAllChanges


% Function: DocumentLinkCallback -----------------------------------------------
% Abstract:
%   This will open MATLAB help window to load the document.
%
function DocumentLinkCallback(figHdl)

ud = get(figHdl, 'UserData');
portHdl = ud.portHdl;
docStr = char(ud.javaItems.docLink.getText);

if ~isempty(docStr),
  if ~isempty(findstr(docStr,'http:/')) | ...
        ~isempty(findstr(docStr,'ftp:/'))
    web(docStr);
  else
    if exist(docStr,'file')
      whichDoc = which(docStr);
      whichDoc = strrep(whichDoc,'\','/');
      web(['file:///' whichDoc]);
    else
      eval(docStr);
    end
  end
else
  warndlg('Cannot launch HTML viewer since Document link field is empty.',...
	  'Signal Properties Warning','modal');
end

% end DocumentLinkCallback


% Function: LogNamePopupChangedCallback ----------------------------------------
% Abstract:
%   This function will sychronize the data inside Variable name panel.
%
function LogNamePopupChangedCallback(figHdl);

ud = get(figHdl, 'UserData');
portHdl = ud.portHdl;

sigName = figHdl.sigName.getText;
if figHdl.logNamePopup.getSelectedIndex == 0
  figHdl.logNameEdit.setText(sigName);
else
  figHdl.logNameEdit.setText(get_param(portHdl, 'DataLoggingName'));
end

% end LogNamePopupChangedCallback


% Function: ToggleLoggingTab ---------------------------------------------------
% Abstract:
%   This function will set most of needed widgets on logging panel to disabled 
%   state during the simulation and set them back after it's done.
%   
function ToggleLoggingTab(figHdl, portHdl)

ud = get(figHdl, 'UserData');

simStatus = get_param(bdroot(get_param(portHdl,'Parent')), 'SimulationStatus');
ud.javaItems.figHdl.setLoggingTabEnabled(...
    (strcmp(simStatus,'stopped') | strcmp(simStatus,'terminating')));

%[EOF]