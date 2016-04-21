% DCGAIN   LTIモデルのDCゲイン
%
% K = DCGAIN(SYS) は、LTIモデル SYS の定常状態( D.C.、または、低周波数)
% でのゲインを計算します。
%
% SYS が、[NY NU S1 ... Sp] の次元をもつLTIモデル配列の場合、DCGAIN は、
% つぎのような同じ次元をもつ配列 K を出力します。
% 
%   K(:,:,j1,...,jp) = DCGAIN(SYS(:,:,j1,...,jp)) 
%
% 参考 : NORM, EVALFR, FREQRESP, LTIMODELS.


%	Andy Potvin  12-1-95
%	Clay M. Thompson  7-6-90
%	Copyright 1986-2002 The MathWorks, Inc. 
