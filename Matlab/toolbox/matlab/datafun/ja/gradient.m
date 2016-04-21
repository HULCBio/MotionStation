% GRADIENT   勾配近似
% 
% [FX,FY] = GRADIENT(F)は、行列Fの数値勾配を出力します。FXは、x(列)方向
% の差分dF/dxに対応します。FYは、y(行)方向の差分dF/dyに対応します。各方
% 向の間隔は、1と仮定します。Fがベクトルのとき、DF = GRADIENT(F)は1次元
% の勾配です。
%
% [FX,FY] = GRADIENT(F,H)は、Hがスカラのとき、各方向での間隔として使いま
% す。
%
% [FX,FY] = GRADIENT(F,HX,HY)は、Fが2次元のとき、HXとHYで指定された間隔
% を使います。HXとHＹは、座標間の間隔を指定するためのスカラや、点の座標
% を指定するベクトルです。HXとHYがベクトルの場合、その長さはFの対応する
% 次元と一致しなければなりません。
%
% [FX,FY,FZ] = GRADIENT(F)は、Fが3次元配列のとき、Fの数値勾配を出力しま
% す。FZは、z方向の差分dF/dzに対応します。GRADIENT(F,H)は、Hがスカラのと
% き、各方向の点間隔として使います。
%
% [FX,FY,FZ] = GRADIENT(F,HX,HY,HZ)は、HX、HY、HZで与えられた間隔を使い
% ます。 
%
% [FX,FY,FZ,...] = GRADIENT(F,...)は、FがN次元のときも同様で、N個の出力
% と、2個、または、N+1個の入力をもたなければなりません。
%
% 例題:
%       [x,y] = meshgrid(-2:.2:2, -2:.2:2);
%       z = x .* exp(-x.^2 - y.^2);
%       [px,py] = gradient(z,.2,.2);
%       contour(z),hold on, quiver(px,py), hold off
%
% 参考：DIFF, DEL2.


%   D. Chen, 16 March 95
%   Copyright 1984-2003 The MathWorks, Inc. 
