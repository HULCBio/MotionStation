% RGB2HSV   RGB(赤-緑-青)カラーマップをHSV(色相-彩度-値)に変換
% 
% H = RGB2HSV(M) は、RGBカラーマップをHSVカラーマップに変換します。各
% マップは､任意の行数をもつ3列の行列で、要素は0から1の区間の値です。
% 入力行列 M の列は、それぞれ赤、緑、青の強度を表わします。出力行列 H 
% の列は、それぞれ色相、彩度、値を表わします。
%
% HSV = RGB2HSV(RGB) は、RGBイメージ RGB(3次元配列)を、等価なHSVイメージ
% HSV(3次元配列)に変換します。
%
% クラスサポート
% --------------
% 入力がRGBイメージの場合は、これは、uint8, uint16, doubleのいずれでも
% 構いません。そして、出力イメージは、クラスdoubleになります。入力が
% カラーマップの場合は、入力と出力のカラーマップは共にdoubleです。
% 
% 参考：HSV2RGB, COLORMAP, RGBPLOT. 


%   See Alvy Ray Smith, Color Gamut Transform Pairs, SIGGRAPH '78.
%   C. B. Moler, 8-17-86, 5-10-91, 2-2-92.
%      revised by C. Griffin for uint8 inputs 7-26-96
%      revised by P. Gravel for faster execution and less memory
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:30 $
