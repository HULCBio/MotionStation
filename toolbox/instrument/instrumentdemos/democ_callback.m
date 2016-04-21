%% Introduction to Instrument Control Callback Functions
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.2.2.4 $  $Date: 2004/03/24 20:40:10 $

%% Introduction
% This demo explores callback functions and callback properties
% using a serial port object.
%
% The information obtained for this demonstration was pre recorded.
% Therefore, you do not need an actual instrument to learn about callbacks
% and events. The instrument connected  to the serial port object was a
% Tektronix TDS 210  oscilloscope.

%% Overview of Callback Functions and Callback Properties
% When an event occurs, you can execute a related function 
% known as a callback function. An event occurs after a 
% condition is met. The event types supported by all instrument
% objects include
%  
%  Type              Description 
%  ----              ----------- 
%
%  Bytes Available   A predefined amount of data has been 
%                    read from the instrument and stored 
%                    in the input buffer.
%  Error             An error occurred during an asynchronous
%                    operation.
%  Output Empty      The completion of an asynchronous write 
%                    operation. 
%  Timer             A predefined period of time passes.
%
% Callback functions are M-file functions that can perform
% essentially any task during your instrument control session, 
% such as processing data, displaying data, or displaying
% a message. Callbacks are initiated by specifying a callback
% function as the value for a callback property. All event
% types have an associated callback property. A callback 
% function is associated with an event by setting one of 
% the callback properties to the name of the callback function.


%% Callback Properties
% Callbacks Common to All Objects:
%
%  BytesAvailableFcn   - Executed when a specified amount of bytes are available.
%  ErrorFcn            - Executed when an error occurs during an asynchronous operation.
%  OutputEmptyFcn      - Executed when an asynchronous write operation has completed.
%  TimerFcn            - Executed when a predefined period of time passes.
%                        
% Additional Serial Port Callbacks:
%
%  BreakInterruptFcn   - Executed when a break-interrupt occurs.                      
%  PinStatusFcn        - Executed when the CarrierDetect, ClearToSend, 
%                        DataSetReady, or RingIndicator pins change value.
%
% Additional VXI Callbacks:
%
%  InterruptFcn        - Executed when a VXI bus signal or interrupt is received.
%  TriggerFcn          - Executed when a trigger occurs.
%
% Additional UDP Callbacks:
%
%  DatagramReceivedFcn - Callback function executed when a datagram is received.
%

%% Callback Functions
% A callback function can be defined as a string, function
% handle, or cell array.
%
% The following table illustrates the different types of 
% callback functions and how they are evaluated:
%
%      Callback Definition        Callback Evaluation
%      -------------------        -------------------
%      'mycallback'               eval('mycallback')
%      @mycallback                feval(@mycallback, obj, event)
%      {'mycallback', arg1}       feval('mycallback', obj, event arg1)
%      {@mycallback, arg1}        feval(@mycallback, obj, event, arg1)
%
% If the callback function is defined as a string, the string
% is evaluated in the MATLAB workspace when the event occurs.
% The string can be any combination of MATLAB functions. For
% example, 'fclose(obj);delete(obj);'.
%
% If the callback function is defined as a function handle, 
% the object that caused the event and an event structure
% is automatically passed to the function represented by the
% function handle.
%
% If the callback function is defined as a cell array,
% the first element of the cell array must be either a string
% or a function handle. The object that caused the event and 
% an event structure are passed to the function defined by the
% first element of the cell array along with the remaining 
% elements of the cell array. 

%% Create a Serial Port Object
% To begin, create a serial port object associated with
% the COM1 port. A TDS 210 Tektronix oscilloscope is connected 
% to the COM1 port.  
%
%  >> s = serial('COM1');
%
% The oscilloscope is configured for no flow control, no 
% parity checking, a baud rate of 9600, and a carriage return 
% terminator.  
%
%  >> set(s, 'FlowControl', 'none');
%  >> set(s, 'Terminator', 'CR', 'Parity', 'none')
%  >> s
%
%    Serial Port Object : Serial-COM1
%
%    Communication Settings 
%       Port:               COM1
%       BaudRate:           9600
%       Terminator:         'CR'
%
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0

%% Connect the Serial Port Object to the Instrument
% Before you can read or write data, you must connect the
% serial port object to the instrument with the FOPEN function.
% If the serial port object was successfully connected, its
% Status property is automatically configured to open.
%
%  >> fopen(s)
%  >> s
%
%    Serial Port Object : Serial-COM1
%
%    Communication Settings 
%       Port:               COM1
%       BaudRate:           9600
%       Terminator:         'CR'
%
%    Communication State 
%       Status:             open
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0

%% Example 1: Using Callbacks
% Next, create the M-file callback function 
% DISPCALLBACK, which displays the event and time of  
% the event to the MATLAB command window. 
%
% Since we are interested in the event information, the
% callback property must be defined as either a function
% handle or a cell array so that the event structure
% is passed automatically to the callback function.
%
% In this case, the callback function must have at least 
% two input arguments. The first input argument is the 
% object that caused the event to occur. The second input 
% argument is a structure containing information regarding 
% the event that occurred.
%
%  >> type dispcallback
%
%  function dispcallback(obj, event)
%  %DISPCALLBACK Display event information for the specified event.
%  % 
%  %    DISPCALLBACK(OBJ, EVENT) a callback function that displays  
%  %    a message containing the type of the event, the name 
%  %    of the object that caused the event to occur, and the 
%  %    time the event occurred. 
%  % 
%  %    See also INSTRCALLBACK.
%
%  callbackTime = datestr(datenum(event.Data.AbsTime));
%  fprintf(['A ' event.Type ' event occurred for ' obj.Name ' at ' callbackTime '.\\n']);

%% Configure the Callback Properties
% Now, configure the object to acquire data continuously
% and to notify you when a BytesAvailable, OutputEmpty, or Error
% event occurs.
%
%  >> set(s, 'ReadAsyncMode', 'continuous');
%  >> set(s, 'BytesAvailableFcn', {'dispcallback'});
%  >> set(s, 'OutputEmptyFcn', {'dispcallback'});
%  >> set(s, 'ErrorFcn', {'dispcallback'});

%% Execute the Callback Function
% To execute DISPCALLBACK, write the 'RS232?' command 
% to the oscilloscope. This command will query the RS-232 
% settings. It returns the BaudRate, the software flow control
% setting, the hardware flow control setting, the parity, and 
% the terminator. 
% 
% Because the object is reading continuously, the data is read 
% from the oscilloscope as soon as it is available (after the
% asynchronous write command finished executing). The data 
% read from the oscilloscope is placed in the input buffer. 
% The amount of data in the input buffer is given by the 
% BytesAvailable property. Once the terminator is read from 
% the oscilloscope, the bytes available callback is executed.
% The data can be brought into the MATLAB workspace with the
% FSCANF function.
%
%  >> fprintf(s, 'RS232?', 'async');
%
%  A OutputEmpty event occurred for Serial-COM1 at 20-Dec-1999 16:12:00.
%  A BytesAvailable event occurred for Serial-COM1 at 20-Dec-1999 16:12:00.
%
%  >> get(s, 'BytesAvailable')
%
%  ans =
%
%    16
%
%  >> fscanf(s)
%
%  ans =
%
%  9600;0;0;NON;CR
%
%  >> fclose(s)

%% Example 2: Using Callbacks with Additional Input Arguments
% You can construct callback functions to accept additional 
% input arguments. For example, if you want to pass the 
% arguments 'range1' and 'range2' to the M-file callback, 
% function MYCALLBACK, define the callback property 
% as follows.
%
%  >> set(s, 'OutputEmptyFcn', {'mycallback', range1, range2});
%
% The callback function would have the following function line.
%
%  function mycallback(obj, event, range1, range2)
%
% Create a simple callback function that takes two
% additional input arguments. The callback function 
% SIMPLECALLBACK is created to sum two input values and  
% assign the resulting value to the UserData property.  
%
%  >> type simplecallback
%
%  function simplecallback(obj, event, value1, value2)
%  %SIMPLECALLBACK Callback function for modifying object's UserData.
%  %
%  %    SIMPLECALLBACK(OBJ, EVENT, VALUE1, VALUE2) sets OBJ's
%  %    UserData property to value1+value2.
%  %
% 
%  set(obj, 'UserData', value1+value2);

%% Configure the Callback Properties
%
% Using the same serial port object, configure the
% BytesAvailableFcn property to execute 'simplecallback'
% when 10 bytes are available in the object's input buffer.
%
%  >> set(s, 'BytesAvailableFcn', {'simplecallback', 4, 10});
%  >> set(s, 'BytesAvailableFcnCount', 10);
%  >> set(s, 'BytesAvailableFcnMode', 'byte');
%  >> set(s, 'OutputEmptyFcn', '');
%  >> set(s, 'ErrorFcn', '');

%% Execute the Callback Function
% SIMPLECALLBACK executes when 10 bytes are available.
%
%  >> fopen(s)
%  >> fprintf(s, 'Display:Contrast?')
%  >> get(s, 'BytesAvailable')
%
%  ans =
%
%     3
%
%  >> get(s, 'UserData')
%
%  ans =
%
%     []
%
%  >> fprintf(s, 'RS232?')
%  >> get(s, 'BytesAvailable')
%
%  ans =
%
%     19
%
%  >> get(s, 'UserData')
%
%  ans =
%
%    14

%% Cleanup
%
% If you are finished with the serial port object, disconnect 
% it from the instrument, remove it from memory, and remove 
% it from the workspace.
%
%  >> fclose(s) 
%  >> delete(s)
%  >> clear s

