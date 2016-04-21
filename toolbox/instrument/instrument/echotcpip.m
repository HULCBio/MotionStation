function echotcpip(varargin)
%ECHOTCPIP start or stop a TCP/IP echo server.
%
%   ECHOTCPIP('STATE',PORT) starts a TCP/IP server with port number,
%   PORT. STATE can only be 'on'.
%
%   ECHOTCPIP('STATE') stops the echo server. STATE can only be 'off'.
% 
%   Example:
%       echotcpip('on', 4000);
%       t = tcpip('localhost', 4000);
%       fopen(t);
%       fprintf(t, 'echo this string.');
%       data = fscanf(t);
%       echotcpip('off');
%       fclose(t);
%       delete(t);
%
%   See also ECHOUDP, TCPIP, UDP.
%

% RGW 02-08-2003
% Copyright 1999-2004 The MathWorks, Inc.
% $Revision: 1.2.2.5 $  $Date: 2004/03/30 13:06:26 $

import com.mathworks.toolbox.instrument.EchoTCP;

% Initialize error messages.
invalidStateErrMsg = 'Invalid STATE. STATE must be either ''on'' or ''off''.';

switch nargin
case 0
    error('instrument:echotcpip:invalidSyntax', 'STATE must be specified. Type ''instrhelp echotcpip'' for more information.');
case 1
    if ~ischar(varargin{1})
        error('instrument:echotcpip:invalidSyntax',invalidStateErrMsg);
    end
    
    % Get the state - on or off.
    state = lower(varargin{1});
    switch (state)
    case 'off'
        echoServer = EchoTCP.getEchoServer;        
        if isempty(echoServer)
            return;
        end        
        
        % Shut down the echo server.
        portNumber = echoServer.getPort;
        echoServer.shutDownServer;

        % workaround for JVM 1.3 bug on LINUX
        if (strcmp(upper(computer),'GLNX86'))
            try
                t=tcpip('localhost', portNumber);
                fopen(t);
                fclose(t);
                delete(t);
            catch
                delete(t);
            end
        end
    case 'on'
        error('instrument:echotcpip:invalidSyntax', 'PORT must be specified.');
    otherwise
        error('instrument:echotcpip:invalidSyntax', invalidStateErrMsg);
    end
case 2 
    if ~ischar(varargin{1})
        error('instrument:echotcpip:invalidSyntax', invalidStateErrMsg);    
    end
    
    % Based on the state, turn on or off the echo server.
    switch (lower(varargin{1}))
    case 'on'
        port = varargin{2};
        if (~localIsValidPort(port))
            error('instrument:echotcpip:invalidSyntax', 'PORT must be an integer ranging from 1 to 65535.')
        end
        
        % Determine if there is already a connection.
        echoServer = EchoTCP.getEchoServer;        
        
        if isempty(echoServer)
            com.mathworks.toolbox.instrument.EchoTCP(port);
        else
            portNumber = echoServer.getPort;
            error('instrument:echotcpip:running', ['TCPIP echo server is already running on port ' num2str(portNumber) '.']);
        end        
    case 'off'
        error('instrument:echotcpip:invalidSyntax', 'Use ECHOTCPIP(''OFF'') to turn the echo server off.');
    otherwise
        error('instrument:echotcpip:invalidSyntax',invalidStateErrMsg);
    end
otherwise
    error('instrument:echotcpip:invalidSyntax', 'Too many input arguments.')
end
    
% -------------------------------------------------------------------
% Determine if the specified port is in a valid range.
function out = localIsValidPort(port)

out = true;
if ((numel(port) ~= 1) || ~isnumeric(port) || isempty(port) || (port < 1) || (port > 65535) || (fix(port) ~= port))
    out = false;
end

