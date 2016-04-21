% ARCOV  共分散法を使って、ARモデルパラメータの推定
%
% A = ARCOV(X,ORDER)は、共分散法を使って、入力信号(X)に適合する自己回帰
% (AR)モデルのARモデルパラメータ(A)を計算します。ORDERはARシステムの次数
% です。
%
% [A,E] = ARCOV(...)は、ARモデルへの白色ノイズ入力の分散(E)を出力します。
%
% 参考： PCOV, ARMCOV, ARBURG, ARYULE, LPC, PRONY.



%   Copyright 1988-2002 The MathWorks, Inc.
