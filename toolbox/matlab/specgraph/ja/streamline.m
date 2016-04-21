% STREAMLINE   2次元または3次元ベクトルデータからストリームラインを作成
% 
% H = STREAMLINE(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) は、3次元ベクトル
% データ U,V,W からストリームラインを作成します。配列 X,Y,Z は、U,V,W に
% 対する座標を定義し、(MESHGRID で出力されるように)単調で3次元格子形で
% なければなりません。STARTX、STARTY、および、STARTZ は、ストリームライン
% の開始位置を定義します。ラインのハンドルのベクトルが出力されます。
% 
% H = STREAMLINE(U,V,W,STARTX,STARTY,STARTZ) は、[M,N,P] = SIZE(U) の
% とき [X Y Z] = meshgrid(1:N、1:M、1:P) と仮定します。
% 
% H = STREAMLINE(XYZ) は、XYZ が(STREAM3 で出力されるような)前もって
% 計算された頂点の配列のセル配列であると仮定します。
% 
% H = STREAMLINE(X,Y,U,V,STARTX,STARTY) は、2次元ベクトルデータ U,V 
% からストリームラインを作成します。配列 X,Y は、U,V に対する座標を定義し、
% (MESHGRID で出力されるように)単調で2次元格子形でなければなりません。
% STARTX および STARTY は、ストリームラインの開始位置を定義します。
% ラインのハンドルのベクトルが出力されます。
% 
% H = STREAMLINE(U,V,STARTX,STARTY) は、[M,N] = SIZE(U) のとき、
% [X Y] = meshgrid(1:N, 1:M) と仮定します。
% 
% H = STREAMLINE(XY) は、XY が(STREAM2 で出力されたような)前もって計算
% された頂点の配列のセル配列であると仮定します。
% 
% STREAMLINE(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = STREAMLINE(...,OPTIONS) は、ストリームラインの作成に使用するオプ
% ションを設定します。OPTIONS は、ストリームラインのステップサイズと頂点の
% 最大個数を含む1要素または2要素のベクトルとして設定されます。OPTIONS が
% 指定されないと、デフォルトのステップサイズは0.1(セルの1/10)で、
% デフォルトの頂点の最大個数は10000です。
% OPTIONS は、[stepsize] または [stepsize maxverts] のいずれかです。
%
% H = STREAMLINE(...) は、lineオブジェクトのハンドルからなるベクトルを
% 出力します。
% 
% 例題:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      h=streamline(x,y,z,u,v,w,sx,sy,sz);
%      set(h, 'Color', 'red');
%      view(3);
%
% 参考：STREAM3, STREAM2, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME,
%       REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
