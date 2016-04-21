% SPH2CART   球面座標からCartesian座標への変換
% 
% [X,Y,Z] = SPH2CART(TH,PHI,R) は、球面座標(方位角 TH、仰角 PHI､半径 R)に
% 格納されたデータの対応する要素を、Cartesian座標X, Y, Z に変換します。
% 配列 TH, PHI, R は、同じサイズでなければなりません(または、いずれかが
% スカラでなければなりません)。TH と PHI は、ラジアン単位でなければなり
% ません。
%
% TH は、正のx軸から測定されたxy平面での左回りの角度です。PHI は、xy平面
% からの仰角です。
%
% 参考：CART2SPH, CART2POL, POL2CART.


%   L. Shure, 4-20-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:31 $
