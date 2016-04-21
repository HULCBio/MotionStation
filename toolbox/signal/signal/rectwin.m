function w = rectwin(n_est)
%RECTWIN Rectangular window.
%   W = RECTWIN(N) returns the N-point rectangular window.
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN, 
%            FLATTOPWIN, NUTTALLWIN, PARZENWIN, TRIANG, WINDOW.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/11/21 15:46:39 $

error(nargchk(1,1,nargin));
[n,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

w = ones(n,1);


% [EOF] 

