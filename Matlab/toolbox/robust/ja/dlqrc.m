% DLQRC は、離散最適 LQR 制御系のシンセシスを行います。
%
% [K,P,PERR] = DLQRC(A,B,QRN,ARETYPE) は、拘束条件 x(k+1) = A(k)x(k) + 
% B(k)u(k) の基で、離散の Riccati 方程式を解き、時間間隔 [i,n]で、コスト
% 関数
%             n-1
%  J(i) = 1/2 SUM { [x(k)' u(k)'] | Q  N | |x(k)| }; ( QRN := |Q  N| )
%             k=i                 | N' R | |u(k)|    (        |N' R| )
%
% を最小にするフィードバック則 u = -Kx を満たす離散最適 LQR フィードバッ
% クゲイン K を求めます。
% 
% 出力される P は、離散の ARE 
%				           -1
%		0 = A'PA - P - A'PB(R+B'PB)  B'P'A + Q
%
% を満足する定常解になります。加えて、ARE の残差も計算できます。残差が大
% きくなるような条件の悪い問題や、1に近い閉ループ極が存在する場合、ワー
% ニングメッセージが表示されます。
%
%          aretype = 'eigen' ---- 固有構造アプローチを使って Riccati を
%                                 解く(デフォルト)
%          aretype = 'schur' ---- Schurベクトルアプローチを使って Ricc-
%                                 ati を解く
%

% Copyright 1988-2002 The MathWorks, Inc. 
