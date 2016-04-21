function W = twiddles(F)
%TWIDDLES  Return twiddle factors associated with quantized FFT object.
%   W = TWIDDLES(F) returns the quantized FFT twiddle factors associated with
%   quantized FFT object F.
%
%   Example:
%     F = qfft;
%     w = twiddles(F)
%
%   See also QFFT.

%   Thomas A. Bryan, 19 April 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.16 $  $Date: 2002/04/14 15:27:13 $

error(lengthcheck(F));

switch radix(F)
  case 2
    W = radix2twiddles(length(F));
  case 4
    W = radix4twiddles(length(F));
end

q = quantizer(F,'coefficient');
W = quantize(q,W);
