% CAMTARGET   カメラのターゲット
% 
% CT = CAMTARGET               カレントのaxesのカメラターゲットを取得
%                              します。
% CAMTARGET([X Y Z])           カメラターゲットを設定します。
% CTMODE = CAMTARGET('mode')   カメラターゲットモードを取得します。
% CAMTARGET(mode)              カメラターゲットモードを設定します
%                              (modeは、'auto'、'manual' のいずれかです)
% CAMTARGET(AX,...)            カレントのaxesの代わりに AX を使用します。
%
% CAMTARGET は、axesの CameraTarget プロパティまたは Camera TargetMode 
% プロパティを設定あるいは取得します。
%
% 参考：CAMPOS, CAMVA, CAMPROJ, CAMUP.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:41 $

