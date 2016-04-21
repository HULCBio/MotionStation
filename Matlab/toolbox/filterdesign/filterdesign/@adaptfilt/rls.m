function H = rls(varargin)
%RLS  Recursive least-squares FIR adaptive filter.
%   H = ADAPTFILT.RLS(L,LAMBDA,INVCOV,COEFFS,STATES) constructs an FIR
%   RLS adaptive filter H.
%
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%   
%   LAMBDA is the RLS forgetting factor. This is a scalar and should lie in
%   the range (0, 1]. LAMBDA defaults to 1.
%   
%   INVCOV is the inverse of the input signal covariance matrix.  This
%   matrix should be initialized to a positive definite matrix.
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
%      P0 = 10*eye(32); % Initial sqrt correlation matrix inverse
%      lam = 0.99;            % RLS forgetting factor
%      h = adaptfilt.rls(32,lam,P0);
%      [y,e] = filter(h,x,d);
%      subplot(2,1,1); plot(1:500,[d;y;e]);
%      title('System Identification of an FIR filter');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,1,2); stem([b.',h.Coefficients.']);
%      legend('Actual','Estimated'); 
%      xlabel('coefficient #'); ylabel('coefficient value'); grid on;
%
%   See also ADAPTFILT/HRLS, ADAPTFILT/QRDRLS, ADAPTFILT/HSWRLS.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:44:53 $

H = adaptfilt.rls(varargin{:});

% [EOF] 

