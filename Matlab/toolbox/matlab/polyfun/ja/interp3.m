% INTERP3   3次元補間(table lookup)
% 
% VI = INTERP3(X,Y,Z,V,XI,YI,ZI) は、配列 XI, YI, ZI 内の点で、3次元関数 
% V の VI 値を求めるために補間を行います。XI, YI, ZI は、同じサイズの
% 配列またはベクトルでなければなりません。ベクトル引数が同じサイズでなく、
% 方向が混在する(例 行ベクトルと列ベクトル)場合は、MESHGRID に渡され、
% 配列Y1, Y2, Y3 を作成します。配列 X, Y, Z は、データ V が与えられる点を
% 指定します。
%
% VI = INTERP3(V,XI,YI,ZI) は、[M,N,P] = SIZE(V) のとき、X = 1:N、Y = 1:M、
% Z = 1:Pと仮定します。
% VI = INTERP3(V,NTIMES) は、再帰的に NTIMES 回、要素間の補間を繰り返
% すことより、V を拡張します。
% INTERP3(V) は、INTERP3(V,1) と同じです。
%
% VI = INTERP3(...,'method') は、補間手法を指定します。デフォルトは、
% 線形補間です。使用可能な手法は以下の通りです。
%
%   'nearest' - 最近傍的による補間
%   'linear'  - 線形補間
%   'cubic'   - キュービック補間
%   'spline'  - スプライン補間
%
% VI = INTERP3(...,'method',EXTRAPVAL) は、X, Y, Zで作成された領域の外側の
% VI の要素に対して使用する外挿法と値を指定するのに使います。
% こうして、VI は、X, Y, Z のそれぞれにより作成されていない、XI,YI 
% または ZI のいずれかの値について EXTRAPVAL に等しくなります。使用される 
% EXTRAPVAL に対して、メソッドが指定されなければなりません。デフォルトの
% メソッドは 'linear' です。 
%
% すべての補間法で、X, Y, Z は単調関数で、(MESHGRID で作成されるものと
% 同様に)格子形でなければなりません。X, Y, Z は、等間隔でない場合があり
% ます。
%
% たとえば、FLOW の粗い近似を作成し、細かいメッシュで補間します。   
% 
%       [x,y,z,v] = flow(10); 
%       [xi,yi,zi] = meshgrid(.1:.25:10,-3:.25:3,-3:.25:3);
%       vi = interp3(x,y,z,v,xi,yi,zi); % V is 31-by-41-by-27
%       slice(xi,yi,zi,vi,[6 9.5],2,[-2 .2]), shading flat
%      
% 参考：INTERP1, INTERP2, INTERPN, MESHGRID.


%   Copyright 1984-2004 The MathWorks, Inc.
