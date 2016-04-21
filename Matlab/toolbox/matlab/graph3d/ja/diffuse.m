% DIFFUSE   拡散反射
% 
% R = DIFFUSE(Nx,Ny,Nz,S) は、法線ベクトル成分 [Nx,Ny,Nz] をもつサーフェス
% の反射を出力します。S は、光源の方向を定義する3要素のベクトルです。S は、
% 球面座標系で方向を指定する2要素のベクトル S = [Theta Phi] でも構いません。
%
% Lambertの法則：PSI が、サーフェスの法線と光源との間の角度のとき、
% R = cos(PSI) となります。
%
% 参考：SPECULAR, SURFNORM, SURFL.


%   Clay M. Thompson 5-1-91
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:52 $
