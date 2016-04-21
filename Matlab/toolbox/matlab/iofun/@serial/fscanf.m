function varargout = fscanf(obj, varargin)
%FSCANF Read data from device and format as text.
%
%   A=FSCANF(OBJ) reads data from the device connected to serial port
%   object, OBJ, and formats the data as text and returns to A.  
%
%   FSCANF blocks until one of the following occurs:
%       1. The terminator is received as specified by the Terminator
%          property
%       2. A timeout occurs as specified by the Timeout property
%       3. The input buffer is filled 
%
%   The serial port object must be connected to the device with the
%   FOPEN function before any data can be read from the device otherwise
%   an error is returned. A connected serial port object has a Status
%   property value of open.
%
%   A=FSCANF(OBJ,'FORMAT') reads data from the device connected to serial 
%   port object, OBJ, and converts it according to the specified FORMAT 
%   string. By default, the %c FORMAT string is used. The SSCANF function 
%   is used to format the data read from the device.
%
%   FORMAT is a string containing C language conversion specifications. 
%   Conversion specifications involve the character % and the conversion 
%   characters d, i, o, u, x, X, f, e, E, g, G, c, and s. See the SSCANF
%   file I/O format specifications or a C manual for complete details.
%
%   A=FSCANF(OBJ,'FORMAT',SIZE) reads the specified number of values,
%   SIZE, from the device connected to serial port object, OBJ.   
%
%   FSCANF blocks until one of the following occurs:
%       1. The terminator is received as specified by the Terminator
%          property
%       2. A timeout occurs as specified by the Timeout property
%       3. SIZE values have been received
%
%   Available options for SIZE include:
%
%      N      read at most N values into a column vector.
%      [M,N]  read at most M * N values filling an M-by-N
%             matrix, in column order.
%
%   SIZE cannot be set to INF. If SIZE is greater than OBJ's 
%   InputBufferSize property value an error will be returned.
%
%   If the matrix A results from using character conversions only and
%   SIZE is not of the form [M,N] then a row vector is returned.
%
%   [A,COUNT]=FSCANF(OBJ,...) returns the number of values read to COUNT.
%
%   [A,COUNT,MSG]=FSCANF(OBJ,...) returns a message, MSG, if FSCANF
%   did not complete successfully. If MSG is not specified a warning is 
%   displayed to the command line. 
%
%   OBJ's ValuesReceived property will be updated by the number of values
%   read from the device including the terminator.
% 
%   If OBJ's RecordStatus property is configured to on with the RECORD
%   function, the data received will be recorded in the file specified
%   by OBJ's RecordName property value.
%    
%   Examples:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%       delete(s);
%
%   See also SERIAL/FOPEN, SERIAL/FREAD, SERIAL/RECORD, STRREAD, SSCANF.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.3 $  $Date: 2004/01/16 20:04:18 $

% Error checking.
if nargout > 3
   error('MATLAB:serial:fscanf:invalidSyntax', 'Too many output arguments.');
end  

if ~isa(obj, 'icinterface')
   error('MATLAB:serial:fscanf:invalidOBJ', 'OBJ must be an interface object.');
end	

if length(obj)>1
    error('MATLAB:serial:fscanf:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

% Parse the input.
switch (nargin)
case 1
   % Ex. fscanf(obj);
   format = '%c';
   size = 0;
case 2
   % Ex. fscanf(obj, '%d');
   format = varargin{1};
   size = 0;
case 3
   % Ex. fscanf(obj, '%d', 10);
   [format, size] = deal(varargin{1:2});
   if ~isa(size, 'double')
	   error('MATLAB:serial:fscanf:invalidSIZE', 'SIZE must be a double.');
   elseif (size < 1)
       error('MATLAB:serial:fscanf:invalidSIZE', 'SIZE must be greater than 0.');	
   end
otherwise
   error('MATLAB:serial:fscanf:invalidSyntax', 'Too many input arguments.');
end   

% Error checking.
if ~ischar(format)
	error('MATLAB:serial:fscanf:invalidFORMAT', 'FORMAT must be a string.');
elseif ~isa(size, 'double')
    error('MATLAB:serial:fscanf:invalidSIZE', 'SIZE must be a double.');
elseif (any(isinf(size)))
   error('MATLAB:serial:fscanf:invalidSIZE', 'SIZE cannot be set to INF.');
elseif (any(isnan(size)))
   error('MATLAB:serial:fscanf:invalidSIZE', 'SIZE cannot be set to NaN.');
end

% Floor the size.  
% Note: The call to floor must be done after the error checking
% since floor on a string converts the string to its ascii value.
size = floor(size);

% Determine the total number of elements to read.
switch (length(size))
case 1
    totalSize = size;
case 2
    totalSize = size(1)*size(2);
    if (totalSize < 1)
    	error('MATLAB:serial:fscanf:invalidSIZE', 'SIZE must be greater than 0.');
	end
otherwise
    error('MATLAB:serial:fscanf:invalidSIZE', 'Invalid SIZE specified. Type ''help serial/fscanf'' for more information.');
end


% Call the fscanf java method.
try 
   out = fscanf(igetfield(obj, 'jobject'), totalSize);
catch
   error('MATLAB:serial:fscanf:opfailed', lasterr);
end   

% Parse the output.
data = out(1);
count = out(2);
errmsg = out(3);

% Format the result and return.
try
  if length(size) > 1
	  [result, numRead, err] = sscanf(data, format, size);
  else
      [result, numRead, err] = sscanf(data, format);
  end
  % Data could be formatted.  Return formatted data, the number
  % of values read and any errors from the java code.
  varargout = {result, count, errmsg};
catch
  % An error occurred while formatting the data.  Return the 
  % unformatted data, the number of values reaad and the error
  % from sscanf (lasterr).
  varargout = {data, count, lasterr};
end   

% sscanf errored (as third output argument). If sscanf returned nothing, return 
% the unformatted data, the number of values read and sscanf's third output argument
% otherwise return the result of sscanf along with the number of values read and
% the third output argument.
if ~isempty(err)
    if isempty(result)
        varargout = {data, count, err};
    else
        varargout = {result, count,err};
    end
end

% Warn if the MSG output variable is not specified.
if (nargout ~= 3) && ~isempty(varargout{3})
    % Store the warning state.
    warnState = warning('backtrace', 'off');
    
    warning('MATLAB:serial:fscanf:unsuccessfulRead', varargout{3});
    
    % Restore the warning state.
    warning(warnState);
end


