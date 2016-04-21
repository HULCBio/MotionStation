% RGB2NTSC   RGB 値を NTSC カラー空間に変換
%   YIQMAP = RGB2NTSC(RGBMAP) は、RGBMAP 内の M 行3列の RGB 値を NTSC
%   カラー空間へ変換します。YIQMAP は、各列に RGBカラーマップのカラー
%   と等価な輝度(Y)、色差(I,Q)をもつ M 行3列の行列です。
%
%   YIQ = RGB2NTSC(RGB) は、トゥルーカラーイメージ RGB を等価な NTSC 
%   イメージ YIQ に変換します。
%
%   クラスサポート
% -------------
%   入力が RGB イメージの場合、uint8、uint16、または、double のいずれ
%   のクラスもサポートしています。出力イメージは、クラス double です。
%   入力がカラーマップの場合、入力と出力のカラーマップは共にクラス 
%   double になります。
%
%   参考：NTSC2RGB, RGB2IND, IND2RGB, IND2GRAY



%   Copyright 1993-2002 The MathWorks, Inc.  
