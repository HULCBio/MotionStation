function h = lms(varargin)
%LMS  Least-mean-square FIR adaptive filter.
%   H = ADAPTFILT.LMS(L,STEPSIZE,LEAKAGE,COEFFS,STATES) constructs an FIR
%   LMS adaptive filter H.
%   
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%
%   STEPSIZE is the LMS step size. It must be a nonnegative scalar. You can
%   use the function MAXSTEP to determine a reasonable range of step size
%   values for the signals being processed. STEPSIZE defaults to 0.
%
%   LEAKAGE is the LMS leakage factor. It must be a scalar between 0 and 1.
%   If it is less than one, the leaky LMS algorithm is implemented. LEAKAGE
%   defaults to 1 (no leakage).
%
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%
%   STATES vector of initial filter states. It must be a length L-1 vector.
%   STATES defaults to a length L-1 vector of all zeros.
%
%   EXAMPLE: System Identification of a 32-coefficient FIR filter 
%   (500 iterations).
%      x  = randn(1,500);     % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      n  = 0.1*randn(1,500); % Observation noise signal
%      d  = filter(b,1,x)+n;  % Desired signal
%      mu = 0.008;            % LMS step size
%      h = adaptfilt.lms(32,mu);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/NLMS, ADAPTFILT/BLMS, ADAPTFILT/DLMS,
%   ADAPTFILT/BLMSFFT, ADAPTFILT/TDAFDFT, ADAPTFILT/SE, ADAPTFILT/SD.


%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/10/30 22:53:37 $

h = adaptfilt.lms(varargin{:});
