% DLQEW   プロセスノイズの直達項をもつ離散時間システムに対する Kalman 推定器
%
% つぎのシステムを考えます。
%
%   x[k+1] = Ax[k] + Bu[k] + Gw[k]           {状態方程式}
%   y[k]   = Cx[k] + Du[k] + Hw[k] + v[k]    {測定方程式}
%
% このシステムは、バイアスを適用していないプロセスノイズ w[k] と測定ノイズ 
% v[k] をもっています。ここでの共分散は、つぎのように表せます。
%
%   E{ww'} = Q,    E{vv'} = R,    E{wv'} = 0 ,
%
% [M,P,Z,E] = DLQEW(A,G,C,H,Q,R) は、y[k] と過去の測定を与えて、観測方程式
% と更新方程式
%
%   x[k|k]   = x[k|k-1] + M(y[k] - Cx[k|k-1] - Du[k])
%   x[k+1|k] = Ax[k|k] + Bu[k] 
%
% をもつ離散、定常 Kalman フィルタは、x[k] の最適状態推定 x[k|k]を作成する
% ゲイン行列 M を出力します。結果の Kalman 推定器は、DESTIM を使って作成
% できます。
%
% また、出力されるものは、定常状態誤差共分散
%
%   P = E{(x[k|k-1] - x)(x[k|k-1] - x)'}     (Riccati 方程式の解)
%   Z = E{(x[k|k] - x)(x[k|k] - x)'}         (誤差の共分散)
%
% と推定器の極 E = EIG(A-A*M*C) です。
%
% 参考 : DLQE, LQED, DESTIM, KALMAN, DARE.


%   Clay M. Thompson  7-23-90
%   Revised: P. Gahinet 7-25-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:47 $
