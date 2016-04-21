function [mumax,mumaxmse] = maxstep(h,x)
%MAXSTEP  Maximum step size for adaptive filter convergence.
%
%	NOTE: MAXSTEP is available for the following adaptive filters:
%		ADAPTFILT.LMS
%		ADAPTFILT.NLMS
%		ADAPTFILT.BLMS
%		ADAPTFILT.BLMSFFT
%		ADAPTFILT.SE
%
%   The usage is the same for all these filters, except for the
%   ADAPFILT.NLMS.
%
%   MUMAX = MAXSTEP(H,X) predicts a bound on the step size to  provide
%   convergence of the mean values of the adaptive filter coefficients.  
%
%   The columns of the matrix X contain individual input signal sequences.
%   The signal set is assumed to have zero mean or nearly so.  
% 
%   [MUMAX,MUMAXMSE] = MAXSTEP(H,X) predicts a bound on the adaptive
%   filter step size to provide convergence of the adaptive filter
%   coefficients in mean square.  
%
%   For the ADAPTFILT.NLMS, the maximum step size for convergence is
%   completely defined by the filter, H.  Therefore the input X should not
%   be used.
%
%   EXAMPLE: Analysis and simulation of a 32-coefficient adaptive filter 
%   (2000 iterations over 50 examples).
%       x = zeros(2000,50); d = x;          % Specify [numiterations,numexamples] = size(x);
%       h  = fir1(31,0.5);                  % FIR system to be identified
%       for k=1:size(x,2);                  % Create input and desired response signal matrices
%           x(:,k)  = filter(sqrt(0.75),[1 -0.5],sign(randn(size(x,1),1))); % (k)th input to the filter
%           n = 0.1*randn(size(x,1),1);     % (k)th observation noise signal
%           d(:,k)  = filter(h,1,x(:,k))+n; % (k)th desired signal
%       end
%       mu = 0.1;                           % LMS step size
%       h = adaptfilt.lms(32,mu);
%       [mumax,mumaxmse] = maxstep(h,x);
%
%   See also ADAPTFILT/MSEPRED, ADAPTFILT/MSESIM, ADAPTFILT/FILTER.


%   Author(s): S.C. Douglas
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:15:46 $

