%DELAUNAY Delaunay 三角形分割
% TRI = DELAUNAY(X,Y) は、三角形の外接円にデータ点が含まれないような、
% 三角形の集合を出力します。M行3列の行列 TRI の各行は 1つの三角形を
% 定義し、ベクトル X と Y のインデックスを含んでいます。 三角形が計算
% できない(オリジナルデータが一直線上に存在、または X が空などの)場合は、
% 空行列が戻されます。
%
% DELAUNAY は、Qhull を使用します。
%
% TRI = DELAUNAY(X,Y,OPTIONS) は、DELAUNAYN により Qhull のオプションとして
% 使用されるように、文字列 OPTIONS のセル配列を指定します。デフォルトの
% オプションは、{'Qt','Qbb','Qc'} です。
% OPTIONS が [] の場合、デフォルトのオプションが使用されます。
% OPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
% Qhull とそのオプションについての詳細は、http://www.qhull.org. を
% 参照してください。
%
% 例題:
%   x = [-0.5 -0.5 0.5 0.5];
%   y = [-0.5 0.5 0.5 -0.5];
%   tri = delaunay(x,y,{'Qt','Qbb','Qc','Qz'})
%
% Delaunay三角形は、GRIDDATA (散布しているデータを内挿), CONVHULL, 
% VORONOI (VORONOIダイアグラムを計算)と共に使われ、散布しているデータ
% 点に対して、三角グリッドを作成するために有効です。
%
% 関数 DSEARCH と TSEARCH は、それぞれ、最も近傍のデータ点や囲んだ三角形
% を求めるための三角形分割を検索します。
%   
% 参考 VORONOI, TRIMESH, TRISURF, TRIPLOT, GRIDDATA, CONVHULL
%      DSEARCH, TSEARCH, DELAUNAY3, DELAUNAYN, QHULL.

%   Copyright 1984-2003 The MathWorks, Inc.
