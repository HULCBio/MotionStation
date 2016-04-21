%% Getting started with the Data Acquisition Toolbox.
%    DEMODAQ_INTRO illustrates how to get started with the Data Acquisition
%    Toolbox.  
%
%    DEMODAQ_INTRO shows you how to determine which hardware and adaptors 
%    are installed on your machine.  It also shows you how to determine
%    what Data Acquisition Toolbox objects can be created for each
%    installed adaptor and what commands are needed to create those
%    objects.  Finally, DEMODAQ_INTRO shows how to obtain help on data
%    acquisition properties and functions.
%    
%    See also ANALOGINPUT, ANALOGOUTPUT, ADDCHANNEL, DAQHWINFO, PROPINFO,
%             DAQHELP.
%
%    MP 12-02-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.7.2.5 $  $Date: 2003/08/29 04:45:21 $

%%
% First find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% In this demo, we will determine:
%    - What hardware and adaptors are installed on your machine
%    - What Data Acquisition Toolbox objects you can create 
%    - How you can find information and help on a data acquisition object.

%%
% A hardware adaptor is the interface that allows you to 
% pass information between the data acquisition engine and  
% the hardware driver. The Data Acquisition Toolbox provides 
% adaptors for:
%   sound cards ('winsound') 
%   parallel ports ('parallel')
%   National Instruments ('nidaq')
%   Measurement Computing, Corp., formerly CBI ('mcc')
%   Agilent Technologies ('hpe1432') 
%   Keithley hardware ('keithley')

%%
% You can display information related to your hardware and to 
% MATLAB with the DAQHWINFO command.  
daqinfo = daqhwinfo;

% The returned information includes a list of installed  
% hardware adaptors on your machine.
daqinadapt = daqinfo.InstalledAdaptors;

daqinfo
daqinadapt
%

%%
% If you need to install an adaptor or move an existing  
% adaptor, then it must be manually registered.  A hardware 
% adaptor is manually registered with the command:
% 
%   daqregister('adaptorname')
% 
% where 'adaptorname' is one of the supported hardware 
% adaptors such as: 'winsound', 'nidaq', 'mcc', or 'hpe1432'.
daqregister('winsound')
%

%%
% Now that we know what adaptors are installed on your computer,  
% you can display specific information related to an adaptor  
% by passing the adaptor name to DAQHWINFO. This information 
% includes:
%   - The hardware adaptor DLL filename and its version
%   - The hardware driver description and its version
%   - MATLAB commands for creating a data acquisition object 
%     using the specified adaptor name
daqinfo = daqhwinfo('winsound')
%

%%
% The commands for creating a winsound data acquisition  
% object are listed below. You can create both an analog input 
% object and an analog output object for the winsound adaptor.
daqinfo.ObjectConstructorName{:}
%

%%
% Now that we know the command for creating an analog input 
% object for the winsound adaptor, let's create it.
ai = analoginput('winsound', 0);
ai
%

%%
% By default, the sound card uses 0 as the device id so it  
% does not need to be specified. The following command 
% illustrates this by creating an analog output object for 
% the winsound adaptor.
ao = analogoutput('winsound');
ao
%

%%
% You can find specific information pertaining to the created 
% analog input object or analog output object by passing the 
% object to DAQHWINFO. This information includes:
%   - The number of channels that you can add to the object
%   - The range of sample rates
%   - The native data type
%   - The polarity
daqhwinfo(ai)
%

%%
% And for the analog output object:
daqhwinfo(ao)
%

%%
% By configuring property values for your data acquisition 
% objects, you can control the behavior of your data 
% acquisition application. 
% 
% The Data Acquisition Toolbox device objects (analog input 
% objects, analog output, and digital I/O objects) contain two 
% kinds of properties:
%   1) Base properties
%   2) Device-specific properties
% 
% Base properties apply to all supported hardware subsystems  
% of a given type (analog input, analog output, digital I/O). 
% For example, all analog input objects have a SampleRate 
% property regardless of the hardware vendor. In addition to 
% the base properties, there may be a set of device-specific 
% properties that is determined by the hardware you are using.

%%
% When PROPINFO is called with an object as the input   
% argument, a structure is returned. The field names of 
% the structure are the property names. The field values
% are a structure containing the property information.  
% This information includes:
%   - The property data type
%   - Constraints on the property values
%   - The default property value
%   - Whether the property is read-only
%   - Whether you can modify the property while the object
%     is running.
%   - An indication of whether the property is device-specific
aiInfo = propinfo(ai)
%

%%
% For example, you can obtain information on the SampleRate 
% property with the command listed below. The information 
% returned indicates that the SampleRate property:
%   - Must be a double between the values 8000 and 44100
%   - Has a default value of 8000
%   - Is not read-only
%   - Cannot be modified while the analog input object is 
%     running
%   - Is a base property available to all analog input objects
aiInfo.SampleRate
%

%%
% Alternatively, you can pass a property name to the  
% PROPINFO command. In this case, information for the 
% specified property is returned.
aoOut = propinfo(ao, 'OutOfDataMode')
%

%%
% The information returned indicates that the OutOfDataMode 
% property:
%   - Has a default value of 'Hold'
%   - Is not read-only
%   - Cannot be modified while the analog output object 
%     is running
%   - Is a base property available to all analog output
%     objects
%   - Must be set to one of the following strings:
aoOut.ConstraintValue
%


%%
% A more detailed property description is given with the 
% DAQHELP command. The "See also" section that follows the
% description contains related properties and functions.
% 
% The related properties are displayed using mixed lower and 
% upper case letters. The related functions are displayed  
% using letters all in upper case.
daqhelp OutOfDataMode

%%
daqhelp StartFcn

%%
% DAQHELP can also be used to display Data Acquisition   
% Toolbox function help. This can be useful in 
% accessing a function's help since MATLAB requires 
% that an object's classname be used for commands with 
% multiple instances.
% 
% However without using DAQHELP, the information returned 
% pertains to deleting a file or a graphics object. It does 
% not give information on deleting a data acquisition object.
%
% For example, to obtain help on MATLAB's DELETE command:
help delete

%%
% If an object's classname was known, help on the Data Acquisition 
% Toolbox's DELETE command could be obtained with the following 
% command:  
% 
% help daqdevice/delete
%
% But, by using DAQHELP, you do not have to know an object's   
% classname to get the correct help.
daqhelp delete
delete(ai);
delete(ao);
