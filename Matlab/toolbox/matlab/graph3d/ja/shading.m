% SHADING   カラーシェーディングモード
% 
% SHADING は、SURFACEとPATCHオブジェクトのカラーシェーディングを制御し
% ます。
% SURFACEとPATCHオブジェクトは、関数 SURF、MESH、PCOLOR、FILL、FILL3
% により作成されます。 
%
% SHADING FLAT は、カレントのグラフのシェーディングをflatに設定します。
% SHADING INTERP は、シェーディングをinterpolatedに設定します。
% SHADING FACETED は、シェーディングをfacetedに設定します。これは、
% デフォルトです。
%
% Flatシェーディングは、区分的に双一次です。各メッシュのラインセグメントや
% サーフェスのパッチは、セグメントの終点または最小のインデックスをもつ
% patchの隅のカラー値で指定される一定のカラーに設定します。   
%
% Interpolatedシェーディングは、Gourandシェーディングとしても知られてい
% ますが、区分的に線形です。各セグメントのカラーまたはパッチは、線形
% に変化し、最後のカラーまたは隅の値を補間します。
%
% Facetedシェーディングは、黒のメッシュラインを重ねたflatシェーディング
% です。これは、最も効果的になることが多く、デフォルトになっています。
%
% SHADING(AX,...) は、カレントのaxesの代わりに AX を使用します。
%
% SHADING は、カレントのaxesのすべてのSURFACEオブジェクトの EdgeColor 
% と FaceColor プロパティを設定するM-ファイルです。これらのプロパティは、
% SURFACEオブジェクトがメッシュとサーフェスのどちらを表しているかに基
% づいた、正しい値に設定されます。
%
% 参考：HIDDEN, SURF, MESH, PCOLOR, FILL, FILL3, SURFACE, PATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:12 $
