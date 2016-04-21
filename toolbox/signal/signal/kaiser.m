function w = kaiser(n_est,bta)
%KAISER Kaiser window.
%   W = KAISER(N) returns an N-point Kaiser window in the column vector W.
% 
%   W = KAISER(N,BTA) returns the BETA-valued N-point Kaiser window.
%       If ommited, BTA is set to 0.500.
%
%   See also CHEBWIN, GAUSSWIN, TUKEYWIN, WINDOW.

%   Author(s): L. Shure, 3-4-87
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.2 $  $Date: 2004/04/13 00:18:04 $

error(nargchk(1,2,nargin));

% Default value for the BETA parameter.
if nargin < 2 || isempty(bta), 
    bta = 0.500;
end

[nn,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

nw = round(nn);
bes = abs(besseli(0,bta));
odd = rem(nw,2);
xind = (nw-1)^2;
n = fix((nw+1)/2);
xi = (0:n-1) + .5*(1-odd);
xi = 4*xi.^2;
w = besseli(0,bta*sqrt(1-xi/xind))/bes;
w = abs([w(n:-1:odd+1) w])';

    
% [EOF] kaiser.m
