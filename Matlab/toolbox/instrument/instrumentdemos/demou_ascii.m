%% UDP ASCII Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.1.2.4 $  $Date: 2004/03/24 20:40:24 $

%% Introduction
% This demo explores ASCII read and write operations with a 
% UDP object. 
% 
% The information obtained for this demonstration was prerecorded.
% Therefore, you do not need an actual instrument to learn about ASCII read
% and write operations using a UDP object. The instrument used was an
% echoserver on a Linux O/S PC. An echoserver is a service available from
% the O/S that returns to the sender's address and port, the same bytes it
% receives from the sender.

%% Functions and Properties
% These functions are used when reading and writing text: 
% 
%  FPRINTF          - Write text to instrument.
%  FSCANF           - Read data from instrument and format as 
%                     text.
% 
% These properties are associated with reading and writing
% text:
% 
%  ValuesReceived   - Specifies the total number of values
%                     read from the instrument.
%  ValuesSent       - Specifies the total number of values 
%                     sent to the instrument.
%  InputBufferSize  - Specifies the total number of bytes 
%                     that can be queued in the input buffer
%                     at one time.
%  OutputBufferSize - Specifies the total number of bytes 
%                     that can be queued in the output buffer
%                     at one time.
%  Terminator       - Character used to terminate commands
%                     sent to the instrument.

%% Creating a UDP Object
% To begin, create a UDP object associated with the
% host name daqlab11, port 7. The host name is assigned by
% your network administrator. Port 7 is the port number for
% the echoserver.
% 
%  >> u = udp('daqlab11', 7);
%  >> u
% 
%    UDP Object : UDP-daqlab11
% 
%    Communication Settings
%       RemotePort:           7
%       RemoteHost:           daqlab11
%       Terminator:           'LF'% 
%  
%    Communication State 
%       Status:               closed
%       RecordStatus:         off
% 
%    Read/Write State  
%       TransferStatus:       idle
%       BytesAvailable:       0
%       ValuesReceived:       0
%       ValuesSent:           0

%% Connecting the UDP Object to the Instrument
% Before you can perform a read or write operation, you must
% connect the UDP object to the instrument with the FOPEN
% function. If the object was successfully connected, its
% Status property is automatically configured to open.
% 
%  >> fopen(u)
%  >> get(u, 'Status')
% 
%  ans =
% 
%  open
%

%% Writing ASCII Data
% You use the FPRINTF function to write ASCII data to the
% instrument. For example, write a string to the
% echoserver.
% 
%  >> fprintf(u, 'Request Time')
% 
% By default, the FPRINTF function operates in a synchronous
% mode. This means that FPRINTF blocks the MATLAB command line
% until one of the following occurs:
%
% * All the data is written
% * A timeout occurs as specified by the Timeout property
%
% By default the FPRINTF function writes ASCII data using 
% the %s\n format. All occurrences of \n in the command 
% being written to the instrument are replaced with the  
% Terminator property value. When using the default format,
% %s\n, all commands written to the instrument will end with 
% the Terminator character. 
% 
% For the previous command, the linefeed (LF) is sent after
% 'Request Time' is written to the instrument, thereby
% indicating the end of the command.
%
% You can also specify the format of the command written by 
% providing a third input argument to FPRINTF. The accepted 
% format conversion characters include: d, i, o, u, x, X, f, 
% e, E, g, G, c, and s.  
% 
% For example, the display command 'Request Time' previously
% shown can be written to the instrument using two calls to
% FPRINTF.
% 
%  >> fprintf(u, '%s', 'Request ');
%  >> fprintf(u, '%s\n', 'Time');
% 
% The Terminator character indicates the end of the command
% and is sent after the last call to FPRINTF.

%% ASCII Write Properties -- OutputBufferSize
% The OutputBufferSize property specifies the maximum number 
% of bytes that can be written to the instrument at once. 
% By default, OutputBufferSize is 512.  
% 
%  >> get(u, 'OutputBufferSize')
% 
%  ans =
% 
%      512
% 
% If the command specified in FPRINTF contains more than 512
% bytes, an error is returned and no data is written to the
% instrument.
% 

%% ASCII Write Properties -- ValuesSent 
% The ValuesSent property indicates the total number of values
% written to the instrument since the object was connected to
% the instrument.
% 
%  >> get(t, 'ValuesSent')
% 
%  ans =
% 
%     26
% 
% Now, remove any data that was returned from the
% echoserver and captured by the UDP object.
% 
%  >> flushinput(u);

%% Reading ASCII Data
% UDP sends and receives data in blocks that are called
% datagrams. Each time you write or read data with a UDP
% object, you are writing or reading a datagram. For
% example, a datagram with 13 bytes (12 ASCII bytes plus
% the LF terminator) is sent to the echoserver.
% 
%  >> fprintf(u, 'Request Time');
% 
% The echoserver will send back a datagram containing the
% same 13 bytes.
% 
% You use the FSCANF function to read ASCII data from the
% instrument.
% 
%  >> data = fscanf(u)
% 
%  data =
% 
%  Request Time
%
% By default, the FSCANF function reads data using the '%c' 
% format and blocks the MATLAB command line until one of the
% following occurs:  
%
% * The terminator is received as specified by the Terminator
%   property (if DatagramTerminateMode is off)
% * A timeout occurs as specified by the Timeout property
% * The input buffer is filled
% * The specified number of values is read (if
%   DatagramTerminateMode is off)
% * A datagram has been received (if DatagramTerminateMode
%   is on)
%
% You can also specify the format of the data read by 
% providing a second input argument to FSCANF. The accepted 
% format conversion characters include: d, i, o, u, x, X, f,
% e, E, g, G, c, and s.
% 
% For example, the string '0.80' sent to the echoserver can
% be read into MATLAB as a double using the %f format string.
% 
%  >> fprintf(u, '0.80')
%  >> data = fscanf(u, '%f')
% 
%  data = 
% 
%       0.8000
%  
%  >> isnumeric(data)
% 
%  ans =
% 
%      1
% 

%% ASCII Read Properties -- DatagramTerminateMode
% The DatagramTerminateMode property indicates whether a read
% operation should terminate when a datagram is received. By
% default DatagramTerminateMode is on, which means that a
% read operation terminates when a datagram is received. To
% read multiple datagrams at once, you can set
% DatagramTerminateMode to off. In this example, two datagrams
% are written. Note, only the second datagram sends the
% Terminator character.
% 
%  >> fprintf(u, '%s', 'Request Time');
%  >> fprintf(u, '%s\n', 'Request Time');
% 
% Since DatagramTerminateMode is off, FSCANF will read across
% datagram boundaries until the Terminator character is 
% received.
% 
%  >> set(u, 'DatagramTerminateMode', 'off')
%  >> data = fscanf(u)
% 
%  data =
% 
%  Request TimeRequest Time

%% ASCII Read Properties -- InputBufferSize
% The InputBufferSize property specifies the maximum number
% of bytes that you can read from the instrument. By default,
% InputBufferSize is 512:
% 
%  >> get(u, 'InputBufferSize')
% 
%  ans =
% 
%      512
% 

%% ASCII Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of 
% values read from the instrument, including the terminator.
% 
%  >> get(u, 'ValuesReceived')
% 
%  ans =
%
%      30

%% Cleanup
% If you are finished with the UDP object, disconnect it from
% the instrument, remove it from memory, and remove it from the
% workspace.
% 
%  >> fclose(u);
%  >> delete(u);
%  >> clear u
