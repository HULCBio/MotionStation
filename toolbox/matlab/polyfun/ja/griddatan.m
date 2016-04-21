%GRIDDATAN 3次元以上のデータに対するグリッド化とハイパーサーフェス
%             フィッティング
%
% YI = GRIDDATAN(X,Y,XI) は、空間的に不均質に分布するベクトル (X, Y) の
% データに、Y = F(X) の型のハイパーサーフェスをフィッティングさせます。
% GRIDDATAN は、Z を作成するために、XI で設定された点でこのハイパー
% サーフェスを補間します。XI は、非一様になることができます。
%
% X は次元 m 行 n 列で、n-次元空間での m 点を表わします。Y はm 行 1 列の
% 次元で、ハイパーサーフェス F(X) のm 個の値を表現します。XI は、p行n列
% のベクトルで、フィッティングされるn-次元空間の表面の値を p 個の点で
% 表わします。YI は、値 F(XI)を近似する長さ p のベクトルです。ハイパー
% サーフェスは、常にデータ点 (X,Y) を通ります。XI は、通常は(MESHGRID 
% で作成するような)一様なグリッドです。
%
% YI = GRIDDATAN(X,Y,XI,METHOD) は、METHOD がつぎのいずれかで、データ
% へのサーフェスのフィッティングのタイプを選択できます。
%       'linear'    - 細分化をベースにした線形内挿 (デフォルト)
%       'nearest'   - 最近傍補間
% すべての手法は、データの Delaunay 三角形をベースにしています。
% METHOD が [] の場合、デフォルトの 'linear' メソッドが使用されます。
%
% YI = GRIDDATAN(X,Y,XI,METHOD,OPTIONS) は、DELAUNAYN により 
% Qhull のオプションとして使用されるように、文字列 OPTIONS のセル配列を
% 指定します。
% OPTIONS が [] の場合、デフォルトのオプションが使用されます。
% OPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
%
% 参考 GRIDDATA, GRIDDATA3, QHULL, DELAUNAYN, MESHGRID.

%   Copyright 1984-2003 The MathWorks, Inc.
