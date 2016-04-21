function checkstruct(S, function_name, variable_name, argument_position)
%CHECKSTRUCT Verifies that the input is a structure. 
%   CHECKSTRUCT(S, FUNCTION_NAME, VARIABLE_NAME, ARGUMENT_POSITION)
%   verifies that S is a structure.  If it isn't, CHECKSTRUCT issues an
%   error message using FUNCTION_NAME, VARIABLE_NAME, and
%   ARGUMENT_POSITION.  FUNCTION_NAME is the name of the user-level
%   function that is checking the struct, VARIABLE_NAME is the name of the
%   struct variable in the documentation for that function, and
%   ARGUMENT_POSITION is the position of the input argument to that
%   function.

%   See also GEOATTRIBNAMES, GEOATTRIBSTRUCT, UPDATEGEOSTRUCT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:30 $

% Verify that the input is a structure
if ~isstruct(S)
    eid = sprintf('%s:%s:invalidGeoStruct', getcomp, function_name);
    msg = sprintf('%s %s %s %s %s, %s, %s', ...
              'Function', upper(function_name), ...
              'expected its', num2ordinal(argument_position), ...
              'input argument', upper(variable_name), ...
              'to be a structure.');
    error(eid, '%s', msg);

end
