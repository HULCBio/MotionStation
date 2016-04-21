function h = ftf(varargin)
%FTF  Fast transversal least-squares adaptive filter.
%   H = ADAPTFILT.FTF(L,LAMBDA,DELTA,GAMMA,GSTATES,COEFFS,STATES)
%   constructs a fast transversal least-squares adaptive filter H.
%
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%   
%   LAMBDA is the RLS forgetting factor. This is a scalar and should lie in
%   the range (1-0.5/L, 1]. LAMBDA defaults to 1.
%   
%   DELTA is the soft-constrained initialization factor. This scalar should
%   be positive and sufficiently large to prevent an excessive number of
%   Kalman gain rescues. DELTA defaults to 1.
%   
%   GAMMA is the conversion factor. GAMMA defaults to 1 (soft-constrained
%   initialization).
%   
%   GSTATES are the States of the Kalman gain updates. GSTATES defaults to
%   a zero vector of length L.
%   
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%   
%   STATES vector of initial filter States. STATES defaults to a zero
%   vector of length (L-1).
%
%   
%   EXAMPLE: System Identification of a 32-coefficient FIR filter 
%   (500 iterations).
%      x  = randn(1,500);     % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      n  = 0.1*randn(1,500); % Observation noise signal
%      d  = filter(b,1,x)+n;  % Desired signal
%      N  = 31;               % Adaptive filter order
%      lam = 0.99;            % RLS forgetting factor
%      del = 0.1;             % Soft-constrained initialization factor
%      h = adaptfilt.ftf(32,lam,del);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/SWFTF, ADAPTFILT/RLS, ADAPTFILT/LSL.

% Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/12 23:15:44 $

h = adaptfilt.ftf(varargin{:});

% [EOF]
