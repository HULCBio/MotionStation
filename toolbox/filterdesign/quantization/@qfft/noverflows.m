function n = noverflows(F)
%NOVERFLOWS  Return number of overflows from quantized FFT.
%   NOVERFLOWS(F) returns the total number of overflows from the input,
%   output, multiplicand, product and sum quantizers from the last
%   invocation of FFT, or IFFT on the quantized FFT object F.
%
%   Example:
%     w = warning('on');
%     F = qfft;
%     y = fft(F,randn(16,1));
%     noverflows(F)
%     warning(w);
%
%   See also QFFT, QFFT/FFT, QFFT/IFFT.

%   Thomas A. Bryan, 28 June 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/12 23:25:50 $

n = noverflows(F.inputformat) + noverflows(F.outputformat) + ...
    noverflows(F.multiplicandformat) + noverflows(F.sumformat);
