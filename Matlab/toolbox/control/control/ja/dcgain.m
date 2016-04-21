% DCGAIN   LTI モデルの DC ゲインを出力
%
%
% K = DCGAIN(SYS) は、LTIモデル SYS の 定常状態 (D.C.または低周波数) 
% ゲインを計算します。
%
% SYS が、[NY NU S1 ... Sp] の次元をもつ LTI モデル配列の場合、 DCGAIN は、
% つぎのような同じ次元をもつ配列 K を出力します。 
%    K(:,:,j1,...,jp) = DCGAIN(SYS(:,:,j1,...,jp)) 
%
% 参考 : NORM, EVALFR, FREQRESP, LTIMODELS


% Copyright 1986-2002 The MathWorks, Inc.
