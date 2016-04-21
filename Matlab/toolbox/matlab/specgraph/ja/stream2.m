% STREAM2   2次元ストリームライン
% 
% XY = STREAM2(X,Y,U,V,STARTX,STARTY) は、ベクトルデータ U,V からスト
% リームラインを計算します。配列 X,Y は、U,V に対する座標を定義し、
% (MESHGRID で出力されるように)単調で2次元格子形でなければなりません。
% STARTX および STARTY は、ストリームラインの開始位置を定義します。頂点
% 配列のセル配列は、XY に出力されます。
% 
% XY = STREAM2(U,V,STARTX,STARTY )は、[M,N] = SIZE(U) のとき、
% [X Y]  = meshgrid(1:N,1:M) と仮定します。  
%
% XY = STREAM2(...,OPTIONS) は、ストリームラインの作成で使用されるオプ
% ションを設定します。OPTIONS は、ストリームラインのステップサイズと頂点
% の最大個数を含む1要素または2要素ベクトルとして指定されます。OPTIONS が
% 指定されないと、デフォルトのステップサイズは0.1(セルの1/10)で、デフォル
% トの頂点の最大個数は10000です。OPTIONS は、[stepsize] または
% [stepsize maxverts] のいずれかです。
% 
% 例題:
%      load wind
%      [sx sy] = meshgrid(80, 20:10:50);
%      streamline(stream2(x(:,:,5),y(:,:,5),u(:,:,5),v(:,:,5),sx,sy));
%
% 参考：STREAMLINE, STREAM3, CONEPLOT, ISOSURFACE, SMOOTH3, SUBVOLUME, 
%       REDUCEVOLUME. 


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:20 $
