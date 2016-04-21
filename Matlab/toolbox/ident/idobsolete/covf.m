function R=covf(z,M,maxsize)
%COVF  Computes the covariance function estimate for a data matrix.
%   R = COVF(Z,M)
%
%   Z : An   N x nz data matrix, typically Z=[y u]
%
%   M: The maximum delay - 1, for which the covariance function is estimated
%   R: The covariance function of Z, returned so that the entry
%   R((i+(j-1)*nz,k+1) is  the estimate of E Zi(t) * Zj(t+k)
%   The size of R is thus nz^2 x M.
%   For complex data z, RESHAPE(R(:,k+1),nz,nz) = E z(t)*z'(t+k)
%   (z' is complex conjugate, transpose)
%
%   For nz<3, an FFT algorithm is used, memory size permitting.
%   For nz>2, straightforward summation is used (in COVF2)
%
%   The memory trade-off is affected by
%   R = COVF(Z,M,maxsize)
%   See also AUXVAR  for how to use this option.

%   L. Ljung 10-1-86,11-11-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:37 $

if nargin<2
        disp('Usage: R = covf(z,M);')
        return
end
[Ncap,nz]=size(z);
maxsdef=idmsize(Ncap);
if nargin<3,maxsize=maxsdef;end
if isempty(maxsize),maxsize=maxsdef;end
if nz>Ncap, error('The data should be arranged in columns'),return,end

if nz>2  |  Ncap>maxsize/8 | any(any(imag(z)~=0)) , R=covf2(z,M); return,end

nfft = 2.^ceil(log(2*Ncap)/log(2));
Ycap=fft(([z(:,1)' zeros(1,Ncap)]),nfft);
if nz==2, Ucap=fft(([z(:,2)'  zeros(1,Ncap)]),nfft);
           YUcap=Ycap.*conj(Ucap);
           UAcap=abs(Ucap).^2;
           clear Ucap
end
YAcap=abs(Ycap).^2;
clear Ycap
RYcap=fft(YAcap,nfft);
n=length(RYcap);
R=real(RYcap(1:M))/Ncap/n;
clear RYcap
if nz==1,return,end
         RUcap=fft(UAcap,nfft);
         ru=real(RUcap(1:M))/Ncap/n;
         clear RUcap
         RYUcap=fft(YUcap,nfft);
         ryu=real(RYUcap(1:M))/Ncap/n;
         ruy=real(RYUcap(n:-1:n-M+2))/Ncap/n;
         clear RYUcap
R = [R;[ryu(1) ruy];ryu;ru];
