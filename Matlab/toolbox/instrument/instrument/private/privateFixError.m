function privateFixError
%PRIVATEFIXERROR Remove trailing carriage returns from error message.
%
%   PRIVATEFIXERROR removes the trailing cariage returns from the 
%   error message and cleans up java class names.
%
%   This is a helper function used by functions in the Instrument
%   Control Toolbox. This function should not be called directly
%   by users.
%

%   MP 11-10-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 20:02:41 $


% Initialize variables.
[out, id] = lasterr;

% Remove the trailing carriage returns from error message.
while out(end) == sprintf('\n')
    out = out(1:end-1);
end

if localfindstr('com.mathworks.toolbox.instrument.device.', out)
    out = strrep(out, sprintf('com.mathworks.toolbox.instrument.device.'), '');
end

if localfindstr('javahandle.', out)
	out = strrep(out, sprintf('javahandle.'), '');
end

if localfindstr('ICDevice', out)
   out = localstrrep(out, 'ICDevice', 'device objects');
   out = localstrrep(out, 'in the ''device objects'' class', 'for device objects');
end

lasterr(out, id);

% *******************************************************************
% findstr which handles possible japanese translation.
function result = localfindstr(str1, out)

result = findstr(sprintf(str1), out);

% *******************************************************************
% strrep which handles possible japanese translation.
function out = localstrrep(out, str1, str2)

out = strrep(out, sprintf(str1), sprintf(str2));

