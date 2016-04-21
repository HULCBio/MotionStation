% BURGERSODE  Burger方程式を、移動メッシュ化法(moving mesh technique)を
%             使って解きます。
% 
% BURGERSODE(N) は、N点の(移動)メッシュ上で、
% u(x,0) = sin(2*pi*x) + 0.5*sin(pi*x) および u(0,t) = 0,u(1,t) = 0 を
% 条件とし、0 <= x <= 1において、Burger方程式 
% 　　　 Du/Dt = 1e-4*D^2 u/Dx^2 - D(0.5u^2)/Dx　　
% を解きます。これは、つぎの Problem 2 です。
% 
% W. Huang, Y. Ren, and R.D. Russell, Moving mesh methods based on
% moving mesh partial differential equations, J. Comput. Phys. 113(1994)
% 279-290.
% 
% この論文では、Burger 方程式は、(19)で展開しているように中央差分で
% 離散化して、使用される移動メッシュ PDE は、tau = 1e-3 である MMPDE6 です。
% 図 6 は、N = 20 で、gamma = 2 ,p = 2 で空間平滑化が行われたものです。
% そして、相対誤差許容範囲 1e-5、絶対誤差許容範囲 1e-4 が使われます。
%
% この例では、解をプロットしたものは図6 に似ていますが、初期データも
% プロットされ、問題が t = 1 でのみ積分されているので、実行時間も少なく
% なっています。解ベクトルを、y = (a1,...,aN,x1,...,xN)とします。
% 時刻 t で、aj はPDEの解 u(t,xj) を近似します。メッシュ点 xj は
% 時間の関数で解かれる ODEの中の y に、質量行列の強い依存性をもたらせます。
% この例題において、質量行列の強い状態依存性を認識しスパース性を考慮することは、% 非常に有効なことです。
%
% 注意 : この変数の順番付けは、方程式のコード化に便利ですが、帯行列を
% 利用できないという欠点をもっています。これは、LSODI または DASSL と
% ode15s を区別します。一般的なスパース行列に対して与えられず、また 
% dF/dy と dMy/dy のスパースパターンの違いに対しても与えられません。
% この例題では、dMy/dy が dF/dy よりも大きいスパース性を示します。
%
% 参考：ODE15S, ODE23T, ODE23TB, ODESET, @.


%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
