% DCLXBODE   離散複素周波数応答(SIMO)
%
% [G] = DCLXBODE(SS_,IU,W,TS)、または、
% [G] = DCLXBODE(A,B,C,D,IU,W,TS) は、システム
% 
%			x[n+1] = Ax[n] + Bu[n]	                -1
%			y[n]   = Cx[n] + Du[n]	   G(z) = C(zI-A) B + D
%
% の入力 iu からの周波数応答を計算します。ベクトル W は、Bode 応答を計算
% する周波数点をラジアンで表したものです。DCLBODE は、出力 y と同数の列
% をもち、LENGTH(W) と同じ行数をもつ行列 MAG と PHASE(度単位) を出力しま
% す。
%

% Copyright 1988-2002 The MathWorks, Inc. 
