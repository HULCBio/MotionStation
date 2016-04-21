% LQEW   プロセスノイズの直達項をもつ連続時間システムに対するKalman推定器
%
% つぎのシステムを考えます。
% 
%    .
%    x = Ax + Bu + Gw        {状態方程式}
%    y = Cx + Du + Hw + v    {測定方程式}
%
% このシステムは、バイアスを適用していないプロセスノイズ wと測定ノイズ v
% をもっています。ここでの共分散は、つぎのように表せます。
%
%    E{ww'} = Q,    E{vv'} = R,    E{wv'} = N ,
%
% [L,P,E] = LQEW(A,G,C,H,Q,R,N) は、センサ測定 y を使って、x の最適状態
% 推定 x_e を、定常 Kalman フィルタ
%    .
%    x_e = Ax_e + Bu + L(y - Cx_e - Du)
%
% を使って、観測ゲイン行列 L を出力します。結果の Kalman 推定器は、ESTIM
% を使って作成できます。
% 
% ノイズの相互相関 N は、省略すると0に設定されます。また、関連したRiccati
% 方程式
%                         -1
%    AP + PA' - (PC'+G*N)R  (CP+N'*G') + G*Q*G' = 0 
%
% の解 P と推定器の極 E = EIG(A-L*C) を出力します。
%
% 参考 : LQE, DLQEW, LQGREG, CARE, ESTIM.


%   Clay M. Thompson  7-23-90
%   Revised  P. Gahinet,  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:09 $
