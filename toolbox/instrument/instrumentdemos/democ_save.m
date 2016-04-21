%% Saving and Loading the Instrument Control Session
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.8.2.4 $  $Date: 2004/03/24 20:40:13 $

%% Introduction
% This demo explores saving your instrument control session. 
% Two methods for saving your session are available. The 
% first method uses the SAVE command to save the instrument 
% objects to a MAT-file. The LOAD command is used to load 
% the instrument objects from the MAT-file back into the 
% MATLAB workspace. The second method uses the OBJ2MFILE
% function to convert the instrument object to the equivalent 
% MATLAB code. The instrument object can be recreated later 
% by running the M-file. 
%
% The information obtained for this demonstration was prerecorded.
%  Therefore, you do not need an actual instrument 
% to learn about saving your instrument control session. The  
% instrument used was a Tektronix TDS 210 oscilloscope.


%% Creating a Serial Port Object
%
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
%
% The Tag, UserData, BaudRate, and InputBufferSize properties
% will be configured as follows:
%
%  >> s.Tag = 'sydney';
%  >> s.UserData = magic(5);
%  >> s.BaudRate = 4800;
%  >> s.InputBufferSize = 2500;

%% Connecting the Serial Port Object to the Instrument    
% Before you can perform a read or write operation, you must
% connect the serial port object to the instrument with the
% FOPEN function. If the object was successfully connected,
% its Status property is configured to open.
%
%  >> fopen(s)
%  >> s.Status
%
%  ans =
%
%  open
%

%% Communicating with the Instrument
% Now query the instrument's identification information.
% By default, the serial port object stores the information in
% its input buffer.
% 
%  >> fprintf(s,'*IDN?')
%  >> get(s, 'BytesAvailable')
% 
%  ans =
% 
%     56
% 
%  >> get(s, ValuesSent')
% 
%  ans =
% 
%     6

%% Saving an Instrument Object and its Data
% The serial port object can be saved to a MAT-file with 
% the MATLAB built-in SAVE command. Any data in the object's
% input buffer will not be stored with the object in the 
% MAT-file. Therefore, if you do not want to lose this data, 
% you must read the data into the workspace with one of the
% read functions such as FSCANF. You must explicitly save the 
% variable containing the data to the MAT-file. 
% 
%  >> data = fscanf(s)
% 
%  data =
% 
%  TEKTRONIX,TDS 210,0,CF:91.1CT FV:v1.16 TDS2CM:CMV:v1.04
% 
%  >> save fname s data
%  >> clear data
%  >> fclose(s)
%  >> delete(s);
%  >> clear s

%% Loading an Instrument Object
% You can recreate the instrument object and its data (if saved) 
% with the MATLAB built-in LOAD command.
%
% It is important to note that values for read-only properties
% will be restored to their default values upon loading. For
% example, any instrument objects that are saved while connected
% will be loaded with their Status property set to closed.
%
%  >> load fname
%  >> s
%
%    Serial Port Object : Serial-COM1
%
%    Communication Settings 
%       Port:               COM1
%       BaudRate:           4800
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
%
%  >> data
%
%  data =
%
%  TEKTRONIX,TDS 210,0,CF:91.1CT FV:v1.16 TDS2CM:CMV:v1.04
% 
%  >> get(s, {'Tag', 'InputBufferSize'})
%
%  ans = 
%
%    'sydney'    [2500]
%
%  >> get(s, 'UserData')
%
%  ans =
%
%     17    24     1     8    15
%     23     5     7    14    16
%      4     6    13    20    22
%     10    12    19    21     3
%     11    18    25     2     9

%% Using OBJ2MFILE 
% OBJ2MFILE converts an instrument object to its equivalent 
% MATLAB code. The instrument object can be recreated by
% running the created M-file. 
% 
% Create a GPIB object that will be converted to M-Code.
%
%  >> g = gpib('ni', 0, 1);
%  >> g.Tag = 'mygpib';
%  >> g.EOIMode = 'off';
%  >> g.UserData = magic(5);
%
% By default, OBJ2MFILE saves properties not set to their 
% default values using the SET syntax. A MAT-file with the 
% same name as the M-file will also be created if
%
% * You assign a value to the UserData property, or 
% * Any of the Callback properties are defined as a cell 
%    array or as a function handle.
%
%  >> obj2mfile(g, 'fname');
%
% The M-file created by OBJ2MFILE is shown below. Note the  
% first line following the online help indicates the time 
% the M-file was created.
%
%  >> type fname.m
%
%  function out = fname
%  %FNAME M-Code for creating an instrument object.
%  %    
%  %    This is the machine generated representation of an instrument object.
%  %    This M-file, FNAME.M, was generated from the OBJ2MFILE function.
%  %    A MAT-file is created if the object's UserData property is not 
%  %    empty or if any of the callback properties are set to a cell array   
%  %    or to a function handle. The MAT-file will have the same name as the 
%  %    M-file but with a .MAT extension. To recreate this instrument object,
%  %    type the name of the M-file, myfile, at the MATLAB command prompt.
%  %    
%  %    The M-file, FNAME.M and its associated MAT-file, FNAME.MAT (if 
%  %    it exists) must be on your MATLAB PATH. For additional information
%  %    on setting your MATLAB PATH, type 'help addpath' at the MATLAB 
%  %    command prompt.
%  %    
%  %    Example: 
%  %       g = fname;
%  %    
%  %    See also SERIAL, GPIB, VISA, TCPIP, INSTRHELP, INSTRUMENT/PROPINFO. 
%  %    
% 
%  %    Creation time: 28-Apr-2000 14:06:21
% 
%  % Load the MAT-file which contains UserData and callback property values.
%  load fname
% 
%  % Create the instrument object.
%  obj1 = gpib('NI', 0, 1);
% 
%  % Set the property values.
%  set(obj1, 'EOIMode', 'off');
%  set(obj1, 'Tag', 'mygpib');
%  set(obj1, 'UserData', userdata1);
% 
%  if nargout > 0 
%      out = [obj1]; 
%  end
% 

%% Recreating the Object from the OBJ2MFILE File
% You can recreate the object by typing the name of the M-file
% at the MATLAB command prompt.
%
%  >> delete(g);
%  >> clear g
%  >> g = fname
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
%  >> get(g, {'EOIMode', 'Tag'})
%
%  ans = 
%
%    'off'    'mygpib'
% 
%  >> g.UserData
%
%  ans =
%
%    17    24     1     8    15
%    23     5     7    14    16
%     4     6    13    20    22
%    10    12    19    21     3
%    11    18    25     2     9
%
%

%% OBJ2MFILE -- Dot Notation
% OBJ2MFILE also allows you to save properties using the dot
% notation. Additionally, you can choose to save all properties,
% regardless if they have been modified.
%
%  >> obj2mfile(g, 'fname', 'dot', 'all');
%  >> type fname.m
%
%  function out = fname
%  %FNAME M-Code for creating an instrument object.
%  %    
%  %    This is the machine generated representation of an instrument object.
%  %    This M-file, FNAME.M, was generated from the OBJ2MFILE function.
%  %    A MAT-file is created if the object's UserData property is not 
%  %    empty or if any of the callback properties are set to a cell array   
%  %    or to a function handle. The MAT-file will have the same name as the 
%  %    M-file but with a .MAT extension. To recreate this instrument object,
%  %    type the name of the M-file, myfile, at the MATLAB command prompt.
%  %    
%  %    The M-file, FNAME.M and its associated MAT-file, FNAME.MAT (if 
%  %    it exists) must be on your MATLAB PATH. For additional information
%  %    on setting your MATLAB PATH, type 'help addpath' at the MATLAB 
%  %    command prompt.
%  %    
%  %    Example: 
%  %       g = fname;
%  %    
%  %    See also SERIAL, GPIB, VISA, TCPIP, INSTRHELP, INSTRUMENT/PROPINFO. 
%  %    
% 
%  %    Creation time: 28-Apr-2000 14:14:00
%
%  % Load the MAT-file which contains UserData and callback property values.
%  load fname
%
%  % Create the instrument object.
%  obj1 = gpib('NI', 0, 1);
%
%  % Set the property values.
%  obj1.BoardIndex = 0;
%  obj1.ByteOrder = 'littleEndian';
%  obj1.BytesAvailableFcn = '';
%  obj1.BytesAvailableFcnCount = 48;
%  obj1.BytesAvailableFcnMode = 'eosCharCode';
%  obj1.CompareBits = 8;
%  obj1.EOIMode = 'off';
%  obj1.EOSCharCode = 10;
%  obj1.EOSMode = 'none';
%  obj1.ErrorFcn = '';
%  obj1.InputBufferSize = 512;
%  obj1.Name = 'GPIB0-1';
%  obj1.OutputBufferSize = 512;
%  obj1.OutputEmptyFcn = ';'
%  obj1.PrimaryAddress = 1;
%  obj1.RecordDetail = 'compact';
%  obj1.RecordMode = 'overwrite';
%  obj1.RecordName = 'record.txt';
%  obj1.SecondaryAddress = 0;
%  obj1.Tag = 'mygpib';
%  obj1.Timeout = 10;
%  obj1.TimerFcn = '';
%  obj1.TimerPeriod = 1;
%  obj1.UserData = userdata1;
%
%  if nargout > 0 
%      out = [obj1]; 
%  end

