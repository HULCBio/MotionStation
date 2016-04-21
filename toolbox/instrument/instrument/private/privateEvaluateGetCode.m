function propertyValue = privateEvaluateGetCode(obj, propertyName, fcn, index, group)
%PRIVATEEVALUATEGETCODE helper function used by device objects.
%
%   PRIVATEEVALUATEGETCODE helper function used by the device objects.
%
%   PRIVATEEVALUATEGETCODE is used when a device object property is 
%   queried with the GET command if the property has a Type of MCode.
%   
%   This function should not be called directly by the user.
%  
 
%   MP 01-03-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:02:37 $

if isempty(fcn)
    return;
end

% If the property is a group object property, extract the group
% object and assign to obj.
if (index ~= -1)
    obj = get(obj, group);
    obj = obj(index);
end

% Extract the code from the fcn to be evaluated.
indexcr  = findstr(fcn, sprintf('\n'));
indexfcn = findstr(fcn, 'function');
index    = find(indexcr>indexfcn(1));
index    = indexcr(index(1));

fcnline = fcn(1:index(1));
code    = fcn(index(1)+1:end);

if isempty(code)
    return;
end

try
    eval(code);
catch
    localCleanupError;
    rethrow(lasterror);
end

if ~exist('propertyValue', 'var')
    error('instrument:get:opfailed', 'Output value was not assigned in the user specified M-Code. Use MIDEDIT to update the M-Code.');
end

% ---------------------------------------------------------
function localCleanupError

[msg, id] = lasterr;
msg = strrep(msg, ['Error using ==> privateEvaluateGetCode' sprintf('\n')], '');
lasterr(msg, id);