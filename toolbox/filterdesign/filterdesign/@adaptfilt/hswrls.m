function H = hswrls(varargin)
%HSWRLS  Householder sliding-window RLS FIR adaptive filter.
%   H = ADAPTFILT.HSWRLS(L, LAMBDA, SQRTINVCOV, SWBLOCKLEN, DSTATES,
%   COEFFS, STATES) constructs an FIR householder sliding-window RLS
%   adaptive filter H.
%
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%   
%   LAMBDA is the RLS forgetting factor. This is a scalar and should lie in
%   the range (0, 1]. LAMBDA defaults to 1 (rectangular window).
%   
%   SQRTINVCOV is the square-root of the inverse of the sliding-window
%   input signal covariance matrix.  This is a square matrix and should
%   be full-ranked.
%   
%   SWBLOCKLEN is the block length of the sliding window. This integer must
%   be at least as large as the filter length. SWBLOCKLEN defaults to 16.
%   
%   DSTATES is the desired signal States of the adaptive filter. DSTATES
%   defaults to a zero vector of length equal to (SWBLOCKLEN - 1).
%   
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%   
%   STATES vector of initial filter States. STATES defaults to a zero
%   vector of length equal to (L + SWBLOCKLEN - 2).
%   
%   EXAMPLE: System Identification of a 32-coefficient FIR filter 
%   (500 iterations).
%      x  = randn(1,500);     % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      n  = 0.1*randn(1,500); % Observation noise signal
%      d  = filter(b,1,x)+n;  % Desired signal
%      G0 = sqrt(10)*eye(32); % Initial sqrt correlation matrix inverse
%      lam = 0.99;            % RLS forgetting factor
%      N  = 64;               % block length
%      h = adaptfilt.hswrls(32,lam,G0,N);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/RLS, ADAPTFILT/QRDRLS, ADAPTFILT/HRLS.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:44:54 $

H = adaptfilt.hswrls(varargin{:});

% [EOF] 
