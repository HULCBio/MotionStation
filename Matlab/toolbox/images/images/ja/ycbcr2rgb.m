% YCBCR2RGB   YCbCr 値を RGB カラー空間へ変換
%   RGBMAP = YCBCR2RGB(YCBCRMAP) は、カラーマップ YCBCRMAP 内の YCbCr 
%   値を RGB カラー空間へ変換します。YCBCRMAP が M 行 3 列であり、
%   YCbCr 輝度(Y) と色差(Cb と Cr)値を列として含む場合、RGBMAP は、そ
%   れらのカラーに等価な赤、緑、青の値を含むM 行 3 列の行列です。
%
%   RGB = YCBCR2RGB(YCBCR) は、YCBCR イメージを等価なトゥルーカラーイ
%   メージ RGB に変換します。
%
%   クラスサポート
% -------------
%   入力が YCbCr イメージの場合、uint8、uint16、または、double のいず
%   れのクラスもサポートしています。出力イメージは、入力イメージと同じ
%   クラスになります。入力がカラーマップの場合、入力と出力のカラーマッ
%   プは、共にクラス double になります。
%
%   参考：NTSC2RGB, RGB2NTSC, RGB2YCBCR



%   Copyright 1993-2002 The MathWorks, Inc.  
