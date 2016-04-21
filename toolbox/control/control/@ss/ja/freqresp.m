% FREQRESP   LTIモデルの周波数応答
%
% H = FREQRESP(SYS,W) は、ベクトル W で指定される周波数でのLTIモデル 
% SYS の周波数応答 H を計算します。これらの周波数は、実数でラジアン/秒
% です。
%
% SYS が NU 入力 NY 出力で、W が NW の周波数点をもつとき、出力 H は 
% NY*NU*NW の配列になり、H(:,:,k) は周波数点 W(k) での応答を与えます。
%
% SYS が Nu 入力 NY 出力のLTIモデルの S1*...*Sp の配列のとき、
% SIZE(H) = [NY NU NW S1 ... Sp] です。ここで、NW = LENGTH(W) です。
% 
% 参考 : EVALFR, BODE, SIGMA, NYQUIST, NICHOLS, LTIMODELS.


%	 Clay M. Thompson 7-10-90
%   Revised: AFP 9-10-95, P.Gahinet 5-2-96
%	 Copyright 1986-2002 The MathWorks, Inc. 
