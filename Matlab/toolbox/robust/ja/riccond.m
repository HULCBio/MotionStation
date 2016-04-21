% RICCOND   連続系のRiccaci方程式の条件数
%
% [TOT] = RICCOND(A,B,QRN,P1,P2)は、Arnold と Laub の概念(1984)を使って、
% Riccati方程式の条件数を求めます。
%
%    入力:
%
%      システム: (A,B)行列、重み行列QRN = [Q N;N' R];
%      Riccati方程式の解: P1,P2 (P = P2/P1)
%
%    出力:
%
%         TOT = [norAc norQc norRc conr conP1 conArn conBey res]
%     ここで		                   -1            -1
%        norAc, norQc, norRc ----- Ac=(A-BR N'), Qc=(Q-NR N'), Rc = B/R*B'
%                                  のF-ノルム
%        conr                ----- Rの条件数
%        conP1               ---- P1の条件数
%        conArn              ---- Arnold と Laub の Riccati方程式の条件数
%        conBey              ---- ByersのRiccati方程式の条件数
%        res                 ---- Riccati方程式の残差
%



% Copyright 1988-2002 The MathWorks, Inc. 
