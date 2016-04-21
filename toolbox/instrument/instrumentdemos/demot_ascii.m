%% TCPIP ASCII Read and Write Operations
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.1.2.4 $  $Date: 2004/03/24 20:40:21 $

%% Introduction
% This demo explores ASCII read and write operations with a 
% TCPIP object. 
% 
% The information obtained for this demonstration was prerecorded.
% Therefore, you do not need an actual instrument to learn about ASCII read
% and write operations using a TCPIP object. The instrument used was a
% SONY/TEKTRONIX AWG520 Arbitrary Waveform Generator. 

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

%% Creating a TCPIP Object
% To begin, create a TCPIP object associated with the  host name
% sonytekawg.mathworks.com, port 4000. The  instrument's host IP address,
% e.g. 192.168.1.10, is user-configurable in the instrument. The associated
% host name is  assigned by your network administrator. The port number is
% fixed and is found in the instrument's documentation.
%
%  >> t = tcpip('sonytekawg.mathworks.com', 4000);
%  >> t
%
%    TCP/IP Object : TCP/IP- sonytekawg.mathworks.com
%
%    Communication Settings
%       RemotePort:           4000
%       RemoteHost:           sonytekawg.mathworks.com
%       Terminator:           'LF'
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

%% Connecting the TCPIP Object to the Instrument
% Before you can perform a read or write operation, you must
% connect the TCPIP object to the instrument with the FOPEN
% function. If the object was successfully connected, its
% Status property is automatically configured to open.
%
%  >> fopen(t)
%  >> get(t, 'Status')
%
%  ans =
%
%  open
%

%% Writing ASCII Data
% You use the FPRINTF function to write ASCII data to the
% instrument. For example, the 'Display:Brightness' command
% changes the display brightness of the instrument.
%
%  >> fprintf(t, 'Display:Brightness 0.8')
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
% 'Display:Brightness 0.8' is written to the  instrument,
% thereby indicating the end of the command.
%
% You can also specify the format of the command written by 
% providing a third input argument to FPRINTF. The accepted 
% format conversion characters include: d, i, o, u, x, X, f, 
% e, E, g, G, c, and s.  
%
% For example, the display brightness command previously shown 
% can be written to the instrument using three calls to FPRINTF.
%
%  >> fprintf(t, '%s', 'Display:');
%  >> fprintf(t, '%s', 'Brightness');
%  >> fprintf(t, '%s\n', ' 0.8');
% 
% The Terminator character indicates the end of the command
% and is sent after the last call to FPRINTF.

%% ASCII Write Properties -- OutputBufferSize
% The OutputBufferSize property specifies the maximum number 
% of bytes that can be written to the instrument at once. 
% By default, OutputBufferSize is 512.  
%
%  >> get(t, 'OutputBufferSize')
%
%  ans =
%
%      512
%
% If the command specified in FPRINTF contains more than 512
% bytes, an error is returned and no data is written to the
% instrument.

%% ASCII Write Properties -- ValuesSent 
% The ValuesSent property indicates the total number of values
% written to the instrument since the object was connected to
% the instrument.
%
%  >> get(t, 'ValuesSent')
%
%  ans =
%
%     46

%% Reading ASCII Data
% You use the FSCANF function to read ASCII data from the 
% instrument. For example, the function generator command
% 'Display:Brightness?' returns the function generator's
% display brightness:
%
%  >> fprintf(t, 'Display:Brightness?')
%  >> data = fscanf(t)
%
%  data =
%
%  0.80
%
% By default, the FSCANF function reads data using the '%c'
% format and blocks the MATLAB command line until one of the
% following occurs:  
%
%  * The terminator is received as specified by the Terminator
%    property
%  * A timeout occurs as specified by the Timeout property. 
%  * The input buffer is filled
%  * The specified number of values is read
%
% You can also specify the format of the data read by 
% providing a second input argument to FSCANF. The accepted 
% format conversion characters include: d, i, o, u, x, X, f,
% e, E, g, G, c, and s.  
%
% For example, the following command returns the display
% brightness as a double.
%
%  >> fprintf(t, 'Display:Brightness?')
%  >> data = fscanf(t, '%f')
%
%  data = 
%
%      0.8000
%
%  >> isnumeric(data)
%
%  ans =
%
%      1

%% ASCII Read Properties  InputBufferSize
% The InputBufferSize property specifies the maximum number
% of bytes that you can read from the instrument. By default,
% InputBufferSize is 512:
%
%  >> get(t, 'InputBufferSize')
%
%  ans =
%
%      512

%% ASCII Read Properties- ValuesReceived
% The ValuesReceived property is updated by the number of 
% values read from the instrument, including the terminator.
%
%  >> get(t, 'ValuesReceived')
%
%  ans =
%
%      10

%% Cleanup
% If you are finished with the TCPIP object, disconnect
% it from the instrument, remove it from memory, and remove
% it from the workspace.
%
%  >> fclose(t);
%  >> delete(t);
%  >> clear t
