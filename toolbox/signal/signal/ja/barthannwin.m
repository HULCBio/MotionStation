function w = barthannwin(N)
%BARTHANNWIN 修正Bartlett-Hanningウィンドウ
%   BARTHANNWIN(N) は、列ベクトルで、N点修正Bartlett-Hanning
%   ウィンドウを返します。 
%
%   例:
%      N = 64; 
%      w = barthannwin(N); 
%      plot(w); title('64-point Modified Bartlett-Hanning window');
%
%   参考     BARTLETT, BLACKMAN, BLACKMANHARRIS, BOHMANWIN, CHEBWIN,
%            GAUSSWIN, HAMMING, HANN, KAISER, NUTTALLWIN, RECTWIN,
%            TRIANG, TUKEYWIN, WINDOW.

%   Reference:
%     [1] Yeong Ho Ha and John A. Pearce, A New Window and Comparison
%         to Standard Windows, IEEE Transactions on Acoustics, Speech,
%         and Signal Processing, Vol. 37, No. 2, February 1999

%   Author(s): P. Costa and T. Bryan

error(nargchk(1,1,nargin));

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin, return, end;

% Equation 6 from [1]
t = ((0:(N-1))/(N-1)-.5)'; % -.5 <= t <= .5
w = .62-.48*abs(t) + .38*cos(2*pi*t);

% [EOF]


%   Copyright 1988-2002 The MathWorks, Inc.
