% INTERPN   N次元補間(table lookup)
% 
% VI = INTERPN(X1,X2,X3,...,V,Y1,Y2,Y3,...) は、配列 Y1, Y2, Y3...の点で
% N次元関数 V の値 VI を求めるために補間を行います。N次元配列 V に対して、
% INTERPN は 2*N+1個の引数を使って呼び出されます。配列 X1, X2, X3...は、
% データ V が与えられる点を指定します。範囲外の値は、NaNとして出力され
% ます。Y1, Y2, Y3...は、同じサイズの配列またはベクトルでなければなりません。
% ベクトル引数が同じサイズでなく、方向が混在する(例 行ベクトルと列ベクトル)
% 場合は、MESHGRID に渡され、配列Y1, Y2, Y3 を作成します。INTERPN は、
% 2次元以上のN次元配列に対して機能します。
%
% VI = INTERPN(V,Y1,Y2,Y3,...) は、X1 = 1:SIZE(V,1),X2 = 1:SIZE(V,2)...と
% 仮定します。VI = INTERPN(V,NTIMES) は、再帰的に NTIMES 回、要素間の
% 補間を繰り返すことにより、V を拡張します。
% VI = INTERPN(V) は、INTERPN(V,1) と同じです。
%
% VI = INTERPN(...,'method') は、補間手法を指定します。デフォルトは、
% 線形補間です。使用可能な手法は以下の通りです。
% 
%   'linear'  - 線形補間
%   'cubic'   - キュービック補間
%   'nearest' - 最近傍点による補間
%   'spline'  - スプライン補間
%   
% VI = INTERPN(...,'method',EXTRAPVAL) は、X1,X2,... で作成された領域の外側の
% VI の要素に対して使用する外挿法と値を指定するのに使います。こうして、VI は
% X1,X2,... のそれぞれにより作成されていない、Y1,Y2,.. のいずれかの値について 
% EXTRAPVAL に等しくなります。使用される EXTRAPVAL に対して、メソッドが指定され
% なければなりません。デフォルトのメソッドは 'linear' です。
%
% INTERPNは、X1, X2, X3...が単調関数で、(NDGRID で作成されるものと同様
% な)格子形でなければなりません。X1, X2, X3...は、等間隔でない場合が
% あります。
%
% データ入力のサポートクラス: 
%      float: double, single
%
% 参考 INTERP1, INTERP2, INTERP3, NDGRID.

%   Copyright 1984-2004 The MathWorks, Inc.

