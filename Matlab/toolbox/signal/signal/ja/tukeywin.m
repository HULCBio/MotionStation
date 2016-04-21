% TUKEYWIN Tukey ウィンドウ
% W = TUKEYWIN(N,R) は、列ベクトルで、N-点Tukeyウィンドウを返します。
% Tukeyウィンドウは、また、余弦-テーパウィンドウとしても知られて
% います。 Rパラメータは、一定区間におけるテーパの比率を指定します。
% この比は、1 (すなわち、0 < R < 1)に規格化されています。
% Rの値が極端な場合、Tukey ウィンドウは、他の共通のウィンドウに
% 退化することに、注意してください。
% 従って、R = 1の場合、これは、Hanning ウィンドウと等価です。逆に、
% R = 0に対して、Tukey ウィンドウは、定数値(すなわち、boxcar)
% を仮定します。
%
% 例題:
%         N = 64; 
%         w = tukeywin(N,0.5); 
%         plot(w); title('64-point Tukey window, Ratio = 0.5');
%
% 参考    BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS, 
%         BOHMANWIN, CHEBWIN, GAUSSWIN, HAMMING, HANN, KAISER,
%         NUTTALLWIN, RECTWIN, TRIANG, WINDOW.
%
% 参考文献:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic Analysis
%         with the Discrete Fourier Transform, Proceedings of the IEEE,
%         Vol. 66, No. 1, January 1978, Page 67, Equation 38.


%   Copyright 1988-2002 The MathWorks, Inc.
