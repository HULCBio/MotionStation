%% TCPIP Asynchronous Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.1.2.4 $  $Date: 2004/03/24 20:40:22 $

%% Introduction
% This demo explores asynchronous read and write operations
% using a TCPIP object.
%
% The information obtained for this demonstration was prerecorded.
% Therefore, you do not need an actual instrument  to learn about
% asynchronous TCPIP read and write  operations. The instrument used was a
% SONY/TEKTRONIX AWG520 Arbitrary Waveform Generator.

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
%  ReadAsyncMode  - Specify whether data is read continuously 
%                   in the background or whether you must call
%                   the READASYNC function to read data 
%                   asynchronously.
%
% Additionally, you can use all callback properties during
% asynchronous read and write operations.

%% Synchronous Versus Asynchronous Operations
% The object can operate in synchronous mode or in asynchronous
% mode. When the object is operating synchronously, the read 
% and write routines block the MATLAB command line until
% the operation has completed or a timeout occurs. When the  
% object is operating asynchronously, the read and write
% routines return control immediately to the MATLAB 
% command line. 
% 
% Additionally, you can use callback properties and callback 
% functions to perform tasks as data is being written or
% read. For example, you can create a callback function that 
% notifies you when the read or write operation has finished.

%% Creating a TCPIP Object
% To begin, create a TCPIP object associated with the
% address sonytekawg.mathworks.com, port 4000. The instrument's 
% host IP address, e.g. 192.168.1.10, is user-configurable in
% the instrument. The associated host name is given by your 
% network administrator. The port number is fixed and is found 
% in the instrument's documentation.
%
%  >> t = tcpip('sonytekawg.mathworks.com', 4000);
%  >> t
%
%    TCPIP Object : TCP/IP- sonytekawg.mathworks.com
%
%    Communication Settings 
%       RemotePort:         4000
%       RemoteHost:         sonytekawg.mathworks.com
%       Terminator:         'LF'
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

%% Connecting the TCPIP Object to Your Instrument
% Before you can perform a read or write operation, you must
% connect the TCPIP object to the instrument with the FOPEN 
% function. If the TCPIP object was successfully connected,
% its Status property is automatically configured to open. 
%
%  >> fopen(t)
%  >> get(t, 'Status')
%
%  ans =
%
%  open

%% Reading Data Asynchronously
% You can read data asynchronously with the TCPIP object 
% in one of these two ways: 
%
% * Continuously, by setting ReadAsyncMode to continuous. In
%   this mode, data is automatically stored in the input
%   buffer as it becomes available from the instrument.
% * Manually, by setting ReadAsyncMode to manual. In this
%   mode, you must call the READASYNC function to store data
%   in the input buffer.
% 
% The FSCANF, FREAD, FGETL and FGETS functions are used to
% bring the data from the input buffer into MATLAB. These 
% functions operate synchronously.
%

%% Reading Data Asynchronously -- Continuous ReadAsyncMode
% To begin, lread data continuously.
%
%  >> set(t, 'ReadAsyncMode', 'continuous')
%
% Now, query the instrument for the SCPI version
% number.
%
%  >> fopen(t);
%  >> fprintf(t, 'SYSTEM:VERSION?')
%
% Because the ReadAsyncMode property is set to 'continuous',
% the object is continuously asking the instrument if any data 
% is available. Once the last FPRINTF function completes, the 
% instrument begins sending data, the data is read from the
% instrument and is stored in the input buffer.
%
%  >> get(t, 'BytesAvailable')
%
%  ans =
%
%     7
%
% You can bring the data from the object's input buffer into 
% the MATLAB workspace with FSCANF.
%
%  >> SCPIversion = fscanf(t)
%
%  SCPIversion =
%
%  1995.0

%% Reading Data Asynchronously -- Manual ReadAsyncMode
% Next, read the data manually.
% 
%  >> set(t, 'ReadAsyncMode', 'manual')
%
% Now, query the instrument for the elapsed time
% since powerup.
%
%  >> fprintf(t, 'SYSTEM:UPTIME?')
%
% Once the last FPRINTF function completes, the instrument 
% begins sending data. However, because ReadAsyncMode is set 
% to manual, the object is not reading the data being sent 
% from the instrument. Therefore no data is being read and 
% placed in the input buffer.  
%
%  >> get(t, 'BytesAvailable')
%
%  ans =
% 
%      0
%
% The READASYNC function can asynchronously read the data 
% from the instrument. The READASYNC function returns control
% to the MATLAB command line immediately.
%
% The READASYNC function takes two input arguments. The first
% argument is the instrument object and the second argument is
% the SIZE, the amount of data to be read from the instrument.
% 
% The READASYNC function without a SIZE specified assumes SIZE
% is given by the difference between the InputBufferSize  
% property value and the BytesAvailable property value. The 
% asynchronous read terminates when
%
% * The terminator is read as specified by the Terminator
%   property
% * The specified number of bytes have been read
% * A timeout occurs as specified by the Timeout property.  
% * The input buffer is filled
%
% An error event will be generated if READASYNC terminates due 
% to a timeout.
%
% The object starts querying the instrument for data when the
% READASYNC function is called. Because all the data was sent
% before the READASYNC function call, no data will be stored
% in the input buffer and the data is lost.
% 
%  >> readasync(t);
%  >> get(t, 'BytesAvailable')
% 
%  ans =
% 
%      0
% 
% When the TCPIP object is in manual mode (the ReadAsyncMode
% property is configured to manual), data that is sent from
% the instrument to the computer is not automatically
% stored in the input buffer of the TCPIP object. Data is
% not stored until READASYNC or one of the blocking read
% functions is called.
% 
% Manual mode should be used when a stream of data is being
% sent from your instrument and you only want to capture 
% portions of the data.

%% Defining an Asynchronous Read Callback
% Now, configure our TCPIP object to notify us when
% a terminator has been read.
%
%  >> set(t, 'ReadAsyncMode', 'continuous')
%  >> set(t, 'BytesAvailableFcn', {'dispcallback'})
%
% Note, the default value for the BytesAvailableFcnMode 
% property indicates that the callback function defined by the 
% BytesAvailableFcn property will be executed when the 
% terminator has been read.
%
%  >> get(t, 'BytesAvailableFcnMode')
%
%  ans =
%
%  terminator 
%

%% The Callback Function
% The M-file callback function DISPCALLBACK is defined below.
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
% Now, query the instrument for the LAN address. Once 
% the terminator is read from the instrument and placed in  
% the input buffer, DISPCALLBACK is executed and a message is 
% posted to the MATLAB command window indicating that a BytesAvailable 
% event occurred.
%
%  >> fprintf(t, 'syst:comm:lan:addr?')
%
%  A BytesAvailable event occurred for TCP/IP-sonytekawg.mathworks.com at 21-Jan-2002 17:53:35.
%
%  >> get(t, 'BytesAvailable')
%
%  ans =
%
%     18
%
%  >> data = fscanf(t, '%c', 18)
%
%  data =
%
%  "144.212.113.249"
%
% Note: the last value read is the line feed (10):
%
%  >> real(data)
%
%  ans =
% 
%  Columns 1 through 15 
%
%    34    49    52    52    46    50    49    50    46    49    49    51    46    50    52
%
%  Columns 16 through 18 
%
%    57    34    10

%% Stopping an Asynchronous Read Operation
% Now suppose that halfway through the asynchronous read
% operation, you realize that the data being read from
% the instrument was incorrect. Rather than waiting for the
% asynchronous operation to complete, you can use the 
% STOPASYNC function to stop the asynchronous read. Note 
% that if an asynchronous write was in progress, the 
% asynchronous write operation would also be stopped.
%
%  >> get(t, {'TransferStatus','BytesAvailable'})
%
%  ans = 
%
%    'read'    [125]
%
%  >> stopasync(t);
%  >> get(t, {'TransferStatus', 'BytesAvailable'})
%
%  ans = 
%
%    'idle'    [165]
%
% The data that has been read from the instrument remains in 
% the input buffer. You can use one of the synchronous read
% functions to bring this data into the MATLAB workspace.  
% However, because this data represents the wrong data, 
% the FLUSHINPUT function is called to remove all data 
% from the input buffer.  
%
%  >> flushinput(t);
%  >> get(t, {'TransferStatus', 'BytesAvailable'});
%
%  ans = 
%
%    'idle'    [0]

%% Writing Data Asynchronously
% You can perform an asynchronous write with the FPRINTF or
% FWRITE functions by passing 'async' as the last input 
% argument.
%
%% Defining an Asynchronous Write Callback
% In asynchronous mode, you can use callback properties and 
% callback functions to perform tasks while data is being written. For
% example, configure the object to notify us when 
% an asynchronous write operation completes.
%
%  >> set(t, 'OutputEmptyFcn', {'dispcallback'});
%  >> fprintf(t, 'syst:comm:lan:addr?', 'async')
%
%  A OutputEmpty event occurred for TCP/IP-sonytekawg.mathworks.com at 21-Jan-2002 18:03:05.
%  A BytesAvailable event occurred for TCP/IP-sonytekawg.mathworks.com at 21-Jan-2002 18:03:05.

%% Stopping an Asynchronous Write Operation
% If the STOPASYNC function is called during an asynchronous 
% write operation, the asynchronous write will be stopped
% and the data in the output buffer will automatically be
% flushed. If an asynchronous read operation was also in
% progress, it would also be stopped. However, the data
% in the input buffer would not be flushed automatically.

%% Cleanup
% If you are finished with the TCPIP object, disconnect
% it from the instrument, remove it from memory, and remove
% it from the workspace.
%
%  >> fclose(t);
%  >> delete(t);
%  >> clear t

