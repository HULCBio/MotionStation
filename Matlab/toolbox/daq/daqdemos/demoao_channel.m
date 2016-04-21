%% Introduction to analog output channels.
%    DEMOAO_CHANNEL introduces analog output channels by demonstrating
%    how to add channels to an analog output object and how to configure 
%    the channels for your acquisition.  
%
%    This demo gives examples on using the get/set notation, dot notation,
%    and named index notation for obtaining information about the channel 
%    and for configuring the channel for your acquisition.
%
%    See also ADDCHANNEL, DAQDEVICE/GET, DAQDEVICE/SET, ANALOGOUTPUT,
%             DAQHELP.
%
%    MP 8-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.5 $  $Date: 2003/08/29 04:45:17 $

%%
% First find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% In this example, you will learn about creating, accessing,  
% and configuring analog output channels.
%
% To get started, an analog output object, ao, associated 
% with the winsound device is created.
ao = analogoutput('winsound');

%%
% You can add a channel to an analog output object with 
% the ADDCHANNEL command. ADDCHANNEL needs at least two 
% input arguments. The first input argument specifies which 
% analog output object the channel is being added to. The 
% second argument is the id of the hardware channels you are
% adding to the analog output object.
% 
% For the sound card, you can add up to two channels. If one  
% channel is added, sound is recorded and played in mono. If 
% two channels are added, sound is recorded and played in 
% stereo.
addchannel(ao, 1);  % adding one channel

%%
% There are three methods for accessing a channel. In the  
% First Method, the channel is accessed through the analog 
% output object's Channel property. For example, using 
% the dot notation, all the analog output object's channels 
% will be assigned to the variable ch1.
%
% Or, using the get notation.
ch1 = ao.Channel;          % dot notation
ch1 = get(ao, 'Channel');  % get notation
ch1

%%
% In the Second Method, the channel is accessed at creation 
% time by assigning an output variable to ADDCHANNEL.
% 
% The third input argument to ADDCHANNEL assigns the name  
% Chan2 to the channel created.
ch2 = addchannel(ao, 2, 'Chan2');
ch2

%%
% In the the Third Method, the channel is accessed 
% through its ChannelName property value. This method 
% is referred to as named referencing. The second channel
% added to the analog output object was assigned the 
% ChannelName 'Chan2'. Therefore, the second channel
% can be accessed with the command:
ch2 = ao.Chan2;
ch2

%%
% Channels that have the same parent (or are associated 
% with the same analog output object) can be concatenated
% into either row or column vectors. Note an error will occur 
% if you try to concatentate channels into a matrix.
cha = [ch1 ch2];   % row concatenation

ch = [ch1; ch2];   % column concatenation

size(cha)
size(ch)
%

%%
% You can access specific channels by specifying the index
% of the channel in the analog output object's channel array. 
ch1 = ao.Channel(1)  % To obtain the first channel

ch2 = ao.Channel(2)  % To obtain the second channel

ch1
ch2
%

%%
% Or, if a 1-by-5 channel array is created, it is possible   
% to access the first, third, and fourth channels as follows:
charray = [ch1 ch2 ch1 ch1 ch2]
temp = charray([1 3 4])
%

%%
% You can obtain information regarding the channel with 
% the GET command. When passing only the channel to GET,
% a list of all properties and their current values are 
% displayed. The common properties are listed first.  
% If any device-specific channel properties exist, they 
% will be listed second.
get(ch1)

%%
% If an output variable is supplied to the GET command,  
% a structure is returned where the structure field names 
% are the channel's property names and the structure 
% field values are the channel's property values.
h = get(ch2);
h

%%
% You can obtain information pertaining to a specific 
% property by specifying the property name as the second
% input argument to GET.
get(ch1, 'Units')

%%
% If the channel array is not 1-by-1, a cell array of 
% property values is returned.
get(ch, 'Units')

%%
% You can obtain information pertaining to multiple properties 
% by specifying a cell array of property names as the second 
% input argument to GET.
get(ch2, {'ChannelName','HwChannel','Units'})

%%
% If the channel array is not singular and a cell array 
% of property names is passed to GET, then a matrix of 
% property values is returned.
%
% The returned property values matrix relate to each object
% and property name as follows: 
get(ch, {'ChannelName','HwChannel','Units'})

%%
% You can also use the dot notation to obtain information about 
% each channel.
% 
% >> ch1.Units;
% >> ao.Channel(2).ChannelName;
%
% You can also obtain channel information through named 
% referencing.
% 
% >> ao.Chan2.OutputRange

%%
% You can assign values to different channel properties  
% with the SET command. If only the channel is passed to 
% SET, a list of settable properties and their possible 
% values are returned. Similar to the GET display, the 
% common properties are listed first. If any device specific 
% channel properties exist, they will be listed second.
set(ch1)

%%
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
% >> set(ch1, 'Units')
% 
% Or, you can assign the result to an output variable.
% 
% >> unit = set(ch1, 'Units')


%%
% You can assign values to a specific property as follows:
set(ch1, 'UnitsRange', [0 100]);
ch

%%
% You can assign the same property values to multiple channels 
% with one call to SET.
set(ch, 'UnitsRange', [-50 50]);
ch

%%
% You can assign different property values to multiple 
% channels by specifying a cell array of property values in 
% the SET command.
set(ch, {'UnitsRange'}, {[-20 20];[0 10]});
ch

%%
% This can be extended to assign multiple properties 
% different values for multiple channels. The cell array
% of property values must be m-by-n, where m is the number
% of objects and n is the number of properties. Each row 
% of the property values cell array contains the property 
% values for a single object. Each column of the property
% values cell array contains the property values for a 
% single property.
% 
% The assigned property values matrix relate to each object and 
% property name as follows:
set(ao.Channel, {'Units'; 'UnitsRange'}, {'LeftUnits', [0 30]; 'RightUnits', [0 40]});
ao.Channel
%

%%
% You can use the dot notation to assign values to channel
% properties.
ch1.Units = 'OneUnits';
ch2.UnitsRange = [0 50];
ao.Channel(1).ChannelName = 'Chan1';
ao.Channel
%

%%
% Or, you can assign values to channel properties through named 
% referencing.
ao.Chan2.Units = 'TwoUnits';
ao.Channel
%


%%
% The range of data output to your D/A converter and the 
% valid ranges the D/A converter can be set to are controlled 
% by the following engineering units properties:
%    1. OutputRange - the D/A converter range.
%    2. UnitsRange  - output data range.
%    3. Units       - Engineering units name.
% 
% The data and D/A hardware ranges should be selected so 
% that the output data is not clipped and you use the 
% largest possible dynamic range of the output hardware.
% 
% For example, suppose you are outputting data that ranges 
% between -2 volts and 2 volts, and the D/A converter has 
% a maximum range of -1 volt to 1 volt. If the data is 
% not scaled, it will we clipped since the data's range 
% exceeds the hardware's range. By setting the UnitsRange 
% property to -2 volts to 2 volts, the data will be scaled
% so that a data value of -2 will map to a value of -1 at 
% the hardware level and a data value of 2 will map to a 
% value of 1 at the hardware level and clipping will not 
% occur.
% 
% The channel configuration would be set as follows:
% 
% >> set(ao.Channel, 'OutputRange', [-1 1]);
% >> set(ao.Channel, 'UnitsRange', [-2 2]);
% 
% Only linear engineering unit conversions are supported.   
% You can perform nonlinear conversions by creating the 
% appropriate M-file function.

