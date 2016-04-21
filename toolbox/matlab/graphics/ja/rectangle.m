% RECTANGLE   長方形、角の丸い長方形、楕円の作成
% 
% RECTANGLE は、カレントのaxesにデフォルトの長方形を追加します。
% RECTANGLE('Position'、[x y w h]) は、指定した位置に長方形を追加します。
% 
% RECTANGLE('Curvature'、[0 0]、...) は、長方形を作成します。
% RECTANGLE('Curvature'、[1 1]、...) は、楕円を作成します。
% RECTANGLE('Curvature'、[x y]、...) は、x と y が0と1の間の数値で正規化
% された曲率を表わすとき、角の丸い長方形を作成します。水平方向の曲率(x)
% は、カーブしている位置を表わす長方形の幅の割合です。垂直方向の曲率(y)
% は、カーブしている位置を表わす長方形の高さの割合です。
%
% RECTANGLE は、RECTANGLEオブジェクトのハンドルを出力します。
% RECTANGLEs は、AXESオブジェクトの子オブジェクトです。
%
% RECTANGLEオブジェクトは、axesのViewの角度が [0 90] 以外では描画しま
% せん。
%
% H が長方形のハンドルのとき、GET(H) を実行するとrectangleオブジェクトの
% プロパティとそのカレント値のリストを見ることができます。SET(H) を実行
% すると、rectangleオブジェクトのプロパティと設定できるプロパティ値の
% リストを見ることができます。
%
% 参考：LINE, PATCH, TEXT, PLOT, PLOT3.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:56:06 $
%   Built-in function.
