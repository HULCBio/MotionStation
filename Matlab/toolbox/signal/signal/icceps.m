function x = icceps(xhat,nd)
%ICCEPS Inverse complex cepstrum.
%   ICCEPS(xhat,nd) returns the inverse complex cepstrum of the 
%   (assumed real) sequence xhat, removing nd samples of delay.
%   If xhat was obtained with CCEPS(x), then the amount of delay
%   that was added to x was the element of 
%   round(unwrap(angle(fft(x)))/pi) corresponding to pi radians.
%
%   See also CCEPS, RCEPS, HILBERT, and FFT.

%   Author(s): T. Krauss, 2/22/96
%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.6 $

%   References: 
%     [1] A.V. Oppenheim and R.W. Schafer, Digital Signal 
%         Processing, Prentice-Hall, 1975.

if nargin<2
    nd = 0;
end
logh = fft(xhat);
h = exp(real(logh)+j*rcwrap(imag(logh),nd));
x = real(ifft(h));

function x = rcwrap(y,nd)
%RCWRAP Phase wrap utility used by ICCEPS.
%   RCWRAP(X,nd) adds phase corresponding to integer lag.  

n = length(y);
nh = fix((n+1)/2);
x = y(:).' + pi*nd*(0:(n-1))/nh;
if size(y,2)==1
    x = x.';
end

