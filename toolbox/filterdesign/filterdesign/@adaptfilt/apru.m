function h = apru(varargin)
%APRU  Affine projection FIR adaptive filter with recursive matrix updates.
%   H = ADAPTFILT.APRU(L,STEP,PROJECTORD,OFFSET,COEFFS,STATES,CORRCOEFFS,
%   ERRSTATES,EPSSTATES) constructs an affine projection FIR adaptive
%   filter H using recursive matrix updates.
%
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%   
%   STEP is the affine projection Step size. This scalar should be a value
%   between zero and one. STEP = 1 provides the fastest convergence. STEP
%   defaults to 1.
%   
%   PROJECTORD is the projection order of the affine projection algorithm.
%   PROJECTORD defines the size of the input signal covariance matrix.
%   PROJECTORD defaults to 2.
%   
%   OFFSET is the Offset parameter for the input signal covariance matrix.
%   The covariance matrix should be initialized to a diagonal matrix whose
%   diagonal entries are equal to the OFFSET specified. OFFSET should be
%   positive. OFFSET defaults to 0.05.
%   
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%   
%   STATES is the vector of the adaptive filter States. STATES defaults to
%   a zero vector of length equal to (L + PROJECTORD - 2).
%   
%   CORRCOEFFS is a vector of initial correlation coefficients. CORRCOEFFS
%   defaults to a zero vector of length equal to (PROJECTORD - 1).
%   
%   ERRSTATES is the vector of the adaptive filter error States. ERRSTATES
%   defaults to a zero vector of length equal to (PROJECTORD - 1).
%   
%   EPSSTATES is a vector of epsilon values of the adaptive filter.
%   EPSSTATES defaults to a zero vector of length equal to (PROJECTORD - 1).
%
%
%   EXAMPLE: QPSK adaptive equalization using a 32-coefficient FIR filter 
%    (1000 iterations).
%      D  = 16;                             % Number of samples of delay
%      b  = exp(j*pi/4)*[-0.7 1];           % Numerator coefficients of channel
%      a  = [1 -0.7];                       % Denominator coefficients of channel
%      ntr= 1000;                           % Number of iterations
%      s  = sign(randn(1,ntr+D)) + j*sign(randn(1,ntr+D));  % Baseband QPSK signal
%      n  = 0.1*(randn(1,ntr+D) + j*randn(1,ntr+D));        % Noise signal
%      r  = filter(b,a,s)+n;                % Received signal
%      x  = r(1+D:ntr+D);                   % Input signal (received signal)
%      d  = s(1:ntr);                       % Desired signal (delayed QPSK signal)
%      mu = 0.1;                            % Step size
%      po = 4;                              % Projection order
%      del = 0.05;                          % Offset
%      h = adaptfilt.apru(32,mu,po,del);
%      [y,e] = filter(h,x,d);
%      subplot(2,2,1); plot(1:ntr,real([d;y;e]));
%      title('In-Phase Components');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,2,2); plot(1:ntr,imag([d;y;e]));
%      title('Quadrature Components');
%      legend('Desired','Output','Error');
%      xlabel('time index'); ylabel('signal value');
%      subplot(2,2,3); plot(x(ntr-100:ntr),'.'); axis([-3 3 -3 3]);
%      title('Received Signal Scatter Plot'); axis('square'); 
%      xlabel('Real[x]'); ylabel('Imag[x]'); grid on;
%      subplot(2,2,4); plot(y(ntr-100:ntr),'.'); axis([-3 3 -3 3]);
%      title('Equalized Signal Scatter Plot'); axis('square');
%      xlabel('Real[y]'); ylabel('Imag[y]'); grid on;
%
%   See also ADAPTFILT/AP, ADAPTFILT/NLMS, ADAPTFILT/BAP and ADAPTFILT/RLS.

% Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/12 23:15:40 $

h = adaptfilt.apru(varargin{:});

% [EOF]
