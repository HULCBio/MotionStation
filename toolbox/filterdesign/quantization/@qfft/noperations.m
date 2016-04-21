function n = noperations(F)
%NOPERATIONS  Number of product and sum operations.
%   NOPERATIONS(F) returns the total number of quantization operations
%   from the product and sum quantizers from the last invocation of FFT,
%   or IFFT on the quantized FFT object F.
%
%   Example:
%     w = warning('on');
%     F = qfft;
%     y = fft(F,randn(16,1));
%     noperations(F)
%     warning(w);
%
%   See also QFFT, QFFT/FFT, QFFT/IFFT.

%   Thomas A. Bryan, 10 December 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/12 23:25:49 $

n = noperations(F.productformat) + noperations(F.sumformat);
