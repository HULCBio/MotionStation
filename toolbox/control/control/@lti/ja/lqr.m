% LQR   状態空間システムに対する線形2次形式レギュレータを設計
%  
% [K,S,E] = LQR(SYS,Q,R,N) は、つぎのような最適なゲイン行列 K を求め
% ます。
%  
%   * 状態空間モデル SYS が連続時間の場合、状態フィードバック則 u = -Kx 
%     は、対象とするシステムダイナミクス x = Ax + Bu のもとで、つぎの
%     評価関数を最小化します。
%  
%           J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%  
%   * 離散時間状態空間モデル SYS に対して u[n] = -Kx[n] は、対象とする
%     システムダイナミクス x[n+1] = Ax[n] + Bu[n] のもとで、つぎの評価
%     関数を最小化します。
%  
%               J = Sum {x'Qx + u'Ru + 2*x'Nu}
%  
% 行列 N は、省略するとゼロに設定します。代数Riccati方程式の解 S 
% と閉ループの固有値 E = EIG(A-B*K) も出力されます。
%
% [K,S,E] = LQR(A,B,Q,R,N) は、連続時間モデルに対応する構文です。
% ここで、A、Bは、モデル dx/dt = Ax + Bu を指定します。
%  
% 参考 : LQRY, LQGREG, DLQR, CARE, DARE.


%   Author(s): J.N. Little 4-21-85
%   Revised    P. Gahinet  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
