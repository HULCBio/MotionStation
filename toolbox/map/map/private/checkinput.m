function checkinput(a, classes, attributes, function_name, variable_name, ...
                    argument_position)
%CHECKINPUT Check validity of array.
%
%   CHECKINPUT(A,CLASSES,ATTRIBUTES,FUNCTION_NAME,VARIABLE_NAME,
%   ARGUMENT_POSITION) checks the validity of the array A and issues a
%   formatted error message if it is invalid.
%
%   CLASSES is a cell array of strings containing the set of classes that A
%   is expected to belong.  For example, CLASSES could be {'logical',
%   'cell'} if A is required to be either a logical array, cell array, or
%   cell.  The string 'numeric' is interpreted as an abbreviation for the
%   classes uint8, uint16, uint32, int8, int16, int32, single, double.
%
%   ATTRIBUTES is a cell array of strings containing the set of attributes
%   that A must satisfy.  For example, if ATTRIBUTES is {'real' 'nonempty'
%   'finite'}, then A must be real and nonempty, and it must contain only
%   finite values.  The supported list of attributes includes:
%   
%       real             vector              row            column
%       scalar           twod                2d             nonsparse
%       nonempty         integer             nonnegative    positive
%       nonnan           finite              nonzero        even
%       odd
%
%   FUNCTION_NAME is a string containing the function name to be used in
%   the formatted error message.
%
%   VARIABLE_NAME is a string containing the documented variable name to be
%   used in the formatted error message.
%
%   ARGUMENT_POSITION is a positive integer indicating which input argument
%   is being checked; it is also used in the formatted error message.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:58:02 $

if ~iscell(classes)
  classes = {classes};
end
if ~iscell(attributes)
  attributes = {attributes};
end
checkinput_mex(a, classes, attributes, function_name, variable_name, ...
               argument_position);
