function varargout = resolvehost(varargin)
%RESOLVEHOST Return the name and address of the host.
%
%   NAME = RESOLVEHOST('HOST') returns the name of host, HOST.
%
%   [NAME, ADDRESS] = RESOLVEHOST('HOST') returns the address of host, HOST,
%   in addition to the HOST'S name. HOST can be either the network name or
%   address of the host. If HOST is not a valid network host, NAME and ADDRESS
%   return as empty strings.
%  
%   For example, 'www.mathworks.com' is a network name and '144.212.100.10' 
%   is a network address.
%
%   OUT = RESOLVEHOST('HOST','RETURNTYPE') returns the host name if RETURNTYPE 
%   is 'name' and returns the host address if RETURNTYPE is 'address'. By default,
%   RETURNTYPE is 'name'.
%
%   Example:
%       [name,address] = resolvehost('144.212.100.10')
%       name = resolvehost('144.212.100.10','name')
%       address = resolvehost('www.mathworks.com','address')
%
%   See also TCPIP, UDP.

%   RGW 7-17-01
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/01/16 20:03:16 $
%

% Error if java is not running.
if ~usejava('jvm')
    error('instrument:resolvehost:nojvm', 'RESOLVEHOST requires JAVA support.');
end

if (nargout > 2)
    error('instrument:resolvehost:invalidSyntax', 'Too many output arguments.');
end

switch nargin
case 0
    error('instrument:resolvehost:invalidSyntax', 'HOST must be specified.');
case 1
    host = lower(varargin{1});
    if (~ischar(host) )
        error('instrument:resolvehost:invalidSyntax', 'Invalid HOST. HOST must be a string.');
    end
    
    list='both';
case 2
    host = lower(varargin{1});
    if (~ischar(host) )
        error('instrument:resolvehost:invalidSyntax', 'Invalid HOST. HOST must be a string.');
    end
    
    list = lower(varargin{2});
    if ( ~ischar(list) || (~ischar(list) && isempty(list)) )
        error('instrument:resolvehost:invalidSyntax', 'Invalid FLAG. FLAG must be a string.');
    elseif (~strcmp(list, {'name' 'address'} ))
        error('instrument:resolvehost:invalidSyntax', 'Invalid FLAG. FLAG must be either ''name'' or ''address''.');
    end
otherwise
    error('instrument:resolvehost:invalidSyntax', 'Too many input arguments.');
end

if (~localVerifyIPAddress(host))
    varargout{1}='';
    varargout{2}='';
    return
end

% Create the output structure.
try
    varargout = cell(com.mathworks.toolbox.instrument.TCPIP.resolveHost(host,list));
catch
    error('instrument:resolvehost:opfailed', lasterr);
end

%--------------------------------------------------------------------------
% Display warning if host is bad IP address. Valid IPs are x.x.x.x where x=0-255
function flag = localVerifyIPAddress(host)

flag = false;
try
    % Parse the string x.x.x.x into four numbers.
    out = strread(host, '%d', 'delimiter', '.');
    if length(out) ~= 4
        return
    end
    for i=1:4
        if ((out(i) < 0) || (out(i) > 255))
            warnState = warning('backtrace', 'off');
            warning('instrument:resolvehost:invalidIPaddress','Invalid IP address. A valid IP address has the format x.x.x.x where x ranges between 0 and 255.');
            warning(warnState);
            return
        end
    end
    flag = true;
catch
    flag = true;
end


