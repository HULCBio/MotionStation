function h = nlms(varargin)
%NLMS  Normalized LMS FIR adaptive filter.
%   H = ADAPTFILT.NLMS(L,STEPSIZE,LEAKAGE,OFFSET,COEFFS,STATES) constructs
%   an FIR LMS adaptive filter H.
%   
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%
%   STEPSIZE is the NLMS step size. It must be a scalar between zero and one.
%   Setting this step size value to one provides the fastest convergence.
%   STEPSIZE defaults to one.
%   
%   LEAKAGE is the NLMS leakage factor. It must be a scalar between 0 and 1.
%   If it is less than one, a "leaky NLMS" algorithm is implemented. LEAKAGE
%   defaults to 1 (no leakage).
%
%   OFFSET specifies an optional offset for the denominator of the Step
%   size normalization term. It must be a scalar greater or equal to zero.
%   A non-zero offset is useful to avoid a divide-by-near-zero if the input
%   signal amplitude becomes very small. OFFSET defaults to zero.
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
%      mu = 1;                % NLMS step size
%      Offset = 50;           % NLMS offset
%      h = adaptfilt.nlms(32,mu,1,Offset);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/LMS, ADAPTFILT/AP, ADAPTFILT/APRU, 
%   ADAPTFILT/RLS, ADAPTFILT/SWRLS.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/11/08 20:55:26 $

h = adaptfilt.nlms(varargin{:});

