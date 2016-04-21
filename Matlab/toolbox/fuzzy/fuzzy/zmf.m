function y = zmf(x, params)
%ZMF Z-shaped curve membership function.
%   ZMF(X, PARAMS) returns a matrix which is the Z-shaped
%   membership function evaluated at X. PARAMS = [X1 X0] is a 2-element
%   vector that determines the break points of this membership function.
%   When X1 < X0, ZMF is a smooth transition from 1 (at X1) to 0 (at X0).
%   When X1 >= X0, ZMF becomes a reverse step function which jumps from 1
%   to 0 at (X0+X1)/2.
%   
%   For example:
%
%       x = 0:0.1:10;
%       subplot(311); plot(x, zmf(x, [2 8]));
%       subplot(312); plot(x, zmf(x, [4 6]));
%       subplot(313); plot(x, zmf(x, [6 4]));
%       set(gcf, 'name', 'zmf', 'numbertitle', 'off');
%
%   See also DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF,
%   SIGMF, SMF, TRAPMF, TRIMF.

%   Roger Jang, 10-5-93, 7-14-94.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/14 22:21:49 $

if nargin ~= 2,
    error('Two arguments are required by ZMF.');
elseif length(params) < 2,
    error('ZMF needs at least two parameters.');
end

x1 = params(1); x0 = params(2);

if x1 >= x0,
    y = x <= (x0+x1)/2;
    return;
end

y = zeros(size(x));

index1 = find(x <= x1);
if ~isempty(index1),
    y(index1) = ones(size(index1));
end

index2 = find((x1 < x) & (x <= (x1+x0)/2));
if ~isempty(index2),
    y(index2) = 1-2*((x(index2)-x1)/(x1-x0)).^2;
end

index3 = find(((x1+x0)/2 < x) & (x <= x0));
if ~isempty(index3),
    y(index3) = 2*((x0-x(index3))/(x1-x0)).^2;
end

index4 = find(x0 <= x);
if ~isempty(index4),
    y(index4) = zeros(size(index4));
end
