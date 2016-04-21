% NORM   LTIシステムのノルム
%
%
% NORM(SYS) は、LTIモデル SYS のインパルス応答の2乗平均、または、等価なSYS の
% H2 ノルムを求めます。
%
% NORM(SYS,2) は、NORM(SYS) と同じです。
%
% NORM(SYS,inf) は、SYS の無限大ノルムです。 すなわち、周波数応答のピークゲイン
% (MIMOの場合、最大特異値で評価されます)です。
%
% NORM(SYS,inf,TOL) は、無限大ノルムを計算するための相対精度 TOL を指定しま
% す(デフォルトは、TOL = 1e-2)。
%
% [NINF,FPEAK] = NORM(SYS,inf) は、ゲインがそのピーク値 NINF となる周波数
% FPEAK も出力します。
%
% LTIモデルの S1*...*Sp 配列 SYS に対して、NORM はサイズが [S1 ... Sp]である、
% つぎのような配列 N を出力します。 N(j1,...,jp) = NORM(SYS(:,:,j1,...,jp))
%
% 参考 : SIGMA, FREQRESP, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
