% DLQE   離散時間システムに対する Kalman 推定器の設計
%
% つぎのシステムを考えます。
%
%   x[n+1] = Ax[n] + Bu[n] + Gw[n]    {状態方程式}
%   y[n]   = Cx[n] + Du[n] +  v[n]    {測定方程式}
%
% このシステムは、バイアスを適用していないプロセスノイズ w[k] と測定
% ノイズ v[k] をもっています。ここでの共分散は、つぎのように表せます。
%
%   E{ww'} = Q,    E{vv'} = R,    E{wv'} = 0 ,
%
% [M,P,Z,E] = DLQE(A,G,C,Q,R) は、y[n] と過去の測定を与えて、観測方程式
% と更新方程式
%
%   x[n|n]   = x[n|n-1] + M(y[n] - Cx[n|n-1] - Du[n])
%   x[n+1|n] = Ax[n|n] + Bu[n] 
% 
% をもつ離散、定常 Kalman フィルタは、x[n] の最適状態推定 x[n|n]を作成
% するゲイン行列 M を出力します。結果の Kalman 推定器は、DESTIM を使って
% 作成できます。
%
% また、出力されるものは、定常状態誤差共分散
%
%   P = E{(x[n|n-1] - x)(x[n|n-1] - x)'}     (Riccati 方程式の解)
%   Z = E{(x[n|n] - x)(x[n|n] - x)'}         (誤差の共分散)
%
% と推定器の極 E = EIG(A-A*M*C) です。
%
% 参考 : DLQEW, LQED, DESTIM, KALMAN, DARE.


%   J.N. Little 4-21-85
%   Revised Clay M. Thompson  7-16-90, P. Gahinet, 7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:46 $
