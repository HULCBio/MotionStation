% ARYULE  Yule-Walker 法を使って、ARモデルパラメータの推定
%
% A = ARYULE(X,ORDER)は、Yule-Walker(自己相関)法を使って、入力信号(X)に
% 適合する自己回帰(AR)モデルのARモデルパラメータ(A)を計算します。ORDERは、
% ARシステムの次数です。 この方法は、Levinson-Durbin再帰法を使って、Yule
% -Walker方程式を解くものです。
%
% [A,E] = ARYULE(...)は、最終予測誤差(ARモデルへの白色ノイズ入力の結果の
% 分散(E))を出力します。
%
% [A,E,K] = ARYULE(...)は、反射係数ベクトル(K)を出力します。
%
% 参考： PYULEAR, ARMCOV, ARBURG, ARCOV, LPC, PRONY.



%   Copyright 1988-2002 The MathWorks, Inc.
