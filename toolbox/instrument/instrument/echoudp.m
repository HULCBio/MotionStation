function echoudp(varargin)
%ECHOUDP start or stop a UDP echo server.
%
%   ECHOUDP('STATE',PORT) starts a UDP server with port number, 
%   PORT. STATE can only be 'on'.
%
%   ECHOUDP('STATE') stops the echo server. STATE can only be 
%   'off'.
% 
%   Example:
%       echoudp('on', 4000);
%       u = udp('localhost', 4000);
%       fopen(u);
%       fprintf(u, 'echo this string.');
%       data = fscanf(u);
%       echoudp('off');
%       fclose(u);
%       delete(u);
%
%   See also ECHOTCPIP, TCPIP, UDP.
%

% RGW 02-08-2003
% Copyright 1999-2004 The MathWorks, Inc.
% $Revision: 1.1.2.5 $  $Date: 2004/03/30 13:06:27 $

import com.mathworks.toolbox.instrument.EchoUDP;

% Initialize error messages.
invalidStateErrMsg = 'Invalid STATE. STATE must be either ''on'' or ''off''.';

switch nargin
case 0
    error('instrument:echoudp:invalidSyntax', 'STATE must be specified. Type ''instrhelp echoudp'' for more information.');
case 1
    if ~ischar(varargin{1})
        error('instrument:echoudp:invalidSyntax',invalidStateErrMsg);
    end    

    % Get the state - on or off.
    state = lower(varargin{1});
    switch (state)
    case 'off'
        echoServer = EchoUDP.getEchoServer;
        
        % Shut down the echo server.
        if ~isempty(echoServer)
            echoServer.shutDownServer;
        end         
    case 'on'
        error('instrument:echoudp:invalidSyntax', 'PORT must be specified.');
    otherwise
        error('instrument:echoudp:invalidSyntax', invalidStateErrMsg);
    end

case 2   
    if ~ischar(varargin{1})
        error('instrument:echoudp:invalidSyntax', invalidStateErrMsg);
    end
    
    % Based on the state, turn on or off the echo server.
    switch (lower(varargin{1}))
    case 'on'
        port = varargin{2};
        if (~localIsValidPort(port))
            error('instrument:echoudp:invalidSyntax', 'PORT must be an integer ranging from 1 to 65535.')
        end
    
        % Determine if there is already a connection.
        echoServer = EchoUDP.getEchoServer;        

        if isempty(echoServer)
            com.mathworks.toolbox.instrument.EchoUDP(port);
        else
            portNumber = echoServer.getPort;
            error('instrument:echotcpip:running', ['UDP echo server is already running on port ' num2str(portNumber) '.']);
        end  
    case 'off'
        error('instrument:echoudp:invalidSyntax', 'Use ECHOUDP(''OFF'') to turn the echo server off.');
    otherwise
        error('instrument:echoudp:invalidSyntax', invalidStateErrMsg);
    end
otherwise
    error('instrument:echoudp:invalidSyntax', 'Too many input arguments.')
end

% -------------------------------------------------------------------
% Determine if the specified port is in a valid range.
function out = localIsValidPort(port)

out = true;
if ((numel(port) ~= 1) || ~isnumeric(port) || isempty(port) || (port < 1) || (port > 65535) || (fix(port) ~= port))
    out = false;
    return
end

