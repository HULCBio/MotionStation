% ZERO   LTIシステムの伝達零点
%
%
% Z = ZERO(SYS) は、LTIモデル SYS の伝達零点を出力します。
%
% [Z,GAIN] = ZERO(SYS) は、SISOモデル SYS に対して、(極-零点-ゲインの観点で)
% 伝達関数ゲインも出力します。
%
% SYS がサイズ [NY NU S1 ... Sp] の LTI モデルの配列の場合、Z と K はSYS と
% 同じ次数をもつ配列になり、Z(:,1,j1,...,jp) と K(1,1,j1,...,jp)は、LTIモデル
% SYS(:,:,j1,...,jp) の零点とゲインを与えます。零点のベクトルは、極ベクトルと
% 比べて、零点が少ないモデルに対して、NaN が割り当て、同じ長さにします。
%
% 参考 : POLE, PZMAP, ZPK, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
