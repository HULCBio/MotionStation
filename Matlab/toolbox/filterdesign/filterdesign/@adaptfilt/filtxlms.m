%FILTXLMS  Filtered-X LMS FIR adaptive filter.
%   H = ADAPTFILT.FILTXLMS(L,STEPSIZE,LEAKAGE,PATHCOEFFS,PATHEST,FSTATES,
%   PSTATES,COEFFS,STATES) constructs an FIR adjoint LMS adaptive filter H.
%   
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%
%   STEPSIZE is the filtered LMS step size. It must be a nonnegative scalar.
%   STEPSIZE defaults to zero.
%   
%   LEAKAGE is the filtered LMS leakage factor. It must be a scalar between
%   0 and 1. If it is less than one, a leaky version of ADJLMS is
%   implemented. LEAKAGE defaults to 1 (no leakage).
%
%   PATHCOEFFS is the secondary path filter model.  This vector should
%   contain  the coefficient values of the secondary path from the output
%   actuator to the error sensor.
%
%   PATHEST is the estimate of the secondary path filter model. PATHEST
%   defaults to the values in PATHCOEFFS.
%
%   FSTATES is a vector of filtered input states of the adaptive filter.
%   FSTATES defaults to a zero vector of length equal to (L - 1).
%   
%   PSTATES are the secondary path FIR filter states. It must be a vector
%   of length  equal to the (length(PATHCOEFFS) - 1). PSTATES defaults to
%   a vector of all zeros of appropriate length.
%   
%   COEFFS is a vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to length L vector of all zeros.
%
%   STATES is a vector of initial filter states. STATES defaults to a zero
%   vector of length equal to the larger of (length(PATHCOEFFS) - 1) and
%   (length(PATHEST) - 1).
%
%   EXAMPLE: Active noise control of a random noise signal 
%   (1000 iterations).
%      x  = randn(1,1000);    % Noise source
%      g  = fir1(47,0.4);     % FIR primary path system model
%      n  = 0.1*randn(1,1000);% Observation noise signal
%      d  = filter(g,1,x)+n;  % Signal to be cancelled (desired)
%      b  = fir1(31,0.5);     % FIR secondary path system model 
%      mu = 0.008;            % Filtered-X LMS step size
%      h = adaptfilt.filtxlms(32,mu,1,b);
%      [y,e] = filter(h,x,d);
%      plot(1:1000,d,'b',1:1000,e,'r');
%      title('Active Noise Control of a Random Noise Signal');
%      legend('Original','Attenuated');
%      xlabel('time index'); ylabel('signal value');  grid on;
%
%   See also ADAPTFILT/DLMS, ADAPTFILT/LMS.


%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/29 22:23:02 $

% Help for the ADAPTFILT.FILTXLMS pcoded constructor. 

% [EOF]

