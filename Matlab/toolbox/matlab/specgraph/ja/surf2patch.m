% SURF2PATCH   サーフェスデータをパッチデータに変換
% 
% FVC = SURF2PATCH(S) は、SURFACEオブジェクト S の幾何学データとカラー
% データをPATCH形式に変換します。構造体 FVC は、パッチデータの面、頂点、
% カラーを含み、PATCHコマンドに直接渡すことができます。
% 
% FVC = SURF2PATCH(Z) は、ZData行列 Z からパッチデータを計算します。
% 
% FVC = SURF2PATCH(Z,C) は、ZDataおよびCdata行列 Z および C からパッチ
% データを計算します。
% 
% FVC = SURF2PATCH(X,Y,Z) は、XData、YData、ZData行列 X、Y、Z からパッチ
% データを計算します。
% 
% FVC = SURF2PATCH(X,Y,Z,C) は、XData、YData、ZData、Cdata行列 X、Y、
% Z、C からパッチを計算します。
% 
% FVC = SURF2PATCH(...,'triangles' )は、四辺形の代わりに三角形の面を作成
% します。
% 
% [F、V、C] = SURF2PATCH(...) は、面、頂点、カラーを構造体の代わりに3つの
% 配列に出力します。
%
% 例題1:
% 
%    [x y z] = sphere; 
%    patch(surf2patch(x,y,z,z)); 
%    shading faceted; view(3)
% 
% 例題2:
%    s = surf(peaks);
%    pause;
%    patch(surf2patch(s));
%    delete(s);
%    shading faceted; view(3)
%
% 参考：REDUCEPATCH, SHRINKFACES.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:28 $
