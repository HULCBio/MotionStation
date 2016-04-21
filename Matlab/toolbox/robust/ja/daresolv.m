% DARESOLV   離散代数Riccati方程式を解く(eigen & schur) 
%
% [P1,P2,LAMP,PERR,WELLPOSED,P] = DARESOLV(A,B,Q,R,ARETYPE)は、つぎの離
% 散代数 Riccati方程式の解を計算します。
%                                   -1
%            A'PA - P - A'PB(R+B'PB)  B'PA + Q = 0
%
% "aretype"によって、つぎのうちの1つを選択します。
%
%                aretype = 'eigen' ---- 固有構造アプローチ
%                aretype = 'schur' ---- Schurベクトルアプローチ
%                aretype = 'dare'  ---- Control System Toolbox DARE
% 
% 出力:      P = P2/P1 Riccati方程式の解
%             [P1;P2] ハミルトニアンの安定な固有空間
%             LAMP 閉ループ固有値
%             PERR 残差誤差関数
%             WELLPOSED = ハミルトニアンが虚軸に固有値をもたなければ
%                         'TRUE '、そうでなければ'FALSE'。



% Copyright 1988-2002 The MathWorks, Inc. 
