% LQRY   出力に重みを与えた線形2次形式レギュレータを設計
%
% [K,S,E] = LQRY(SYS,Q,R,N) は、つぎのような最適なゲイン行列 K を求め
% ます。 
%
%  * SYS が連続時間システムの場合、状態フィードバック則 u = -Kx は、対象
%    とするシステムダイナミクス  dx/dt = Ax + Bu,  y = Cx + Du のもとで
%    つぎのコスト関数を最小化します。
%
%          J = Integral {y'Qy + u'Ru + 2*y'Nu} dt
%
%  * SYS が離散時間システムの場合、u[n] = -Kx[n] は、対象とするシステム
%    ダイナミックス x[n+1] = Ax[n] + Bu[n],   y[n] = Cx[n] + Du[n] のも
%    とで、つぎのコスト関数を最小化します。
% 
%          J = Sum {y'Qy + u'Ru + 2*y'Nu}
%                
% 行列 N は、省略するとゼロに設定します。代数Riccati方程式の解 S と
% 閉ループの固有値 E = EIG(A-B*K) も出力されます。
%
% 参考 : LQR, DLQR, LQGREG, CARE, DARE.


%   J.N. Little 7-11-88
%   Revised: 7-18-90 Clay M. Thompson, P. Gahinet 7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
