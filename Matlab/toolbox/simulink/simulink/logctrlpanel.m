function varargout = logctrlpanel(varargin)
%LOGCTRLPANEL Simulink external mode data logging central control panel.
%   LOGCTRPANEL creates and manages the external mode data logging control
%   panel. The first argument is always an "action" string.  The second
%   argument is always the handle to the block diagram (root level).
%
%   See also LOGCFG, LOGPANEL.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.19.2.8 $

try
  action = lower(varargin{1});

  switch(action)
 
    case 'create',
      %
      % Create the dialog. Message from Simulink.
      %
      bd = varargin{2};
   
      dlgFig = get_param(bd, 'ExtModeLogCtrlPanelDlg');
      if dlgFig ~= -1,
	i_Assert('If the dialog exists, use the ''reshow''');
      end
	  
      [dlgFig, dlgUserData] = i_CreateDlg(bd);
   
      set(dlgFig, ...
	  'UserData', dlgUserData, ...
	  'Visible',  'on');
   
      set_param(bd, 'ExtModeLogCtrlPanelDlg', dlgFig);
      
      if nargout == 1
	varargout{1} = dlgFig;
      end;

    case 'reshow'

      dlgFig = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      bd          = dlgUserData.bd;

      set(dlgFig, 'Name', i_DialogName(bd));

      i_AdjustDlgState(bd, dlgUserData);
      
      if strcmp(get(dlgFig, 'Visible'), 'on'),
	%
	% It exists and its opened.  Re-sync it and pop it to the foreground.
	%
	figure(dlgFig);
      else
	%
	% It exists, but its closed.  Re-sync it with the diagram
	% and open it.
	%
	set(dlgFig, ...
	    'Visible',     'on', ...
	    'UserData',    dlgUserData);
      end
      
    case 'trigarmed',
        %
        % Message from simulink.
        %
        % Major Assumption : There is one and only one call to this case and
        %                    that is from HandleIncomingPkt() at the end of
        %                    processing the EXT_ARM_TRIGGER_REPONSE packet.
        %                    i.e. When the Wired upInfo is ARMED
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;
        configDlg   = dlgUserData.configDlg;

        i_AdjustDlgState(bd, dlgUserData);

        %
        % If 'arm when connect' is 'on', then the 'start real-time code'
        % button should be enabled when the trigger is armed.  If the
        % 'start real-time code' button was already enabled, it doesn't
        % hurt to enable it again here.
        %
        set(dlgUserData.children.startButton, 'Enable', 'on');

        % Update the Trigger button text
        set(dlgUserData.children.armButton, 'String', 'Cancel trigger');

        if (configDlg ~= -1) & strcmp(get(configDlg, 'Visible'),'on'),
            logcfg(action, configDlg);
        end 

    case 'trigunarmed',
        %
        % Message from simulink.
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;
        configDlg   = dlgUserData.configDlg;

        i_AdjustDlgState(bd, dlgUserData);


	if (configDlg ~= -1) & strcmp(get(configDlg, 'Visible'),'on'),
            logcfg(action, configDlg);
        end 
       
    case 'connected',
        %
        % Message from simulink.
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;
        configDlg   = dlgUserData.configDlg;

        i_AdjustDlgState(bd, dlgUserData);

        if (configDlg ~= -1) & strcmp(get(configDlg, 'Visible'),'on'),
            logcfg(action, configDlg);
        end 

    case 'unconnected',
        %
        % Message from simulink.
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;
        configDlg   = dlgUserData.configDlg;

        i_AdjustDlgState(bd, dlgUserData);

        if (configDlg ~= -1) & strcmp(get(configDlg, 'Visible'),'on'),
            logcfg(action, configDlg);
        end 

    case {'targetstarted','targetstopped'},
        %
        % Message from simulink.
        %
        dlgFig      = varargin{2};
        dlgUserData = get(dlgFig, 'UserData');
        bd          = dlgUserData.bd;

        i_AdjustDlgState(bd, dlgUserData);

    case 'connect'
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      dlgUserData = i_ConnectButtonCB(dlgFig, dlgUserData);      

      set(dlgFig, 'UserData', dlgUserData);
     
    case 'start'
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      dlgUserData = i_StartButtonCB(dlgFig, dlgUserData);      
      
      set(dlgFig, 'UserData', dlgUserData);

    case 'arm'
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      dlgUserData = i_ArmButtonCB(dlgFig, dlgUserData);      
      
      set(dlgFig, 'UserData', dlgUserData);
      
    case 'floating'
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      dlgUserData = i_FloatingButtonCB(dlgFig, dlgUserData);      
      
      set(dlgFig, 'UserData', dlgUserData);
      
    case 'duration'
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      dlgUserData = i_FloatingDurationCB(dlgFig, dlgUserData);      
      
      set(dlgFig, 'UserData', dlgUserData);
      
    case 'batch'
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      dlgUserData = i_BatchCheckboxCB(dlgFig, dlgUserData);      
      
      set(dlgFig, 'UserData', dlgUserData);
      
    case 'download'
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      % 
      % Start downloading now.
      %
      set_param(dlgUserData.bd, 'SimulationCommand', 'update');
      i_UpdateChangesPendingIndicator(dlgFig, dlgUserData);
      
      set(dlgFig, 'UserData', dlgUserData);
      
    case {'extmodechangespending', 'extmodedownloaddone'},
      %
      % These are messages directly from Simulink that are not in the
      % standard format.  Pass them on to the appropriate functions.
      %
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');

      i_UpdateChangesPendingIndicator(dlgFig, dlgUserData);
      
    case 'signal'
      %
      % Invoke logcfg.m
      %
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      dlgUserData = i_SignalButtonCB(dlgUserData);      
      
      set(dlgFig, 'UserData', dlgUserData);
      
    case 'archive'
      %
      % Invoke logpanel
      %
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      
      dlgUserData = i_DataArchiveButtonCB(dlgUserData);      

      set(dlgFig, 'UserData', dlgUserData);
      
    case 'hgdeletefcn',
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      bd          = dlgUserData.bd;

      configDlg   = dlgUserData.configDlg;
      archiveDlg  = dlgUserData.archiveDlg;
      
      %
      % Delete the configuration dialog - if it exists.  Note that this
      % triggers the configuration dialogs deletefcn to be called.  This
      % in turn calls back into this function with the 'configdeleted'
      % action (see below).  This action updates the user data of the
      % figure.
      %
      if configDlg ~= -1,
	delete(configDlg);
      end
      if archiveDlg ~= -1,
	delete(archiveDlg);
      end
      
      delete(dlgFig);
      
      %
      % Now tell the bd that we've disappeared (if it still exists).
      % If this occurs due to the bd getting deleted, the the bd's
      % handle is already invalid when we get to here.
      %
      errMsg = [];
      try
	find_system(bd);
      catch
	errMsg = lasterr;
      end
      
      if isempty(errMsg)
	set_param(bd, 'ExtModeLogCtrlPanelDlg', -1);
      end

    case 'subfigdeleted'
      %
      % Inform this control panel if any of those three sub-figures is
      % deleted. 
      %
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      subfigName  = varargin{3};
      
      switch subfigName
	
	case 'config'
	  dlgUserData.configDlg = -1;
	case 'logpanel'
	  dlgUserData.archiveDlg = -1;
	otherwise
	  % Error handling to prevent this functions from being called
	  % incorrectly. 
	  i_Assert('Unrecognized action in sub-figure deleted function.');
	  
      end
      set(dlgFig, 'UserData', dlgUserData);
    
    case 'hgclosereqfcn'
        
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      i_CloseReqCB(dlgFig, dlgUserData);
      
    case 'changename'
      %==================================================================
      % Message from Simulink that the bd has changed names.
      %==================================================================
      dlgFig      = varargin{2};
      dlgUserData = get(dlgFig, 'UserData');
      bd          = dlgUserData.bd;
      configDlg   = dlgUserData.configDlg;
      archiveDlg  = dlgUserData.archiveDlg;
      
      set(dlgFig, 'Name', i_DialogName(bd));
      
      if configDlg ~= -1
	logcfg('ChangeName', bd, dlgUserData.configDlg);
      end
      if archiveDlg ~= -1
	logpanel('ChangeName', bd, dlgUserData.archiveDlg);
      end
      
    otherwise,
      i_Assert('Unrecognized action in main entry point.');

  end %action switch

catch
  
  if nargout == 1
 
    if ishandle(dlgFig)
      delete(dlgFig);
    end
 
    varargout = {-1};
  end
  errordlg(lasterr, 'Error in external mode control panel', 'modal');

end


% Function: i_Assert ===========================================================
% Abstract:
%      Mimicks a c assertion by throwing an error if asserts are active.
%
function i_Assert(str),

error(['M Assert: ' str]);


% Function: i_CreateDlg ========================================================
% Abstract:
%      Create the external mode logging control panel.
%
function [dlgFig, dlgUserData] = i_CreateDlg(bd)

%
% Create constants based upon current computer & cache in user data
%
dlgUserData.fontsize = get(0, 'FactoryUicontrolFontSize');
dlgUserData.fontname = get(0, 'FactoryUicontrolFontName');

%
% Create an empty figure & invisible text object for text sizing.
%
figColor      = get(0, 'FactoryUiControlBackGroundColor');
hgclosereqfcn = 'logctrlpanel(''hgclosereqfcn'', gcbf)';
hgdeletefcn   = 'logctrlpanel(''hgdeletefcn'', gcbf)';

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
    'Parent',    dlgFig, ...
    'Visible',   'off', ...
    'Style',     'text', ...
    'Units',     'characters');

%
% Create geometry constants.
%
sysOffsets = sluigeom('character');
geom       = i_CreateGeom(sysOffsets, dlgUserData);

%
% Calculate figure position.
%
figWidth  = geom.wBox + 3 * geom.sideEdgeBuffer;
figHeight = ...
    geom.figTopEdgeBuffer  + ...
    geom.hConnectionBox + ...
    geom.boxSeparator + ...
    geom.hFloatingBox + ...
    geom.rowSpace   + ...
    geom.hText + ...
    geom.rowSpace   + ...
    geom.hText + ...
    geom.rowSpace + ...
    geom.hCheckbox + ...
    geom.rowSpace + ...
    max([geom.hButton geom.hText]) + ...
    geom.rowSpace + ...
    geom.hText + ...
    geom.rowSpace + ...
    geom.rowSpace + ...
    geom.rowSpace + ...
    geom.hSysButton + ...
    geom.figBottomEdgeBuffer;

figPos = get(dlgFig,'Position');
figPos([3 4]) = [figWidth figHeight];
set(dlgFig, 'Position', figPos);

%
% Calculate the position of each control.
%
ctrlPos = i_CtrlPos(geom,figPos);

%
% Create control objects.
%
dlgUserData.children = i_CreateCtrls(dlgFig, ctrlPos, dlgUserData, geom);

dlgUserData.configDlg  = -1;
dlgUserData.archiveDlg = -1;

%
% Install callbacks
%
i_InstallCallbacks(bd, dlgUserData);

%
% Synchronize settings with model. 
%
i_AdjustDlgState(bd, dlgUserData);

%
% Cache remaining info in dlgUserData.
%
dlgUserData.bd = bd;

% end of i_CreateDlg


% Function: i_InstallCallbacks =================================================
% Abstract:
%      Install callbacks for the uicontrols.
%
function i_InstallCallbacks(bd, dlgUserData),

children = dlgUserData.children;

%
% Connect button
%
cb = 'logctrlpanel(''connect'', gcbf)';
set(children.connectButton, 'Callback', cb);

%
% Start real-time code button
%
cb = 'logctrlpanel(''start'', gcbf)';
set(children.startButton, 'Callback', cb);

%
% Arm button
%
cb = 'logctrlpanel(''arm'', gcbf)';
set(children.armButton, 'Callback', cb);

%
% Floating button
%
cb = 'logctrlpanel(''floating'', gcbf)';
set(children.floatingButton, 'Callback', cb);

%
% Floating duration edit field
%
cb = 'logctrlpanel(''duration'', gcbf)';
set(children.floatingDurationEdit, 'Callback', cb);

%
% Batch download checkbox
%
cb = 'logctrlpanel(''batch'', gcbf)';
set(children.batchCheckbox, 'Callback', cb);

%
% Download button
%
cb = 'logctrlpanel(''download'', gcbf)';
set(children.downloadButton, 'Callback', cb);

%
% Signal & triggering button
%
cb = 'logctrlpanel(''signal'', gcbf)';
set(children.signalButton, 'Callback', cb);

%
% Data archive button
%
cb = 'logctrlpanel(''archive'', gcbf)';
set(children.archiveButton, 'Callback', cb);

%
% Close button
%
cb = 'logctrlpanel(''hgclosereqfcn'', gcbf)';
set(children.closeButton, 'Callback', cb);

% end of i_InstallCallbacks

% Function: i_AdjustDlgState ===================================================
% Abstract:
%      Adjust the enable state for the entire dialog.
%
function i_AdjustDlgState(bd, dlgUserData)

children = dlgUserData.children;

set(children.batchCheckbox, ...
    'Value',    onoff(get_param(bd, 'ExtModeBatchMode')) ...
    );

set(children.floatingButton, ...
    'Value',    onoff(get_param(bd, 'ExtModeEnableFloating')) ...
    );

floatingDuration = get_param(bd, 'ExtModeTrigDurationFloating');
set(children.floatingDurationEdit, 'String', floatingDuration);

if isempty ( get_param(bd, 'ExtModeMexFile') )
  %
  % When RTW Options MEX-File has not been defined, all
  % buttons are disabled. This is also the default state.
  %
  set(children.startButton, 'String', 'Start Real-Time Code');
  set(children.armButton,   'String', 'Arm Trigger');
  
  offHandles = [
    children.connectButton
    children.startButton
    children.armButton
    children.downloadButton
    children.signalButton
    children.archiveButton];
  
  set(offHandles, 'Enable', 'off');

else
  %
  % When RTW Options MEX-File has been defined, we will have
  % 'connect', 'signal & triggering' and 'data archiving' buttons enabled. 
  %
  onHandles = [
    children.connectButton
    children.signalButton
    children.archiveButton];
  
  set(onHandles, 'Enable', 'on');

  if strcmp(get_param(bd, 'ExtModeConnected'), 'on')

    %
    % When target has been connected, we will have 'start real-time code'
    % and 'Arm/Cancel trigger' buttons enabled so that you can start to run
    % and/or Arm/Cancel the trigger.  The 'start real-time code' will only
    % be enabled if there is no data to upload, 'arm when connect' is 'off',
    % or 'arm when connect' is 'on' and the trigger is not 'inactive'.
    %
    i_ExtModeConnected(bd, children);
      
    upStatus = get_param(bd, 'ExtModeUploadStatus'); 
    
    if strcmp(upStatus, 'armed') | strcmp(upStatus, 'uploading'),
      set(children.armButton, 'String', 'Cancel trigger');
    else,
      set(children.armButton, 'String', 'Arm Trigger');
    end
    
  elseif strcmp(get_param(bd, 'ExtModeConnected'), 'off')
    %
    % When target is not connected, 'Connect' button will show 'Connect'.
    %
    i_ExtModeUnconnected(bd, children);
    
  else
    %
    % When any error occurs and connection failed, keep the states as they
    % were. Do nothing. The error was handled by C source code. 
    %
  end

end

% end of i_AdjustDlgState


% Function: i_ExtModeUnconnected ===============================================
% Abstract:
%      Update the dialog status when target is disconnected
%
function i_ExtModeUnconnected(bd, children)

set(children.connectButton, 'String', 'Connect');
set(children.startButton,   ...
    'Enable', 'off', ...
    'String', 'Start Real-Time Code');
set(children.armButton,     ...
    'Enable', 'off', ...
    'String', 'Arm Trigger');

set(children.floatingDurationEdit, 'Enable', 'on');
%end of i_ExtModeUnconnected


% Function: i_ExtModeConnected =================================================
% Abstract:
%      Update the dialog status when target is connected
%
function i_ExtModeConnected(bd, children)

set(children.connectButton, 'String', 'Disconnect');
set(children.armButton,     'Enable', 'on');
if get_param(bd, 'ExtModeStartButtonEnabled') == 1
   set(children.startButton, 'Enable', 'on');
end

%
% update the start real-time code button
%
if strcmp(get_param(bd, 'ExtModeConnected'), 'off')
  %
  % get_param(model, 'ExtModeTargetSimStatus') doesn't have a associated
  % create_block_diagram_params and destroy function. It can be only called 
  % when the model is there and is in External mode and is connected to the
  % target already. Otherwise it will make seg-v's. Consult Jun or Howie 
  % for this. 
  %
  i_Assert('Connect to the target before start the real-time code.');
else

  %
  % Control the real-time code start/stop status.
  %
  switch(get_param(bd, 'ExtModeTargetSimStatus')),
    
   case {'running','startPending'},
    i_ExtModeStartRealTimeCode(children, 'running');
   case 'waitingToStart',
    i_ExtModeStartRealTimeCode(children, 'waiting');
   otherwise,
    i_Assert('Unexpected target simtatus');
  end
  
  % If we "armed on connect" the floating scopes, disable the duration
  if strcmp(get_param(bd, 'ExtModeEnableFloating'), 'on'),
    set(children.floatingDurationEdit, 'Enable','off');
  end
  
end

% end of i_ExtModeConnected


% Function: i_ExtModeStartRealTimeCode =========================================
% Abstract:
%      Adjust 'start real-time code' button's status
%
function i_ExtModeStartRealTimeCode(children, status)

switch status

  case 'running'
    set(children.startButton, 'String', 'Stop Real-Time Code');
  case 'waiting'
    set(children.startButton, 'String', 'Start Real-Time Code');
  otherwise
    i_Assert('Invalid command to ''Start Real-Time Code'' button.');
end

%end of i_ExtModeStartRealTimeCode


% Function: i_SignalButtonCB ===================================================
% Abstract:
%      Callback functions for signal&triggering button.
%
function dlgUserData = i_SignalButtonCB(dlgUserData)

bd = dlgUserData.bd;

if dlgUserData.configDlg == -1
  %
  % Create the configuration dialog
  %
  dlgUserData.configDlg = logcfg('create', bd, dlgUserData.configDlg);

else
  %
  % logcfg exists, re-show it. If it's visible (opened), just bring it to the
  % foreground. If it is not visible (closed), it is refreshed with the model
  % settings and displayed.
  %
  logcfg('reshow', dlgUserData.configDlg);
  
end

% end of i_SignalButtonCB


% Function: i_DataArchiveButtonCB ==============================================
% Abstract:
%      Callback functions for data archive button.
%
function dlgUserData = i_DataArchiveButtonCB(dlgUserData)

bd         = dlgUserData.bd;
archiveDlg = dlgUserData.archiveDlg;

if archiveDlg == -1
  %
  % Create the data archiving dialog
  %
  archiveDlg = logpanel('create', bd, archiveDlg);

else
  %
  % logpanel exists, re-show it. If it's visible (opened), just bring it to the
  % foreground. If it is not visible (closed), it is refreshed with the model
  % settings and displayed.
  %
  logpanel('reshow', archiveDlg);

end

dlgUserData.archiveDlg = archiveDlg;

% end of i_DataArchiveButtonCB


% Function: i_CloseReqCB =======================================================
% Abstract: 
%      Handle callback from the close button.
%
function i_CloseReqCB(dlgFig, dlgUserData),

bd          = dlgUserData.bd;
configDlg   = dlgUserData.configDlg;
archiveDlg  = dlgUserData.archiveDlg;

%
% Delete the configuration dialog - if it exists.  Note that this
% triggers the configuration dialogs deletefcn to be called.  This
% in turn calls back into this function with the 'configdeleted'
% action (see below).  This action updates the user data of the
% figure.
%
if configDlg ~= -1,
  set(configDlg, 'Visible', 'off');
end
if archiveDlg ~= -1,
  set(archiveDlg, 'Visible', 'off');
end

set(dlgFig, 'visible', 'off');

% end of i_CloseReqCB

% Function: i_ConnectButtonCB ==================================================
% Abstract:
%      Callback function for 'Connect/Disconnect' button.
%
function dlgUserData = i_ConnectButtonCB(dlgFig, dlgUserData)

children = dlgUserData.children;
bd       = dlgUserData.bd;

if ~strcmp(get_param(bd, 'SimulationMode'), 'external')
  set_param(bd, 'SimulationMode', 'External');
end
  
if strcmp(get(children.connectButton, 'String'), 'Connect') & ...
      strcmp(get(children.connectButton, 'Enable'), 'on')
  
  set_param(bd, 'SimulationCommand', 'connect');

  %
  % update the Arm trigger button
  %
  if strcmp(get_param(bd, 'ExtModeArmWhenConnect'), 'on')
    set(children.armButton, 'String', 'Cancel trigger');
  end

else
  %
  % Set the connect button back to 'Connect' state.
  %
  set_param(bd, 'SimulationCommand', 'disconnect');
  
end

%
% Call the main states update function
%
i_AdjustDlgState(bd, dlgUserData);

%end of i_ConnectButtonCB


% Function: i_StartButtonCB ====================================================
% Abstract:
%      Callback function for 'Start/Stop real-time code' button.
%
function dlgUserData = i_StartButtonCB(dlgFig, dlgUserData)

children = dlgUserData.children;
bd       = dlgUserData.bd;
rtcstr   = 'Real-Time Code';

if strcmp(get(children.startButton, 'String'), ['Start ' rtcstr]) & ...
      strcmp(get(children.startButton, 'Enable'), 'on')
  %
  % Set the start button back to 'stop'(running state).
  %
  set_param(bd, 'SimulationCommand', 'start');
else
  %
  % Set the start button back to 'start'(ready state).
  %
  set_param(bd, 'SimulationCommand', 'stop');
end

%end of i_StartButtonCB


% Function: i_ArmButtonCB ======================================================
% Abstract:
%      Callback function for 'Arm/Cancel trigger' button.
%
function dlgUserData = i_ArmButtonCB(dlgFig, dlgUserData)

children = dlgUserData.children;
bd       = dlgUserData.bd;

if strcmp(get(children.armButton, 'String'), 'Arm Trigger') & ...
      strcmp(get(children.armButton, 'Enable'), 'on')
  %
  % Set the arm button back to 'Cancel trigger' state.
  %
  set(children.armButton, 'String', 'Cancel trigger');
  set_param(bd, 'ExtModeCommand', 'armWired');
  
elseif strcmp(get(children.armButton, 'String'), 'Cancel trigger') & ...
      strcmp(get(children.armButton, 'Enable'), 'on')
  %
  % Set the arm button back to 'arm' state.
  %
  set(children.armButton, 'String', 'Arm Trigger');
  set_param(bd, 'ExtModeCommand', 'cancelWired');
  
else
  i_Assert('Invalid action on Arm/Cancel button.');
end

%
% Call the main states update function
%
i_AdjustDlgState(bd, dlgUserData);

%end of i_ArmButtonCB

% Function: i_BatchCheckboxCB ==================================================
% Abstract:
%      Callback function for the batch download checkbox.
%
function dlgUserData = i_BatchCheckboxCB(dlgFig, dlgUserData)

children = dlgUserData.children;
bd       = dlgUserData.bd;

val = get(children.batchCheckbox, 'Value');

set_param(bd, 'ExtModeBatchMode', onoff(val));

if val 
  set(children.downloadButton, 'Enable', 'on');
else
  set(children.downloadButton, 'Enable', 'off');
end

dlgUserData.children = children;

%
% Call the main states update function
%
i_AdjustDlgState(bd, dlgUserData);

%end of i_BatchCheckboxCB

% Function: i_FloatingButtonCB =================================================
% Abstract:
%      Callback function for the floating checkbox.
%
function dlgUserData = i_FloatingButtonCB(dlgFig, dlgUserData)

children = dlgUserData.children;
bd       = dlgUserData.bd;

val = get(children.floatingButton, 'Value');

% Set the flag
set_param(bd, 'ExtModeEnableFloating', onoff(val));

% Send ExtModeCommand only if connected
connected = onoff(get_param(bd, 'ExtModeConnected'));

if ~connected, return; end

% Enable/disable the duration field
if val,
  set(children.floatingDurationEdit, 'Enable', 'off');
  set_param(bd, 'ExtModeCommand', 'armFloating');
else,
  set_param(bd, 'ExtModeCommand', 'cancelFloating');  
  set(children.floatingDurationEdit, 'Enable', 'on');
end

%end of i_FloatingButtonCB

% Function: i_FloatingDurationCB ==============================================
% Abstract:
%      Callback function for the floating duration edit field.
%
function dlgUserData = i_FloatingDurationCB(dlgFig, dlgUserData)

children = dlgUserData.children;
bd       = dlgUserData.bd;

string = get(children.floatingDurationEdit, 'String');

if ( ~strcmpi(string, 'auto') & evalin('base', string) <= 0 ),
  i_Assert('Duration must be a positive integer');
else,
  set_param(bd, 'ExtModeTrigDurationFloating', string);
end

%end of i_FloatingDurationCB


% Function: i_UpdateChangesPendingIndicator ====================================
% Abstract:
%      Manage param changes pending indicator for external mode.
%
function i_UpdateChangesPendingIndicator(dlgFig, dlgUserData)

children  = dlgUserData.children;
bd        = dlgUserData.bd;
indicator = children.downloadText;

changesPending = onoff( ...
    get_param(bd, 'ExtModeChangesPending') ...
    );

if (changesPending)
  set(indicator, 'Enable', 'on', ...
      'String', 'Parameter changes pending .....');
else,
  set(indicator, 'Enable', 'off', 'String', '');
  
  val = get(children.batchCheckbox, 'Value');
  if val == 1
    set(children.downloadButton, 'Enable', 'on');
  else
    set(children.downloadButton, 'Enable', 'off');
  end
  
end

%end of i_UpdateChangesPendingIndicator


% Function: i_CreateCtrls ======================================================
% Abstract:
%      Create the uicontrols in the specified locations.
%
function children = i_CreateCtrls(dlgFig, ctrlPos, dlgUserData, geom)

  
textExtent = uicontrol( ...
    'Parent',     dlgFig, ...
    'Visible',    'off', ...
    'Style',      'text', ...
    'FontSize',   dlgUserData.fontsize, ...
    'FontName',   dlgUserData.fontname ...
    );

%
% Connection and triggering group box
%
children.ConnectionsGroupBox = groupbox(...
    dlgFig,...
    ctrlPos.connectionBox, ...
    [' ',xlate('Connection and triggering'),' '], ...
    textExtent ...
    );
%
% Connect/Disconnect button
%
children.connectButton = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'pushbutton', ...
    'String',              'Connect', ...
    'Enable',              'off', ...
    'Horizontalalign',     'center', ...
    'Position',            ctrlPos.connectButton, ...
    'Tooltip',             '' ...
    );
 
%
% Start/Stop real-time code button
%
children.startButton = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'pushbutton', ...
    'Enable',              'off', ...
    'Horizontalalign',     'center', ...
    'String',              'Start Real-Time Code', ...
    'Position',            ctrlPos.startButton, ...
    'Tooltip',             '' ...
    );

%
% Arm/Cancel trigger button 
%
children.armButton = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'pushbutton', ...
    'Enable',              'off', ...
    'Horizontalalign',     'center', ...
    'String',              'Arm Trigger', ...
    'Position',            ctrlPos.armButton, ...
    'Tooltip',             '' ...
    );

%
% Floating scope group box
%
children.FloatingGroupBox = groupbox(...
    dlgFig,...
    ctrlPos.floatingBox, ...
    [' ',xlate('Floating scope'), ' '] ,...
    textExtent ...
    );
%
% Floating scope button
%
children.floatingButton = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'checkbox', ...
    'Enable',              'on', ...
    'String',              xlate('Enable data uploading'), ...
    'Position',            ctrlPos.floatingButton, ...
    'Tooltip',             '' ...
    );

%
% text 'Duration for floating scopes' 
%
children.floatingDurationText = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'text', ...
    'Horizontalalign',     'center', ...
    'String',              [xlate('Duration'),' :'], ...
    'Position',            ctrlPos.floatingDurationText, ...
    'Tooltip',             '' ...
    );

%
% Floating duration text edit field
%
children.floatingDurationEdit = uicontrol( ...
    'Parent',             dlgFig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.floatingDurationEdit, ...
    'BackGroundColor',    'w' ...
    );

%
% Parameter tuning group box
%
children.ParameterTuningGroupBox = groupbox(...
    dlgFig,...
    ctrlPos.paramBox, ...
    [' ', xlate('Parameter tuning'), ' '], ...
    textExtent ...
    );

%
% batch download checkbox
%
children.batchCheckbox = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'checkbox', ...
    'Enable',              'on', ...
    'String',              'Batch download', ...
    'Position',            ctrlPos.batchCheckbox, ...
    'Tooltip',             '' ...
    );

%
% download button
%
children.downloadButton = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'pushbutton', ...
    'Enable',              'off', ...
    'Horizontalalign',     'center', ...
    'String',              'Download', ...
    'Position',            ctrlPos.downloadButton, ...
    'Tooltip',             '' ...
    );

%
% downloading status display
%
children.downloadText = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'text', ...
    'Enable',              'off', ...
    'String',              '', ...
    'ForegroundColor',     'blue', ...
    'Position',            ctrlPos.downloadText, ...
    'Tooltip',             '' ...
    );

%
% Configuration group box
%
children.ConfigurationGroupBox = groupbox(...
    dlgFig, ...
    ctrlPos.configBox, ...
    [' ', xlate('Configuration'), ' '], ...
    textExtent ...
    );

%
% 'Signal & Triggering' button
%
children.signalButton = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'pushbutton', ...
    'Enable',              'off', ...
    'Horizontalalign',     'center', ...
    'String',              'Signal & Triggering ...', ...
    'Position',            ctrlPos.signalButton, ...
    'Interruptible',       'off', ...
    'BusyAction',          'cancel', ...
    'Tooltip',             '');

%
% 'Data Archiving' button
%
children.archiveButton = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'pushbutton', ...
    'Enable',              'off', ...
    'Horizontalalign',     'center', ...
    'String',              'Data Archiving ...', ...
    'Position',            ctrlPos.archiveButton, ...
    'Tooltip',             '' ...
    );

%
% close button
%
children.closeButton = uicontrol( ...
    'Parent',              dlgFig, ...
    'Style',               'pushbutton', ...
    'Horizontalalign',     'center', ...
    'String',              'Close', ...
    'Position',            ctrlPos.closeButton, ...
    'Tooltip',             '' ...
    );

%end of i_CreateCtrls


% Function: i_CtrlPos ==========================================================
% Abstract:
%      Calculate the position for every control object.
%
% There are 24 objects, including 5 parts.
% --------- Description --------------------- variable name --------
%  First group, general area (4):
%    (1) Connect/Disconnect button ---------- connectButton
%    (2) Start/Stop real-time code button --- startButton
%    (3) Arm/Cancel trigger button ---------- armButton
%    (4) box -------------------------------- topBox
%  Second group, floating scopes area (7):
%    (5) separate bar ----------------------- floatingBar 
%    (6) box -------------------------------- floatingBox
%    (7) text 'Floating scope' -------------- floatingText
%    (8) Enable floating scopes checkbox ---- floatingButton
%    (9) Floating duration edit text -------- floatingDurationText
%    (10) Floating duration edit field ------ floatingDurationEdit
%  Third group, parameter tuning area (6):
%    (11) separate bar----------------------- paramBar 
%    (12) text 'Parameter tuning' ----------- paramText
%    (13) batch download checkbox ----------- batchCheckbox
%    (14) download button ------------------- downloadButton
%    (15) downloading status display -------- downloadText
%  Fourth group, configuration area (5):
%    (16) separate bar ---------------------- configBar
%    (17) text 'Configuration' -------------- configText
%    (18) 'Signal & Triggering' button ------ signalButton
%    (19) 'Data Archiving' button ----------- archiveButton
%    (20) box ------------------------------- configBox
%  Fifth group, system area (4):
%    (21) separate bar ---------------------- bottomBar
%    (22) text 'Status:' -------------------- statusText
%    (23) status displaying area ------------ statusEdit
%    (24) close button ---------------------- closeButton
%
function ctrlPos = i_CtrlPos(geom, figPos)

%
% General area -----------------------------------------------------------------
%
%
% --- Connection box ----
%
cxCur = 1.5 * geom.sideEdgeBuffer;
cyCur = figPos(4) - geom.figTopEdgeBuffer - geom.hConnectionBox;

ctrlPos.connectionBox = [cxCur cyCur geom.wBox geom.hConnectionBox];

%
% Connect/Disconnect button
%
cxCur = cxCur + geom.sideEdgeBuffer;
cyCur = cyCur + 2*geom.boxBottomEdgeBuffer;

ctrlPos.connectButton = [cxCur cyCur geom.wConnectButton geom.hTwoLineButton];

%
% Start/Stop real-time code button
%
cxCur = cxCur + geom.wConnectButton + geom.buttonDelta;

ctrlPos.startButton = [cxCur cyCur geom.wStartButton geom.hTwoLineButton];

%
% Arm/Cancel trigger button 
%
cxCur = cxCur + geom.wStartButton + geom.buttonDelta;

ctrlPos.armButton = [cxCur cyCur geom.wArmButton geom.hTwoLineButton];

%
% --- floating box ---
%
cxCur = 1.5 * geom.sideEdgeBuffer;
cyCur = cyCur - geom.hConnectionBox - 6*geom.boxBottomEdgeBuffer;

ctrlPos.floatingBox = [cxCur cyCur geom.wBox geom.hFloatingBox];

%
% floating button
%
cxCur = cxCur + geom.sideEdgeBuffer;
cyCur = cyCur + 6*geom.boxBottomEdgeBuffer;

ctrlPos.floatingButton = [cxCur cyCur geom.wFloating geom.hCheckbox];

%
% text 'Duration :'
%
cyCur = cyCur - geom.rowSpace - 1.2*geom.hEdit;

ctrlPos.floatingDurationText = [cxCur cyCur ...
                    geom.wFloatingDurationText geom.hText];
    
%
% Floating duration edit field
%
cxCur = cxCur + geom.wFloatingDurationText;

ctrlPos.floatingDurationEdit = [cxCur cyCur ...
                    geom.wFloatingDurationEdit geom.hEdit];

cyCur = cyCur + 0.2*geom.hEdit;

%
% --- Parameter tuning box ---
%
cxCur = 1.5 * geom.sideEdgeBuffer;
cyCur = cyCur - geom.hFloatingBox - 4*geom.boxBottomEdgeBuffer;

ctrlPos.paramBox = [cxCur cyCur geom.wBox geom.hParamBox];
    
%
% batch download checkbox
%
cxCur = cxCur + geom.sideEdgeBuffer;
cyCur = cyCur + 6*geom.boxBottomEdgeBuffer;

ctrlPos.batchCheckbox = [cxCur cyCur geom.wBatchCheckbox geom.hCheckbox];
    
%
% download button
%
cyCur = cyCur - geom.rowSpace - 1.2*geom.hButton;

ctrlPos.downloadButton = [cxCur cyCur geom.wDownloadButton 1.2*geom.hButton];
 
%
% downloading status display
%
cxCur = cxCur + geom.wDownloadButton + geom.buttonDelta;

ctrlPos.downloadText = [cxCur cyCur geom.wDownloadText 1.2*geom.hText];
 
%
% --- configuration box ---
%
cxCur = 1.5 * geom.sideEdgeBuffer;
cyCur = cyCur - geom.hParamBox - geom.boxBottomEdgeBuffer;

ctrlPos.configBox = [cxCur cyCur geom.wBox geom.hConfigBox];

%
% 'Signal & Triggering' button
%
cxCur = cxCur + geom.sideEdgeBuffer;
cyCur = cyCur + 2*geom.boxBottomEdgeBuffer;

ctrlPos.signalButton = [cxCur cyCur geom.wSignalButton geom.hTwoLineButton];
 
%
% 'Data Archiving' button
%
cxCur = cxCur + geom.wSignalButton + geom.buttonDelta;

ctrlPos.archiveButton = [cxCur cyCur geom.wArchiveButton geom.hTwoLineButton];

%
% close button
%
cxCur = figPos(3) - 2*geom.sideEdgeBuffer - geom.wSysButton;
cyCur = cyCur - 0.75*geom.hConfigBox;

ctrlPos.closeButton = [cxCur cyCur geom.wSysButton geom.hSysButton];

%end of i_CtrlPos


% Function: i_CreateGeom =======================================================
% Abstract:
%      Create the geomerty constants for construction of the dialog.  Note
%      that these are the minimun size requirements.  Some controls may be
%      stretched to improve appearance (e.g., line the right edges up).
%
function geom = i_CreateGeom(sysOffsets, dlgUserData),

%
% NOTE: These values should be consistent with those in
%       logcfg.m.
%

%
% General geometry data
%
geom.hText                 = 1   + sysOffsets.text(4);
geom.hEdit                 = 1   + sysOffsets.edit(4);
geom.hButton               = 1   + sysOffsets.pushbutton(4);
geom.hCheckbox             = 1   + sysOffsets.checkbox(4);
geom.wSysButton            = 7.5 + sysOffsets.pushbutton(3);
geom.hSysButton            = 1.1 + sysOffsets.pushbutton(4);
geom.buttonDelta           = 3;

geom.figTopEdgeBuffer      = 1;
geom.figBottomEdgeBuffer   = 1;
geom.boxTopEdgeBuffer    = (geom.hText/1.8);
geom.boxBottomEdgeBuffer = 0.5;
geom.sideEdgeBuffer        = 1.5;
geom.rowSpace              = 0.5;
geom.boxSeparator          = 2;

%
% First group geom data
%
geom.wStartButton   = length('Signal & Triggering ...');
geom.wConnectButton = geom.wStartButton;
geom.wArmButton     = geom.wStartButton;
geom.hTwoLineButton = 1.2 + 2 * sysOffsets.pushbutton(4);
geom.hConnectionBox = 4*geom.boxBottomEdgeBuffer + geom.hTwoLineButton;
geom.hFloatingBox   = 6*geom.boxBottomEdgeBuffer + geom.hTwoLineButton;
geom.hParamBox      = 6*geom.boxBottomEdgeBuffer + geom.hTwoLineButton;
geom.hConfigBox     = 4*geom.boxBottomEdgeBuffer + geom.hTwoLineButton;
geom.wBox         = ...
    2 * geom.sideEdgeBuffer + ...
    3 * geom.wStartButton   + ...
    2 * geom.buttonDelta;
geom.wFloating      = ...
    length('Enable data uploading__') + sysOffsets.checkbox(3);
geom.wFloatingDurationText = length('Duration :_');
geom.wFloatingDurationEdit = length('10000000000_');

%
% Second group geom data
%
geom.wParamText      = length('_Parameter tuning_');
geom.wBatchCheckbox  = length('Batch download__') + sysOffsets.checkbox(3);
geom.wDownloadButton = geom.wBatchCheckbox;
geom.wDownloadText   = length('_Parameter changes pending .....__');

%
% Third group geom data
%
geom.wSignalButton  = geom.wStartButton+13;
geom.wArchiveButton = geom.wSignalButton;

%
% Status display area geom data
%
geom.wStatusText = length('Status:_');
geom.wStatusEdit = ...
    geom.wBox - geom.wStatusText - ...
    2*geom.buttonDelta - geom.wSysButton;

%end of i_CreateGeom


% Function: i_DialogName =======================================================
% Abstract:
%      Get the name for the dialog box.
%
function figName = i_DialogName(bd),

figName = [get_param(bd, 'Name') ': ',xlate('External Mode Control Panel')];

