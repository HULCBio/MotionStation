% CART2SPH   Cartesian座標から球面座標への変換
% 
% [TH,PHI,R] = CART2SPH(X,Y,Z) は、Cartesian座標 X, Y, Z に格納された
% データの対応する要素を、球面座標(方位角 TH、仰角 PHI、半径 R)に変換
% します。配列 X, Y, Z は、同じサイズでなければなりません(または、いずれ
% かがスカラでも構いません)。TH と PHI は、ラジアン単位で出力されます。
%
% TH は、正のx軸から測定されたxy平面での左回りの角度です。PHI は、
% xy平面からの仰角です。
%
% 参考：CART2POL, SPH2CART, POL2CART.


%   L. Shure, 4-20-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:02 $
