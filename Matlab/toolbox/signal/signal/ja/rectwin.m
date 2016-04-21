function w = rectwin(n_est)
%RECTWIN 長方形のウィンドウ
%   W = RECTWIN(N) N点長方形ウィンドウ
%
%   参考     BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS,
%            BOHMANWIN, CHEBWIN, GAUSSWIN, HAMMING, HANN, KAISER, 
%            NUTTALLWIN, TRIANG, TUKEYWIN, WINDOW.


[n,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

w = ones(n,1);

% [EOF] 



%   Copyright 1988-2002 The MathWorks, Inc.
