%% Recording Instrument Control Sessions
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.8.2.4 $  $Date: 2004/03/24 20:40:12 $

%% Introduction
% This demo explores recording data and event information with  
% a serial port object. However, any interface object can be 
% used with the commands given throughout the demo.
%
% The information obtained for this demonstration was prerecorded. 
% Therefore, you do not need an actual instrument 
% to learn about recording data and event information. The  
% instrument used was a Tektronix TDS 210 oscilloscope.
%

%% Functions and Properties
% This function is used to record data and event information: 
%
%  RECORD       - Record data and event information to a file.
% 
% These properties are associated with recording data and event
% information:
%
%  RecordDetail - Specifies the amount of information recorded.
%  RecordMode   - Specifies whether data and event information 
%                 are saved to one record file or to multiple 
%                 record files.
%  RecordName   - Specifies the name of the record file. 
%  RecordStatus - Indicates if data and event information are
%                 saved to a record file. 
%

%% Creating a Serial Port Object
% To begin, create a serial port object associated with
% the COM1 port.  
%
%  >> s=serial('COM1')
%
%    Serial Port Object : Serial-COM1
%
%    Communication Settings 
%       Port:               COM1
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

%% Using RECORD
%
% You initiate and terminate recording with the RECORD function.
% Before recording can begin, the interface object must be
% connected to the instrument with the FOPEN function. If an
% error occurs while writing information to the record file, 
% recording will be terminated and a warning will be displayed.
% When the interface object is closed with the FCLOSE function,
% recording will automatically be terminated.
% 
% The object's RecordStatus property indicates if data and 
% events are being recorded. RecordStatus can be either on or
% off. The value of the RecordStatus property is configured
% with the RECORD function.
% 
% You can specify the name of the record file with the objects's
% RecordName property. The default value is record.txt.
% 
%  >> s.RecordStatus
%
%  ans =
%
%  off
%
%  >> fopen(s)
%  >> record(s)
%  >> s.RecordStatus
%
%  ans =
%
%  on
%
%  >> s.RecordName
%
%  ans =
%
%  record.txt

%% Specifying the Amount of Information Recorded
% The RecordDetail property specifies the amount of information
% recorded. RecordDetail can be set to either compact or 
% verbose.
%
% If RecordDetail is set to compact, the following information
% is captured:
%
% * The number of values read
% * The data type of the values read
% * The number of values written
% * The data type of the values written
% * The event information
% 
% If RecordDetail is set to verbose, the data read from the 
% instrument and the data written to the instrument are also
% captured in the record file.
% 
% The default value for the RecordDetail property is compact.


%% Recording ASCII Data
% Now query the instrument's identification information.
% Because recording is on, this information will be captured in 
% the record file.
%
% Note the legend at the top of the record file uses a
% 
% * > to indicate data that is written to the instrument
% * < to indicate data read from the instrument
% * * to indicate events that occurred
%
%  >> fprintf(s, '*IDN?')
%  >> data = fscanf(s)
% 
%  data =
%
%  TEKTRONIX,TDS 210,0,CF:91.1CT FV:v1.16 TDS2CM:CMV:v1.04
%
%  >> type record.txt
%
%  Legend: 
%    * - An event occurred.
%    > - A write operation occurred.
%    < - A read operation occurred.
% 
%  1      Recording on 28-Apr-2000 at 13:11:29.910. Binary data in little endian format.
%  2    > 6 ascii values.
%  3    < 56 ascii values.
%
% Now let's capture the data written to the instrument and the
% data read from the instrument. 
%
%  >> set(s, 'RecordDetail', 'verbose')
%  >> fprintf(s, 'Display:Contrast?')
%  >> data = fscanf(s)
% 
%  data =
% 
%  30
%
%  >> type record.txt
%
%  Legend: 
%    * - An event occurred.
%    > - A write operation occurred.
%    < - A read operation occurred.
% 
%  1      Recording on 28-Apr-2000 at 13:11:29.910. Binary data in little endian format.
%  2    > 6 ascii values.
%  3    < 56 ascii values.
%  4    > 18 ascii values.
%         Display:Contrast?
%
%  5    < 3 ascii values.
%         30

%% Recording Binary Data
% Binary data with uchar, schar, (u)int8, (u)int16, or (u)int32
% precision is recorded in the record file in hexadecimal 
% format.
%
%  >> fprintf(s, 'Display:Contrast?')
%  >> fread(s, 1, 'int16')
%
%  ans =
%
%        12339
%
%  >> dec2hex(12339)
%
%  ans =
% 
%  3033
%
%  >> fclose(s)
%  >> type record.txt
%
%  Legend: 
%    * - An event occurred.
%    > - A write operation occurred.
%    < - A read operation occurred.
%  
%  1      Recording on 28-Apr-2000 at 13:11:29.910. Binary data in little endian format.
%  2    > 6 ascii values.
%  3    < 56 ascii values.
%  4    > 18 ascii values.
%         Display:Contrast?
%  
%  5    < 3 ascii values.
%         30
% 
%  6    > 18 ascii values.
%         Display:Contrast?
% 
%  7    < 1 int16 values.
%         3033 
%  8      Recording off.
%
% Binary data with single or double precision is recorded 
% according to the IEEE 754 floating-point bit layout.  
% 
% This means that a single precision value is represented 
% as a 32-bit value, which will be converted to the 
% equivalent hex value. To translate the single-precision 
% value, one would have to do the following (bit 1 is the 
% leftmost bit):
% 
%      sign        = bit1 (a value of 0 is positive and a 
%                    value of 1 is negative).
%      exp         = bit2 to bit 9
%      significand = bit 10 to bit 32
%      value       = (2^(exp-127))*(1.significand)
%
% For double-precision values the following would be used 
% (bit 1 is the leftmost bit):
% 
%      sign        = bit1 (a value of 0 is positive and a 
%                          value of 1 is negative).
%      exp         = bit2 to bit 12
%      significand = bit 13 to bit 64
%      value       = (2^(exp-1023))*(1.significand)
%
% Additionally, a text representation of the value will be
% listed to the right of the single-precision hex value, using
% the %g format string.

%% Appending Data to an Existing File
% Since recording was terminated, the record file will be 
% overwritten if recording is once again initiated. This is
% because the default value for RecordMode is overwrite. To
% avoid overwriting the previous record file, either specify
% a new value for the RecordName property or set the RecordMode
% property to append.
%
%  >> s.RecordMode = 'append';
%  >> fopen(s);
%  >> record(s, 'on')
%  >> fprintf(s, 'RS232:BAUD?')
%  >> data = fscanf(s)
%
%  data =
%
%  9600
%
%
%  >> fclose(s)
%  >> type record.txt
%
%  Legend: 
%    * - An event occurred.
%    > - A write operation occurred.
%    < - A read operation occurred.
%  
%  1      Recording on 28-Apr-2000 at 13:11:29.910. Binary data in little endian format.
%  2    > 6 ascii values.
%  3    < 56 ascii values.
%  4    > 18 ascii values.
%         Display:Contrast?
% 
%  5    < 3 ascii values.
%         30
% 
%  6    > 18 ascii values.
%         Display:Contrast?
% 
%  7    < 1 int16 values.
%         3033 
%  8      Recording off.
%  1      Recording on 28-Apr-2000 at 13:20:46.314.  Binary data in little endian format.
%  2    > 12 ascii values.
%         RS232:Baud?
% 
%  3    < 5 ascii values.
%         9600
% 
%  4      Recording off.


