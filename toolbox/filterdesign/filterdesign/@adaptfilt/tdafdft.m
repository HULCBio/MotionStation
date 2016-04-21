function H = tdafdft(varargin)
%TDAFDFT  Transform-domain adaptive filter using discrete Fourier transform.
%   H = ADAPTFILT.TDAFDFT(L,STEP,LEAKAGE,OFFSET,DELTA,LAMBDA,COEFFS,
%   STATES) constructs a transform-domain adaptive filter H using
%   discrete Fourier transform.  
%
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%   
%   STEP is the Step size of the adaptive filter. This is a scalar and
%   should lie in the range (0,1]. STEP defaults to 0.
%   
%   LEAKAGE is the Leakage parameter of the adaptive filter. If this
%   parameter is set to a value between zero and one, a leaky TDAFDFT
%   algorithm is implemented. LEAKAGE defaults to 1 (i.e., no Leakage).
%   
%   OFFSET is the Offset for the normalization terms in the coefficient
%   updates. This can be used to avoid divide by zeros (or by very small
%   numbers) if any of the FFT input signal powers become very small.
%   OFFSET defaults to zero.
%   
%   DELTA is the initial common value of all of the transform domain
%   powers. Its initial value should be positive. DELTA defaults to 5.
%   
%   LAMBDA specifies the averaging  factor used to compute the
%   exponentially-windowed estimates of the powers in the transformed
%   signal bins for the coefficient updates. LAMBDA should lie in the
%   range (0,1). LAMBDA defaults to (1 - STEP).
%   
%   COEFFS are the initial time-domain coefficients of the adaptive filter.
%   It should be a length L vector. COEFFS defaults to a zero vector of
%   length L.
%   
%   STATES are the initial conditions of the adaptive filter. STATES defaults
%   to a zero vector of length (L - 1).
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
%      L  = 32;                             % filter length
%      mu = 0.01;                           % Step size
%      h = adaptfilt.tdafdft(L,mu);
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
%   See also ADAPTFILT/TDAFDCT, ADAPTFILT/FDAF and ADAPTFILT/BLMS.

%   References: 
%     [1] S. Haykin, "Adaptive Filter Theory", 3rd Edition,
%         Prentice Hall, N.J., 1996.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:03:38 $

H = adaptfilt.tdafdft(varargin{:});
