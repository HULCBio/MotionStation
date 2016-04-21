%% GPIB Asynchronous Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.9.2.4 $  $Date: 2004/03/24 20:40:15 $

%% Introduction
% This demo explores asynchronous read and write operations 
% using a GPIB object. The information obtained for this demonstration 
% was prerecorded. Therefore, you do not need an actual instrument
% to learn about GPIB asynchronous operations. 
% 
% The GPIB board used was a National Instruments PCI-GPIB+ GPIB card.
% 
% The instrument used was a Hewlett Packard 33120A function generator.

%% Functions and Properties
% These functions are associated with reading and writing text 
% asynchronously:
% 
%  FPRINTF         - Write text to instrument.
%  READASYNC       - Asynchronously read bytes from an instrument.
%  STOPASYNC       - Stop an asynchronous read and write operation.
%
% These properties are associated with ASCII read and write 
% asynchronous operations:
% 
%  BytesAvailable  - Indicate the number of bytes available in
%                    the input buffer.
%  TransferStatus  - Indicate what type of asynchronous operation
%                    is in progress.
%
% Additionally, you can use all callback properties during 
% asynchronous read and write operations.


%% Synchronous Versus Asynchronous Operations
% The GPIB object can operate in either synchronous or 
% asynchronous mode. 
%
% In synchronous mode, the MATLAB command line is blocked 
% until
%
% * The read or write operation completes
% * A timeout occurs as specified by the Timeout property
%
% In asynchronous mode, control is immediately returned to
% the MATLAB command line. Additionally, you can use callback 
% properties and callback functions to perform tasks as data 
% is being written or read. For example, you can create a
% callback function that notifies you when the read or write 
% operation has finished.


%% Creating a GPIB Object
% To begin, create a GPIB object. The board index is
% configured to 0, the primary address of the instrument is
% configured to 1.
%
%  >> g = gpib('ni', 0, 1)
%
%    GPIB Object Using NI Adaptor : GPIB0-1
%
%    Communication Address 
%       BoardIndex:         0
%       PrimaryAddress:     1
%       SecondaryAddress:   0
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

%% Connecting the GPIB Object to Your Instrument
% Before you can perform a read or write operation, you must
% connect the GPIB object to the instrument with the FOPEN 
% function. If the GPIB object was successfully connected,
% its Status property is automatically configured to open. 
%
%  >> fopen(g)
%  >> get(g, 'Status')
%
%  ans =
%
%  open
%


%% Reading Data Asynchronously
% You read data asynchronously from the instrument with the
% READASYNC function. For example, query the instrument
% for the signal's voltage and asynchronously read 20 bytes. 
%
%  >> fprintf(g, 'Volt?');
%  >> readasync(g, 20)
%
% If you do not specify the number of bytes to read,
% READASYNC reads up to the difference between the 
% InputBufferSize property value and the BytesAvailable
% property value. 
%
% An asynchronous read terminates when
%
% * The specified number of bytes are stored in the input 
%   buffer
% * The terminator is read as defined by the EOSCharCode 
%   property
% * The EOI line is asserted
% * A timeout occurs as specified by the Timeout property
%
% An error event will occur if READASYNC terminates due to 
% a timeout.


%% Asynchronous Read Properties -- TransferStatus
% The TransferStatus property indicates what type of 
% asynchronous operation is in progress. For GPIB objects, 
% TransferStatus can be read, write, or idle. 
%
%  >> get(g, 'TransferStatus')
%
%  ans = 
%
%  read
%
% While an asynchronous read is in progress, an error occurs
% if you execute another write or asynchronous read operation. 
% You can stop the asynchronous read operation with the  
% STOPASYNC function. STOPASYNC will not flush any data 
% remaining in the input buffer. This allows you to bring 
% the data that was read into the MATLAB workspace with one 
% of the synchronous read functions (FSCANF, FGETL, FGETS, or 
% FREAD).
%

%% Asynchronous Read Properties -- BytesAvailable
% If we now look at the BytesAvailable property, you see that 
% 13 bytes were read. 
%
%  >> get(g, 'BytesAvailable')
%
%  ans =
%
%     13
%
% You can bring the data into the MATLAB workspace with the 
% FSCANF function.
%
%  >> data = fscanf(g, '%g')
%
%  data =
%
%      1


%% Defining an Asynchronous Read Callback
% In asynchronous mode, you can use callback properties and
% callback functions to perform a task as data is read. For
% example, configure the GPIB object to notify you
% when a linefeed has been read. The BytesAvailableFcnMode
% property controls when the BytesAvailable event is created.
% By default, the BytesAvailable event is created when the 
% EOSCharCode character is received. The BytesAvailable event
% can also be created after a certain number of bytes have been 
% read. 
%
% Note: the BytesAvailableFcnMode property cannot be 
% configured while the object is connected to the instrument.
%
%  >> set(g, 'BytesAvailableFcn', {'dispcallback'})
%  >> set(g, 'EOSCharCode', 10);
%

%% The Callback Function
% The M-file callback function, DISPCALLBACK, is defined below.
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
%  fprintf(['A ' event.Type ' event occurred for ' obj.Name ' at ' callbackTime '.\n]);
%

%% Using Callbacks During an Asynchronous Read
% Now, query the instrument for the frequency of the 
% signal. Once the linefeed is read from the instrument and 
% placed in the input buffer, DISPCALLBACK is executed and a 
% message is displayed to the MATLAB command window indicating
% that an event occurred.
%
%  >> fprintf(g, 'Freq?')
%  >> readasync(g)
%
%  A BytesAvailable event occurred for Gpib0-1 at 30-Dec-1999 11:26:22.
%
%  >> get(g, 'BytesAvailable')
%
%  ans =
%
%     19
%
%  >> data = fscanf(g, '%c', 19)
%
%  data =
%
%  +1.00000000000E+03
%
% Note that the last value read is the line feed (10):
%
%  >> real(data)
%
%  ans =
%
%  Columns 1 through 12 
%
%    43    49    46    48    48    48    48    48    48    48    48    48
%
%  Columns 13 through 19 
%
%    48    48    69    43    48    51    10    
%


%% Writing Data Asynchronously
% You can perform an asynchronous write with the FPRINTF or 
% FWRITE functions by passing 'async' as the last input 
% argument. 
%
% While an asynchronous write is in progress, an error occurs 
% if you execute a read or write operation. You can stop an 
% asynchronous write operation with the STOPASYNC function. 
% The data remaining in the output buffer will be flushed.
%


%% Defining an Asynchronous Write Callback
% In asynchronous mode, you can use callback properties and 
% callback functions to perform tasks as data is written. For
% example, configure our GPIB object to notify you when 
% the write operation is complete.
%
%  >> set(g, 'OutputEmptyFcn', {'dispcallback'});
%  >> fprintf(g, 'Func:Shape?', 'async')
%
%  A OutputEmpty event occurred for Gpib0-1 at 30-Dec-1999 12:01:17.
%


%% Cleanup
% If you are finished with the GPIB object, disconnect it 
% from the instrument, remove it from memory, and remove it 
% from the workspace.
%
%  >> fclose(g)
%  >> delete(g)
%  >> clear g
%
