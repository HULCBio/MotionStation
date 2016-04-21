%% Serial Port Binary Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.6.2.4 $  $Date: 2004/03/24 20:40:20 $

%% Introduction
% This demo explores binary read and write operations with a 
% serial port object.
%
% The information obtained for this demonstration was prerecorded.
% Therefore, you do not need an actual instrument  to learn about binary
% read and write operations using a  serial port object. The instrument
% used was a Tektronix TDS  210 oscilloscope.

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

%% Creating a Serial Port Object
% To begin, create a serial port object associated 
% with the COM2 port.  
%
%  >> s = serial('COM2');
%  >> s
%
%    Serial Port Object : Serial-COM2
%
%    Communication Settings 
%       Port:               COM2
%       BaudRate:           9600
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

%% Connecting the Serial Port Object to the Instrument
% Before you can perform a read or write operation, you must
% connect the serial port object to the instrument with the 
% FOPEN function. If the object was successfully connected,
% its Status property is automatically configured to open. 
%
%  >> fopen(s)
%  >> get(s, 'Status')
%
%  ans =
%
%  open
%
% Note that the display summary is updated accordingly.
%
%  >> s
%
%    Serial Port Object : Serial-COM2
%
%    Communication Settings 
%       Port:               COM2
%       BaudRate:           9600
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
% a sine wave to the oscilloscope:
% 
%  >> fprintf(s, 'Data:Destination RefA');
%  >> fprintf(s, 'Data:Encdg SRPbinary');
%  >> fprintf(s, 'Data:Width 1');
%  >> fprintf(s, 'Data:Start 1');
% 
%  >> t = (0:499) .* 8 * pi / 500;
%  >> data = round(sin(t) * 90 + 127);
%  >> fprintf(s, 'CURVE #3500');
%  >> fwrite(s, data)
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
%     'uchar          unsigned character,  8 bits.
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

%% Binary Write Properties -- OutputBufferSize
% The OutputBufferSize property specifies the maximum number 
% of bytes that can be written to the instrument at once. 
% By default, OutputBufferSize is 512.  
%
%  >> get(s, 'OutputBufferSize')
%
%  ans =
%
%     512
%
% If the command specified in FWRITE contains more than 512
% bytes, an error is returned and no data is written to the
% instrument.
%
% Configure the object's output buffer size to 3000.
% Note, the OutputBufferSize can be configured only when the 
% object is not connected to the instrument.
% 
%  >> fclose(s); 
%  >> set(s, 'OutputBufferSize', 3000);
%  >> fopen(s); 


%% Writing Int16 Binary Data
% Now write a waveform as an int16 array.  
%
%  >> fprintf(s, 'Data:Destination RefB');
%  >> fprintf(s, 'Data:Encdg SRPbinary');
%  >> fprintf(s, 'Data:Width 2');
%  >> fprintf(s, 'Data:Start 1');
% 
%  >> t = (0:499) .* 8 * pi / 500;
%  >> data = round(sin(t) * 90 + 127);
%  >> fprintf(s, 'CURVE #3500');
% 
% Note: one int16 value consists of two bytes. Therefore, the
% following command will write 1000 bytes.
% 
%  >> fwrite(s, data, 'int16')

%% Binary Write Properties -- ValuesSent
% The ValuesSent property indicates the total number of values
% written to the instrument since the object was connected to
% the instrument.
%
%  >> get(s, 'ValuesSent')
%
%  ans =
%
%    581

%% Reading Binary Data
% You use the FREAD function to read binary data from the 
% instrument. For example, to read the waveform on channel 1
% of the oscilloscope:
%
%  >> fprintf(s, 'Data:Source CH1');
%  >> fprintf(s, 'Data:Encdg SRPbinary');
%  >> fprintf(s, 'Data:Width 1');
%  >> fprintf(s, 'Data:Start 1');
%  >> fprintf(s, 'Curve?')
%  >> data = fread(s, s.BytesAvailable); 
%
% By default, the FREAD function reads data using the uchar
% precision and blocks the MATLAB command line until one of the
% following occurs
%
% * A timeout occurs as specified by the Timeout property 
% * The specified number of values is read
% * The input buffer is filled
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

%% Binary Read Properties -- InputBufferSize
% The InputBufferSize property specifies the maximum number
% of bytes that you can read from the instrument. By default,
% InputBufferSize is 512.  
%
%  >> get(s, 'InputBufferSize')
%
%  ans =
%
%      512
%

%% Reading int16 Binary Data
% Now read the same waveform on channel 1 as an int16  
% array.  
%
%  >> fprintf(s, 'Data:Source CH1');
%  >> fprintf(s, 'Data:Encdg SRIbinary');
%  >> fprintf(s, 'Data:Width 2');
%  >> fprintf(s, 'Data:Start 1');
%  >> fprintf(s, 'Curve?')
%  >> s.BytesAvailable
% 
%  ans =
%
%   512
%
% Note one int16 value consists of two bytes. Therefore, the
% following command will read 512 bytes.
% 
%  >> data = fread(s, 256, 'int16');

%% Binary Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of 
% values read from the instrument.
%
%  >> get(s, 'ValuesReceived')
%
%  ans =
%
%      768


%% Cleanup
% If you are finished with the serial port object, disconnect
% it from the instrument, remove it from memory, and remove
% it from the workspace.
%
%  >> fclose(s);
%  >> delete(s);
%  >> clear s

