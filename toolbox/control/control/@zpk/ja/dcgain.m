% DCGAIN   LTIモデルの DC ゲイン
%
% K = DCGAIN(SYS) は、LTIモデル SYS の定常状態(D.C. または、低周波数)
% でのゲインを計算します。
%
% SYS が、[NY NU S1 ... Sp] の次元をもつLTIモデル配列の場合、DCGAIN は、
% つぎのような同じ次元をもつ配列 K を出力します。
% 
%   K(:,:,j1,...,jp) = DCGAIN(SYS(:,:,j1,...,jp)) 
%
% 参考 : NORM, EVALFR, FREQRESP, LTIMODELS.


%   Author(s): A. Potvin, 12-1-95
%   Revised: P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
