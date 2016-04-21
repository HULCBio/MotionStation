% REDUCEVOLUME   体積データセットの削減
% 
% [NX、NY、NZ、NV] = REDUCEVOLUME(X,Y,Z,V,[Rx Ry Rz]) は、x方向の Rx 要素、
% y方向の Ry 要素、z方向の Rz 要素毎にデータを保持して、体積内の要素数を
% 減らします。3要素のベクトルの代わりに、削減数を表わすためにスカラ R が
% 使用される場合は、削減数は [R R R] と仮定されます。配列 X、Y、Z は、
% データ V が与えられる点を指定します。削減された体積は NV に出力され、
% 削減された体積の座標は NX、NY、NZ に出力されます。
% 
% [NX、NY、NZ、NV] = REDUCEVOLUME(V,[Rx Ry Rz]) は、[M,N,P] = SIZE(V)
% のとき、[X Y Z] = meshgrid(1:N, 1:M, 1:P) と仮定します。
%
% NV = REDUCEVOLUME(...) は、削減された体積のみを出力します。
%
% 例題:
%      load mri
%      D = squeeze(D);
%      [x y z D] = reducevolume(D, [4 4 1]);
%      D = smooth3(D);
%      p = patch(isosurface(x,y,z,D, 5,'verbose'), ...
%                'FaceColor', 'red', 'EdgeColor', 'none');
%      p2 = patch(isocaps(x,y,z,D, 5), 'FaceColor', 'interp',....
%               'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(x,y,z,D,p);
%
% 参考：ISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, SUBVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:35 $
