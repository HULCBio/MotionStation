% MARGIN   ゲイン余裕、位相余裕とゲイン交差周波数、位相交差周波数
%
% [Gm,Pm,Wcg,Wcp] = MARGIN(SYS) は、SISO 開ループLTIモデル SYS (連続系
% または離散系)のゲイン余裕 Gm と位相余裕 Pm、そして、関連する位相交差
% 周波数 Wcg とゲイン交差周波数 Wcp を計算します。ゲイン余裕 Gm は 1/G 
% として定義され、ここで、G は位相が-180度と交差するときのゲインです。
% 位相余裕 Pm は、度単位で表れます
%
% dB単位で表したゲイン余裕は、つぎの関係から導かれます。
% 
%      Gm_dB = 20*log10(Gm)
% 
% Wcg でのループのゲインは、安定性がくずれる前での増加または減少する
% ゲインで、Gm_dB < 0 (Gm < 1)は、安定性がループゲインの減少に非常に
% 敏感であることを意味します。複数の交差点が存在する場合、MARGIN は、
% 最悪の余裕(ゲイン余裕は0 dB に近く、最小位相余裕)を出力します。
%
% LTIモデルの S1*...*Sp 配列 SYS に対して、MARGIN は、サイズ [S1 ... Sp]
% のつぎのような配列を出力します。
%      [Gm(j1,...,jp),Pm(j1,...,jp)] = MARGIN(SYS(:,:,j1,...,jp))
%
% [Gm,Pm,Wcg,Wcp] = MARGIN(MAG,PHASE,W) BODE によって生成された Bode
% ゲイン、位相、周波数ベクトルである MAG, PHASE, W からゲインと位相余裕を
% 導出します。補間は、値を推定するために周波数点間で行われます。
%
% MARGIN(SYS) は、それ自身では垂直ラインでマーク付けされたゲインと位相余裕
% を使って開ループBodeをプロットします。
%
% 参考 : ALLMARGIN, BODE, LTIVIEW, LTIMODELS.


%   Andrew Grace 12-5-91
%   Revised ACWG 6-21-92
%   Revised P.Gahinet 96-98
%   Revised A.DiVergilio 7-00
%   Revised J.Glass 1-02
%   Copyright 1986-2002 The MathWorks, Inc. 
