function b = isinf(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/isinf.m$
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/14 23:58:20 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');

if(isreal(x))
  b = eml_isinf(x);
else
  b = eml_isinf(real(x)) | eml_isinf(imag(x));
end
