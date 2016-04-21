%% UDP Binary Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.1.2.4 $  $Date: 2004/03/24 20:40:26 $

%% Introduction
% This demo explores binary read and write operations with a 
% UDP object.
% 
% The information obtained for this demonstration was prerecorded.
% Therefore, you do not need an actual instrument to learn about binary
% read and write operations using a UDP object. The instrument used was an
% echoserver on a Linux O/S PC. An echoserver is a service available from
% the O/S that returns to the sender's address and port, the same bytes it
% receives from the sender.

%% Functions and Properties
% These functions are used when reading and writing binary 
% data: 
% 
%  FREAD                 - Read binary data from instrument.
%  FWRITE                - Write binary data to instrument.
% 
% These properties are associated with reading and writing
% binary data:
% 
%  ValuesReceived        - Specifies the total number of values
%                          read from the instrument.
%  ValuesSent            - Specifies the total number of values 
%                          sent to the instrument.
%  InputBufferSize       - Specifies the total number of bytes 
%                          that can be queued in the input buffer
%                          at one time.
%  OutputBufferSize      - Specifies the total number of bytes 
%                          that can be queued in the output 
%                          buffer at one time.
%  DatagramTerminateMode - defines how FREAD and FSCANF read 
%                          operations terminate.

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
% 

%% Configuring the UDP Object -- OutputBufferSize
% The OutputBufferSize property specifies the maximum number
% of bytes that can be written to the instrument at once. By
% default, OutputBufferSize is 512.
% 
%  >> get(u, 'OutputBufferSize')
% 
%  ans =
% 
%       512
% 
% If the command specified in FWRITE contains more than 512
% bytes, an error is returned and no data is written to the
% instrument.
%    
% In this example 1000 bytes will be written to the instrument.
% Therefore, the OutputBufferSize is increased to 1000.
% 
%  >> set(u, 'OutputBufferSize', 1000)
%  >> get(u, 'OutputBufferSize')
% 
%  ans =
% 
%      1000

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
% Note that the display summary is updated accordingly.
% 
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
%       Status:               open
%       RecordStatus:         off
% 
%    Read/Write State  
%       TransferStatus:       idle
%       BytesAvailable:       0
%       ValuesReceived:       0
%       ValuesSent:           0

%% Writing Binary Data
% You use the FWRITE function to write binary data to the
% instrument.
%
% By default, the FWRITE function operates in a synchronous
% mode. This means that FWRITE blocks the MATLAB command line
% until one of the following occurs:
%
% * All the data is written
% * A timeout occurs as specified by the Timeout property
%
% By default the FWRITE function writes binary data using the
% uchar precision. However, the following precisions can also 
% be used:
% 
%     MATLAB           Description
%     'uchar'          unsigned character,  8 bits.
%     'schar'          signed character,    8 bits.
%     'int8'           integer,             8 bits.
%     'int16'          integer,             16 bits.
%     'int32'          integer,             32 bits.
%     'uint8'          unsigned integer,    8 bits.
%     'uint16'         unsigned integer,    16 bits.
%     'uint32'         unsigned integer,    32 bits.
%     'single'         floating point,      32 bits.
%     'float32'        floating point,      32 bits.
%     'double'         floating point,      64 bits.
%     'float64'        floating point,      64 bits.
%     'char'           character,           8 bits (signed or unsigned).
%     'short'          integer,             16 bits.
%     'int'            integer,             32 bits.
%     'long'           integer,             32 or 64 bits.
%     'ushort'         unsigned integer,    16 bits.
%     'uint'           unsigned integer,    32 bits.
%     'ulong'          unsigned integer,    32 bits or 64 bits.
%     'float'          floating point,      32 bits.
% 
% UDP sends and receives data in blocks that are called
% datagrams. Each time you write or read data with a UDP
% object, you are writing or reading a datagram. In the
% example below, a datagram with 1000 bytes, 4 bytes per
% integer number, will be sent to the echoserver.
% 
%  >> fwrite(u, 1:250, 'int32');
% 

%% Values Versus Bytes
% When performing a write operation, you should think of the 
% transmitted data in terms of values rather than bytes. A 
% value consists of one or more bytes. For example, one uint32  
% value consists of four bytes.

%% Properties Associated With Binary Writes -- ValuesSent
% The ValuesSent property indicates the total number of values
% written to the instrument because the object was connected to
% the instrument.
% 
%  >> get(u, 'ValuesSent')
% 
%  ans =
% 
%     250

%% Configuring the UDP Object -- InputBufferSize
% The InputBufferSize property specifies the maximum number
% of bytes that you can read from the instrument. By default,
% InputBufferSize is 512.  
% 
%  >> get(u, 'InputBufferSize')
% 
%  ans =
% 
%      512
%
% In the next example, 1000 bytes will be read from the 
% instrument. Configure the InputBufferSize to hold
% 1000 bytes. Note, the InputBufferSize can be configured only
% when the object is not connected to the instrument.
% 
%  >> fclose(u)
%  >> set(u, 'InputBufferSize', 1000)
%  >> get(u, 'InputBufferSize')
% 
%  ans =
% 
%      1000
% 
% Now that the object is configured to hold the data, you can
% reopen the connection to the instrument:
% 
%  >> fopen(u)

%% Reading Binary Data
% You use the FREAD function to read binary data from the 
% instrument. 
%
% By default, the FREAD function blocks the MATLAB command
% line until one of the following occurs:  
%
% * A timeout occurs as specified by the Timeout property
% * The input buffer is filled
% * The specified number of values is read. (if
%   DatagramTerminateMode is off)
% * A datagram has been received (if DatagramTerminateMode
%   is on)
%
% By default the FREAD function reads data using the uchar 
% precision. However, the following precisions can also be
% used:
% 
%     MATLAB           Description
%     'uchar'          unsigned character,  8 bits.
%     'schar'          signed character,    8 bits.
%     'int8'           integer,             8 bits.
%     'int16'          integer,             16 bits.
%     'int32'          integer,             32 bits.
%     'uint8'          unsigned integer,    8 bits.
%     'uint16'         unsigned integer,    16 bits.
%     'uint32'         unsigned integer,    32 bits.
%     'single'         floating point,      32 bits.
%     'float32'        floating point,      32 bits.
%     'double'         floating point,      64 bits.
%     'float64'        floating point,      64 bits.
%     'char'           character,           8 bits (signed or unsigned).
%     'short'          integer,             16 bits.
%     'int'            integer,             32 bits.
%     'long'           integer,             32 or 64 bits.
%     'ushort'         unsigned integer,    16 bits.
%     'uint'           unsigned integer,    32 bits.
%     'ulong'          unsigned integer,    32 bits or 64 bits.
%     'float'          floating point,      32 bits.

%% Values Versus Bytes
% When performing a read operation, you should think of the 
% received data in terms of values rather than bytes. A value 
% consists of one or more bytes. For example, one uint32 value
% consists of four bytes.

%% Reading int32 Binary Data
% Read binary data from the instrument. For example,
% read one datagram consisting of 250 integers from
% the instrument.
% 
%  >> fwrite(u, 1:250, 'int32');
%  >> data = fread(u, 250, 'int32');
% 

%% Binary Read Properties -- DatagramTerminateMode
% The DatagramTerminateMode property indicates whether a read
% operation should terminate when a datagram is received. By
% default DatagramTerminateMode is on, which means that a
% read operation terminates when a datagram is received. To
% read multiple datagrams at once, you can set
% DatagramTerminateMode to off. In this example, two datagrams
% are written to the echoserver.
% 
%  >> fwrite(u, 1:125, 'int32');
%  >> fwrite(u, 1:125, 'int32');
% 
% Because DatagramTerminateMode is off, FREAD will read across
% datagram boundaries until 250 integers have been received.
% 
%  >> set(u, 'DatagramTerminateMode', 'off')
%  >> data = fread(u, 250, 'int32');
%  >> size(data)
% 
%  ans =
% 
%    250     1


%% Binary Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of
% values read from the instrument.
% 
%  >> get(u, 'ValuesReceived')
% 
%  ans =
% 
%     250

%% Cleanup
% If you are finished with the UDP object, disconnect
% it from the instrument, remove it from memory, and remove
% it from the workspace.
% 
%  >> fclose(u);
%  >> delete(u);
%  >> clear u

