function x = denormalmin(q)
%DENORMALMIN  Smallest denormalized quantized number.
%   X = DENORMALMIN(Q) is the smallest positive denormalized quantized
%   number where Q is a QUANTIZER object.  Anything smaller underflows
%   to zero with respect to the quantizer Q.  Denormalized numbers are
%   only applicable to floating-point.  If Q represents a fixed-point
%   number, then DENORMALMIN(Q) = EPS(Q).
%
%   Example:
%     q = quantizer('float',[6 3]);
%     denormalmin(q)
%   returns 0.0625 = 1/16
%
%   See also QUANTIZER, QUANTIZER/DENORMALMAX, QUANTIZER/EPS.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:35:21 $

switch q.mode
  case {'fixed','ufixed'}
    x = eps(q);
  case {'float','double','single'}
    x = realmin(q)*2^-fractionlength(q);
end
