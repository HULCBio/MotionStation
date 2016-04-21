function obj = tcpip(varargin)
%TCPIP Construct TCPIP object.
%
%   OBJ = TCPIP('RHOST') constructs a TCPIP object, OBJ, associated with
%   remote host, RHOST, and the default remote port value of 80.
%
%   In order to communicate with the instrument, the object, OBJ, must be
%   connected to RHOST with the FOPEN function.
%
%   OBJ = TCPIP('RHOST', RPORT) constructs a TCPIP object, OBJ, associated
%   with remote host, RHOST, and remote port value, RPORT.
%
%   When the TCPIP object is constructed, the object's Status property
%   is closed. Once the object is connected to the host with the FOPEN
%   function, the Status property is configured to open.
%
%   OBJ = TCPIP(..., RPORT, 'P1',V1,'P2',V2,...) construct a TCPIP object 
%   with the specified property values. If an invalid property name or
%   property value is specified the object will not be created.
%
%   Note that the property value pairs can be in any format supported by
%   the SET function, i.e., param-value string pairs, structures, and
%   param-value cell array pairs.
%
%   The default local host in multi-homed hosts is the systems default. 
%   LocalPort defaults to a value of [], and it causes any free local port to
%   be picked up as the local port. The LocalPort property is updated when
%   FOPEN is issued.
%
%   At any time you can view a complete listing of TCPIP functions and
%   properties with the INSTHELP function, i.e., instrhelp tcpip.
%
%   Example:
%       echotcpip('on',4012)
%       t = tcpip('localhost',4012);
%       fopen(t)
%       fwrite(t,65:74)
%       A = fread(t, 10);
%       fclose(t)
%       delete(t)
%       echotcpip('off')
%
%   See also ECHOTCPIP, ICINTERFACE/FOPEN, INSTRUMENT/PROPINFO, INSTRHELP,
%   SENDMAIL, UDP, URLREAD, URLWRITE.
%

%   RGW 6-05-01
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.4 $  $Date: 2004/01/16 20:01:53 $

% Initialize variables.
serrPort = 'RPORT must be an integer between 1 and 65535.';
defaultPort = 80;

% Create the parent class.
try
    instr = icinterface('tcpip');
catch
    error('instrument:tcpip:nojvm', 'TCPIP objects require JAVA support.');
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
    error('instrument:tcpip:invalidSyntax', 'The HOST must be specified.');
case 1
    host = varargin{1};
    port = defaultPort;
    props = {};
case 2
    host = varargin{1};
    port = varargin{2};
    if ~(localIsValidPort(port))
        error('instrument:tcpip:invalidRPORT', serrPort);
    end
    props = {};
otherwise
    % Ex. t = tcpip('144.212.100.10', 8080, 'p','v',...);
    host = varargin{1};
    port = varargin{2};
    if (isa(port,'numeric'))
        if ~(localIsValidPort(port))
            error('instrument:tcpip:invalidRPORT', serrPort);
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
    % Ex. t = tcpip('144.212.100.10')
    % Call the java constructor and store the java object in the
    % tcpip object.
    if isempty(host)
        error('instrument:tcpip:invalidRHOST', 'RHOST must be a non-empty string.');
    end
    try
        obj.jobject = handle(com.mathworks.toolbox.instrument.TCPIP(host,port));
        connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
    catch
        error('instrument:tcpip:cannotCreate', lasterr);
    end
    obj.type = 'tcpip';
    obj.constructor = 'tcpip';
    % Assign the class tag.
    obj = class(obj, 'tcpip', instr);
elseif strcmp(class(host), 'tcpip')
    obj = host;
elseif isa(host, 'com.mathworks.toolbox.instrument.TCPIP')
    obj.jobject = handle(host);
    obj.type = 'tcpip';
    obj.constructor = 'tcpip';
    obj = class(obj, 'tcpip', instr);
elseif isa(host, 'javahandle.com.mathworks.toolbox.instrument.TCPIP') 
    obj.jobject = host;
    obj.type = 'tcpip';
    obj.constructor = 'tcpip';
    obj = class(obj, 'tcpip', instr);
elseif ishandle(host)
    % True if loading an array of objects and the first is a TCPIP object. 
    if ~isempty(findstr(class(host(1)), 'com.mathworks.toolbox.instrument.TCPIP'))
        obj.jobject = host;
        obj.type = 'tcpip';
        obj.constructor = 'tcpip';
        obj = class(obj, 'tcpip', instr);
    else
       error('instrument:tcpip:invalidRHOST', 'Invalid RHOST specified.');
    end
else      
    error('instrument:tcpip:invalidRHOST', 'Invalid RHOST specified.');
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
[errmsg, id] = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
    errmsg = errmsg(1:end-1);
end

lasterr(errmsg, id);
