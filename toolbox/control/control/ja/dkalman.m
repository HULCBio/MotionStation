% KALMAN   連続または離散の Kalman 推定器を計算
%
%  離散時間 Kalman 推定器
%  ----------------------
%
% [KEST,L,P,M,Z] = KALMAN(SYS,QN,RN,NN) は、LTI プラント SYS が離散の
% 場合、離散 Kalman 推定器 KEST を作成します。つぎのプラントを考えます。
%
%   x[n+1] = Ax[n] + Bu[n] + Gw[n]           {状態方程式}
%   y[n]   = Cx[n] + Du[n] + Hw[n] + v[n]    {観測方程式}
%
% ここで、u は既知入力、w はプロセスノイズ、v は測定ノイズで、ノイズの
% 共分散
%
%   E{ww'} = QN,     E{vv'} = RN,     E{wv'} = NN
% 
% を使って、つぎの結果の Kalman 推定器
%
%   x[n+1|n] = Ax[n|n-1] + Bu[n] + L(y[n] - Cx[n|n-1] - Du[n])
%
%    y[n|n]  = Cx[n|n] + Du[n]
%    x[n|n]  = x[n|n-1] + M(y[n] - Cx[n|n-1] - Du[n])
%
% を、入力として、u[n] と y[u]を使い(この順で設定)、最適出力 y[n|n] と
% 最適状態 x[n|n] を作成します。推定器状態 x[n|n-1] は、過去の測定値 
% y[n-1], y[n-2],...を与えて、x[n] の最適推定を行います。
%
% また、推定器のゲイン L とイノベーションゲイン M とつぎの定常状態
% 誤差の共分散も出力します。
%
%    P = E{(x - x[n|n-1])(x - x[n|n-1])'}   (Riccati 方程式の解)
%    Z = E{(x - x[n|n])(x - x[n|n])'}       (更新された推定値)


%   Author(s): P. Gahinet  8-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:02 $
