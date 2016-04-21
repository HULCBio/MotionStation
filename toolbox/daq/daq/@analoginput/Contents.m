% Data Acquisition Toolbox
%
% Analog Input Functions and Properties.
%
% Data acquisition object construction.
%   daq/analoginput   - Construct analog input object.
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
% Analog input functions.
%   addchannel        - Add channels to analog input object.
%   addmuxchannel     - Add mux'd channels to analog input object.
%   flushdata         - Remove data from engine.
%   getdata           - Return acquired data samples.
%   getsample         - Immediately acquire a single sample.
%   muxchanidx        - Return scan channel index associated with mux board.
%   peekdata          - Preview most recent acquired data.
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
%   daqtimerplot     - Example callback function which plots the data acquired.
%
% Analog input demos.
%   daqrecord        - Record data from the specified adaptor.
%   demoai_channel   - Introduction to analog input channels.
%   demoai_fft       - FFT display of an incoming analog input signal.
%   demoai_intro     - Introduction to analog input objects.
%   demoai_logging   - Demonstrate data logging.
%   demoai_trig      - Demonstrate the use of immediate, manual and software 
%                      triggers.
%   daqscope         - Example oscilloscope for the Data Acquisition Toolbox.
%   
% Analog input properties.
%   BufferingConfig            - Specifies the allocated memory per channel.
%   BufferingMode              - How memory is allocated.
%   Channel                    - Vector of channels contained by object.
%   ChannelSkew                - Time between consecutive scanned hardware 
%                                channels.
%   ChannelSkewMode            - Hardware specific channel skew mode.
%   ClockSource                - Clock governing the acquisition rate.
%   DataMissedFcn              - Callback function executed when data is missed.
%   EventLog                   - Log of events while running.
%   InitialTriggerTime         - Observed time of first trigger.
%   InputOverRangeFcn          - Callback function executed when channel exceeds 
%                                its valid range.  
%   InputType                  - Single-ended or differential hardware 
%                                configuration.
%   LogFileName                - Name of disk file that data/events are written
%                                to.
%   Logging                    - Indicates whether data is logged.
%   LoggingMode                - Specifies where data is logged.  
%   LogToDiskMode              - Specifies multiple or single file logging.
%   ManualTriggerHwOn          - Specify that the hardware device starts when 
%                                a manual trigger is issued
%   Name                       - Name of object.
%   Running                    - Hardware device and data acquisition engine 
%                                running status.
%   RuntimeErrorFcn            - Callback function executed when runtime error 
%                                occurs.     
%   SampleRate                 - Sampling rate of the hardware device.
%   SamplesAcquired            - Number of samples acquired per channel.
%   SamplesAcquiredFcn         - Callback function executed based on 
%                                SamplesAcquiredFcnCount.
%   SamplesAcquiredFcnCount    - Number of samples to be acquired before 
%                                executing SamplesAcquiredFcn callback. 
%   SamplesAvailable           - Number of samples available per channel.
%   SamplesPerTrigger          - Number of samples to acquire per channel for
%                                each trigger.
%   StartFcn                   - Callback function executed before hardware and 
%                                data acquisition engine start.
%   StopFcn                    - Callback function executed after hardware and
%                                data acquisition engine stop.
%   Tag                        - Label for object.
%   Timeout                    - Seconds to wait for trigger.
%   TimerFcn                   - Callback function executed every TimerPeriod.
%   TimerPeriod                - Seconds between TimerFcn executions.
%   TriggerChannel             - Array of hardware channels serving as trigger
%                                sources.
%   TriggerCondition           - Condition to be satisfied before trigger is 
%                                issued.
%   TriggerConditionValue      - Value of trigger condition.
%   TriggerDelay               - Delay value for data logging.
%   TriggerDelayUnits          - Specifies trigger delay as samples or seconds.
%   TriggerFcn                 - Callback function executed when trigger occurs.
%   TriggerRepeat              - Number of times to repeat trigger.
%   TriggersExecuted           - Number of triggers that have occurred. 
%   TriggerType                - Type of trigger to be issued.
%   Type                       - Object type.
%   UserData                   - User data for object.
%
% WINSOUND specific properties.
%   BitsPerSample              - Select 8 or 16 bit conversion.
%   StandardSampleRates        - Specifies whether the valid sample rates 
%                                snap to a small set of standard values.
%
% National Instruments specific properties.
%   DriveAISenseToGround       - Specifies whether to drive AISENSE to onboard 
%                                ground.
%   NumMuxBoards               - Number of external multiplexer devices 
%                                connected.
%   TransferMode               - Specifies how data is transferred to computer
%                                memory.
%
% Agilent specific properties.
%   Span                       - Specify the measurement bandwidth.
%
% Measurement Computing and Advantech specific properties.
%   TransferMode               - Specifies how data is transferred to computer
%                                memory.
%
% See also DAQ, ANALOGOUTPUT, DIGITALIO, DAQHELP, PROPINFO.
%

% MP 5-1-98
% Copyright 1998-2003 The MathWorks, Inc.
% $Revision: 1.18.2.6 $  $Date: 2004/04/04 03:24:00 $
