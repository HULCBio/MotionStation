% KALMAN   連続、離散のKalman状態推定器を作成します。
%
%
% [KEST,L,P] = KALMAN(SYS,QN,RN,NN) は、状態空間モデル SYS で表される連続、
% または、離散のプラントに対して、 Kalman 状態推定器 KEST を設計します。つぎの
% 連続時間プラントでは、 . x = Ax + Bu + Gw            {状態方程式}
% y = Cx + Du + Hw + v        {観測方程式}
%
% が、既知の入力 u、プロセスノイズ w、観測ノイズ v、共分散ノイズ
%
%  E{ww'} = Qn,     E{vv'} = Rn,     E{wv'} = Nn,
%
% をもっているとき、推定器 KEST は、入力 [u;y]をもち、y, x の最適な推定値
%  . x_e  = Ax_e + Bu + L(y - Cx_e - Du)
%
%  |y_e| = | C | x_e + | D | u |x_e|   | I |       | 0 |
%
% 離散時間の差分方程式についての詳細は、HELP DKALMAN とタイプしてください。
%
% 状態空間モデル SYS は、プラントデータ (A,[B G],C,[D H]) をもっていて、NN が
% 省略されたとき、ゼロと設定されます。QN の行のサイズは、ノイズ入力w (SYS への
% 最新入力)の数を設定します。Kalman 状態推定器 KEST は、SYS が連続の場合、連続
% になり、他の場合、離散になります。
%
% KALMAN は、推定器ゲイン L と定常偏差の共分散 P があります。
% H = 0 で、連続時間では、P は、つぎのRiccati 方程式を解いて求められます。 -1
%                                                            AP + PA' - (PC'+G*N)R  (CP+N'*G') + G*Q*G' = 0
%
%
% [KEST,L,P] = KALMAN(SYS,QN,RN,NN,SENSORS,KNOWN) は、つぎのような、より一般
% 的な立場を扱います。 * SYS の出力のいずれかが測定できない。 * ノイズ入力
% w は、SYS への最新入力でない。 インデックスベクトル SENSORS と KNOWN は、
% SYS のどの出力 y が測定可能かどの入力が既知かを示します。他のすべての入力
% は確率的であると仮定します。
%
% 参考 : KALMD, ESTIM, LQGREG, SS, LTIMODELS, CARE, DARE.


% Copyright 1986-2002 The MathWorks, Inc.
