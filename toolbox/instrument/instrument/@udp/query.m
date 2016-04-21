function varargout = query(obj, varargin)
%QUERY Write and read formatted data from instrument.
%
%   A=QUERY(OBJ,'CMD') writes the string, CMD, to the instrument 
%   connected to interface object, OBJ and reads the data available 
%   from the instrument as a result of CMD. OBJ must be a 1-by-1
%   interface object. QUERY is equivalent to using the FPRINTF and 
%   FGETS functions.
%
%   The interface object must be connected to the instrument with the 
%   FOPEN function before any data can be queried from the instrument
%   otherwise an error will be returned. A connected interface object
%   has a Status property value of open.
%
%   A=QUERY(OBJ,'CMD','WFORMAT') writes the string CMD, to the instrument
%   connected to interface object, OBJ, with the format, WFORMAT. By 
%   default, the %s\n format string is used.
%
%   A=QUERY(OBJ,'CMD','WFORMAT','RFORMAT') writes the string, CMD, with the
%   specified format, WFORMAT and reads data from the instrument connected 
%   to interface object, OBJ, and converts it according to the specified 
%   format string, RFORMAT. By default, the %c format string is used.
%
%   WFORMAT and RFORMAT is a string containing C language conversion 
%   specifications. Conversion specifications involve the character % 
%   and conversion characters d, i, o, u, x, X, f, e, E, g, G, c, and 
%   s. See the SPRINTF file I/O format specifications or a C manual 
%   for complete details.
%
%   [A,COUNT]=QUERY(OBJ,...) returns the number of values read to COUNT.
%
%   [A,COUNT,MSG]=QUERY(OBJ,...) returns a message, MSG, if QUERY did
%   not complete successfully. If MSG is not specified a warning is 
%   displayed to the command line. 
%
%   [A,COUNT,MSG,DATAGRAMADDRESS]=QUERY(OBJ,...) returns the datagram
%   address to DATAGRAMADDRESS, if OBJ is a UDP object. If more than
%   one datagram is read, DATAGRAMADDRESS is ''.
%
%   [A,COUNT,MSG,DATAGRAMADDRESS,DATAGRAMPORT]=QUERY(OBJ,...) returns
%   the datagram port to DATAGRAMPORT, if OBJ is a UDP object. If more
%   than one datagram is read, DATAGRAMPORT is [].
%
%   OBJ's ValuesSent property will be updated by the number of values
%   written from the QUERY operation. OBJ's ValuesReceived property
%   will be updated by the number of values read from the QUERY operation.
% 
%   If OBJ's RecordStatus property is configured to on with the RECORD
%   function, the data sent and the data received will be recorded in 
%   the file specified by OBJ's RecordName property value.
%
%   Example:
%       g = gpib('ni', 0, 2);
%       fopen(g);
%       idn = query(g, '*IDN?');
%       fclose(g);
%
%   See also ICINTERFACE/FOPEN, ICINTERFACE/FGETS, ICINTERFACE/FPRINTF, 
%   INSTRUMENT/PROPINFO, INSTRHELP, SPRINTF, SSCANF.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:02:06 $

% Error checking.
if (nargout > 5)
    error('instrument:query:invalidSyntax', 'Too many output arguments.');
end

if ~isa(obj, 'icinterface')
    error('instrument:query:invalidOBJ', 'OBJ must be an interface object.');
end

if (length(obj) > 1)
    error('instrument:query:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

% Parse the input.
switch (nargin)
case 1
   error('instrument:query:invalidSyntax', 'CMD must be specified.');
case 2
   cmd = varargin{1};
   wformat = '%s\n';
   rformat = '%c';
case 3
   [cmd, wformat] = deal(varargin{1:2});
   rformat = '%c';
case 4
   [cmd, wformat, rformat] = deal(varargin{1:3});
case 5
   error('instrument:query:invalidSyntax', 'Too many input arguments.');
end   

% Error checking.
if ~isa(cmd, 'char')
    error('instrument:query:invalidCMD', 'CMD must be a string.');
end

if ~isa(wformat, 'char')
    error('instrument:query:invalidWFORMAT', 'WFORMAT must be a string.');
end

if ~isa(rformat, 'char')
    error('instrument:query:invalidRFORMAT', 'RFORMAT must be a string.');
end

% Format the string.
[formattedCmd, errmsg] = sprintf(wformat, cmd);
if ~isempty(errmsg)
    error('instrument:fprintf:invalidFormat', lasterr);
end

% Call the query java method.
try
   out = query(igetfield(obj, 'jobject'), formattedCmd);
catch
   error('instrument:query:opfailed', lasterr);
end   

% Parse the output.
data     = out(1);
count    = out(2);
errmsg   = out(3);
rAddress = out(4);
rPort    = out(5);

% Format the result and return.
try
  [result, numRead, err] = sscanf(data, rformat);
  % Data could be formatted.  Return formatted data, the number
  % of values read and any errors from the java code.
  varargout = {result, count, errmsg, rAddress, rPort};
catch
  % An error occurred while formatting the data.  Return the 
  % unformatted data, the number of values reaad and the error
  % from sscanf (lasterr).
  varargout = {data, count, lasterr, rAddress, rPort};
end   

% sscanf errored (as third output argument). Return the unformatted 
% data, the number of values read and sscanf's third output argument.
if ~isempty(err)
  varargout = {data, count, err, rAddress, rPort};
end

% Warn if the MSG output variable is not specified.
if (nargout < 3) && ~isempty(varargout{3})
    % Store the warning state.
    warnState = warning('backtrace', 'off');
    
    warning('instrument:query:unsuccessfulRead', varargout{3});
    
    % Restore the warning state.
    warning(warnState);
end