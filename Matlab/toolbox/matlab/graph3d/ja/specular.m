% SPECULAR   鏡面反射
% 
% R = SPECULAR(Nx,Ny,Nz,S,V) は、法線ベクトルの要素 [Nx,Ny,Nz] を使って、
% サーフェスの反射を出力します。S と V は、光源および視点への方向を各々
% 指定します。 S と V は、3つのベクトル [x,y,z] または2つのベクトル
% [Theta Phi] (球面座標)です。
%
% 鏡面の強調は、S が光源の方向で V が視点方向とすると、法線ベクトルが
% (S+V)/2 の方向のときに最も強くなります。
%
% サーフェスの拡がり指数は、specular(Nx,Ny,Nz,S,V,spread) として6番目の
% 引数によって設定されます。
%
% 参考：DIFFUSE, SURFNORM, SURFL.


%   Clay M. Thompson 5-1-91
%   Revised 4-21-92 by cmt
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:13 $
