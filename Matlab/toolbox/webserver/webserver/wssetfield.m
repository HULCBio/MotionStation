function s = wssetfield(s, varargin)
%WSSETFIELD Add new field or append to existing field.
%   S = WSSETFIELD(S, NAME1, VALUE1, ...) sets the contents
%   of the field NAME1 to VALUE1 and returns the result in
%   the changed structure S.  A single value is stored as
%   a character array.  Items with multiple values are
%   stored in a cell array of strings.  Multiple calls
%   add values to an existing field.
%
%   Either use the GETFIELD function to retrieve the values
%   or reference the structure fields directly.
%
%   S = structure
%   NAME = field name in varargin(i)
%   VALUE = field value in varargin(i + 1)
%
%   See also GETFIELD.

%   Author(s): M. Greenstein, 01-06-98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.7 $   $Date: 2001/04/25 18:49:34 $

% Check arguments.
n = length(varargin);
% varargin must be even
if (mod(n, 2))
   error(['The number of variable arguments (varargin) is odd. ' ...
   	'They must be positive and even.']);
end 
% varargin must be positive
if (0 >= n)
   error(['The number of variable arguments (varargin) is zero. ' ...
      'They must be positive and even.']);
end 

% Loop through NAME/VALUE pairs.
for i = 1:2:n
   name = varargin{i}; % name is a character string
   value = varargin{i + 1}; % value is a character array
	if (isfield(s, name))
		% Convert char to a cell array, if it's a char.
		fld = cellstr(getfield(s, name));
      % Append value to fld.  Both are cell arrays of strings.
      s = setfield(s, name, [fld , {value}]);
	else
		% Create a new char string.
		s = setfield(s, name, value);
	end
end % for i

