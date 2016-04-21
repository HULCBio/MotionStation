function varargout = embedded_target_download(varargin)
%   EMBEDDED_TARGET_DOWNLOAD Download files to an embedded target over a communication link.
%
%   EMBEDDED_TARGET_DOWNLOAD launches the Download Control Panel GUI that allows files to be downloaded
%   to the target (eg. MPC555) over a communication link (eg. CAN, Serial).
%
%   EMBEDDED_TARGET_DOWNLOAD FORCE completely resets and re-launches the Download Control
%   Panel GUI.   Use this option only if the GUI cannot be raised by calling 
%   EMBEDDED_TARGET_DOWNLOAD with no arguments.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%   $Date: 2004/04/29 03:40:01 $

persistent StandaloneMPC555Control Listener

if (nargin == 0) 
    % end user case - launch the GUI
    if (isempty(StandaloneMPC555Control))
        % create GUI
        [StandaloneMPC555Control, Listener] = i_creategui;
        StandaloneMPC555Control.show;
    else
        % bring existing GUI to the front
        i_bringToFront(StandaloneMPC555Control);
    end;
else 
    % MathWorks internal options...
    % process varargin
    action = varargin{1};
    switch (lower(action))
    case 'clearpersistentvariables'
        % clear the persistent variables to allow
        % a new GUI to be created
        clear Listener;
        clear StandaloneMPC555Control;
    case 'commandline'
        % commandline usage
        if (isempty(StandaloneMPC555Control))
            % create GUI
            [StandaloneMPC555Control, Listener] = i_creategui;
        else 
            % hide any existing GUI!
            StandaloneMPC555Control.hide;
        end;
    case 'hidegui'
        % hide the gui
        if (i_guiIsInitialised(StandaloneMPC555Control))
            StandaloneMPC555Control.hide;
        end;
    case 'showgui'
        % show the gui
        if (i_guiIsInitialised(StandaloneMPC555Control))
            StandaloneMPC555Control.show;
        end;
    case 'startdownload'
        % commence the download programmatically
        if (i_guiIsInitialised(StandaloneMPC555Control))
            StandaloneMPC555Control.startDownloadAndWait;
        end;
    case 'force'
        % clear any existing download GUI state
        % and launch a new one
        if (~isempty(StandaloneMPC555Control))
            embedded_target_download('hidegui');
        end;
        embedded_target_download('clearPersistentVariables');
        embedded_target_download;
    case 'set'
        % set Download options
        if (i_guiIsInitialised(StandaloneMPC555Control))
            if (ischar(varargin{3}))
                % set string variable
                eval(['StandaloneMPC555Control.set' varargin{2} '(''' varargin{3} ''');']);
            else
                % set numeric variable
                eval(['StandaloneMPC555Control.set' varargin{2} '(' num2str(varargin{3}) ');']);
            end;
        end;
    case 'status'
        if isempty(StandaloneMPC555Control)
            varargout = { 'idle' };
        elseif StandaloneMPC555Control.isDownloading
            varargout = { 'downloading' };
        else
            varargout = { 'idle' };
        end
    otherwise
        disp(['Unknown action ' action]);
    end;
end;
  
function init = i_guiIsInitialised(javahandle)
    if (isempty(javahandle))
        % Java GUI has not been initialised
        disp('Error: The Download Control Panel GUI has not been correctly initialised.');
        disp('The Download Control Panel GUI may be initialised by any of the following:');
        disp('embedded_target_download, embedded_target_download(''force''), embedded_target_download(''commandline'')');
        init = 0;
    else
        init = 1;
    end;
return;

function i_bringToFront(javahandle)
    % bring existing GUI to the front
    javahandle.toFront;
return;

function [javahandle, listener] = i_creategui
    % instead of the MATLAB work dir, use the current dir
    % as the work dir
    work_dir_path = pwd;
    % need to provide the path to matlab/toolbox/rtw/targets so that
    % the download code can find the appropriate bootcodeversion.txt file
    bootverpath = fullfile(matlabroot, 'toolbox', 'rtw', 'targets', '');
    % create the java object and store a handle to it.
    StandaloneMPC555Controljava = com.mathworks.toolbox.ecoder.canlib.CanDownload.StandaloneMPC555Control...
        (com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame.getIconImage,...
        work_dir_path,...
        bootverpath,...
        0);
    
    javahandle = handle(StandaloneMPC555Controljava,'callbackproperties');
    
    % use the @cancommon/@candownloadprefs preferences to 
    % initialise the GUI
    prefs = RTW.TargetPrefs.load('cancommon.candownloadprefs');
     
    javahandle.setCCP_CRO_Id(prefs.CAN_message_id_CRO);
    javahandle.setCCP_DTO_Id(prefs.CAN_message_id_DTO);
    javahandle.setCCP_Station_Id(prefs.CCP_Station_Address);
    javahandle.setCanHardware(prefs.CAN_Hardware);
    javahandle.setBitRate(prefs.Bit_Rate);
    javahandle.setNumQuanta(prefs.Num_Quanta);
    javahandle.setSamplePoint(prefs.Sample_Point);
    javahandle.setDownloadType(prefs.Download_Type);
    javahandle.setNetworkType(prefs.ConnectionType);
    javahandle.setSerialCommPort(prefs.SerialPort);
    
    % create a listener for ActionPerformed callbacks from Java.
    listener = handle.listener(javahandle,'ActionPerformed',{@i_action_callback javahandle});
    
    % -- Layout the dialog in the center of the screen ---
    screen_size = java.awt.Toolkit.getDefaultToolkit.getScreenSize;
    dialog_size = javahandle.getSize;
    new_pos = java.awt.Dimension((screen_size.width-dialog_size.width)/2, ...
        (screen_size.height-dialog_size.height)/2);
    javahandle.setLocation(new_pos.width, new_pos.height);
return;

function i_savePrefs(javahandle)
    % use the @cancommon/@candownloadprefs preferences 
    % to store the prefs.
    prefs = RTW.TargetPrefs.load('cancommon.candownloadprefs'); 
    
    % get the current settings from the gui
    prefs.CAN_message_id_CRO = javahandle.getCCP_CRO_Id;
    prefs.CAN_message_id_DTO = javahandle.getCCP_DTO_Id;
    prefs.CCP_Station_Address = javahandle.getCCP_Station_Id;
    prefs.CAN_Hardware = char(javahandle.getCanHardware);
    prefs.Bit_Rate = javahandle.getBitRate;
    prefs.Num_Quanta = javahandle.getNumQuanta;
    prefs.Sample_Point = javahandle.getSamplePoint;
    prefs.Download_Type = char(javahandle.getDownloadType);
    prefs.ConnectionType = char(javahandle.getNetworkType);
    prefs.SerialPort = char(javahandle.getSerialCommPort);
    
    % save the preferences
    prefs.save;
return;
    
function i_action_callback(source, event, javahandle)
   import('com.mathworks.toolbox.ecoder.canlib.CanDownload.*');

   % get the ActionPerformed callback data.
   data = get(javahandle,'ActionPerformedCallbackData');
   
   switch char(data.getActionCommand)
   case char(StandaloneMPC555Control.DOWNLOAD_ACTION)
       % callback no longer used - GUI controls this
   case char(StandaloneMPC555Control.CANCEL_DOWNLOAD_ACTION)
       % callback no longer used - GUI control this
   case char(StandaloneMPC555Control.GENERIC_CANCEL_ACTION)
       % callback for the main cancel button
       % this will allow a new GUI to be created with a call 
       % toembedded_target_download 
       embedded_target_download('clearPersistentVariables');
   case char(StandaloneMPC555Control.HELP_ACTION) 
       % link to help here.
       helpview([docroot '/mapfiles/mpc555dk.map'], 'can_download');
   case char(StandaloneMPC555Control.SAVE_PREFS_ACTION)
       i_savePrefs(javahandle);
   otherwise
       disp('Unknown action callback.');
       disp(data.getActionCommand);
   end;
return;
