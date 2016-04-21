% KALMD   連続時間のプラントに対する離散時間のKalman状態推定器を作成
%
%
% [KEST,L,P,M,Z] = KALMD(SYS,Qn,Rn,Ts) は、連続時間のプラントに対し、 
%      .
%      x = Ax + Bu + Gw      {状態方程式}
%      y = Cx + Du +  v      {観測方程式}
%
% 散時間のKalman状態推定器 KEST を作成します。
%
% プロセスノイズと観測ノイズは、つぎのようになります。
%
%   E{w} = E{v} = 0,  E{ww'} = Qn,  E{vv'} = Rn,  E{wv'} = 0
%
% LTI システム SYS は、プラントデータ (A,[B G],C,[D 0]) を設定します。
% 連続時間のプラントと共分散行列 (Q,R) は、初めに、サンプル時間 Ts とゼロ次ホー
% ルドによる近似を用いて離散化され、その結果の離散時間のプラントに対する離散
% 時間のKalman状態推定器を、KALMAN によって計算します。
%
% 推定器のゲイン L とイノベーションのゲイン M と定常偏差の共分散行列 Pと
% Z も出力します(詳細は、HELP DKALMAN とタイプしてください)。
%
% 参考 : LQRD, KALMAN, LQGREG.


% Copyright 1986-2002 The MathWorks, Inc.
