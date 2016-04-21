% SMOOTH3   3次元データの平滑化
% 
% W = SMOOTH3(V) は、入力データ V を平滑化します。平滑化されたデータは、
% W に出力されます。
% 
% W = SMOOTH3(V、'filter') で、Filterは 'gaussian' または 'box'(デフォルト)
% で、コンボリューションカーネルを指定します。
% 
% W = SMOOTH3(V、'filter'、SIZE) は、コンボリューションカーネルのサイズを
% 設定します(デフォルトは [3 3 3] です)。SIZE がスカラの場合、サイズは 
% [SIZE SIZE SIZE] として解釈されます。
% 
% W = SMOOTH3(V、'filter'、SIZE、ARG) は、コンボリューションカーネルの
% 属性を設定します。フィルタが 'gaussian' のとき、ARG は標準偏差です
% (デフォルトは.65です)。
%
% 例題:
% 
%      data = rand(10,10,10);
%      data = smooth3(data,'box',5);
%      p = patch(isosurface(data,.5), ...
%          'FaceColor', 'blue', 'EdgeColor', 'none');
%      p2 = patch(isocaps(data,.5), ...
%          'FaceColor', 'interp', 'EdgeColor', 'none');
%      isonormals(data,p)
%      view(3); axis vis3d tight
%      camlight; lighting phong
%
% 参考：ISOSURFACE, ISOCAPS, ISONORMALS, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:14 $
