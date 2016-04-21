% SUBVOLUME   体積データセットのサブセットの抽出
% 
% [NX、NY、NZ、NV] = SUBVOLUME(X,Y,Z,V,LIMITS) は、指定した軸の LIMITS
% を使って、体積データセット V のサブセットを抽出します。
% LIMITS = [xmin xmax ymin ymax zmin zmax] です(limits 内の任意のNaNは、
% 体積が軸に沿って切り取られないことを意味します)。配列 X,Y,Z は、データ
% V が与えられる点を指定します。抽出された体積は NV に出力され、抽出
% された体積の座標は NX、NY、NZ に出力されます。
%
% [NX、NY、NZ、NV] = SUBVOLUME(V,LIMITS) は、[M,N,P] = SIZE(V) のとき、
% [X YZ] = meshgrid(1:N、1:M、1:P) と仮定します。
% 
% [NX, NY, NZ, NU, NV, NW] = SUBVOLUME(X,Y,Z,U,V,W,LIMITS) は、ベクトル
% データベース U,V,W からサブセットを抽出します。
%
% [NX, NY, NZ, NU, NV, NW] = SUBVOLUME(U,V,W,LIMITS) は、
% [M,N,P]=SIZE(U) のときに、[X Y Z] = meshgrid(1:N, 1:M, 1:P) を仮定して
% います。
% 
% NV = SUBVOLUME(...) または [NU, NV, NW] = SUBVOLUME(...) は、抽出された
% 体積のみを出力します。
%
%   例題 1:
%      load mri
%      D = squeeze(D);
%      [x y z D] = subvolume(D, [60 80 nan 80 nan nan]);
%      p = patch(isosurface(x,y,z,D, 5), 'FaceColor', 'red', ....
%          'EdgeColor', 'none');
%      p2 = patch(isocaps(x,y,z,D, 5), 'FaceColor', 'interp',...
%         'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(x,y,z,D,p);
%
%   例題 2:
%      load wind
%      [x y z u v w] = subvolume(x,y,z,u,v,w,[105 120  nan 30  2 6]);
%      streamslice(x,y,z,u,v,w,[],[],[3 4 5], .4);
%      daspect([1 1 .125])
%      h = streamtube(x,y,z,u,v,w,110,22,5.5);
%      set(h, 'FaceColor', 'red', 'EdgeColor', 'none')
%      axis tight
%      view(3)
%      camlight; lighting gouraud
%
% 参考：ISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, REDUCEVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:27 $
