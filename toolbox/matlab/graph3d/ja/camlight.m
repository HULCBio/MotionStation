% CAMLIGHT   lightオブジェクトの作成と位置の設定
% 
% CAMLIGHT HEADLIGHT は、カレントaxesのカメラの位置にlightを作成します。
% CAMLIGHT RIGHT は、カメラの右上にlightを作成します。
% CAMLIGHT LEFT は、カメラの左上にlightを作成します。
% CAMLIGHT は、CAMLIGHT RIGHT と同じです。
% CAMLIGHT(AZ、EL )は、カメラから AZ、EL の位置にlightを作成します。
%
% CAMLIGHT(..., style) は、lightのスタイルを指定します。style は、
% 'local' (デフォルト)または'infinite'です。
%
% CAMLIGHT(H, ...) は、指定した位置に指定したlightを配置します。
% H = CAMLIGHT(...) は、lightのハンドル番号を出力します。
%
% CAMLIGHT は、カメラの座標系でlightを作成または配置します。たとえば、
% AZ と EL が共にゼロの場合は、lightはカメラの位置に配置されます。
% CAMLIGHT で作成したlightを、カメラに対して一定の位置に配置するために
% は、CAMLIGHT はカメラが移動するたびに呼び出されなければなりません。
%
% 参考：LIGHT, LIGHTANGLE, LIGHTING, MATERIAL, CAMORBIT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:33 $

