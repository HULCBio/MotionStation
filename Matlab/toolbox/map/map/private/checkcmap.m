function checkcmap(map, function_name, variable_name, argument_position)
%CHECKCMAP Check colormap for validity.
%   CHECKCMAP(MAP,FUNCTION_NAME,VARIABLE_NAME,VARIABLE_ARGUMENT_POSITION)
%   checks to see if MAP is a valid MATLAB colormap.  If it isn't,
%   CHECKCMAP, issues an error message using FUNCTION_NAME, VARIABLE_NAME,
%   and VARIABLE_ARGUMENT_POSITION.  FUNCTION_NAME is the name of the
%   user-level function that is checking the colormap, VARIABLE_NAME is
%   the name of the colormap variable in the documentation for that
%   function, and VARIABLE_ARGUMENT_POSITION is the position of the
%   colormap input argument to that function.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:26 $

try
   do_checkcmap(map, function_name, variable_name, argument_position)
catch
   rethrow(lasterror);
end

%----------------------------------------------------------------------
function do_checkcmap(map, function_name, variable_name, argument_position)

if ~isa(map,'double') || isempty(map) || ...
      (ndims(map) ~= 2) || (size(map,2) ~= 3) || ...
      issparse(map)
    msgId = sprintf('%s:%s:badMapMatrix',getcomp,function_name);
    msg = sprintf('%s %s %s %s %s, %s, %s\n %s %s', ...
          'Function', upper(function_name), ...
          'expected its', num2ordinal(argument_position), ...
          'input argument', upper(variable_name), ...
          'to be a valid colormap.', ...
          'Valid colormaps must be nonempty,', ...
          'double, 2-D matrices with 3 columns.');
    error(msgId, '%s', msg);
end

if any(map(:) < 0) || any(map(:) > 1)
    msgId = sprintf('%s:%s:badMapValues',getcomp,function_name);
    msg = sprintf('%s %s %s %s %s %s, %s\n %s', ...
          'Function',upper(function_name), ...
          'expected its', num2ordinal(argument_position), ...
          'input argument,', upper(variable_name), ...
          'to be a valid colormap.', ...
          'Valid colormaps cannot have values outside the range [0,1].');
    error(msgId, '%s', msg);
end
