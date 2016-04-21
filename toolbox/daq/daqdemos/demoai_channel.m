%% Introduction to analog input channels.
%    DEMOAI_CHANNEL introduces analog input channels by demonstrating how
%    to add channels to an analog input object and how to configure  the
%    channels for your acquisition.  
%
%    This demo gives examples on using the get/set notation, dot notation,
%    and named index notation for obtaining information about the channel 
%    and for configuring the channel for your acquisition.
%
%    See also ADDCHANNEL, DAQDEVICE/GET, DAQDEVICE/SET, ANALOGINPUT,
%             DAQHELP.
%
%    MP 8-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.6 $  $Date: 2004/03/30 13:03:54 $

%%
% In this example, you will learn about creating, accessing, and
% configuring  analog input channels.

%%
% Find any open DAQ objects and stop them.
openDAQ = daqfind;
for i = 1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% To get started, an analog input object, ai, is created for the winsound
% device.
ai = analoginput('winsound');
ai 

%%
% You can add a channel to an analog input object with the  ADDCHANNEL
% command.  ADDCHANNEL needs at least two input arguments. The first input
% argument  specifies which analog input object the channel is being added
% to. The second  argument is the id of the hardware channels you are
% adding to the analog input  object. For the sound card, you can add up to
% two channels. If one channel is  added, sound is recorded and played in
% mono. If two channels are added, sound  is recorded and played in stereo.
addchannel(ai, 1)
%

%%
% There are three methods for accessing a channel. In the first method, the
% channel is accessed through the analog input object's Channel property. 
% For example, using the dot notation, all the analog input object's 
% channels will be assigned to the variable ch1.
ch1 = ai.Channel;

% Or, using the GET notation

ch1 = get(ai, 'Channel');
ch1

%%
% In the second method, the channel is accessed at creation time by
% assigning  an output variable to ADDCHANNEL.  The third input argument to
% ADDCHANNEL assigns the name Chan2 to the added  channel. 
addchannel(ai, 2, 'Chan2')
%

%%
% In the the third method, the channel is accessed through its ChannelName 
% property value. This method is referred to as Named Referencing. The 
% second channel added to the analog input object was assigned the 
% ChannelName 'Chan2'.  Therefore, you can access the second channel with
% the command:
ch2 = ai.Chan2;
ch2

%%
% Channels that have the same parent (or are associated with the same
% analog  input object) can be concatenated into either row or column
% vectors. An  error will occur if you try to concatentate channels into a
% matrix.
ch = [ch1 ch2];
s = size(ch);

% Or

ch = [ch1; ch2];
s1 = size(ch);

s
s1

%%
% You can access specific channels by specifying the index of the channel
% in  the analog input object's channel array. 
% To obtain the first channel:
ch1 = ai.Channel(1);

% To obtain the second channel:

ch2 = ai.Channel(2);

ch1
ch2

%%
% Or, if a 1-by-5 channel array is created, it is possible to access the
% first,  third, and fourth channels as follows: 
charray = [ch1 ch2 ch1 ch1 ch2];
temp = charray([1 3 4]); 

charray
temp

%%
% You can obtain information regarding the channel with the 
% GET command. When passing only the channel to GET, a list of
% all properties and their current values are displayed. The 
% common properties are listed first. If any device-specific 
% channel properties exist, they will be listed second.
get(ch1)
%

%%
% If an output variable is supplied to the GET command, a 
% structure is returned where the structure field names are 
% the channel's property names, and the structure field 
% values are the channel's property values.
h = get(ch2);
h

%% 
% You can obtain information pertaining to a specific property 
% by specifying the property name as the second input argument 
% to GET (e.g. ch1).
%
% If the channel array is not 1-by-1, a cell array of property 
% values is returned (e.g. ch).
get(ch1, 'Units')
get(ch, 'Units')
%

%%
% You can obtain information pertaining to multiple properties 
% by specifying a cell array of property names as the second 
% input argument to GET (e.g. ch2).
%
% If the channel array is not singular, and a cell array of  
% property names is passed to GET, then a matrix of property 
% values is returned (e.g. ch).
%
% The returned property values matrix relate to each object 
% and property name as follows:
get(ch2, {'ChannelName','HwChannel','Units'})
get(ch, {'ChannelName','HwChannel','Units'})
%

%%
% Note that you can also use the dot notation to obtain information about 
% each channel.
% 
% ch1.Units
% ai.Channel(2).ChannelName
%
% And you can also obtain channel information through named 
% referencing.
% 
% ai.Chan2.InputRange

%%
% You can assign values to different channel properties with 
% the SET command. If only the channel is passed to SET, a 
% list of settable properties and their possible values are 
% returned. Similar to the GET display, the common properties 
% are listed first. If any device-specific channel properties 
% exist, they will be listed second. 
% 
% set(ch1)
%
% If you supply an output variable to SET, a structure is 
% returned where the structure field names are the channel's 
% property names and the structure field values are the 
% possible property values for the channel property.
h = set(ch1);
h

%%
% You can obtain information on possible property values for
% a specific property by specifying the property name as the 
% second input argument to SET.
% 
% set(ch1, 'Units');
% 
% Or, you can assign the result to an output variable.
% 
% unit = set(ch1, 'Units');

%%
% You can assign values to a specific property as follows
set(ch1, 'SensorRange', [-2 2]);
ch

%%
% You can assign the same property values to multiple channels 
% with one call to SET.
set(ch, 'SensorRange', [-3 3]);
ch

%%
% You can assign different property values to multiple 
% channels by specifying a cell array of property values in 
% the SET command.
set(ch, {'SensorRange'}, {[-2 2];[-1 1]});
ch

%%
% This concept can be extended to assign multiple properties 
% different values for multiple channels. The cell array of 
% property values must be m-by-n, where m is the number of 
% objects and n is the number of properties. 
% 
% Each row of the property values cell array contains the 
% property values for a single object. Each column of the 
% property values cell array contains the property values 
% for a single property.
%
% The assigned property values matrix relate to each object and 
% property name as follows:  
set(ai.Channel, {'Units'; 'UnitsRange'}, {'LeftUnits', [0 30]; 'RightUnits', [0 40]});
ai.Channel
%

%%
% You can use the dot notation to assign values to channel properties.
% 
% ch1.Units = 'OneUnits';
% ch2.SensorRange = [-4 4];
% ai.Channel(1).ChannelName = 'Chan1';
% ai.Channel
% 
% Or, you can assign values to channel properties through named 
% referencing.
%
% ai.Chan2.Units = 'TwoUnits';
% ai.Channel
%
ch1.Units = 'OneUnits';
ch2.SensorRange = [-4 4];
ai.Channel(1).ChannelName = 'Chan1';

ai.Chan2.Units = 'TwoUnits';
ai.Channel
%

%%
% You can convert the analog input signals into values that 
% represent specific engineering units by specifying the  
% following Channel properties:
% 
%     1. SensorRange - Expected range of data from sensor.
%     2. InputRange  - Range of A/D converter.
%     3. UnitsRange  - Range of data in MATLAB workspace.
%     4. Units       - Engineering units name.
% 
% For example, suppose you are using a microphone which can
% measure sound levels up to 120 dB and this range produces
% an output voltage from -0.5 volts to 0.5 volts.  Your A/D
% converter may have several valid voltage ranges that it 
% can be set to. The best A/D hardware range is the one that 
% encompasses the expected sensor range most closely.  
% 
% The channel configuration would be set as follows:
% 
% set(ai.Channel, 'SensorRange', [-0.5 0.5]);
% set(ai.Channel, 'InputRange', [-1 1]);
% set(ai.Channel, 'UnitsRange', [0 120]);
% set(ai.Channel, 'Units', 'dB');
% 
% Only linear engineering unit conversions are supported.   
% You can perform nonlinear conversions by creating the 
% appropriate M-file function.


