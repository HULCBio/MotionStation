% ARMCOV  修正共分散法を使って、ARモデルパラメータの推定 
%
% A = ARMCOV(X,ORDER)は、修正共分散法を使って、入力信号(X)に適合する自己
% 回帰(AR)モデルのARモデルパラメータ(A)を計算します。ORDERは、ARシステム
% の次数です。
%
% [A,E] = ARMCOV(...)は、ARモデルへの白色ノイズ入力の分散(E)を出力します。
%
% 参考： PMCOV, ARCOV, ARBURG, ARYULE, LPC, PRONY.



%   Copyright 1988-2002 The MathWorks, Inc.
