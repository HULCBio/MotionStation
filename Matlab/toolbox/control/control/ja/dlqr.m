% DLQR   離散時間システム用の線形2次レギュレータを作成
%
%
% [K,S,E] = DLQR(A,B,Q,R,N) は、つぎの評価関数
%
%  J = Sum {x'Qx + u'Ru + 2*x'Nu}
%
% を状態ダイナミックス x[n+1] = Ax[n] + Bu[n] の基で、最小にする状態フィード
% バック則 u[n] = -Kx[n] の最適ゲイン行列 K を計算します。
%
% 行列 N は、省略するとゼロに設定します。
% また、Riccati 方程式の解 S と閉ループの固有値 E も求めます。
%                                -1
%     A'SA - S - (A'SB+N)(R+B'SB) (B'SA+N') + Q = 0,   E = EIG(A-B*K)
%
%
% 参考 : DLQRY, LQRD, LQGREG, DARE.


% Copyright 1986-2002 The MathWorks, Inc.
