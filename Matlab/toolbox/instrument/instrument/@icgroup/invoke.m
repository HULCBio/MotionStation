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
%   $Revision: 1.1.6.5 $  $Date: 2004/01/16 19:59:59 $

% Error checking.
if (nargin == 1)
    error('icgroup:invoke:invalidSyntax', 'NAME must be specified.');
end

if ~ischar(name)
   error('icgroup:invoke:invalidArg', 'NAME must be a string. For a list of supported functions, use INSTRHELP(OBJ).'); 
end

if ~isa(obj, 'icgroup')
   error('icgroup:invoke:invalidArg', 'OBJ must be a 1-by-1 device group object.'); 
end

if ~all(isvalid(obj))
   error('icgroup:invoke:invalidArg', 'OBJ is an invalid object.');
end

% Extract java object.
jobj = igetfield(obj, 'jobject');

% Verify method is supported by object.
if ~isDeviceChildMethod(java(jobj(1)), name)
    errorCode = 'icgroup:invoke:invalidFcn';
    errorMessage = ['The function ' name ' is not supported by this device group object.'];
    
    try
        if isParentMethod(java(jobj), name)
            errorMessage = [errorMessage sprintf('\n') 'This method is supported by the parent device object.'];
        end
    catch
    end
    
    error(errorCode, errorMessage);
end

% Verify that the objects are connected to the instrument.
try
   verifyObjectState(jobj(1))
catch
   error('icgroup:invoke:invalidState', 'OBJ''s parent must be connected to the instrument with CONNECT.');
end

% If method was defined as m-code execute.
if isMethodMCode(jobj(1), name)  
   try
       code = char(getMethodMCode(jobj(1), name)); 
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
       localFixError;
       error('icgroup:invoke:invalidArg', lasterr);
   end
end

% Execute the java method.
try
    for i = 1:length(obj)
        tempOut(i) = executeMethod(jobj(i), name, varargin);
    end
catch
    localFixError;
    error('icgroup:invoke:executionErr', lasterr);
end

% Create output.
out = cell(length(tempOut), length(tempOut(1)));
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

if isempty(out)
    out = [];
end

% Assign to varargout.
if (nargout == 1) || ~isempty(out)
    if size(out,2) == 1
        if length(out) == 1
            % There is one output argument and one group object.
            varargout{1} = out{:};
        else
            % There is one output argument and multiple group objects.
            varargout{1} = out;
        end
    elseif size(out,1) == 1
        % There is one group object and multiple output arguments.
        [varargout(1:numel(out))] = out;
    else
        % Theare are more than one group objects and multiple output
        % arguments.
        for i = 1:nargout
            varargout{i} = out(:,i);
        end
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

% -------------------------------------------------------------------
% Fix the error message.
function localFixError

% Initialize variables.
[out, id] = lasterr;

% Remove the trailing carriage returns from errmsg.
while out(end) == sprintf('\n')
   out = out(1:end-1);
end

% Remove the "Error using ..." message.
if findstr(out, 'Error using') == 1
    index = findstr(out, sprintf('\n'));
    if (index ~= -1)
        out = out(index+1:end);
    end
end

% Reset the error and it's id.
lasterr(out, id);
