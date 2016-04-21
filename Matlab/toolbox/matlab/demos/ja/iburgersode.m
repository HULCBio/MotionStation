%IBURGERSODE  implicit ODE systemとして解かれる Burgers 方程式
% IBURGERSODE(N) は、つぎのBurgers 方程式を解きます。N点の(移動)メッシュ上で、
% u(x,0) = sin(2*pi*x) + 0.5*sin(pi*x) および u(0,t) = 0, u(1,t) = 0 を
% 条件とし、0 <= x <= 1 において、Du/Dt = 1e-4 * D^2 u/Dx^2 - D(0.5u^2)/Dx.
% これは、つぎの論文の Problem 2 です。
% W. Huang, Y. Ren, and R.D. Russell, Moving mesh methods based on moving 
% mesh partial differential equations, J. Comput. Phys. 113(1994) 279-290. 
%
% この論文では、Burger 方程式は、(19) で概略が述べられたように、
% 中心差分により離散化され、用いた移動メッシュ PDE は、tau = 1e-3 
% としたMMPDE6です。図 6 は、N = 20 の場合の解を示し、gamma = 2 ，
% p = 2として特別な平滑化が行われます。この問題は、相対許容誤差 
% 1e-5 と絶対許容誤差 1e-4 を用いて解かれました。 
%  
% この例では、解をプロットしたものは図6 に似ていますが、初期データも
% プロットされ、問題が t = 1 でのみ積分されているので、実行時間も少なく
% なっています。離散化された問題は、fully implicit system f(t,y,y') = 0 
% として解かれます。解のベクトルは、y = (a1,...,aN,x1,...,xN)です。
% 時刻 t で、aj は、偏微分方程式の解 u(t,xj) を近似します。
% メッシュ点 xj は、時間 (移動メッシュ)の関数です。厳密な導関数 df/dy' 
% を与え、df/dy にスパースパターンを指定すると、実行時間が大幅に減少します。
%
%   参考 ODE15I, BURGERSODE, ODESET, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
