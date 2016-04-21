function softscope(varargin)
%SOFTSCOPE Open the Data Acquisition oscilloscope.
%
%   SOFTSCOPE opens the Data Acquisition oscilloscope setup gui. The setup
%   gui defines what hardware is used to run the Data Acquisition oscilloscope. 
%
%   The setup gui creates an analoginput object based on the specified Adaptor 
%   and ID values. The analoginput object's SampleRate and InputType properties 
%   are configured based on the specified SampleRate and Input Type values. All
%   available channels are added to the analoginput object. Each channel's InputRange
%   property is configured to the value specified in the setup UI table. The
%   oscilloscope is opened when the OK button is pressed with the channels selected
%   in the setup UI table displayed.
%
%   Data is acquired from the analoginput object and displayed in the oscilloscope 
%   once the trigger button is pressed.
%   
%   SOFTSCOPE(OBJ) opens the Data Acquisition oscilloscope configured to display the 
%   data acquired from analoginput object, OBJ. OBJ must be a 1-by-1 analoginput object.
%
%   SOFTSCOPE('FNAME.SI') opens the Data Acquisition oscilloscope using the settings
%   specified in the SI file, FNAME. FNAME is generated from the Data Acquisition 
%   oscilloscope's Save menu item.
%
%   SOFTSCOPE modifies or uses many properties of the analoginput object. It is
%   recommended to not change any properties through the command line since it
%   may result in unexpected behavior.
%
%   See also ANALOGINPUT.
%

%   MP 10-03-01
%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.5 $  $Date: 2004/03/30 13:03:58 $

switch (nargin)
case 0
    % Create the UI for defining the hardware that is used by the scope.
    try
        localLayoutSetupUI;
    catch
        % Cleanup in case something bad happened.
        frame = findobj('Tag', 'ScopeHardwareConfiguration');
        delete(frame);
        error('daqguis:softscope:couldNotCreate', 'An error occurred while opening the oscilloscope setup gui.');
    end
case 1
    data = varargin{1};
    if (isstr(data))
        % Create the scope from a saved xml file.
        try
            errmsg = localLoadSoftScope(data);
            if ~isempty(errmsg)
                error('daqguis:softscope:invalidXMLFile', errmsg);
            end
        catch
            error('daqguis:softscope:invalidXMLFile', lasterr);
        end
    elseif isa(data, 'analoginput')
        if length(data) > 1
            error('daqguis:softscope:invalidOBJ', 'OBJ must be a 1-by-1 analoginput object.');
        elseif ~isvalid(data)
            error('daqguis:softscope:invalidOBJ', 'Analoginput object OBJ is an invalid object.');
        end
        % Create the scope from an analoginput object.
        msg = localCreateSoftScope(data, inputname(1));
        if ~isempty(msg)
            error('daqguis:softscope:couldNotCreate', msg);
        end
    else
        error('daqguis:softscope:invalidArg', 'Invalid first argument. Type ''help softscope'' for more information.');
    end
otherwise
    error('daqguis:softscope:invalidSyntax', 'Too many input arguments');
end

% ---------------------------------------------------------------------
function localLayoutSetupUI

import com.mathworks.mwswing.*;
import javax.swing.JLabel;
import java.awt.Font;
import java.awt.BorderLayout;

% Determine if the GUI is currently open. If so, bring it to the foreground.
frame = findobj('Tag', 'ScopeHardwareConfiguration');
if ishandle(frame)
    data = get(frame, 'UserData');
    data.frame.toFront;
    return;
end

data.tag = 'ScopeHardwareConfiguration';
frame = MJFrame;
frame.setDefaultCloseOperation(MJFrame.DO_NOTHING_ON_CLOSE)

% Create a message to display while GUI is initializing.
niceMessage = JLabel('    Initializing Softscope Hardware Configuration Tool...'); 
niceMessage.setFont(Font(get(0,'fixedwidthfontname'), 0, 12)); 
frame.getContentPane.add(niceMessage, BorderLayout.CENTER); 

% Set the frames size and make it visible.
frame.setTitle('Hardware Configuration');
frame.setSize(490, 390);
frame.show;

data.frame = frame;

% Parent the window to Root so FINDOBJ can find it.
set(frame, 'Parent', 0);
set(frame, 'Tag', 'ScopeHardwareConfiguration');

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
p2 = JPanel(GridLayout(1, 3, 5, 0));
p3 = JPanel(BorderLayout);
p4 = JPanel(BorderLayout);
p5 = JPanel(BorderLayout);

okButton         = JButton('OK');
closeButton      = JButton('Close');
helpButton       = JButton('Help');

p3.add(okButton, BorderLayout.NORTH);
p2.add(p3);

p4.add(closeButton, BorderLayout.NORTH);
p2.add(p4);

p5.add(helpButton, BorderLayout.NORTH);
p2.add(p5);

p.add(p2);

data.button.ok = okButton;
data.button.close = closeButton;
data.button.help = helpButton;

set(okButton,         'ActionPerformedCallback', {@localOKButton, data.frame});
set(closeButton,      'ActionPerformedCallback', {@localCloseButton, data.frame});
set(helpButton,       'ActionPerformedCallback', @localHelpButton);

% ---------------------------------------------------------------------
% User closed the dialog with the x window button. Delete the analoginput
% object if it exists and close the frame.
function localClose(obj, event, frame)

data = get(frame, 'UserData');
if ~isempty(data.analoginput)
    delete(data.analoginput);
end
delete(obj);

% ---------------------------------------------------------------------
% The user hit the OK button. Make sure only those channels requested
% are added to the analoginput object. Create the oscilloscope with
% one display and one channel for each selected channel. Configure the
% analoginput object's SampledAcquiredFcn and StopFcn.
function localOKButton(obj,event, frame);

import com.mathworks.mwt.dialog.MWAlert;
import com.mathworks.mwt.MWFrame;

data = get(frame, 'UserData');

% Determine the channels to create.
chans = data.table.getSelectedChannels;

% If no channels are selected, display a warning dialog and return
% without opening the scope.
if isempty(chans)
    MWAlert.errorAlert(MWFrame, 'Too Few Channels', 'At least one channel must be selected.', MWAlert.BUTTONS_OK); 
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
        return;
    elseif ~isvarname(name)
        MWAlert.errorAlert(MWFrame, 'Invalid Channel Name', 'All channels must have a valid MATLAB variable name.', MWAlert.BUTTONS_OK); 
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
    s = warning('off');
	
    for i=selectedChannels
        addchannel(data.analoginput, str2num(allChannelInfo(i,2)));

        % Configure the input range and name.
        try
            set(data.analoginput.Channel(count), 'ChannelName', allChannelInfo(i,3), ...
                                         'InputRange', str2num(allChannelInfo(i,5)));       
            count = count+1;                         
        catch
            MWAlert.errorAlert(MWFrame, 'Invalid Input Range', ['Invalid InputRange value for HW Channel: ' allChannelInfo(i,2)], MWAlert.BUTTONS_OK); 
            
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
    return;
end

% Create the scope.
scope = com.mathworks.toolbox.softinstruments.daq.scope.Scope;
scope.setObject(data.analoginput);

% Add all the hardware channels to the scope so that they can be selected
% at some later point by the user.
sampleRate = get(data.analoginput, 'SampleRate');
count = 1;
for i=selectedChannels 
    scope.createHardwareChannel(allChannelInfo(i,3), allChannelInfo(i,4), str2num(allChannelInfo(i,2)), count, sampleRate);
    count = count+1;
end

% Add the display.
display = scope.defineDisplay('display1');

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
triggerPanel = scope.addTriggerPane('Triggers');

set(data.analoginput, 'RuntimeErrorFcn', {@localStopDueToError, triggerPanel});
set(data.analoginput, 'DataMissedFcn', {@localStopDueToError, triggerPanel});

% Close the figure.
delete(findobj('Tag', 'ScopeHardwareConfiguration'));

% Show the scope.
scope.addToFrame;
scope.autoscale;

% ---------------------------------------------------------------------
% The user selected the Close button. Delete the analoginput object if
% it exists and close the window.
function localCloseButton(obj,event, frame);

data = get(frame, 'UserData');
if ~isempty(data.analoginput)
    delete(data.analoginput);
end

delete(findobj('Tag', 'ScopeHardwareConfiguration'));

% ---------------------------------------------------------------------
% The user selected the Help button. Show help.
function localHelpButton(obj,event)

privateShowHelp('softscope_hardware_configuration', '');

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
            children(i).plot(data(1:index-1,   children(i).getChannelIndex), time(1));
            children(i).plot(data(index+1:end, children(i).getChannelIndex), time(index+1));
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
% Create softscope with the specified analoginput object.
function [msg] = localCreateSoftScope(ai, varname)

% Initialize variables.
msg = '';

% Create the scope.
scope = com.mathworks.toolbox.softinstruments.daq.scope.Scope;
scope.setObject(ai);

% Add the display.
display = scope.defineDisplay('display1');

% Extract necessary information from the analoginput object.
sampleRate = get(ai, 'SampleRate');
channels = get(ai, 'Channel');

if isempty(channels)
    msg = 'At least one channel must be added to the analoginput object.';
    return;
end

% Add the hardware channels to the scope.
for i=1:length(channels)
    hardwareID = get(ai.Channel(i), 'HwChannel');
    channelIndex = get(ai.Channel(i), 'Index');
    scope.createHardwareChannel(['CH' num2str(i)], ['Hardware Channel' num2str(hardwareID)], hardwareID,channelIndex, sampleRate);
    scope.addChannel(['CH' num2str(i)], display);
end

% Set up the callback for the analoginput object.
channelPane = scope.findChannelPanes;
channelPane = channelPane.elementAt(0);
children = channelPane.getDataChannels;
set(ai, 'SamplesAcquiredFcn', {@localPlotData, children});
set(ai, 'UserData', children);
triggerPanel = scope.addTriggerPane('Triggers');
scope.setDeleteOnClose(0);

set(ai, 'RuntimeErrorFcn', {@localStopDueToError, triggerPanel});
set(ai, 'DataMissedFcn', {@localStopDueToError, triggerPanel});

% Show the scope.
scope.setAnalogInputName(varname);
scope.addToFrame;
scope.autoscale;

% ---------------------------------------------------------------------
% Load the softscope from the XML file.
function errmsg = localLoadSoftScope(filename)

% Initialize variables.
errmsg = '';

try
    document = xmlread(filename);
catch
    errmsg = 'The specified file does not exist or could not be read.';
    return;
end

if ~(strcmp(document.getFirstChild.getNodeName, 'Data_Acquisition_Oscilloscope'))
    errmsg = 'The specified file is not a valid Data Acquisition oscilloscope file.';
    return;
end

reader = com.mathworks.toolbox.softinstruments.daq.scope.ScopeXMLReader(document);
scope = reader.createScope;
ai = localCreateAnalogInputObject(scope, document);
scope.setObject(ai);
localAddToFrame(scope, document);

% ---------------------------------------------------------------------
% Create the analoginput object from saved parameters in the XML file.
function ai = localCreateAnalogInputObject(scope, document)

root = document.getFirstChild;        
childNodes = root.getChildNodes;

for i=1:childNodes.getLength
    if (childNodes.item(i).getNodeName.equals('AnalogInput'))
        % Extract the AnalogInput element.
        analogInput = childNodes.item(i);
        
        % Extract the information needed to create the analoginput object
        % from the AnalogInput element.
        vendor = char(analogInput.getAttribute('Vendor'));
        id = str2num(analogInput.getAttribute('ID'));
        sampleRate = str2num(analogInput.getAttribute('SampleRate'));
        inputType = char(analogInput.getAttribute('InputType'));
        
        % Create the object and configure it's properties.
        ai = analoginput(vendor, id);
        set(ai, 'SampleRate', sampleRate, 'InputType', inputType);
        
        % Add the channels and configure their input range value.
        child = analogInput.getChildNodes;
        count = 1;
        for j=1:child.getLength-1
            if strcmp(child.item(j).getNodeName, 'Channel')
                channelID = str2num(child.item(j).getAttribute('HwChannel'));
                addchannel(ai, channelID);
                set(ai.Channel(count), 'InputRange', str2num(child.item(j).getAttribute('InputRange')));
                count = count+1;
            end
        end
        
        % Set up the callback for the analoginput object.
		channelPane = scope.findChannelPanes;
		channelPane = channelPane.elementAt(0);
		children = channelPane.getDataChannels;
		set(ai, 'SamplesAcquiredFcn', {@localPlotData, children});
		set(ai, 'UserData', children);
        
        % Configure callback properties.
        triggerPanel = scope.findTriggerPanes;
        triggerPanel = triggerPanel.elementAt(0);
        set(ai, 'RuntimeErrorFcn', {@localStopDueToError, triggerPanel});
        set(ai, 'DataMissedFcn', {@localStopDueToError, triggerPanel});
        return;
    end
end

% ---------------------------------------------------------------------
% Add the scope to a frame of the correct size and location.
function localAddToFrame(scope, document)

root = document.getFirstChild;        
childNodes = root.getChildNodes;

for i=1:childNodes.getLength
    if (childNodes.item(i).getNodeName.equals('Location'))
        % Extract the Location element.
        location = childNodes.item(i);

        % Extract the attributes from the Location element.
        width = str2num(location.getAttribute('Width'));
        height = str2num(location.getAttribute('Height'));
        x = str2num(location.getAttribute('X'));
        y = str2num(location.getAttribute('Y'));
        scope.addToFrame(x,y,width,height);
        return;
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

