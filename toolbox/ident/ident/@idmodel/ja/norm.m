%NORM は、IDMODEL のノルムを計算します。
%   Control Systems Toolbox が必要です。
%
%   NORM(MOD) は、IDMODEL オブジェクト MOD のインパルス応答の平方根で、
%   MOD の H2 ノルムに相当します。
%
%   NORM(MOD,2) は、NORM(MOD) と同じです。
%
%   NORM(MOD,inf) は、MOD の無限大ノルムで、周波数応答のピークゲインです。
%   MIMO システムの場合、最大特異値を意味します。
%
%   NORM(MOD,inf,TOL) は、無限大ノルムを計算するための相対精度 TOL を指
%   定します。デフォルトは、TOL=1e-2 です。
%       
%   [NINF,FPEAK] = NORM(MOD,inf) は、ゲインが最大値 NINF となる周波数
%   FPEAK も同時に出力します。
%
%   デフォルトで、MOD の観測入力のみが計算のために利用されます。ノイズ入
%   力からの影響も含めるためには、あらかじめ NOISECNV を利用して変換して
%   おかなければいけません。
%
%   参考:  SIGMA, FREQRESP



%   Copyright 1986-2001 The MathWorks, Inc.
