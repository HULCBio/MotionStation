% TREELAYOUT   treeやforestのレイアウト
% 
% [x,y,h,s] = treelayout(parent,post)
% 
% parent は、親ポインタのベクトルで、ルートに対しては0です。
% post は、ツリーノード上のpostorder置換です(post が省略されれば、
% 計算します)。
% x と y は、適切な図を作成するために、tree のノードをレイアウトする
% 単位長さの正方形内の座標ベクトルです。オプションで、h は tree の高さ
% で、s はトップレベルのセパレータの頂点の数です。
%
% 参考：ETREE, TREEPLOT, ETREEPLOT, SYMBFACT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:44 $
