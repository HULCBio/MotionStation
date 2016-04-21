function [xhat, yhat] = rceps(x)
%RCEPS Real cepstrum.
%   RCEPS(X) returns the real cepstrum of the real sequence X.
%
%   [XHAT, YHAT] = RCEPS(X) returns both the real cepstrum XHAT and 
%   a minimum phase reconstructed version YHAT of the input sequence.
%
%   See also CCEPS, HILBERT, FFT.

%   Author(s): L. Shure, 6-9-88
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 01:13:34 $

%   References: 
%     [1] A.V. Oppenheim and R.W. Schafer, Digital Signal 
%         Processing, Prentice-Hall, 1975.
%     [2] Programs for Digital Signal Processing, IEEE Press,
%         John Wiley & Sons, 1979, algorithm 7.2.

n = length(x);
xhat = real(ifft(log(abs(fft(x)))));
if nargout > 1
   odd = fix(rem(n,2));
   wn = [1; 2*ones((n+odd)/2-1,1) ; ones(1-rem(n,2),1); zeros((n+odd)/2-1,1)];
   yhat = zeros(size(x));
   yhat(:) = real(ifft(exp(fft(wn.*xhat(:)))));
end

