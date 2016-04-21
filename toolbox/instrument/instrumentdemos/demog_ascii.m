%% GPIB ASCII Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.9.2.4 $  $Date: 2004/03/24 20:40:14 $

%% Introduction
% This demo explores ASCII read and write operations with a 
% GPIB object. The information obtained for this demonstration 
% was pre-recorded. Therefore, you do not need an actual instrument 
% to learn about GPIB ASCII read and write operations using 
% a GPIB object.
% 
% The GPIB board used was a National Instruments PCI-GPIB+ GPIB card.
% 
% The instrument used was a Hewlett Packard 33120A function generator.

%% Functions and Properties
% These functions are used when reading and writing text: 
%
%  FPRINTF          - Write text to instrument.
%  FSCANF           - Read data from instrument and format as text.
%
% These properties are associated with ASCII read and write 
% operations:
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
%  EOIMode          - Enables or disables the assertion of the
%                     EOI mode at the end of a write operation.


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
%


%% Connecting the GPIB Object to the Instrument
%
% Before you can perform a read or write operation, you 
% must connect the GPIB object to the instrument with the 
% FOPEN function. If the GPIB object was successfully connected,
% its Status property is automatically configured to open. 
%
%  >> fopen(g)
%  >> get(g, 'Status')
%
%  ans =
%
%  open

%% Writing ASCII Data
% You use the FPRINTF function to write ASCII data to 
% the instrument. For example, the 'Volt 2'% command 
% changes the signal's peak-to-peak voltage to 4 volts.
%
%  >> fprintf(g, 'Volt 2')
%
% By default, FPRINTF operates in synchronous mode. This 
% means that the function blocks the MATLAB command line 
% until one of the following occurs:
%
% * All the data is written
% * A timeout occurs as specified by the Timeout property
%
% By default, FPRINTF writes ASCII data using the %s\n 
% format. You can also specify the format of the command 
% written to the instrument by specifying a third input 
% argument to FPRINTF. The accepted format conversion 
% characters include: d, i, o, u, x, X, f, e, E, g, G,
% c, and s. 
%
% For example,
%
%  >> fprintf(g, '%s', 'Volt 3')


%% ASCII Write Properties -- OutputBufferSize
% The OutputBufferSize property specifies the maximum
% number of bytes that can be written to the instrument 
% at once. By default, OutputBufferSize is 512.  
%
%  >> get(g, 'OutputBufferSize')
%
%  ans =
%
%  512
%
% If the command specified in FPRINTF contains more than
% 512 bytes, an error is returned and no data is written
% to the instrument.
%

%% ASCII Write Properties -- EOIMode, EOSMode and EOSCharCode 
% By default, the End or Identify (EOI) line is asserted 
% when the last byte is written to the instrument. This 
% behavior is controlled by the EOIMode property. When 
% EOIMode is set to on, the EOI line is asserted when 
% the last byte is written to the instrument. When EOIMode
% is set to off, the EOI line is not asserted when the
% last byte is written to the instrument.
%
% The EOI line can also be asserted when a terminator is 
% written to the instrument. The terminator is defined by
% the EOSCharCode property. When EOSMode is configured to 
% write or read&write, the EOI line is asserted when 
% the EOSCharCode property value is written to the instrument.
%
% All occurrences of \n in the command written to the instrument
% are replaced with the EOSCharCode property value if EOSMode 
% is set to write or read&write.
%

%% ASCII Write Properties -- ValuesSent
% The ValuesSent property is updated by the number of values 
% written to the instrument. Note that by default EOSMode 
% is set to none. Therefore, EOSCharCode is not sent
% as the last byte of the write.
%
%  >> fprintf(g, 'Volt 2')
%  >> get(g, 'ValuesSent')
%
%  ans =
%
%      18
%
% Now, configure the object to send a linefeed 
% character at the end of the write operation and to 
% assert the EOI line when the linefeed character is 
% sent. Because EOSMode is configured to write, the
% linefeed character is sent at the end of the write.
% Therefore, ValuesSent is incremented from the previous
% value (18) by 7 values.
%
%  >> set(g, 'EOSMode', 'write')
%  >> set(g, 'EOSCharCode', 10)
%  >> fprintf(g, 'Volt 3')
%  >> get(g, 'ValuesSent')
%
%  ans =
%
%     25
%
%

%% Reading ASCII Data
% The FSCANF function reads ASCII data from the instrument. 
% For example, the 'Volt?' command returns the signal's
% peak-to-peak voltage.
%
%  >> fprintf(g, 'Volt?')
%  >> data = fscanf(g)
%
%  data =
%
%  +3.00000E+00
%
% FSCANF blocks until one of the following occurs
%
% * The EOI line is asserted
% * The terminator is received as defined by the EOSCharCode property
% * A timeout occurs as specified by the Timeout property
% * The input buffer is filled
% * The specified number of values is received
%
% By default, FSCANF reads ASCII data using the %c format.
% You can also specify the format of the data read by 
% specifying a second input argument to FSCANF.  The 
% accepted format conversion characters include: 
% d, i, o, u, x, X, f, e, E, g, G, c, and s. 
%
% For example, the following command will return the 
% voltage as a double:
%
%  >> fprintf(g, 'Volt?')
%  >> data = fscanf(g, '%g')
%
%  data =
%
%      3
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
%  >> get(g, 'InputBufferSize')
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
%  >> fprintf(g, 'Volt?')
%  >> data = fscanf(g)
%
%  data =
%
%  +3.00000E+00
%
%  >> get(g, 'ValuesReceived')
%
%  ans =
% 
%     39
%

%% ASCII Read Properties -- EOSMode and EOSCharCode
% To terminate the data transfer based on receiving 
% EOSCharCode, you should set the EOSMode property to 
% read or read&write, and the EOSCharCode property 
% to the ASCII code for which the read operation should 
% terminate. For example, if you set EOSMode to read 
% and EOSCharCode to 10, then one of the ways that the read 
% terminates is when the linefeed character is received. 
%
% Configure the GPIB object to terminate the read 
% operation when the 'E' character is received. 
%
% The first read terminates when the 'E' character is received. 
%
%  >> set(g, 'EOSMode', 'read')
%  >> set(g, 'EOSCharCode', double('E'))
%  >> fprintf(g, 'Volt?')
%  >> data = fscanf(g)
%
%  data =
%
%  +3.00000E
%
% If you perform a second read operation, it terminates when 
% the EOI line is asserted. 
%
%  >> data = fscanf(g)
%
%  data =
%
%  +00

%% Cleanup
% If you are finished with the GPIB object, disconnect 
% it from the instrument, remove it from memory, and 
% remove it from the workspace.
%
%  >> fclose(g)
%  >> delete(g)
%  >> clear g


