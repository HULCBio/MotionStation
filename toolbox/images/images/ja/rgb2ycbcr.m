% RGB2YCBCR   RGB 値を YCBCR カラー空間に変換
%   YCBCRMAP = RGB2YCBCR(RGBMAP) は、RGBMAP の RGB 値を YCBCR カラー空
%   間へ変換します。YCBCRMAP は、YCBCR の各列に輝度(Y)と色差(CbとCr)カ
%   ラー値を含む M 行3列の行列です。各行は、RGB カラーマップの対応する
%   行と等価なカラーを表します。
%
%   YCBCR = RGB2YCBCR(RGB) は、トゥルーカラーイメージ RGB を YCBCR カ
%   ラー空間での等価なイメージへ変換します。
%
%   クラスサポート
% -------------
%   入力が RGB イメージの場合、uint8、uint16、または、double のいずれ
%   のクラスもサポートしています。出力イメージは、入力イメージと同じク
%   ラスになります。入力がカラーマップの場合、入力と出力のカラーマップ
%   は、共にクラス double になります。
%
%   参考：NTSC2RGB, RGB2NTSC, YCBCR2RGB.



%   Copyright 1993-2002 The MathWorks, Inc.  
