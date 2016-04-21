%% Serial Port ASCII Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.8.2.4 $  $Date: 2004/03/24 20:40:18 $

%% Introduction
% This demo explores ASCII read and write operations with a 
% serial port object.
%
% The information obtained for this demonstration was prerecorded.
% Therefore, you do not need an actual instrument  to learn about ASCII
% read and write operations using a  serial port object. The instrument
% used was a Tektronix TDS  210 oscilloscope.

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


%% Creating a Serial Port Object
% To begin, create a serial port object associated 
% with the COM2 port.  
%
%  >> s = serial('COM2');
%  >> set(s, 'Terminator', 'CR');
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
% 
% 

%% Connecting the Serial Port Object to the Instrument
% Before you can perform a read or write operation, you must
% connect the serial port object to the instrument with the 
% FOPEN function. If the object was successfully connected,
% its Status property is automatically configured to open. 
%
%
%  >> fopen(s)
%  >> get(s, 'Status')
%
%  ans =
%
%  open

%% Writing ASCII Data
% You use the FPRINTF function to write ASCII data to the
% instrument. For example, the 'Display:Contrast' command 
% will change the display contrast of the oscilloscope.  
%
%  >> fprintf(s, 'Display:Contrast 45')
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
% For the previous command, the carriage return (CR) is
% sent after 'Display:Contrast 45' is written to the 
% oscilloscope, thereby indicating the end of the command. 
%
% You can also specify the format of the command written by 
% specifying a third input argument to FPRINTF. The accepted 
% format conversion characters include: d, i, o, u, x, X, f, 
% e, E, g, G, c, and s.  
%
% For example, the display contrast command previously shown 
% can be written to the instrument using three calls to FPRINTF.
%
%  >> fprintf(s, '%s', 'Display:');
%  >> fprintf(s, '%s', 'Contrast');
%  >> fprintf(s, '%s\n', ' 45');
% 
% The Terminator character indicates the end of the command
% and is sent after the last call to FPRINTF.


%% ASCII Write Properties -- OutputBufferSize
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
% If the command specified in FPRINTF contains more than 512
% bytes, an error is returned and no data is written to the
% instrument.

%% ASCII Write Properties -- ValuesSent 
% The ValuesSent property indicates the total number of values
% written to the instrument since the object was connected to
% the instrument.
%
%  >> get(s, 'ValuesSent')
%
%  ans =
%
%    40
%

%% Reading ASCII Data
% You use the FSCANF function to read ASCII data from the 
% instrument. For example, the oscilloscope command 
% 'Display:Contrast?' returns the oscilloscope's display
% contrast:
%
%  >> fprintf(s, 'Display:Contrast?')
%  >> data = fscanf(s)
%
%  data =
%
%  45
%
% By default, the FSCANF function reads data using the '%c'
% format and blocks the MATLAB command line until one of the
% following occurs:  
%
% * The terminator is received as specified by the Terminator
%   property
% * A timeout occurs as specified by the Timeout property
% * The input buffer is filled
% * The specified number of values is read
%
% You can also specify the format of the data read by 
% specifying a second input argument to FSCANF. The accepted 
% format conversion characters include: d, i, o, u, x, X, f,
% e, E, g, G, c, and s.  
%
% For example, the following command returns the display
% contrast as a double.
%
%  >> fprintf(s, 'Display:Contrast?')
%  >> data = fscanf(s, '%d')
%
%  data = 
%
%     45
%
%  >> isnumeric(data)
%
%  ans =
%
%      1

%% ASCII Read Properties -- InputBufferSize
% The InputBufferSize property specifies the maximum number
% of bytes that you can read from the instrument. By default,
% InputBufferSize is 512.  
%
%  >> get(s, 'InputBufferSize')
%
%  ans =
%
%     512

%% ASCII Read Properties -- ValuesReceived
% The ValuesReceived property is updated by the number of 
% values read from the instrument, including the terminator.
%
%  >> get(s, 'ValuesReceived')
%
%  ans =
%
%     6

%% Cleanup
% If you are finished with the serial port object, disconnect
% it from the instrument, remove it from memory, and remove
% it from the workspace.
%
%  >> fclose(s);
%  >> delete(s);
%  >> clear s
