%ADJLMS  Adjoint LMS FIR adaptive filter.
%   H = ADAPTFILT.ADJLMS(L,STEPSIZE,LEAKAGE,PATHCOEFFS,PATHEST,ERRSTATES,
%   PSTATES,COEFFS,STATES) constructs an FIR adjoint LMS adaptive filter H.
%   
%   L is the adaptive filter length (the number of coefficients or taps)
%   and it must be a positive integer. L defaults to 10.
%
%   STEPSIZE is the adjoint LMS step size. It must be a nonnegative scalar.
%   STEPSIZE defaults to zero.
%   
%   LEAKAGE is the adjoint LMS leakage factor. It must be a scalar between
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
%   ERRSTATES is a vector of error states of the adaptive filter. It must
%   have a length equal to the filter order of the secondary path model
%   estimate. ERRSTATES defaults to a vector of all zeros of appropriate
%   length.
%
%   PSTATES are the secondary path FIR filter states. It must be a vector
%   of length  equal to the filter order of the secondary path model.
%   PSTATES defaults to a vector of all zeros of appropriate length.
%
%   COEFFS vector of initial filter coefficients. It must be a length L
%   vector. COEFFS defaults to a length L vector of all zeros.
%
%   STATES vector of initial filter states. It must be a vector of length
%   L+Ne-1, where Ne is the length of ERRSTATES. STATES defaults to a
%   vector of all zeros of appropriate length.
%
%   EXAMPLE: Active noise control of a random noise signal 
%   (1000 iterations).
%      x  = randn(1,1000);    % Noise source
%      g  = fir1(47,0.4);     % FIR primary path system model
%      n  = 0.1*randn(1,1000);% Observation noise signal
%      d  = filter(g,1,x)+n;  % Signal dosto be cancelled (desired)
%      b  = fir1(31,0.5);     % FIR secondary path system model 
%      mu = 0.008;            % Adjoint LMS step size
%      h = adaptfilt.adjlms(32,mu,1,b);
%      [y,e] = filter(h,x,d);
%      plot(1:1000,d,'b',1:1000,e,'r');
%      title('Active Noise Control of a Random Noise Signal');
%      legend('Original','Attenuated');
%      xlabel('time index'); ylabel('signal value');  grid on;
%
%   See also ADAPTFILT/DLMS, ADAPTFILT/FILTXLMS.


%   Author(s): R. Losada, Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/29 22:22:59 $

% Help for the ADAPTFILT.ADJLMS pcoded constructor.m

% [EOF]




