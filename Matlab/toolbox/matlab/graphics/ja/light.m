% LIGHT   lightオブジェクトの作成
% 
% LIGHT は、すべてのプロパティをデフォルト値に設定したLIGHTオブジェクトを、
% カレントのaxesに追加します。
% 
% LIGHT(Param1、Value1、...、ParamN、ValueN) は、プロパティ Param1-ParamN
% の組に対して、Value1-ValueN で指定した値に設定したLIGHTオブジェクトを、
% カレントのaxesに追加します。
% 
% L = LIGHT(...) は、LIGHTオブジェクトのハンドル番号を出力します。
%
% LIGHTオブジェクトは、AXESオブジェクトの子です。LIGHTオブジェクトは、
% 描画されませんが、SURFACEとPATCHオブジェクトの外観に影響を与えます。
% LIGHTオブジェクトの影響は、Color、Style、Position、Visible を含むLIGHT
% のプロパティによって制御されます。ライトの位置は、データ範囲内です。
%
% SURFACEとPATCHオブジェクト上のLIGHTオブジェクトの効果は、AXESのプロ
% パティ AmbientLightColor と、SURFACEとPATCHのプロパティ AmbientStrength、
% DiffuseStrength、SpecularColorReflectance、SpecularExponent、
% SpecularStrength,VertexNormals、EdgeLighting、FaceLightingにより制御
% されます。
%
% figureのRendererは、LIGHTオブジェクトを有効にするために、'zbuffer'、
% または 'OpenGL' のいずれかに設定されていなければなりません(または、
% figureのRendererMode は、'auto' に設定しなければなりません)。
% ライティングの計算は、Renderer が 'painters' に設定されているときは
% 行われません。
%
% H がLIGHTのハンドル番号のとき、LIGHTオブジェクトのプロパティのリストと、
% そのカレント値を見るためには、GET(H) を実行してください。LIGHTオブジェ
% クトのプロパティと設定できるプロパティ値を見るためには、SET(H) を実行し
% てください。
%
% 参考：LIGHTING, MATERIAL, CAMLIGHT, LIGHTANGLE, SURF, PATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:56 $
%   Built-in function.
