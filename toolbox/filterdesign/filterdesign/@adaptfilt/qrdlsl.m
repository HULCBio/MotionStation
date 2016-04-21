%QRDLSL  QR-decomposition-based least-squares lattice adaptive filter.
%   H = ADAPTFILT.QRDLSL(L,LAMBDA,DELTA,COEFFS,STATES) constructs a
%   QR-decomposition-based least-squares lattice adaptive filter H.
%
%   L is the length of the joint process auxiliary coefficients. It must
%   be a positive integer and must be equal to the length of the prediction
%   coefficients plus one. L defaults to 10.
%   
%   LAMBDA is the forgetting factor of the adaptive filter. This is a
%   scalar and should lie in the range (0, 1]. LAMBDA defaults to 1.
%   LAMBDA = 1 denotes infinite memory.
%   
%   DELTA is the soft-constrained initialization factor in the QRD least
%   squares lattice algorithm. It should be positive. DELTA defaults to 1.
%   
%   COEFFS is a vector of the initial joint process filter coefficients.
%   It must be a length L vector. COEFFS defaults to a length L vector
%   of all zeros.
%   
%   STATES is a vector of the angle-normalized backward prediction error
%   States of the adaptive filter. STATES defaults to a zero-vector of
%   length (L - 1).
%   
%
%   EXAMPLE: QPSK adaptive equalization using a 32-coefficient adaptive filter 
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
%      lam = 0.995;                         % Forgetting factor
%      del = 1;                             % Soft-constrained initialization factor
%      h = adaptfilt.qrdlsl(32,lam,del);
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
%   See also ADAPTFILT/QRDRLS, ADAPTFILT/GAL, ADAPTFILT/FTF, ADAPTFILT/LSL.

%   References: 
%     [1] S. Haykin, "Adaptive Filter Theory", 2nd Edition,
%         Prentice Hall, N.J., 1991.

%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/29 22:23:11 $

% Help for ADAPTFILT.QRDLSL pcoded constructor.

% [EOF]



