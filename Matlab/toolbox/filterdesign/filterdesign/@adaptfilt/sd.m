function h = sd(varargin)
%SD  Sign-data FIR adaptive filter.
%   H = ADAPTFILT.SD(L,STEPSIZE,LEAKAGE,COEFFS,STATES) constructs an FIR
%   sign-data adaptive filter H.
%   
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%
%   STEPSIZE is the sign-data step size. It must be a nonnegative scalar.
%   STEPSIZE defaults to 0.
%
%   LEAKAGE is the sign-data leakage parameter. It must be a scalar between
%   0 and 1. If it is less than one, a leaky version of the algorithm is
%   implemented. LEAKAGE defaults to 1 (no leakage).
%
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%
%   STATES vector of initial filter states. It must be a length L-1 vector.
%   STATES defaults to a length L-1 vector of all zeros.
%
%   EXAMPLE: Adaptive line enhancement using a 32-coefficient FIR filter 
%    (5000 iterations).
%      D  = 1;                              % Number of samples of delay
%      ntr= 5000;                           % Number of iterations
%      v  = sin(2*pi*0.05*[1:ntr+D]);       % Sinusoidal signal
%      n  = randn(1,ntr+D);                 % Noise signal
%      x  = v(1:ntr)+n(1:ntr);              % Input signal (delayed desired signal)
%      d  = v(1+D:ntr+D)+n(1+D:ntr+D);      % Desired signal
%      mu = 0.0001;                         % Sign-data step size.
%      h = adaptfilt.sd(32,mu);
%      [y,e] = filter(h,x,d); 
%      subplot(2,1,1); plot(1:ntr,[d;y;v(1+D:ntr+D)]);
%      axis([ntr-100 ntr -3 3]);
%      title('Adaptive line enhancement of a noisy sinusoidal signal');
%      legend('Observed','Enhanced','Original');
%      xlabel('time index'); ylabel('signal value');
%      [Pxx,om] = pwelch(x(ntr-1000:ntr));
%      Pyy = pwelch(y(ntr-1000:ntr));  
%      subplot(2,1,2); plot(om/pi,10*log10([Pxx/max(Pxx),Pyy/max(Pyy)]));
%      axis([0 1 -60 20]);
%      legend('Observed','Enhanced'); 
%      xlabel('Normalized Frequency (\times \pi rad/sample)');
%      ylabel('Power Spectral Density'); grid on;
%
%   See also ADAPTFILT/SE, ADAPTFILT/SS, ADAPTFILT/LMS.


%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/10/30 22:53:37 $

h = adaptfilt.sd(varargin{:});
