% BUTTER Butterworth アナログおよびディジタルフィルタの設計
%
% [B,A] = BUTTER(N,Wn)は、N次のローパスデジィタルButterworthフィルタを
% 設計し、フィルタ係数を長さ(N+1)の行ベクトルBおよびAに、zの次数の降順
% に出力します。 また、カットオフ周波数Wnは、0と1の間の数でなければなり
% ません。ここで、1はサンプリング周波数の1/2(Nyquist周波数)です。
% 
% Wnが2要素ベクトルWn  = [W1 W2]の場合、BUTTERは通過帯域 W1 < W < W2 を
% もつ2*N次のバンドパスフィルタを出力します。
% 
% [B,A] = BUTTER(N,Wn,'high')は、カットオフ周波数Wnをもつハイパスフィル
% タを設計します。
% 
% [B,A] = BUTTER(N,Wn,'stop')は、Wnが2要素ベクトルWn  = [W1 W2]の場合、
% 遮断帯域 W1 < W < W2 をもつバンドストップフィルタを設計します。
% 
% [Z,P,K] = BUTTER(...)のように、3つの出力引数を与えると、零点と極を
% 長さNの列ベクトルZとPに、またゲインをスカラKにそれぞれ出力します。
%
% [A,B,C,D] = BUTTER(...)のように、4つの出力引数を与えると、状態空間
% 行列を出力します。
% 
% BUTTER(N,Wn,'s'), BUTTER(N,Wn,'high','s'), BUTTER(N,Wn,'stop','s')
% は、アナログButterworthフィルタを設計します。また、Wnは、[rad/s]を
% 単位とし、1より大きく設定することもできます。
%
% 参考：   BUTTORD, BESSELF, CHEBY1, CHEBY2, ELLIP, FREQZ, FILTER.



%   Copyright 1988-2002 The MathWorks, Inc.
