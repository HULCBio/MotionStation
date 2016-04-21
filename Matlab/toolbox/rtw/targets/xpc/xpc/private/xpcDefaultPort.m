function port = xpcDefaultPort
% XPCDEFAULTPORT xPC Target private function.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: $ $Date: $

% Use the default settings
settings = getxpcenv('HostTargetComm', ...
                     'RS232HostPort', 'RS232Baudrate', ...
                     'TcpIpTargetAddress', 'TcpIpTargetPort');
if strcmp(lower(settings{1}), 'tcpip')
  settings(2:3) = [];
else
  settings(4:5) = [];
end
[mode, ipadd, ipport, comport, baud] = ...
    xpcgate('decodeconnsettings', settings{:});
mode = strmatch(mode, {'RS232', 'TCPIP'}, 'exact');
port = xpcgate('initconn', mode, ipadd, ipport, comport, baud);
xpcgate('setdefaultgateid', port);