% DLQRY   離散時間システムに対する重み付きの出力をもつ線形二次レギュレータ
%
% [K,S,E] = DLQRY(A,B,C,D,Q,R) は、評価関数
% 
%    J = Sum {y'Qy + u'Ru}
% 
% を、つぎの拘束方程式
%
%    x[n+1] = Ax[n] + Bu[n] 
%      y[n] = Cx[n] + Du[n]
%             
% のもとで、最小にする制御則 u[n] = -Kx[n] を満たす最適フィードバック
% ゲイン行列 K を計算します。
%
% ここで、関連した離散行列 Riccati 方程式の定常状態の解 S と、閉ループの
% 固有値 E = EIG(A-B*K) も出力できます。
%
% コントローラは、DREG を使って作成できます。
%
% 参考 : DLQR, LQRD, DREG.


%   Clay M. Thompson  7-23-90
%   Revised: P. Gahinet  7-25-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:48 $
