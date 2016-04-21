% SURFACE   surfaceオブジェクトの作成
% 
% SURFACE(X,Y,Z,C) は、カレントのaxesに X、Y、Z、C で指定したsurfaceを追加
% します。
% SURFACE(X,Y,Z) は、C = Z で、色はsurfaceの高さに比例します。
% X、Y、Z、C が取り得る種々の形式の詳細な説明は、SURF を参照してください。
% 
% SURFACE は、SURFACEオブジェクトのハンドル番号を出力します。
% SURFACE は、AXESオブジェクトの子です。
%
% SURFACE の引数の後に、surfaceのプロパティの指定のためにパラメータと値
% の組を指定できます。SURFACEの X、Y、Z、C 引数は、省略することができ、す
% べてのプロパティをパラメータと値の組を使って指定できます。
%
% AXIS、CAXIS、COLORMAP、HOLD、SHADING、VIEW は、SURFACE の表示に
% 影響を与えるfigure、axes、surfaceのプロパティを設定します。
%
% H がsurfaceのハンドル番号のとき、surfaceオブジェクトのプロパティとそれら
% のカレントの値を見るためには、GET(H) を実行してください。surfaceオブジェ
% クトのプロパティのリストと設定できるプロパティ値を見るためには、SET(H)
% を実行してください。
%
% 参考：SURF, LINE, PATCH, TEXT, SHADING.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:56:16 $
%   Built-in function.
