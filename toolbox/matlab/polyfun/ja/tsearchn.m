% TSEARCHN  N-次元最近傍の三角形探索
% 
% T = TSEARCHN(X,TES,XI) は、XI 内の各点に対して囲んだDelaunay三角形
% TES のシンプレックスのインデックス T を出力します。X は、m行n列行列で、N
% 次元空間のm点を表わします。XI は、p行n列行列で、N次元空間のp点を表わし
% ます。TSEARCHN は、X の凸包の外側のすべての点に対してNaNを出力しま
% す。TSEARCHN は、DELAUNAYN から得られる点 X の三角形 TESを必要とし
% ます。

% [T, P] = TSEARCHN(X,TES,XI) は、シンプレックス TES 内のXI の重心座標 
% P も出力します。P は、p行n+1列の行列です。P の各行は、XI 内の対応
% する点の重心座標です。これは、内挿に役立ちます。
%
% 参考：DSEARCHN, TSEARCH, QHULL, GRIDDATAN, DELAUNAYN.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 02:02:03 $
