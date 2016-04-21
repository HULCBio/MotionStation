function [freq,xval,recfreq] = centfrq(wname,iter,in3)
%CENTFRQ Wavelet center frequency.
%   FREQ = CENTFRQ('wname') returns the center frequency in hertz
%   of the wavelet function 'wname' (see WAVEFUN).
%
%   For FREQ = CENTFRQ('wname',ITER), ITER is the number
%   of iterations used by the WAVEFUN function to compute
%   the wavelet.
%
%   [FREQ,XVAL,RECFREQ] = CENTFRQ('wname',ITER, 'plot')   
%   returns in addition the associated center frequency based 
%   approximation RECFREQ on the 2^ITER points grid XVAL 
%   and plots the wavelet function and RECFREQ.
%
%   See also SCAL2FRQ, WAVEFUN, WFILTERS. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Mar-98.
%   Last Revision: 25-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/03/15 22:39:48 $

% Check arguments.
if nargin==1, iter = 8; end

% Retrieve wavelet.
wname = deblankl(wname);
wtype = wavemngr('type',wname);
switch wtype
  case 1 , [nul,psi,xval] = wavefun(wname,iter);
  case 2 , [nul,psi,nul,nul,xval] = wavefun(wname,iter);
  case 3 , [nul,psi,xval] = wavefun(wname,iter);
  case 4 , [psi,xval] = wavefun(wname,iter);
  case 5 , [psi,xval] = wavefun(wname,iter);
end

T = max(xval)-min(xval);         % T is the size of the domain of psi.
n = length(psi);
psi = psi-mean(psi);             % psi is numerically centered.
psiFT = fft(psi);                % computation of the modulus
sp = (abs(psiFT));               % of the FT.

% Compute arg max of the modulus of the FT (center frequency).
[vmax,indmax] = max(sp);
if indmax > n/2
  indmax = n-indmax+2;           % indmax is always >= 2.
end	 
per = T/(indmax-1);              % period corresponding to the maximum.		         
freq = 1/per;                    % associated frequency.

if nargin > 2                    
  % plots and  computation of the associated reconstructed signal.
  psiFT(sp<vmax) = 0;
  recfreq = ifft(psiFT);
    if wtype <= 4
		plot(xval,psi,'-b',xval, ...
        0.75*max(abs(psi))*real(recfreq)/max(abs(recfreq)),'-r'),
        title(['Wavelet ',wname,' (blue) and Center frequency',...
        ' based approximation'])
		xlabel(['Period: ',num2str(per), '; Cent. Freq: ', num2str(freq)])
	else
		subplot(211)
        plot(xval,real(psi),'-b',xval, ...
        0.75*max(abs(psi))*real(recfreq)/max(abs(recfreq)),'-r')
        title(['Wavelet ',wname,' (blue) and Center frequency',...
        ' based approximation'])
        ylabel('Real parts')
		xlabel(['Period: ',num2str(per), '; Cent. Freq: ', num2str(freq)])  
             	
        subplot(212),plot(xval,imag(psi),'-b',xval, ...
        0.75*max(abs(psi))*imag(recfreq)/max(abs(recfreq)),'-r')
        ylabel('Imaginary parts')
		xlabel(['Period: ',num2str(per), '; Cent. Freq: ', num2str(freq)])       
	end
else
    recfreq = [];
end
