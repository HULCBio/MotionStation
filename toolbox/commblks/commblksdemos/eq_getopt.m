function [e_opt, mmse, delta_opt, mu_max, mu_opt, P, Rn, dv] = eq_getopt(chCoeff, numTaps, sigma2S, sigma2N)
% EQ_GETOPT Computes Equalizer coefficients that minimizes the Mean Square
% Error. It also returns the vale of the minimum MSE and the optimum value
% of delta.
%
% Syntax:
% [e_opt, mmse, delta_opt, mu_max, mu_opt, P, Rn, dv] = eq_getopt(chCoeff, numTaps, sigma2S, sigma2N);

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/01/26 23:19:51 $

%-- Find Delta that minimizes MSE
P = convmtx(chCoeff, numTaps);
Rn = sigma2N*eye(numTaps);
deltaMtx = P*P'+(Rn/sigma2S);
delta_inv = inv(deltaMtx);

%-- Get Mean Square Error for all values of delta
mse = sigma2S*(1-diag(P'*delta_inv*P));

%-- Get Delta that minimizes MSE 
[mmse, delta_opt] = min(real(mse));
dv = [zeros(1,delta_opt-1) 1 zeros(1,size(P,2)-delta_opt)];

%-- Get the equalizer taps that minimizes MSE at a given delta
e_opt=(dv*P'*delta_inv).';

%-- Substract 1 to delta_opt (0-based)
delta_opt = delta_opt-1;

%-- Compute mu_max and mu_opt
lambda = eig(deltaMtx); 
mu_max = real(2/max(lambda));
mu_opt = real(1/max(lambda)*(min(lambda)/max(lambda)));

%[end of eq_getopt.m]

