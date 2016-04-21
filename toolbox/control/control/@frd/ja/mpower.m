% MPOWER   LTIモデルのベキ乗計算
%
% MPOWER(SYS,K) は、SYS^K の実行時にコールされ、ここで、SYS は入力と出力
% が同数のLTI モデルで、K は整数でなければいけません。結果は、つぎの LTI
% モデルになります。
% 
%  * K>0 の場合、SYS * ... * SYS (K回) 
%  * K<0 の場合、INV(SYS) * ... * INV(SYS) (K回)
%  * K = 0 の場合、静的ゲイン EYE(SIZE(SYS))
%
% 参考 : FRD, PLUS, MTIMES, LTIMODELS.


%   Author(s): P. Gahinet, S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
