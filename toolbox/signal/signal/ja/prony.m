% PRONY は、時間領域IIRフィルタ設計のためのProny法です。
%
% [B,A] = PRONY(H, NB, NA)は、ベクトル H 内のインパルス応答を使って、分
% 子の次数 NB と分母の次数 NA をもつフィルタを求めます。PRONY は、長さ 
% NB+1 および NA+1 のフィルタ係数を行ベクトル B および A にそれぞれ出力
% します。フィルタ係数は、Z の次数の降順です。 H は、実数でも複素数でも
% 構いません。
%
% 指定される最大次数が、Hの長さより大きい場合、H は、ゼロ点で埋められ
% ます。
%
% 参考：   STMCB, LPC, BUTTER, CHEBY1, CHEBY2, ELLIP, INVFREQZ.



%   Copyright 1988-2002 The MathWorks, Inc.
