function y = gbellmf(x, params)
%GBELLMF Generalized bell curve membership function.
%   GBELLMF(X, PARAMS) returns a matrix which is the generalized bell
%   membership function evaluated at X. PARAMS is a 3-element vector
%   that determines the shape and position of this membership function.
%   Specifically, the formula for this membership function is:
%
%   GBELLMF(X, [A, B, C]) = 1./((1+ABS((X-C)/A))^(2*B));
%
%   Note that this membership function is an extension to the Cauchy
%   probability dist. function. 
%   
%   For example:
%
%       x = (0:0.1:10)';
%       y1 = gbellmf(x, [1 2 5]);
%       y2 = gbellmf(x, [2 4 5]);
%       y3 = gbellmf(x, [3 6 5]);
%       y4 = gbellmf(x, [4 8 5]);
%       subplot(211); plot(x, [y1 y2 y3 y4]);
%       y1 = gbellmf(x, [2 1 5]);
%       y2 = gbellmf(x, [2 2 5]);
%       y3 = gbellmf(x, [2 4 5]);
%       y4 = gbellmf(x, [2 8 5]);
%       subplot(212); plot(x, [y1 y2 y3 y4]);
%       set(gcf, 'name', 'gbellmf', 'numbertitle', 'off');
%
%   See also DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, MF2MF, PIMF, PSIGMF, SIGMF, SMF,
%   TRAPMF, TRIMF, ZMF.

%   Roger Jang, 6-28-93, 10-5-93.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.22 $  $Date: 2002/04/14 22:20:41 $

if nargin ~= 2
    error('Two arguments are required by the generalized bell MF.');
elseif length(params) < 3
    error('Generalized bell MF needs at least three parameters.');
elseif params(1) == 0,
    error('Illegal parameter in gbellmf() --> a == 0');
end

a = params(1); b = params(2); c = params(3);

tmp = ((x - c)/a).^2;
if (tmp == 0 & b == 0)
    y = 0.5;
elseif (tmp == 0 & b < 0)
    y = 0;
else
    tmp = tmp.^b;
    y = 1./(1 + tmp);
end
