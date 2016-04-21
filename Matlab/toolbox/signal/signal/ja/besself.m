% BESSELF  Besselアナログフィルタの設計
%
% [B,A] = BESSELF(N,Wn)は、カットオフ周波数(Wn)をもつ、N次のローパスアナ
% ログBesselフィルタを設計し、フィルタ係数を長さN+1の行ベクトルB および
% A に出力します。カットオフ周波数(Wn)は 0 より大きくなければなりません。 
% 
% カットオフ周波数(Wn)が2要素ベクトル Wn = [W1 W2] の場合、BESSELF(N,Wn)
% は、通過帯域 W1 < W < W2 をもつ 2*N次のバンドパスフィルタを出力します。
% 
% [B,A] = BESSELF(N,Wn,'high')は、ハイパスフィルタを設計します。
% 
% [B,A] = BESSELF(N, Wn, 'stop')は、Wn = [W1,W2]の場合にバンドストップフ
% ィルタになります。[Z, P, K] = BESSELF(...)のような出力引数を3つ指定す
% ると、零点と極を長さ(N)の列ベクトル Z,P に、また、スカラ Kにゲインをそ
% れぞれ出力します。
%
% [A,B,C,D] = BESSELF(...)のように出力引数を4つ指定すると、状態空間行列
% を出力します。
%
% 参考： BESSELAP, BUTTER, CHEBY1, CHEBY2, FREQZ, FILTER.



%   Copyright 1988-2002 The MathWorks, Inc.
