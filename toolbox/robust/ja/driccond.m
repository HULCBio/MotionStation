% DRICCOND は、離散 Riccati 条件数を計算します。
%
% [TOT] = DRICCOND(A,B,Q,R,P1,P2)は、Arnold と Laubの概念(1984)を使って、
% Riccati方程式の条件数を求めます。
%
% 入力:
%
%      システム: (A,B)行列、重み行列Q, R
%      Riccati方程式の解: P1,P2 (P = P2/P1)
%
% 出力:
%
%         TOT = [norA norQ norR conr conP1 conArn conBey res]
%     ここで、                         -1
%        norA, norQ, norR ----- A, Q, BR B'のFノルム
%        conr ----- Rの条件数
%        conP1 ---- P1の条件数
%        conArn --- Arnold と Laub のRiccati条件数
%        conBey --- ByersのRiccati条件数
%        res ------ Riccati方程式の残差
%
%



% Copyright 1988-2002 The MathWorks, Inc. 
