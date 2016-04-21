function [mode, ipadd, ipport, comport, baud] = ...
    decodeconnsettings(type, data1, data2)
% DECODECONNSETTINGS xPC Target private function.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: $  $Date: 2003/10/28 19:39:16 $


% Convert the input arguments into a format more palatable to xpcgate.

% Mode: 1 (RS232) or 2 (TCPIP)
% IpAdd: String with the ip address
% IpPort: String with the IP Port
% Comport: 0 for COM1, 1 for COM2, etc.
% Baudrate: double scalar with the numeric bauddate

modes = {'rs232', 'tcpip'};

mode = strmatch(lower(type), modes);

if numel(mode) ~= 1
  error('xPCTarget:connsettings', 'Invalid mode: must be RS232 or TCPIP');
end

if mode == 1                            % rs232
  ipadd  = '';
  ipport = '';
  [s, f, t] = regexp(lower(data1), '^com\d$');
  if isempty(t)
    error('xPCTarget:connsettings', ...
          'COM port must be specified as ''COM1'', ''COM2'', etc.');
  end
  comport = eval(data1(end)) - 1;
  if isa(data2, 'char')
    data2   = eval(data2);
  end
  baudrates = [115200, 57600, 38400, 19200, 9600, 4800, 2400, 1200];
  if ~ismember(data2, baudrates);
    error('xPCTarget:connsettings', ...
          'Baudrate must be one of the following: %s', ...
          sprintf('%d ', baudrates));
  end
  baud = data2;
else
  comport = 0;
  baud    = 0;
  ipadd   = data1;
  ipport  = data2;
end
mode = upper(modes{mode});
