% LATC2TF ラティスフィルタを伝達関数に変換
% [NUM,DEN] = LATC2TF(K,V) は、ラティス係数Kとラダー係数VをもつIIRフィル
% タから分子NUM、分母DENをもつ伝達関数を求めます。
%
% [NUM,DEN] = LATC2TF(K,'allpole') では、Kは全極IIRラティスフィルタに関
% 連していると仮定します。
%
% [NUM,DEN] = LATC2TF(K,'allpass') では、KはオールパスのIIRラティスフィ
% ルタに関連していると仮定します。
%
% NUM = LATC2TF(K)とNUM = LATC2TF(K,'fir')は、KがFIRフィルタ構造に
% 関連し、構造の上出力が利用されると仮定します
% (FIRに対するLATCFILTの第一出力に対応)。
%
% NUM = LATC2TF(K,'min')は、abs(K) <= 1のとき、Kが最小位相FIRラティス
% フィルタ構造に関連すると仮定します。
%
% NUM = LATC2TF(K,'max'),は、abs(K) <= 1のとき、Kが最大位相FIRラティス 
% フィルタ構造に関連し、構造の下出力が利用されると仮定します(FIRに対す
% るLATCFILTの第二出力に対応)。
%
% 参考：LATCFILT, TF2LATC.



%   Copyright 1988-2002 The MathWorks, Inc.
