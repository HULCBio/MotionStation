function [y,e,Zf] = preadaptfir(x,d,S)
%PREADAPT Perform the filtering step for an adaptive filter.

%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 15:38:46 $


% Use filter to compute the output and return the final conditions
[y, Zf] = firfilter(S.coeffs, x, S.states);

e = d-y;   % Prediction error

%-----------------------------------------------------------------
function [y, Zf] = firfilter(coeffs, x, Zi)
% Perform direct form FIR filtering

% Make sure coefficients are a row
coeffs = coeffs(:).';

u  = [x;Zi];
y  = coeffs*u;
Zf = u(1:end-1);

% [EOF] 
