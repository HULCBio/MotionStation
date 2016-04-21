% FREQRESP   LTI モデルの周波数応答を計算
%
%
% H = FREQRESP(SYS,W) は、ベクトル W で指定される周波数での LTI モデル SYS
% の周波数応答 H を計算します。これらの周波数は、実数でラジアン/秒です。
%
% SYS が NU 入力 NY 出力で、W が NW の周波数点をもつとき、出力 H は
% NY*NU*NW の配列になり、H(:,:,k) は周波数点 W(k) での応答を与えます。
%
% SYS が Nu 入力 NY 出力をもつLTIモデルの S1*...*Sp 配列のとき、
% SIZE(H) = [NY NU NW S1 ... Sp] です。 ここで、NW = LENGTH(W) です。
%
% 参考 : EVALFR, BODE, SIGMA, NYQUIST, NICHOLS, LTIMODELS


% Copyright 1986-2002 The MathWorks, Inc.
