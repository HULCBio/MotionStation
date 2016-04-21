% VOLUMEBOUNDS   物体データに対するx,y,z とカラーに関する範囲を出力
% 
% LIMS = VOLUMEBOUNDS(X,Y,Z,V) は、スカラデータに対するカレント軸のx,y,z
% とカラーの範囲を出力します。LIMS は、ベクトル [xmin xmax ymin ymax 
% zmin zmax cmin cmax] になります。このベクトルは、AXIS コマンドに渡され
% ます。
%
% LIMS = VOLUMEBOUNDS(X,Y,Z,U,V,W) は、ベクトルデータに対するカレント軸の
% x,y,z の範囲を出力します。LIMS は、ベクトル [xmin xmax ymin ymax zmin zmax]
% になります。
%
% VOLUMEBOUNDS(V)  または VOLUMEBOUNDS(U,V,W) は、つぎのステートメント
% を仮定しています。
% 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(V) です。 
%
% 例題:
% 
%      [x y z v] = flow;
%      p = patch(isosurface(x, y, z, v, -3));
%      isonormals(x,y,z,v, p)
%      daspect([1 1 1])
%      isocolors(x,y,z,flipdim(v,2),p)
%      shading interp
%      axis(volumebounds(x,y,z,v))
%      view(3)
%      camlight 
%      lighting phong
%
% 参考：ISOSURFACE, STREAMSLICE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:06:33 $
