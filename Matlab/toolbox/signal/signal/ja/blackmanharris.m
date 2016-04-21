function w = blackmanharris(N)
%BLACKMANHARRIS 最小4-項Blackman-Harrisウィンドウ
%   BLACKMANHARRIS(N) は、列ベクトルで、N点最小4項Blackman-Harris
%   ウィンドウを返します。
%
%   例題:
%      N = 32; 
%      w = blackmanharris(N); 
%      plot(w); title('32-point Blackman-Harris window');
%
%   参考     BARTLETT, BARTHANNWIN, BLACKMAN, BOHMANWIN, CHEBWIN, 
%            GAUSSWIN, HAMMING, HANN, KAISER, NUTTALLWIN, RECTWIN, 
%            TRIANG, TUKEYWIN, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic 
%         Analysis with the Discrete Fourier Transform, Proceedings of 
%         the IEEE, Vol. 66, No. 1, January 1978

%   Author(s): P. Costa

error(nargchk(1,1,nargin));

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin, return, end;

% Coefficients obtained from page 65 of [1]
a = [0.35875 0.48829 0.14128 0.01168];
w = min4termwin(N,a);

% [EOF]


%   Copyright 1988-2002 The MathWorks, Inc.
