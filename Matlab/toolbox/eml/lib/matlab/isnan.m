function b = isnan(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/isnan.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  $Date: 2004/04/14 23:58:21 $
% Comments:
% This is a temporary mesure to provide NaN tolerance in
%      eML run-time libraries


eml_assert(nargin > 0, 'error', 'Not enough input arguments.');

if(isreal(x))
  b = eml_isnan(x);
else
  b = eml_isnan(real(x)) | eml_isnan(imag(x));
end
