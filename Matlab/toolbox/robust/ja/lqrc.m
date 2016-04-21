% LQRC は、連続最適 LQR 制御系のシンセシスを行います。
%
% [K,P,P1,P2] = LQRC(A,B,QRN,ARETYPE)  は、拘束条件 dx/dt = Ax + Bu の基で、
% Riccati 方程式を解き、コスト関数
%
%       J = 1/2 Integral { [x' u'] | Q  N | |x| } dt ; ( QRN := |Q  N| )
%                                  | N' R | |u|        (        |N' R| )
% 
% を最小にするフィードバック則 u = -Kx を満たす最適 LQR フィードバックゲイ
% ン K を求めます。
% 
% 出力される P は、ARE
%                                     -1
%		0 = A'P + PA - (PB+N)R  (B'P+N') + Q
%
% を満足する定常解になります。加えて、ARE の残差も計算できます。残差が大き
% くなるような条件の悪い問題や、jw 軸に近い閉ループ極が存在する場合、ワー
% ニングメッセージが表示されます。
%
%          aretype = 'eigen' ---- 固有構造アプローチを使って Riccati を解
%                                 く(デフォルト)
%          aretype = 'schur' ---- Schurベクトルアプローチを使って Riccati 
%                                 を解く
%

% Copyright 1988-2002 The MathWorks, Inc. 
