% LQE   連続時間システムに対する Kalman 推定器
%
% つぎのシステムを考えます。
%    .
%    x = Ax + Bu + Gw            {状態方程式}
%    y = Cx + Du + v             {測定方程式}
%
% このシステムは、バイアスを適用していないプロセスノイズ w と測定ノイズ 
% v をもっています。ここでの共分散は、つぎのように表せます。
%
%    E{ww'} = Q,    E{vv'} = R,    E{wv'} = N ,
%
% [L,P,E] = LQE(A,G,C,Q,R,N) は、センサ測定 y を使って、x の最適状態推定 
% x_e を、定常 Kalman フィルタ
%    .
%    x_e = Ax_e + Bu + L(y - Cx_e - Du)
%
% を使って、観測ゲイン行列 L を出力します。結果の Kalman 推定器は、ESTIM 
% を使って作成できます。
%
% ノイズの相互相関 N は、省略すると0に設定されます。また、関連した Riccati 
% 方程式
%                         -1
%    AP + PA' - (PC'+G*N)R  (CP+N'*G') + G*Q*G' = 0 
%
% の解 P と推定器の極 E = EIG(A-L*C) を出力します。
%
% 参考 : LQEW, DLQE, LQGREG, CARE, ESTIM.


%   J.N. Little 4-21-85
%   Revised Clay M. Thompson  7-16-90, P. Gahinet  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:06 $
