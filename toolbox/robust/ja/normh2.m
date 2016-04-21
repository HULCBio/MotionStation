% NORMH2   連続系H2ノルムの計算
%
% [NMH2] = NORMH2(A,B,C,D)、または、[NMH2] = NORMH2(SS_)は、与えられた状態
% 空間実現のH2ノルムを計算します。システムが厳密にプロパでなければ、INFが
% 出力されます。そうでなければ、H2ノルムは、つぎのように計算されます。
%
%            NMH2 = trace[CPC']^0.5 = trace[B'QB]^0.5
%
% ここで、Pは、可制御性グラミアンで、Qは、可観測性グラミアンです。



% Copyright 1988-2002 The MathWorks, Inc. 
