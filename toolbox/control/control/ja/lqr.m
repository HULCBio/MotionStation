% LQR   連続時間システムに対する線形2次レギュレータを設計
%
%
% [K,S,E] = LQR(A,B,Q,R,N) は、つぎの評価関数
%
%   J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%                        .
% を、状態ダイナミックス x = Ax + Bu で、最小にする状態フィードバック則 
% u = -Kx の最適ゲイン行列 K を計算します。
%
% 行列 N は、省略するとゼロに設定します。
% また、Riccati 方程式の解 S と閉ループの固有値 E も求めます。
%                    -1
%   SA + A'S - (SB+N)R  (B'S+N') + Q = 0 ,    E = EIG(A-B*K) 
%
%
% 参考 : LQRY, DLQR, LQGREG, CARE, REG.


% Copyright 1986-2002 The MathWorks, Inc.
