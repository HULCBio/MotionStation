function checkmap(map, function_name, variable_name, argument_position)
%CHECKMAP Check colormap for validity.
%   CHECKMAP(MAP,FUNCTION_NAME,VARIABLE_NAME,VARIABLE_ARGUMENT_POSITION)
%   checks to see if MAP is a valid MATLAB colormap.  If it isn't,
%   CHECKMAP, issues an error message using FUNCTION_NAME, VARIABLE_NAME,
%   and VARIABLE_ARGUMENT_POSITION.  FUNCTION_NAME is the name of the
%   user-level function that is checking the colormap, VARIABLE_NAME is
%   the name of the colormap variable in the documentation for that
%   function, and VARIABLE_ARGUMENT_POSITION is the position of the
%   colormap input argument to that function.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/01/26 05:58:00 $

if ~isa(map,'double') || isempty(map) || ...
      (ndims(map) ~= 2) || (size(map,2) ~= 3) || ...
      issparse(map)
    msgId = sprintf('Images:%s:badMapMatrix',function_name);
    error(msgId,'Function %s expected its %s input argument, %s, to be a valid colormap.\nValid colormaps must be nonempty, double, 2-D matrices with 3 columns.', ...
          upper(function_name), num2ordinal(argument_position), variable_name);
end

if any(map(:) < 0) || any(map(:) > 1)
    msgId = sprintf('Images:%s:badMapValues',function_name);
    error(msgId,'Function %s expected its %s input argument, %s, to be a valid colormap.\nValid colormaps cannot have values outside the range [0,1].', ...
          upper(function_name), num2ordinal(argument_position), variable_name);
end
