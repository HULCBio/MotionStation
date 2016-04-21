% DSEARCH 最近傍を用いたDelaunay三角分割の検索
% 
% K = DSEARCH(X,Y,TRI,XI,YI) は、データ点 (xi,yi) の最近傍のデータ点 
% (x,y) のインデックスを出力します。DSEARCH には、DELAUNAY から得られた
% データ点 X, Y からなる三角形分割 TRI が必要です。
%
% K = DSEARCH(X,Y,TRI,XI,YI,S) は、毎回計算する代わりに、スパース行列 
% S を使います。
% 
%    S = sparse(tri(:,[1 1 2 2 3 3]),tri(:,[2 3 1 3 1 2]),1,nxy,nxy) 
%
% ここで、nxy = prod(size(x)) です。
%
% 参考：TSEARCH, DELAUNAY, VORONOI.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:01:23 $
