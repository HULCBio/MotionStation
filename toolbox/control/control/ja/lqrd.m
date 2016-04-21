% LQRD   連続時間評価関数から離散時間線形2次形式レギュレータを設計
%
%
% [K,S,E] = LQRD(A,B,Q,R,Ts) は、つぎの連続時間評価関数と等価な離散時間評価
% 関数を最小化する離散時間状態フィードバック則 u[n] = -K x[n] の最適ゲイン
% 行列 K を求めます。
% これは、離散化された状態ダイナミクス x[n+1] = Ad x[n] + Bd u[n] で
%
%   J = Integral {x'Qx + u'Ru} dt
%
% ここで、[Ad,Bd] = C2D(A,B,Ts) です。
% 離散 Riccati 方程式の解 S と閉ループの固有値 E = EIG(Ad-Bd*K) も出力します。
%
% [K,S,E] = LQRD(A,B,Q,R,N,Ts) は、つぎのより一般的な評価関数を扱います。
%   J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%
% アルゴリズム:  連続時間プラント(A, B, C, D)と連続時間の重み行列(Q, R, N)は、
% サンプル時間 Ts ゼロ次ホールドによる近似を用いて離散化されます。
% ゲイン行列 Kは、このとき DLQR を用いて計算されます。
%
% 参考 : DLQR, LQR, C2D, KALMD.


% Copyright 1986-2002 The MathWorks, Inc.
