function [Pxy, Pxyc, f] = csd(varargin)
%CSD Cross Spectral Density estimate.
%   CSD has been replaced by CPSD.  CSD still works but may be removed in
%   the future. Use CPSD instead.
%
%   CPSD does not support detrending.  Please use the DETREND function if
%   you need to detrend your signal.  Type "help detrend" for details.
%
%   See also PWELCH, TFESTIMATE, MSCOHERE,
%   ETFE, SPA, and ARX in the Identification Toolbox.

%   Author(s): T. Krauss, 3-30-93
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/13 00:17:44 $

error(nargchk(2,8,nargin))
x = varargin{1};
y = varargin{2};
[msg,nfft,Fs,window,noverlap,p,dflag]=psdchk(varargin(3:end),x,y);
error(msg)
    
% compute CSD
window = window(:);
n = length(x);		% Number of data points
nwind = length(window); % length of window
if n < nwind    % zero-pad x , y if length is less than the window length
    x(nwind)=0;
    y(nwind)=0;  
    n=nwind;
end
x = x(:);		% Make sure x is a column vector
y = y(:);		% Make sure y is a column vector
k = fix((n-noverlap)/(nwind-noverlap));	% Number of windows
					% (k = fix(n/nwind) for noverlap=0)
index = 1:nwind;
KMU = k*norm(window)^2;	% Normalizing scale factor ==> asymptotically unbiased
% KMU = k*sum(window)^2;% alt. Nrmlzng scale factor ==> peaks are about right

Spec = zeros(nfft,1);
for i=1:k
    if strcmp(dflag,'none')
        xw = window.*x(index);
        yw = window.*y(index);
    elseif strcmp(dflag,'linear')
        xw = window.*detrend(x(index));
        yw = window.*detrend(y(index));
    else
        xw = window.*detrend(x(index),0);
        yw = window.*detrend(y(index),0);
    end
    index = index + (nwind - noverlap);
    Xx = fft(xw,nfft);
    Yy = fft(yw,nfft);
    Xy2 = Yy.*conj(Xx);
    Spec = Spec + Xy2;
end

% Select first half
if ~any(any(imag([x y])~=0)),   % if x and y are not complex
    if rem(nfft,2),    % nfft odd
        select = [1:(nfft+1)/2];
    else
        select = [1:nfft/2+1];   % include DC AND Nyquist
    end
    Spec = Spec(select);
else
    select = 1:nfft;
end
freq_vector = (select - 1)'*Fs/nfft;

% find confidence interval if needed
if (nargout == 3)|((nargout == 0)&~isempty(p)),
    if isempty(p),
        p = .95;    % default
    end
    confid = Spec*chi2conf(p,k)/KMU;
end

Spec = Spec*(1/KMU);

% set up output parameters
if (nargout == 3),
   Pxy = Spec;
   Pxyc = confid;
   f = freq_vector;
elseif (nargout == 2),
   Pxy = Spec;
   Pxyc = freq_vector;
elseif (nargout == 1),
   Pxy = Spec;
elseif (nargout == 0),
   if ~isempty(p),
       P = [Spec confid];
   else
       P = Spec;
   end
   newplot;
   plot(freq_vector,10*log10(abs(P))), grid on
   xlabel('Frequency'), ylabel('Cross Spectrum Magnitude (dB)');
end
