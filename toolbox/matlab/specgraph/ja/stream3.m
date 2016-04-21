% STREAM3   3次元ストリームライン
% 
% XYZ = STREAM3(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) は、ベクトルデータ
% U,V,W からストリームラインを計算します。配列 X,Y,Z は、U,V,W に対する
% 座標を定義し、(MESHGRID で出力されるように)単調で3次元格子形でなければ
% なりません。STARTX、STARTY および STARTZ は、ストリームラインの開始
% 位置を定義します。頂点の配列のセル配列は、XYZ に出力されます。  
% 
% XYZ = STREAM3(U,V,W,STARTX,STARTY,STARTZ) は、[M,N,P] = SIZE(U) の
% とき [X Y Z] = meshgrid(1:N、1:M、1:P) と仮定します。
% 
% XYZ = STREAM3(...,OPTIONS) は、ストリームラインの作成で使用される
% オプションを設定します。OPTIONS は、ストリームラインのステップサイズと
% 頂点の最大個数を含む1要素または2要素ベクトルとして指定されます。OPTIONS 
% が指定されないと、デフォルトのステップサイズは0.1(セルの1/10)で、
% デフォルトの頂点の最大個数は10000です。OPTIONS は、[stepsize] または
% [stepsize maxverts] のいずれかです。
% 
% 例題:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      streamline(stream3(x,y,z,u,v,w,sx,sy,sz));
%      view(3);
%
% 参考：STREAMLINE, STREAM2, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME, 
%       REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:21 $
