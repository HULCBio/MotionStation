function [panel,data] = privateLayoutPanel(data)
%PRIVATELAYOUTPANEL Layout the Hardware Configuration Panel used by softscope.
%
%   PRIVATELAYOUTPANEL create the Hardware Configuration Panel used
%   by softscope. 
%
%   This function should not be used directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 1-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:45:32 $

import javax.swing.JPanel;
import java.awt.BorderLayout;

if ~isstruct(data)
    localUpdateTable(data);
    return;
end

% Create the outermost panel.
panel = JPanel(BorderLayout);

% Create the Vendor, BoardIndex and Input Type comboboxes.
[northPanel, data] = localCreateHardwareSelection(data);
panel.add(northPanel, BorderLayout.NORTH);

% Create the Channel table.
[centerPanel, data] = localCreateChannelTable(data);
panel.add(centerPanel, BorderLayout.CENTER);

% ---------------------------------------------------------------------
% Layout the comboboxes that allow users to select the adaptor, id
% InputType, SampleRate and IDs.
function [p, data] = localCreateHardwareSelection(data)

import javax.swing.*;
import java.awt.BorderLayout;
import java.awt.GridLayout;
import java.awt.FlowLayout;

% Create the outer panel.
p = JPanel(BorderLayout(6,0));
p.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

% Create the panel of labels.
west = JPanel(GridLayout(4,1,0,2));
west.add(JLabel('Adaptor:'));
west.add(JLabel('ID:'));
west.add(JLabel('Sample Rate (Hz):'));
west.add(JLabel('Input Type:'));
p.add(west, BorderLayout.WEST);

% Create the panel where users enter the hardware values.
center = JPanel(GridLayout(4,1,0,2));
adaptorNames = localGetValidAdaptorNames;
ids          = localGetIDs(adaptorNames);
ai = analoginput(adaptorNames{1}, ids{1});
inputRange = daqhwinfo(ai, 'InputRanges');

adaptor    = JComboBox(adaptorNames);
id         = JComboBox(ids);
id.setPreferredSize(java.awt.Dimension(106, 21))
sampleRate = JTextField(num2str(ai.SampleRate));
inputType  = JComboBox(localGetValidInputTypes(ai));
channelIds = JTextField('1:2');
channelIds.setEditable(0);

% Store the handles to the controls.
data.combobox.adaptor = adaptor;
data.combobox.id = id;
data.combobox.inputType = inputType;
data.textField.samplerate = sampleRate;
data.textField.channelIds = channelIds;
data.analoginput = ai;
data.samplerate = ai.SampleRate;
data.adaptorNames = adaptorNames;
data.ids = ids;
data.currentId = ids{1};
data.inputRanges = localCreateInputRangesCellStr(inputRange);
data = localFindDefaultInputRange(data);
data.changed = 0;

idPanel = JPanel(FlowLayout(FlowLayout.LEFT, 0, 0));
idPanel.add(id);

% Add controls to layout.
center.add(adaptor);
center.add(idPanel);
center.add(sampleRate);
center.add(inputType);
p.add(center, BorderLayout.CENTER);
 
% Configure the callbacks.
set(adaptor, 'ActionPerformedCallback', {@localAdaptor, data.frame});
set(sampleRate, 'ActionPerformedCallback', {@localSampleRate, data.frame});
set(sampleRate, 'FocusLostCallback', {@localSampleRate, data.frame});
set(id, 'ActionPerformedCallback', {@localID, data.frame});
set(inputType, 'ActionPerformedCallback', {@localInputType, data.frame});
set(channelIds, 'ActionPerformedCallback', {@localChannelIds, data.frame});
set(data.frame, 'KeyReleasedCallback', {@localKeyReleased});

% ---------------------------------------------------------------------
% Layout the table that contains the available channels. 
function [p, data] = localCreateChannelTable(data)

import javax.swing.*;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import com.mathworks.toolbox.softinstruments.daq.scope.*;

% Create the outer panel.
p = JPanel(BorderLayout(6,5));
p.setBorder(BorderFactory.createEmptyBorder(2, 10, 2, 10));

% Create the label.
labelAndButtons = JPanel(GridLayout(1,2,0,0));
p.add(labelAndButtons, BorderLayout.NORTH);

labelAndButtons.add(JLabel('Select the channels to add:'));
[buttonPanel, data] = localCreateButtonPanel(data);
labelAndButtons.add(buttonPanel);

columnNames = {' ', 'HW Channel', 'Name', 'Description', 'Input Range'};
tableData = {logical(1), '1', 'CH1', 'Hardware Channel 1', '[-1 1]'};
table = HardwareChannelTable(tableData, columnNames);
table.setBackground(java.awt.Color.white);

data.table = table;

scrollPane = JScrollPane(table);
scrollPane.getViewport.setBackground(p.getBackground)
p.add(scrollPane, BorderLayout.CENTER);

% ---------------------------------------------------------------------
% Create the select all and deselect all buttons.
function [p, data] = localCreateButtonPanel(data)

import java.awt.*;
import javax.swing.*;

p  = JPanel(FlowLayout(FlowLayout.RIGHT));
p.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 0));
p2 = JPanel(GridLayout(1, 2, 5, 0));
p3 = JPanel(BorderLayout);
p4 = JPanel(BorderLayout);

selectButton        = JButton('Select All');
unselectButton      = JButton('Unselect All');

p3.add(selectButton, BorderLayout.NORTH);
p2.add(p3);

p4.add(unselectButton, BorderLayout.NORTH);
p2.add(p4);

p.add(p2);

data.button.select = selectButton;
data.button.unselect = unselectButton;

set(selectButton,   'ActionPerformedCallback', {@localSelectButton, data.frame});
set(unselectButton, 'ActionPerformedCallback', {@localUnselectButton, data.frame});

% ---------------------------------------------------------------------
% Find the Data Acquisition adaptors that MATLAB knows about.
function names = localGetAdaptorNames

h = daqhwinfo;
initNames = h.InstalledAdaptors;
count = 1;

% Determine if analoginput hardware really exists for these adaptors.
for i=1:length(initNames)
    try
        % Get object constructor information and determine if an
        % analoginput constructor exists.
        info = daqhwinfo(initNames{i});
        constructorName = info.ObjectConstructorName;
        if ~isempty(strmatch('analoginput', constructorName))
            % Add name to output.
            names{count} = initNames{i};
            count = count+1;
        end
    catch
    end
end

% ---------------------------------------------------------------------
% Verify the adaptors can be used. If the hardware is powered off, the
% adaptor may be listed but the user won't be able to create an object
% with it.
function validAdaptors = localGetValidAdaptorNames

% Find those adaptors that allow analoginput.
names = localGetAdaptorNames;
validAdatpors = {};
count = 1;

for i=1:length(names)
    info = daqhwinfo(names{i});
    
    % Find those constructors that allow analoginput. 
    constructorName = info.ObjectConstructorName;
    index = strmatch('analoginput', constructorName);

    % Try to create the analoginput object.
    for j=1:length(index)
        try
            % If one can be created, add it to the list.    
            ai = eval(constructorName{index(j)});
            delete(ai);
            validAdaptors{count} = names{i};
            count = count+1;
            break;
        catch
        end
    end          
end

% ---------------------------------------------------------------------
% Get the hardware ids associated with the adaptor.
function ids = localGetIDs(adaptorName)

if isempty(adaptorName)
    ids = {' '};
    return;
end

% Initialize variables.
count = 1;
info = daqhwinfo(adaptorName{1});

% Find those constructors that allow analoginput.
constructorName = info.ObjectConstructorName;
index = strmatch('analoginput', constructorName);

validIndices = [];

% Extract only those indices that can be created. One may be listed
% that cannot be created if the hardware is turned off.
for i=1:length(index)
    try
        ai = eval(constructorName{index(i)});
        delete(ai);
        validIndices = [validIndices index(i)];
    catch
    end
end

% Loop through each analoginput constructor and pull out the id.
boardIndices = info.InstalledBoardIds;
for i=1:length(validIndices)
    ids{count} = localFindBoardIndex(constructorName{index(i)}, boardIndices);
    count = count+1;
end

% ---------------------------------------------------------------------
% Find the installed board index for the given constructor.
function boardIndex = localFindBoardIndex(constructor, boardIndices)

for i=1:length(boardIndices)
    if ~isempty(findstr(constructor, boardIndices{i}))
        boardIndex = boardIndices{i};
        return
    end
end

% ---------------------------------------------------------------------
% Find the valid InputTypes and the default InputType for the given object.
function [allValues, defaultValue] = localGetValidInputTypes(obj)

out = propinfo(obj, 'InputType');
allValues = out.ConstraintValue;
defaultValue = out.DefaultValue;

% ---------------------------------------------------------------------
% The user selected the Adaptor combobox. Update the available ids
% and InputTypes based on the selected adaptor. Create the analoginput
% object given the current selected values. Update the table with
% channel information.
function localAdaptor(obj, event, frame)

data = get(frame, 'UserData');
data.changed = 1;

% Get the current adaptor and it's ids.
adaptor = get(obj, 'SelectedItem');

% Determine if the user selected from the available list.
if isempty(find(strcmp(adaptor, data.adaptorNames)))
    % User entered their own adaptor.
    ids = {' '};
    data.currentId = '';
    delete(data.analoginput);
    data.analoginput = [];
    newSampleRate = '';
    inputTypes = {'Differential', 'SingleEnded'};
    data.inputRanges = localCreateInputRangesCellStr([]);
    data.currentInputRange = data.inputRanges{1,:};
else
    % Determine the InputTypes for the selected Adaptor and ID.
    ids = localGetIDs({adaptor});
    data.currentId = ids{1};
    ai = analoginput(adaptor, ids{1});
    newSampleRate = get(ai, 'SampleRate');
    delete(data.analoginput);
    data.analoginput = ai;
    [inputTypes, defaultInputType] = localGetValidInputTypes(ai);
    inputRange = daqhwinfo(ai, 'InputRanges');
    data.inputRanges = localCreateInputRangesCellStr(inputRange);
    data = localFindDefaultInputRange(data);
end

data.ids = ids;

% Store and unset other callbacks - so they don't get called when updating
% the IDs and InputTypes.
oldIDCallback = get(data.combobox.id, 'ActionPerformedCallback');
oldInputTypeCallback = get(data.combobox.inputType, 'ActionPerformedCallback');

set(data.combobox.id, 'ActionPerformedCallback', '');
set(data.combobox.inputType, 'ActionPerformedCallback', '');

% Update the IDs for the selected Adaptor.
data.combobox.id.removeAllItems;
for i=1:length(ids)
    data.combobox.id.addItem(ids{i});
end

% Update the SampleRate textfield.
set(data.textField.samplerate, 'Text', num2str(newSampleRate));
data.samplerate = newSampleRate;

% Update the InputTypes for the selected Adaptor and ID.
data.combobox.inputType.removeAllItems;
for i=1:length(inputTypes)
    data.combobox.inputType.addItem(inputTypes{i});
end
data.combobox.inputType.setSelectedItem(defaultInputType);

% Restore the callbacks for the ID and InputType.
set(data.combobox.id, 'ActionPerformedCallback', oldIDCallback);
set(data.combobox.inputType, 'ActionPerformedCallback', oldInputTypeCallback);

% Store the data structure.
set(frame, 'UserData', data);

% Update the channels listed in the table.
localUpdateTable(frame);

% ---------------------------------------------------------------------
% The user selected the ID combobox. Update the InputType based on the 
% selected ID. Create the analoginput object associated with the selected
% Adaptor, ID and InputType. Update the table that lists the channels 
% that can be added to the analoginput object.
function localID(obj, event, frame)

data = get(frame, 'UserData');
data.changed = 1;

adaptor = data.combobox.adaptor.getSelectedItem; 
id = data.combobox.id.getSelectedItem;
data.currentId = id;

% Determine the InputTypes for the selected Adaptor and ID.
try
	ai = analoginput(adaptor, id);
    if ~isempty(data.analoginput)
		delete(data.analoginput);
    end
	data.analoginput = ai;
    [inputTypes, defaultInputType] = localGetValidInputTypes(ai);
    
    % Update SampleRate text field.
    newSampleRate = setverify(ai, 'SampleRate', data.samplerate);
    set(data.textField.samplerate, 'Text', num2str(newSampleRate));
    data.samplerate = newSampleRate;
    
    inputRange = daqhwinfo(ai, 'InputRanges');
    data.inputRanges = localCreateInputRangesCellStr(inputRange);
    data = localFindDefaultInputRange(data);
catch
    if ~isempty(data.analoginput)
        delete(data.analoginput);
    end
    data.analoginput = [];
    data.inputRanges = localCreateInputRangesCellStr([]);
    data.currentInputRange = data.inputRanges{1,:};
    
    if strcmp(adaptor, 'winsound')
        inputTypes = {'AC-Coupled'};
        defaultInputType = 'AC-Coupled';
    else
        inputTypes = {'Differential', 'SingleEnded'};
        defaultInputType = 'Differential';
    end
end

% Store and unset InputType callback - so it doesn't get called when updating
% theTypes.
oldInputTypeCallback = get(data.combobox.inputType, 'ActionPerformedCallback');
set(data.combobox.inputType, 'ActionPerformedCallback', '');

% Update the InputTypes for the selected Adaptor and ID.
data.combobox.inputType.removeAllItems;
for i=1:length(inputTypes)
    data.combobox.inputType.addItem(inputTypes{i});
end
data.combobox.inputType.setSelectedItem(defaultInputType);

% Restore the callbacks for the InputType.
set(data.combobox.inputType, 'ActionPerformedCallback', oldInputTypeCallback);

% Store the data structure.
set(frame, 'UserData', data);

% Update the channels listed in the table.
localUpdateTable(frame);

% ---------------------------------------------------------------------
% The user entered a value in the SampleRate edit text box.
function localSampleRate(obj, event, frame)

data = get(frame, 'UserData');

% data is empty if the user enters a samplerate value and then
% hits the X to close the softscope window. Focus for the sample
% rate text field is lost and therefore this method is called.
if isempty(data)
    return;
end

data.changed = 1;

if ~isempty(data.analoginput)
    value = str2num(data.textField.samplerate.getText);
    try
        % Try configuring the value. If successful, store the value.
        % This will take care of the case where a non-number was specified
        % since value will be [] and an error will be thrown and caught.
        actualValue = setverify(data.analoginput, 'SampleRate', value);
        data.textField.samplerate.setText(num2str(actualValue));
        data.textField.samplerate.setCaretPosition(length(data.textField.samplerate.getText));
        data.samplerate = actualValue;
    catch
        % An error occurred so reset the SampleRate.
        data.textField.samplerate.setText(num2str(data.samplerate));
        data.textField.samplerate.setCaretPosition(length(data.textField.samplerate.getText));
    end
else
    value = str2num(data.textField.samplerate.getText);
    if ~isempty(value)
        data.samplerate = value;
    else
        % A non-number was entered.
        data.textField.samplerate.setText(num2str(data.samplerate));
    end
end

% Store the data structure.
set(frame, 'UserData', data);

% ---------------------------------------------------------------------
% The user selected the InputType combobox. Update the analoginput object's
% InputType property. Update the table that lists the channels that can 
% be added to this analoginput object.
function localInputType(obj, event, frame)

data = get(frame, 'Userdata');

% Configure InputType property.
if ~isempty(data.analoginput)
    
    data = get(frame, 'UserData');
    data.changed = 1;
    set(data.analoginput, 'InputType', data.combobox.inputType.getSelectedItem);

    % Store the data structure.
    set(frame, 'UserData', data);

    % Update the channels listed in the table.
    localUpdateTable(frame)
end

% ---------------------------------------------------------------------
% The user entered a value in the Available HW Channel text field.
% If the hardware exists, the text field will default back to those
% channels that exist. Otherwise, we take the word of the user and update
% the table accordingly.
function localChannelIds(obj, event, frame)

data = get(frame, 'UserData');
data.changed = 1;

if ~isempty(data.analoginput)
    % Give a dialog.
    title = 'Invalid Available HW Channels';
    msg = ['The available hardware channels are ' [num2str(min(data.channels)) ':' num2str(max(data.channels))] '.'];
    h = warndlg(msg, title, 'modal');
    
    % Wait until the user hits ok on the dialog before updating the ChannelIDs textfield.
    waitfor(h);
    
    % Update the ChannelIDs textfield.
    oldChannelIDCallback = get(data.textField.channelIds, 'ActionPerformedCallback');
    set(data.textField.channelIds, 'ActionPerformedCallback', '');
    set(data.textField.channelIds, 'Text', [num2str(min(data.channels)) ':' num2str(max(data.channels))]);
    set(data.textField.channelIds, 'ActionPerformedCallback', oldChannelIDCallback);    
    
    % Store the data structure.
    set(frame, 'UserData', data);
else
    % Update table.
    localUpdateTable(frame);
end

% ---------------------------------------------------------------------
% Update the channels listed in the table. The user selected the adaptor,
% ID or InputType comboboxes.
function localUpdateTable(frame)

data = get(frame, 'UserData');
data.changed = 1;

if isempty(data.analoginput)
    ids = str2num(data.textField.channelIds.getText);
    if isempty(ids)
        data.textField.channelIds.setText(localConvertChannelListToString(data.channels));
        return;
    else
        data.channels = ids;
    end
    names = {};
else
	inputType = data.combobox.inputType.getSelectedItem;
	adaptor = data.combobox.adaptor.getSelectedItem;
	
	info = daqhwinfo(data.analoginput);
	
	% Based on the InputType, extract information from daqhwinfo.
	names = {};
	if strcmp(inputType, 'AC-Coupled')
        data.channels = info.SingleEndedIDs;
        names = {'Left', 'Right'};
	elseif ~isempty(findstr('SingleEnded', inputType))
        data.channels = info.SingleEndedIDs;
	elseif ~isempty(findstr('Differential', inputType))
        data.channels = info.DifferentialIDs;
    else
        data.channels = info.SingleEndedIDs;
    end
end

% Construct the data to go into the table.
newData = cell(length(data.channels), 5);

for i=1:length(data.channels)
    newData{i,1} = logical(1); 
    newData{i,2} = num2str(data.channels(i));
    if isempty(names)
        newData{i,3} = ['CH' num2str(data.channels(i))];
    else
        newData{i,3} = names{i};
    end
    newData{i,4} = ['Hardware channel ' num2str(data.channels(i))];
    newData{i,5} = data.currentInputRange;
end    

% Set the table's data.
table = data.table;
table.clearSelection;
table.setData(newData);
table.setInputRanges(data.inputRanges);

% Needed so that if a row was selected, the right input ranges are displayed
% in the combobox.
table.selectAll;
table.clearSelection;

% Update the ChannelIDs textfield.
if ~isempty(data.analoginput)
    oldChannelIDCallback = get(data.textField.channelIds, 'ActionPerformedCallback');
    set(data.textField.channelIds, 'ActionPerformedCallback', '');
    set(data.textField.channelIds, 'Text', [num2str(min(data.channels)) ':' num2str(max(data.channels))]);
    set(data.textField.channelIds, 'ActionPerformedCallback', oldChannelIDCallback);
end

% Store the data structure.
set(frame, 'UserData', data);

% ---------------------------------------------------------------------
% User entered a bad id list. Need to restore old list to the proper 
% string, for example, either 1:4 or 1,2,4 depending on if the 3 is 
% included.
function out = localConvertChannelListToString(x)

minValue = min(x);
maxValue = max(x);
temp = minValue:maxValue;

if isequal(x, temp)
    % Can represent as a range of values.
    out = [num2str(minValue) ':' num2str(maxValue)];
else
    % List each value seperately since it isn't a continuous list of values.
    out = '';
    for i=1:length(x)
        out = [out num2str(x(i)) ','];
    end
    out = out(1:end-1);
end

% ---------------------------------------------------------------------
% Convert the InputRanges into a cell array of strings containing,
% for example, [-1 1], [-2 2], [-3 3].
function out = localCreateInputRangesCellStr(x)

if isempty(x)
    out = {'[-1 1]'};
else
    out = cell(size(x,1),1);
    for i=1:size(x,1)
        out{i} = ['[' num2str(x(i,1)) ' ' num2str(x(i,2)) ']'];
    end
end

% ---------------------------------------------------------------------
% Find the default input range for the selected adaptor.
function data = localFindDefaultInputRange(data)
try
    channelIDs = daqhwinfo(data.analoginput, 'SingleEndedIds');
    channel = addchannel(data.analoginput, channelIDs(1));
    currentInputRange = localCreateInputRangesCellStr(get(channel, 'InputRange'));
    data.currentInputRange = currentInputRange{1};
    delete(channel);
catch
    data.currentInputRange = data.inputRanges{1,:};
end

% ---------------------------------------------------------------------
function localKeyReleased(obj,event)

data = get(obj, 'UserData');
keyInfo = get(data.frame, 'KeyReleasedCallbackData');
if isempty(keyInfo)
    return;
end

if (keyInfo.modifiers == 2) & (keyInfo.keyCode == 87)
    if ~isempty(data.analoginput)
       delete(data.analoginput);
   end
   frame = findobj('Tag', data.tag);
   delete(frame);
end

% ---------------------------------------------------------------------
% Select button was pressed. Select all the channels.
function localSelectButton(obj, event, frame)  

data = get(frame, 'UserData');
data.table.selectAllRowsInTable;

% ---------------------------------------------------------------------
% Unselect button was pressed. Unselect all the channels.
function localUnselectButton(obj, event, frame) 

data = get(frame, 'UserData');
data.table.unselectAllRowsInTable;


        