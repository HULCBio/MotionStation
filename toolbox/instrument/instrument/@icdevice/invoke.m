function varargout = invoke(obj, name, varargin)
%INVOKE Execute driver function on device or device group object.
%   
%   OUT=INVOKE(OBJ, 'NAME') execute driver function, NAME, on object, OBJ
%   and returns the result to OUT. OBJ must be a device object, a device
%   group object or an array of device group objects. OUT can be an array
%   of arguments depending on the output of the driver function, NAME.
%
%   OUT=INVOKE(OBJ, 'NAME', ARG1, ARG2, ...) executes driver function, NAME,
%   on OBJ and passes NAME the specified arguments, ARG1, ARG2,... and
%   returns the result to OUT.
%
%   The driver functions supported by OBJ can be found with INSTRHELP(OBJ)
%   or METHODS(OBJ). Help on the driver functions can be found with 
%   INSTRHELP(OBJ, 'NAME').
%
%   See also INSTRHELP, METHODS.
%

%   MP 10-14-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.8 $  $Date: 2004/01/16 19:59:14 $

% Error checking.
if (nargin == 1)
    error('icdevice:invoke:invalidSyntax', 'NAME must be specified.');
end

if ~ischar(name)
   error('icdevice:invoke:invalidArg', 'NAME must be a string. For a list of supported functions, use INSTRHELP(OBJ).'); 
end

if ~isa(obj, 'icdevice')
   error('icdevice:invoke:invalidArg', 'OBJ must be a 1-by-1 device object.'); 
end

if length(obj) > 1
    error('icdevice:invoke:invalidArg', 'OBJ must be a 1-by-1 device object.');
end

if ~isvalid(obj)
   error('icdevice:invoke:invalidArg', 'OBJ is an invalid object.');
end

% Extract java object.
jobj = igetfield(obj, 'jobject');

% Verify method is supported by object.
if ~isDeviceMethod(java(jobj), name)
    errorCode = 'icdevice:invoke:invalidFcn';
    errorMessage = ['The function ' name ' is not supported by this device object.'];
    
    typeOfObject = char(isChildMethod(java(jobj), name));
    if ~isempty(typeOfObject)
        errorMessage = [errorMessage sprintf('\n') 'This method is supported by the ' typeOfObject 'channel object.'];
    end
    
    error(errorCode, errorMessage);
end

% Verify that the object is connected to the instrument.
try
    verifyObjectState(jobj);
catch
    error('icdevice:invoke:invalidState', lasterr);
end

% If method was defined as m-code execute.
if isMethodMCode(jobj, name)    
    try
        code = char(getMethodMCode(jobj, name)); 
        output = instrgate('privateExecuteMCode', code, obj, varargin, nargout);
        
        % Create varargout appropriately based on type of output.
        if ~iscell(output)
            varargout{1} = output;
            return;
        end
        
        for i = 1:length(output)
            varargout{i} = output{i};
        end
        return;
	catch
        rethrow(lasterror)
	end
end

% Execute the java method.
try
    tempOut = executeMethod(jobj, name, varargin);
catch
    error('icdevice:invoke:executionErr', lasterr);
end

% Create output.
if ischar(tempOut(1))
    out = cell(length(tempOut), 1);
else
    out = cell(length(tempOut), length(tempOut(1)));
end

% Add values to output. Each row represents an object's response.
% Each column represents one output.
for i = 1:length(tempOut)
    x = tempOut(i);
    
    if isempty(x)
        out{i,1} = [];    
    elseif isa(x(1), 'java.lang.Object[]') && (length(x(1)) == 2)
        % Special case for binary data that needs to be formatted.
        out{i,1} = localFormatData(x(1));
    else
    
        % If a string was returned, don't split each character into a
        % cell element.
        if ischar(x)
            out{i,1} = x;
        else
            % Loop through and add to the output cell array.
            for j = 1:length(x);
                out{i,j} = x(j);
            end
        end
    end
end

% Return MATLAB empty.
if isempty(out)
    out = [];
end

% Assign to varargout. User gets output only if asked.
if (nargout == 1) || ~isempty(out)
    if numel(out) == 1
        varargout{1} = out{:};
    else
        [varargout(1:numel(out))] = out;
    end
end

% ---------------------------------------------------------------------
% Format the binary data read from the instrument.
function data = localFormatData(dataread)

data = dataread(1);
precision = char(dataread(2));

try	
  	switch precision
	case {'uint8', 'uchar', 'char'}
	    data = double(data);
        data = data + (data<0).*256;
    case {'uint16', 'ushort'}
        data = double(data);
        data = data + (data<0).*65536;
	case {'uint32', 'uint', 'ulong'}
        data = double(data);
        data = data + (data<0).*(2^32);
    case {'int8', 'schar'}
		data = double(data);
        data = data - (data>127)*256;
    otherwise
        data = double(data);
    end
catch
end

