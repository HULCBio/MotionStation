% GAUSSWIN Gaussian ウィンドウ 
% GAUSSWIN(N) は、N-点 Gaussian ウィンドウを返します。
%
% GAUSSWIN(N, ALPHA) は、ALPHA値 N点Gaussianウィンドウ
% を返します。ALPHA は、標準偏差の逆数として定義され、
% フーリエ変換の幅の尺度です。ALPHA が増加するにつれて、
% ウィンドウの幅は、減少します。ALPHAを省略する場合、
% ALPHA は、2.5です。
%
% 例題:
%      N = 32; 
%      wvtool(gausswin(N));
%
%
% 参考: BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS, BOHMANWIN, 
%       CHEBWIN, HAMMING, HANN, KAISER, NUTTALLWIN, RECTWIN, TRIANG, 
%       TUKEYWIN, WINDOW.


%   Copyright 1988-2002 The MathWorks, Inc.
