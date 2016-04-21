function outForCustomFunction = privateExecuteMCode(fcn, obj, args, numout)
%PRIVATEEXECUTEMCODE helper function used by device objects.
%
%   PRIVATEEXECUTEMCODE helper function used by the device objects and
%   device input and output channels. 
%
%   PRIVATEEXECUTEMCODE is used when the INVOKE method is called.
%   
%   This function should not be called directly by the user.
%  
 
%   MP 01-03-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/01/16 20:02:39 $

% Extract the code from the fcn to be evaluated.
index   = findstr(fcn, sprintf('\n'));
fcnline = fcn(1:index(1));
code    = fcn(index(1)+1:end);

[output, input] = localParseFcnLine(fcnline);

% Check for varargin.
if (length(input) > 0) && (strcmp(input(end), 'varargin'))
    varargin = args(length(input)-1:end);
    input(end) = [];
end    

% Evaluate the input arguments.
for i=1:length(args)
    value = args{i};
    if (length(input) >= i+1)
        inputName = input{i+1};
        eval([inputName ' = value ;']);
    end
end

eval(['nargin = ' num2str(length(args)+1) ';']);
eval(['nargout = ' num2str(numout) ';']);

% Evaluate the code.
try
    eval(code);
catch
    localCleanupError
    rethrow(lasterror)
end

% Determine if varargout has been defined.
tempvarargout = {};
numOfOutput = length(output);

if (length(output) > 0) && (strcmp(output(end), 'varargout'))
    numOfOutput = length(output)-1;
    try
        eval('tempvarargout = varargout;');
    catch
        tempvarargout = {};
    end
end

% Assign output.
outForCustomFunction = cell(1, (length(output)-1) + length(tempvarargout));
for i = 1:numOfOutput
    outForCustomFunction{i} = eval(output{i});
end

if (numOfOutput ~= length(output))
    for i = numOfOutput+1:length(outForCustomFunction)
        outForCustomFunction{i} = tempvarargout{i-numOfOutput};
    end
end

% ---------------------------------------------------------------------
function [output, input] = localParseFcnLine(fcnline)

% Initialize variables.
output = {};
input  = {};

% Determine if there are any output arguments.
index = findstr(fcnline, '=');
if (index ~= -1)
    output = localParseOutputArguments(fcnline(9:index));
end

% Determine if there are any input arguments.
index = findstr(fcnline, '(');
if (index ~= -1)
    input = localParseInputArguments(fcnline(index:end));
end

% ---------------------------------------------------------------------
function output = localParseOutputArguments(str)

str = strrep(str, '[', '');
str = strrep(str, ']', '');
str = strrep(str, '=', '');
str = strtrim(str);

output = strread(str,'%s','delimiter', ',');

% ---------------------------------------------------------------------
function output = localParseInputArguments(str)

str = strrep(str, '(', '');
str = strrep(str, ')', '');
str = strtrim(str);

output = strread(str,'%s','delimiter', ',');

% ---------------------------------------------------------------------
function localCleanupError

[msg, id] = lasterr;
msg = strrep(msg, ['Error using ==> privateExecuteMCode' sprintf('\n')], '');
lasterr(msg, id);