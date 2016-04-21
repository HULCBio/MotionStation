% ARBURG  Burg 法を使った、ARモデルパラメータの推定  
%
% A = ARBURG(X,ORDER)は、Burg 法を使って、入力信号(X)に適合する自己回帰
% (AR)モデルのARモデルパラメータ(A)を計算します。
% ORDER は、ARシステムのモデルの次数です。
%
% [A,E] = ARBURG(...)は、最終予測誤差 E (AR モデルに白色ノイズ入力を
% 行ったときの分散)を出力します。
%
% [A,E,K] = ARBURG(...)は、反射係数のベクトル(K)を出力します。
%
% 参考： PBURG, ARMCOV, ARCOV, ARYULE, LPC, PRONY.



%   Copyright 1988-2002 The MathWorks, Inc.
