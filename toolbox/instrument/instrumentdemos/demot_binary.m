%% TCPIP Binary Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.1.2.4 $  $Date: 2004/03/24 20:40:23 $

%% Introduction
% This demo explores binary read and write operations with a 
% TCPIP object.
%
% The information obtained for this demonstration was prerecorded.
% Therefore, you do not need an actual instrument  to learn about binary
% read and write operations using a  TCPIP object. The instrument used was
% a SONY/TEKTRONIX AWG520 Arbitrary Waveform Generator.

%% Functions and Properties
% These functions are used when reading and writing binary 
% data: 
%
%  FREAD            - Read binary data from instrument.
%  FWRITE           - Write binary data to instrument.
% 
% These properties are associated with reading and writing
% binary data:
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
%  ByteOrder        - Specifies the byte order of the instrument.

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
%    TCP/IP Object : TCP/IP- sonytekawg.mathworks.com
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

%% Configuring the TCPIP Object -- OutputBufferSize
% The OutputBufferSize property specifies the maximum number
% of bytes that can be written to the instrument at once. By
% default, OutputBufferSize is 512.
% 
%  >> get(t, 'OutputBufferSize')
%  
%  ans =
% 
%      512
% 
% If the command specified in FWRITE contains more than 512
% bytes, an error is returned and no data is written to the
% instrument.
% 
% In this example 2577 bytes will be written to the instrument.
% Therefore, the OutputBufferSize is increased to 3000.
% 
%  >> set(t, 'OutputBufferSize', 3000)
%  >> get(t, 'OutputBufferSize')
% 
%  ans =
% 
%     3000
%

%% Configuring the TCPIP Object -- ByteOrder
% The ByteOrder property specifies the byte order of the
% instrument. By default ByteOrder is bigEndian:
% 
%  >> get(t, 'ByteOrder')
% 
%  ans =
% 
%  bigEndian
% 
% Since the instrument's byte order is little-endian, the
% ByteOrder property of the object is configured to
% littleEndian:
% 
%  >> set(t, 'ByteOrder', 'littleEndian')
%  >> get(t, 'ByteOrder')
% 
%  ans =
% 
%  littleEndian

%% Connecting the TCPIP Object to the Instrument
% Before you can perform a read or write operation, you must
% connect the TCPIP object to the instrument with the 
% FOPEN function. If the object was successfully connected,
% its Status property is automatically configured to open. 
%
%  >> fopen(t)
%  >> get(t, 'Status')
%
%  ans =
%
%  open
%
% Note that the display summary is updated accordingly.
%
%  >> t
%
%    TCP/IP Object : TCP/IP- sonytekawg.mathworks.com
%
%    Communication Settings 
%       Port:               4000
%       RemoteHost:         sonytekawg.mathworks.com
%       Terminator:         'LF'
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

%% Writing Binary Data
% You use the FWRITE function to write binary data to the
% instrument. For example, the following command will send 
% a sine wave to the instrument.
% 
% Construct the sine wave to be written to the instrument.
%
%  >> x = (0:499) .* 8 * pi / 500;
%  >> data = sin(x) ;
%  >> marker = zeros(length(data),1);
%  >> marker(1)=3;
%
% Instruct the instrument to write a file, matsine.wfm,
% with Waveform File format, total length 2544 bytes and
% data length 2500.
%
%  >> fprintf(t,'%s', ['MMEMORY:DATA "matsine.wfm",#42544MAGIC 1000' 13 10]);
%  >> fprintf(t, '%s', '#42500');
%
% Write the sine wave to the instrument.
%
%  >> for (i=1:length(data)),
%       fwrite(t,data(i), 'float32');
%       fwrite(t,marker(i));
%    end;
%
% Instruct the instrument the to use clock frequency of 100MS/s for the
% waveform.
%
%  >> fprintf(t,'%s', ['CLOCK 1.0000000000e+008' 13 10 10]);
%
% By default, the FWRITE function operates in a synchronous
% mode. This means that FWRITE blocks the MATLAB command line
% until one of the following occurs:
%
% * All the data is written
% * A timeout occurs as specified by the Timeout property
%
% By default the FWRITE function writes binary data using 
% the uchar precision. However, the following precisions 
% can also be used:
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
% When performing a write operation, you should think of the 
% transmitted data in terms of values rather than bytes. A 
% value consists of one or more bytes. For example, one uint32  
% value consists of four bytes.

%% Properties Associated with Binary Writes -- ValuesSent
% The ValuesSent property indicates the total number of values
% written to the instrument since the object was connected to
% the instrument.
% 
%  >> get(t, 'ValuesSent')
% 
%  ans =
% 
%     1077

%% Configuring the TCPIP Object -- InputBufferSize
% The InputBufferSize property specifies the maximum number
% of bytes that you can read from the instrument. By default,
% InputBufferSize is 512.  
%
%  >> get(t, 'InputBufferSize')
%
%  ans =
%
%     512
%
% Next, the waveform stored in the function generator's memory
% will be read. The waveform contains 2000 bytes plus, markers,
% header, and clock information. Configure the
% InputBufferSize to hold 3000 bytes. Note, the InputBufferSize
% can be configured only when the object is not connected to
% the instrument.
%
%  >> fclose(t)
%  >> set(t, 'InputBufferSize', 3000)
%  >> get(t, 'InputBufferSize')
%
%  ans =
%
%     3000
%
% Now that the property is configured correctly, you can reopen
% the connection to the instrument:
%
%  >> fopen(t)

%% Reading Binary Data
% You use the FREAD function to read binary data from the 
% instrument. For example, read the file, matsine.wfm, from
% the function generator.
%
%  >> fprintf(t, 'MMEMORY:DATA? "matsine.wfm" ')
%  >> data = fread(t, t.BytesAvailable);
%
% By default, the FREAD function reads data using the uchar
% precision and blocks the MATLAB command line until one of the
% following occurs:  
%
% * A timeout occurs as specified by the Timeout property 
% * The specified number of values is read
% * The InputBufferSize number of values has been read
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

%% Reading float32 Binary Data
% Now, read the same waveform as a float32 array.
%
%  >> fprintf(t, 'MMEMORY:DATA? "matsine.wfm" ')
%
% Read the file header:
%
%  >> header1 = fscanf(t)
%
%  header1 =
%
%  #42544MAGIC 1000
%
% The next six bytes specify the length of data:
%
%  >> header2 = fscanf(t,'%s',6)
%
%  header2 =
%
%  #42500
%
% Note one float32 value consists of four bytes. Therefore,
% the following command will read 2500 bytes:
%
%  >> data = zeros(500,1);
%  >> marker=zeros(500,1);
%  >> for i=1:500,
%       data(i) = fread(t, 1, 'float32');
%       marker(i) = fread(t, 1, 'uint8');
%       end;
%  >> clock = fscanf(t);
%  >> cleanup = fread(t,2);

%% Binary Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of
% values read from the instrument.
%
%  >> get(t, 'ValuesReceived')
%
%  ans =
%
%      3602

%% Cleanup
% If you are finished with the TCPIP object, disconnect
% it from the instrument, remove it from memory, and remove
% it from the workspace.
%
%  >> fclose(t);
%  >> delete(t);
%  >> clear t

