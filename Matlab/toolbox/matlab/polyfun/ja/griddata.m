%GRIDDATA データのグリッド化とサーフェスの適合
% 
% ZI = GRIDDATA(X,Y,Z,XI,YI) は、(通常)一様間隔でないベクトル (X,Y,Z) の
% データに、Z = F(X,Y) 型のサーフェスを適合させます。GRIDDATA は、ZI を
% 作成するために、(XI,YI) で指定される点でこのサーフェスを補間します。
% サーフェスは、必ずデータ点を通ります。XI と YI は、通常(MESHGRIDで作成
% されるような)一様間隔のグリッドで、そのため、GRIDDATA と名付けられて
% います。
%
% XI は、行ベクトルでも構いません。この場合、列要素が一定の値である行列と
% 考えられます。同様に、YI は列ベクトルでも構わず、行要素が一定の値である
% 行列と考えられます。
%
% [XI,YI,ZI] = GRIDDATA(X,Y,Z,XI,YI) は、この方法で作成された XI と YI も
% 出力します([XI,YI] = MESHGRID(XI,YI) の結果)。
%
% [...] = GRIDDATA(X,Y,Z,XI,YI,METHOD) は、METHOD がつぎのうちのいずれか
% のとき、データに対するサーフェスの近似のタイプを定義します。
% 
%     'linear'    - 三角形ベースの線形補間(デフォルト)
%     'cubic'     - 三角形ベースのキュービック補間
%     'nearest'   - 最近傍点による補間
%     'v4'        - MATLAB 4のgriddataの手法
% 'cubic' と 'v4' は、滑らかなサーフェスを作成します。一方、'linear' 
% と 'nearest' は、それぞれ、1次導関数と0次導関数における不連続性をもち
% ます。'v4' 以外のすべての手法は、データの Delaunay 三角形分割に基づいて
% います。
% METHOD が [] の場合、デフォルトの 'linear' メソッドが使用されます。
%
% [...] = GRIDDATA(X,Y,Z,XI,YI,METHOD,OPTIONS) は、DELAUNAYN により Qhull 
% のオプションとして使用されるように、文字列 OPTIONS のセル配列を指定します。
% OPTIONS が [] の場合、デフォルトの DELAUNAYN オプションが使用されます。
% OPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
%
% 参考 GRIDDATA3, GRIDDATAN, DELAUNAY, INTERP2, MESHGRID, DELAUNAYN.

%   Copyright 1984-2003 The MathWorks, Inc. 
