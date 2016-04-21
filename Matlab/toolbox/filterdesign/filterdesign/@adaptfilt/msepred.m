function [mmse,emse,meanW,mse,traceK] = msepred(h,x,d,M);
%MSEPRED Predicted mean-squared error for adaptive filters.
%
%	NOTE: MSEPRED is available for the following adaptive filters:
%		ADAPTFILT.LMS
%		ADAPTFILT.NLMS
%		ADAPTFILT.BLMS
%		ADAPTFILT.BLMSFFT
%		ADAPTFILT.SE
%
%	The usage is the same for all these filters. The help follows:
%
%   [MMSE,EMSE] = MSEPRED(H,X,D) predicts the steady-state values at
%   convergence of the minimum mean-squared error (MMSE) and the excess 
%   mean-squared error (EMSE) given the input and desired response signal
%   sequences  in X and D and the quantities in the adaptive filter H.  
%  
%   [MMSE,EMSE,MEANW,MSE,TRACEK] = MSEPRED(H,X,D) calculates three
%   sequences corresponding to the analytical behavior of the LMS adaptive 
%   filter defined by H:
%
%       MEANW     - Sequence of coefficient vector means.  The columns of this 
%                   matrix contain predictions of the mean values of the LMS adaptive
%                   filter coefficients at each time instant.  The dimensions of
%                   MEANW are (SIZE(X,1)) x (H.length).
%       MSE       - Sequence of mean-square errors.  This column vector contains
%                   predictions of the mean-square error of the LMS adaptive filter
%                   at each time instant.  The length of MSE is equal to SIZE(X,1).
%       TRACEK    - Sequence of total coefficient error powers.  This column vector
%                   contains predictions of the total coefficient error power of the
%                   LMS adaptive filter at each time instant.  The length of TRACEK 
%                   is equal to SIZE(X,1).
%
%   [MMSE,EMSE,MEANW,MSE,TRACEK] = MSEPRED(H,X,D,M) specifies
%   an optional decimation factor for computing MEANW, MSE, and TRACEK.  If M > 1,
%   every Mth predicted value of each of these sequences is saved.  If omitted,
%   the value of M defaults to one.
%
%   EXAMPLE: Analysis and simulation of a 32-coefficient adaptive filter 
%   (2000 iterations over 25 trials).
%       x = zeros(2000,25); d = x;          % Initialize variables
%       h = fir1(31,0.5);                  % FIR system to be identified
%       x = filter(sqrt(0.75),[1 -0.5],sign(randn(size(x)))); 
%       n = 0.1*randn(size(x));             % observation noise signal
%       d = filter(h,1,x)+n;                % desired signal
%       L = 32;                             % Filter length
%       mu = 0.008;                         % LMS step size.
%       M  = 5;                             % Decimation factor for analysis and simulation results
%       h = adaptfilt.lms(L,mu);
%       [mmse,emse,meanW,mse,traceK] = msepred(h,x,d,M);
%       [simmse,meanWsim,Wsim,traceKsim] = msesim(h,x,d,M);
%       nn = M:M:size(x,1);   
%       subplot(2,1,1);
%       plot(nn,meanWsim(:,12),'b',nn,meanW(:,12),'r',nn,meanWsim(:,13:15),'b',nn,meanW(:,13:15),'r');
%       title('Average Coefficient Trajectories for W(12), W(13), W(14) and W(15)');
%       legend('Simulation','Theory');
%       xlabel('time index'); ylabel('coefficient value');
%       subplot(2,2,3);
%       semilogy(nn,simmse,[0 size(x,1)],[(emse+mmse) (emse+mmse)],nn,mse,[0 size(x,1)],[mmse mmse]);
%       title('Mean-Square Error Performance'); axis([0 size(x,1) 0.001 10]);
%       legend('MSE (Sim.)','Final MSE','MSE','Min. MSE');
%       xlabel('time index'); ylabel('squared error value');
%       subplot(2,2,4);
%       semilogy(nn,traceKsim,nn,traceK,'r');
%       title('Sum-of-Squared Coefficient Errors'); axis([0 size(x,1) 0.0001 1]);
%       legend('Simulation','Theory');
%       xlabel('time index'); ylabel('squared error value');
%
%   See also ADAPTFILT/MSESIM, ADAPTFILT/MAXSTEP, ADAPTFILT/FILTER.

%   Author(s): Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/10/30 16:45:40 $

msg = sprintf(['Use MSEPRED in conjunction with the following adaptive filters:\n',...
		'adaptfilt.lms\n',...
		'adaptfilt.nlms\n',...
		'adaptfilt.blms\n',...
		'adaptfilt.blmsfft\n',...
		'adaptfilt.se\n',...
		'For an example, type: help msepred.']);
error(msg)
