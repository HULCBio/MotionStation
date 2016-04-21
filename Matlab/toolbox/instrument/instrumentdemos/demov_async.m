%% VISA Asynchronous Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.9.2.6 $  $Date: 2004/03/24 20:40:28 $

%% Introduction
% This demo explores asynchronous read and write operations
% using a VISA-GPIB-VXI object.
% 
% The information obtained for this tutorial was prerecorded. Therefore,
% you do not need an actual instrument to learn about asynchronous read and
% write operations for VISA objects. 
% 
% The instruments used included an Agilent E1406A command module in VXI
% slot 0 and an Agilent E1441A instrument in VXI slot 1.  
% 
% The HP E1406A is a GPIB controller and it is connected 
% to a GPIB board. The HP E1441A is a function/arbitrary
% waveform generator. The GPIB controller will communicate
% with the HP E1441A function generator over the VXI 
% backplane.

%% The Supported VISA Interfaces
% The VISA object supports seven interfaces:
%
% * serial
% * GPIB
% * VXI
% * GPIB-VXI
% * TCPIP
% * USB
% * RSIB
% 
% This tutorial explores asynchronous read and write operations
% for a VISA-GPIB-VXI object. However, asynchronous read and 
% write operations for VISA-GPIB, VISA-VXI, VISA-GPIB-VXI, 
% VISA-TCPIP, and VISA-USB objects are identical to each other. 
% Therefore, you can use the same commands. The only difference
% is the resource name specified in the VISA constructor.
% 
% Asynchronous read and write operations for the VISA-serial 
% object are identical to asynchronous read and write operations
% for the serial port object. Therefore, to learn how to perform
% asynchronous read and write operations for the VISA-serial
% object, you should refer to the Serial Port Asynchronous
% Read/Write tutorial.
% 
% Asynchronous read and write operations are not supported
% for the VISA-RSIB object.

%% Functions and Properties
% These functions are associated with reading and writing text 
% asynchronously:
% 
%  FPRINTF        - Write text to instrument.
%  READASYNC      - Asynchronously read bytes from an instrument.
%  STOPASYNC      - Stop an asynchronous read and write operation.
% 
% These properties are associated with ASCII read and write 
% asynchronous operations:
% 
%  BytesAvailable - Indicate the number of bytes available in
%                   the input buffer.
%  TransferStatus - Indicate what type of asynchronous operation
%                   is in progress.
% 
% Additionally, you can use all callback properties during
% asynchronous read and write operations.

%% Synchronous Versus Asynchronous Operations
% The VISA object can operate in either synchronous or 
% asynchronous mode. 
% 
% In synchronous mode, the MATLAB command line is blocked
% until
%
% * The read or write operation completes  
% * A timeout occurs as specified by the Timeout property
% 
% In asynchronous mode, control is immediately returned to the 
% MATLAB command line. Additionally, you can use callback 
% properties and callback functions to perform tasks as data
% is being written or read. For example, you can create a 
% callback function that notifies you when the read or write
% operation has finished.

%% Creating a VISA Object
% To begin, create a VISA-GPIB-VXI object. The HP
% E1441A instrument is configured with a logical address
% of 80 and is in the first chassis.
% 
%  >> v = visa('agilent', 'GPIB-VXI0::80::INSTR')
% 
%    VISA-GPIB-VXI Object Using AGILENT Adaptor : VISA-GPIB-VXI0-80
% 
%    Communication Address 
%       ChassisIndex:       0
%       LogicalAddress:     80
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

%% Connecting the VISA Object to Your Instrument
% Before you can perform a read or write operation, you
% must connect the VISA-GPIB-VXI object to the instrument 
% with the FOPEN function. If the object was successfully
% connected, its Status property is automatically configured
% to open, otherwise the Status property remains configured
% to closed.
% 
%  >> fopen(v)
%  >> get(v, 'Status')
%
%  ans =
%
%  open
%

%% Reading Data Asynchronously
% The VISA-GPIB-VXI object's asynchronous read functionality 
% is controlled with the READASYNC function.Query
% the instrument for the signal's voltage:
% 
%  >> fprintf(v, 'Volt?');
% 
% The READASYNC function can asynchronously read the data 
% from the instrument. The READASYNC function returns control
% to the MATLAB command prompt immediately.
% 
%  >> readasync(v, 20)
% 
% The READASYNC function without a SIZE specified will assume
% SIZE is given by the difference between the InputBufferSize
% property value and the BytesAvailable property value. In the 
% above example, SIZE is 20. The asynchronous read terminates
% when one of the following occurs: 
%
% * The specified number of bytes are stored in the input 
%   buffer
% * The terminator has been read as specified by the EOSCharCode
%   property
% * The EOI line has been asserted 
% * A timeout occurs as specified by the Timeout property
% 
% An error event will be generated if READASYNC terminates due 
% to a timeout.

%% Asynchronous Read Properties -- TransferStatus
% The TransferStatus property indicates what type of 
% asynchronous operation is in progress. For VISA-GPIB-VXI
% objects, TransferStatus can be configured as read, write,
% or idle.
% 
%  >> get(v, 'TransferStatus')
% 
%  ans = 
% 
%  read
% 
% While an asynchronous read is in progress, an error occurs
% if you execute another write or asynchronous read operation. 
% You can stop the asynchronous read operation with the 
% STOPASYNC function. The data in the input buffer will 
% remain after STOPASYNC is called. This allows you to
% bring the data that was read into the MATLAB workspace
% with one of the synchronous read routines (FSCANF, FGETL,
% FGETS, or FREAD).

%% Asynchronous Read Properties - BytesAvailable
% If you look at the BytesAvailable property, you see
% that 13 bytes have been read. The data can be brought
% into the MATLAB workspace with the FSCANF function. 
% 
%  >> get(v, 'BytesAvailable')
% 
%  ans =
% 
%     13
% 
%  >> data = fscanf(v)
% 
%  data =
% 
%  +2.00000E+00

%% Defining an Asynchronous Read Callback
% Now, configure our VISA-GPIB-VXI object to notify
% you when a line feed has been read. The BytesAvailableFcnMode
% property controls when the BytesAvailable event is created.
% By default, the BytesAvailable event is created when the 
% EOSCharCode character is received. The BytesAvailable event
% can also be created after a certain number of bytes have been 
% read. Note: the BytesAvailableFcnMode property cannot be 
% configured while the object is connected to the instrument.
% 
%  >> set(v, 'BytesAvailableFcn', {'dispcallback'})
%  >> set(v, 'EOSCharCode', 10);

%% The Callback Function
% The DISPCALLBACK callback function is defined as follows.
% 
%  function dispcallback(obj, event)
%  %DISPCALLBACK Display event information for the specified event.
%  % 
%  %    DISPCALLBACK(OBJ, EVENT) a callback function that displays  
%  %    a message which contains the type of the event, the name 
%  %    of the object which caused the event to occur and the 
%  %    time the event occurred.
%  %
%  %    See also INSTRCALLBACK.
% 
%  callbackTime = datestr(datenum(event.Data.AbsTime));
%  fprintf(['A ' event.Type ' event occurred for ' obj.Name ' at ' callbackTime '.\n']);

%% Using Callbacks During an Asynchronous Read
% Now, query the instrument for the frequency of the
% signal. Once the linefeed has been read from the instrument
% and placed in the input buffer, DISPCALLBACK will be executed 
% and a message will be displayed to the MATLAB command window
% indicating that a BytesAvailable event occurred.
% 
%  >> fprintf(v, 'Freq?')
%  >> readasync(v)
% 
%  A BytesAvailable event occurred for VISA-GPIB-VXI0-80 at 30-Dec-1999 03:48:18.
% 
%  >> get(v, 'BytesAvailable')
% 
%  ans =
% 
%     19
% 
%  >> data = fscanf(v, '%c', 19)
% 
%  data =
% 
%  +1.00000000000E+03
% 
% Note: the last value read is the line feed (10):
% 
%  >> real(data)
% 
%  ans =
% 
%   Columns 1 through 12 
% 
%     43    49    46    48    48    48    48    48    48    48    48    48
% 
%   Columns 13 through 19 
% 
%     48    48    69    43    48    51    10    

%% Writing Data Asynchronously
% You can perform an asynchronous write with the FPRINTF 
% or FWRITE functions by passing an 'async' flag as the
% last input argument. 
% 
% While an asynchronous write is in progress, an error occurs 
% if you execute a read or write operation. You can stop an 
% asynchronous write operation with the STOPASYNC function. 
% The data remaining in the output buffer will be flushed.
%

%% Defining an Asynchronous Write Callback
% Also configure the object to notify you when the
% write operation has completed.  
% 
%  >> set(v, 'OutputEmptyFcn', {'dispcallback'});
%  >> fprintf(v, 'Func:Shape?', 'async')
% 
%  A OutputEmpty event occurred for VISA-GPIB-VXI0-80 at 30-Dec-1999 3:52:33.
% 

%% Cleanup
% If you are finished with the VISA-GPIB-VXI object, disconnect 
% it from the instrument, remove it from memory, and remove it
% from the workspace.
% 
%  >> fclose(v)
%  >> delete(v)
%  >> clear v

