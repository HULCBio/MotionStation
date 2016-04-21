%GRIDDATA3 3次元データ用のデータのグリッド化とハイパーサーフェス
%            フィッティング
% W = GRIDDATAN(X, Y, Z, V, XI, YI, ZI) は、空間的に不均質に分布する
% ベクトル (X, Y, Z, V) のデータに W = F(X,Y,Z) の型のハイパーサーフェス
% をフィッティングさせます。GRIDDATA3 は、W を作成するために、(XI,YI,ZI) 
% で指定される点でこのハイパーサーフェスを補間します。
%
% (XI,YI,ZI) は、通常(関数 MESHGRID で作成する)一様分布グリッドで、その
% ため GRIDDATA3 と名付けられています。
%
% [...] = GRIDDATA3(X,Y,Z,V,XI,YI,ZI,METHOD) は、METHOD が
%    'linear'    - 細分化をベースに線形補間 (デフォルト)
%    'nearest'   - 最近傍補間
%
% のいずれかのとき、データにフィッティングさせるサーフェスのタイプを
% 定義します。
% すべての方法は、データの Delaunay 三角形をベースにしています。
% METHOD が [] の場合、デフォルトの 'linear' メソッドが使用されます。
%
% [...] = GRIDDATA3(X,Y,Z,V,XI,YI,ZI,METHOD,OPTIONS) は、DELAUNAYN により 
% Qhull のオプションとして使用されるように、文字列 OPTIONS のセル配列を
% 指定します。
% OPTIONS が [] の場合、デフォルトのオプションが使用されます。
% OPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
%
% 入力 X,Y,Z,V,XI,YI,ZI のサポートクラス: double
%
% 参考 GRIDDATA, GRIDDATAN, QHULL, DELAUNAYN, MESHGRID.

%   Copyright 1984-2004 The MathWorks, Inc.
