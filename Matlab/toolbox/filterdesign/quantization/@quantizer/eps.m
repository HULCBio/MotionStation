function p = eps(q)
%EPS  Quantized relative accuracy.
%   EPS(Q) returns the quantization level of QUANTIZER object Q,
%   or the distance from 1.0 to the next largest floating-point
%   number if Q is a floating-point QUANTIZER object.
%
%   For both fixed-point and floating-point quantizers Q,
%   EPS(Q)=2^-FRACTIONLENGTH(Q).
%
%   Example:
%     q = quantizer('float',[6 3]);
%     eps(q)
%   returns 0.25.
%
%   See also QUANTIZER, QUANTIZER/QUANTIZE.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:33:37 $

fmt = get(q,'format');
w = fmt(1);
switch q.mode
  case {'fixed','ufixed'}
    f = fmt(2);
  case {'double','float','single'}
    e = fmt(2);
    f = w-e-1;
end
p = pow2(-f);
