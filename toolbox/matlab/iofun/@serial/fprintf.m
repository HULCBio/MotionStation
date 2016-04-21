function fprintf(obj, varargin)
%FPRINTF Write text to device.
%
%   FPRINTF(OBJ,'CMD') writes the string, CMD, to the device connected
%   to serial port object, OBJ. OBJ must be a 1-by-1 serial port object.
%
%   The serial port object must be connected to the device with the 
%   FOPEN function before any data can be written to the device otherwise
%   an error is returned. A connected serial port object has a Status
%   property value of open.
%
%   FPRINTF(OBJ,'FORMAT','CMD') writes the string CMD, to the device
%   connected to serial port object, OBJ, with the format, FORMAT. By
%   default, the %s\n FORMAT string is used. The SPRINTF function is 
%   used to format the data written to the instrument.
% 
%   Each occurrence of \n in CMD is replaced with OBJ's Terminator
%   property value. When using the default FORMAT, %s\n, all commands 
%   written to the device will end with the Terminator value.
%
%   FORMAT is a string containing C language conversion specifications. 
%   Conversion specifications involve the character % and the conversion 
%   characters d, i, o, u, x, X, f, e, E, g, G, c, and s. See the SPRINTF
%   file I/O format specifications or a C manual for complete details.
%
%   FPRINTF(OBJ, 'CMD', 'MODE')
%   FPRINTF(OBJ, 'FORMAT', 'CMD', 'MODE') writes data asynchronously
%   to the device when MODE is 'async' and writes data synchronously
%   to the device when MODE is 'sync'. By default, the data is written
%   with the 'sync' MODE, meaning control is returned to the MATLAB
%   command line after the specified data has been written to the device
%   or a timeout occurs. When the 'async' MODE is used, control is
%   returned to the MATLAB command line immediately after executing 
%   the FPRINTF function. 
%
%   OBJ's TransferStatus property will indicate if an asynchronous 
%   write is in progress.
%
%   OBJ's ValuesSent property will be updated by the number of values 
%   written to the device.
%
%   If OBJ's RecordStatus property is configured to on with the RECORD
%   function, the data written to the device will be recorded in the
%   file specified by OBJ's RecordName property value.
%
%   Example:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, 'Freq 2000');
%       fclose(s);
%       delete(s);
%
%   See also SERIAL/FOPEN, SERIAL/FWRITE, SERIAL/STOPASYNC, SERIAL/RECORD,
%   SPRINTF.
%    

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.3 $  $Date: 2004/01/16 20:04:15 $

% Error checking.
if ~isa(obj, 'icinterface')
    error('MATLAB:serial:fprintf:invalidOBJ', 'OBJ must be an interface object.');
end

if length(obj)>1
    error('MATLAB:serial:fprintf:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

% Parse the input.
switch (nargin)
case 1
   error('MATLAB:serial:fprintf:invalidSyntax', 'CMD must be specified.');
case 2
   % Ex. fprintf(obj, cmd); 
   cmd = varargin{1};
   format = '%s\n';
   mode = 0;
case 3
   % Original assumption: fprintf(obj, format, cmd); 
   [format, cmd] = deal(varargin{1:2});
   mode = 0;
   if ~(isa(cmd, 'char') || isa(cmd, 'double'))
	   error('MATLAB:serial:fprintf:invalidArg', 'The third input argument must be a string.');
   end
   
   if strcmpi(cmd, 'sync') 
       % Actual: fprintf(obj, cmd, mode);
       mode = 0;
       cmd = format;
       format = '%s\n';
   elseif strcmpi(cmd, 'async') 
       % Actual: fprintf(obj, cmd, mode);
       mode = 1;
       cmd = format;
       format = '%s\n';
   end
case 4
   % Ex. fprintf(obj, format, cmd, mode); 
   [format, cmd, mode] = deal(varargin{1:3}); 
   
   if ~ischar(mode)
	   error('MATLAB:serial:fprintf:invalidMODE', 'MODE must be either ''sync'' or ''async''.');
   end
   
   switch lower(mode)
   case 'sync'
       mode = 0;
   case 'async'
       mode = 1;
   otherwise
	   error('MATLAB:serial:fprintf:invalidMODE', 'MODE must be either ''sync'' or ''async''.');
   end
otherwise
   error('MATLAB:serial:fprintf:invalidSyntax', 'Too many input arguments.');
end   

% Error checking.
if ~isa(format, 'char')
	error('MATLAB:serial:fprintf:invalidFORMAT', 'FORMAT must be a string.');
end
if ~(isa(cmd, 'char') || isa(cmd, 'double'))
	error('MATLAB:serial:fprintf:invalidCMD', 'CMD must be a string.');
end

% Format the string.
[formattedCmd, errmsg] = sprintf(format, cmd);
if ~isempty(errmsg)
    error('instrument:fprintf:invalidFormat', errmsg);
end

% Call the fprintf java method.
try
   fprintf(igetfield(obj, 'jobject'), formattedCmd, mode);
catch
   error('MATLAB:serial:fprintf:opfailed', lasterr);
end