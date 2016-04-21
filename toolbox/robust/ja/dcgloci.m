% DCGLOCI   離散系の特性ゲイン/位相周波数応答
%
% DCGLOCI(A,B,C,D,Ts)、または、DCGLOCI(SS_,Ts)は、つぎの周波数関数
%                                                 -1
%                             G(w) = C(exp(jwT)I-A) B + D
%
% の複素行列の特性ゲイン/位相のBodeプロットを作成します。特性ゲイン/位相
% は、Bodeゲイン応答のMIMOシステムへの拡張です。周波数領域とポイント数は、
% 自動的に選択されます。正方システムに対して、DCGLOCI(A,B,C,D,'inv')は、
% 逆システムの複素行列の特性ゲイン/位相を出力します。
%	                  -1                    -1      -1
%	                 G (w) = [ C(exp(jwT)I-A) B + D ]
%
% DCGLOCI(A,B,C,D,Ts,W)、または、DCGLOCI(A,B,C,D,Ts,W,'inv')は、ユーザが
% 周波数ベクトルWを与えることができます。周波数ベクトルWは、特性ゲイン/
% 位相が評価されるラジアン/秒単位の周波数を含まなければなりません。ナイ
% キスト周波数(pi/Ts)よりも大きい周波数では、エリアシングが起こります。
% 
% 左辺引数を設定して実行したとき
%		[CG,PH,W] = DCGLOCI(A,B,C,D,Ts,...)
% は、周波数ベクトルWと、length(W)行MIN(NU,NY)列の行列CG,PHを出力します。
% ここで、NUは入力数、NYは出力数です。スクリーン上にプロットは行われませ
% ん。特性ゲイン/位相は、降順に出力されます。
% 
% 参考：LOGSPACE, SEMILOGX, DNICHOLS, DNYQUIST, DBODE.



% Copyright 1988-2002 The MathWorks, Inc. 
