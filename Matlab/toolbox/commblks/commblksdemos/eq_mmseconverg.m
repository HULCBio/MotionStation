function mse=eq_mmseconverg(w, chCoeff, numTaps, sigma2S, sigma2N, lenChCoeff)
% EQ_MMSECONV plots MSE value given the values of the equalizer coefficients.
%
% Syntax:
% e_taps = eq_mmseconverg(e_taps, chCoeff, numTaps, lenChCoeff sigma2S, sigma2N);

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.2.4.1 $  $Date: 2004/01/26 23:19:54 $

%-- Reshape input data
s = size(w(1:numTaps,:));
w_t = conj(reshape(w(1:numTaps,:),max(s),min(s)));
s = size(chCoeff(1:lenChCoeff));
chCoeff_t = reshape(chCoeff(1:lenChCoeff),min(s),max(s));

%-- Get number of equalizers
ndims = size(w_t,2);

%-- Compute MMSe
[w_opt, mmse, delta_opt, mu_max, mu_opt, P, Rn, dv] = eq_getopt(chCoeff_t, ...
    numTaps, sigma2S, sigma2N);

%-- Compute MSE
dv_t = repmat(dv,ndims,1);
mse_t2 = real(sigma2S*(w_t'*(P*P'+Rn)*w_t - 2*real(w_t'*P*dv_t') + 1));

%-- Mux results
mse = real([diag(mse_t2)' mmse]);
%end of eq_mmseconverg.m
