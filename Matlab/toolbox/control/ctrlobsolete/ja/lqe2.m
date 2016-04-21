% LQE2   線形二次推定器を設計
%
% 連続時間システムに対して、
%    .
%    x = Ax + Bu + Gw            {状態方程式}
%    z = Cx + Du + v             {測定方程式}
% 
% つぎのプロセスノイズと測定ノイズ共分散をもつとします。
% 
%    E{w} = E{v} = 0,  E{ww'} = Q,  E{vv'} = R, E{wv'} = 0
%
% L = LQE2(A,G,C,Q,R) は、ゲイン行列 L を出力し、それをもとに、定常 
% Kalman フィルタ
% 
%    x = Ax + Bu + L(z - Cx - Du)
% 
% が、x の LQG の最適推定を行います。推定器は、ESTIM を使って作成します。
%
% [L,P] = LQE2(A,G,C,Q,R) は、ゲイン行列 L と 推定誤差共分散になる Riccati 
% 方程式の解 P を出力します。
%
% [L,P] = LQE2(A,G,C,Q,R,N) は、プロセスノイズとセンサノイズが相関をもつ 
% E{wv'} = N 場合、推定器問題になります。
%
% LQE2 は、SCHUR アルゴリズムを使い、固有値分解を使った LQE より、数値的な
% 信頼度が高いものです。
%
% 参考 : LQEW, LQE, ESTIM.


%   Clay M. Thompson  7-23-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:07 $
