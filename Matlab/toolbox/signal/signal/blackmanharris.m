function w = blackmanharris(N)
%BLACKMANHARRIS Minimum 4-term Blackman-Harris window.
%   BLACKMANHARRIS(N) returns an N-point minimum 4-term Blackman-Harris 
%   window in a column vector.
%
%   EXAMPLE:
%      N = 32; 
%      w = blackmanharris(N); 
%      plot(w); title('32-point Blackman-Harris Window');
%
%   See also BARTHANNWIN, BARTLETT, BOHMANWIN, FLATTOPWIN, 
%            NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic 
%         Analysis with the Discrete Fourier Transform, Proceedings of 
%         the IEEE, Vol. 66, No. 1, January 1978

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/11/21 15:46:27 $

error(nargchk(1,1,nargin));

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin, return, end;

% Coefficients obtained from page 65 of [1]
a = [0.35875 0.48829 0.14128 0.01168];
w = min4termwin(N,a);


% [EOF]
