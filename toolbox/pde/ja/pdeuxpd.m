% PDEUXPD は、解 u をノード点に展開
% U = PDEUXPD(P,U) は、点行列 P で定義されるノード点にスカラ値 U を展開
% します。
% 
% U は、x と y の関数として、スカラ、または、文字列で書かれています。
%
% U = PDEUXPD(P,U,N) は、次元 N (デフォルトは1)をもつシステム用に U をノ
% ード点に展開します。
%
% PDEUXPD は、長さ N * size(P,2) の列ベクトルとして、展開された U を出力
% します。

%       Copyright 1994-2001 The MathWorks, Inc.
