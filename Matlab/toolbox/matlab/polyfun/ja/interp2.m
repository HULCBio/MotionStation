% INTERP2   2次元補間(table lookup)
% 
% ZI = INTERP2(X,Y,Z,XI,YI) は、行列 XI と YI 内の点で2次元関数 Z の値 
% ZI を求めるために補間を行います。行列 X と Y は、データ Z が与えられる
% 点を指定します。
%
% XI は、行ベクトルでも構いません。この場合、列要素が一定の値である行列と
% 考えられます。同様に、YI は列ベクトルでも構わず、行要素が一定の値である
% 行列と考えられます。
%
% ZI = INTERP2(Z,XI,YI) は、[M,N] = SIZE(Z) のとき、X = 1:N かつ Y = 1:M 
% であると仮定します。ZI = INTERP2(Z,NTIMES) は、再帰的に NTIMES 回、
% 要素間の補間を繰り返すことにより、Z を拡張します。INTERP2(Z) は、
% INTERP2(Z,1) と同じです。
%
% ZI = INTERP2(...,'method') は、補間手法を指定します。デフォルトは、
% 線形補間です。使用可能な手法は以下の通りです。
%
%   'nearest'  - 最近傍点による補間
%   'linear'   - 線形補間
%   'cubic'    - キュービック補間
%   'spline'   - スプライン補間
%
%
% ZI = INTERP2(...'method',EXTRAPVAL) は、X と Y で作成された領域の外側の
% ZI の要素に対して使用する外挿法とスカラー値を指定するのに使います。
% こうして、ZI は、Y または X のそれぞれにより作成されていない、YI または
% XI のいずれかの値について EXTRAPVAL に等しくなります。使用される EXTRAPVAL
% に対して、メソッドが指定されなければなりません。デフォルトのメソッドは
% 'linear' です。
%
% すべての補間法で、X と Y は単調関数で、(MESHGRID で作成されるものと
% 同様な)格子形でなければなりません。2つの単調ベクトルが与えられない場合、
% interp2 は、それらを内部的に配置します。X と Y は、等間隔でない場合が
% あります。
%
% たとえば、PEAKS の粗い近似を作成し、細かいメッシュで補間します。
% 
%     [x,y,z] = peaks(10); [xi,yi] = meshgrid(-3:.1:3,-3:.1:3);
%     zi = interp2(x,y,z,xi,yi); mesh(xi,yi,zi)
%
% 入力 X, Y, Z, XI, YI のサポートクラス  
%      float: double, single
% 
% 参考：INTERP1, INTERP3, INTERPN, MESHGRID, GRIDDATA.


%   Copyright 1984-2004 The MathWorks, Inc.

