function output = instrfind(varargin)
%INSTRFIND Find instrument or device group objects with specified property values.
%
%   OUT = INSTRFIND returns all instrument objects that exist in memory.
%   The instrument objects are returned as an array to OUT.
%
%   OUT = INSTRFIND('P1', V1, 'P2', V2,...) returns an array, OUT, of
%   instrument objects or device group objects whose property names and
%   property values match those passed as param-value pairs, P1, V1, P2,
%   V2,... The param-value pairs can be specified as a cell array. 
%
%   OUT = INSTRFIND(S) returns an array, OUT, of instrument objects or
%   device group objects whose property values match those defined in
%   structure S whose field names are object property names and the field
%   values are the requested property values.
%   
%   OUT = INSTRFIND(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%   matching param-value pairs to the objects listed in OBJ. OBJ can be an
%   array of instrument objects or an array of device group objects.
%
%   Note that it is permissible to use param-value string pairs, structures,
%   and param-value cell array pairs in the same call to INSTRFIND.
%
%   When a property value is specified, it must use the same format as
%   GET returns. For example, if GET returns the Name as 'MyObject',
%   INSTRFIND will not find an object with a Name property value of
%   'myobject'. However, properties which have an enumerated list data type
%   will not be case sensitive when searching for property values. For
%   example, INSTRFIND will find an object with a RecordDetail property value
%   of 'Verbose' or 'verbose'. The data type of a property can be determined 
%   with PROPINFO's Constraint field.
%
%   Example:
%       g1 = gpib('ni', 0, 1, 'Tag', 'Oscilloscope');
%       g2 = gpib('ni', 0, 2, 'Tag', 'FunctionGenerator');
%       out1 = instrfind('Type', 'gpib')
%       out2 = instrfind('Tag', 'Oscilloscope')
%       out3 = instrfind({'Type', 'Tag'}, {'gpib', 'FunctionGenerator'})
%
%   See also INSTRUMENT/PROPINFO, INSTRUMENT/GET, ICGROUP/PROPINFO,
%   ICGROUP/GET, INSTRFINDALL, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.14.2.8 $  $Date: 2004/01/16 20:01:33 $

% Find all the objects.
output = localFindAllObjects;

% Return results.
switch nargin
case 0
    return;
otherwise
    firstInput = varargin{1};
    if (nargin == 1) && ~isa(firstInput, 'struct')
        error('instrument:instrfind:invalidPVPair', 'Invalid param-value pairs specified.');
    end

    if ~isa(output,'double'),
        try
            output = instrfind(output, varargin{:});
        catch
            localFixError;
            rethrow(lasterror);
        end
    end
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

% ************************************************************************
% Find all the objects.
function output = localFindAllObjects

out1 = com.mathworks.toolbox.instrument.Instrument.getNonLockedObjects;
out2 = com.mathworks.toolbox.instrument.device.ICDevice.getNonLockedObjects;

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
function localFixError

[errmsg, id] = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

lasterr(errmsg, id);


