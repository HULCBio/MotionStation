% NTSC2RGB   NTSC 値を RGB カラー空間に変換
%   RGBMAP = NTSC2RGB(YIQMAP) は、カラーマップ YIQMAP 内の M 行 3 列の
%   NTSC(テレビ)カラー値を RGB カラー空間に変換します。YIQMAP は M 行
%   3 列で、列方向に NTSC の輝度(Y)と色差(I と Q)のカラー要素を含んで
%   いる場合 RGBMAP はそれらのカラーと等価の赤、緑、青の値を含む M 行
%   3 列の行列になります。RGBMAP と YIQMAP は共に、0.0から1.0の間に入
%   る強度値を含んでいます。解像度 0.0 は成分が全くないことを意味し、
%   解像度 1.0 はその成分で満たされていることを意味しています。
%
%   RGB = NTSC2RGB(YIQ) は、NTSC イメージ YIQ を等価なトゥルーカラーイ
%   メージ RGB に変換します。
%
%   クラスサポート
% -------------
%   入力イメージ、または、カラーマップは、クラス double でなければなり
%   ません。出力は、クラス double です。
%
%   参考：RGB2NTSC, RGB2IND, IND2RGB, IND2GRAY



%   Copyright 1993-2002 The MathWorks, Inc.  
