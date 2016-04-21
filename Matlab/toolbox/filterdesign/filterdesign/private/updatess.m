function S = updatess(x,e,S)
% Execute one iteration of the sign-sign FIR adaptive filter.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:39:12 $


% Form vector of input+states
u  = [x;S.states].';

% Compute new coefficients
S.coeffs = S.leakage.*S.coeffs + S.step.*sign(e).*sign(u);

% EOF

