function y = psigmf(x, params)
% PSIGMF Product of two sigmoid membership functions.
%       PSIGMF(X, PARAMs) returns a matrix Y which is the product of two
%   sigmoid functions evaluated at X. PARAMS is a 4-element vector
%   that determines the shape and position of this membership function.
%   Specifically, X and PARAMS are passed to SIGMF as follows:
%
%   PSIGMF(X, PARAMS) = SIGMF(X, PARAMS(1:2)).*SIGMF(X, PARAMS(3:4));
%   
%   For example:
%
%       x = (0:0.2:10)';
%       params1 = [2 3];
%       y1 = sigmf(x, params1);
%       params2 = [-5 8];
%       y2 = sigmf(x, params2);
%       y3 = psigmf(x, [params1 params2]);
%       subplot(211);
%       plot(x, y1, x, y2); title('sigmf');
%       subplot(212);
%       plot(x, y3, 'g-', x, y3, 'o'); title('psigmf');
%       set(gcf, 'name', 'psigmf', 'numbertitle', 'off');
%
%   See also DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, SIGMF, SMF,
%   TRAPMF, TRIMF, ZMF.

%       Roger Jang, 10-5-93.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/14 22:19:37 $

if nargin ~= 2
    error('Two arguments are required by the prod. sigmoidal MF.');
elseif length(params) < 4
    error('The prod. sigmoidal MF needs at least four parameters.');
end

y = sigmf(x, params(1:2)).*sigmf(x, params(3:4));
