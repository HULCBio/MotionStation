% CAMVA   カメラの視点の角度
% 
% CVA = CAMVA               カレントのaxesのカメラの視点の角度を取得
%                           します。
% CAMVA(val)                カメラの視点の角度を設定します。
% CVAMODE = CAMVA('mode')   カメラの視点の角度モードを取得します。
% CAMVA(mode)               カメラの視点の角度モードを設定します
%                           (mode は、'auto'、'manual' のいずれかです)
% CAMVA(AX,...)             カレントのaxesの代わりに軸 AX を使用します。
% 
% CAMVA は、軸の CameraViewAngle プロパティまたは CameraViewAngleMode 
% プロパティを設定あるいは取得します。
% 
% 参考：CAMPOS, CAMTARGET, CAMPROJ, CAMUP.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:43 $

