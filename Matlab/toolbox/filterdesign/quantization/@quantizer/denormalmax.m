function x = denormalmax(q)
%DENORMALMAX  Largest denormalized quantized number.
%   X = DENORMALMAX(Q) is the largest positive denormalized
%   quantized number where Q is a QUANTIZER object.  Anything
%   larger is a normalized number.  Denormalized numbers are only
%   applicable to floating-point.  If Q represents a fixed-point
%   number, then DENORMALMAX(Q) = EPS(Q).
%
%   Example:
%     q = quantizer('float',[6 3]);
%     denormalmax(q)
%   returns 0.1875 = 3/16
%
%   See also QUANTIZER, QUANTIZER/DENORMALMIN, QUANTIZER/EPS.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:35:24 $

switch q.mode
  case {'fixed','ufixed'}
    x = eps(q);
  case {'float', 'double', 'single'}
    x = realmin(q)-denormalmin(q);
end
