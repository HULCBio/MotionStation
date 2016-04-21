% Data Acquisition Toolbox
%
% Analog Output Functions and Properties.
%
% Data acquisition object construction.
%   daq/analogoutput  - Construct analog output object.
%
% Getting and setting parameters.
%   daqdevice/get     - Get value of data acquisition object property.
%   daqdevice/set     - Set value of data acquisition object property.
%   setverify         - Set and return value of data acquisition object 
%                       property.                
%
% Execution.
%   daqdevice/start   - Start object running.
%   stop              - Stop object running and logging/sending. 
%   trigger           - Manually initiate logging/sending for running object.
%   waittilstop       - Wait for the object to stop running.
%
% Analog output functions.
%   addchannel        - Add channels to analog output object.
%   putdata           - Queue data samples for output.
%   putsample         - Immediately output single sample to object.
%
% General.
%   binvec2dec        - Convert binary vector to decimal number.
%   daq/private/clear - Clear data acquisition object from the workspace. 
%   daqcallback       - Display event information for specified event.
%   daqfind           - Find specified data acquisition objects.
%   daqmem            - Allocate or display memory for one or more device 
%                       objects.
%   daqread           - Read Data Acquisition Toolbox (.daq) data file.
%   daqregister       - Register or unregister adaptor DLLs.
%   daqreset          - Delete and unload all data acquisition objects and 
%                       DLLs.
%   daqdevice/delete  - Remove data acquisition objects from the engine.
%   dec2binvec        - Convert decimal number to binary vector.
%   ischannel         - Determine if object is a channel.
%   isdioline         - Determine if object is a line.
%   isvalid           - Determine if object is associated with hardware.
%   length            - Determine length of data acquisition object.
%   daq/private/load  - Load data acquisition objects from disk into MATLAB
%                       workspace.
%   makenames         - Generate cell array of names for naming channels/lines.
%   obj2mfile         - Convert data acquisition object to MATLAB code.
%   daq/private/save  - Save data acquisition objects to disk.
%   showdaqevents     - Display summary of event log.
%   size              - Determine size of data acquisition object.
%   softscope         - Data Acquisition oscilloscope GUI.
%
% Information and help.
%   daqhelp           - Data acquisition property and function help.
%   daqhwinfo         - Information on available hardware.
%   daqpropedit       - Data acquisition property editor.
%   daqsupport        - Data acquisition technical support tool.
%   propinfo          - Property information for data acquisition objects.
%
% Data acquisition demos.
%   daqschool        - Launch command line Data Acquisition Toolbox tutorials.
%   demodaq_callback - Introduction to data acquisition callback functions.
%   demodaq_intro    - Introduction to Data Acquisition Toolbox.
%   demodaq_save     - Methods for saving and loading data acquisition objects.
%   daqtimerplot     - Example Callback Function which plots the data acquired.
%
% Analog output demos.
%   daqplay          - Output data to the specified adaptor.
%   daqsong          - Output data from HANDEL.MAT to a sound card.
%   demoao_channel   - Introduction to analog output channels.
%   demoao_intro     - Introduction to analog output objects.
%   demoao_trig      - Demonstrate the use of immediate and manual triggers.
%   daqfcngen        - Example function generator for the Data Acquisition Toolbox.
%
% Analog output properties.
%   BufferingConfig          - Specifies the allocated memory per channel.
%   BufferingMode            - How memory is allocated.
%   Channel                  - Vector of channels contained by object.
%   ClockSource              - Clock governing acquisition rate.
%   DataMissedFcn            - Callback Function executed when data is missed.
%   EventLog                 - Log of events while running.
%   InitialTriggerTime       - Observed time of first trigger.
%   MaxSamplesQueued         - Maximum number of samples allowed in queue.
%   Name                     - Name of object.
%   RepeatOutput             - Number of times to repeat output of queued data.
%   Running                  - Hardware device and data acquisition engine 
%                              running status.
%   RuntimeErrorFcn          - Callback Function executed when runtime error 
%                              occurs.     
%   SampleRate               - Output sample rate of hardware device.
%   SamplesAvailable         - Number of samples per channel in queue for 
%                              output.
%   SamplesOutput            - Number of samples per channel that have been 
%                              output.
%   SamplesOutputFcn         - Callback Function executed based on 
%                              SamplesOutputFcnCount.
%   SamplesOutputFcnValue    - Number of samples to send before executing 
%                              SamplesOutputFcn Callback Function. 
%   Sending                  - Indicates data is being output to hardware 
%                              device.
%   StartFcn                 - Callback Function executed before hardware and 
%                              data acquisition engine start.
%   StopFcn                  - Callback Function executed after hardware and 
%                              data acquisition engine stop.
%   Tag                      - Label for object.
%   Timeout                  - Seconds to wait for putdata to return.
%   TimerFcn                 - Callback Function executed every TimerPeriod.
%   TimerPeriod              - Seconds between TimerFcn executions.
%   TriggerFcn               - Callback Function executed when trigger occurs.
%   TriggersExecuted         - Number of triggers that have occurred. 
%   TriggerType              - Type of trigger to be issued.
%   Type                     - Object type.
%   UserData                 - User data for object.
%
% WINSOUND specific properties.
%   BitsPerSample            - Select 8 or 16 bit conversion.
%   StandardSampleRates      - Specifies whether the valid sample rates 
%                              snap to a small set of standard values.
%
% National Instruments specific properties.
%   OutOfDataMode            - Value to send when out-of-data condition occurs.
%   TransferMode             - Specifies how data is transferred to computer 
%                              memory.
% Agilent specific properties.
%   Span                     - Specify the measurement bandwidth.
%
% Measurement Computing specific properties.
%   OutOfDataMode            - Value to send when out-of-data condition occurs.
%   TransferMode             - Specifies how data is transferred to computer 
%                              memory.
%
% Advantech specific properties.
%   TransferMode             - Specifies how data is transferred to computer 
%                              memory.
%
% See also DAQ, ANALOGINPUT, DIGITALIO, DAQHELP, PROPINFO.
%


% MP 5-1-98
% Copyright 1998-2003 The MathWorks, Inc.
% $Revision: 1.18.2.6 $  $Date: 2004/04/04 03:24:02 $

