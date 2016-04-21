% CART2POL   Cartesian座標から極座標への変換
% 
% [TH,R] = CART2POL(X,Y) は、Cartesian座標 X, Y に格納されたデータの対応
% する要素を、極座標(角度 TH と半径 R)に変換します。配列 X と Y は、
% 同じサイズでなければなりません(または、いずれかがスカラでも構いません)。
% TH は、ラジアン単位で出力されます。
%
% [TH,R,Z] = CART2POL(X,Y,Z) は、Cartesian座標X, Y ,Z に格納されたデータ
% の対応する要素を、円筒座標(角度 TH、半径 R、高さ Z)に変換します。配列 
% X, Y, Z は同じサイズでなければなりません(または、いずれかがスカラでも
% 構いません)。TH は、ラジアン単位で出力されます。
%
% 参考：CART2SPH, SPH2CART, POL2CART.


%   L. Shure, 4-20-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:01 $
