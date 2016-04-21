function H = pbfdaf(varargin)
%PBFDAF  Partitioned block frequency-domain FIR adaptive filter with bin
%        Step size normalization.
%   H = ADAPTFILT.PBFDAF(L,STEP,LEAKAGE,DELTA,LAMBDA,BLOCKLEN,OFFSET,
%   COEFFS,STATES) constructs a partitioned block frequency-domain FIR
%   adaptive filter H with bin Step size normalization.
%
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%   
%   STEP is the Step size of the adaptive filter. This is a scalar and
%   should lie in the range (0,1]. STEP defaults to 1.
%   
%   LEAKAGE is the Leakage parameter of the adaptive filter. If this
%   parameter is set to a value between zero and one, a leaky PBFDAF
%   algorithm is implemented. LEAKAGE defaults to 1 (i.e., no Leakage).
%   
%   DELTA is the initial common value of all of the FFT input signal
%   powers. Its initial value should be positive. DELTA defaults to 1.
%   
%   LAMBDA specifies the averaging factor used to compute the exponentially
%   windowed FFT input signal powers for the coefficient updates. LAMBDA
%   should lie in the range (0,1]. LAMBDA defaults to 0.9.
%   
%   BLOCKLEN is the block length for the coefficient updates. This must
%   be a positive integer such that (L/BLOCKLEN) is also an integer.
%   For faster execution, BLOCKLEN should be a power of two.  BLOCKLEN
%   defaults to two.
%   
%   OFFSET is the Offset for the normalization terms in the coefficient
%   updates. This can be used to avoid divide by zeros (or by very small
%   numbers) if any of the FFT input signal powers become very small.
%   OFFSET defaults to zero.
%   
%   COEFFS are the initial time-domain coefficients of the adaptive filter.
%   It should be a length L vector. These coefficients are used to compute
%   the initial frequency-domain filter coefficient matrix via FFTs.
%   
%   STATES specifies the filter initial conditions. STATES defaults to a
%   zero vector of length L.
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
%      del = 1;                             % Initial FFT input powers
%      mu  = 0.1;                           % Step size
%      lam = 0.9;                           % Averaging factor
%      N   = 8;                             % Block size
%      h = adaptfilt.pbfdaf(32,mu,1,del,lam,N);
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
%   See also ADAPTFILT/FDAF, ADAPTFILT/PBUFDAF, ADAPTFILT/SBAF and
%   ADAPTFILT/BLMSFFT.

%   References: 
%     [1] J.S. So and K.K. Pang, "Multidelay block frequency domain 
%         adaptive filter,"  IEEE Trans. Acoustics, Speech, and 
%         Signal Processing, vol. 38, no. 2, pp. 373-376, February
%         1990.
%     [2] J.M. Paez Borrallo and and M.G. Otero, "On the implementation 
%         of a partitioned block frequency domain adaptive filter 
%         (PBFDAF) for long acoustic echo cancellation,"  Signal 
%         Processing, vol. 27, no. 3, pp. 301-315, June 1992.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:03:37 $

H = adaptfilt.pbfdaf(varargin{:});
