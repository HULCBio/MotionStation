function checkrefvec(refvec, function_name, variable_name, argument_position)
%CHECKREFVEC Check validity of referencing vector.
%
%   CHECKREFVEC(REFVEC, FUNCTION_NAME, VARIABLE_NAME, ARGUMENT_POSITION)
%   ensures that the referencing vector is a 1-by-3  vector of real-valued
%   doubles and that the first element is positive.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/13 02:52:29 $

try
    do_checkrefvec(...
        getcomp, refvec, function_name, variable_name, argument_position);
catch
    rethrow(lasterror);
end

%----------------------------------------------------------------------

function do_checkrefvec( ...
        component, refvec, function_name, variable_name, argument_position)

checkinput(refvec, {'double'}, {'real','finite', 'nonempty','vector'}, ...
           function_name, variable_name,argument_position);

% REFVEC must have three elements.
if numel(refvec) ~= 3
    eid = sprintf('%s:%s:refvecNumelNot3',component,function_name);
    msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
                   upper(function_name), num2ordinal(argument_position), ...
                   variable_name);
    msg2 = sprintf('to have 3 elements.');
    throwerr(eid, '%s\n%s', msg1, msg2);
end

% Make sure that the first element of REFVEC (cells/angleunit) is nonzero.
if refvec(1) <= 0
    eid = sprintf('%s:%s:cellsPerAngleUnitNotPositive',component,function_name);
    msg1 = sprintf('Function %s expected the first element of %s', ...
                   upper(function_name), variable_name);
    msg2 = sprintf('to be positive.');
    throwerr(eid, '%s\n%s', msg1, msg2);
end
