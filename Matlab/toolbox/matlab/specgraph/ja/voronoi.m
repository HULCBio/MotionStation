% VORONOI   Voronoi線図
%
% VORONOI(X,Y) は、点 X,Y に対するVoronoi線図をプロットします。
% 無限大の点を含むセルは、有界ではなく、プロットされません。
%
% VORONOI(X,Y,TRI) は、DELAUNAY で計算する代わりに、三角形分割 TRI を
% 使います。
%
% VORONOI(X,Y,OPTIONS) は、DELAUNAYでQhullのオプションとして用いられる
% 文字列のセル配列を指定します。
%   OPTIONSが[]の場合は、デフォルトのDELAUNAYオプションが用いられます。
%   OPTIONSは{''}の場合は、デフォルトも含め、オプションは用いられません。
%
% VORONOI(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = VORONOI(...,'LineSpec') は、指定したカラーとラインスタイルで、
% Voronoi線図をプロットし、作成されたlineオブジェクトのハンドル番号を 
% H に出力します。 
%
% [VX,VY] = VORONOI(...) は、Voronoi線図のエッジの頂点を VX と VY に出力
% します。出力された結果は、plot(VX,VY,'-',X,Y,'.') により、Voronoi線図を
% 作成します。
%
% Voronoi線図の型、すなわち、各voronoiセルの頂点について、 関数 VORONOIN 
% をつぎのように使います。
%
%         [V,C] = VORONOIN([X(:) Y(:)])
%
% 参考：VORONOIN, DELAUNAY, CONVHULL.


%   Copyright 1984-2002 The MathWorks, Inc. 
