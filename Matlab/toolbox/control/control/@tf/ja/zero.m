% ZERO   LTIシステムの伝達零点
% 
% Z = ZERO(SYS) は、LTIモデル SYS の伝達零点を出力します。
%
% [Z,GAIN] = ZERO(SYS) は、SISOモデル SYS に対して、(極-零点-ゲインの
% 観点で)伝達関数ゲインも出力します。
% 
% SYS がサイズ [NY NU S1 ... Sp] のLTIモデルの配列の場合、Z と K は 
% SYS と同じ次数をもつ配列になり、Z(:,1,j1,...,jp) と K(1,1,j1,...,jp) 
% は、LTIモデル SYS(:,:,j1,...,jp) の零点とゲインを与えます。 零点の
% ベクトルは、極ベクトルと比べて、零点が少ないモデルに対して、NaN が割り
% 当て、同じ長さにします。
%
% 参考 : POLE, PZMAP, ZPK, LTIMODELS.


%   Clay M. Thompson  7-23-90, 
%   Revised:  P.Gahinet 5-15-96
%   Copyright 1986-2002 The MathWorks, Inc. 
