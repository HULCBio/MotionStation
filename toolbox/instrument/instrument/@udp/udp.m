function obj = udp(varargin)
%UDP Construct UDP object.
%
%   OBJ = UDP('') constructs an UDP object not associated with a remote host.
%
%   OBJ = UDP('RHOST') constructs an UDP object associated with remote host,
%   RHOST. 
%
%   OBJ = UDP('RHOST', RPORT) constructs an UDP object associated with remote
%   host, RHOST, and remote port value, RPORT. 
%
%   The object, OBJ, must be bound to the local socket with the FOPEN function.
%   The default remote port is 9090. The default local host in multi-homed
%   hosts is the systems default. The LocalPort property defaults to a value of
%   [], and it causes any free local port to be picked up as the local port. The
%   LocalPort property is updated when FOPEN is issued.
%
%   When the UDP object is constructed, the object's Status property is closed.
%   Once the object is bound to the local socket with the FOPEN function, the
%   Status property is configured to open.
%
%   OBJ = UDP(...,'P1',V1,'P2',V2,...) construct UDP objects with the specified
%   properties, P1, etc., and values V1, etc. If an invalid property name or
%   property value is specified the object will not be created.
%
%   Note that the property value pairs can be in any format supported by the
%   SET function, i.e., property-value string pairs, structures, and
%   property-value cell array pairs.  
%
%   Example:
%       echoudp('on',4012)
%       u = udp('127.0.0.1',4012);
%       fopen(u)
%       fwrite(u,65:74)
%       A = fread(u, 10);
%       fclose(u)
%       delete(u)
%       echoudp('off')
%
%   See also ECHOUDP, ICINTERFACE/FOPEN, INSTRUMENT/PROPINFO, INSTRHELP, TCPIP.
%

%   RGW 8-02-01
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.4 $  $Date: 2004/01/16 20:02:09 $


% variables
serrPort = 'RPORT must be an integer between 1 and 65535.';
serrPortID = 'instrument:udp:invalidRPORT';
defaultPort = 9090;

% Create the parent class.
try
    instr = icinterface('udp');
catch
    error('instrument:udp:nojvm','UDP objects require JAVA support.');
end

try
    instrPackage = findpackage('instrument');
catch
end

if isempty(instrPackage)
    instrPackage = schema.package('instrument');
end

switch (nargin)
case 0
    host = '';
    port = defaultPort;
    props = {};
case 1
    host = varargin{1};
    port = defaultPort;
    props = {};
case 2
    host = varargin{1};
    port = varargin{2};
    if ~localIsValidPort(port)
        error(serrPortID, serrPort);
    end
    props = {};
otherwise
    % Ex. t = tcpip('144.212.100.10', 8080, 'p','v',...);
    host = varargin{1};
    port = varargin{2};
    if isa(port,'numeric')
        if ~localIsValidPort(port)
            error(serrPortID, serrPort);
        end
        iniprop = 3;
    else
        port = defaultPort;
        iniprop = 2;
    end
    props = {varargin{iniprop:end}};
end	    

% parse the host
if (strcmp(class(host), 'char'))
    % Ex. t = udpp('144.212.100.10')
    % Call the java constructor and store the java object in the
    % udp object.
    try
        obj.jobject = handle(com.mathworks.toolbox.instrument.UDP(host,port));
        connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
    catch
        error('instrument:udp:cannotCreate', lasterr);
    end
    obj.type = 'udp';
    obj.constructor = 'udp';
    % Assign the class tag.
    obj = class(obj, 'udp', instr);
elseif strcmp(class(host), 'udp')
    obj = host;
elseif isa(host, 'com.mathworks.toolbox.instrument.UDP')
    obj.jobject = handle(host);
    obj.type = 'udp';
    obj.constructor = 'udp';
    obj = class(obj, 'udp', instr);
elseif isa(host, 'javahandle.com.mathworks.toolbox.instrument.UDP') 
    obj.jobject = host;
    obj.type = 'udp';
    obj.constructor = 'udp';
    obj = class(obj, 'udp', instr);
elseif ishandle(host)
    % True if loading an array of objects and the first is a TCPIP object. 
    if ~isempty(findstr(class(host(1)), 'com.mathworks.toolbox.instrument.UDP'))
        obj.jobject = host;
        obj.type = 'udp';
        obj.constructor = 'udp';
        obj = class(obj, 'udp', instr);
    else
       error(serrPortID, 'Invalid RHOST specified.');
    end
else      
    error(serrPortID, 'Invalid RHOST specified.');
end

if ~isempty(props)
    % Try setting the object properties.
    try
        set(obj, varargin{iniprop:end});
    catch
        delete(obj); 
        localFixError	
        rethrow(lasterror);
    end
end

% Pass the OOPs object to java. Used for callbacks.
obj.jobject(1).setMATLABObject(obj);

% *******************************************************************
% Determine if the specified port is in a valid range.
function out = localIsValidPort(port)

out = true;
if (~(isa(port,'numeric') && (port >= 1) && (port <= 65535) && (fix(port) == port)))
    out = false;
end

% *******************************************************************
% Fix the error message.
function localFixError

% Initialize variables.
errmsg = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
    errmsg = errmsg(1:end-1);
end

lasterr(errmsg);
