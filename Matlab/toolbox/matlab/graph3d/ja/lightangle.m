% LIGHTANGLE   lightオブジェクトの球面座標系の位置
%
% LIGHTANGLE(AZ、EL)       カレントのaxesの指定した位置でlightオブジェ
%                          クトを作成します。
% H = LIGHTANGLE(AZ、EL)   lightを作成し、lightのハンドル番号を H に
%                          出力します。
% LIGHTANGLE(H、AZ、EL)    指定したlightの位置を設定します。
% [AZ EL] = LIGHTANGLE(H)  指定したlightの位置を取得します。
%
% LIGHTANGLE は、方位角と仰角を使ってlightを作成し、配置します。AZ は、
% 方位角または水平方向の回転で、EL は垂直回転(どちらも角度)です。 
% 方位角と仰角の解釈は、VIEW コマンドとまったく同じです。lightが作成
% されるとき、そのスタイルは 'infinite' です。lightangle に与えられた
% lightがローカルなlightの場合、lightとカメラのターゲット間の距離は
% 保存されます。
%
% 参考：LIGHT, CAMLIGHT, LIGHTING, MATERIAL, VIEW.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:01 $

