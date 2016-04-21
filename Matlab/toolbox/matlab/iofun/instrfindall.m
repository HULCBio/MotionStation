function output = instrfindall(varargin)
%INSTRFINDALL Find all serial port objects with specified property values.
%
%   OUT = INSTRFINDALL returns all serial port objects that exist in memory
%   regardless of the object's ObjectVisibility property value. The serial
%   port objects are returned as an array to OUT.
%
%   OUT = INSTRFINDALL('P1', V1, 'P2', V2,...) returns an array, OUT, of
%   serial port objects whose property names and property values match 
%   those passed as param-value pairs, P1, V1, P2, V2,... The param-value
%   pairs can be specified as a cell array. 
%
%   OUT = INSTRFINDALL(S) returns an array, OUT, of serial port objects whose
%   property values match those defined in structure S whose field names 
%   are serial port object property names and the field values are the 
%   requested property values.
%   
%   OUT = INSTRFINDALL(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%   matching param-value pairs to the serial port objects listed in OBJ. 
%   OBJ can be an array of serial port objects.
%
%   Note that it is permissible to use param-value string pairs, structures,
%   and param-value cell array pairs in the same call to INSTRFIND.
%
%   When a property value is specified, it must use the same format as
%   GET returns. For example, if GET returns the Name as 'MyObject',
%   INSTRFIND will not find an object with a Name property value of
%   'myobject'. However, properties which have an enumerated list data type
%   will not be case sensitive when searching for property values. For
%   example, INSTRFIND will find an object with a Parity property value
%   of 'Even' or 'even'. 
%
%   Example:
%       s1 = serial('COM1', 'Tag', 'Oscilloscope');
%       s2 = serial('COM2', 'Tag', 'FunctionGenerator');
%       set(s1, 'ObjectVisibility', 'off');
%       out1 = instrfind('Type', 'serial')
%       out2 = instrfindall('Type', 'serial');
%
%   See also SERIAL/GET, SERIAL/INSTRFIND.
%

%   MP 9-19-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 20:03:59 $

% Find all the objects.
objs = localFindAllObjects;

try
    if isempty(objs)
        output = instrfind(varargin{:});
    else
        output = instrfind(objs, varargin{:});
    end
catch
    info = lasterror;    
    error(strrep(info.identifier, 'instrfind', 'instrfindall'), info.message);
end

% ************************************************************************
% Find all the objects.
function output = localFindAllObjects

out1 = com.mathworks.toolbox.instrument.Instrument.jinstrfindall;
out2 = com.mathworks.toolbox.instrument.device.ICDevice.jinstrfindall;

if isempty(out1) && isempty(out2)
	output = [];
	return;
else
	output1 = javaToMATLAB(out1);
    output2 = javaToMATLAB(out2);
    output = [output1 output2];
end

% ************************************************************************
% Convert objects to their appropriate MATLAB object type.
function obj = javaToMATLAB(allObjects)

obj = [];

if isempty(allObjects)
    return;
end

for i = 0:allObjects.size-1
    inputObj  = allObjects.elementAt(i);
    className = class(inputObj);
    if strcmp(className, 'com.mathworks.toolbox.instrument.SerialComm')
        obj = [obj serial(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.SerialVisa')
        obj = [obj visa(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.GpibVisa')
        obj = [obj visa(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.VxiGpibVisa')
    	obj = [obj visa(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.VxiVisa')
   		obj = [obj visa(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.TCPIP')
		obj = [obj tcpip(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.UDP')
		obj = [obj udp(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.RsibVisa')
		obj = [obj visa(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.TcpipVisa')
		obj = [obj visa(inputObj)];
    elseif strcmp(className, 'com.mathworks.toolbox.instrument.UsbVisa')
		obj = [obj visa(inputObj)];        
    elseif findstr(className, 'ICDevice')
		obj = [obj icdevice(inputObj)];
    else
        obj= [obj gpib(inputObj)];
    end
end

