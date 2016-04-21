% ARESOLV   連続系代数Riccati方程式を解く(eigen & schur)
%
% [P1,P2,LAMP,PERR,WELLPOSED,P] = ARESOLV(A,Q,R,ARETYPE)は、つぎの代数
% Riccati方程式の解を計算します。
%
%                     A'P + PA - PRP + Q = 0
%
% "aretype"により、つぎのうちの1つを選択します。
%
%                aretype = 'eigen' ---- 固有構造アプローチ
%                aretype = 'schur' ---- Schurベクトルアプローチ
%
% 出力:   P = P2/P1 Riccati方程式の解
%         [P1;P2] ハミルトニアン [A,-R;-Q,-A']の安定な固有空間
%         LAMP 閉ループ固有値
%         PERR 残差誤差行列
%         WELLPOSED = ハミルトニアンが虚軸に固有値をもたなければ'TRUE'、
%         そうでなければ'FALSE'



% Copyright 1988-2002 The MathWorks, Inc. 
