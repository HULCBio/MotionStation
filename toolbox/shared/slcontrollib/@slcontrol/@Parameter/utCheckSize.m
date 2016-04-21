function value = utCheckSize(this, value, NoTypeCheck)
% Formats the VALUE argument to be the same size as SIZES.
% 
% If VALUE is a scalar, then do scalar expansion.
% If VALUE is an array, then its size should match SIZES, otherwise BADVALUE
% flag will be set to TRUE, and the original VALUE will be returned.

% Author(s): Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:57 $
if nargin>2 || (isnumeric(value) && isreal(value))
   sizes = this.Dimensions;
   if isempty(sizes)
      error('Cannot set properties of uninitialized parameter.');
   else
      % Make row vector by default
      if isscalar(value)
         value = value( ones(sizes) );
      elseif isvector(value) && length(value)==prod(sizes)
         value = reshape(value,sizes);
      elseif ~isequal( size(value), sizes );
         error('Cannot modify the parameter sizes.')
      end
   end
else
   error('Assigned value must be real double precision.');
end
