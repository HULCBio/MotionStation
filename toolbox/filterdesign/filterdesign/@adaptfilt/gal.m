%GAL  Gradient adaptive lattice FIR filter.
%   H = ADAPTFILT.GAL(L,STEP,LEAKAGE,OFFSET,RSTEP,DELTA,LAMBDA,RCOEFFS,
%   COEFFS,STATES) constructs a gradient adaptive lattice FIR filter H.
%
%   L is the length of the joint process filter coefficients. It must be
%   a positive integer and must be equal to the length of the reflection
%   coefficients plus one. L defaults to 10.
%   
%   STEP is the joint process step size of the adaptive filter. This
%   scalar should be a value between zero and one. STEP defaults to 0.
%   
%   LEAKAGE is the leakage factor of the adaptive filter. It must be a
%   scalar between 0 and 1. If it is less than one, leaky algorithms will
%   be implemented for the estimation of both the reflection and the joint
%   process coefficients. LEAKAGE defaults to 1 (no leakage).
%   
%   OFFSET specifies an optional offset for the denominator of the Step
%   size normalization term. It must be a scalar greater or equal to zero.
%   A non-zero Offset is useful to avoid a divide-by-near-zero if the input
%   signal amplitude becomes very small. OFFSET defaults to 1.
%
%   RSTEP is the reflection process step size of the adaptive filter. This
%   scalar should be a value between zero and one. RSTEP defaults to STEP.
%   
%   DELTA is the initial common value of all of the forward and backward 
%   prediction error powers. It should be a positive value. The default 
%   value for DELTA is 0.1.
%
%   LAMBDA specifies the averaging factor used to compute the exponentially
%   windowed forward and backward prediction error powers for the
%   coefficient updates. LAMBDA should lie in the range (0, 1].
%   LAMBDA defaults to the value (1 - STEP).
%   
%   RC0EFFS is a vector of initial reflection coefficients. It should be a
%   length (L-1) vector. RCOEFFS defaults to a zero-vector of length (L-1).
%   
%   COEFFS is a vector of initial joint process filter coefficients.
%   It must be a length L vector. COEFFS defaults to a length L vector
%   of all zeros.
%   
%   STATES is a vector of the backward prediction error states of the
%   adaptive filter. STATES defaults to a zero-vector of length (L-1).
%   
%
%   EXAMPLE: QPSK adaptive equalization using a 32-coefficient adaptive filter 
%   (1000 iterations).
%      D  = 16;                             % Number of samples of delay
%      b  = exp(j*pi/4)*[-0.7 1];           % Numerator coefficients of channel
%      a  = [1 -0.7];                       % Denominator coefficients of channel
%      ntr= 1000;                           % Number of iterations
%      s  = sign(randn(1,ntr+D)) + j*sign(randn(1,ntr+D));  % Baseband QPSK signal
%      n  = 0.1*(randn(1,ntr+D) + j*randn(1,ntr+D));        % Noise signal
%      r  = filter(b,a,s)+n;                % Received signal
%      x  = r(1+D:ntr+D);                   % Input signal (received signal)
%      d  = s(1:ntr);                       % Desired signal (delayed QPSK signal)
%      L = 32;                              % filter length
%      mu = 0.007;                          % Step size
%      h = adaptfilt.gal(L,mu);
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
%   See also ADAPTFILT/QRDLSL, ADAPTFILT/LSL, ADAPTFILT/TDAFDFT.

%   References: 
%     [1] L.J. Griffiths, "A continuously adaptive filter implemented as a 
%         lattice structure,"  Proc. IEEE Int. Conf. on Acoustics, Speech, 
%         and Signal Processing, Hartford, CT, pp. 683-686, 1977.
%     [2] S. Haykin, Adaptive Filter Theory, 3rd Ed.  (Upper Saddle 
%         River, NJ:  Prentice Hall, 1996).

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/29 22:23:05 $

% Help for the ADAPTFILT.GAL pcoded constructor.

% [EOF]
