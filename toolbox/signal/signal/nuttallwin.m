function w = nuttallwin(N)
%NUTTALLWIN Nuttall defined minimum 4-term Blackman-Harris window.
%   NUTTALLWIN(N) returns an N-point modified minimum 4-term 
%   Blackman-Harris window with coefficients according to 
%   Albert H. Nuttal's paper. 
%
%   EXAMPLE:
%      N = 32; 
%      w = nuttallwin(N); 
%      plot(w); title('32-point Nuttall window');
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN, 
%            FLATTOPWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] Albert H. Nuttall, Some Windows with Very Good Sidelobe
%         Behavior, IEEE Transactions on Acoustics, Speech, and 
%         Signal Processing, Vol. ASSP-29, No.1, February 1981

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/11/21 15:46:29 $

error(nargchk(1,1,nargin));

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin, return, end;

% Coefficients obtained from page 89 of [1]
a = [0.3635819 0.4891775 0.1365995 0.0106411];
w = min4termwin(N,a);
    

% [EOF]
