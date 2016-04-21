function [x,s] = fft(F,x,dim)
%FFT  Quantized Fast Fourier Transform.
%   Y = FFT(F,X) is the quantized Fast Fourier Transform (FFT) of X.  The
%   parameters of the quantized FFT are specified in QFFT object F.  If the
%   length of X is less than F.length, then X is padded with zeros.  If the
%   length of X is greater than F.length, then X is truncated.  For matrices,
%   the FFT operation is applied to each column.  For N-D arrays, the FFT
%   operation operates on the first non-singleton dimension.
%
%   Y = FFT(F,X,DIM) applies the quantized FFT operation across the dimension
%   DIM.
%
%   [Y, S] = FFT(F,X,...) also returns a MATLAB structure S containing
%   quantization information.  See QREPORT for details.
%
%   Example:
%     w = warning('on');
%     F = qfft('length',4,'mode','fixed');
%     Y = fft(F,eye(4))
%     warning(w);
%
%   See also QFFT, QFFT/IFFT, QREPORT.

%   Thomas A. Bryan, 28 June 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/12 23:25:47 $

if nargin<3
  dim = [];
end
error(lengthcheck(F))
x = privfft('fft',F,x,dim);

if nargout>1
  s=qreport(F);
end
