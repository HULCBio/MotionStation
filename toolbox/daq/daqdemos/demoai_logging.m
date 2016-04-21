%% Demonstrate data logging.
%    DEMOAI_LOGGING illustrates how to configure an analog input object
%    for data logging and shows an example for logging multiple triggers 
%    to disk.  
%
%    DEMOAI_LOGGING illustrates the functionality of DAQREAD by reading 
%    the data logged into the MATLAB workspace.  Examples are given on 
%    how DAQREAD can be used to read all the data logged to disk, a 
%    portion of the data logged to disk, the event information that 
%    occurred while the object was being logged to disk and the state
%    of the data acquisition object when logging was finished.
%
%    See also DAQREAD, ANALOGINPUT, ADDCHANNEL, DAQDEVICE/START, 
%             STOP, DAQHELP.
%
%    MP 8-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:45:15 $

%%
% First find any open DAQ objects and stop them.
openDAQ = daqfind;
for i = 1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% DATA LOGGING.
% In this example, you will learn about logging data to a 
% file and reading the data back into the MATLAB workspace.

%%
% To get started, an analog input object containing two 
% channels is created.
ai = analoginput('winsound');
ch = addchannel(ai, [1 2], {'Left', 'Right'});

%%
% Note there are four properties that control how data is logged 
% to disk:  
%     1. Logging
%     2. LogFileName
%     3. LoggingMode
%     4. LogToDiskMode
% 
% Type the following for Data Acquistion Logging property information:
% >> daqhelp Logging;
%
% Type the following for Data Acquistion LogFileName property information:
% >> daqhelp LogFileName;
%
% Type the following for Data Acquistion LoggingMode property information:
% >> daqhelp LoggingMode;
%
% Type the following for Data Acquistion LogToDiskMode property information:
% >> daqhelp LogToDiskMode;

%%
% With the following settings, data will be logged to the 
% file file00.daq and to memory. If another start occurs, 
% the new data will overwrite the old data in file00.daq.
ai.LogFileName = 'file00.daq';
ai.LogToDiskMode = 'overwrite';
ai.LoggingMode = 'Disk&Memory';

%%
% Let's configure the analog input object to trigger 
% five times. Each trigger will collect 1000 data samples 
% using a sample rate of 10,000 samples per second.
ai.TriggerType = 'Immediate';
ai.TriggerRepeat = 4;
ai.SamplesPerTrigger = 1000;
ai.SampleRate = 10000;

%%
% Since the TriggerType is 'Immediate', the Logging property 
% will be immediately set to 'On' after the analog input 
% object is started with the START command. Therefore, the  
% data will be immediately sent to the log file upon starting. 
start(ai);
ai.logging
%

%%
% The DAQREAD command is used to read the .daq file. With 
% the following syntax, all the samples logged to disk will 
% be read into the variable data. data will be an m-by-n 
% matrix where m is the number of samples logged and n 
% is the number of channels. However, if multiple triggers
% are logged, the data between triggers are separated by NaNs. 
% In this case, m will be increased by the number of triggers. 
% The time vector will contain the relative times that each 
% data sample was logged relative to the first trigger.
[data, time] = daqread('file00.daq');

% Now the data can be displayed:
plot(time,data);

%%
% It is possible to limit the amount of data being read by  
% DAQREAD by using one of the following properties:
%  
% Property Name               Description
%  
%    Samples            Specify the range of samples
%    Triggers           Specify the range of triggers
%    Time               Specify the range of time in seconds
%    Channels           Specify the channel indices
%
%
% For example the following command will read all samples between 
% the 1000th data sample and the 2000th data sample.
[data,time] = daqread('file00.daq', 'Samples', [1000 2000]);

% The subset of data is now plotted.
plot(time,data);

%%
% Similarly, you can restrict the number of Channels read by 
% specifying the 'Channels' property. For example, to read 
% samples 500 to 1000 of the second channel, you would assign 
% the following values to the 'Samples' and 'Channels' properties.
[data,time] = daqread('file00.daq', 'Samples', [500 1000], 'Channels', 2);

% The subset of data is now plotted.
plot(time,data);

%%
% You can select the format of the data and time output variables
% using the following properties where the default value is 
% given in curly braces {}.
% 
%  Property Name                     Description
%    DataFormat                    {double} | native
%    TimeFormat                    {vector} | matrix
% 
% For example, to read in all the data in native format for 
% the 1st channel only, you would assign the following values 
% to the 'Channels' and 'DataFormat' properties.
[data,time] = daqread('file00.daq', 'Channels', 1, 'DataFormat', 'native');

% The subset of data is now plotted.
plot(time,data);

%%
% You can also use the DAQREAD command to read in information  related 
% to the object used to log the data and hardware information.
daqinfo = daqread('file00.daq', 'info');

%%
% To obtain the object information:
daqinfo.ObjInfo
%

%%
% To obtain channel information:
daqinfo.ObjInfo.Channel
%

%%
% To obtain event information you can use the SHOWDAQEVENTS command to
% display the event information.
daqinfo.ObjInfo.EventLog;
showdaqevents(daqinfo.ObjInfo.EventLog)

%% 
% To obtain the hardware information:
daqinfo.HwInfo
%

%%
% Lastly, clean up the data acquistion object
delete(ai);
delete file00.daq


