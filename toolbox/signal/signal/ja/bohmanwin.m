function w = bohmanwin(n)
%BOHMANWIN Bohman ウィンドウ
%   BOHMANWIN(N) は、列ベクトルで、N点 Bohman ウィンドウを返します。
%
%   例題:
%      N = 64; 
%      w = bohmanwin(N); 
%      plot(w); title('64-point Bohman window');
%
%   参考     BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS, CHEBWIN, 
%            GAUSSWIN, HAMMING, HANN, KAISER, NUTTALLWIN, RECTWIN,
%            TRIANG, TUKEYWIN, WINDOW.

%    Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic Analysis
%         with the Discrete Fourier Transform, Proceedings of the IEEE,
%         Vol. 66, No. 1, January 1978, Page 67, Equation 39.

%   Author(s): A. Dowd

[n,w,trivialwin] = check_order(n);
if trivialwin, return, end;

q = abs(linspace(-1,1,n));

% Forced end points to exactly zero
w = [ 0; ((1-q(2:end-1)).*cos(pi*q(2:end-1))+(1/pi)*sin(pi*q(2:end-1)))'; 0];

% [EOF]


%   Copyright 1988-2002 The MathWorks, Inc.
