% ISONORMALS   等特性サーフェスの法線
% 
% N = ISONORMALS(X,Y,Z,V,VERTICES) は、データ V の勾配を使って、等特性
% サーフェスの頂点 VERTICES の法線を計算します。配列 X、Y、Z は、データ 
% V が与えられる点を指定します。法線は N に出力されます。デフォルトでは、
% 法線はより小さなデータ値の方向を向いています。
% 
% N = ISONORMALS(V,VERTICES) は、[M,N,P] = SIZE(V) のとき 
% [X Y Z] = meshgrid(1:N,1:M,1:P) と仮定します。
% 
% N = ISONORMALS(V,P) または N = ISONORMALS(X,Y,Z,V,P) は、patch P から
% 頂点を使用します。
% 
% N = ISONORMALS(...、'negate') は、計算された法線を無効にします。
% 
% ISONORMALS(V,P) または ISONORMALS(X,Y,Z,V,P) は、計算された法線をもち、
% P で指定されたpatchの 'VertexNormals' プロパティを設定します。
%
% 例題:
%      data = cat(3, [0 .2 0; 0 .3 0; 0 0 0], ...
%                    [.1 .2 0; 0 1 0; .2 .7 0],...
%                    [0 .4 .2; .2 .4 0;.1 .1 0]);
%      data = interp3(data,3, 'cubic');
%      subplot(1,2,1)
%      p = patch(isosurface(data, .5), 'FaceColor', 'red', ....
%                 'EdgeColor', 'none');
%      view(3); daspect([1 1 1]);axis tight
%      camlight;  camlight(-80,-10); lighting p; 
%      title('Triangle Normals')
%      subplot(1,2,2)
%      p = patch(isosurface(data, .5), 'FaceColor', 'red', ....
%                     'EdgeColor', 'none');
%      isonormals(data,p)
%      view(3); daspect([1 1 1]); axis tight
%      camlight;  camlight(-80,-10); lighting phong; 
%      title('Data Normals')
%
% 参考：ISOSURFACE, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 02:05:20 $
