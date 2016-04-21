function y = boolean(x)
%BOOLEAN Creates a boolean vector.
%   This function is typically used in Simulink parameter dialogs, such as
%   the Constant block dialog.  This function generates a logical vector,
%   which is treated as a boolean value in Simulink.  Now that logical is a
%   MATLAB type, this function is essentially just an alias.
%
%   Y = BOOLEAN(X) Converts the vector X into a boolean vector.
%
%   Example: 
%      boolean([0 1 1]) returns [0 1 1]
%
%   See also LOGICAL.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.14 $

error(nargchk(1, 1, nargin));

if ~isreal(x)
  error('Complex number cannot be converted to boolean.');
end

y = logical(x);
