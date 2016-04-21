%CGAUWAVF 複素 Gaussian ウェーブレット
%   [PSI,X] = CGAUWAVF(LB,UB,N,P) は、[LB,UB] の区間で、N 点の等間隔のグ%   リッド上で、Gaussian 関数 F = Cp*exp(-i*x)*exp(-x^2) の P 階の微分係%   数の値を出力します。ここで、Cp は、F = 1のときの P 階の微分係数の2ノ%   ルムになります。P は、1から8の範囲整数値です。
%
%   出力引数は、グリッド X 上で計算されるウェーブレット関数 PSI になりま%   す。[PSI,X] = CGAUWAVF(LB,UB,N) は [PSI,X] = CGAUWAVF(LB,UB,N,1) と
%   等価です。
%
%   このウェーブレットの効果的なサポートの範囲は、[-5 5] です。
%
%   ----------------------------------------------------
%   Extended Symbolic Toolbox を使う場合、 P > 8 の値が
%   指定できます。
%   ----------------------------------------------------
%
%   参考: GAUSWAVF, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jun-99.


%   Copyright 1995-2002 The MathWorks, Inc.
