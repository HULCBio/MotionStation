%INTERP1 1次元補間(table lookup)
% YI = INTERP1(X,Y,XI) は、ベクトル または 配列 XI 内の点での関数 Y の値
% Y1 を求めるために補間を行います。X は、長さ N のベクトルで SIZE(Y,1) は
% N である必要があります。Y がサイズ [N,M1,M2,...,Mk] の配列の場合、Y の
% 各M1×M2×...Mk の値に対して、補間が行われます。XI がサイズ
% [D1,D2,...,Dj] の配列の場合、YI は、サイズ [D1,D2,...,Dj,M1,M2,...,Mk]
% になります。
%
% YI = INTERP1(Y,XI) は、X = 1:N と仮定します。ここで、N はベクトル Y に
% 対しては length(Y) で、配列 Y に対しては SIZE(Y,1) です。
%
% 補間は、"table lookup" と同じ演算を行います。"table lookup"の用語で説明
% すると、"table"は [X,Y] で、INTERP1 は X の XI の要素を"looks-up"し、
% それらの位置に基づいて Y の要素内で補間された値 YI を出力します。
%
% YI = INTERP1(X,Y,XI,'method') は、補間手法を指定します。デフォルトは、
% 線形補間です。使用可能な手法は以下の通りです。
%
%   'nearest' - 最近傍点による補間
%   'linear'  - 線形補間
%   'spline'  - キュービックスプライン補間(SPLINE)
%   'pchip'   - shape-preserving の区分的キュービック補間
%   'cubic'   - キュービック補間
%   'v5cubic' - MATLAB 5 のキュービック補間、これは、X が等間隔でない
%               場合は外挿できず、 'spline'を利用します。
%
% YI = INTERP1(X,Y,XI,'method','extrap') は、X で作成された区間の外側の
% XI の要素に対して使用する外挿法を指定するのに使います。
% また、YI = INTERP1(X,Y,XI,'method',EXTRAPVAL) は、EXTRAPVAL を使って、
% X で作成された区間の外側の値を置き換えます。
% EXTRAPVAL に対しては、NaN と 0 がしばしば使用されます。4つの入力引数を
% もつデフォルトの外挿法は、'spline' と 'pchip' に対しては 'extrap' で、
% 他の方法に対しては EXTRAPVAL = NaN です。
%
% PP = INTERP1(X,Y,'method','pp') は、Y の ppform (piecewise polynomial form)
% を作成するために、指定したメソッドを使用します。メソッドは、'v5cubic' 
% 以外では、上記のいずれかとなります。
%
% たとえば、粗い正弦波を作成し、細かい横軸上で内挿します。
%       x = 0:10; y = sin(x); xi = 0:.25:10;
%       yi = interp1(x,y,xi); plot(x,y,'o',xi,yi)
%
% 多次元の例として、functional values の表を作成します。
%       x = [1:10]'; y = [ x.^2, x.^3, x.^4 ]; 
%       xi = [ 1.5, 1.75; 7.5, 7.75]; yi = interp1(x,y,xi);
%
% は、3 つの関数各々について1つずつ、補間した関数値の2行2列の行列を
% 作成します。yi は、サイズが 2×2×3 となります。
%
%   入力 X, Y, XI に対するサポートクラス: 
%      float: double, single
%  
% 参考 INTERP1Q, INTERPFT, SPLINE, INTERP2, INTERP3, INTERPN.

%   Copyright 1984-2004 The MathWorks, Inc.
