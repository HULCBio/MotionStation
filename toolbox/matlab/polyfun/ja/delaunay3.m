%DELAUNAY3  3次元のDelaunay分割
%
% T = DELAUNAY3(X,Y,Z) は、四面体の周りの球面に含まれない X のデータ点
% からなる四面体の集合を出力します。T は、num 行4列の配列です。T の各行の
% 要素は、(X,Y,Z) のモザイク内で四面体を形作る点(X,Y,Z)の点のインデックス
% です。三角形が計算できない(オリジナルデータが一直線上に存在、または X 
% が空などの)場合は、空行列が出力されます。
%
% DELAUNAY3 は、Qhull を使用します。 
%
% T = DELAUNAY3(X,Y,Z,OPTIONS) は、DELAUNAY3 により Qhull のオプションとして
% 使用されるように、文字列 OPTIONS のセル配列を指定します。デフォルトの
% オプションは、{'Qt','Qbb','Qc'} です。
% OPTIONS が [] の場合、デフォルトのオプションが使用されます。
% OPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
% Qhull のオプションについての詳細は、http://www.qhull.org. を
% 参照してください。
%
% 例題:
%   X = [-0.5 -0.5 -0.5 -0.5 0.5 0.5 0.5 0.5];
%   Y = [-0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5];
%   Z = [-0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5];
%   T = delaunay3( X, Y, Z, {'Qt', 'Qbb', 'Qc', 'Qz'} )
%
% 参考 QHULL, DELAUNAY, DELAUNAYN, GRIDDATA3, GRIDDATAN,
%      VORONOIN, TETRAMESH.

%   Copyright 1984-2003 The MathWorks, Inc.
