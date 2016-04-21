%% GPIB Binary Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.7.2.4 $  $Date: 2004/03/24 20:40:16 $

%% Introduction
% This demo explores binary read and write operations with a 
% GPIB object. The information obtained for this demonstration
% was pre-recorded. Therefore, you do not need an actual instrument 
% to learn about binary read and write operations using a 
% GPIB object.
% 
% The GPIB board used was a National Instruments PCI-GPIB+ GPIB card.
% 
% The instrument used was a Tektronix TDS 210 oscilloscope.

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
%  EOSMode          - Configures the End-Of-String termination
%                     mode.
%  EOSCharCode      - Specifies the End-Of-String terminator.

%% Creating a GPIB Object
% To begin, create a GPIB object. The board index is 
% configured to 0, the primary address of the instrument is 
% configured to 2.
%
%  >> g = gpib('ni', 0, 2)
%
%    GPIB Object Using NI Adaptor : GPIB0-2
%
%    Communication Address 
%       BoardIndex:         0
%       PrimaryAddress:     2
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

%% Connecting the GPIB Object to the Instrument
% Before you can perform a read or write operation, you must
% connect the GPIB object to the instrument with the FOPEN
% function. If the object was successfully connected, its
% Status property is automatically configured to open. 
%
%  >> fopen(g)
%  >> get(g, 'Status')
%
%  ans =
%
%  open
%
%  Note that the display summary is updated accordingly.
%
%  >> g
%
%    GPIB Object Using NI Adaptor : GPIB0-2
%
%    Communication Address 
%       BoardIndex:         0
%       PrimaryAddress:     2
%       SecondaryAddress:   0
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
% instrument. For example, the following commands will send 
% a sine wave to the oscilloscope:
% 
%  >> fprintf(g, 'Data:Destination RefB');
%  >> fprintf(g, 'Data:Encdg SRPbinary');
%  >> fprintf(g, 'Data:Width 1');
%  >> fprintf(g, 'Data:Start 1');
% 
%  >> t = (0:499) .* 8 * pi / 500;
%  >> data = round(sin(t) * 90 + 127);
%  >> fprintf(g, 'CURVE #3500');
%  >> fwrite(g, data)
% 
% By default, the FWRITE function operates in synchronous
% mode. This means that FWRITE blocks the MATLAB command 
% line until one of the following occurs:
%
% * All the data is written
% * A timeout occurs as specified by the Timeout property
%
% By default, the FWRITE function writes binary data using 
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
%
% When performing a write operation, you should think of the 
% transmitted data in terms of values rather than bytes. A 
% value consists of one or more bytes. For example, one uint32  
% value consists of four bytes.
 
%% Binary Write Properties -- OutputBufferSize
% The OutputBufferSize specifies the maximum number of bytes that can be
% written to the instrument at once. By default, OutputBufferSize is 512.
%
%  >> get(g, 'OutputBufferSize')
%
%  ans =
%
%      512
%
% Configure the object's output buffer size to 3000.
% Note the OutputBufferSize can be configured only when the 
% object is not connected to the instrument.
% 
%  >> fclose(g); 
%  >> set(g, 'OutputBufferSize', 3000);
%  >> fopen(g); 

%% Writing Int16 Binary Data
% Now write a waveform as an int16 array.  
%
%  >> fprintf(g, 'Data:Destination RefB');
%  >> fprintf(g, 'Data:Encdg SRPbinary');
%  >> fprintf(g, 'Data:Width 2');
%  >> fprintf(g, 'Data:Start 1');
% 
%  >> t = (0:499) .* 8 * pi / 500;
%  >> data = round(sin(t) * 90 + 127);
%  >> fprintf(g, 'CURVE #3500');
% 
% Note: one int16 value consists of two bytes. Therefore, the
% following command will write 1000 bytes.
% 
%  >> fwrite(g, data, 'int16')

%% Binary Write Properties -- ValuesSent
%
% The ValuesSent property indicates the total number of values
% written to the instrument since the object was connected to
% the instrument.
%
%  >> get(g, 'ValuesSent')
%
%  ans =
%
%     576

%% Reading Binary Data
% You use the FREAD function to read binary data from the 
% instrument. For example, to read the waveform on channel 1
% of the oscilloscope:
%
%  >> fprintf(g, 'Data:Source CH1');
%  >> fprintf(g, 'Data:Encdg SRPbinary');
%  >> fprintf(g, 'Data:Width 1');
%  >> fprintf(g, 'Data:Start 1');
%  >> fprintf(g, 'Curve?')
%  >> data = fread(g, 512); 
%
% By default, the FREAD function reads data using the uchar
% precision and blocks the MATLAB command line until one of the
% following occurs:  
%
% * The specified number of values is read
% * The input buffer is filled
% * The EOI line is asserted
% * The terminator is received as specified by the EOSCharCode
%   property (if defined)
% * A timeout occurs as specified by the Timeout property 
%
% By default, the FREAD function reads data using the uchar 
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
%
% When performing a read operation, you should think of the 
% received data in terms of values rather than bytes. A value 
% consists of one or more bytes. For example, one uint32 value  
% consists of four bytes.

%% Binary Read Properties - InputBufferSize
% The InputBufferSize property specifies the maximum number
% of bytes that you can read from the instrument. By default,
% InputBufferSize is 512.  
%
%  >> get(g, 'InputBufferSize')
%
%  ans =
%
%      512
%
% Configure the object's input buffer size to 2500.
% Note the InputBufferSize can be configured only when the 
% object is not connected to the instrument.
% 
%  >> fclose(g); 
%  >> set(g, 'InputBufferSize', 2500);
%  >> fopen(g); 

%% Reading Int16 Binary Data
% Now read the same waveform on channel 1 as an int16  
% array.  
%
%  >> fprintf(g, 'Data:Source CH1');
%  >> fprintf(g, 'Data:Encdg SRIbinary');
%  >> fprintf(g, 'Data:Width 2');
%  >> fprintf(g, 'Data:Start 1');
%  >> fprintf(g, 'Curve?')
% 
% Note: one int16 value consists of two bytes. Therefore, the
% following command will read 2400 bytes.
% 
%  >> data = fread(g, 1200, 'int16');


%% Binary Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of 
% values read from the instrument.
%
%  >> get(g, 'ValuesReceived')
%
%  ans =
%
%      1200

%% Binary Read Properties -- EOSMode and EOSCharCode
% For GPIB, the terminator is defined by setting the 
% objects' EOSMode property to read, and setting the objects' 
% EOSCharCode property to the ASCII code for the character 
% received. For example, if the EOSMode property is set to 
% read and the EOSCharCode property is set to 10, then one 
% of the ways that the read terminates is when the linefeed 
% character is received.
% 
% Configure the GPIB object's terminator to the letter E.
% 
%  >> set(g, 'EOSMode', 'read');
%  >> set(g, 'EOSCharCode', double('E'));
% 
% Now, read the channel 1's signal frequency.
% 
%  >> fprintf(g, 'Measurement:Meas1:Source CH1')
%  >> fprintf(g, 'Measurement:Meas1:Type Freq')
%  >> fprintf(g, 'Measurement:Meas1:Value?')
% 
% Note: the first read terminates due to the EOSCharCode being
% detected, while the second read terminates due to the EOI 
% line being asserted.
% 
%  >> data = fread(g, 30);
%  Warning: The EOI line was asserted or the EOSCharCode was detected before SIZE values were available.
%  >> char(data)'
% 
%  ans =
%
%  9.980040283203E
%
%  >> data = fread(g, 30);
%  Warning: The EOI line was asserted or the EOSCharCode was detected before SIZE values were available.
%  >> char(data)'
% 
%  ans =
% 
%  2

%% Cleanup
% If you are finished with the GPIB object, disconnect it
% from the instrument, remove it from memory, and remove
% it from the workspace.
%
%  >> fclose(g);
%  >> delete(g);
%  >> clear g