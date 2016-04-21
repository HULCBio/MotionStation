function out = privateCreateObjHelper(action, varargin)
%PRIVATECREATEOBJHELPER helper function used by the New Object Dialog.
%
%   PRIVATECREATEOBJHELPER helper function used by the New Object 
%   Dialog to create instrument objects. This dialog is used by
%   INSTRCREATE, MIDTEST and TMTOOL.
%   
%   This function should not be called directly be the user.
%  
%   See also INSTRCREATE, MIDTEST, TMTOOL.
%
 
%   MP 9-08-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:02:32 $

switch action
case 'serial'
    % Create the serial port object.
    obj = serial(varargin{1});
    out = createdObject(obj);
case 'gpib'
    % Parse the input.
    vendor = varargin{1};
    bid = str2num(varargin{2});
    pad = str2num(varargin{3});
    
    % Create the GPIB object.
    obj = gpib(vendor, bid, pad);
    out = createdObject(obj);
case 'visa'
    % Create the VISA object.
    obj = visa(varargin{1}, varargin{2});
    out = createdObject(obj);
case 'tcpip'
    % Parse the inputs.
    remotehost = varargin{1};
    remoteport = str2num(varargin{2});
    
    % Call the TCPIP constructor with the correct arguments based
    % on what the user entered in the dialog.
    if isempty(remoteport)
        obj = tcpip(remotehost);
    else
        obj = tcpip(remotehost, remoteport);
    end
    
    % Get needed output arguments for GUI.
    out = createdObject(obj);
case 'udp'
    % Parse the input.
    remotehost = varargin{1};
    remoteport = str2num(varargin{2});
    
    % Call the UDP constructor with the correct arguments based
    % on what the user entered in the dialog.
    if isempty(remotehost)
        obj = udp;
    elseif isempty(remoteport)
        obj = udp(remotehost);
    else
        obj = udp(remotehost, remoteport);
    end
    
    % Get needed output arguments for GUI.
    out = createdObject(obj);
case 'device'
    % Parse the input.
    driverName = char(varargin{1});
    interface  = varargin{2};
    
    if isa(interface, 'com.mathworks.toolbox.instrument.Instrument');
        interface = localGetValidObject(interface);
    elseif iscell(interface)
        constructor = interface{1};
        instrfindArgs = interface{2};
        obj = eval(['instrfind' instrfindArgs]);
        if ~isempty(obj)
            fclose(obj);
            interface = obj(1);
        else
            obj = eval(constructor);
        end
    else
        interface = char(interface)
    end
    
    % Call the device object constructor with the correct arguments based
    % on what the user entered in the dialog.
    if isempty(interface)
        obj = icdevice(driverName);
    else
        obj = icdevice(driverName, interface);
    end
    
    % Get needed output arguments for GUI.
    out = createdObject(obj);    
end

% ------------------------------------------------------------------------
% Create the output arguments needed by instrcreate after an object
% has been created.
function out = createdObject(obj)

out = {obj.Type, obj, obj.Name, java(igetfield(obj, 'jobject'))};

% ------------------------------------------------------------------------
% Get the MATLAB OOPs object for the java instrument object.
function out = localGetValidObject(instr)

objs = instrfindall;
for i = 1:length(objs)
    obj = objs(i);
    jobj = java(igetfield(obj, 'jobject'));
    if (jobj == instr)
        out = obj;
        return;
    end
end    
