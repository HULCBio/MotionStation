function tag = privateUpdateHardware(scope, oldobj)
%PRIVATEUUPDATEHARDWARE Update the analoginput object used by softscope.
%
%   PRIVATEUUPDATEHARDWARE opens a GUI that defines the available data
%   acquisition hardware for use with softscope. After selecting the new
%   hardware, the following updates are made to softscope:
%
%       1. The old data channels and math channels are removed.
%       2. The measurements are removed.
%       3. The new data channels selected are added.
%    
%   PRIVATEUUPDATEHARDWARE is a helper function for the softscope function.
%   It is called when the Edit -> Hardware menu item is selected from softscope.
%
%   This function should not be used directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 01-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:45:34 $

% Create the UI for defining the hardware that is used by the scope.
try
    tag = localLayoutSetupUI(scope, oldobj);
catch
    % Cleanup in case something bad happened.
    frame = findobj('Tag', 'UpdateScopeHardwareConfiguration');
    delete(frame);
    error('daqguis:softscope:couldNotCreate', 'An error occurred while opening the oscilloscope setup gui.');
end

% ---------------------------------------------------------------------
function tag = localLayoutSetupUI(scope, oldobj)

import com.mathworks.mwswing.*;
import java.awt.BorderLayout;
import javax.swing.JLabel;
import java.awt.Font;

% Define a unique tag.
frame = findobj('Tag', 'UpdateScopeHardwareConfiguration');
if isempty(frame)
    data.tag = 'UpdateScopeHardwareConfiguration';
else
    data.tag = ['UpdateScopeHardwareConfiguration' num2str(length(frame))];
end
tag = data.tag;

% Create the frame.
frame = MJFrame;
frame.setDefaultCloseOperation(MJFrame.DO_NOTHING_ON_CLOSE)

niceMessage = JLabel('    Initializing Softscope Hardware Configuration Tool...'); 
niceMessage.setFont(Font(get(0,'fixedwidthfontname'), 0, 12)); 
frame.getContentPane.add(niceMessage, BorderLayout.CENTER); 

% Set the frames size and make it visible.
frame.setTitle('Hardware Configuration');
frame.setSize(522, 390);
loc = scope.getLocation;
frame.setLocation(loc.x, loc.y);
frame.show;

data.frame = frame;
data.scope = scope;
data.oldobj = oldobj;
data.created = false;

% Parent the window to Root so FINDOBJ can find it.
set(frame, 'Parent', 0);
set(frame, 'Tag', data.tag);

[panel, data] = privateLayoutPanel(data);

% Create the Button panel.
[southPanel, data] = localCreateButtonPanel(data);
panel.add(southPanel, BorderLayout.SOUTH);

% Store the UserData.
set(frame, 'UserData', data);

% Update the table to reflect the channels that are available for the 
% currently selected adaptor, id and inputType.
privateLayoutPanel(frame);

% Configure x button to close window.
set(frame, 'WindowClosingCallback', {@localClose, frame});

% View the frame.
frame.getContentPane.add(panel);
frame.setDefaultCloseOperation(MJFrame.HIDE_ON_CLOSE )
niceMessage.setVisible(0); 
frame.show;
data.combobox.adaptor.requestFocus;

% ---------------------------------------------------------------------
% Create the button panel that consists of an OK button - opens the scope,
% Properties button - opens daqpropedit on the analoginput object, Close
% button - closes dialog, Help button - gives users help.
function [p, data] = localCreateButtonPanel(data)

import java.awt.*;
import javax.swing.*;

p  = JPanel(FlowLayout(FlowLayout.RIGHT));
p.setBorder(BorderFactory.createEmptyBorder(0, 0, 0, 5));
p2 = JPanel(GridLayout(1, 4, 5, 0));
p3 = JPanel(BorderLayout);
p4 = JPanel(BorderLayout);
p5 = JPanel(BorderLayout);
p6 = JPanel(BorderLayout);

okButton         = JButton('OK');
closeButton      = JButton('Close');
applyButton      = JButton('Apply');
helpButton       = JButton('Help');

p3.add(okButton, BorderLayout.NORTH);
p2.add(p3);

p4.add(closeButton, BorderLayout.NORTH);
p2.add(p4);

p5.add(applyButton, BorderLayout.NORTH);
p2.add(p5);

p6.add(helpButton, BorderLayout.NORTH);
p2.add(p6);

p.add(p2);

data.button.ok = okButton;
data.button.close = closeButton;
data.button.apply = applyButton;
data.button.help = helpButton;

set(okButton,         'ActionPerformedCallback', {@localOKButton, data.frame});
set(closeButton,      'ActionPerformedCallback', {@localCloseButton, data.frame});
set(applyButton,      'ActionPerformedCallback', {@localApplyButton, data.frame});
set(helpButton,       'ActionPerformedCallback', @localHelpButton);

% ---------------------------------------------------------------------
% User closed the dialog with the x window button. Delete the analoginput
% object if it exists and close the frame.
function localClose(obj, event, frame)

data = get(frame, 'UserData');
if ~data.created & ~isempty(data.analoginput)
    delete(data.analoginput);
end
delete(obj);

% ---------------------------------------------------------------------
% The user hit the Apply button.
function localApplyButton(obj, event, frame)

import com.mathworks.mwt.dialog.MWAlert;
import com.mathworks.mwt.MWFrame;

data = get(frame, 'UserData');
if (data.changed == 0) & (data.table.didTableChange == 0)
    return;
end
data.changed = 0;
data.error = 0;

% Determine the channels to create.
chans = data.table.getSelectedChannels;

% If no channels are selected, display a warning dialog and return
% without opening the scope.
if isempty(chans)
    MWAlert.errorAlert(MWFrame, 'Too Few Channels', 'At least one channel must be selected.', MWAlert.BUTTONS_OK); 
    data.error = 1;
    set(frame, 'UserData', data);
    return;
end

% Create the object.
if isempty(data.analoginput)
    % Try to create.
    try
        adaptor = data.combobox.adaptor.getSelectedItem;
        id = data.combobox.id.getSelectedItem;
        ai = analoginput(adaptor, id);
    catch
        MWAlert.errorAlert(MWFrame, 'Unavailable Hardware', 'The hardware does not exist for creating the analoginput object', MWAlert.BUTTONS_OK); 
        data.error = 1;
        set(frame, 'UserData', data);
        return;
    end
else
    delete(get(data.analoginput, 'Channel'));
end

% Configure the InputType and SampleRate.
set(data.analoginput, 'InputType', data.combobox.inputType.getSelectedItem);
set(data.analoginput, 'SampleRate', data.samplerate);

% Determine which channels have been selected and add them.
allChannelInfo = data.table.getData;

% Get the selectedChannels.
selectedChannels = [];
for i=1:length(allChannelInfo)
    if allChannelInfo(i,1) == 1
        selectedChannels = [selectedChannels i];
    end
end

% Verify that all the selected Channels have unique names.
count=1;
allNames = {};
for i=selectedChannels
    name = allChannelInfo(i,3);
    if isempty(name) | any(strcmp(name, allNames))
        MWAlert.errorAlert(MWFrame, 'Invalid Channel Name', 'All channels must have a unique non-empty name.', MWAlert.BUTTONS_OK); 
        data.error = 1;
        set(frame, 'UserData', data);
        return;
    elseif ~isvarname(name)
        MWAlert.errorAlert(MWFrame, 'Invalid Channel Name', 'All channels must have a valid MATLAB variable name.', MWAlert.BUTTONS_OK); 
        data.error = 1;
        set(frame, 'UserData', data);
        return;
    end
    allNames{count} = name;
    count = count+1;
end

% Add the channels.
try
    count = 1;
    
    % Store the warning state.
    warning('');
    s = warning('backtrace', 'off');
	
	for i=selectedChannels
        addchannel(data.analoginput, str2num(allChannelInfo(i,2)));
        % Configure the input range and name.
        try
            set(data.analoginput.Channel(count), 'ChannelName', allChannelInfo(i,3), ...
                                             'InputRange', str2num(allChannelInfo(i,5)));       
            count = count+1;
        catch
            MWAlert.errorAlert(MWFrame, 'Invalid Input Range', ['Invalid InputRange value for HW Channel: ' allChannelInfo(i,2)], MWAlert.BUTTONS_OK); 
            data.error = 1;
            set(frame, 'UserData', data);
            
            % Restore the warning state.
            warning(s)
            return;
        end
	end
    if ~isempty(lastwarn)
        MWAlert.warningAlert(MWFrame, 'Add Channel Warning', lastwarn, MWAlert.BUTTONS_OK);         
    end

    % Restore the warning state.
    warning(s)
catch
    % Extract only the message from the error.
    msg = lasterr;
    index = findstr(sprintf('\n'), msg);
    if ~isempty(index)
        msg = msg(index(end)+1:length(msg));
    end
    
    % Show error in dialog box.
    MWAlert.errorAlert(MWFrame, 'Add Channel Error', msg, MWAlert.BUTTONS_OK); 
    data.error = 1;
    set(frame, 'UserData', data);
    return;
end

% Clean up the scope's configuration so that the new analoginput object
% can be used.
scope = data.scope;
scope.cleanupForNewHardware;

% Delete the old analoginput object used by the scope.
delete(data.oldobj);

if (scope.getDeleteOnClose == 0)
    varname = char(scope.getAnalogInputName);
    assignin('base', varname, data.analoginput);
end

% Configure the scope to use the new analoginput object.
scope.setObject(data.analoginput);

% Add all the hardware channels to the scope so that they can be selected
% at some later point by the user.
sampleRate = get(data.analoginput, 'SampleRate');
count = 1;
for i=selectedChannels
    scope.createHardwareChannel(allChannelInfo(i,3), allChannelInfo(i,4), str2num(allChannelInfo(i,2)), count, sampleRate);
    count = count+1;
end

% Get the existing display from the scope.
display = scope.getDisplays;
if (display.size ~= 0)
    display = display.elementAt(0);
else
    display = [];
end

% Add the selected channels to the scope.
for i=selectedChannels
    scope.addChannel(allChannelInfo(i,3), display);
end

% Set up the callback for the analoginput object.
channelPane = scope.findChannelPanes;
channelPane = channelPane.elementAt(0);
children = channelPane.getDataChannels;
set(data.analoginput, 'SamplesAcquiredFcn', {@localPlotData, children});
set(data.analoginput, 'UserData', children);

triggerPanel = scope.findTriggerPanes.elementAt(0);
set(data.analoginput, 'RuntimeErrorFcn', {@localStopDueToError, triggerPanel});
set(data.analoginput, 'DataMissedFcn', {@localStopDueToError, triggerPanel});

% Indicate that object is needed and shouldn't be deleted on close.
data.created = true;

% Store the UserData.
set(frame, 'UserData', data);

scope.configureForNewHardware;
scope.autoscale;
data.table.setTableChanged(0);

% ---------------------------------------------------------------------
% The user hit the OK button. Make sure only those channels requested
% are added to the analoginput object. Create the oscilloscope with
% one display and one channel for each selected channel. Configure the
% analoginput object's SampledAcquiredFcn and StopFcn.
function localOKButton(obj,event, frame);

localApplyButton(obj,event, frame);

data = get(frame, 'UserData');

% Close the figure.
if (data.error == 0)
    delete(findobj('Tag', data.tag));
end

% ---------------------------------------------------------------------
% The user selected the Close button. Delete the analoginput object if
% it exists and close the window.
function localCloseButton(obj,event, frame);

data = get(frame, 'UserData');
if ~data.created & ~isempty(data.analoginput)
    delete(data.analoginput);
end

delete(findobj('Tag', data.tag));

% ---------------------------------------------------------------------
% The user selected the Help button. Show help.
function localHelpButton(obj,event)

privateShowHelp('softscope_hardware_configuration');

% ---------------------------------------------------------------------
% Data has been acquired. Plot the data in the scope.
function localPlotData(obj, event, children)

try
	[data, time] = getdata(obj, obj.SamplesAcquiredFcnCount);
	index = find(isnan(data(:,1)));
	
	if isempty(index)
        for i=1:length(children)
            children(i).plot(data(:,children(i).getChannelIndex), time(1));
        end
	else
        for i=1:length(children)
            children(i).plot(data(1:index-1,  children(i).getChannelIndex), time(1));
            children(i).plot(data(index+1:end,children(i).getChannelIndex), time(index+1));
        end
	end
catch
    if (isvalid(obj))
        if strcmp(obj.Running, 'on')
            stop(obj);
            warndlg(lasterr, 'Acquisition Error'); 
        end
    end
end
% ---------------------------------------------------------------------
% An error occurred on the object. This is the object's RuntimeErrorFcn
% callback.
function localStopDueToError(obj, event, triggerPanel)

import com.mathworks.mwt.dialog.MWAlert;
import com.mathworks.mwt.MWFrame;

stop(obj);

% Enable the triggerPanel controls.
triggerPanel.enableAllComponents;

% Open a dialog that gives information on why the acquisition stopped.
if (strcmp(event.Type, 'Error'))
    MWAlert.errorAlert(MWFrame, 'Acquisition Error', event.Data.String, MWAlert.BUTTONS_OK); 
else
    MWAlert.errorAlert(MWFrame, 'Acquisition Error', 'The acquisition has stopped due to a data missed event.', MWAlert.BUTTONS_OK); 
end

