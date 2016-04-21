% LQED   連続時間評価関数から離散時間 Kalman 推定器
%
% [M,P,Z,E] = LQED(A,G,C,Q,R,Ts) は、つぎのようなプロセスノイズと測定
% ノイズ
% 
%   E{w} = E{v} = 0,  E{ww'} = Q,  E{vv'} = R,  E{wv'} = 0
% 
% をもつ連続時間システム
% 
%         .
%         x = Ax + Bu + Gw    {状態方程式}
%         y = Cx + Du +  v    {測定方程式}
%
% に対して、推定誤差と等価な離散推定誤差を最小にする離散 Kalman ゲイン
% 行列 M を計算します。また、離散の Riccati 方程式の解 P、推定誤差の
% 共分散 Z、離散の推定器の極 E = EIG(Ad-Ad*M+C) も出力します。結果の
% 離散の Kalman 推定器は、DESTIM を使って作成します。
%
% 連続プラント (A,B,C,D) と連続共分散行列 (Q,R) は、サンプル時間 Ts と
% ゼロ次ホールド近似を使って、離散化されます。ゲイン行列 M は、DLQE を
% 使って計算されます。
%
% 参考 : DLQE, LQE, LQRD, DESTIM.


%   Clay M. Thompson 7-18-90
%   Revised: P. Gahinet  7-25-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:08 $
