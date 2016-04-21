% FFTSHIFT   DC成分をスペクトルの中心に移動
% 
% FFTSHIFT(X)は、Xがベクトルの場合、Xの右半分と左半分を入れ替えたベクト
% ルを出力します。Xが行列の場合、第1象限と第3象限を、第2象限と第4象限を
% 入れ替えた行列を出力します。XがN次元配列であれば、FFTSHIFT(X)は各次元
% でXの"半空間"を入れ替えます。
%
% FFTSHIFT(X,DIM) は、次元 DIM に沿って、FFTSHIFT 演算を適用します。
% 
% FFTSHIFTは、スペクトルの中心にDC成分をもつフーリエ変換の可視化に役立ち
% ます。
%
% 参考：IFFTSHIFT, FFT, FFT2, FFTN, CIRCSHIFT.


%   Copyright 1984-2004 The MathWorks, Inc.
