% HSV   色相-彩度-明度によるカラーマップ
% 
% HSV(M) は、HSVカラーマップを含むM行3列の行列を出力します。
% HSV は、カレントのカラーマップと同じ長さです。
%
% HSVカラーマップは、色相-彩度-明度カラーモデルの色相要素を変化させます。
% カラーは赤から始まり、黄、緑、シアン、青、マジェンタ、そして赤に戻り
% ます。このカラーマップは、周期関数の表示に特に有効です。
%
% たとえば、カレントのfigureのカラーマップをリセットするには、つぎのよう
% にします。
%
%             colormap(hsv)
%
% 参考：GRAY, HOT, COOL, BONE, COPPER, PINK, FLAG, PRISM, JET,
%       COLORMAP, RGBPLOT, HSV2RGB, RGB2HSV.


%   See Alvy Ray Smith, Color Gamut Transform Pairs, SIGGRAPH '78.
%   C. B. Moler, 8-17-86, 5-10-91, 8-19-92, 2-19-93.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:59 $
