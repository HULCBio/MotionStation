function H = qrdrls(varargin)
%QRDRLS  QR-decomposition-based RLS FIR adaptive filter.
%   H = ADAPTFILT.QRDRLS(L,LAMBDA,SQRTCOV,COEFFS,STATES) constructs an FIR
%   QR-decomposition-based RLS adaptive filter H.
%
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%   
%   LAMBDA is the RLS forgetting factor. This is a scalar and should lie in
%   the range (0, 1]. LAMBDA defaults to 1.
%   
%   SQRTCOV is the upper-triangular Cholesky (square root) factor of the
%   input covariance matrix.  This matrix should be initialized with a
%   positive definite upper triangular matrix.
%   
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%   
%   STATES vector of initial filter States. It must be a length L-1 vector.
%   STATES defaults to a length L-1 vector of all zeros.
%
%   EXAMPLE: System Identification of a 32-coefficient FIR filter 
%   (500 iterations).
%      x  = randn(1,500);     % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      n  = 0.1*randn(1,500); % Observation noise signal
%      d  = filter(b,1,x)+n;  % Desired signal
%      G0 = sqrt(.1)*eye(32); % Initial sqrt correlation matrix 
%      lam = 0.99;            % RLS forgetting factor
%      h = adaptfilt.qrdrls(32,lam,G0);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/RLS, ADAPTFILT/HRLS, ADAPTFILT/HSWRLS.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:44:55 $

H = adaptfilt.qrdrls(varargin{:});

% [EOF] 

    
