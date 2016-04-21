% TSEARCH   最近傍の三角形検索
% 
% T = TSEARCH(X,Y,TRI,XI,YI) は、点 (XI(k),YI(k)) に対して囲んだ三角形が
% TRI(T(k),:) であるような、XI, YI 内の点に対する囲んだDelaunay三角形の
% インデックスを出力します。TSEARCH は、凸包の外部のすべての点に対しては、
% NaNを出力します。DELAUNAY から得られる点 X, Y の三角形分割TRIが必要です。
%
% 参考：DELAUNAY, DSEARCH, QHULL, TSEARCHN, DELAUNAYN.


%   Clay M. Thompson 8-15-95
%   Copyright 1984-2004 The MathWorks, Inc. 