% GAUSWAVF 　　Gaussianウェーブレット
% [PSI,X] = GAUSWAVF(LB,UB,N,P) は、[LB,UB] の区間で、N 点の等間隔のグリ% ッド上で、Gaussian関数 F = Cp*exp(-x^2) の P 階の微分係数の値を出力し
% ます。ここで、Cp は、F = 1のときの P 階の微分係数の2ノルムになります。% Pは、1から8までの整数値です。
%
% 出力引数はグリッド X 上で計算されるウェーブレット関数 PSI になります。% [PSI,X] = GAUSWAVF(LB,UB,N) は、[PSI,X] = GAUSWAVF(LB,UB,N,1) と等価で% す。
%
% このウェーブレットの効果的なサポートの範囲は、[-5 5] です。
%
%   ----------------------------------------------------
%   Extended Symbolic Toolbox を使う場合、 P > 8 の値が
%   指定できます。
%   ----------------------------------------------------
%
% 参考： WAVEINFO.



%   Copyright 1995-2002 The MathWorks, Inc.
