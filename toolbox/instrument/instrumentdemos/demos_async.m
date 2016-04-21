%% Serial Port Asynchronous Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.8.2.4 $  $Date: 2004/03/24 20:40:19 $

%% Introduction
% This demo explores asynchronous read and write operations
% using a serial port object.
%
% The information obtained for this demonstration was prerecorded.
% Therefore, you do not need an actual instrument  to learn about
% asynchronous serial port read and write  operations. The instrument used
% was a Tektronix TDS 210 oscilloscope.

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
% and write routines will block the MATLAB command line until
% the operation has completed or a timeout occurs. When the  
% object is operating asynchronously, the read and write
% routines will return control immediately to the MATLAB 
% command line. 
% 
% Additionally, you can use callback properties and callback 
% functions to perform tasks as data is being written or
% read. For example, you can create a callback function that 
% notifies you when the read or write operation has finished.

%% Creating a Serial Port Object
% To begin, create a serial port object associated
% with the COM2 port. The oscilloscope is configured to a baud 
% rate of 9600, 1 stop bit, a carriage return terminator, no  
% parity, and no flow control.
%
%  >> s = serial('COM2');
%  >> set(s, 'BaudRate', 9600, 'StopBits', 1)
%  >> set(s, 'Terminator', 'CR', 'Parity', 'none')
%  >> set(s, 'FlowControl', 'none');
%  >> s
%
%    Serial Port Object : Serial-COM2
%
%    Communication Settings 
%       Port:               COM2
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

%% Connecting the Serial Port Object to Your Instrument
% Before you can perform a read or write operation, you must
% connect the serial port object to the instrument with the FOPEN 
% function. If the serial port object was successfully connected,
% its Status property is automatically configured to open. 
%
%  >> fopen(s)
%  >> get(s, 'Status')
%
%  ans =
%
%  open

%% Reading Data Asynchronously
% You can read data asynchronously with the serial port object 
% in one of these two ways: 
%
% * Continuously, by setting ReadAsyncMode to continuous. In 
%   this mode, data is automatically stored in the input 
%   buffer as it becomes available from the instrument.
% * Manually, by setting ReadAsyncMode to manual. In this 
%   mode, you must call the READASYNC function to store data
%   in the input buffer.
% 
% The FSCANF, FREAD, FGETL, and FGETS functions are used to 
% bring the data from the input buffer into MATLAB. These 
% functions operate synchronously.

%% Reading Data Asynchronously -- Continuous ReadAsyncMode
% To begin, read data continuously.  
%
%  >> set(s, 'ReadAsyncMode', 'continuous')
%
% Now, query the instrument for the peak-to-peak value
% of the signal on channel 1.
%
%  >> fprintf(s, 'Measurement:Meas1:Source CH1')
%  >> fprintf(s, 'Measurement:Meas1:Type Pk2Pk')
%  >> fprintf(s, 'Measurement:Meas1:Value?')
%
% Since the ReadAsyncMode property is set to 'continuous',
% the object is continuously asking the instrument if any data 
% is available. Once the last FPRINTF function completes, the 
% instrument begins sending data; the data is read from the  
% instrument and is stored in the input buffer.
%
%  >> get(s, 'BytesAvailable')
%
%  ans =
%
%     15
%
% You can bring the data from the object's input buffer into 
% the MATLAB workspace with FSCANF.
%
%  >> data = fscanf(s)
%
%  data =
%
%  4.1199998856E0

%% Reading Data Asynchronously -- Manual ReadAsyncMode
% Next, read the data manually.
% 
%  >> set(s, 'ReadAsyncMode', 'manual')
%
% Now, query the instrument for the frequency of the
% signal on channel 1.
%
%  >> fprintf(s, 'Measurement:Meas2:Source CH1')
%  >> fprintf(s, 'Measurement:Meas2:Type Freq')
%  >> fprintf(s, 'Measurement:Meas2:Value?')
%
% Once the last FPRINTF function completes, the instrument 
% begins sending data. However, since ReadAsyncMode is set 
% to manual, the object is not reading the data being sent 
% from the instrument. Therefore, no data is being read and 
% placed in the input buffer.  
%
%  >> get(s, 'BytesAvailable')
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
% The READASYNC function without a specified SIZE assumes SIZE
% is given by the difference between the InputBufferSize  
% property value and the BytesAvailable property value. The 
% asynchronous read terminates when
%
% * The terminator is read as specified by the Terminator
%   property
% * The specified number of bytes have been read
% * A timeout occurs as specified by the Timeout property 
% * The input buffer is filled
%
% An error event will be generated if READASYNC terminates due 
% to a timeout.
%
% Since all the data has been sent when the READASYNC function
% is called, no data will be stored in the input buffer and the
% data is lost.
% 
%  >> readasync(s);
%  >> s.BytesAvailable
% 
%  ans =
% 
%      0
% 
% It is important to remember that when the serial port object
% is in manual mode (the ReadAsyncMode property is configured
% to manual), data that is sent from the instrument to the 
% computer is not automatically stored in the input buffer of 
% the connected serial port object. Data is not stored until
% READASYNC or one of the blocking read functions is called.
% 
% Manual mode should be used when a stream of data is being 
% sent from your instrument and you only want to capture 
% portions of the data.

%% Defining an Asynchronous Read Callback
% Now, configure our serial object to notify us when
% a terminator has been read.
%
%  >> set(s, 'ReadAsyncMode', 'continuous')
%  >> set(s, 'BytesAvailableFcn', {'dispcallback'})
%
% Note, the default value for the BytesAvailableFcnMode 
% property indicates that the callback function defined by the 
% BytesAvailableFcn property will be executed when the 
% terminator has been read.
%
%  >> get(s, 'BytesAvailableFcnMode')
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
% Now, query the instrument for the period of the signal 
% on channel 1. Once the terminator is read from the instrument
% and placed in the input buffer, DISPCALLBACK is executed and a
% message is posted to the MATLAB command window indicating that
% a BytesAvailable event occurred.
%
%  >> fprintf(s, 'Measurement:Meas3:Source CH1')
%  >> fprintf(s, 'Measurement:Meas3:Type Period')
%  >> fprintf(s, 'Measurement:Meas3:Value?')
%
%  A BytesAvailable event occurred for Serial-COM2 at 29-Dec-1999 17:16:36.
%
%  >> get(s, 'BytesAvailable')
%
%  ans =
%
%     13
%
%  >> data = fscanf(s, '%c', 13)
%
%  data =
%
%  1.0019999E-3
%
% Note: the last value read is the carriage return (13):
%
%  >> real(data)
%
%  ans =
% 
%  Columns 1 through 12 
%
%    49    46    48    48    49    57    57    57    57    69    45    51
%
%  Column 13 
%
%    13


%% Stopping an Asynchronous Read Operation
% Now suppose that halfway through the asynchronous read 
% operation, you realize that the signal displayed on the
% oscilloscope was incorrect. Rather than waiting for the
% asynchronous operation to complete, you can use the 
% STOPASYNC function to stop the asynchronous read. Note 
% that if an asynchronous write was in progress, the 
% asynchronous write operation would also be stopped.
%
%  >> set(s, 'BytesAvailableFcn', '');
%  >> fprintf(s, 'Curve?');
%  >> get(s, {'TransferStatus', 'BytesAvailable'})
%
%  ans = 
%
%    'read'    [146]
%
%  >> stopasync(s);
%  >> get(s, {'TransferStatus', 'BytesAvailable'})
%
%  ans = 
%
%    'idle'    [186]
%
% The data that has been read from the instrument remains in 
% the input buffer. You can use one of the synchronous read
% functions to bring this data into the MATLAB workspace.  
% However, since this data represents the wrong signal, 
% the FLUSHINPUT function is called to remove all data 
% from the input buffer.  
%
%  >> flushinput(s);
%  >> get(s, {'TransferStatus', 'BytesAvailable'});
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
% callback functions to perform tasks as data is written. For
% example, configure the object to notify us when 
% an asynchronous write operation completes.  
%
%  >> set(s, 'OutputEmptyFcn', {'dispcallback'});
%  >> fprintf(s, 'Measurement:Meas3:Value?', 'async')
%
%  A OutputEmpty event occurred for Serial-COM2 at 29-Dec-1999 17:25:48.

%% Stopping an Asynchronous Write Operation
% If the STOPASYNC function is called during an asynchronous 
% write operation, the asynchronous write will be stopped
% and the data in the output buffer will automatically be
% flushed. If an asynchronous read operation was also in
% progress, it would be stopped as well. However, the data
% in the input buffer would not be flushed automatically.

%% Cleanup
% If you are finished with the serial port object, disconnect it 
% from the instrument, remove it from memory, and remove it 
% from the workspace.
%
%  >> fclose(s)
%  >> delete(s)
%  >> clear s
%
