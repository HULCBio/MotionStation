function w = bartlett(n_est)
%BARTLETT Bartlett window.
%   W = BARTLETT(N) returns the N-point Bartlett window.
%
%   See also BARTHANNWIN, BLACKMANHARRIS, BOHMANWIN, FLATTOPWIN,
%            NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/11/21 15:46:24 $

error(nargchk(1,1,nargin));

[n,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

w = 2*(0:(n-1)/2)/(n-1);
if rem(n,2)
    % It's an odd length sequence
    w = [w w((n-1)/2:-1:1)]';
else
    % It's even
    w = [w w(n/2:-1:1)]';
end

% [EOF] bartlett.m
