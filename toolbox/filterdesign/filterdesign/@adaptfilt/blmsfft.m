function h = blmsfft(varargin)
%BLMSFFT  FFT-based block LMS FIR adaptive filter.
%   H = ADAPTFILT.BLMSFFT(L,STEPSIZE,LEAKAGE,BLOCKLEN,COEFFS,STATES)
%   constructs an FIR Block LMS adaptive filter H.
%   
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%
%   STEPSIZE is the block LMS step size. It must be a nonnegative scalar.
%   The function MAXSTEP can be used to determine a reasonable range of
%   Step size values for the signals being processed.
%   STEPSIZE defaults to 0.
%
%   LEAKAGE is the block LMS leakage factor. It must be a scalar between
%   0 and 1. If it is less than one, the leaky block LMS algorithm is
%   implemented. LEAKAGE defaults to 1 (no leakage).
%   
%   BLOCKLEN is the block length used. It must be a positive integer such
%   that BLOCKLEN + length(COEFFS) is a power of two; otherwise, an
%   ADAPTFILT.BLMS algorithm is to be used. Larger block lengths result in
%   faster execution times with poor adaptation characteristics. BLOCKLEN
%   defaults to L.
%   
%   COEFFS is a vector of initial filter coefficients. It must be a length
%   L vector. COEFFS defaults to length L vector of all zeros.
%
%   STATES vector of initial filter states. It must be a length L vector.
%   STATES defaults to a length L vector of all zeros.
%
%   EXAMPLE: System Identification of a 32-coefficient FIR filter 
%   (512 iterations).
%      x  = randn(1,512);     % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      n  = 0.1*randn(1,512); % Observation noise signal
%      d  = filter(b,1,x)+n;  % Desired signal
%      mu = 0.008;            % Step size
%      N  = 16;               % Block Length
%      h = adaptfilt.blmsfft(32,mu,1,N);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d(1:500);y(1:500);e(1:500)]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/LMS, ADAPTFILT/BLMS, ADAPTFILT/FDAF.

%     [1] J.J. Shynk, "Frequency-domain and multirate adaptive 
%         filtering,"  IEEE Signal Processing Magazine, vol. 9,
%         no. 1, pp. 14-37, Jan. 1992.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/10/30 22:53:37 $

h = adaptfilt.blmsfft(varargin{:});
