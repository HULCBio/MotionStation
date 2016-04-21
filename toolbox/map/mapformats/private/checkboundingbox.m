function checkboundingbox(...
               bbox, function_name, variable_name, argument_position)
%CHECKBOUNDINGBOX Check validity of bounding box array.
%   CHECKBOUNDINGBOX(...
%              BBOX, FUNCTION_NAME, VARIABLE_NAME, ARGUMENT_POSITION)
%   ensures that the bounding box array is a 2-by-2 array of double with
%   real, finite values, and that in each column the second value always
%   exceeds the first.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:25 $

try
    do_checkboundingbox(getcomp, bbox,...
                    function_name, variable_name, argument_position);
catch
    rethrow(lasterror);
end

%----------------------------------------------------------------------

function do_checkboundingbox(component, bbox,...
    function_name, variable_name, argument_position)

checkinput(bbox, {'double'},{'real','nonnan'},...
           function_name,variable_name,argument_position);
        
if size(bbox,1) ~= 2 || size(bbox,2) ~= 2 || ndims(bbox) ~= 2
    eid = sprintf('%s:%s:invalidBBoxSize',component,function_name);
    msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
                   upper(function_name), num2ordinal(argument_position), ...
                   variable_name);
    msg2 = sprintf('to be a 2-by-2 array.');
    throwerr(eid, '%s\n%s', msg1, msg2);
end

if ~all(bbox(1,:) <= bbox(2,:))
    eid = sprintf('%s:%s:invalidBBoxOrder',component,function_name);
    msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
                   upper(function_name), num2ordinal(argument_position), ...
                   variable_name);
    msg2 = sprintf('to have element (2,k) greater than or equal to element (1,k).');
    throwerr(eid, '%s\n%s', msg1, msg2);
end
