function value = formatValueToSize(this, value, sizes, NoTypeCheck)
% FORMATVALUETOSIZE Formats the VALUE argument to be the same size as SIZES.
%
% SIZES   A row vector of dimension lengths
%
% VALUE - empty : reshape to SIZES only if at least one element of SIZES is zero.
%       - scalar: do scalar expansion.
%       - vector: reshape it to match SIZES.
%       - array : its size should match SIZES.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:06 $

if (nargin > 3) || ( isnumeric(value) && isreal(value) )
  if ~isempty(sizes)
    if isscalar(value)
      % Scalar
      value = value( ones(sizes) );
    elseif isvector(value) && length(value) == prod(sizes)
      % Vector with same number of elements.
      value = reshape(value, sizes);
    elseif prod(size(value)) == prod(sizes)
      % Array with same number of elements. Includes size(value) == sizes.
      value = reshape(value, sizes);
    else
      error('Cannot modify the property sizes.')
    end
  else
    error('Cannot set properties of uninitialized objects.');
  end
else
  error('Assigned value must be real double precision.');
end
