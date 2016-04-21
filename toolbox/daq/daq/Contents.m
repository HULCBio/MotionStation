% Data Acquisition Toolbox
% Version 2.5 (R14) 05-May-2004
%
% Data acquisition object construction.
%   daq/analoginput   - Construct analog input object.
%   daq/analogoutput  - Construct analog output object.
%   daq/digitalio     - Construct digital input/output object.
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
% Analog output functions.
%   addchannel        - Add channels to analog output object.
%   putdata           - Queue data samples for output.
%   putsample         - Immediately output single sample to object.
%
% Digital input/output functions.
%   addline           - Add lines to digital input/output object.
%   getvalue          - Read line values.
%   putvalue          - Write line values.
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
%   daqschool         - Launch command line Data Acquisition Toolbox tutorials.
%   demodaq_callback  - Introduction to data acquisition callback functions.
%   demodaq_intro     - Introduction to Data Acquisition Toolbox.
%   demodaq_save      - Methods for saving and loading data acquisition objects.
%   daqtimerplot      - Example callback function which plots the data acquired.
%
% Analog input demos.
%   daqrecord         - Record data from the specified adaptor.
%   demoai_channel    - Introduction to analog input channels.
%   demoai_fft        - FFT display of an incoming analog input signal.
%   demoai_intro      - Introduction to analog input objects.
%   demoai_logging    - Demonstrate data logging.
%   demoai_trig       - Demonstrate the use of immediate, manual and software 
%                       triggers.
%   daqscope          - Example oscilloscope for the Data Acquisition Toolbox.
%   
% Analog output demos.
%   daqplay           - Output data to the specified adaptor.
%   daqsong           - Output data from HANDEL.MAT to a sound card.
%   demoao_channel    - Introduction to analog output channels.
%   demoao_intro      - Introduction to analog output objects.
%   demoao_trig       - Demonstrate the use of immediate and manual triggers.
%   daqfcngen         - Example function generator for the Data Acquisition Toolbox.
%
% Digital I/O demos.
%    demodio_intro    - Introduction to digital I/O objects.
%    demodio_line     - Introduction to digital I/O lines.
%    diopanel         - Display digital I/O panel.
%
% See also ANALOGINPUT, ANALOGOUTPUT, DIGITALIO, DAQHELP.
%

% MP 5-29-98
% Copyright 1998-2003 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.1.6.1  $Date: 2003/12/04 18:38:35 $

