% CHECKERBOARD 　Checkerboard イメージの作成
% I = CHECKERBOARD は、一辺が10ピクセルをもつ正方形から構成されるChec-
% kerboardイメージを作成します。この左半分は、明るい正方形は白、右半分
% の明るい正方形はグレーです。
%
% I = CHECKERBOARD(N) は、個々の正方形が、一辺 N ピクセルをもつChecker-
% boardを作成します。
%
% I = CHECKERBOARD(N,P,Q) は、長方形のCheckerboardを作成します。TILE の
% P 行、Q 列が存在します。ここで、TILE = [DARK LIGHT; LIGHT DARK] を表し
% DARK と LIGHT は、一辺が N ピクセルをもつ正方形です。Q を省略すると、
% デフォルトで、P を使い、Checkerboardは正方形になります。
%
% 関数 CHECKERBOARD は、幾何学的演算に対するテストイメージを作成するため
% に、有効なものです。
%   
% 例題s
%   --------
%       I = checkerboard(20);
%       imshow(I)
%
%       J = checkerboard(10,2,3);
%       figure, imshow(J)
%
%       K = (checkerboard > 0.5); % 黒白のCheckerboardを作成
%       figure, imshow(K)
%
% 参考： CP2TFORM, IMTRANSFORM, MAKETFORM.



%   Copyright 1993-2002 The MathWorks, Inc. 
