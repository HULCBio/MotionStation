%DLMS  Delayed LMS FIR adaptive filter.
%   H = ADAPTFILT.DLMS(L,STEPSIZE,LEAKAGE,DELAY,ERRSTATES,COEFFS,STATES)
%   constructs an FIR delayed LMS adaptive filter H.
%   
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%
%   STEPSIZE is the delayed LMS step size. It must be a nonnegative scalar.
%   STEPSIZE defaults to zero.
%   
%   LEAKAGE is the delayed LMS leakage factor. It must be a scalar between
%   0 and 1. If it is less than one, a leaky version of DLMS is
%   implemented. LEAKAGE defaults to 1 (no leakage).
%
%   DELAY is the update delay.  This scalar should be a positive integer.
%   DELAY defaults to 1.
%
%   ERRSTATES is a vector of error states of the adaptive filter. It must
%   have a length equal to the update delay. ERRSTATES defaults to a vector
%   of all zeros of appropriate length.
%
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%
%   STATES vector of initial filter states. It must be a vector of length
%   L+DELAY-1. STATES defaults to a vector of all zeros of appropriate
%   length.
%
%   EXAMPLE: System Identification of a 32-coefficient FIR filter 
%   (500 iterations).
%      x  = randn(1,500);     % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      n  = 0.1*randn(1,500); % Observation noise signal
%      d  = filter(b,1,x)+n;  % Desired signal
%      mu = 0.008;            % LMS Step size.
%      delay = 1;             % Update delay
%      h = adaptfilt.dlms(32,mu,1,delay);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/LMS, ADAPTFILT/ADJLMS, ADAPTFILT/FILTXLMS.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/29 22:22:56 $

% Help for the ADAPTFILT.DLMS pcoded constructor.

% [EOF]

