function y = trimf(x, params)
%TRIMF Triangular membership function.
%   TRIMF(X, PARAMS) returns a matrix which is the triangular
%   membership function evaluated at X. PARAMS = [A B C] is a 3-element
%   vector that determines the break points of this membership function.
%   Usually we require A <= B <= C.
%
%   Note that this MF always has a height of unity. To have a triangular
%   MF with a height less than unity, use TRAPMF instead.
%
%   For example:
%
%       x = (0:0.2:10)';
%       y1 = trimf(x, [3 4 5]);
%       y2 = trimf(x, [2 4 7]);
%       y3 = trimf(x, [1 4 9]);
%       subplot(211), plot(x, [y1 y2 y3]);
%       y1 = trimf(x, [2 3 5]);
%       y2 = trimf(x, [3 4 7]);
%       y3 = trimf(x, [4 5 9]);
%       subplot(212), plot(x, [y1 y2 y3]);
%       set(gcf, 'name', 'trimf', 'numbertitle', 'off');
%
%   See also DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF,
%   SIGMF, SMF, TRAPMF, ZMF.

%   Roger Jang, 6-29-93, 10-5-93, 4-14-94.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/14 22:21:19 $

if nargin ~= 2
    error('Two arguments are required by the triangular MF.');
elseif length(params) < 3
    error('The triangular MF needs at least three parameters.');
end

a = params(1); b = params(2); c = params(3);

if a > b,
    error('Illegal parameter condition: a > b');
elseif b > c,
    error('Illegal parameter condition: b > c');
elseif a > c,
    error('Illegal parameter condition: a > c');
end

y = zeros(size(x));

% Left and right shoulders (y = 0)
index = find(x <= a | c <= x);
y(index) = zeros(size(index));

% Left slope
if (a ~= b)
    index = find(a < x & x < b);
    y(index) = (x(index)-a)/(b-a);
end

% right slope
if (b ~= c)
    index = find(b < x & x < c);
    y(index) = (c-x(index))/(c-b);
end

% Center (y = 1)
index = find(x == b);
y(index) = ones(size(index));
