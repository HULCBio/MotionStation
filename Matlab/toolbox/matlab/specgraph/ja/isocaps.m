% ISOCAPS  等特性エンドキャップを計算
% 
% FVC = ISOCAPS(X,Y,Z,V,ISOVALUE) は、データ V に対する等特性サーフェス
% 値 ISOVALUE 等特性サーフェスエンドキャップを計算します。配列 X,Y,Z は
% 与えられたデータ V の点を設定します。構造体 FVC は、エンドキャップの
% フェース、頂点、カラーを含み、PATCH コマンドに直接渡すことができます。
% 
% FVC = ISOCAPS(V,ISOVALUE) は、つぎのステートメントを仮定しています。
% 
%    [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
%        
% ここで、[M,N,P] = SIZE(V) です。 
% 
% FVC = ISOCAPS(X,Y,Z,V) または FVC = ISOCAPS(V) は、データのヒストグラム
% を使って、自動的に等特性値を選択します。
% 
% FVC = ISOCAPS(..., ENCLOSE) では、ENCLOSE がエンドキャップが、
% ISOVALUEの上('above' デフォルト)または下('below')のデータを含む場合を
% 設定します。
% 
% FVC = ISOPCAPS(..., WHICHPLANE) では、WHICHPLANE が、エンドキャップ
% が描画される平面または平面群を指定します。WHICHPLANE は、 'all'(デフォ
% ルト), 'xmin', 'xmax', 'ymin', 'ymax', 'zmin', 'zmax' のいずれかを
% 設定します。
% 
% [F, V, C] = ISOCAPS(...) は、構造体の代わりに3つの配列にフェース、頂点、
% カラーを出力します。
% 
% ISOCAPS(...) は、出力引数を設定しないで使用すると、計算したフェース、
% 頂点、カラーからパッチが作られます。
%
% 例題：
%      load mri
%      D = squeeze(D);
%      D(:,1:60,:) = [];
%      p = patch(isosurface(D, 5), 'FaceColor', 'red',....
%               'EdgeColor', 'none');
%      p2 = patch(isocaps(D, 5), 'FaceColor', 'interp', ....
%                  'EdgeColor', 'none');
%      view(3); axis tight;  daspect([1 1 .4])
%      colormap(gray(100))
%      camlight; lighting gouraud
%      isonormals(D, p);
%
% 参考：ISOSURFACE, ISONORMALS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%       REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:18 $
