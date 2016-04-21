% SPECPLOT は、SPECTRUM 関数の出力をプロットします。
% SPECPLOT(P,Fs) は、P を使って、サンプル周波数 Fs で、連続的に SPECTRUM
% の出力をプロットします。
%
% 	Pxx        - X のパワースペクトル密度 と信頼区間
% 	Pyy        - Y のパワースペクトル密度 と信頼区間
% 	abs(Txy)   - 伝達関数の大きさ
% 	angle(Txy) - 伝達関数の位相
% 	Cxy        - コヒーレンス関数
%
% 95% の信頼区間は、パワースペクトル密度曲線上に重ねて表示されます。
%
% SPECPLOT(P) は、正規化された周波数 Fs = 2 を使って、計算します。従って、
% 周波数軸の 1.0 は、サンプルレートの半分(Nyquist 周波数)です。

%   Copyright 1988-2001 The MathWorks, Inc.
