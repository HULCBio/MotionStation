function h = swftf(varargin)
%SWFTF  Sliding-window fast transversal least-squares adaptive filter.
%   H = ADAPTFILT.SWFTF(L,DELTA,BLOCKLEN,GAMMA,GSTATES,DSTATES,COEFFS,
%   STATES) constructs a sliding-window fast transversal least-squares
%   adaptive filter H.
%
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%   
%   DELTA is the soft-constrained initialization factor. This scalar
%   should be positive and sufficiently large to maintain stability.
%   DELTA defaults to 1.
%   
%   BLOCKLEN is the block length of the sliding window. This integer must
%   be at least as large as the filter length. BLOCKLEN defaults to L.
%   
%   GAMMA is the conversion factor. GAMMA defaults to the matrix [1 -1]
%   (soft-constrained initialization).
%   
%   GSTATES are the States of the Kalman gain updates. GSTATES defaults to
%   a zero vector of length (L + BLOCKLEN - 1).
%   
%   DSTATES is the desired signal States of the adaptive filter. DSTATES
%   defaults to a zero vector of length equal to (BLOCKLEN - 1).
%   
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%   
%   STATES vector of initial filter States. STATES defaults to a zero
%   vector of length equal to (L + BLOCKLEN - 2).
%   
%
%   EXAMPLE: System Identification of a 32-coefficient FIR filter 
%   (500 iterations).
%      x  = randn(1,500);     % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      n  = 0.1*randn(1,500); % Observation noise signal
%      d  = filter(b,1,x)+n;  % Desired signal
%      L  = 32;               % Adaptive filter length
%      del = 0.1;             % Soft-constrained initialization factor
%      N  = 64;               % block length
%      h = adaptfilt.swftf(L,del,N);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/FTF, ADAPTFILT/SWRLS, ADAPTFILT/AP, ADAPTFILT/APRU,
%   ADAPTFILT/FAP.

% Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/12 23:15:48 $

h = adaptfilt.swftf(varargin{:});

% [EOF]
