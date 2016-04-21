function w = triang(n_est)
%TRIANG Triangular window.
%   W = TRIANG(N) returns the N-point triangular window.
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN, 
%            FLATTOPWIN, NUTTALLWIN, PARZENWIN, RECTWIN, WINDOW.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/11/21 15:46:40 $

error(nargchk(1,1,nargin));
[n,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

if rem(n,2)
    % It's an odd length sequence
    w = 2*(1:(n+1)/2)/(n+1);
    w = [w w((n-1)/2:-1:1)]';
else
    % It's even
    w = (2*(1:(n+1)/2)-1)/n;
    w = [w w(n/2:-1:1)]';
end

    
% [EOF] triang.m
