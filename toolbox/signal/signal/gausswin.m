function w = gausswin(N, a)
%GAUSSWIN Gaussian window. 
%   GAUSSWIN(N) returns an N-point Gaussian window.
%
%   GAUSSWIN(N, ALPHA) returns the ALPHA-valued N-point Gaussian 
%   window.  ALPHA is defined as the reciprocal of the standard
%   deviation and is a measure of the width of its Fourier Transform.  
%   As ALPHA increases, the width of the window will decrease. If omitted, 
%   ALPHA is 2.5.
%
%   EXAMPLE:
%      N = 32;
%      wvtool(gausswin(N));
%
%
%   See also CHEBWIN, KAISER, TUKEYWIN, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic 
%         Analysis with the Discrete Fourier Transform, Proceedings of 
%         the IEEE, Vol. 66, No. 1, January 1978

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/11/21 15:46:46 $

error(nargchk(1,2,nargin));

% Default value for Alpha
if nargin < 2 | isempty(a), 
    a = 2.5;
end

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin, return, end;

% Index vector
k = -(N-1)/2:(N-1)/2;

% Equation 44a from [1]
w = exp((-1/2)*(a * k/(N/2)).^2)'; 

    
% [EOF]
