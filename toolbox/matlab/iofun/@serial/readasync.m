function readasync(obj, varargin)
%READASYNC Read data asynchronously from device.
%
%   READASYNC(OBJ) reads data asynchronously from the device connected
%   to serial port object, OBJ. READASYNC returns control to MATLAB 
%   immediately.  
%
%   The data read is stored in the input buffer. The BytesAvailable
%   property indicates the number of bytes stored in the input
%   buffer. 
%
%   READASYNC will stop reading data when one of the following occurs:
%       1. The terminator is received as specified by the Terminator
%          property
%       2. A timeout occurs as specified by the Timeout property 
%       3. The input buffer has been filled
% 
%   The serial port object must be connected to the device with the 
%   FOPEN function before any data can be read from the device otherwise
%   an error is returned. A connected serial port object has a Status
%   property value of open.
%
%   READASYNC(OBJ, SIZE) reads at most SIZE bytes from the device.
%   If SIZE is greater than the difference between OBJ's InputBufferSize
%   property value and OBJ's BytesAvailable property value an error will
%   be returned.
%
%   The TransferStatus property indicates the type of asynchronous 
%   operation that is in progress.
%
%   An error is returned if READASYNC is called while an asynchronous 
%   read is in progress. However, an asynchronous write can occur while  
%   an asynchronous read is in progress.
%
%   The STOPASYNC function can be used to stop an asynchronous read
%   operation.
%
%   Example:
%       s = serial('COM1', 'InputBufferSize', 5000);
%       fopen(s);
%       fprintf(s, 'Curve?');
%       readasync(s);
%       data = fread(s, 2500);
%       fclose(s);
%      
%   See also SERIAL/FOPEN, SERIAL/STOPASYNC.
%

%   MP 12-30-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.3 $  $Date: 2004/01/16 20:04:37 $

% Error checking.
if (nargin > 2)
    error('MATLAB:serial:readasync:invalidSyntax', 'Too many input arguments.');
end

if ~isa(obj, 'icinterface')
    error('MATLAB:serial:readasync:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

if length(obj) > 1
    error('MATLAB:serial:readasync:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

switch nargin
case 2
    numBytes = varargin{1};
    if ~isa(numBytes, 'double')
        error('MATLAB:serial:readasync:invalidSIZE', 'SIZE must be a double.');
    elseif length(numBytes) > 1
        error('MATLAB:serial:readasync:invalidSIZE', 'SIZE must be a scalar.');
    elseif (numBytes <= 0)
        error('MATLAB:serial:readasync:invalidSIZE','SIZE must be greater than 0.');
    elseif (isinf(numBytes))
        error('MATLAB:serial:readasync:invalidSIZE','SIZE cannot be set to INF.');
    elseif (isnan(numBytes))
        error('MATLAB:serial:readasync:invalidSIZE','SIZE cannot be set to NaN.');
    end
end

% Get the java object.
jobject = igetfield(obj, 'jobject');

% Call the java readasync method.
try
    readasync(jobject, varargin{:});
catch
   error('MATLAB:serial:readasync:opfailed', lasterr);
end
