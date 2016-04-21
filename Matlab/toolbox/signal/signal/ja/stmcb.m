% STMCB は、Steiglitz-McBride 反復法を使って、線形モデルを計算します。
%
% [B,A] = stmcb(H,NB,NA) は、インパルス応答 H を NA 個の極、NB 個の零点
% をもつシステム B(Z)/A(Z) で近似したシステムの係数をもちます。
%
% [B,A] = stmcb(H,NB,NA,N) は、N 回の反復を行います。N のデフォルトは5で
% す。
%
% [B,A] = stmcb(H,NB,NA,N,Ai) は、分母係数の初期推定値としてベクトル Ai 
% を使用します。Ai を設定しない場合、STMCB は、[B,Ai] = PRONY(H,0,NA)の
% 出力引数をベクトル Ai として使用します。
%
% [B,A] = STMCB(Y,X,NB,NA,N,Ai) は、入力としてXが与え、出力として Y をも
% つシステムのシステム係数 B および A を求めます。NとAiは、N = 5, [B,Ai]
% = PRONY(Y,0,NA)のデフォルト値を使って、求めます。
%
% 参考：   PRONY, LEVINSON, LPC, ARYULE.



%   Copyright 1988-2002 The MathWorks, Inc.
