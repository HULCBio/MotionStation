function freeserial(port)
%FREESERIAL Release MATLAB's hold on serial port.
%
%   FREESERIAL releases MATLAB's hold on all serial ports. 
%
%   FREESERIAL('PORT') releases MATLAB's hold on the specified port,
%   PORT. PORT can be a cell array of strings.  
%
%   FREESERIAL(OBJ) releases MATLAB's hold on the port associated with
%   serial port object, OBJ. OBJ can be an array of serial port objects.
%   
%   An error will be returned if a serial port object is connected 
%   to the port that is being freed. The FCLOSE command can be used 
%   to disconnect the serial port object from the serial port.
%
%   FREESERIAL should be used only if you need to connect to the serial
%   port from another application after a serial port object has been 
%   connected to that port, and you do not want to exit MATLAB.
%
%   Note: this function is necessary only on the Windows platform.
%
%   Example:
%       freeserial('COM1');
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?')
%       idn = fscanf(s);
%       fclose(s)
%       freeserial(s)
%   
%   See also INSTRUMENT/FCLOSE.
%

%   MP 4-11-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:03:56 $

% Store the warning state.
warnState = warning('backtrace', 'off');

% Warn.
warning('MATLAB:serial:freeserial:obsolete','FREESERIAL is being obsoleted. The serial port is released with FCLOSE(OBJ).');

% Restore the warning state.
warning(warnState);

