% ELLIPSOID  楕円面の作成
%
% [X,Y,Z]=ELLIPSOID(XC,YC,ZC,XR,YR,ZR,N) は、3つの (N+1)行(N+1)列の行列を
% 作成します。そして、SUFRF(X,Y,Z) により、中心(XC,YC,ZC) で、半径 XR,  
% YR, ZR をもつ楕円面を作成します。
% 
% [X,Y,Z] = ELLIPSOID(XC,YC,ZC,XR,YR,ZR) は、N = 20 を使用します。
%
% ELLIPSOID(...) と ELLIPSOID(...,N) で、出力引数を設定しないものは、
% SURFACE と同様な楕円面を表示し、出力を行いません。
%
% ELLIPSOID(AX,...) は、GCAの代わりにAXにプロットします。
%
% 楕円面データは、つぎの方程式を使って作成されます。
%
%  (X-XC)^2     (Y-YC)^2     (Z-ZC)^2
%  --------  +  --------  +  --------  =  1
%    XR^2         YR^2         ZR^2
%
% 参考： SPHERE, CYLINDER.


% Laurens Schalekamp and Damian T. Packer
% Copyright 1984-2002 The MathWorks, Inc. 
