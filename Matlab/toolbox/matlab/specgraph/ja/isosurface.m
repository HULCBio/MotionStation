% ISOSURFACE   等特性サーフェスの抽出
% 
% FV = ISOSURFACE(X,Y,Z,V,ISOVALUE) は、等特性サーフェスの値ISOVALUE で、
% データ V に対する等特性サーフェスの形を計算します。配列 (X,Y,Z) は、
% データ V が与えられる点を指定します。構造体 FV は、等特性サーフェスの
% 面と頂点を含み、PATCHコマンドに直接渡されます。
% 
% FV = ISOSURFACE(V,ISOVALUE) は、[M,N,P] = SIZE(V) のとき、
% [X Y Z] = meshgrid(1:N,1:M,1:P) と仮定します。
% 
% FV = ISOSURFACE(X,Y,Z,V) または FV = ISOSURFACE(V) は、データのヒスト
% グラムを使って、等特性サーフェスの値を自動的に選択します。
% 
% FVC = ISOSURFACE(..., COLORS) は、配列 COLORS をスカラ場に内挿し、
% 内挿された値を FACEVERTEXCDATA に返します。COLORS 配列のサイズは、
% V と同じです。
% 
% FV = ISOSURFACE(...、'noshare') は、共有される頂点を作成しません。この
% 方法は、処理速度は速いですが、出力される頂点の数は多くなります。
% 
% FV = ISOSURFACE(...、'verbose') は、計算の進行に従って、コマンドウィン
% ドウに進行のメッセージを表示します。
% 
% [F、V] = ISOSURFACE(...) または [F, V, C] = ISOSURFACE(...) は、面と
% 頂点を構造体の代わりに、配列に出力します。
% 
% ISOSURFACE(...)は、出力引数を設定しないと、計算した面や頂点を使って、
% patchが作成されます。
% 
% 例題 1：
%      [x y z v] = flow;
%      p = patch(isosurface(x, y, z, v, -3));
%      isonormals(x,y,z,v, p)
%      set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
%      daspect([1 1 1])
%      view(3)
%      camlight; lighting phong
%
% 例題 2:
%      [x y z v] = flow;
%      q = z./x.*y.^3;
%      p = patch(isosurface(x, y, z, q, -.08, v));
%      isonormals(x,y,z,q, p)
%      set(p, 'FaceColor', 'interp', 'EdgeColor', 'none');
%      daspect([1 1 1]); axis tight; 
%      colormap(prism(28))
%      camup([1 0 0 ]); campos([25 -55 5]) 
%      camlight; lighting phong
%       
%
% 参考：ISONORMALS, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH, SHRINKFACES.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:21 $
