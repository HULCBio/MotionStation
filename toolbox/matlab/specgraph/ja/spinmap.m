% SPINMAP   カラーマップの回転
% 
% SPINMAP は、約3秒間カラーマップを回転します。
% SPINMAP(T) は、約T秒間カラーマップを回転します。
% SPINMAP(inf) は、無限にカラーマップの回転を行い、中断するためには
% <ctrl-C>を入力します。
% SPINMAP(T,inc) は、指定した inc に基づいた速度で回転します。デフォルトは
% inc = 2 なので、inc = 1 はより遅い回転、inc = 3 はより速い回転、inc = -2
% は逆の方向の回転になります。
%
% 書き直しの反復を避けるためには、set(gcf,'sharecolors','off')や
% set(gcf,'renderer','painters') を設定してください。
%
% 参考：COLORMAP, RGBPLOT.


%   Copyright 1984-2002 The MathWorks, Inc. 
