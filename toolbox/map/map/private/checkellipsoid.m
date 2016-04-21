function ellipsoid = checkellipsoid(ellipsoid,...
    function_name, variable_name, argument_position)
%CHECKELLIPSOID Check validity of ellipsoid vector.
%   ELLIPSOID = CHECKELLIPSOID(ELLIPSOID, FUNCTION_NAME, VARIABLE_NAME,
%   ARGUMENT_POSITION) ensures that the ellipsoid vector is a 1-by-2 vector
%   of the form form [SemimajorAxis  Eccentricity]) with 0 <= Eccentricity
%   < 1.  If a scalar is supplied, it is interpreted to be a semimajor axis
%   and a zero eccentricity is appended.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:58:01 $

try
    % Ensure a real, non-negative double
    if ~isa(ellipsoid,'double') || ~isreal(ellipsoid) || any(ellipsoid < 0)
        eid = sprintf('%s:%s:invalidEllipsoid',getcomp,function_name);
        msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
                       upper(function_name), num2ordinal(argument_position), ...
                       variable_name);
        msg2 = sprintf('to be a real-valued, non-negative double.');
        throwerr(eid, '%s\n%s', msg1, msg2);
    end

    % Append zero eccentricity if needed
    if numel(ellipsoid) == 1
        ellipsoid(1,2) = 0;
    end

    % Ensure a 1-by-2 vector
    if (numel(ellipsoid) ~= 2 || size(ellipsoid,1) > 1)
        eid = sprintf('%s:%s:ellipsoidNot1By2',getcomp,function_name);
        msg1 = sprintf('Function %s expected its %s input argument, %s,', ...
                       upper(function_name), num2ordinal(argument_position), ...
                       variable_name);
        msg2 = sprintf('to be 1-by-1 or 1-by-2.');
        throwerr(eid, '%s\n%s', msg1, msg2);
    end

    % Ensure eccentricity in the range [0 1)
    if (ellipsoid(2) >= 1)
        eid = sprintf('%s:%s:invalidEccentricity',getcomp,function_name);
        msg1 = sprintf('Function %s expected the 2nd element (the eccentricity) of %s', ...
                       upper(function_name), variable_name);
        msg2 = sprintf('to be in the range [0 1).');
        throwerr(eid, '%s\n%s', msg1, msg2);
    end
catch
    rethrow(lasterror);
end
