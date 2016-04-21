function [mse,meanW,W,traceK] = msesim(h,x,d,M)
%MSESIM Adaptive filter measured mean-squared error.
%   MSE = MSESIM(H,X,D) Sequence of mean-square errors.  This column
%   vector contains estimates of the mean-square error of the adaptive
%   filter at each time instant.  The length of MSE is equal to SIZE(X,1).
%   The columns of the matrix X contain individual input signal sequences,
%   and the columns of the matrix D contain corresponding desired response
%   signal sequences. 
% 
%   [MSE,MEANW,W,TRACEK] = MSESIM(H,X,D) calculates three parameters
%   corresponding  to the simulated behavior of the adaptive filter defined
%   by H:
%
%       MEANW     - Sequence of coefficient vector means.  The columns of this 
%                   matrix contain estimates of the mean values of the LMS adaptive
%                   filter coefficients at each time instant.  The dimensions of
%                   MEANW are (SIZE(X,1)) x (H.length).
%       W       -   estimate of the final values of the adaptive filter
%                   coefficients for the algorithm corresponding to H.
%       TRACEK    - Sequence of total coefficient error powers.  This column vector
%                   contains estimates of the total coefficient error power of the
%                   LMS adaptive filter at each time instant.  The length of TRACEK 
%                   is equal to SIZE(X,1).
%
%   [MSE,MEANW,W,TRACEK] = MSESIM(H,X,D,M) specifies an optional
%   decimation factor  for computing MSE, MEANW, and TRACEK.  If M > 1,
%   every Mth predicted value of  each of these sequences is saved.  If
%   omitted, the value of M defaults to one.
%
%   EXAMPLE: Simulation of a 32-coefficient FIR filter 
%   (2000 iterations over 25 trials).
%       x = zeros(2000,25); d = x;          % Initialize variables
%       h = fir1(31,0.5);                  % FIR system to be identified
%       x = filter(sqrt(0.75),[1 -0.5],sign(randn(size(x)))); 
%       n = 0.1*randn(size(x));             % observation noise signal
%       d = filter(h,1,x)+n;                % desired signal
%       L = 32;                             % Filter length
%       mu = 0.008;                         % LMS Step size.
%       M  = 5;                             % Decimation factor for analysis and simulation results
%       h = adaptfilt.lms(L,mu);
%       [simmse,meanWsim,Wsim,traceKsim] = msesim(h,x,d,M);
%       nn = M:M:size(x,1);   
%       subplot(2,1,1);
%       plot(nn,meanWsim(:,12),'b',nn,meanWsim(:,13:15),'b');
%       title('Average Coefficient Trajectories for W(12), W(13), W(14) and W(15)');
%       xlabel('time index'); ylabel('coefficient value');
%       subplot(2,2,3);
%       semilogy(nn,simmse);
%       title('Mean-Square Error Performance'); axis([0 size(x,1) 0.001 10]);
%       legend('Measured MSE');
%       xlabel('time index'); ylabel('squared error value');
%       subplot(2,2,4);
%       semilogy(nn,traceKsim);
%       title('Sum-of-Squared Coefficient Errors'); axis([0 size(x,1) 0.0001 1]);
%       xlabel('time index'); ylabel('squared error value');
%
%   See also ADAPTFILT/FILTER, ADAPTFILT/MSEPRED, ADAPTFILT/MAXSTEP.

%   Author(s): Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/10/31 16:53:24 $

msg = sprintf(['Use MSESIM with one of the adaptive filters.\n',...
		'For an example, type: help msesim.']);
error(msg)
