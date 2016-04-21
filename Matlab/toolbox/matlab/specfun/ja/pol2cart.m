% POL2CART   極座標からCartesian座標への変換
% 
% [X,Y] = POL2CART(TH,R) は、極座標(角度 TH、半径 R)に格納されたデータの
% 対応する要素を、Cartesian座標 X, Y に変換します。配列 TH と R は、同じ
% サイズでなければなりません(または、いずれかがスカラでも構いません)。
% TH は、ラジアン単位でなければなりません。
%
% [X,Y,Z] = POL2CART(TH,R,Z) は、円筒座標(角度 TH、半径 R、高さ Z)に
% 格納されたデータの対応する要素を、Cartesian座標X, Y, Z に変換します。
% 配列 TH, R, Z は同じサイズでなければなりません(またはいずれかがスカラ
% でも構いません)。TH は、ラジアン単位でなければなりません。
%
% 参考：CART2SPH, CART2POL, SPH2CART.


%   L. Shure, 4-20-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:25 $
