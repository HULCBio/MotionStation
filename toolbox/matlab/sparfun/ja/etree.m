% ETREE  ツリーの消去
% 
% p = ETREE(A) は、上三角部分が A の上三角部分である正方対称行列に対し
% て、消去されるツリーを出力します。p(j) はツリー内のj列の親で、j が
% ルートの場合は0です。
%
% p = ETREE(A,'col') は、A'*A の消去ツリーを出力します。
% p = ETREE(A,'sym') は、p = ETREE(A) と同じです。
%
% [p,q] = ETREE(...) は、ツリーのpostorder置換 q も出力します。
%
% 参考：TREELAYOUT, TREEPLOT, ETREEPLOT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:37 $
