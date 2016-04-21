% CGLOCI   連続系の特性ゲイン/位相周波数応答
% CGLOCI(A,B,C,D)、または、CGLOCI(SS_)は、つぎの周波数関数
%                                       -1
%                        G(jw) = C(jwI-A) B + D
% の複素行列の特性ゲイン/位相のBodeプロットを作成します。特性ゲイン軌跡
% は、Bodeゲイン応答のMIMOシステムへの拡張です。周波数領域とポイント数は、
% 自動的に選択されます。正方システムに対して、CGLOCI(A,B,C,D,'inv')は、
% つぎに示す逆システムの複素行列の特性ゲイン/位相を出力します。
%	     -1               -1      -1
%           G (jw) = [ C(jwI-A) B + D ]
%
% CGLOCI(A,B,C,D,W)、または、CGLOCI(A,B,C,D,W,'inv')は、ユーザが周波数ベ
% クトルWを与えることができます。周波数ベクトルWは、特性ゲイン/位相応答
% が評価されるラジアン/秒単位の周波数を含まなければなりません。
% 左辺引数を設定して実行したとき
%		[CG,PH,W] = CGLOCI(A,B,C,D,...)
% は、周波数ベクトルWと、length(W)行MIN(NU,NY)列の行列CG,PHを出力します。
% ここで、NUは入力数、NYは出力数です。スクリーン上にプロットは行われませ
% ん。特性ゲインは、降順に出力されます。
%
% 参考  : LOGSPACE, SEMILOGX, NICHOLS, NYQUIST, BODE.



% Copyright 1988-2002 The MathWorks, Inc. 
