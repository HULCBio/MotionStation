% Data Acquisition Toolbox
%
% Digital Input/Output Functions and Properties.
%
% Data acquisition object construction.
%   daq/digitalio     - Construct digital input/output object.
%
% Getting and setting parameters.
%   daqdevice/get     - Get value of data acquisition object property.
%   daqdevice/set     - Set value of data acquisition object property.
%   setverify         - Set and return value of data acquisition object 
%                       property.                
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
%   daqschool        - Launch command line Data Acquisition Toolbox tutorials.
%   demodaq_callback - Introduction to data acquisition callback functions.
%   demodaq_intro    - Introduction to Data Acquisition Toolbox.
%   demodaq_save     - Methods for saving and loading data acquisition objects.
%   daqtimerplot     - Example callback function which plots the data acquired.
%
% Digital I/O demos.
%    demodio_intro   - Introduction to digital I/O objects.
%    demodio_line    - Introduction to digital I/O lines.
%    diopanel        - Display digital I/O panel.
%
% Digital input/output properties.
%   Line             - Vector of lines contained by object.
%   Name             - Name of object.
%   Running          - Hardware device and data acquisition engine 
%                      running status.
%   Tag              - Label for object.
%   TimerFcn         - Calback function executed every TimerPeriod.
%   TimerPeriod      - Seconds between TimerFcn executions.
%   Type             - Object type.
%   UserData         - User data for object.
%
% PARALLEL specific properties.
%   BiDirectionalBit - Control register bit specifying bidirectional use of
%                      Port 0. (Used only to support nonstandard hardware)
%   PortAddress      - Read-only field identifying the port's base address
%
% See also DAQ, ANALOGINPUT, ANALOGOUTPUT, DAQHELP, PROPINFO.
%

% MP 5-1-98
% Copyright 1998-2003 The MathWorks, Inc.
% $Revision: 1.18.2.6 $  $Date: 2004/04/04 03:24:04 $
