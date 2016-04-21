function openvar(name, obj)
%OPENVAR Open a serial port object for graphical editing.
%
%   OPENVAR(NAME, OBJ) open a serial port object, OBJ, for graphical 
%   editing. NAME is the MATLAB variable name of OBJ.
%
%   See also SERIAL/SET, SERIAL/GET.
%

%   MP 04-17-01
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.3 $  $Date: 2004/01/16 20:04:35 $

if ~isa(obj, 'instrument')
    errordlg('OBJ must be an instrument object.', 'Invalid object', 'modal');
    return;
end

if ~isvalid(obj)
    errordlg('The instrument object is invalid.', 'Invalid object', 'modal');
    return;
end

try
    inspect(obj);
catch
    localFixError;
    errordlg(lasterr, 'Inspection error', 'modal');
end

% *******************************************************************
% Fix the error message.
function localFixError

% Initialize variables.
[out, id] = lasterr;

% Remove the trailing carriage returns from errmsg.
while out(end) == sprintf('\n')
   out = out(1:end-1);
end

lasterr(out, id);
