function w = chebwin(n_est, r)
%CHEBWIN Chebyshev window.
%   CHEBWIN(N) returns an N-point Chebyshev window in a column vector.
% 
%   CHEBWIN(N,R) returns the N-point Chebyshev window with R decibels of
%   relative sidelobe attenuation. If ommited, R is set to 100 decibels.
%
%   See also GAUSSWIN, KAISER, TUKEYWIN, WINDOW.

%   Author: James Montanaro
%   Reference: E. Brigham, "The Fast Fourier Transform and its Applications" 

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2002/11/21 15:46:45 $

error(nargchk(1,2,nargin));

% Default value for R parameter.
if nargin < 2 || isempty(r), 
    r = 100.0;
end

[n,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

if r < 0,
    error('Attenuation must be specified as a positive number.');
end

w = chebwinx(n,r);


% [EOF] chebwin.m
