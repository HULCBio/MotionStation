function checkrefmat(refmat, function_name, variable_name, argument_position)
%CHECKREFMAT Check validity of referencing matrix.
%
%   CHECKREFMAT(REFMAT, FUNCTION_NAME, VARIABLE_NAME, ARGUMENT_POSITION)
%   ensures that the referencing matrix is a 3-by-2 matrix of real-valued
%   finite doubles. 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:28 $

try
    do_checkrefmat( ...
        getcomp, refmat, function_name, variable_name, argument_position);
catch
    rethrow(lasterror);
end

%----------------------------------------------------------------------

function do_checkrefmat( ...
        component, refmat, function_name, variable_name, argument_position)

checkinput(refmat,{'double'},{'real','2d','finite','nonempty'}, ...
          function_name,variable_name,argument_position);

% REFMAT must have three elements.
if ~all(size(refmat) == [3,2])
    eid = sprintf('%s:%s:refmatNot3by2',component,function_name);
    msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
                   upper(function_name), num2ordinal(argument_position), ...
                   variable_name);
    msg2 = sprintf('to have size [3,2].');
    throwerr(eid, '%s\n%s', msg1, msg2);
end
