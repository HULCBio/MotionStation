%THREEBVP  3点境界値問題
%
%   多点境界値問題(multipoint BVPs) のこの例は、つぎの論文に述べられた
%   生理学での流れの問題の研究によりもたらされたものです。
%   C.Lin and L.Segel, Mathematics Applied to Deterministic Problems 
%   in the Natural Sciences, SIAM, Philadelphia, PA, 1988.
%   [0, lambda] の x に対して、問題に対する方程式は、既知パラメータ 
%   n, kappa, と lambda > 1，eta = lambda^2/(n*kappa^2) に対して、
%
%       v' = (C - 1)/n
%       C' = (vC - min(x,1))/eta
%
%   です。C'(x) に対する方程式における項 min(x,1) は、x = 1 において
%   滑らかではありません。Lin と Segel は、この 境界値問題を2つの問題
%   として述べています。 1つは、[0, 1] 上に設定され、もう1つは 
%   [1, lambda]上に設定され、v(x) と C(x) が x = 1 で連続であることを
%   要求することによりつなげられます。この解は、境界条件 v(0) = 0 と 
%   C(lambda) = 1を満たすことになっています。BVP4C は、接点 x = 1で
%   内部条件を課し、3点境界値問題(three-point BVP)としてこの問題を
%   解きます。
%   
%　 この例は、n = 5e-2, lambda = 2, および 列 kappa = 2,3,4,5 
%   に対する問題を解きます。kappa の1つの値に対する解は、 つぎ
%   のものに対する推測として使用されます。
%
%   参考 BVP4C, BVPSET, BVPGET, BVPINIT, DEVAL, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
