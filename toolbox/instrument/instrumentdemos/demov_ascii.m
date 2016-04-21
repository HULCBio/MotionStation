%% VISA ASCII Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.9.2.6 $  $Date: 2004/03/24 20:40:27 $

%% Introduction
% This tutorial explores ASCII read and write operations 
% with a VISA object.
% 
% The information obtained for this tutorial was prerecorded. Therefore,
% you do not need an actual instrument to learn about VISA ASCII read and
% write operations. 
% 
% The instruments used include an Agilent E1406A command module in VXI slot
% 0 and an Agilent E1441A instrument in VXI slot 1.  
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
% This tutorial explores ASCII read and write operations
% using a VISA-GPIB-VXI object. However, ASCII read and 
% write operations for VISA-GPIB, VISA-VXI, VISA-GPIB-VXI, 
% VISA-TCPIP, and VISA-USB objects are identical to each other. 
% Therefore, you can use the same commands. The only difference
% is the resource name specified in the VISA constructor. 
% 
% ASCII read and write operations for the VISA-serial object
% are identical to ASCII read and write operations for the
% serial port object. Therefore, to learn how to perform ASCII
% read and write operations for the VISA-serial object,
% you should refer to the Serial Port ASCII Read/Write tutorial.
% 
% ASCII read and write operations for the VISA-RSIB object are
% identical to the ASCII read and write operations for the 
% VISA-GPIB, VISA-VXI, VISA-GPIB-VXI, VISA-TCPIP, and VISA-USB
% objects, except the VISA-RSIB object does not support the
% EOSCharCode and EOSMode properties.

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
%  EOSMode          - Configures the End-Of-String termination
%                     mode.
%  EOSCharCode      - Specifies the End-Of-String terminator.
%  EOIMode          - Enables or disables the assertion of 
%                     the EOI line at the end of a write
%                     operation.

%% Creating a VISA Object
% To begin, create a VISA-GPIB-VXI object. The HP
% E1441A instrument is configured with a logical address
% of 80 and is in the first chassis.
% 
%  >> v = visa('agilent', 'GPIB-VXI0::80::INSTR')
% 
%    VISA-GPIB-VXI Object Using AGILENT Adaptor: VISA-GPIB-VXI0-80
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
% connected, its Status property is automatically 
% configured to open.
% 
%  >> fopen(v)
%  >> v
% 
%    VISA-GPIB-VXI Object Using AGILENT Adaptor: VISA-GPIB-VXI0-80
% 
%    Communication Address 
%       ChassisIndex:       0
%       LogicalAddress:     80
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

%% Writing ASCII Data
% You use the FPRINTF function to write ASCII data to 
% the instrument. For example, the 'Volt 2' command
% changes the signal's peak-to-peak voltage to 4 volts. 
% 
%  >> fprintf(v, 'Volt 2')
% 
% By default, FPRINTF operates in synchronous mode. This
% means that the function blocks until one of the following 
% occurs:
%
% * All the data is written
% * A timeout occurs as specified by the Timeout property
% 
% By default, FPRINTF writes ASCII data using the %s\n 
% format. You can also specify the format of the command 
% written by providing a third input argument to FPRINTF.  
% The accepted format conversion characters include: d, i,
% o, u, x, X, f, e, E, g, G, c, and s.
% 
% For example,
% 
%  >> fprintf(v, '%s', 'Volt 3')


%% ASCII Write Properties -- OutputBufferSize
% The OutputBufferSize property specifies the maximum
% number of bytes that can be written to the instrument 
% at once. By default, OutputBufferSize is 512.  
%
%  >> get(v, 'OutputBufferSize')
%
%  ans =
%
%  512
%
% If the command specified in FPRINTF contains more than
% 512 bytes, an error is returned and no data is written
% to the instrument.
%

%% ASCII Write Properties -- EOIMode, EOSMode, and EOSCharCode 
% By default, the End or Identify (EOI) line is asserted 
% when the last byte is written to the instrument. This 
% behavior is controlled by the EOIMode property. When 
% EOIMode is set to on, the EOI line is asserted when 
% the last byte is written to the instrument. When EOIMode
% is set to off, the EOI line is not asserted when the
% last byte is written to the instrument.
%
% All occurrences of \n in the command written to the 
% instrument are replaced with the EOSCharCode property  
% value if EOSMode is set to write or read&write.

%% ASCII Write Properties -- ValuesSent
% The ValuesSent property is updated by the number of 
% values written to the instrument. Note that by default
% EOSMode is set to none. Therefore, EOSCharCode is not
% sent as the last byte of the write.
% 
%  >> fprintf(v, 'Volt 2')
%  >> get(v, 'ValuesSent')
% 
%  ans =
% 
%      18

%% Reading ASCII Data
% The FSCANF function reads ASCII data from the instrument.
% For example, the 'Volt?' command returns the signal's 
% peak-to-peak voltage. 
% 
%  >> fprintf(v, 'Volt?')
%  >> data = fscanf(v)
% 
%  data =
% 
%  +2.00000E+00
%
% FSCANF blocks until one of the following occurs:  
%
% * The EOI line is asserted
% * The terminator is received as defined by the EOSCharCode property
% * A timeout occurs as specified by the Timeout property
% * The input buffer is filled
% * The specified number of values is received
%
% By default, FSCANF reads ASCII data using the %c format.
% You can also specify the format of the data read by 
% providing a second input argument to FSCANF. The 
% accepted format conversion characters include: 
% d, i, o, u, x, X, f, e, E, g, G, c, and s. 
%
% For example, the following command will return the 
% voltage as a double:
%
%  >> fprintf(v, 'Volt?')
%  >> data = fscanf(v, '%g')
%
%  data =
%
%      2
%
%  >> isnumeric(data)
%
%  ans =
%
%      1

%% ASCII Read Properties -- InputBufferSize
% The InputBufferSize property specifies the maximum 
% number of bytes that you can read from the instrument.
% By default, InputBufferSize is 512.  
%
%  >> get(v, 'InputBufferSize')
%
%  ans =
%
%     512
%

%% ASCII Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of
% values read from the instrument. Note the last value 
% received is a linefeed.
%
%  >> fprintf(v, 'Volt?')
%  >> data = fscanf(v)
%
%  data =
%
%  +2.00000E+00
%
%  >> get(v, 'ValuesReceived')
%
%  ans =
% 
%     39
%

%% ASCII Read Properties -- EOSMode and EOSCharCode
% To terminate the data transfer based on receiving 
% EOSCharCode, you should set the EOSMode property to 
% read or read&write and the EOSCharCode property 
% to the ASCII code for which the read operation should 
% terminate. For example, if you set EOSMode to read 
% and EOSCharCode to 10, then one of the ways that the read 
% terminates is when the linefeed character is received. 
%
% Configure the VISA-GPIB-VXI object to terminate the read 
% operation when the 'E' character is received. 
%
% The first read terminates when the 'E' character is received. 
%
%  >> set(v, 'EOSMode', 'read')
%  >> set(v, 'EOSCharCode', double('E'))
%  >> fprintf(v, 'Volt?')
%  >> data = fscanf(v)
%
%  data =
%
%  +2.00000E
%
% If you perform a second read operation, it terminates when 
% the EOI line is asserted. 
%
%  >> data = fscanf(v)
%
%  data =
%
%  +00

%% Cleanup
% If you are finished with the VISA-GPIB-VXI object, disconnect 
% it from the instrument, remove it from memory, and remove it
% from the workspace.
% 
%  >> fclose(v)
%  >> delete(v)
%  >> clear v

