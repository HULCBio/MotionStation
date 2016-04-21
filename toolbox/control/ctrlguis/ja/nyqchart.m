% NYQCHART   Nyquistのグリッドを生成(M と N の円)
%
% [GRIDHANDLES,TEXTHANDLES] = NYQCHART(AX) は、座標軸 AX 内にNyquistの
% グリッドをプロットします。NYQCHART は、現在の座標軸の範囲を使用します。
%
% [GRIDHANDLES,TEXTHANDLES] = NYQCHART(AX,OPTIONS) は、付加的なグリッド
% オプションを指定します。OPTION は、以下のフィールドをもつ構造体です。:
%     * MagnitudeUnits  : 'abs' または dB'
%     * FrequencyUnits: 'rad/sec' または 'Hz' (デフォルト = rad/sec)
%     * Zlevel        : 実数のスカラ (デフォルト = 0)
%
% 参考 : NYQUIST.


%   Authors: Adam W. DiVergilio, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/06/26 16:07:08 $
