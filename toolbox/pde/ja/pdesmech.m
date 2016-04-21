% PDESMECH   構造力学のテンソル関数を計算します。
%
% OUT = PDESMECH(P,T,C,U,P1,V1,...) は、平面応力や平面歪みの構造力学アプ
% リケーションに対する応力と歪みであるテンソル表現を計算します。P と T 
% は、それぞれメッシュの節点と三角形行列です。C は、PDE 方程式の係数Cで、
% U は長さが2*節点数の PDE の解 [u; v] です。
%
% 有効なプロパティ/値の組合わせは、つぎの通りです。
%
%     tensor        {vonMises} | ux | uy | vx | vy | exx | eyy | exy |
%                    sxx | syy | sxy | e1 | e2 | s1 | s2
% 



%       Copyright 1994-2001 The MathWorks, Inc.
