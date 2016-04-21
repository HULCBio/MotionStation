% LQRY   出力に重みを与えた線形2次形式レギュレータを設計
%
%
% [K,S,E] = LQRY(SYS,Q,R,N) は、つぎのような最適なゲイン行列 K を求めます。
%
%  * SYS が連続時間システムの場合、状態フィードバック則 u = -Kx は、対象とする
%    システムダイナミクス  dx/dt = Ax + Bu,  y = Cx + Du のもとでつぎのコスト
%    関数を最小化します。
%
%      J = Integral {y'Qy + u'Ru + 2*y'Nu} dt
%
%  * SYS が離散時間システムの場合、u[n] = -Kx[n] は、x[n+1] = Ax[n] + Bu[n],   
%    y[n] = Cx[n] + Du[n] のもとでつぎのコスト関数を最小化します。
%
%      J = Sum {y'Qy + u'Ru + 2*y'Nu}
%
% 行列 N は、省略するとゼロに設定します。
% 代数Riccati 方程式の解 S と閉ループの固有値 E = EIG(A-B*K) も出力されます。
%
% 参考 : LQR, DLQR, LQGREG, CARE, DARE.


% Copyright 1986-2002 The MathWorks, Inc.
